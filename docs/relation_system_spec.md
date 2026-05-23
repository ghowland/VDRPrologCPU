## VdrId-to-VdrId Relation System — Complete Report

### The Fundamental Unit

A TypedRelation is a triple: two VdrIds and a RelationType.

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

Both ends are VdrIds. Not fact-to-fact. VdrId-to-VdrId. The `from_id` and `to_id` can point to any entry type — a KBData entry, a Fact, a Rule, a Grammar, a KB itself, a TypedRelation, an IoSe declaration. The entry type is encoded in the VdrId's bits. The relation doesn't care what it's connecting. It connects addresses.

### What RelationType Carries

The RelationType enum has ~120 types organized into 7 categories: structural (~80), identity/binding (~12), knowledge structure (~15), agency/action (10), condition/logic (10), grammar (10), toolchain (5), plus domain-registerable slots starting at 1,000,000.

Each type declares three algebraic properties via methods on the enum:

**inverse()** — what relation type you get when you reverse the direction. `enables.inverse() = depends_on`. `specializes.inverse() = generalizes`. `part_of.inverse() = contains`. Symmetric types are their own inverse: `prevents.inverse() = prevents`. Types without a clean inverse return `.unknown`, meaning reversal is handled by query direction, not a distinct relation type.

**isSymmetric()** — whether the relation holds in both directions automatically. `contradicts`, `equivalent_to`, `approximates`, `borders`, `alternative_to`, `connects_to`, `contrasts`, `complements`, `parallel_to`, `opposes`, `aliases`, `agrees_with`, `and_also`, `or_else`, `complement_of`. 16 symmetric types. If `contradicts(A, B)` exists, `contradicts(B, A)` is automatically true without storing a second relation.

**isTransitive()** — whether the relation chains. `enables`, `requires`, `extends`, `specializes`, `generalizes`, `part_of`, `contains`, `follows`, `precedes`, `depends_on`, `scoped_to`, `flows_to`, `derived_from`, `transforms_to`, `composed_of`. 15 transitive types. If `part_of(A, B)` and `part_of(B, C)`, then `part_of(A, C)` is mechanically derivable via BFS without storing the transitive closure explicitly.

### Resolution: Both Ends Are Full Addresses

When the Prolog engine evaluates a relation, both `from_id` and `to_id` resolve through the standard tree walk. Extract structural bits → scope selects root or session_root → L1 through L5 array dereferences → host KB → entry type dispatch → item_id indexes into typed array.

The `from_id` might be a KBData entry in `root.edu.physics` (entry_type = .data, pointing to the speed of light row). The `to_id` might be a Rule in `root.programming.zig` (entry_type = .rule, pointing to a compiler optimization rule). The relation `enables(physics_constant, compiler_rule)` connects two entirely different entity types in two entirely different domains. The VdrIds handle the routing. The tree walk doesn't care about type or domain — it follows the bits.

### The RelationIndex

Each KB that stores relations has a RelationIndex:

```zig
pub const RelationIndex = struct {
    by_type_counts: [128]i32,
    // by_from, by_to offsets for indexed lookup
    total_relations: i32,
    last_rebuilt: i32,
};
```

The `by_type_counts` array tells you how many relations of each type exist in this KB before you scan anything. `by_type_counts[1000]` (the `enables` slot) might be 47 — this KB has 47 enables relations. If the query asks for `prevents` and `by_type_counts[1002]` is 0, skip the KB entirely. One array read.

### Query Mechanics

**Direct lookup:** "What does entity X enable?"

```
1. Extract X's VdrId structural bits
2. Identify host KB via tree walk
3. Check host KB's RelationIndex: by_type_counts[enables] > 0?
4. If yes, scan relations where rel_type = .enables and from_id = X
5. Each match yields a to_id — resolve that VdrId to get the target entity
```

Sub-microsecond. Integer comparison on contiguous arrays.

**Inverse lookup:** "What depends on entity X?"

```
1. depends_on.inverse() = enables
2. Rewrite query to: scan for rel_type = .enables where to_id = X
3. Each match yields a from_id — these are the things that depend on X
```

Same cost. The inverse method on RelationType tells the engine which relation type to scan and which direction to match. No separate inverse index needed.

**Transitive closure:** "What does X transitively depend on?"

```
1. depends_on is transitive
2. BFS: find all Y where depends_on(X, Y)
3. For each Y, find all Z where depends_on(Y, Z)
4. Continue until no new entities found
5. Return complete closure
```

BFS over contiguous arrays. Each hop is a RelationIndex scan. For a chain 5 deep with branching factor 3, that's ~15 relation lookups. Still sub-microsecond.

**Symmetric query:** "Does X contradict Y?"

```
1. contradicts.isSymmetric() = true
2. Scan for contradicts(X, Y) OR contradicts(Y, X)
3. Either direction is sufficient — only one needs to be stored
```

### Cross-Entry-Type Relations

Relations aren't limited to connecting data entries. Every addressable entity has a VdrId. This means:

**KB to KB:**
```
contains(root.edu, root.edu.physics)
    from_id: VdrId with entry_type=.kb, L1=edu_index
    to_id: VdrId with entry_type=.kb, L1=edu_index, L2=physics_index
```
The tree structure itself can be expressed as relations. A KB containing a child KB is a `contains` relation between two VdrIds with entry_type = .kb.

**KBData to KBData:**
```
enables(speed_of_light, lorentz_invariance)
    from_id: VdrId with entry_type=.data, physics KB, item_id=K1
    to_id: VdrId with entry_type=.data, physics KB, item_id=C18
```
The physics constant K1 enables the concept C18. Both are KBData entries in the same KB. The relation connects their VdrIds.

**Rule to Fact:**
```
derived_from(fact_42, rule_7)
    from_id: VdrId with entry_type=.fact, item_id=42
    to_id: VdrId with entry_type=.rule, item_id=7
```
A derived fact traces back to the rule that produced it. The provenance chain uses exactly this pattern — `derivation_rule_id` is a VdrId pointing to a rule.

**Fact to Grammar:**
```
generates(grammar_template, output_pattern)
    from_id: VdrId with entry_type=.grammar
    to_id: VdrId with entry_type=.data
```
A grammar template generates an output pattern. The bidirectional pattern system (PT1-PT5) connects grammars to their outputs via relations.

**Relation to Relation:**
```
contradicts(relation_A, relation_B)
    from_id: VdrId with entry_type=.relation, item_id=A
    to_id: VdrId with entry_type=.relation, item_id=B
```
Meta-relations. Two relations contradict each other. The system can express "the claim that X enables Y contradicts the claim that X prevents Y" as a relation between two relations. Both ends are VdrIds with entry_type = .relation.

**IoSe to Rule:**
```
implements(prolog_rule, iose_spec)
    from_id: VdrId with entry_type=.rule
    to_id: VdrId with entry_type=.iose
```
A Prolog rule implements an input/output/side-effects specification. The relation connects the rule's address to the IoSe declaration's address.

### Cross-Domain Mechanics

The VdrId encodes the host KB's tree path. A relation between entities in different KBs is just two VdrIds with different level bits:

```
enables(
    VdrId{scope=0, entry_type=.data, L1=edu, L2=chemistry, item_id=47},
    VdrId{scope=0, entry_type=.data, L1=trades, L2=blacksmithing, item_id=12}
)
```

Chemistry entity 47 enables blacksmithing entity 12. The relation lives in one KB (whichever it was asserted in). The VdrIds route through the tree to resolve both ends. The Prolog engine follows both addresses mechanically — tree walk to chemistry's host KB for the from entity, tree walk to blacksmithing's host KB for the to entity.

GEMM scoping sees both L1 values (edu and trades) in the query's VdrIds and includes both subtrees. Everything else eliminated.

### Prolog Constraint Rules Over Relations

Relations act as structural constraints on valid term combinations:

**Single constraint — direct filter:**

```prolog
valid(X, Y) :- enables(X, Y).
```

Out of all possible (X, Y) pairs in a KB with 200 entities (40,000 pairs), only those connected by `enables` pass. If the KB has 80 enables relations, the valid space is 80 pairs. Pruning ratio: 500:1.

**Conjunction — multiplicative pruning:**

```prolog
valid(X, Y, Z) :- 
    enables(X, Y), 
    requires(Y, Z),
    \+ prevents(X, Z).
```

Three constraints. 200³ = 8,000,000 possible triples. The enables scan yields ~80 (X, Y) pairs. For each Y, the requires scan might yield ~3 Z values. The prevents negation check eliminates a few. Result: maybe 200 valid triples. Pruning ratio: 40,000:1.

**Transitive constraint — chain filter:**

```prolog
full_chain(X, Z) :-
    depends_on(X, Y),
    depends_on(Y, Z),
    \+ contradicts(X, Z).
```

Because `depends_on` is transitive, the BFS expands the candidate set across the full dependency graph. But `contradicts` at the end gates the result — even if X transitively depends on Z, if they contradict, the chain is invalid. The transitive property expands, the negation prunes.

**Cross-type constraint — mixing entity types:**

```prolog
valid_derivation(Data, Rule, Output) :-
    derived_from(Output, Rule),
    enables(Data, Output),
    instance_of(Output, Data).
```

Data is a KBData entry (entry_type = .data). Rule is a Rule (entry_type = .rule). Output is a Fact (entry_type = .fact). Three different entry types, three constraints, all connected by VdrId-to-VdrId relations. The relation system doesn't see types — it sees addresses. The constraints narrow the valid (Data, Rule, Output) triples to those actually connected in the graph.

### Two-Tier Rule Placement

**Root rules** live in `root` (KB id = 1). These are relation-pattern rules with no VdrId bindings that apply across 30%+ of all KBs. Always scanned on every query. ~120 rules covering the common compositions of universal relation types (enables + requires, specializes + enables, part_of + part_of, etc.). Pure patterns over relation types.

**KB-local rules** live in each individual KB. These have concrete VdrId bindings reflecting the actual connections in that KB's data. Only scanned when the KB is in the query's surviving subtrees. ~175 rules per KB average.

Scan order: root first (always, ~120 rules), then surviving KB-local rules (3-7 KBs × ~175 rules = ~500-1,200 rules). Total rule evaluation per query: ~600-1,300 checks. Each check is a RelationIndex lookup. Sub-microsecond total.

### Examples Across Domains

**Physics — theoretical dependency chain:**

```
specializes(Newton_gravity_L4, Einstein_field_L28)
    L4's VdrId → L28's VdrId
derived_from(Schwarzschild_L29, Einstein_field_L28)
    L29's VdrId → L28's VdrId
explains(Schwarzschild_L29, black_holes_C37)
    L29's VdrId → C37's VdrId
```

Query: "Trace the theoretical path from Newton's gravity to black holes." The engine follows: L4 specializes L28, L29 derived_from L28, L29 explains C37. Three relation lookups, three tree walks, three KBData entries returned with full text columns and Q16 values. Zero tokens.

**Programming — type hierarchy:**

```
implements(ArrayList, List_interface)
    ArrayList's VdrId (entry_type=.data, in root.programming.zig)
    → List_interface's VdrId (entry_type=.data, in root.programming.data_structures)
extends(ArrayList, DynamicArray)
    ArrayList's VdrId → DynamicArray's VdrId
requires(ArrayList, Allocator)
    ArrayList's VdrId → Allocator's VdrId
```

Query: "What does ArrayList need?" Follow all outgoing relations from ArrayList's VdrId. It implements List_interface, extends DynamicArray, requires Allocator. Each target VdrId resolves to a KBData entry with the full description. Cross-domain: ArrayList is in the Zig KB, List_interface is in data_structures, the relation connects them.

**Cooking → Chemistry → Physics:**

```
requires(maillard_reaction, temperature_threshold)
    maillard's VdrId (root.trades.cooking)
    → temperature's VdrId (root.edu.chemistry)
enables(kinetic_energy, temperature_threshold)
    kinetic's VdrId (root.edu.physics)
    → temperature's VdrId (root.edu.chemistry)
```

Query: "Why does meat brown?" Start from maillard_reaction. Follow `requires` → temperature_threshold in chemistry. Follow inverse: what enables temperature_threshold? → kinetic_energy in physics. Three KBs, two relations, the full causal chain from molecular kinetics through thermal chemistry to cooking technique. Each hop is a VdrId tree walk + RelationIndex scan.

**Literature → History → Military:**

```
instance_of(siege_of_minas_tirith, siege_warfare)
    fiction entity VdrId (root.literature.fantasy)
    → tactic VdrId (root.edu.history.military_tactics)
specializes(siege_warfare, attrition_strategy)
    tactic VdrId → strategy VdrId (same KB)
enables(attrition_strategy, supply_line_disruption)
    strategy VdrId → logistics VdrId
```

Query: "What real military tactic does the siege of Minas Tirith represent?" Follow `instance_of` from the fantasy KB entity to the military tactics KB entity. The relation connects fiction to its real-world basis. Then follow the tactic's own relations within the military KB to understand the broader strategic context. Cross-domain from literature to history, then within history.

**Grammar — self-referential:**

```
governs(subject_verb_agreement, verb_conjugation)
    rule VdrId (root.language.english_grammar, entry_type=.grammar)
    → rule VdrId (same KB, entry_type=.grammar)
applies_to(subject_verb_agreement, present_tense_verbs)
    rule VdrId → category VdrId (entry_type=.data)
violates(double_negative, standard_negation)
    anti-pattern VdrId → rule VdrId
```

Grammar rules relating to other grammar rules. A grammar governing verb conjugation, applying to a verb category, with an anti-pattern that violates it. All VdrIds, all within the English grammar KB. The relation system expresses linguistic structure the same way it expresses physics or cooking — addresses connected by typed edges.

### What the Relation Algebra Produces

The ~120 relation types with their inverse, symmetry, and transitivity properties create a reasoning substrate that is:

**Self-extending** — Prolog walks chains, discovers new paths, asserts rules for them. Idempotent. Run on a schedule. The relation graph grows rules mechanically.

**Domain-independent** — The same `enables + requires` composition works in physics, cooking, programming, and literature. The pattern is universal. The data is domain-specific.

**Pruning by construction** — Every relation constraint exponentially narrows the valid term space. Combining three constraints on a KB with 200 entities can reduce 8 million possible triples to 200 valid ones. The RelationIndex answers each constraint in nanoseconds.

**Cross-domain by default** — VdrIds encode tree position. A relation between chemistry and blacksmithing is no different mechanically from a relation within physics. The tree walk resolves both ends regardless of where they live. GEMM scoping includes the relevant subtrees automatically.

**Inspectable** — Every relation has provenance. You can trace why `enables(A, B)` exists — which compact file it came from, at what confidence, when it was asserted. Edit it, retract it, strengthen it, weaken it. The relation is a 48-byte struct at a known address.
