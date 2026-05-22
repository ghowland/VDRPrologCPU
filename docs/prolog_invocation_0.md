# VDR-Prolog LLM→Prolog Invocation

## Technical Specification

---

## 1. Overview

The LLM does not execute Prolog directly. It emits command tokens that reference KB paths, rule IDs, and query patterns. The system parses these tokens, resolves them against the KB tree and relation index, and executes the Prolog operation. The result goes back to the LLM's scratch space for the next generation step.

The critical performance question is: how does the LLM know what Prolog rules and typed relations are available for a given query, and how does the system find the right ones fast enough to keep L2 invocation at ~18 tokens (~3% of L1 cost)?

This spec covers the scan, match, and dispatch pipeline from LLM intent to Prolog execution.

---

## 2. The Three Invocation Paths

### 2.1 L3 — Automatic, No LLM Involvement

The system fires Prolog rules and typed relation queries without the LLM. This happens when:

- A typed relation query matches the RelationIndex exactly.
- A Prolog rule's body is fully satisfied by existing facts.
- A transitive closure or inverse lookup resolves the query structurally.

The LLM never sees these. They happen in the inference loop's Phase 5 before token generation, or as side effects of command execution. The system checks for L3 resolution first — if it works, no tokens are generated.

```
User query arrives in prompt_input.
System checks: can this be answered at L3?

    1. Parse query for structural patterns (see Section 4).
    2. If pattern matches typed relation schema → RelationIndex lookup.
    3. If pattern matches existing rule heads → fire_and_commit.
    4. If resolution succeeds → write result to prompt_current, skip LLM.

If L3 fails or is ambiguous → fall through to LLM (L1 or L2).
```

### 2.2 L2 — LLM Selects, Prolog Executes

The LLM generates a short command sequence that invokes a specific Prolog rule or KB operation. The LLM's contribution is selecting which rule to fire and providing the bindings. Prolog does the execution.

```
LLM generates: CMD_PROLOG_QUERY root.knowledge.math.math_4.relationships enables(P1, X)
System parses: query = enables(P1, X) in KB scope root.knowledge.math.math_4.relationships
Prolog executes: unify, backtrack, collect bindings for X
Result written to prompt_current: X = [AR1, AR2, AR3]
LLM reads result, continues generation.

Total LLM tokens: ~18 (command prefix + path + query pattern)
Total Prolog cost: integer comparisons, sub-microsecond
```

### 2.3 L1 — Full LLM Judgment

The LLM generates the full response. No Prolog invocation. This happens for novel queries, ambiguous intent, prose generation, and situations where no rule or relation covers the need.

---

## 3. What the LLM Needs to Know

For L2 invocation to work, the LLM must know what is available to invoke. It cannot search the entire KB tree at generation time — that would be slower than just answering the question directly. The LLM needs a pre-computed, bounded summary of what Prolog rules and typed relations exist and what they can answer.

### 3.1 The Availability Surface

The availability surface is everything the LLM could invoke at L2 or that the system could fire at L3. It consists of:

**Typed relations by type** — for each RelationType present in accessible KBs, the count and sample from/to entities. "There are 47 enables relations, 23 requires relations, 12 specializes relations across your accessible KBs."

**Rule heads by functor** — for each distinct rule head functor in accessible KBs, the count and arity. "There are 15 rules with head enables/2, 8 rules with head validates/2, 3 rules with head severity_threshold/1."

**KB paths with data** — which KB paths have facts, relations, or rules. "root.knowledge.math.math_4 has 6 tables, 47 relations, 40 rules."

**Builtin catalog** — the 448 builtins with their IOSE declarations. This is static — loaded from seed at startup, never changes.

### 3.2 Where This Lives

The availability surface is computed per-session and cached in the session's `_llm.concepts` KB as structured facts. It is rebuilt when:

- The session starts (clone from template populates initial surface).
- A compacted document is ingested that the session can access.
- The admin modifies grants that change which KBs are visible.
- A training run updates weights in accessible KBs.

The surface is not rebuilt per-prompt. It changes on session-level events, not per-token events.

---

## 4. Structural Pattern Detection

### 4.1 Query Pattern Classification

Before the LLM generates tokens, the system examines the user's input for structural patterns that might resolve at L3. This is a pre-LLM scan — it runs on the raw input text, not on generated tokens.

```
fn classifyQueryPattern(input: []const u8, store: *KbStore, session: *Session) QueryClassification {
    var result = QueryClassification{};

    // Pattern 1: Relation query
    // "what does X enable" → enables(X, ?)
    // "what requires Y" → requires(?, Y)
    // "does X enable Y" → enables(X, Y)
    if (matchRelationPattern(input)) |rel_pattern| {
        result.has_relation = true;
        result.rel_type = rel_pattern.rel_type;
        result.from_hint = rel_pattern.from_id;
        result.to_hint = rel_pattern.to_id;
        result.confidence = rel_pattern.match_confidence;
    }

    // Pattern 2: Transitive query
    // "what does X transitively enable" → transitive_closure(enables, X)
    // "all dependencies of Y" → transitive_closure(depends_on, Y)
    if (matchTransitivePattern(input)) |trans_pattern| {
        result.has_transitive = true;
        result.transitive_type = trans_pattern.rel_type;
        result.transitive_root = trans_pattern.root_id;
    }

    // Pattern 3: Fact lookup
    // "what is the value of alpha_em" → fact read on KB path
    // "show me the basis constants" → fact scan on table KB
    if (matchFactPattern(input)) |fact_pattern| {
        result.has_fact = true;
        result.fact_kb_path = fact_pattern.path;
        result.fact_slot_hint = fact_pattern.slot;
    }

    // Pattern 4: Aggregation
    // "how many relations of type enables" → index count read
    // "count of basis constants" → facts_count on table KB
    if (matchAggregationPattern(input)) |agg_pattern| {
        result.has_aggregation = true;
        result.agg_type = agg_pattern.type;
        result.agg_target = agg_pattern.target;
    }

    return result;
}
```

### 4.2 Pattern Matchers

The pattern matchers are not LLM-based. They are integer-comparison keyword scanners operating on the input tokens:

```
fn matchRelationPattern(input: []const u8) ?RelationPattern {
    // Scan for relation type keywords
    const rel_keywords = .{
        .{ "enables", .enables },
        .{ "requires", .requires },
        .{ "prevents", .prevents },
        .{ "depends on", .depends_on },
        .{ "part of", .part_of },
        .{ "contains", .contains },
        .{ "follows", .follows },
        .{ "specializes", .specializes },
        .{ "implements", .implements },
        .{ "validates", .validates },
        .{ "contradicts", .contradicts },
        .{ "causes", .causes },
        .{ "equivalent to", .equivalent_to },
        // ... all 20 system types
    };

    for (rel_keywords) |kw| {
        if (containsWord(input, kw[0])) {
            return RelationPattern{
                .rel_type = kw[1],
                .from_id = extractEntityBefore(input, kw[0]),
                .to_id = extractEntityAfter(input, kw[0]),
                .match_confidence = computeMatchConfidence(input, kw[0]),
            };
        }
    }

    return null;
}
```

These matchers are fast — substring scan over a short input, no allocation, no LLM involvement. They produce candidates, not final answers. A match with low confidence is passed to the LLM for disambiguation rather than executed directly.

### 4.3 Confidence Thresholds

Pattern classification produces a match confidence:

```
# pattern_confidence(condition|confidence|action)
exact match, single relation type, both entities identified|high (>= 80%)|attempt L3 directly
exact match, single relation type, one entity identified|medium (50-79%)|attempt L3 with wildcard
multiple possible relation types|low (< 50%)|pass to LLM, include candidates in prompt_current
no relation keyword found|none|pass to LLM without candidates
entity referenced but not found in any accessible KB|low|pass to LLM with "entity not found" note
```

High confidence → try L3 immediately. If L3 succeeds, write result to `prompt_current` and the LLM generates a response that frames the result. The LLM still runs but on a much easier task (framing a known answer vs. reasoning about the question).

Medium confidence → try L3 with the wildcard. If it produces exactly one result set, use it. If ambiguous, pass the candidates to the LLM.

Low/no confidence → full L1 or L2.

---

## 5. Scan Algorithms

### 5.1 The Problem

The system may have 100K+ KBs, 10M+ facts, 100K+ rules, 1M+ typed relations. The LLM cannot scan all of this. The scan must be targeted — find relevant rules and relations for a specific query without touching irrelevant data.

### 5.2 RelationIndex Scan — O(1) Type Check, O(N_type) Scan

For typed relation queries, the RelationIndex makes the common case fast:

```
fn scanForRelation(
    store: *KbStore,
    session: *Session,
    rel_type: RelationType,
    from: ?VdrId,
    to: ?VdrId,
) []TypedRelation {
    var results_buf: [MAX_SCAN_RESULTS]TypedRelation = undefined;
    var count: i32 = 0;

    // Walk accessible KBs
    for (getAccessibleKbs(store, session)) |kb| {
        if (!kb.hasRelations()) continue;

        // O(1): check if this KB has any relations of this type
        const index = getRelationIndex(kb, store.global_arena);
        if (!index.hasType(rel_type)) continue;

        // O(N_type): scan only relations of this type in this KB
        const rels = getRelationsForType(kb, rel_type, store.global_arena);
        for (rels) |rel| {
            if (from != null and !rel.matchesFrom(from.?)) continue;
            if (to != null and !rel.matchesTo(to.?)) continue;

            if (count < MAX_SCAN_RESULTS) {
                results_buf[@intCast(count)] = rel;
                count += 1;
            }
        }
    }

    return results_buf[0..@intCast(count)];
}
```

The outer loop walks accessible KBs, which is bounded by the session's grant set — typically tens to hundreds of KBs, not 100K. For each KB, the `hasType()` check is a single i32 read. For KBs that have the relation type, the scan is linear over a contiguous array of only that type's relations.

For a system with 50 accessible KBs and 2000 total typed relations of which 200 are `enables`, a query for `enables(P1, ?)` touches: 50 index checks (50 i32 reads) + ~200 relation scans (200 × VdrId comparison). Sub-microsecond total.

### 5.3 Rule Head Index — Functor-Based Dispatch

For general Prolog queries, rules are matched by head functor. The system maintains a functor index per KB:

```
fn scanForMatchingRules(
    store: *KbStore,
    session: *Session,
    query_functor: i32,
    query_arity: i16,
) []RuleCandidate {
    var candidates_buf: [MAX_RULE_CANDIDATES]RuleCandidate = undefined;
    var count: i32 = 0;

    for (getAccessibleKbs(store, session)) |kb| {
        if (kb.rules_count == 0) continue;

        const rules = getRuleSlice(kb, store.global_arena);
        for (rules) |*rule| {
            const head = getTerm(rule.head, store.global_arena);
            if (head.type != .compound) continue;
            if (head.primary_id != query_functor) continue;
            if (head.secondary_aux != query_arity) continue;

            if (count < MAX_RULE_CANDIDATES) {
                candidates_buf[@intCast(count)] = RuleCandidate{
                    .rule = rule,
                    .kb = kb,
                    .head_term = head,
                };
                count += 1;
            }
        }
    }

    return candidates_buf[0..@intCast(count)];
}
```

This is a linear scan over rules, but bounded: each KB's rules array is typically 10-100 rules, and the functor+arity check is two integer comparisons per rule. For a system with 50 accessible KBs averaging 50 rules each, that's 2500 integer comparisons — microseconds.

### 5.4 Functor Hash Index (Optimization)

For systems with many rules per KB, a hash index on rule head functors avoids the linear scan:

```
const FunctorIndex = struct {
    buckets: [FUNCTOR_HASH_SIZE]i32,  // index into rules array, -1 = empty
    chains: []i32,                     // next pointers for collision chains

    fn lookup(self: *FunctorIndex, functor_id: i32, arity: i16) ?i32 {
        const hash = @as(u32, @bitCast(functor_id)) % FUNCTOR_HASH_SIZE;
        var idx = self.buckets[hash];
        while (idx >= 0) {
            // Check the rule at this index
            // Return first match; caller handles multiple matches via chain
            return idx;
            idx = self.chains[@intCast(idx)];
        }
        return null;
    }
};
```

Built lazily when a KB's rule count exceeds a threshold (e.g., 64 rules). Below that, linear scan is faster than the hash lookup overhead. The threshold is configurable.

### 5.5 KB Path Narrowing

Most queries don't need to scan all accessible KBs. The query context narrows the search:

```
fn narrowKbScope(
    store: *KbStore,
    session: *Session,
    query: *QueryClassification,
) []const *KB {
    // Strategy 1: explicit path in query
    // "what does root.knowledge.math.math_4 say about..."
    // → scan only math_4 and its children
    if (query.fact_kb_path) |path| {
        return resolvePathAndChildren(path, store, session);
    }

    // Strategy 2: entity ID prefix narrows to table
    // P1 → principles table, BC3 → basis_constants table
    // Uses the decode legend's id_prefixes mapping
    if (query.from_hint) |from| {
        if (resolveIdPrefix(from, store, session)) |kb| {
            return &.{kb};
        }
    }

    // Strategy 3: relation type narrows to KBs with that type
    // Only check KBs where RelationIndex.hasType(rel_type)
    if (query.rel_type) |rel_type| {
        return filterKbsByRelationType(store, session, rel_type);
    }

    // Strategy 4: topic context from _llm.concepts
    // LLM has been talking about physics → bias toward root.knowledge.physics.*
    if (getActiveTopicKbs(session)) |topic_kbs| {
        return topic_kbs;
    }

    // Fallback: all accessible KBs
    return getAccessibleKbs(store, session);
}
```

Narrowing eliminates most KBs before the scan starts. A query about "what does P1 enable" in a math context doesn't need to scan incident triage KBs or chemistry KBs.

---

## 6. Availability Surface Construction

### 6.1 When Built

The availability surface is computed when:

1. **Session creation.** Clone from template populates a base surface from the session's accessible KBs.
2. **Grant change.** Admin adds or removes KB access for a client. All client's active sessions rebuild their surface.
3. **Ingestion.** A new compacted document is ingested into an accessible KB path. Sessions that can see it get their surface updated.
4. **Training.** A training run modifies weights or rules in accessible KBs. Surface updated.

Not per-prompt. Not per-token. Session-level events only.

### 6.2 Surface Structure

The surface is stored as facts in `session_root._llm.concepts`:

```
session_root._llm.concepts.available_relations
    facts[0] = TAG_VALUE: rel_type=0(enables), count=47
    facts[1] = TAG_VALUE: rel_type=1(requires), count=23
    facts[2] = TAG_VALUE: rel_type=14(specializes), count=12
    ...

session_root._llm.concepts.available_rules
    facts[0] = TAG_TEXT: functor="severity_threshold", arity=1, count=3
    facts[1] = TAG_TEXT: functor="escalation", arity=2, count=8
    ...

session_root._llm.concepts.kb_coverage
    facts[0] = TAG_TEXT: path="root.knowledge.math.math_4", tables=6, relations=47, rules=40
    facts[1] = TAG_TEXT: path="root.ops.incidents", tables=2, relations=15, rules=12
    ...
```

The LLM reads these as part of its `prompt_last` continuity or when it needs to decide whether to attempt L2 vs. L1. The surface tells it: "you have 47 enables relations available — if the user asks about what something enables, you can emit a typed relation query instead of reasoning about it yourself."

### 6.3 Surface Build Algorithm

```
fn buildAvailabilitySurface(session: *Session, store: *KbStore, arena: *Arena) void {
    const surface_kb = resolveKb(session, "_llm.concepts", store);

    // Clear previous surface
    clearSurfaceFacts(surface_kb, store, arena);

    // Aggregate relation counts by type
    var rel_counts: [RELATION_TYPE_SLOTS]i32 = [_]i32{0} ** RELATION_TYPE_SLOTS;
    var kb_summaries = ArrayListManaged(KbSummary).init(arena);

    for (getAccessibleKbs(store, session)) |kb| {
        if (kb.hasRelations()) {
            const index = getRelationIndex(kb, store.global_arena);
            for (0..RELATION_TYPE_SLOTS) |slot| {
                rel_counts[slot] += index.by_type_counts[slot];
            }
        }

        if (kb.facts_count > 0 or kb.rules_count > 0 or kb.hasRelations()) {
            kb_summaries.append(.{
                .kb_id = kb.id,
                .facts = kb.facts_count,
                .rules = kb.rules_count,
                .relations = kb.relations_count,
            }) catch continue;
        }
    }

    // Assert relation counts as facts
    for (0..RELATION_TYPE_SLOTS) |slot| {
        if (rel_counts[slot] > 0) {
            assertRelationCountFact(surface_kb, @intCast(slot), rel_counts[slot], store, arena);
        }
    }

    // Assert rule head summaries
    var functor_counts = FunctorCountMap.init(arena);
    for (getAccessibleKbs(store, session)) |kb| {
        const rules = getRuleSlice(kb, store.global_arena);
        for (rules) |*rule| {
            const head = getTerm(rule.head, store.global_arena);
            if (head.type == .compound) {
                functor_counts.increment(head.primary_id, head.secondary_aux);
            }
        }
    }
    for (functor_counts.entries()) |entry| {
        assertRuleSummaryFact(surface_kb, entry.functor, entry.arity, entry.count, store, arena);
    }

    // Assert KB coverage summaries
    for (kb_summaries.items) |summary| {
        assertKbCoverageFact(surface_kb, summary, store, arena);
    }
}
```

---

## 7. LLM Decision Process

### 7.1 The LLM's View

During generation, the LLM has access to:

1. **`prompt_input`** — the user's current query.
2. **`prompt_last`** — continuity from prior cycle, including notes about available capabilities.
3. **`_llm.concepts.available_relations`** — what typed relations are available.
4. **`_llm.concepts.available_rules`** — what rule heads are available.
5. **`_llm.concepts.kb_coverage`** — which KBs have data.
6. **`_llm.scratchpad`** — any prior analysis the LLM has done.
7. **`prompt_current`** — results from L3 pre-resolution (if any).

### 7.2 Decision Tree

```
LLM reads prompt_current:
    - If L3 pre-resolution produced a result:
        → Frame the result as prose. L2-equivalent cost (~18 tokens framing).
        → The hard work is done. LLM adds context, caveats, formatting.

    - If L3 found candidates but couldn't disambiguate:
        → LLM reads candidates from prompt_current.
        → LLM selects the right one based on context.
        → Emits CMD_PROLOG_QUERY or CMD_KB_QUERY for the selected candidate.
        → L2 invocation (~18 tokens).

    - If L3 found nothing:
        → LLM checks availability surface in _llm.concepts.
        → If a relation type or rule head matches the query intent:
            → Emit the appropriate command. L2.
        → If no match in surface:
            → Full L1 reasoning. Generate prose response from weights.
```

### 7.3 Command Emission

When the LLM decides to invoke Prolog, it generates command tokens:

```
CMD_PROLOG_QUERY <kb_path> <query_pattern>
CMD_KB_QUERY <kb_path> <slot_or_tag>
CMD_PROLOG_ASSERT_RULE <kb_path> <rule>
CMD_BUILTIN_CALL <builtin_id> <args>
CMD_GRAMMAR_RENDER <kb_path> <grammar_id>
CMD_DIRECT_OUTPUT <kb_url>
```

The command vocabulary is ~300 tokens loaded from `root.system.command_vocab` at session init. The LLM has been trained on these tokens — they are part of its vocabulary, not free-form text that gets parsed heuristically.

The command parser in `vdr_command.zig` is deterministic: tokenize the command, match the command type, parse the arguments, resolve KB paths, execute. No ambiguity in parsing. If the LLM emits a malformed command, the parser returns an error to `prompt_current` and the LLM can retry or fall back to L1.

---

## 8. Execution Pipeline

### 8.1 Full Pipeline for an L2 Invocation

```
1. LLM generates: CMD_PROLOG_QUERY root.knowledge.math.math_4.relationships enables(P1, X)

2. Command parser (vdr_command.zig):
   a. Tokenize: CMD_PROLOG_QUERY | root.knowledge.math.math_4.relationships | enables(P1, X)
   b. Command type: .prolog_query
   c. KB path: resolve "root.knowledge.math.math_4.relationships" → VdrId
   d. Query term: parse "enables(P1, X)" → compound(enables_atom, [atom(p1), variable(x)])
   e. Grant check: does session have access to this KB? If not, deny.

3. Typed relation fast path check (vdr_relation.zig):
   a. Is the query head functor a known RelationType? "enables" → yes, slot 0.
   b. Does the target KB have a RelationIndex? Check kb.relation_index_offset.
   c. Does the index have enables relations? Check by_type_counts[0].
   d. If yes → dispatch to typed relation scan, skip general Prolog.

4. Typed relation scan:
   a. Get contiguous enables relations array from index.
   b. Filter: from_id matches P1's VdrId.
   c. Collect to_id values: [AR1, AR2, AR3].
   d. Build result as Prolog bindings: X = AR1; X = AR2; X = AR3.

5. Result delivery:
   a. Write bindings to prompt_current as structured facts.
   b. Set command result status = ok.

6. LLM reads prompt_current, sees: X = [AR1, AR2, AR3].
   Generates: "P1 (Shared power-of-two denominator) enables AR1, AR2, and AR3."
   Total LLM tokens: ~18 (command) + ~20 (framing response) = ~38.
```

### 8.2 Fallback to General Prolog

If the typed relation fast path doesn't apply (the functor isn't a known RelationType, or the KB has no RelationIndex), the command falls through to general Prolog:

```
3. Typed relation fast path check:
   a. Is "custom_relation" a known RelationType? Check enum → no.
   b. Is it a registered domain type? Check root.system.relation_types → maybe.
   c. If domain type found → dispatch to typed relation scan with domain slot.
   d. If not found → fall through to general Prolog.

4. General Prolog query (vdr_prolog.zig):
   a. Build query term: compound(custom_relation_atom, [atom(p1), variable(x)])
   b. Depth-first search with backtracking on per-core scratch.
   c. Session tree searched first, then global.
   d. Match rule heads by functor + arity.
   e. Unify, bind, collect results.
   f. Slower than typed relation scan but correct for arbitrary queries.
```

### 8.3 Typed-Then-General Strategy

The dispatch is a priority chain:

```
fn executeQuery(kb: *KB, query: *Term, store: *KbStore, session: *Session, arena: *Arena) QueryResult {

    // Priority 1: typed relation fast path
    if (query.type == .compound) {
        const functor = query.primary_id;
        if (resolveRelationType(functor, store)) |rel_type| {
            if (kb.hasRelationIndex()) {
                const index = getRelationIndex(kb, store.global_arena);
                if (index.hasType(rel_type)) {
                    const result = queryTypedRelation(kb, rel_type, extractFrom(query), extractTo(query), arena);
                    if (result.len > 0) {
                        session.level_stats.l3_relation_queries += 1;
                        return buildQueryResult(result, arena);
                    }
                }
            }
        }
    }

    // Priority 2: transitive closure for transitive types
    if (query.type == .compound and isTransitiveQuery(query)) {
        const rel_type = resolveRelationType(query.primary_id, store).?;
        if (rel_type.isTransitive()) {
            const closure = transitiveClosure(getAccessibleKbs(store, session), rel_type, extractFrom(query).?, arena);
            if (closure.len > 0) {
                session.level_stats.l3_transitive_closures += 1;
                return buildClosureResult(closure, arena);
            }
        }
    }

    // Priority 3: inverse lookup
    if (query.type == .compound) {
        if (resolveRelationType(query.primary_id, store)) |rel_type| {
            const inv = rel_type.inverse();
            if (inv != .unknown and inv != rel_type) {
                const result = queryTypedRelation(kb, inv, extractTo(query), extractFrom(query), arena);
                if (result.len > 0) {
                    session.level_stats.l3_inverse_lookups += 1;
                    return buildQueryResult(result, arena);
                }
            }
        }
    }

    // Priority 4: general Prolog unification
    return prologQuery(kb, query, store, session, arena);
}
```

Each priority level is strictly faster than the next. The typed relation scan is an integer array scan. Transitive closure is BFS over integer arrays. Inverse lookup is the same scan with swapped from/to. General Prolog is full unification with backtracking. The chain short-circuits at the first level that produces results.

---

## 9. Atom Resolution for Relation Types

### 9.1 The Bridging Problem

The LLM generates text tokens like "enables". The Prolog engine works with integer atom IDs. The RelationType enum has integer slots. These three representations need to map to each other efficiently.

### 9.2 Relation Keyword → Enum Mapping

A compile-time table maps relationship name strings to RelationType enum values:

```
const RELATION_KEYWORDS = [_]struct { name: []const u8, rel_type: RelationType }{
    .{ .name = "enables", .rel_type = .enables },
    .{ .name = "requires", .rel_type = .requires },
    .{ .name = "prevents", .rel_type = .prevents },
    .{ .name = "implements", .rel_type = .implements },
    .{ .name = "extends", .rel_type = .extends },
    .{ .name = "overrides", .rel_type = .overrides },
    .{ .name = "validates", .rel_type = .validates },
    .{ .name = "verified_by", .rel_type = .verified_by },
    .{ .name = "contradicts", .rel_type = .contradicts },
    .{ .name = "causes", .rel_type = .causes },
    .{ .name = "determined_by", .rel_type = .determined_by },
    .{ .name = "depends_on", .rel_type = .depends_on },
    .{ .name = "equivalent_to", .rel_type = .equivalent_to },
    .{ .name = "approximates", .rel_type = .approximates },
    .{ .name = "specializes", .rel_type = .specializes },
    .{ .name = "generalizes", .rel_type = .generalizes },
    .{ .name = "part_of", .rel_type = .part_of },
    .{ .name = "contains", .rel_type = .contains },
    .{ .name = "follows", .rel_type = .follows },
    .{ .name = "precedes", .rel_type = .precedes },
};
```

For domain-registered types, the mapping is dynamic — stored in the DomainRelationDef structs in `root.system.relation_types`, looked up by name at ingestion time and cached in the KB's domain_rel_defs.

### 9.3 Atom ID → RelationType Resolution

When the command parser has already converted "enables" to an atom ID in the Prolog term store, the execution pipeline needs to check whether that atom ID corresponds to a RelationType:

```
fn resolveRelationType(atom_id: i32, store: *KbStore) ?RelationType {
    // Check system-defined types first (compile-time table)
    for (RELATION_KEYWORDS) |kw| {
        if (store.atomId(kw.name) == atom_id) {
            return kw.rel_type;
        }
    }

    // Check domain-registered types
    const rel_types_kb = store.resolveKb(SEED.RELATION_TYPES);
    if (rel_types_kb) |kb| {
        const defs = getDomainRelDefs(kb, store.global_arena);
        for (defs) |def| {
            const def_name = getTextSlice(store, def.name_offset, def.name_length);
            if (store.atomId(def_name) == atom_id) {
                return @enumFromInt(def.slot);
            }
        }
    }

    return null;
}
```

This is called once per query, not per relation. The cost is 20 string-to-atom comparisons for system types plus N comparisons for domain types. With atom IDs cached after first resolution, subsequent queries for the same functor skip the string comparison entirely.

### 9.4 Atom ID Cache

To avoid repeated string→atom→RelationType lookups, the session caches the mapping:

```
const AtomRelTypeCache = struct {
    entries: [MAX_CACHED]struct { atom_id: i32, rel_type: RelationType } = undefined,
    count: i32 = 0,

    fn lookup(self: *AtomRelTypeCache, atom_id: i32) ?RelationType {
        for (self.entries[0..@intCast(self.count)]) |entry| {
            if (entry.atom_id == atom_id) return entry.rel_type;
        }
        return null;
    }

    fn insert(self: *AtomRelTypeCache, atom_id: i32, rel_type: RelationType) void {
        if (self.count >= MAX_CACHED) return;
        self.entries[@intCast(self.count)] = .{ .atom_id = atom_id, .rel_type = rel_type };
        self.count += 1;
    }
};
```

Small fixed-size array (MAX_CACHED = 64). Linear scan is faster than hash lookup for this size. Populated lazily on first resolution. Lives in per-core session scratch — dies with the session.

---

## 10. Result Formatting

### 10.1 Prolog Results → LLM-Readable Facts

Prolog query results are bindings — variable-to-value mappings. These need to be written to `prompt_current` in a form the LLM can read and incorporate into its generation:

```
fn writeResultToScratch(
    result: QueryResult,
    session: *Session,
    store: *KbStore,
    arena: *Arena,
) void {
    const scratch_kb = resolveKb(session, "_llm.prompt_current", store);

    // Write binding summary
    for (result.bindings[0..@intCast(result.binding_count)]) |binding| {
        const var_name = getAtomName(binding.var_id, store);
        const bound_value = renderTerm(binding.bound_term_offset, store, arena);

        // Assert as text fact: "X = AR1"
        var fact = Fact{};
        fact.tag = .text;
        const text = formatBinding(var_name, bound_value, arena);
        fact.value.v = storeTextInKb(text, scratch_kb, arena);
        fact.value.r0 = @intCast(text.len);
        fact.provenance = Provenance.direct(.prolog_derivation, scratch_kb.id, scratch_kb.facts_count, currentTimestamp());

        store.assertFact(scratch_kb, fact, arena);
    }

    // Write result count
    var count_fact = Fact{};
    count_fact.tag = .value;
    count_fact.value = Q16.fromParts(result.result_count, 0, 0);
    count_fact.provenance = Provenance.direct(.prolog_derivation, scratch_kb.id, scratch_kb.facts_count, currentTimestamp());
    store.assertFact(scratch_kb, count_fact, arena);
}
```

### 10.2 Grammar-Based Result Rendering

If the target KB has a grammar attached, the result can be rendered through it instead of as raw bindings:

```
fn renderResultViaGrammar(
    result: QueryResult,
    target_kb: *KB,
    store: *KbStore,
    output: *OutputBuffer,
    arena: *Arena,
) bool {
    const grammar = grammarInherit(target_kb, store, arena);
    if (grammar == null) return false;

    for (result.bindings[0..@intCast(result.binding_count)]) |binding| {
        const fills = buildGrammarFills(binding, store, arena);
        grammarRender(grammar.?, fills, output, arena);
    }

    return true;
}
```

Grammar rendering is L3 — zero tokens. The LLM doesn't need to generate prose describing the result. It can emit a CMD_GRAMMAR_RENDER or CMD_DIRECT_OUTPUT token and the grammar handles formatting.

---

## 11. Performance Budget

### 11.1 L3 Pre-Resolution

```
# l3_pre_resolution_budget(operation|time|notes)
input pattern scan|~10 μs|keyword scan over short input
KB scope narrowing|~5 μs|grant check + path resolution
RelationIndex type check|~1 μs per KB|single i32 read
typed relation scan|~1 μs per 100 relations|contiguous array, integer compare
result write to prompt_current|~10 μs|fact assertion to session KB
total L3 pre-resolution|~30 μs|well under 1ms
```

### 11.2 L2 Command Execution

```
# l2_command_budget(operation|time|notes)
command token generation|~5 ms|~18 tokens at ~3.5 ms/token (single core reduced model)
command parsing|~5 μs|tokenize + match + resolve
typed relation dispatch|~10 μs|same as L3 scan
result formatting|~10 μs|binding text or grammar render
result read by LLM|~5 ms|~15 tokens reading result, generating framing
total L2|~10 ms|~38 tokens total, 3% of L1 cost
```

### 11.3 L1 Full Forward Pass

```
# l1_budget(operation|time|notes)
full generation|~27 ms per token × 50-500 tokens|single core, reduced model
total L1|~1.3 - 13.5 seconds|varies by response length
```

The L2/L1 cost ratio is ~10ms / ~5000ms = 0.2%. The spec estimates ~3% because L2 includes some prose framing, but the Prolog execution itself is negligible.

---

## 12. Training the LLM for L2

### 12.1 What the LLM Must Learn

The LLM needs to learn when and how to emit command tokens. This is trained behavior, not programmed behavior. The training data includes:

- **Positive examples:** Queries that should produce CMD_PROLOG_QUERY, paired with the correct command syntax and the expected result.
- **Negative examples:** Queries that should NOT produce commands (judgment calls, novel situations, ambiguous intent) paired with prose responses.
- **Surface reading:** Examples showing the LLM reading `_llm.concepts.available_relations` and deciding to use L2 based on what's available.
- **Fallback:** Examples where the LLM attempts L2, gets an error (relation not found, KB access denied), and falls back to L1.

### 12.2 Command Vocabulary Integration

The ~300 command tokens in `root.system.command_vocab` are added to the model's vocabulary. During training, these tokens appear in training sequences alongside normal text tokens. The LLM learns to generate them in context — "when the user asks about what enables something and I have enables relations available, I emit CMD_PROLOG_QUERY with an enables pattern."

### 12.3 L3 Pre-Resolution Training

The LLM also needs to learn to recognize when L3 has already answered the question. Training examples include:

- User asks "what does P1 enable?" → L3 pre-resolution fills prompt_current with X = [AR1, AR2, AR3] → LLM generates a framing response using the pre-resolved data, not re-answering the question from weights.

This is a different skill than L2 emission. The LLM must recognize "the answer is already in my scratch space" and frame it rather than ignore it and re-derive.

---

## 13. Future Improvements

### 13.1 Learned Pattern Matchers

The keyword-based pattern matchers in Section 4 are simple substring scans. A future improvement is to train a small classifier (using the system's own inference engine) that maps input patterns to query structures with higher accuracy than keyword matching. The classifier would run as an L2 invocation itself — the LLM reads the input and emits a structured query classification rather than a full response.

### 13.2 Dynamic Surface Compression

As the KB tree grows, the availability surface in `_llm.concepts` could become large. A compression strategy would track which relations and rules the LLM actually uses (from LevelStats) and present only high-usage items in the surface. Low-usage items remain available but are not surfaced proactively — the LLM can still invoke them via explicit KB path commands.

### 13.3 Speculative L3

Instead of waiting for the LLM to emit a command, the system could speculatively execute L3 queries based on the pattern classification while the LLM is still generating tokens. If the LLM then emits a command that matches the speculative result, the result is already available. If the LLM generates prose instead, the speculative result is discarded. This overlaps L3 computation with L1 token generation.

### 13.4 Rule Relevance Scoring

Rules carry their own statistics: `fire_count`, `success_count`, `failure_count`. A future improvement uses these statistics to rank rule candidates — rules that fire frequently and succeed often are presented to the LLM first. Rules that fire rarely or fail often are deprioritized. This makes the LLM's selection task easier when multiple rules match.

### 13.5 Relation Embedding Cache

Instead of keyword matching to find relevant relations, the system could maintain a small embedding index over relation from/to entities. A dot product between the query embedding and relation entity embeddings would produce a ranked list of relevant relations. This is more expensive than keyword matching but handles paraphrased queries ("what enables..." vs "what makes possible..." vs "prerequisites for..."). The embedding index would live in a per-session cache KB and be rebuilt on surface updates.

---

## New Structs

### QueryClassification

```zig
/// Result of pre-LLM structural pattern detection on user input.
/// Produced by classifyQueryPattern() before the LLM generates tokens.
/// Lives in per-core scratch — ephemeral, destroyed after the inference cycle.
pub const QueryClassification = struct {
    /// true if input matches a relation pattern like "what does X enable"
    has_relation: bool = false,
    /// the detected RelationType if has_relation is true
    rel_type: RelationType = .unknown,
    /// VdrId of the source entity if detected, NONE if wildcard
    from_hint: VdrId = .{},
    /// VdrId of the target entity if detected, NONE if wildcard
    to_hint: VdrId = .{},

    /// true if input matches a transitive pattern like "all dependencies of X"
    has_transitive: bool = false,
    /// the transitive relation type if has_transitive is true
    transitive_type: RelationType = .unknown,
    /// the root entity for transitive closure
    transitive_root: VdrId = .{},

    /// true if input matches a direct fact lookup like "value of alpha_em"
    has_fact: bool = false,
    /// KB path hash for fact lookup, 0 if unresolved
    fact_path_hash: u32 = 0,
    /// fact slot hint, -1 if scanning all slots
    fact_slot_hint: i32 = -1,

    /// true if input matches an aggregation like "how many enables relations"
    has_aggregation: bool = false,
    /// aggregation type: 0=count, 1=sum, 2=list
    agg_type: i32 = 0,
    /// target for aggregation (RelationType slot or KB path hash)
    agg_target: i32 = 0,

    /// overall confidence in the classification, Q16 (0 = no match, 65536 = certain)
    confidence: Q16 = .{},

    /// how many patterns matched (0 = no structural match, pass to LLM)
    match_count: i32 = 0,

    /// true if L3 pre-resolution should be attempted before LLM generation
    pub fn shouldAttemptL3(self: QueryClassification) bool {
        return self.match_count > 0 and self.confidence.v >= 32768; // >= 50%
    }

    /// true if only one pattern matched unambiguously
    pub fn isUnambiguous(self: QueryClassification) bool {
        return self.match_count == 1 and self.confidence.v >= 52428; // >= 80%
    }
};
```

---

### RelationPattern

```zig
/// A parsed relation pattern extracted from user input text.
/// Produced by matchRelationPattern() during structural pattern detection.
/// Ephemeral — lives in per-core scratch during classification.
pub const RelationPattern = struct {
    /// the detected relation type
    rel_type: RelationType = .unknown,
    /// VdrId of source entity if identified, NONE if wildcard
    from_id: VdrId = .{},
    /// VdrId of target entity if identified, NONE if wildcard
    to_id: VdrId = .{},
    /// confidence in this specific pattern match, Q16
    match_confidence: Q16 = .{},
    /// byte offset in input where the relation keyword was found
    keyword_offset: i32 = 0,
    /// length of the matched keyword in bytes
    keyword_length: i16 = 0,
};
```

---

### RuleCandidate

```zig
/// A Prolog rule that matched a query's functor and arity during scan.
/// Collected during scanForMatchingRules(), ranked, then presented to
/// the LLM or executed directly if unambiguous.
/// Ephemeral — lives in per-core scratch during query execution.
pub const RuleCandidate = struct {
    /// pointer to the matched rule in arena memory
    rule_offset: i32 = 0,
    /// KB that owns this rule
    kb_id: VdrId = .{},
    /// head term offset for quick re-access without re-scanning
    head_term_offset: i32 = 0,
    /// rule's historical success rate, Q16 (from rule.successRate())
    success_rate: Q16 = .{},
    /// rule's total fire count — higher means more proven
    fire_count: i32 = 0,
    /// relevance score combining success rate and recency, Q16
    relevance: Q16 = .{},
};
```

---

### AtomRelTypeCache

```zig
/// Per-session cache mapping Prolog atom IDs to RelationType enum values.
/// Avoids repeated string→atom→RelationType lookups during query execution.
/// Lives in per-core session scratch — dies with the session.
pub const ATOM_REL_CACHE_SIZE: usize = 64;

pub const AtomRelTypeCacheEntry = struct {
    /// the Prolog atom ID (from the term store's atom table)
    atom_id: i32 = -1,
    /// the resolved RelationType for this atom
    rel_type: RelationType = .unknown,
};

pub const AtomRelTypeCache = struct {
    /// fixed-size array of cached mappings
    entries: [ATOM_REL_CACHE_SIZE]AtomRelTypeCacheEntry =
        [_]AtomRelTypeCacheEntry{.{}} ** ATOM_REL_CACHE_SIZE,
    /// current number of cached entries
    count: i32 = 0,

    /// look up a cached atom→RelationType mapping, null if not cached
    pub fn lookup(self: *AtomRelTypeCache, atom_id: i32) ?RelationType {
        for (self.entries[0..@intCast(self.count)]) |entry| {
            if (entry.atom_id == atom_id) return entry.rel_type;
        }
        return null;
    }

    /// insert a new mapping, silently drops if cache is full
    pub fn insert(self: *AtomRelTypeCache, atom_id: i32, rel_type: RelationType) void {
        if (self.count >= ATOM_REL_CACHE_SIZE) return;
        self.entries[@intCast(self.count)] = .{
            .atom_id = atom_id,
            .rel_type = rel_type,
        };
        self.count += 1;
    }

    /// clear all entries (on session reset or grant change)
    pub fn reset(self: *AtomRelTypeCache) void {
        self.count = 0;
    }
};
```

---

### KbSummary

```zig
/// Compact summary of a KB's contents for the availability surface.
/// Stored as structured facts in session_root._llm.concepts.kb_coverage.
/// Rebuilt on session-level events (creation, grant change, ingestion).
pub const KbSummary = struct {
    /// KB identity
    kb_id: VdrId = .{},
    /// total facts in this KB
    facts_count: i32 = 0,
    /// total rules in this KB
    rules_count: i32 = 0,
    /// total typed relations in this KB
    relations_count: i32 = 0,
    /// whether this KB has weight data (inference-relevant)
    has_weights: bool = false,
    /// whether this KB was created by compaction ingestion
    from_compaction: bool = false,
    /// path hash for quick matching against query context
    path_hash: u32 = 0,
};
```

---

### RelationSurfaceEntry

```zig
/// Summary of available relations for one RelationType slot.
/// Part of the availability surface in session_root._llm.concepts.available_relations.
/// The LLM reads these to decide whether L2 invocation is viable.
pub const RelationSurfaceEntry = struct {
    /// which RelationType slot this summarizes
    rel_type_slot: i16 = 0,
    /// total count of this relation type across all accessible KBs
    total_count: i32 = 0,
    /// how many distinct KBs contain this relation type
    kb_count: i32 = 0,
    /// whether this type is transitive (copied from RelationType.isTransitive())
    is_transitive: bool = false,
    /// whether this type is symmetric (copied from RelationType.isSymmetric())
    is_symmetric: bool = false,
    /// whether an inverse type exists (inverse() != .unknown)
    has_inverse: bool = false,
};
```

---

### RuleSurfaceEntry

```zig
/// Summary of available rules for one functor/arity combination.
/// Part of the availability surface in session_root._llm.concepts.available_rules.
/// The LLM reads these to decide whether an L2 Prolog query is viable.
pub const RuleSurfaceEntry = struct {
    /// atom ID of the rule head functor
    functor_id: i32 = 0,
    /// arity of the rule head (number of arguments)
    arity: i16 = 0,
    /// total count of rules with this functor/arity across accessible KBs
    total_count: i32 = 0,
    /// average success rate across all matching rules, Q16
    avg_success_rate: Q16 = .{},
    /// total fire count across all matching rules
    total_fire_count: i64 = 0,
    /// text offset for the functor name (for LLM readability)
    functor_name_offset: i32 = 0,
    /// functor name length
    functor_name_length: i16 = 0,
};
```

---

### FunctorIndexEntry

```zig
/// Entry in the per-KB functor hash index for fast rule head lookup.
/// Built lazily when a KB's rule count exceeds FUNCTOR_INDEX_THRESHOLD.
/// Lives in the KB's arena region alongside the rules.
pub const FunctorIndexEntry = struct {
    /// atom ID of the rule head functor
    functor_id: i32 = -1,
    /// arity of the rule head
    arity: i16 = 0,
    /// index into the KB's rules array for the first matching rule
    first_rule_index: i32 = -1,
    /// count of rules with this functor/arity in this KB
    rule_count: i32 = 0,
};

/// Threshold: build functor index when KB has more rules than this
pub const FUNCTOR_INDEX_THRESHOLD: i32 = 64;

pub const FUNCTOR_INDEX_BUCKETS: usize = 64;

pub const FunctorIndex = struct {
    /// hash buckets mapping functor_id hash → FunctorIndexEntry index, -1 = empty
    buckets: [FUNCTOR_INDEX_BUCKETS]i32 = [_]i32{-1} ** FUNCTOR_INDEX_BUCKETS,
    /// entries array
    entries_offset: i32 = -1,
    /// number of distinct functor/arity combinations indexed
    entries_count: i32 = 0,
    /// chain pointers for hash collisions, parallel to entries
    chains_offset: i32 = -1,
    /// timestamp of last rebuild
    last_rebuilt: i32 = 0,

    /// look up a functor/arity in the index, returns first entry index or null
    pub fn lookup(self: *FunctorIndex, functor_id: i32, arity: i16, arena: *Arena) ?*FunctorIndexEntry {
        const hash = @as(u32, @bitCast(functor_id)) % FUNCTOR_INDEX_BUCKETS;
        var idx = self.buckets[hash];
        while (idx >= 0) {
            const entries = getEntries(self, arena);
            const entry = &entries[@intCast(idx)];
            if (entry.functor_id == functor_id and entry.arity == arity) {
                return entry;
            }
            const chains = getChains(self, arena);
            idx = chains[@intCast(idx)];
        }
        return null;
    }

    /// true if this index has been built (entries_offset != -1)
    pub fn isBuilt(self: FunctorIndex) bool {
        return self.entries_offset != -1;
    }
};
```

---

### L3PreResolution

```zig
/// Result of L3 pre-resolution attempted before LLM token generation.
/// Written to prompt_current if resolution succeeds.
/// The LLM reads this and either frames the answer (cheap) or ignores
/// it and reasons from weights (expensive, shouldn't happen often).
pub const L3PreResolution = struct {
    /// whether pre-resolution produced a result
    resolved: bool = false,
    /// how the resolution was achieved
    resolution_type: ResolutionType = .none,
    /// number of result bindings
    result_count: i32 = 0,
    /// offset into scratch where result bindings are stored
    results_offset: i32 = -1,
    /// the original query classification that triggered this resolution
    classification_confidence: Q16 = .{},
    /// microseconds spent on pre-resolution (integer, not float)
    resolution_time_us: i32 = 0,

    /// true if the LLM should frame this result rather than re-derive
    pub fn shouldFrame(self: L3PreResolution) bool {
        return self.resolved and self.result_count > 0;
    }
};

pub const ResolutionType = enum(i8) {
    /// no resolution attempted or nothing matched
    none = 0,
    /// resolved via RelationIndex typed relation scan
    relation_index = 1,
    /// resolved via transitive closure BFS
    transitive_closure = 2,
    /// resolved via inverse() dispatch
    inverse_lookup = 3,
    /// resolved via symmetric auto-swap
    symmetric_swap = 4,
    /// resolved via general Prolog fire_and_commit
    prolog_rule = 5,
    /// resolved via direct KB fact read
    fact_read = 6,
};
```

---

## Targeted Additions to Existing Structs

### Session — add atom cache and surface staleness tracking

```zig
pub const Session = struct {
    // ... all existing fields ...

    /// per-session cache of atom_id → RelationType mappings
    /// avoids repeated string lookups during query execution
    /// reset on grant change or KB access modification
    atom_rel_cache_offset: i32 = -1,

    /// timestamp of last availability surface rebuild
    /// compared against KB modification times to detect staleness
    surface_last_built: i32 = 0,

    /// true if the surface needs rebuilding (grant change, ingestion, training)
    surface_dirty: bool = true,

    // ... all existing methods ...

    /// mark surface as needing rebuild on next query
    pub fn invalidateSurface(self: *Session) void {
        self.surface_dirty = true;
    }
};
```

---

### KB — add functor index offset

```zig
pub const KB = struct {
    // ... all existing fields including relations, domain_rel_defs, compaction_profile ...

    /// offset to FunctorIndex in arena, -1 if not built
    /// built lazily when rules_count exceeds FUNCTOR_INDEX_THRESHOLD
    /// accelerates rule head lookup by functor/arity
    functor_index_offset: i32 = -1,

    // ... all existing methods ...

    /// true if this KB has a functor index for fast rule head lookup
    pub fn hasFunctorIndex(self: KB) bool {
        return self.functor_index_offset != -1;
    }

    /// true if this KB should have a functor index but doesn't yet
    pub fn needsFunctorIndex(self: KB) bool {
        return self.rules_count >= FUNCTOR_INDEX_THRESHOLD and self.functor_index_offset == -1;
    }
};
```

---

### LevelStats — add pre-resolution tracking

```zig
pub const LevelStats = struct {
    // ... all existing fields including l3_relation_queries, l3_transitive_closures, l3_inverse_lookups ...

    /// L3 operations resolved by pre-LLM pattern detection
    /// (query answered before the LLM generated any tokens)
    l3_pre_resolutions: i64 = 0,

    /// L2 operations where LLM selected from candidates provided by pre-resolution
    /// (pre-resolution found options but couldn't disambiguate)
    l2_assisted_selections: i64 = 0,

    /// L1 operations where pre-resolution ran but found nothing
    /// (pattern detection fired but no matching data existed)
    l1_pre_resolution_misses: i64 = 0,

    // ... all existing methods ...

    /// ratio of pre-resolution hits to total pre-resolution attempts, Q16
    pub fn preResolutionHitRate(self: LevelStats) Q16 {
        const attempts = self.l3_pre_resolutions + self.l2_assisted_selections + self.l1_pre_resolution_misses;
        if (attempts == 0) return Q16.zero();
        const hits = self.l3_pre_resolutions + self.l2_assisted_selections;
        return Q16.fromParts(
            @intCast(@divTrunc(hits * Q16.D, attempts)),
            0,
            0,
        );
    }
};
```

---

### WorkItem — add pre-resolution result slot

```zig
pub const WorkItem = struct {
    // ... all existing fields (op, a_ptr, b_ptr, c_ptr, m, n, k, seq_len, n_heads, d_head, scale_v, completion) ...

    /// offset into per-core scratch where L3PreResolution result is stored
    /// -1 if no pre-resolution was attempted for this work item
    /// set by the pre-resolution pass before LLM generation begins
    pre_resolution_offset: i32 = -1,

    /// offset into per-core scratch where QueryClassification is stored
    /// -1 if no classification was performed
    /// the pinned thread reads this to decide whether to attempt L3
    classification_offset: i32 = -1,
};
```

---

All new structs have defaults. All use existing types (VdrId, Q16, RelationType, Arena). Parse-time structs (QueryClassification, RelationPattern, RuleCandidate, L3PreResolution) live in per-core scratch and are ephemeral. Session-attached structs (AtomRelTypeCache) live in per-core session arena and die with the session. Surface structs (KbSummary, RelationSurfaceEntry, RuleSurfaceEntry) are asserted as facts in `_llm.concepts` KBs. Index structs (FunctorIndex, FunctorIndexEntry) live in global arena alongside their KB's data and persist via normal KB save/load.
