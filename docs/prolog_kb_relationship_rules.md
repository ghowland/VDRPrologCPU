# VDR-Prolog Knowledge Composition — Technical Specification

## How Typed Relations, Prolog Rules, and KB Structure Compose into Mechanical Reasoning

### Version 1.0 — Canonical Reference

---

## 1. Purpose

This spec defines how VDR-Prolog's typed relation system, Prolog engine, and KB tree compose to produce mechanical reasoning over structured knowledge. Every query the system answers, every inference it draws, and every connection it discovers operates through the mechanisms described here.

The system does not reason by analogy, intuition, or pattern matching in weights. It reasons by traversing typed edges in indexed graphs, firing rules over ground facts, and composing results through well-defined algebraic operations on relation types. The LLM provides orchestration and judgment. This spec describes what it orchestrates.

---

## 2. The Three Layers of Knowledge

### 2.1 Facts (Ground Assertions)

A fact is a typed relation between two entities stored in the KB:

```
enables(cn12_conceptual_metaphor, mf1_war_argument).
```

This asserts that conceptual metaphor enables the WAR→ARGUMENT metaphor frame. The assertion lives as a `TypedRelation` struct (48 bytes) in the KB's relation array and as a `TAG_RELATION` Fact for provenance tracking.

Facts come from compacted document ingestion. Each relationship line in a compact file becomes one fact. The system currently holds facts from English grammar, English phrasing, English vocabulary, connections, movement/locomotion, mathematics of logic, mathematics foundations, physics, ancient philosophy, programming data structures, programming algorithms, finite state machines, databases, and utility AI. Each domain adds entities and edges. The structural rules that reason over them do not change.

### 2.2 Rules (Inference Templates)

A rule is a universally quantified conditional that derives new facts from existing ones:

```prolog
enables(X, Z) :- enables(X, Y), enables(Y, Z).
```

This says: for all X, Y, Z — if X enables Y and Y enables Z, then X enables Z. The rule fires at L3 by BFS over the RelationIndex. No LLM tokens consumed.

Rules come from two sources: the core Prolog ruleset (domain-agnostic structural rules derived from RelationType properties) and domain-specific rules asserted during ingestion or by the LLM at L2.

### 2.3 Queries (Goal Resolution)

A query asks whether a fact holds or what bindings satisfy a pattern:

```prolog
?- enables(symmetry, X).
```

This asks: what does symmetry enable? The engine scans the RelationIndex for `enables` edges with `from_id = symmetry`, follows transitive closure if the rule applies, and returns all bindings for X.

---

## 3. RelationType as Algebraic Structure

### 3.1 The Enum Is the Schema

Every relationship in the system maps to a `RelationType` enum value. The enum defines three compile-time properties per type:

```zig
pub fn inverse(self: RelationType) RelationType { ... }
pub fn isSymmetric(self: RelationType) bool { ... }
pub fn isTransitive(self: RelationType) bool { ... }
```

These three properties generate all structural inference rules. No domain document needs to declare transitivity or symmetry — the RelationType enum already knows.

### 3.2 The Three Properties

**Transitivity.** If R is transitive and R(A,B) and R(B,C) hold, then R(A,C) holds. This generates the closure rule:

```prolog
R(X, Z) :- R(X, Y), R(Y, Z).    %% for every transitive R
```

Transitive types: `enables`, `requires`, `specializes`, `generalizes`, `part_of`, `contains`, `follows`, `precedes`, `depends_on`, `extends`, `scoped_to`, `flows_to`.

Implementation: BFS over contiguous integer arrays in the RelationIndex. Each hop is an array scan. The full closure is the set of all nodes reachable from the source by edges of that type.

**Symmetry.** If R is symmetric and R(A,B) holds, then R(B,A) holds. This generates:

```prolog
R(Y, X) :- R(X, Y).    %% for every symmetric R
```

Symmetric types: `prevents`, `contradicts`, `equivalent_to`, `approximates`, `borders`, `aliases`, `complement_of`, `agrees_with`, `and_also`, `or_else`, `complements`, `parallel_to`, `opposes`, `alternative_to`, `contrasts`, `connects_to`.

Implementation: when querying R(target, X), the engine also checks R(X, target). No duplicate storage needed — the query direction is reversed at query time.

**Inverse.** If R has inverse R⁻¹, and R(A,B) holds, then R⁻¹(B,A) holds. This generates:

```prolog
R_inv(Y, X) :- R(X, Y).    %% for every R with defined inverse
```

Key inverse pairs: `enables`↔`depends_on`, `specializes`↔`generalizes`, `part_of`↔`contains`, `follows`↔`precedes`, `validates`↔`verified_by`, `causes`↔`result_of`, `source_of`↔`destination_of`, `protects`↔`threatens`, `greater_than`↔`less_than`.

Implementation: when querying `depends_on(X, target)`, the engine rewrites to `enables(target, X)` and scans the `enables` index. One index serves both directions.

### 3.3 Property Composition

The three properties compose. For a transitive relation with an inverse:

```prolog
%% enables is transitive, inverse is depends_on
enables(X, Z) :- enables(X, Y), enables(Y, Z).     %% closure
depends_on(Y, X) :- enables(X, Y).                   %% inverse
depends_on(X, Z) :- depends_on(X, Y), depends_on(Y, Z). %% closure on inverse (because depends_on is also transitive)
```

For a symmetric transitive relation like `equivalent_to`:

```prolog
equivalent_to(Y, X) :- equivalent_to(X, Y).          %% symmetry
equivalent_to(X, Z) :- equivalent_to(X, Y), equivalent_to(Y, Z). %% closure
%% Together: equivalence classes. All entities equivalent to X form a set.
```

This is exactly a mathematical equivalence relation (reflexive via identity, symmetric by property, transitive by closure). The engine computes equivalence classes by BFS.

---

## 4. The RelationIndex

### 4.1 Structure

```zig
pub const RelationIndex = struct {
    by_type_counts: [128]i32,    // count per RelationType slot
    // Plus sorted indices by_from and by_to for directional queries
};
```

`by_type_counts` makes "how many enables relations exist in this KB?" a single i32 read. Relations of the same type are grouped contiguously in arrays for cache-friendly scanning.

### 4.2 Query Execution

A typed relation query bypasses general Prolog unification entirely:

```
queryTypedRelation(kb, rel_type, from, to) → []TypedRelation
    1. Check by_type_counts[@intFromEnum(rel_type)] — if 0, skip KB.
    2. Scan contiguous TypedRelation array for this type.
    3. Filter by from/to if specified.
```

No term construction. No binding stack. No backtracking. Integer comparison on struct fields. This is why L3 is sub-microsecond.

### 4.3 Index Consistency

The RelationIndex is eventually consistent — rebuilt periodically (configurable interval), not on every assertion. Between rebuilds, newly asserted relations are still findable via the KB's relations array (linear scan of the short new-relations list). The index accelerates queries on the bulk; the tail is handled by scanning the delta.

---

## 5. Inheritance Through the Relation Graph

### 5.1 Specialization Inheritance

When X specializes Y, X inherits all of Y's outgoing constraints:

```prolog
requires(X, T) :- specializes(X, Y), requires(Y, T).
prevents(X, T) :- specializes(X, Y), prevents(Y, T).
contains(X, T) :- specializes(X, Y), contains(Y, T).
```

This fires transitively. If A specializes B and B specializes C, then A inherits from both B and C. The engine computes the full ancestor chain via transitive closure on `specializes`, then collects all `requires`/`prevents`/`contains` edges from every ancestor.

Concrete example across documents:

```
%% Grammar: specializes(sc8_transitive_verb, wc2_verb)
%% Phrasing: specializes(cx7_conative, cx6_transitive_construction)
%% Algorithms: specializes(al11_introsort, al5_quicksort)
%% Physics: specializes(d4_optics, d3_electromagnetism)
%% Philosophy: specializes(sc7_peripatetic, sc6_academy) — conceptually via extends
%%
%% Same rule. Different entities. Same integer scan.
```

### 5.2 Instance Inheritance

`instance_of` binds a specific token to a general type. The token inherits all type constraints:

```prolog
requires(Instance, T) :- instance_of(Instance, Type), requires(Type, T).
```

This is how vocabulary words inherit grammar constraints (CW68 "give" is instance of SC10 ditransitive verb, which requires a direct and indirect object), how algorithms inherit technique prerequisites (AL4 merge sort is instance of TE1 divide-and-conquer, which requires divide + conquer + combine steps), and how physics particles inherit force interactions (P7 electron is instance of lepton, which interacts via EM and weak).

### 5.3 Containment Accessibility

When X contains Y, and Y contains Z, Z is accessible within X:

```prolog
contains(X, Z) :- contains(X, Y), contains(Y, Z).
```

This models structural composition. A clause contains a phrase, a phrase contains a word class, therefore the clause has access to that word class. A B-tree node contains keys and child pointers, therefore a B-tree has access to its data through key traversal. An independent clause contains a noun phrase and verb phrase, therefore a sentence provides access to both.

---

## 6. Cross-Document Composition

### 6.1 How Documents Connect

Each compacted document lives in its own KB subtree. Documents connect through shared RelationType edges. The ingestion pipeline resolves cross-document references during fact assertion — if a phrasing entity references a grammar entity by ID prefix, the pipeline resolves the full VdrId.

The system does not require explicit cross-references. Cross-document reasoning emerges from structural rules. If grammar says `instance_of(sp2, cl1)` (SVO is instance of independent clause) and phrasing says `requires(cx6, ar1)` (transitive construction requires agent), and vocabulary says `instance_of(cw68, sc10)` (give is a ditransitive verb), then the system can compose:

```prolog
%% Query: "Is 'She gave him the book' structurally valid?"
%%
%% 1. Vocabulary: cw68 (give) → instance_of sc10 (ditransitive)
%% 2. Grammar: sc10 specializes wc2 (verb) — inherits verb constraints
%% 3. Grammar: requires(sp5, sc10) — SVOO requires ditransitive
%% 4. Phrasing: requires(cx1, ar1) — ditransitive construction requires agent
%% 5. Phrasing: requires(cx1, ar5) — requires goal (recipient)
%% 6. Phrasing: requires(cx1, ar3) — requires theme
%%
%% All requirements satisfied. L3. Zero tokens.
```

### 6.2 The Bridge Pattern

Certain documents serve as structural bridges between otherwise independent domains:

**English** (grammar + phrasing + vocabulary) bridges all domains to human communication. Every domain's content is parsed, queried, and explained through English structure.

**Connections** bridges all domains via a taxonomy of relatedness. Every domain has edges that are instances of connection types (forces are connections, foreign keys are connections, philosophical influences are connections).

**Movement** bridges all domains via a taxonomy of change. Every domain has state transitions, causal chains, and constraints that are instances of movement patterns.

**Math Logic** bridges all domains via a formalization of inference. Every domain's rules are logical formulas. Every domain's queries are logical goals. Every domain's proofs are logical derivations.

**Math Foundations** bridges all domains via mathematical structures. Every domain uses sets, functions, relations, and algebraic structures that are instances of foundational concepts.

These five bridge documents plus the domain-specific documents form a lattice where any two domains connect through at most two bridge hops.

### 6.3 Composition Algebra

Cross-document composition follows algebraic rules determined by RelationType properties. The key compositions:

**Transitive chain across documents:**

```prolog
%% Movement: enables(force, acceleration)
%% Physics: enables(acceleration, velocity_change)
%% Therefore: enables(force, velocity_change)
%%
%% The transitive closure rule fires identically whether
%% the two edges are in the same document or different documents.
%% The engine sees only VdrIds and RelationType — no document boundary.
```

**Inheritance across documents:**

```prolog
%% Data Structures: specializes(st24_avl, st23_bst)
%% Data Structures: validates(co4_invariant, st23_bst)
%% Therefore: validates(co4_invariant, st24_avl) — by inheritance
%%
%% Databases: equivalent_to(ix1_btree_index, st28_btree)
%% Therefore: anything that applies to st28 also applies to ix1.
```

**Inverse bridging across documents:**

```prolog
%% Philosophy: enables(co51_syllogism, logic_dm1)
%%   Syllogism enables propositional logic
%% Inverse: depends_on(logic_dm1, co51_syllogism)
%%   Propositional logic depends on syllogism
%%
%% A philosopher asking "what does syllogism enable?" and
%% a logician asking "what does propositional logic depend on?"
%% get the same edge, traversed in opposite directions.
```

---

## 7. The Execution Level Decision

### 7.1 L3: Typed Relation Query (Zero Tokens)

Every query is first attempted at L3. The engine checks:

1. Does the query match a `rel_type(from, to)` pattern?
2. Does the RelationIndex have entries for this type?
3. Can transitive closure, inverse, or symmetry resolve it?

If yes: scan the index, apply structural rules, return results. Cost: sub-microsecond per hop. Total: microseconds for multi-hop chains.

L3 handles: taxonomy queries ("what is X?"), dependency queries ("what does X need?"), enablement queries ("what does X enable?"), containment queries ("what is inside X?"), sequence queries ("what comes after X?"), conflict queries ("what prevents X?"), and all their transitive closures.

At maturity (10,000+ typed relations, 3,000+ Prolog rules), approximately 93% of queries resolve at L3.

### 7.2 L2: LLM-Guided Rule Selection (~18 Tokens)

When L3 cannot resolve the query (no direct typed relation, no transitive path), the engine checks whether any Prolog rule matches. If multiple rules match, or if the rule requires choosing between alternatives, the LLM runs a short forward pass (~18 tokens) to select which rule to fire.

The LLM does not execute the rule. It selects it. Prolog executes it.

L2 handles: ambiguous queries with multiple valid rule paths, queries requiring judgment about which domain to search, and multi-step reasoning where the sequence of rule applications matters.

### 7.3 L1: Full Forward Pass (50-500 Tokens)

When neither L3 nor L2 can resolve the query, the LLM runs a full forward pass. This handles: novel entities not in any KB, ambiguous natural language requiring pragmatic interpretation, judgment calls about relevance or importance, and prose generation for user-facing responses.

L1 is where the neural network earns its keep. Everything structured runs at L3. Everything requiring genuine judgment runs at L1. The boundary between them is precisely the boundary between what the typed relation system can answer and what it cannot.

### 7.4 Decision Procedure

```prolog
execute(Query, Result, Level) :-
    typed_relation_covers(Query),
    execute_l3(Query, Result),
    Level = l3.

execute(Query, Result, Level) :-
    \+ typed_relation_covers(Query),
    prolog_rule_covers(Query),
    select_rule(Query, Rule),       %% may invoke LLM for ~18 tokens
    execute_rule(Rule, Query, Result),
    Level = l2.

execute(Query, Result, Level) :-
    \+ typed_relation_covers(Query),
    \+ prolog_rule_covers(Query),
    execute_llm_forward(Query, Result),  %% full forward pass
    Level = l1.
```

---

## 8. Domain-Agnostic Core Rules

The following rules fire identically across all ingested domains. They are the complete set of structural inference rules generated from RelationType properties. No domain document adds structural rules — it adds only facts.

### 8.1 Taxonomy Rules

```prolog
specializes(X, Z) :- specializes(X, Y), specializes(Y, Z).
generalizes(Y, X) :- specializes(X, Y).
requires(X, T) :- specializes(X, Y), requires(Y, T).
prevents(X, T) :- specializes(X, Y), prevents(Y, T).
contains(X, T) :- specializes(X, Y), contains(Y, T).
requires(X, T) :- instance_of(X, Y), requires(Y, T).
contains(X, T) :- instance_of(X, Y), contains(Y, T).
prevents(X, T) :- instance_of(X, Y), prevents(Y, T).
```

### 8.2 Containment Rules

```prolog
contains(X, Z) :- contains(X, Y), contains(Y, Z).
part_of(Y, X) :- contains(X, Y).
part_of(X, Z) :- part_of(X, Y), part_of(Y, Z).
```

### 8.3 Enablement Rules

```prolog
enables(X, Z) :- enables(X, Y), enables(Y, Z).
depends_on(Y, X) :- enables(X, Y).
```

### 8.4 Requirement Rules

```prolog
requires(X, Z) :- requires(X, Y), requires(Y, Z).
requires(X, T) :- extends(X, Y), requires(Y, T).
```

### 8.5 Symmetric Rules

```prolog
prevents(Y, X) :- prevents(X, Y).
opposes(Y, X) :- opposes(X, Y).
equivalent_to(Y, X) :- equivalent_to(X, Y).
contrasts(Y, X) :- contrasts(X, Y).
parallel_to(Y, X) :- parallel_to(X, Y).
contradicts(Y, X) :- contradicts(X, Y).
alternative_to(Y, X) :- alternative_to(X, Y).
connects_to(Y, X) :- connects_to(X, Y).
complements(Y, X) :- complements(X, Y).
```

### 8.6 Inverse Rules

```prolog
verified_by(Y, X) :- validates(X, Y).
validates(Y, X) :- verified_by(X, Y).
decomposes_to(X, Y) :- composed_of(X, Y).
composed_of(Y, X) :- decomposes_to(X, Y).
follows(Y, X) :- precedes(X, Y).
precedes(Y, X) :- follows(X, Y).
```

### 8.7 Sequence and Transformation Rules

```prolog
follows(X, Z) :- follows(X, Y), follows(Y, Z).
precedes(X, Z) :- precedes(X, Y), precedes(Y, Z).
transforms_to(X, Z) :- transforms_to(X, Y), transforms_to(Y, Z).
flows_to(X, Z) :- flows_to(X, Y), flows_to(Y, Z).
extends(X, Z) :- extends(X, Y), extends(Y, Z).
derived_from(X, Z) :- derived_from(X, Y), derived_from(Y, Z).
```

### 8.8 Scope and Visibility

```prolog
visible_in(X, Scope) :- scoped_to(X, Scope).
visible_in(X, Outer) :- scoped_to(X, Scope), part_of(Scope, Outer).
```

### 8.9 Validation Chain

```prolog
validation_chain(Controller, Mechanism, Rule) :-
    determined_by(Mechanism, Controller),
    validates(Mechanism, Rule).
```

---

## 9. Domain-Specific Rule Patterns

Domain documents do not add structural rules. They add facts that the structural rules operate on, and they add domain-specific query patterns that compose structural rules for common domain questions.

### 9.1 Selection Rules

Every domain has a "given requirements, select best option" pattern:

```prolog
%% Algorithms: select sort given properties
select_sort(AL, Properties) :-
    instance_of(AL, sort_algorithm),
    forall(member(P, Properties), has_property(AL, P)).

%% Databases: select index given query pattern
select_index(IX, QueryPattern) :-
    instance_of(IX, index_type),
    supports(IX, QueryPattern).

%% Utility AI: select curve given input characteristics
select_curve(SC, InputType) :-
    instance_of(SC, scoring_curve),
    appropriate_for(SC, InputType).
```

The pattern is identical. The entities and properties differ.

### 9.2 Failure Prediction Rules

Every domain has a "given system state, predict failure" pattern:

```prolog
risk(System, FailureMode) :-
    causes(Cause, FailureMode),
    exhibits(System, Cause).
```

This fires for: hash table clustering (data structures), deadlock (databases), score collapse (utility AI), state explosion (FSM), resonance failure (movement/physics), and wrong cardinality (databases). Same rule, different entities.

### 9.3 State Machine Rules

Every domain has entities with state transitions:

```prolog
can_transition(Entity, From, To) :-
    current_state(Entity, From),
    evolves_to(From, To),
    \+ blocked(Entity, To).
```

This fires for: session lifecycle (VDR-Prolog), HTTP requests (VDR-Prolog), transaction lifecycle (databases), stellar evolution (physics), philosophical development (philosophy), samsara cycle (philosophy/Buddhism), and particle decay (physics). Same FSM rules, different state sets.

---

## 10. The Confidence Dimension

Every TypedRelation carries provenance including confidence:

```zig
pub const TypedRelation = struct {
    rel_type: RelationType,
    from_id: VdrId,
    to_id: VdrId,
    provenance: Provenance,
    strength: Q16,
    scope_kb_id: VdrId,
};
```

Confidence propagates through inference chains:

```prolog
%% Chain rule: confidence of derived fact = minimum of inputs
confidence(Derived, MinConf) :-
    derived_from_facts(Derived, Facts),
    maplist(confidence, Facts, Confs),
    min_list(Confs, MinConf).

%% Parallel agreement: confidence = maximum of agreeing sources
confidence(Fact, MaxConf) :-
    multiple_sources(Fact, Sources),
    all_agree(Sources),
    maplist(confidence, Sources, Confs),
    max_list(Confs, MaxConf).
```

A fact derived through LLM compaction starts at confidence 19660 (30/100 = llm_generated). If that fact is verified by a human, it promotes to 52428 (80/100 = published). If the Prolog engine derives a new fact from verified facts, the derived fact gets confidence 65536 (1/1 = prolog_derivation), but the chain minimum is still bounded by the weakest input.

This means the system knows not just what it knows, but how much to trust what it knows. L3 results from vdr_computation or prolog_derivation carry full confidence. L1 results from the LLM carry llm_generated confidence and must be promoted explicitly.

---

## 11. The KB Tree as Namespace

### 11.1 Path-Based Addressing

Every entity is addressable by dotted path:

```
root.language.english.grammar.word_classes.wc1     → "noun"
root.science.physics.forces.f2                     → "electromagnetic"
root.computing.programming.algorithms.al4          → "merge sort"
root.humanities.philosophy.ancient.thinkers.th15    → "Aristotle"
```

The path is the namespace. Two different domains can have entities with the same local name (e.g., `co1` in connections means "Connection", `co1` in movement means "Position", `co1` in databases means "Database") without collision because their full paths differ.

### 11.2 Scoped Resolution

When the Prolog engine resolves a query, it searches the session tree first (negative IDs), then the global tree (positive IDs). Within the global tree, it walks from the most specific scope outward.

A query about `enables(X, Y)` within `root.science.physics` first checks the physics KB's local relations, then walks up to `root.science`, then to `root`. Cross-domain relations (physics entity enables math concept) are stored at the junction point or in one of the participating KBs.

### 11.3 Grant-Gated Visibility

Not all KBs are visible to all sessions. The grant system controls which KBs a session can access. This means different users can see different typed relations — the same query can produce different results depending on grants.

For knowledge composition, this means: the system's reasoning is bounded by what the session can see. A session without physics grants cannot traverse physics relations, even if they would resolve a query. This is by design — it prevents unauthorized knowledge access while maintaining structural soundness within the visible scope.

---

## 12. How New Domains Integrate

When a new compacted document is ingested, the following happens:

1. **Parser** reads pipe-delimited tables, creates entities with IDs.
2. **Validator** checks ID uniqueness, relationship target existence, column counts.
3. **KB Creator** makes parent document KB + child KB per table.
4. **Fact Asserter** creates TAG_TEXT and TAG_VALUE facts from table cells.
5. **Relation Asserter** reads the relationships section, maps each to a canonical RelationType via the `relation_mapping` table, creates TypedRelation structs + TAG_RELATION facts + Prolog rules.
6. **Domain Registration** registers any new domain-specific relation types (slots 1,000,000+).
7. **Index Rebuild** triggered on next interval to incorporate new relations.

After ingestion, the new domain's entities are immediately available to all structural rules. No rule changes. No retraining. No recompilation. The domain's typed relations join the global graph and participate in transitive closure, inheritance, inverse queries, and cross-document composition from the moment they are indexed.

The system grows by adding facts. The rules are fixed. The engine is fixed. The model weights do not change. Only the knowledge base grows.

---

## 13. Invariants

```
1.  Every TypedRelation has a TAG_RELATION Fact for provenance.
2.  RelationType slots 0-99 are system-defined and frozen at compile time.
3.  Domain relation slots 1,000,000+ are first-come, never reassigned.
4.  RelationIndex is eventually consistent — rebuilt periodically.
5.  Typed relation queries bypass general Prolog unification.
6.  Transitive closure is BFS over contiguous integer arrays.
7.  Symmetric queries check both directions without duplicate storage.
8.  Inverse queries rewrite to the stored direction and scan that index.
9.  Inheritance propagates requires/prevents/contains through specializes and instance_of.
10. Confidence propagates as minimum through derivation chains.
11. Cross-document composition uses the same rules as within-document.
12. No structural rule is domain-specific. All structural rules are RelationType-derived.
13. Domain-specific rules are query patterns that compose structural rules.
14. The execution level (L3/L2/L1) is determined by coverage, not by domain.
15. Grant-gating bounds visibility but does not change rule semantics.
16. New domains integrate by adding facts. Rules and engine are fixed.
17. Every relation_mapping in a compact file normalizes to a canonical RelationType.
18. The relation graph is a single connected structure across all ingested documents.
```

---

## 14. Summary

The VDR-Prolog knowledge composition system works as follows:

Compacted documents provide **typed facts** — ground assertions of relationships between named entities using canonical RelationType values.

The RelationType enum provides **algebraic properties** — transitivity, symmetry, and inverse — that generate all structural inference rules at compile time.

The RelationIndex provides **fast access** — contiguous arrays grouped by type, enabling sub-microsecond typed queries that bypass Prolog unification entirely.

The core Prolog ruleset provides **domain-agnostic inference** — inheritance, closure, inverse resolution, containment accessibility, and validation chains that fire identically across every domain.

Domain-specific rules provide **query patterns** — selection rules, failure prediction, state machines, and other compositions of structural rules tailored to common questions in each domain.

The confidence system provides **epistemic grading** — every derived fact carries the minimum confidence of its inputs, so the system knows how much to trust each conclusion.

The KB tree provides **namespace and scope** — path-based addressing, scoped resolution, and grant-gated visibility that organize knowledge without collision and control access without changing semantics.

Cross-document composition provides **emergent reasoning** — facts from different domains connect through shared RelationType edges, and structural rules derive conclusions that no single document contains. The grammar says what sentences are valid. The phrasing says what meanings are packaged. The vocabulary says which words exist. The connections say how things relate. The movement says how things change. The logic says how reasoning works. The math says what structures underlie everything. Each domain adds its entities. The rules connect them all.

The engine does not grow when knowledge grows. The rules do not change when domains change. The model weights do not update when facts are added. Only the fact base grows. The reasoning is mechanical, exact, and deterministic. The LLM orchestrates and judges. The graph does the work.
