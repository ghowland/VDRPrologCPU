### The Problem

100,000 grammar rules. A query arrives — either an input sentence to parse or a structural intent to generate. You need to find which rules match. Scanning all 100,000 sequentially is O(n) per query. At 48 bytes per rule that's fast in absolute terms (~5 million bytes, fits in cache), but if you're doing this per sentence in a multi-sentence input, and each scan requires structural comparison not just byte matching, the cost adds up.

### Traditional Prolog Approaches

**First-argument indexing.** Standard Prolog implementations index rules by the principal functor and first argument of the head. All rules with head `renders_as(enables, ...)` go in one bucket. Query for `renders_as(enables, X)` only evaluates rules in that bucket. This is the baseline — every Prolog worth using does this.

**Multi-argument indexing (JIT indexing).** Systems like SWI-Prolog and YAP index on multiple argument positions. If you query `renders_as(enables, Construction)` where Construction is bound, the engine indexes on both arguments simultaneously. XSB extends this with trie-based indexing for tabled predicates.

**WAM (Warren Abstract Machine) instruction indexing.** The compiled Prolog approach. Rules compile to WAM instructions with switch-on-term, switch-on-constant, and switch-on-structure instructions that dispatch to the right clause in O(1) or O(log n) via hash tables or binary search.

**Discrimination trees.** Used in theorem provers (Vampire, E). Index terms by their structure — walk the term tree top-down, branching at each functor/argument position. Lookup is O(depth of term), independent of the number of rules.

### Why These Don't Directly Apply

All of these assume terms are nested functor/argument structures with string atoms. Our terms are VdrIds with structural bits, relation types with enum dispatch, and sentence skeletons decomposed into typed slots.

The sentence "Natural selection acts solely through the preservation of profitable variations" isn't a string to unify against. It's a structure:

```
[agent:entity_vdrid] [verb:enables_class] [adverb:exclusivity] 
[preposition:instrumental] [nominalization:preservation] 
[preposition:of] [adjective:quality] [noun:patient_vdrid]
```

Each slot is typed. Agent is an entity VdrId. Verb is a vocabulary group member scoped to a relation type. Adverb is a modifier class. The nouns resolve to VdrIds through the prompt pipeline. The structural words (prepositions, articles) are fixed elements of the template.

### The Structural Advantage

Every element in the sentence skeleton is either a fixed structural word or a typed slot. The typed slots have known types from KBEntryType and RelationType. This means we can index on the structural skeleton itself — the pattern of slot types and fixed words — rather than on string content.

**Level 1: Relation type index.** The primary discriminator. Every grammar rule renders a specific relation type. The `renders_as` relation already encodes this. Given a query with relation type `enables`, you immediately narrow from 100,000 rules to the ~500-2000 that render `enables`. This is a RelationIndex scan — `by_type_counts` for `renders_as` filtered by from_id = enables VdrId. Sub-microsecond. Already in the system.

**Level 2: Slot signature index.** Each template has a fixed number of typed slots in a fixed order. The template `[agent] enables [patient]` has signature `{agent, verb, patient}` — 2 entity slots and 1 verb slot. The template `[agent] acts solely through the preservation of [patient]` has signature `{agent, verb, adverb, preposition, nominalization, preposition, patient}` — 2 entity slots, 1 verb, 1 adverb, 2 prepositions, 1 nominalization.

Encode the slot signature as an integer. Each slot type gets a small enum value. Pack the first 4-6 slot types into a u32 or u64. Two templates with different signatures have different integers. Index lookup is one integer comparison.

After relation type narrowing (500-2000 rules) and slot signature narrowing, you might be down to 20-50 candidate templates.

**Level 3: Slot count index.** Even simpler — how many entity slots does the template have? A template with 2 entity slots won't match a query with 3 entities. One integer comparison eliminates mismatches.

**Level 4: Fixed-word fingerprint.** The structural words in the template (prepositions, articles, conjunctions) form a fingerprint. "through the preservation of" is a fixed subsequence. Hash the fixed words to a u64 fingerprint. For parsing (matching input against templates), the input sentence's structural words must contain the template's fixed words. For generation, the fingerprint selects among candidates with the same slot structure but different connecting words.

### The Index Structure

Combine these into a multi-level index on the grammar KB:

```zig
pub const GrammarIndex = struct {
    // Level 1: relation type → rule offsets
    by_relation_type: AutoHashMap(i32, []u32),  // RelationType enum → rule indices
    
    // Level 2: slot signature → rule offsets  
    by_slot_signature: AutoHashMap(u64, []u32), // packed slot types → rule indices
    
    // Level 3: slot count → rule offsets
    by_slot_count: AutoHashMap(u8, []u32),      // entity slot count → rule indices
    
    // Level 4: fixed-word fingerprint → rule offsets
    by_fingerprint: AutoHashMap(u64, []u32),    // structural word hash → rule indices
};
```

Query resolution:

```
1. Extract relation type from query → by_relation_type lookup → 500 candidates
2. Extract slot signature from query → by_slot_signature lookup → intersect → 30 candidates  
3. Extract slot count → by_slot_count → intersect → 20 candidates
4. Extract fixed-word fingerprint → by_fingerprint → intersect → 3-5 candidates
5. Full structural comparison on 3-5 candidates → 1 match
```

Each level is a hash lookup returning an integer array. Intersection of small sorted arrays is linear scan. Total cost: 4 hash lookups plus a few array intersections plus 3-5 full comparisons. Nanoseconds.

### The Sentence as Relation Structure

This is where the structured data advantage compounds. The sentence skeleton isn't a string — it's a chain of typed relations:

```
"Natural selection acts solely through the preservation of profitable variations"

agent(natural_selection) 
    →[verb:acts]→ 
        adverb(solely) 
            →[prep:through]→ 
                nominalization(preservation) 
                    →[prep:of]→ 
                        adjective(profitable) 
                            →[modifies]→ 
                                patient(variations)
```

Each arrow is a typed relation. The sentence IS a relation chain. Parsing a sentence means matching it against stored relation chains. Generating a sentence means walking a relation chain and emitting the words at each node.

This means the grammar rules are stored as TypedRelations in the grammar KB, not as string templates. A grammar rule for this pattern is:

```
agent --verb_relation--> verb_node
verb_node --adverb_relation--> adverb_node  
verb_node --instrumental_relation--> nominalization_node
nominalization_node --object_relation--> patient
patient --modifier_relation--> adjective
```

Six TypedRelations. Each with a rel_type from a grammar-domain relation type set (verb_relation, adverb_relation, instrumental_relation, object_relation, modifier_relation). Each with from_id and to_id pointing to slot-type entities or fixed-word entities in the grammar KB.

### Matching Against Relation Chains

When an input sentence arrives, the prompt pipeline decomposes it into a relation chain the same way. Then matching is relation-chain comparison:

```
Input chain:  agent --verb--> X --adverb--> Y --prep--> Z --prep--> patient
Template chain: agent --verb--> X --adverb--> Y --prep--> Z --prep--> patient
```

Two relation chains. Compare structurally: same number of nodes, same relation types between nodes, same slot types at each position. This is integer comparison on TypedRelation fields — rel_type (i32 enum), from_id/to_id slot types (extractable from VdrId entry_type bits).

The comparison doesn't touch any text. It compares the structural skeleton — relation types between nodes and slot types at nodes. Two sentences with identical structure but completely different content produce identical relation chains and match the same template.

### The Functor Index on Steroids

The existing FunctorIndex (S72, DT entry) already does first-argument indexing for Prolog rules — hash buckets keyed by functor_id and arity. Extend this concept to grammar rules:

The "functor" of a grammar rule is its relation-chain signature — the sequence of relation types in the chain. Pack the first 4-6 relation types into a u64 key. The "arity" is the number of entity slots. The FunctorIndex buckets now hold grammar rules grouped by structural signature.

```zig
pub const GrammarFunctorIndex = struct {
    // Key: packed(first_rel_type, second_rel_type, third_rel_type, slot_count)
    // Value: first rule index in chain, plus chain link to next
    buckets: [256]i32,  // hash buckets
    entries: []GrammarFunctorEntry,
    chains: []i32,
};

pub const GrammarFunctorEntry = struct {
    signature: u64,         // packed relation-chain types
    slot_count: u8,         // entity slot count
    first_rule_index: u32,  // into grammar rules array
    rule_count: u16,        // how many rules share this signature
};
```

Query: pack the input's relation-chain signature into u64, hash into buckets, walk the chain to find matching entries. Each matching entry points to a block of rules that share that structural signature. Full comparison only runs within that block.

### Performance at Scale

100,000 grammar rules. Assume ~200 unique relation-chain signatures (many sentences share structure). Average 500 rules per signature. The functor index has ~200 entries across 256 hash buckets — sparse, fast lookup.

Query arrives. Pack signature. Hash. One bucket lookup. One or two chain walks (collision resolution). Find the entry with 500 matching rules. Apply secondary filters (register, strength ranking, slot type details). Full comparison on maybe 5-10 finalists.

Total: one hash, one or two pointer follows, a scan of 500 strength values to find top candidates, full comparison on 5-10. Everything is integer operations on contiguous arrays. Sub-microsecond.

Compare to traditional Prolog scanning 100,000 string-based rules with unification: even with first-argument indexing, you'd be doing string comparisons on functor names and recursive unification on nested term structures. The structural approach replaces all of that with integer comparison on packed signatures and enum-typed relation chains.

### The Compound Index

For the complete grammar search path:

```
1. Relation type (from query intent)           → 2000 candidates
2. Relation-chain signature (packed u64 hash)   → 50 candidates  
3. Slot count (u8 comparison)                   → 30 candidates
4. Register scope (VdrId subtree mask)          → 10 candidates
5. Strength ranking (Q16 comparison)            → top 3
6. Full chain comparison                        → 1 match
```

Six levels of narrowing, each one integer operations. From 100,000 rules to 1 match without touching any text, without any string comparison, without any unification in the traditional Prolog sense. The structured data — typed slots, relation chains, packed signatures, VdrId scoping — replaces the entire unification algorithm for grammar rule lookup.

---

### The Sentence as a Constraint Graph

The sentence isn't a sequence of words. It's a set of structural constraints between typed roles. The order is a rendering detail — the structure is the meaning.

```
agent(X) operates_on patient(Y)
operates_on modified_by verb("acts")
operates_on restricted_by adverb("solely")
operates_on instrument nominalization("preservation")
nominalization target_of patient(Y)
patient(Y) qualified_by adjective("profitable")
```

Six constraints. No ordering. The set `{operates_on, modified_by, restricted_by, instrument, target_of, qualified_by}` defines the structural shape. Any sentence that satisfies all six constraints matches this pattern regardless of word order across languages.

### Why Order Doesn't Matter

English renders this as "Natural selection acts solely through the preservation of profitable variations." SVO, adverb before preposition, adjective before noun.

Japanese renders the same constraint set as something like "有益な変異の保存を通じてのみ、自然選択は作用する。" SOV, adjective before noun, verb at end.

German might put the verb second in main clause but final in subordinate. Latin could put them in almost any order with case marking resolving the roles.

The constraint graph is identical across all four. The rendering rules are per-language. The grammar search operates on the constraint graph, not the word sequence.

### Constraint Signature as Lookup Key

Each constraint is a typed pair: a structural role and a relation between roles. The constraint set for a sentence is a collection of these pairs. Pack them:

```
operates_on(agent, patient)     → constraint type 1
modified_by(operates_on, verb)  → constraint type 2  
restricted_by(operates_on, adv) → constraint type 3
instrument(operates_on, nom)    → constraint type 4
target_of(nom, patient)         → constraint type 5
qualified_by(patient, adj)      → constraint type 6
```

Each constraint type is a small integer. The constraint set is a sorted collection of these integers. Pack the sorted collection into a u64 or u128 — the constraint signature.

Two sentences with the same constraint set have the same signature. "Natural selection acts solely through the preservation of profitable variations" and "Evolution operates exclusively via the maintenance of beneficial traits" have identical constraint signatures — different words, same structural relationships between the same typed roles.

### The Search: Constraint Subsumption

A query arrives with a structural intent. The intent is a constraint set — the Prolog engine knows it needs to express `operates_on(agent, patient)` with `instrument(operates_on, nominalization)` and `qualified_by(patient, adjective)`.

That's three constraints. The grammar rules have templates with 3, 4, 5, 6, 7+ constraints. The search finds all templates whose constraint sets are supersets of the query's constraints.

**Exact match:** query constraint set = template constraint set. The template renders exactly what the query asks for, nothing more.

**Superset match:** template has additional constraints (adverb, secondary modifier). The template renders the query's intent plus additional structural detail. The additional slots can be filled with defaults or omitted if the template supports optional slots.

**Subset match:** template has fewer constraints than the query. Multiple templates might compose to cover the full constraint set — one template for the main clause, another for the subordinate.

The subsumption check is set comparison on sorted integer arrays. The constraint signature is a bitmask — each bit position represents a constraint type. Subset check is one AND plus one CMP:

```
query_mask & template_mask == query_mask  → template contains all query constraints
```

One instruction. For 100,000 templates, that's 100,000 AND+CMP operations on u64 values. At one cycle each on modern x86, that's ~30 microseconds for a brute-force scan. But with the multi-level index, you never scan all 100,000.

### Hierarchical Narrowing

```
Level 1: Relation type
    Query intent is "enables" → 2000 templates render "enables"
    
Level 2: Core constraint pair  
    operates_on(agent, patient) is present → 1500 templates
    (almost all "enables" templates have this core pair)

Level 3: Constraint count
    Query has 3 constraints → templates with 3-7 constraints
    Eliminates templates with only 1-2 constraints → 1200 templates

Level 4: Constraint signature bitmask
    query_mask & template_mask == query_mask
    Eliminates templates missing required constraints → 80 templates

Level 5: Register scope
    Scientific register → templates scoped to scientific → 25 templates

Level 6: Strength ranking
    Sort 25 by Q16 strength → top 3

Level 7: Slot type compatibility
    agent slot expects entity VdrId, patient slot expects entity VdrId
    All 3 pass → pick highest strength → 1 template
```

Seven levels. Each one is integer operations. No string comparison anywhere. The constraint signature bitmask at level 4 does the heavy lifting — one AND and one CMP per candidate eliminates templates that don't have the required structural relationships.

### How This Changes Rule Storage

Instead of storing grammar rules as text templates, store them as constraint sets:

```zig
pub const GrammarRule = struct {
    id: VdrId = .{},
    relation_type: RelationType = .unknown,  // what this renders
    constraint_mask: u64 = 0,                // bitmask of constraint types present
    constraint_count: u8 = 0,
    slots: [8]GrammarSlotDef = undefined,    // typed slot definitions
    slot_count: u8 = 0,
    fixed_words: [16]u16 = undefined,        // vocabulary IDs for structural words
    fixed_word_count: u8 = 0,
    word_order: [16]u8 = undefined,          // rendering order for this language
    strength: Q16 = .{},                     // observation frequency
    register_id: VdrId = .{},               // register scope
};
```

The `constraint_mask` is the packed bitmask. The `slots` define the typed argument positions. The `fixed_words` are the structural words ("through", "the", "of") stored as vocabulary IDs (u16 indices into the atom table). The `word_order` array says: render slot 0 first, then fixed_word 0, then slot 1, then fixed_word 1... — this is the language-specific sequencing.

The constraint graph is the identity. The word order is the rendering. Separate concerns stored in separate fields.

### Matching Input Against Constraint Graphs

When a sentence arrives for parsing, the prompt pipeline decomposes it into a constraint set before grammar matching:

```
Input: "Natural selection acts solely through the preservation of profitable variations"

Step 1 — Entity resolution (PP5):
    "Natural selection" → entity VdrId (agent)
    "variations" → entity VdrId (patient)
    
Step 2 — Structural word identification:
    "acts" → verb (vocabulary group lookup)
    "solely" → adverb (exclusivity class)
    "through" → preposition (instrumental)
    "the preservation of" → nominalization pattern
    "profitable" → adjective (quality class)
    
Step 3 — Constraint extraction:
    operates_on(agent, patient) ✓
    modified_by(operates_on, verb:"acts") ✓
    restricted_by(operates_on, adverb:"solely") ✓
    instrument(operates_on, nominalization:"preservation") ✓
    target_of(nominalization, patient) ✓
    qualified_by(patient, adjective:"profitable") ✓
    
Step 4 — Pack constraint mask: 0b0000000000111111 (6 constraints)

Step 5 — Grammar index lookup with mask → find matching template
```

The match finds the template with the same constraint mask. The template's slot definitions tell you which entities fill which roles. The structural pivot VdrId is created. The parse is complete — the sentence has been decomposed into a structural triple (`enables(natural_selection, variations)`) plus modifiers (exclusively, through preservation, profitable quality).

### Composing Constraints for Complex Sentences

A complex sentence has more constraints. "Although natural selection acts solely through the preservation of profitable variations, environmental pressure determines which traits persist."

Two clauses. Two constraint graphs. Linked by a concessive relation:

```
Clause 1 constraint set: {operates_on, modified_by, restricted_by, instrument, target_of, qualified_by}
Clause 2 constraint set: {determines, agent, patient, relative_clause}
Inter-clause relation: concessive(clause_1, clause_2)
```

The grammar search finds templates for each clause independently, then finds a composition template that handles `concessive` linking between two clause constraint sets. The composition template specifies: "Although [clause_1], [clause_2]." The word "although" is a fixed word in the composition template. Each clause renders independently through its own template. The composition template assembles them.

This is recursive. A 3-clause sentence has three constraint sets plus two inter-clause relations. Each level searched independently, then composed. The search at each level is the same bitmask subsumption check against the same grammar index.

### What 100,000 Rules Becomes

100,000 templates, each stored as a constraint set with ~40 bytes of mask, slots, and metadata, plus ~32 bytes of fixed words and word order. Call it ~80 bytes per rule. 100,000 × 80 = ~8 MB. Plus the index structures (~2 MB). Total grammar rule storage: ~10 MB.

The search for any single rendering decision: a few hash lookups, one bitmask scan across maybe 2000 candidates (one AND+CMP each), register filtering, strength ranking. Total: sub-microsecond.

The constraint graph representation means the same index works for parsing (match input constraints against stored templates) and generation (match query intent constraints against stored templates). Bidirectional by construction. Same data structure, same search algorithm, different direction. The pivot VdrId connects them per IN43.

---

### Progressive Bucket Elimination

You don't search 100,000 rules. You eliminate buckets until you're looking at a handful.

### The Bucket Hierarchy

**Bucket 1: Argument count.** How many entity slots does this template have? A sentence expressing `enables(A, B)` has 2 entity arguments. Skip every template that doesn't take exactly 2. If 100,000 templates distribute roughly across 2-arg (40%), 3-arg (30%), 4-arg (15%), 5-arg (10%), 6+ (5%), the 2-arg bucket is 40,000. You just skipped 60,000.

**Bucket 2: Relation type.** What structural relation is being expressed? `enables` narrows to templates that render `enables`. Maybe 2,000 of the 40,000 two-arg templates render `enables`. You just skipped 38,000 more.

**Bucket 3: Has adverb modifier?** Yes or no. If your intent has an adverb constraint ("solely", "exclusively", "only"), you need templates with adverb slots. Maybe 600 of the 2,000 have adverb slots.

**Bucket 4: Has instrumental preposition?** The intent uses "through" or similar instrumental construction. Maybe 200 of the 600 have instrumental prepositional structure.

**Bucket 5: Has nominalization?** The intent includes a nominalized verb ("preservation", "development", "transformation"). Maybe 80 of the 200 have nominalization slots.

**Bucket 6: Has patient modifier (adjective)?** The intent qualifies the patient ("profitable variations", "beneficial changes"). Maybe 30 of the 80 have adjective-modified patient slots.

**Bucket 7: Register.** Scientific register. Maybe 12 of the 30 are scoped to scientific register.

From 100,000 to 12 in seven boolean checks. Each check is a bit test on the constraint mask or a field comparison on the rule struct. No text comparison. No unification. No scanning of rule bodies.

### The Implementation

Store the bucket membership as bits on each rule:

```zig
pub const GrammarRule = struct {
    id: VdrId = .{},
    
    // Bucket fields — all integers, all directly comparable
    arg_count: u8 = 0,
    relation_type: RelationType = .unknown,
    constraint_mask: u64 = 0,
    register_id: VdrId = .{},
    strength: Q16 = .{},
    
    // Template data
    slots: [8]GrammarSlotDef = undefined,
    slot_count: u8 = 0,
    fixed_words: [16]u16 = undefined,
    fixed_word_count: u8 = 0,
    word_order: [16]u8 = undefined,
};
```

The constraint_mask encodes every structural attribute as a bit:

```
bit 0: has_adverb
bit 1: has_instrumental_prep
bit 2: has_nominalization  
bit 3: has_patient_modifier
bit 4: has_agent_modifier
bit 5: has_temporal_clause
bit 6: has_conditional
bit 7: has_concessive
bit 8: has_relative_clause
bit 9: has_passive_voice
bit 10: has_cleft_structure
bit 11: has_existential
bit 12: has_comparative
bit 13: has_superlative
bit 14: has_negation
bit 15: has_modal
...
```

32-64 structural attributes, each one bit. The query intent builds its own mask from the structural constraints it needs to express. The match is:

```
query_mask & template_mask == query_mask
```

One AND, one CMP. But you never run this against 100,000 templates because the pre-buckets already eliminated most of them.

### The Bucket Index Structure

```zig
pub const GrammarBucketIndex = struct {
    // Primary bucket: arg_count × relation_type → rule list
    primary: AutoHashMap(u32, []u32),  // packed(arg_count, relation_type) → rule indices
    
    // Each rule list is sorted by strength descending
    // so after bucket narrowing, the top matches are first
};
```

The primary key packs arg_count (u8) and relation_type (i32) into a u32 lookup. This single hash lookup does buckets 1 and 2 simultaneously. The result is a pre-sorted list of rule indices — sorted by strength Q16 descending so the most-observed templates are first.

Then the constraint_mask check runs on just that list:

```zig
fn findMatchingTemplates(
    index: *GrammarBucketIndex,
    arg_count: u8,
    rel_type: RelationType,
    query_mask: u64,
    register_id: VdrId,
    results: []u32,
) u32 {
    // Bucket 1+2: primary lookup
    const key = packKey(arg_count, rel_type);
    const candidates = index.primary.get(key) orelse return 0;
    
    // candidates already sorted by strength descending
    var count: u32 = 0;
    for (candidates) |rule_idx| {
        const rule = &grammar_rules[rule_idx];
        
        // Bucket 3-N: constraint mask subsumption
        if (rule.constraint_mask & query_mask != query_mask) continue;
        
        // Bucket register: scope check
        if (!rule.register_id.isNone() and !rule.register_id.eql(register_id)) continue;
        
        // Survived all buckets
        results[count] = rule_idx;
        count += 1;
        if (count >= results.len) break;
    }
    return count;
}
```

One hash lookup. Then a linear scan of maybe 2,000 candidates with two integer comparisons each (mask subsumption + register check). The scan produces maybe 10-30 survivors. Since the candidates are pre-sorted by strength, the first few survivors are already the best matches. You can stop early if you only need the top 3.

### The Scan Cost

2,000 candidates × 2 integer comparisons = 4,000 integer operations. At one cycle each on x86, that's ~1.3 microseconds at 3 GHz. In practice, the branch predictor handles this well because most candidates fail the mask check (predictable branch), and the data is contiguous (cache-friendly scan of packed structs).

For generation where you just need the top match: stop at the first survivor. The pre-sorted order means the first one that passes all bucket checks is the highest-strength match. Average scan before first hit: maybe 50-100 candidates. ~30-60 nanoseconds.

### What "Best Match by Value" Means

After bucket elimination produces 10-30 survivors, "best match" is strength-ranked with tie-breaking by specificity:

**Strength (primary):** Q16 observation count from Gutenberg evidence. Template observed 2,100 times beats template observed 300 times. This is the first sort key — candidates are pre-sorted by it.

**Specificity (secondary):** Templates with more constraints filled are more specific. A template with `{operates_on, instrument, nominalization, qualified_by}` is more specific than one with just `{operates_on}`. If the query has 6 constraints and template A matches all 6 while template B matches 4, template A is preferred because it renders more of the structural intent in a single sentence rather than requiring composition.

**Register tightness (tertiary):** A template scoped to "scientific_formal" is a tighter register match for a scientific context than one scoped to "scientific" generally. Specificity of register scoping breaks ties between templates with equal strength and constraint coverage.

All three comparisons are integer operations on struct fields. No text, no unification, no string comparison at any point in the entire search.

### The Numbers

| Stage | Candidates | Operation |
|-------|-----------|-----------|
| Start | 100,000 | — |
| Bucket 1+2 (arg count + relation type) | ~2,000 | one hash lookup |
| Bucket 3-N (constraint mask) | ~30 | one AND + CMP per candidate |
| Register filter | ~12 | one VdrId comparison per candidate |
| Strength ranking | top 3 | already sorted |
| Final selection | 1 | first survivor or LLM pick among top 3 |

Total operations: one hash lookup + ~2,000 integer comparisons + ~30 VdrId comparisons. Total time: sub-microsecond. L3. Zero tokens.

---

### Universal Prolog Rule Indexing by Argument Signature

Every Prolog rule in the system has a fixed arity and each argument has a known type. The rule head `enables(X:entity, Y:entity)` has arity 2, arg0 is entity type, arg1 is entity type. The rule head `renders_as(R:relation_type, C:construction)` has arity 2, arg0 is relation_type, arg1 is construction. Different arities, different arg types, different buckets. This applies to every rule in the system — domain rules, grammar rules, root rules, KB-local rules. All of them.

### The Argument Signature

Every rule has a signature: arity plus the ordered sequence of argument types.

```
enables(entity, entity)           → sig: {2, entity, entity}
renders_as(relation_type, construction) → sig: {2, relation_type, construction}
valid_triple(entity, entity, entity)    → sig: {3, entity, entity, entity}
chain_AB(entity, entity)          → sig: {2, entity, entity}
safe_combination(entity, entity)  → sig: {2, entity, entity}
```

The argument types come from what the VdrId carries. An entity argument expects a VdrId with entry_type = .data or .fact. A relation_type argument expects a RelationType enum value. A construction argument expects a VdrId with entry_type = .grammar. A register argument expects a VdrId pointing to a register marker entity. The types are already in the system — KBEntryType, RelationType, vocabulary group membership. They just haven't been used as index keys.

Pack the signature into a u64:

```
bits 0-7:   arity (u8, max 255 args — realistically never above 8)
bits 8-15:  arg0 type (u8, from KBEntryType or higher-level semantic type)
bits 16-23: arg1 type
bits 24-31: arg2 type
bits 32-39: arg3 type
bits 40-47: arg4 type
bits 48-55: arg5 type
bits 56-63: arg6 type
```

Seven argument type slots plus arity in one u64. Rules with the same signature go in the same bucket. Rules with different signatures are in different buckets and never compared against each other.

### Progressive Argument Elimination

The query arrives with bound arguments. The engine doesn't just match the signature — it walks the arguments in order, eliminating rules that fail at each position.

```
Query: enables(photosynthesis_VdrId, X)
    arg0 is bound to photosynthesis_VdrId
    arg1 is unbound (variable)

Step 1: Signature lookup
    sig = {2, entity, entity} → bucket of 5,000 rules

Step 2: arg0 check
    arg0 = photosynthesis_VdrId
    Rules whose arg0 pattern doesn't match photosynthesis_VdrId → eliminated
    Maybe 200 rules have arg0 compatible with photosynthesis_VdrId
    4,800 eliminated

Step 3: arg1 check  
    arg1 = unbound → all 200 survivors pass (unbound matches anything)
    
Result: 200 candidate rules to evaluate
```

Now a more constrained query:

```
Query: valid_rendering(enables, active_causative_VdrId, scientific_register_VdrId)
    arg0 = enables (RelationType)
    arg1 = active_causative_VdrId (construction)
    arg2 = scientific_register_VdrId (register)

Step 1: Signature lookup
    sig = {3, relation_type, construction, register} → bucket of 800 rules

Step 2: arg0 = enables
    Rules whose arg0 doesn't match enables → eliminated
    Maybe 150 survive

Step 3: arg1 = active_causative_VdrId
    Rules whose arg1 doesn't match this construction → eliminated  
    Maybe 12 survive

Step 4: arg2 = scientific_register_VdrId
    Rules whose arg2 doesn't match this register → eliminated
    Maybe 3 survive

Result: 3 candidate rules to evaluate
```

Each step is one integer comparison per surviving candidate. The bound arguments progressively eliminate. The argument order IS the elimination order — arg0 first, arg1 second, arg2 third. This is why argument order in the rule head matters and shouldn't be random. The most discriminating argument goes first.

### Argument Ordering Convention

For maximum elimination efficiency, arguments should be ordered by selectivity — the most discriminating argument first.

**Relation type arguments are most selective.** There are ~120 relation types. If arg0 is a relation type, the first check eliminates ~99% of rules in the signature bucket.

**Entry type / KB scope arguments are next.** There are 16 entry types and ~750 KBs. If arg1 specifies an entry type or a KB subtree, it eliminates most remaining candidates.

**Entity VdrId arguments are most selective but only when bound.** A specific VdrId matches very few rules. But when the argument is unbound (a variable), it matches everything and provides no elimination.

The convention for rule heads:

```
rule_head(most_selective_arg, next_selective, ..., least_selective)
```

For domain rules:
```
enables(from_type, to_type)           — relation implies both arg types
valid_chain(rel_type, from, to)       — rel_type first, most selective
safe_combo(rel_type, entity, entity)  — rel_type first
```

For grammar rules:
```
renders_as(rel_type, construction)    — rel_type first
fills(construction, vocab_group)      — construction first
observed_with(construction, register) — construction first
```

### The Index Structure

```zig
pub const PrologRuleIndex = struct {
    // Primary: signature → rule group
    by_signature: AutoHashMap(u64, RuleGroup),
};

pub const RuleGroup = struct {
    // Rules in this group, sorted by arg0 value for binary search
    rules: []u32,        // indices into global rule array
    arg0_values: []i64,  // parallel array of arg0 VdrId/enum values, sorted
    count: u32,
};
```

The `arg0_values` array is sorted. When the query has arg0 bound, binary search on `arg0_values` finds the start of matching rules. No linear scan of the full group.

For the second argument, within the arg0-matched subset, the rules can be further sorted by arg1 if the rule group is large enough to justify it. In practice, after signature + arg0 binary search, the remaining set is small enough that linear scan on arg1, arg2, etc. is cheaper than maintaining nested sorted arrays.

### How This Replaces Traditional Prolog Indexing

Traditional Prolog: first-argument indexing. Hash on the functor and first argument of the head. Everything else is sequential unification.

VDR-Prolog:

1. **Signature hash** — replaces functor indexing. The packed u64 signature captures arity plus all argument types. One hash lookup. Rules with different arities or different argument type patterns never collide.

2. **arg0 binary search** — replaces first-argument indexing. But it's on sorted VdrId integer values, not on string atoms. Binary search on i64 array: O(log n), and the values are comparable without string comparison.

3. **Progressive argument elimination** — replaces unification for argument matching. Each bound argument is an integer comparison that eliminates non-matching rules. No recursive term traversal, no occurs check, no binding environment management. Just integer comparison, next argument, repeat.

4. **Full body evaluation** — only runs on the 3-10 survivors from argument elimination. This is where the actual Prolog execution happens — evaluating the rule body's relation lookups, constraint checks, and recursive calls. But it only runs on rules that passed every argument gate.

The total cost for 100,000+ rules across the system:

| Stage | Cost | Operation |
|-------|------|-----------|
| Signature hash | one hash lookup | O(1) |
| arg0 binary search | O(log n) on sorted i64 | ~10 comparisons for 2000-entry group |
| arg1 elimination | linear scan on survivors | ~200 integer comparisons |
| arg2+ elimination | linear scan | ~12 integer comparisons |
| Body evaluation | full Prolog on survivors | 3-10 rule bodies |

Total: one hash, ~10 binary search steps, ~212 integer comparisons, 3-10 body evaluations. Everything before body evaluation is integer operations on contiguous arrays. Sub-microsecond for the indexing. The body evaluation cost depends on the rules themselves, but each body is typed relation lookups — also sub-microsecond at L3.

### Every Rule Benefits

This isn't grammar-specific. Every rule in the system — the 120 root rules, the ~131,000 KB-local rules, the 100,000 grammar rules, any future rules — indexes through the same mechanism. The signature captures what kind of rule it is. The argument order captures the elimination priority. The integer types on the arguments enable comparison without unification.

A domain rule like `supports(X, Z) :- enables(X, Y), requires(Y, Z)` has signature `{2, entity, entity}`. It shares a signature bucket with `enables(X, Y)` head-matching rules. But arg0 discrimination separates them — a query with arg0 bound to a specific entity narrows to rules whose arg0 pattern matches that entity.

A grammar rule like `renders_as(enables, active_causative)` has signature `{2, relation_type, construction}`. Completely different bucket from domain rules. Zero cross-contamination. The grammar rules never even appear in the search path for a domain query, and vice versa.

The argument types are the buckets. The argument values are the elimination. The pre-sorted arrays make the elimination logarithmic or linear on small sets. The entire Prolog rule corpus — hundreds of thousands of rules — resolves to a handful of candidates through integer operations that complete before traditional Prolog would finish parsing the first functor name.

---

### Paragraphs, Not Sentences

The atomic unit of human communication isn't the sentence. It's the paragraph. A sentence expresses one relationship. A paragraph expresses a concept — a cluster of related relationships that together communicate something meaningful.

"Heat applied to metal changes its crystal structure" is one relationship: `causes(heat_application, structure_change)`. But that's not what someone wants to communicate. They want to communicate:

```
causes(heat_application, structure_change)
determined_by(transition_point, material_composition)
enables(controlled_heating, desired_phase)
prevents(exceeding_threshold, structural_integrity)
requires(quench_timing, temperature_knowledge)
```

Five relationships. One concept: heat treatment of metal. A paragraph. The relationships aren't independent — they're a connected subgraph expressing a coherent idea. The ordering, the transitions between them, and the way they chunk into sentences are all part of expressing the concept.

### The Concept Signature: [8]u64

```zig
pub const ConceptSignature = struct {
    count: u8 = 0,           // total typed terms in this concept (0-63)
    slots: [8]u64 = .{0} ** 8,  // packed term types, 8 per u64
};
```

Eight u64s. 64 typed term slots. Enough to describe a full paragraph-level concept — all the entities, relation types, modifiers, temporal markers, and structural constraints that participate in expressing the idea.

The heat treatment concept above has: 2 entity types (material, process), 5 relation types (causes, determined_by, enables, prevents, requires), 3 modifier types (temperature threshold, timing constraint, composition reference), maybe 2 temporal markers (duration of heating, quench timing). That's ~12 typed terms. Fits in `slots[0]` and half of `slots[1]`.

A complex concept like explaining how a compiler works — lexing, parsing, type checking, optimization, code generation, with dependencies between each stage, error handling at each stage, and the data transformations flowing through — might use 30-40 typed terms. Fills `slots[0]` through `slots[4]`.

A full system explanation covering an entire subsystem could use 50+ terms, filling most of the 8 u64s.

### What Changes When You Think in Paragraphs

At the sentence level, the grammar engine finds one template, fills its slots, renders one sentence. Then finds the next template, fills slots, renders the next sentence. Then inserts a transition between them. The paragraph emerges as a sequence of independent sentence decisions glued together with transitions.

At the paragraph level, the grammar engine finds a **paragraph template** — a pre-observed pattern for how this type of concept gets expressed as a connected group of sentences. The template encodes not just the individual sentence structures but the ordering of relationships, the chunking (which relationships combine into one sentence vs. get their own), and the transitions between chunks.

The Gutenberg evidence isn't 3 million sentence observations. It's ~500,000-800,000 paragraph observations. Each paragraph is a concept signature — a typed term collection — plus the observed rendering: how many sentences it split into, which relationships chunked together, what transitions connected them, what register governed the whole block.

### Concept Matching

A query produces a structural result — a subgraph from the knowledge base. The causal chain derivation (CC1-CC5) produces maybe 5-8 relationships connected by typed relations. The grammar engine needs to render this as a paragraph.

**Step 1: Build the concept signature.** Extract all typed terms from the subgraph — entity types, relation types, modifier types, temporal markers. Pack them into the [8]u64 ConceptSignature sorted by type for consistent ordering.

**Step 2: Bucket elimination.** Same principle as before, but at concept scale.

```
Total paragraph templates: 500,000

Bucket 1: Term count range
    Concept has 12 terms → templates with 10-14 terms
    500,000 → 80,000

Bucket 2: Required relation types present
    Concept needs {causes, determined_by, enables, prevents, requires}
    Subsumption check: template_mask & query_mask == query_mask
    80,000 → 3,000

Bucket 3: Entity type pattern
    Concept has {material, process, temperature, timing}
    3,000 → 400

Bucket 4: Domain scope
    Metallurgy/physics domain
    400 → 60

Bucket 5: Register
    Technical instructional
    60 → 15

Bucket 6: Strength ranking
    Top 3 by Gutenberg observation frequency
```

From 500,000 to 3 in six integer-operation steps.

### Chunking: Which Relationships Share a Sentence

The matched paragraph template specifies chunking. The template observed in Gutenberg that "when expressing causes + determined_by + enables together, chunk causes+determined_by into one sentence and enables into the next" is structural data — it says which relationships combine.

```zig
pub const ParagraphTemplate = struct {
    id: VdrId = .{},
    concept_sig: ConceptSignature = .{},
    chunk_count: u8 = 0,
    chunks: [8]ChunkDef = undefined,
    transitions: [7]VdrId = undefined,  // transition template between each chunk pair
    register_id: VdrId = .{},
    strength: Q16 = .{},
};

pub const ChunkDef = struct {
    // Which term indices from the concept signature go in this chunk
    term_indices: [8]u8 = undefined,
    term_count: u8 = 0,
    // The sentence-level grammar rule to render this chunk
    sentence_template_id: VdrId = .{},
};
```

The ParagraphTemplate says: this concept has 12 terms. Split them into 3 chunks. Chunk 0 takes terms {0, 1, 4} and renders with sentence template X. Chunk 1 takes terms {2, 3} and renders with sentence template Y. Chunk 2 takes terms {5, 6, 7} and renders with sentence template Z. Between chunk 0 and 1, use transition T1. Between chunk 1 and 2, use transition T2.

The chunking decisions came from Gutenberg observation — how did Darwin actually split 5 related concepts across 3 sentences? How did Russell do it in 2 sentences? How did Faraday do it in 4? Each observation is a different ParagraphTemplate with different chunking, different sentence templates, different transitions, different register. The strength Q16 tracks how often each pattern was observed.

### Ordering: Which Chunk Comes First

The concept signature has typed terms in a sorted order for lookup. But the rendering order — which relationship to express first — is a separate decision encoded in the paragraph template.

"Heat causes structural change. The transition point depends on material composition. Controlled heating enables the desired phase." — causes first, then determined_by, then enables.

"To achieve the desired phase, controlled heating is required. Heat application causes structural change at temperatures determined by composition." — enables first (as purpose), then causes, then determined_by.

Same concept. Same relationships. Different ordering. Different paragraph templates. The Gutenberg evidence captures both orderings (and others) with their register associations. Scientific exposition tends to state the cause first and the effect second. Instructional prose tends to state the goal first and the method second. The register constraint narrows the ordering.

The ordering is data in the ParagraphTemplate — the `chunks` array is in rendering order. Chunk 0 renders first. The chunking definition says which terms go in chunk 0. The paragraph template's ordering IS the decision about what the reader sees first.

### The Term Ordering Problem

Before matching against paragraph templates, the system needs to decide what order the terms should take in the concept signature. This is the "which group of terms goes first" decision.

The structural relationships themselves constrain this. In a chain `causes(A, B), enables(B, C), requires(C, D)`, there's a natural flow: A → B → C → D. The terms sort by their position in the relation chain — sources before targets, causes before effects, general before specific.

```
Ordering heuristics (all mechanical, all from relation properties):

1. Causal flow: causes/enables sources before targets
2. Dependency flow: requires targets before sources (state what's needed first)  
3. Generality: generalizes before specializes (broad context first)
4. Containment: contains before part_of (whole before parts)
5. Temporal: precedes before follows (chronological)
```

Each heuristic is a comparison on RelationType — `causes.isTransitive()`, the inverse method, the relation direction. The ordering algorithm walks the subgraph, applies the heuristics, and produces a canonical term order. This canonical order goes into the ConceptSignature for template matching. The paragraph template then reorders for rendering — but the lookup key is the canonical structural order, not the rendering order.

### Scale

500,000 paragraph templates at maybe 200 bytes each (ConceptSignature + chunks + transitions + metadata): ~100 MB. Significant but fits in the global arena alongside everything else.

The bucket elimination makes search independent of template count. 500,000 or 5,000,000 templates — the bucket hierarchy narrows to a handful of candidates in the same number of integer operations. The only cost that scales with template count is the size of intermediate bucket arrays, which are pre-built at ingestion time.

At L3, paragraph rendering is: one concept signature construction (walking the subgraph, integer operations), one bucket elimination (hash + bitmask + comparisons), one template selection (strength ranking), then chunk-by-chunk sentence rendering using the sentence-level grammar rules already in the system. Total: a few microseconds. No tokens.

### What This Means for Output Quality

The system doesn't generate sentences and hope they form a coherent paragraph. It matches the entire concept against observed paragraph patterns from centuries of published English prose. The chunking, ordering, transitions, and register are all pre-observed and pre-packaged. The output reads like a paragraph because it IS a paragraph — one that Darwin or Russell or Faraday actually wrote, with the domain entities swapped for the current query's entities.

The structural matching ensures the paragraph template is appropriate for the concept being expressed. You don't get a narrative-style paragraph when expressing a causal chain, or an instructional paragraph when expressing a historical sequence — unless the register says otherwise. The concept signature captures the structural shape, the template captures the rendering pattern, and the register constrains the selection. The LLM's ~20 framing tokens (IF1) handle the final polish, if even needed.

