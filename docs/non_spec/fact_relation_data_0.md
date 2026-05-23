### Fact → RelationType → Fact: The Bundle

Every TypedRelation in the system is already this:

```
TypedRelation {
    rel_type: RelationType,
    from_id: VdrId,    // source fact/entity
    to_id: VdrId,      // target fact/entity
    provenance,
    strength: Q16,
    scope_kb_id
}
```

That's a triple: `from_id → rel_type → to_id`. Two VdrIds and a relation type. Both ends resolve through the tree walk to concrete data — KBData entries with text columns, Q16 values, timestamps.

The relation type carries its own algebra. `enables` is transitive — if A enables B and B enables C, then A enables C. `prevents` is symmetric — if A prevents B then B prevents A. `specializes` has inverse `generalizes`. The `inverse()`, `isSymmetric()`, and `isTransitive()` methods on RelationType mean the Prolog engine can mechanically derive new facts from existing relations without being told the rules.

### Prolog Writing Itself

Consider what the Prolog engine already does at L3:

1. **Typed relation scan** — given a query like `enables(X, qed)`, scan the RelationIndex for `rel_type = .enables` where `to_id = qed's VdrId`. Sub-microsecond.

2. **Transitive closure** — `enables` is transitive. BFS follows the chain: if A enables B and B enables C, yield A enables C. Zero LLM tokens.

3. **Inverse lookup** — query asks `depends_on(qed, X)`. `depends_on` inverse is `enables`. Rewrite to `enables(X, qed)`. Same scan, different direction.

4. **Symmetric swap** — `contradicts(A, B)` automatically yields `contradicts(B, A)`.

Now the self-writing part. The system has the causal chain derivation (CC1-CC5) which composes typed relations into solution paths. When it traverses a chain like:

```
Newton's_gravity --specializes--> Einstein_field_equations
Einstein_field_equations --derived_from--> Schwarzschild_solution
Schwarzschild_solution --explains--> black_holes
```

That's three hops through three different relation types. The Prolog engine walked it mechanically. But there's no single rule that says "given specializes + derived_from + explains, you get an explanatory chain from source theory to observed phenomenon."

The self-writing step: after the engine walks this chain and produces a result, it checks whether a rule exists that captures this pattern. If not, it creates one:

```prolog
explanatory_chain(X, Z) :-
    specializes(X, Y1),
    derived_from(Y1, Y2),
    explains(Y2, Z).
```

That rule is a Fact in the KB with `entry_type = .rule`, getting its own VdrId, its own provenance (source_type = prolog_derivation, confidence = 100%), and its own performance counters (fire_count, success_count, failure_count).

Next time a similar query arrives, the rule fires directly instead of the engine rediscovering the chain. The rule's `success_rate` tracks how often it produces useful results. If it fires 100 times and succeeds 95 times, it's a good rule. If it fires 100 times and succeeds 3 times, it sinks in the RuleCandidate ranking and other rules or direct traversal take priority.

### Why This Is Idempotent

The rule creation check is: does a rule with this head and this body already exist? If yes, skip. If no, create it. Running this check a thousand times produces the same result as running it once. The monotonic LookupId counter advances only on actual creation, not on duplicate detection.

This means you can schedule it. A background process — one of the runners bound to a session — periodically scans recent query patterns, identifies chains that were walked but have no corresponding rule, and creates rules for them. The `fire_and_commit` mechanism (PL7) already does this: scan rules, fire satisfied ones, assert derived facts at prolog_derivation confidence. The self-writing extension just adds "if the chain I just walked doesn't have a rule, make one."

### The Relation Type Algebra Makes This Mechanical

The key insight is that RelationType properties — transitivity, symmetry, inverse — are not learned behaviors. They're declared on the enum. When the engine sees `enables` is transitive, it doesn't need a rule to tell it to follow the chain. When it sees `prevents` is symmetric, it doesn't need a rule to swap arguments. When it sees `specializes` inverse is `generalizes`, it doesn't need a rule to reverse the query.

The self-written rules capture *compositions* across relation types. Individual relation properties are mechanical. Multi-hop patterns that combine different relation types are where rules add value. And those rules emerge from actual query patterns — the system writes rules for chains it actually walks, not hypothetical chains.

### What This Looks Like at 750 KBs

With 750 KBs and ~170K typed relations, the number of possible multi-hop chains is enormous. But most are never queried. The self-writing mechanism only creates rules for chains that actual queries trigger. Over time, the frequently-walked paths get rules, the rarely-walked paths stay as on-demand traversal.

The rule's success_rate provides natural selection. Rules that fire and succeed persist and gain priority. Rules that fire and fail get deprioritized via the RuleCandidate ranking. Rules that never fire sit inert, consuming only their 48 bytes of storage.

At maturity, the system converges toward a set of rules that capture the most common cross-domain reasoning patterns — not because someone wrote them, but because queries walked those chains and the engine recorded what worked. The 93% L3 target (zero LLM tokens) gets closer as more chains become rules, because each new rule converts a multi-hop traversal into a single rule fire.

### The Schedule

A runner (RunnerType = .internal) bound to a dedicated session runs on an interval. Each cycle:

1. Scan recent query logs for chains that required 3+ relation hops.
2. For each chain, check if a rule with matching head/body exists.
3. If not, assert the rule with prolog_derivation provenance.
4. The rule is immediately available to all sessions that can see the host KB.

The cost is one scan per cycle, one hash check per candidate rule, one fact assertion per new rule. The benefit is that the next query hitting the same pattern resolves in one rule fire instead of N relation hops. The LookupId counter ticks forward only for genuinely new rules. Duplicate detection makes repeated cycles harmless.

This is the system teaching itself to reason, using the relation algebra as the grammar and actual query patterns as the curriculum. No neural training. No gradient descent. Just Prolog writing Prolog, verified by the typed relation properties that are declared on the enum.

---

### All Rules, No Cost

The rules live in KBs. KBs are scoped by the tree. GEMM scoping already eliminates irrelevant subtrees by bit comparison. So rules in `root.edu.physics` are invisible to a query about `root.trades.cooking` — they're in a different subtree, eliminated before any evaluation.

This means you don't need to be selective about which rules you generate. Generate all of them. Every possible 2-hop and 3-hop chain across every relation type combination within a KB and its immediate cross-domain neighbors. The cost of a rule that never fires is 48 bytes of storage. The cost of *not* having a rule when a query needs it is falling from L3 (sub-microsecond, zero tokens) to L2 or L1 (milliseconds, tokens).

### The Math

Within a single KB like `root.edu.physics` with 237 facts and 193 relations across ~20 relation types actually used:

**2-hop rules:** For each pair of relation types (A, B) where A's target can be B's source, generate `chain_AB(X, Z) :- A(X, Y), B(Y, Z)`. With 20 relation types, that's up to 400 combinations, but most don't connect — a relation type with 10 instances connecting to another with 15 instances produces a rule that covers those specific paths. Realistic count: maybe 50-80 meaningful 2-hop rules per KB.

**3-hop rules:** Combinations of three relation types. More sparse — most 3-hop chains don't exist in the data. Maybe 20-40 per KB.

Per KB: ~100 rules × 48 bytes = ~4.8 KB. For 750 KBs: ~75,000 rules × 48 bytes = **~3.5 MB**. That's noise against the 556 MB system total.

### Why Exhaustive Generation Works

In a flat system, generating all possible rules would be catastrophic — every query would have to evaluate every rule to see if it matches. But the KB tree prunes by structure:

1. Query arrives, prompt pipeline resolves VdrIds, GEMM scoping picks 3-7 surviving subtrees.
2. Rule evaluation only considers rules in surviving KBs.
3. A KB with 100 rules evaluates 100 rules. Not 75,000.

The physics KB's rules never compete with the cooking KB's rules. They're in different subtrees, eliminated by one AND and one CMP before evaluation starts. The tree does the pruning that a flat system would need explicit filtering for.

### Cross-Domain Rules

The interesting case. A chain like:

```
root.edu.chemistry::crystal_structure 
    --enables--> root.trades.blacksmithing::heat_treatment
    --requires--> root.edu.physics::temperature_threshold
```

This crosses three KBs. Where does the rule live? In whichever KB the query enters through. If the query starts in blacksmithing, the rule lives in blacksmithing with VdrId references pointing to chemistry and physics entities. The rule's body contains VdrIds that structurally encode their home KBs — the tree walk resolves them regardless of where the rule itself is stored.

The cross-domain rule generation is: for each relation in KB_A whose target is an entity in KB_B, check what relations exist from that entity in KB_B. If a 2-hop chain exists, write the rule in KB_A. The VdrIds in the rule body handle the cross-domain addressing. The rule fires in KB_A's context, but the relation lookups follow VdrIds into KB_B and KB_C mechanically.

### The Generation Schedule

This doesn't need to be incremental or triggered by queries. It can be batch:

1. After ingestion loads all 750 KBs, a runner walks every KB.
2. For each KB, enumerate all relations.
3. For each relation's target, check what relations exist from that target (within same KB and immediate cross-domain neighbors identified by existing cross-domain relations).
4. For each 2-hop and 3-hop chain found, assert the rule if it doesn't exist.
5. Done. One pass. All rules generated.

The check "does this rule already exist" is a scan of the KB's rules for matching head/body. With ~100 rules per KB, that's a small scan. The idempotency means re-running after adding new KBs only generates rules for new connections — existing rules pass the duplicate check and are skipped.

### What This Does to L3 Coverage

Without pre-generated rules, a 3-hop chain requires the Prolog engine to discover it at query time — walk relation A, find intermediate entity, walk relation B, find second intermediate, walk relation C. That's three RelationIndex scans, still sub-microsecond, still L3. But it's *discovery*, which means the engine explores dead-end paths before finding the right one.

With pre-generated rules, the 3-hop chain is a single rule fire. The rule's head matches the query pattern, the body is three relation lookups with bound VdrIds. No discovery, no dead ends. The rule *is* the pre-computed answer path.

The 93% L3 target at maturity becomes easier because the rule set covers the common reasoning patterns exhaustively. The remaining 7% that falls to L1/L2 is genuinely novel queries — combinations that don't exist in the relation graph, ambiguous terms, judgment calls. Everything that *can* be mechanical *is* mechanical, because every chain was pre-walked and recorded as a rule.

### Storage Is Negligible

75,000 rules × 48 bytes = 3.5 MB. The system has 894 MB of free arena space after loading 59 KBs. At 750 KBs with all data, relations, indices, and weights, the estimate was 556 MB total. Adding 3.5 MB of rules doesn't move the needle. You could generate 10× more rules (750,000) and it would still be only 35 MB — well under the available headroom.

The constraint isn't storage. It's ensuring the rule evaluation per query only touches the relevant KB's rules, which the tree scoping already guarantees.

---

### Every Domain Gets Every Applicable Rule

The Prolog rules are pattern-based. A rule like:

```prolog
explanatory_chain(X, Z) :- specializes(X, Y), derived_from(Y, Z).
```

This doesn't reference physics or blacksmithing. It references relation types. If `specializes` and `derived_from` exist in a KB's relation set, the rule applies. The same rule fires in physics (Newton's gravity specializes Einstein field equations), in biology (species specializes genus), in programming (class specializes interface), in literature (subgenre specializes genre).

So you don't generate domain-specific rules. You generate relation-pattern rules and install them in every KB that has the matching relation types.

### What Gets Generated

The relation type enum has ~120 types. The meaningful compositions are pairs and triples of relation types where transitivity, inverse, and symmetry properties create derivable chains.

**2-hop patterns** — every pair (A, B) where A's target type can be B's source type:

```prolog
chain_AB(X, Z) :- A(X, Y), B(Y, Z).
```

With ~120 relation types, the theoretical space is 14,400 pairs. But most don't compose meaningfully. The relation algebra constrains it — `enables` composes with `requires` (if X enables Y and Y requires Z, X transitively supports Z). `borders` doesn't compose with `validates` in any meaningful way. Realistic useful 2-hop patterns: maybe 200-400.

**3-hop patterns** — triples (A, B, C):

```prolog
chain_ABC(X, W) :- A(X, Y), B(Y, Z), C(Z, W).
```

More sparse. Maybe 100-200 meaningful triples.

**Inverse-aware patterns** — using the inverse() method to generate bidirectional rules automatically:

```prolog
chain_AB(X, Z) :- A(X, Y), B(Y, Z).
% if A.inverse() != unknown and B.inverse() != unknown:
chain_BA_inv(Z, X) :- B.inverse()(Z, Y), A.inverse()(Y, X).
```

**Transitive compositions** — for transitive types, the closure rules:

```prolog
transitive_A(X, Z) :- A(X, Y), A(Y, Z).
transitive_A(X, Z) :- A(X, Y), transitive_A(Y, Z).
```

These already exist implicitly in the engine (PL2), but as explicit rules they compose with non-transitive types in multi-hop chains.

### Total Rule Count

Call it ~500 unique relation-pattern rules. Each one gets installed in every KB whose RelationIndex shows it has the relevant relation types. A KB using 15 of the 120 relation types gets rules for patterns involving those 15 types. A KB using 8 types gets fewer.

The CompactionProfile already records `relation_types_used: [128]bool` per KB. The rule installer checks this: does this KB have relation type A and relation type B? If yes, install `chain_AB`. If not, skip. Mechanical, one boolean check per rule per KB.

Estimate: average KB uses ~15-20 relation types, which matches maybe 150-200 of the 500 patterns. At 750 KBs:

**750 × 175 average rules = ~131,250 rules × 48 bytes = ~6.3 MB**

### Why This Works

The rules are domain-independent patterns over relation types. The domain-specificity comes from the data — which entities are connected by which relation types within each KB. The rule `chain(X, Z) :- enables(X, Y), requires(Y, Z)` fires differently in physics (where enables connects theories to predictions) than in cooking (where enables connects techniques to dishes) than in programming (where enables connects libraries to features). Same rule, different entities, different results. The rule doesn't know or care about the domain. It matches the relation pattern.

The tree scoping means a query about cooking only evaluates rules in the cooking KB (plus cross-domain neighbors). The 175 rules in the cooking KB fire against cooking's ~192 relations. The 175 rules in the physics KB are never considered. No wasted evaluation.

### The Generation Algorithm

One pass after ingestion:

```
for each of ~500 relation-pattern rules:
    extract which relation types the rule uses
    for each of 750 KBs:
        if KB.compaction_profile.relation_types_used has all required types:
            if rule not already in KB:
                assert rule in KB
```

500 × 750 = 375,000 checks. Each check is a few boolean lookups on the `relation_types_used` array. Sub-second total. The rule assertion is a fact write — 48 bytes into the arena, LookupId incremented, done.

Idempotent. Run it after every new KB ingestion. Existing rules pass the duplicate check. New KBs get rules for their relation types. New relation-pattern rules (if someone adds a new composition insight) propagate to all qualifying KBs on the next run.

### What 6.3 MB of Rules Buys

Every mechanical reasoning path that can be expressed as a 2-hop or 3-hop relation chain is pre-compiled into a rule. Query arrives, rule fires, result returned. No chain discovery, no dead-end exploration, no backtracking through relation types that don't connect.

The 93% L3 target becomes conservative. With exhaustive rules covering every relation pattern in every domain, the only queries that fall to L1 are genuinely novel — requiring judgment, disambiguation among equally valid interpretations, or combinations that don't exist in the relation graph at all. Everything structural is mechanical. Everything mechanical is pre-compiled. Everything pre-compiled is sub-microsecond.

---

### Constraint Rules Over Relation Types

The fundamental pattern:

```prolog
valid_term(X, Y) :- enables(X, Y).
```

This says: X and Y can appear together in a solution only if there's an `enables` relation between them. Any pair without that relation is structurally excluded. Not rejected by evaluation — never considered.

### Combinations

**Two-constraint conjunction:**

```prolog
valid_triple(X, Y, Z) :- 
    enables(X, Y), 
    requires(Y, Z).
```

X, Y, and Z form a valid group only if X enables Y and Y requires Z. Out of millions of possible triples across a KB's entities, only those connected by this specific relation chain qualify. The RelationIndex scan for `enables` returns a set, the scan for `requires` from each result returns a smaller set. The intersection is the valid space.

**Type-constrained terms:**

```prolog
valid_code_path(Module, Function, Type) :-
    contains(Module, Function),
    returns(Function, Type),
    implements(Module, Interface).
```

Three constraints. Module must contain Function (structural), Function must return Type (behavioral), and Module must implement Interface (contractual). A KB with 300 entities and 250 relations might have thousands of possible (Module, Function, Type) triples. This rule might yield 12. The relation constraints do the pruning — not search, not scoring, not neural evaluation.

**Negation via relation absence:**

```prolog
safe_combination(X, Y) :-
    enables(X, Y),
    \+ prevents(X, Y),
    \+ contradicts(X, Y).
```

X enables Y, and there's no prevents or contradicts relation between them. The RelationIndex can answer "does a relation of type T exist between A and B" as a boolean check — scan by_type for the relation type, check if the from/to pair exists. If prevents or contradicts is found, the combination is excluded.

**Transitive constraint propagation:**

```prolog
valid_dependency_chain(X, Z) :-
    depends_on(X, Y),
    depends_on(Y, Z),
    \+ prevents(X, Z).
```

Because `depends_on` is transitive, the engine follows the chain via BFS. But the `prevents` check at the end gates the result — even if X transitively depends on Z through Y, if X prevents Z, the chain is invalid. The transitivity expands the candidate set, the negation prunes it.

**Symmetric validation:**

```prolog
compatible(X, Y) :-
    equivalent_to(X, Y).
compatible(X, Y) :-
    alternative_to(X, Y),
    \+ contradicts(X, Y).
```

Because `equivalent_to` and `alternative_to` are symmetric, this rule automatically works in both directions. Query `compatible(A, B)` or `compatible(B, A)` — same result, no duplicate rules needed.

### Why This Is Potent

Each relation type in the enum is a filter. Each filter narrows the valid term space exponentially. Consider:

- A KB with 200 entities has 40,000 possible pairs.
- Adding `enables(X, Y)` narrows to maybe 80 pairs (the actual enables relations).
- Adding `requires(Y, Z)` narrows the third position to maybe 30 valid triples.
- Adding `\+ prevents(X, Z)` removes maybe 5 of those.
- Result: 25 valid triples out of 8,000,000 possible (200³).

That's a pruning ratio of 320,000:1. Achieved by three integer scans on the RelationIndex and a few boolean checks. Sub-microsecond. Zero tokens.

### Cross-Domain Constraint Composition

The VdrIds in the rule body can point anywhere in the tree:

```prolog
safe_material_for_structure(Material, Technique, Load) :-
    root.edu.chemistry::composed_of(Material, Elements),
    root.trades.blacksmithing::enables(Material, Technique),
    root.engineering.structural::requires(Load, Material),
    \+ root.edu.chemistry::degrades(Elements, Technique).
```

Four constraints across three domains. The chemistry KB validates material composition. The blacksmithing KB validates that the material supports the technique. The structural engineering KB validates load requirements. The chemistry KB again checks that the elemental composition doesn't degrade under the technique. Each constraint is a RelationIndex scan in its respective KB, resolved through VdrId tree walks.

The rule doesn't care that it spans three L1 subtrees. The VdrIds route through the tree mechanically. The GEMM scoping for this query would include chemistry, blacksmithing, and structural engineering — three subtrees out of 750 KBs. Everything else eliminated by bit comparison.

### The Inversion Property

Because RelationType has `inverse()`, every constraint rule implicitly generates its reverse query. The rule:

```prolog
what_does_X_enable(X, Y) :- enables(X, Y), \+ prevents(X, Y).
```

The inverse query "what depends on Y" rewrites to:

```prolog
what_depends_on_Y(Y, X) :- depends_on(X, Y), \+ prevents(X, Y).
```

Because `enables.inverse() = depends_on`. The engine rewrites automatically using the inverse method. One rule, two query directions. The symmetric types (`prevents`, `contradicts`, `equivalent_to`, `alternative_to`, `borders`, etc.) don't even need rewriting — they work in both directions as written.

### Rule Generation From Relation Algebra

The ~120 relation types with their transitivity, symmetry, and inverse properties define which compositions are meaningful. The rule generator can enumerate them mechanically:

1. For every transitive type T: generate closure rules.
2. For every pair (A, B) where A.inverse() != unknown: generate bidirectional chain rules.
3. For every symmetric type S combined with any type T: generate rules knowing S works both directions.
4. For every pair where one type has `prevents` or `contradicts` as a plausible negation: generate safe-combination rules with negation.
5. For compositions involving `part_of`/`contains`, `specializes`/`generalizes`: generate hierarchical traversal rules.

The relation algebra *is* the grammar for rule generation. The 120 types with their declared properties produce the rule set. The data in each KB determines which rules fire and what they produce. The rules are domain-independent. The results are domain-specific.

### Storage

~500 pattern rules × ~175 average per KB × 750 KBs = ~131,250 installed rules. Adding constraint variants (negation combinations, inverse-aware versions) might double that to ~260,000 rules.

260,000 × 48 bytes = **~12.5 MB**.

Still negligible against the system total. And each rule that fires successfully converts a multi-hop chain-discovery into a single rule match. Every rule is a pre-compiled reasoning path that moves a query from "discover the answer" to "look up the answer." The more rules, the higher the L3 percentage, the fewer tokens through the forward pass, the faster the system runs.

---

### Two-Tier Rule Architecture

**Root rules** — live in the `root` KB. These are relation-pattern rules that apply across 30%+ of all KBs. Always scanned regardless of which domain the query targets. Small set, universally applicable.

**KB-local rules** — live in each individual KB. These are rules with specific VdrId bindings reflecting how that KB's data actually connects to itself and to entities in other KBs. Only scanned when the KB is in the query's surviving subtrees.

### Root Rules: The Common Patterns

These are pure relation-type patterns with no VdrId bindings. They work everywhere because they express structural reasoning that any domain can use:

```prolog
% If X enables Y and Y requires Z, X transitively supports Z
supports(X, Z) :- enables(X, Y), requires(Y, Z).

% If X specializes Y, everything Y enables, X also enables
inherits_capability(X, Z) :- specializes(X, Y), enables(Y, Z).

% If X part_of Y and Y part_of Z, X part_of Z (transitive closure)
nested_in(X, Z) :- part_of(X, Y), part_of(Y, Z).

% Safe combination: X enables Y with no contradiction
compatible(X, Y) :- enables(X, Y), \+ contradicts(X, Y), \+ prevents(X, Y).

% Dependency with no circular block
clean_dependency(X, Y) :- depends_on(X, Y), \+ depends_on(Y, X).

% Causal explanation: X causes Y which explains Z
causal_explanation(X, Z) :- causes(X, Y), explains(Y, Z).

% Compositional breakdown
full_decomposition(X, Z) :- composed_of(X, Y), composed_of(Y, Z).

% Hierarchical inheritance
ancestor(X, Z) :- generalizes(X, Y), generalizes(Y, Z).
```

The threshold for root placement: if the rule's required relation types appear in 30%+ of KBs (225+ out of 750), it goes in root. The `CompactionProfile.relation_types_used` array across all KBs gives you the frequency count per relation type. Pairs like (`enables`, `requires`), (`specializes`, `enables`), (`part_of`, `contains`), (`depends_on`, `enables`) will appear in the vast majority of KBs because they're fundamental structural relations.

Estimated root rule count: maybe 80-150 rules. These are the reasoning primitives — the compositions so common that every domain uses them.

### KB-Local Rules: The Specific Connections

These have concrete VdrId bindings. They express how *this* KB's entities connect to each other and to entities elsewhere in the tree:

In `root.edu.physics`:

```prolog
% Specific: Noether's theorem enables conservation of energy
noether_energy(C17_id, L5_id) :- enables(C17_id, L5_id).

% Specific: Rayleigh-Jeans contradicting Planck caused quantum mechanics
classical_failure_to_qm(L63_id, TR14_id) :- 
    contradicts(L63_id, L37_id), 
    causes(L63_id, TR14_id).

% Cross-domain: phase transition chemistry enables blacksmithing technique
phase_enables_technique(Chem_entity, BS_entity) :-
    root.edu.chemistry::determines(Chem_entity, Phase),
    enables(Phase, BS_entity).
```

These rules carry VdrIds pointing to actual entities. They're not patterns — they're pre-computed connections specific to the data. The physics KB has 193 relations. The local rules capture every meaningful 2-hop and 3-hop chain across those 193 relations plus cross-domain connections to chemistry, engineering, astronomy, etc.

### The Scan Order

Query arrives, subtree scoping picks surviving KBs. Rule evaluation:

1. **Root rules first.** Always. Every query evaluates against the 80-150 root rules. These are the common reasoning patterns. Since root rules are pure relation-type patterns, they fire against whatever relations exist in the surviving KBs. Cost: 80-150 rule checks, each is a RelationIndex scan. Sub-microsecond total.

2. **KB-local rules second.** For each surviving KB (3-7 typical), evaluate its local rules. These have VdrId bindings — they're pre-computed paths through the specific data. A KB with 175 local rules gets 175 checks. Cost: maybe 500-1000 rule checks total across surviving KBs. Still sub-microsecond.

Total rule evaluation per query: ~1,100 checks in the worst case. Each check is a RelationIndex lookup — integer scan on contiguous arrays. This is what CPUs are built for.

### Why Root Rules Stay Small

The 30% threshold is the key. A rule that only applies to 10% of KBs doesn't belong in root because 90% of queries pay the evaluation cost for nothing. A rule that applies to 80% of KBs absolutely belongs in root because almost every query benefits.

The common relation types cluster hard. Looking at the relation_mapping sections across the 59 existing compacts:

- `enables` / `depends_on` / `requires` — virtually every domain
- `part_of` / `contains` / `composed_of` — virtually every domain
- `specializes` / `generalizes` — most domains
- `precedes` / `follows` — history, sciences, programming, trades
- `causes` / `result_of` — sciences, history, engineering
- `contradicts` / `prevents` — sciences, philosophy, engineering

The 2-hop and 3-hop combinations of these common types form the root rule set. Domain-specific types like `activates`, `encoded_by`, `governs`, `subcategorizes` stay out of root — they're relevant to neuroscience, grammar, or specific domains. Rules involving those types live only in the KBs that use them.

### Memory

**Root rules:** ~120 rules × 48 bytes = ~5.7 KB. Negligible.

**KB-local rules:** 750 KBs × ~175 average local rules × 48 bytes = ~6.3 MB.

**Total: ~6.3 MB.** Same as before. The root rules don't add meaningful cost — they're a tiny subset extracted from what would otherwise be duplicated across hundreds of KBs. In fact, root rules *save* space because the 120 common patterns don't need to be replicated in each of the 750 KBs individually.

### The Generation Algorithm

```
Phase 1 — Root rule generation:
    For each 2-hop and 3-hop relation-type pattern:
        Count how many KBs have all required relation types
        If count >= 0.30 × total_kbs:
            Assert rule in root.rules KB

Phase 2 — KB-local rule generation:
    For each KB:
        For each relation R in KB:
            Follow R.to_id to target entity
            Find all relations from target entity (same KB + cross-domain)
            For each 2-hop chain found:
                If not covered by a root rule:
                    Assert local rule with VdrId bindings in this KB
            Extend to 3-hop similarly
```

Phase 1 runs once after all KBs are loaded. Phase 2 runs per KB. Both are idempotent — re-running after adding new KBs generates rules for new connections and skips existing ones.

The "not covered by a root rule" check in phase 2 prevents duplication. If `supports(X, Z) :- enables(X, Y), requires(Y, Z)` is already in root, the local KB doesn't need a copy with bound VdrIds for every specific (X, Y, Z) triple — the root rule fires against the RelationIndex and finds them. Local rules only cover patterns that root rules don't — domain-specific relation types, negation constraints specific to this domain, 3-hop chains involving uncommon relation type combinations.

