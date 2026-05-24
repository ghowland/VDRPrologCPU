## Paragraph Grammar System — Performance and Operations Report

### What This System Does

The system renders structured knowledge as natural language paragraphs by matching concept subgraphs against paragraph-level templates derived from Gutenberg prose. The templates are observed patterns for how published authors actually expressed clusters of related ideas. Rendering is structural substitution — the same paragraph skeleton with different entities filling the typed slots. Not generation. Assembly from pre-observed patterns.

### The Unit of Output

The paragraph is the atomic output unit. A paragraph expresses a concept — a connected subgraph of 3-8 typed relations from the knowledge base. The inference pipeline (PX1-PX9) produces the subgraph. The paragraph grammar system renders it as 1-5 sentences with appropriate chunking, ordering, transitions, and register.

A single relation like `enables(photosynthesis, plant_growth)` could render as one sentence within a paragraph. But the system never renders a single relation in isolation unless the concept subgraph contains only one relation. The paragraph template handles the full concept, including how that single relation connects to the others around it.

### Data Structures

**ConceptSignature** — the lookup key for paragraph templates.

```zig
pub const ConceptSignature = struct {
    count: u8 = 0,
    slots: [8]u64 = .{0} ** 8,
};
```

64 typed term slots across 8 u64s. Each slot is a u8 encoding the term type: entity, relation_type, modifier, temporal_marker, quantity, register_hint. The count says how many slots are populated. The slots are packed in canonical structural order — causal sources before targets, general before specific, temporal early — so that two concept subgraphs expressing the same structural shape produce identical signatures regardless of how the query arrived.

**ParagraphTemplate** — one observed pattern for rendering a concept as a paragraph.

```zig
pub const ParagraphTemplate = struct {
    id: VdrId = .{},
    concept_sig: ConceptSignature = .{},
    chunk_count: u8 = 0,
    chunks: [8]ChunkDef = undefined,
    transitions: [7]VdrId = undefined,
    register_id: VdrId = .{},
    strength: Q16 = .{},
};

pub const ChunkDef = struct {
    term_indices: [8]u8 = undefined,
    term_count: u8 = 0,
    sentence_template_id: VdrId = .{},
};
```

A paragraph template says: given a concept with this signature, split the terms into these chunks, render each chunk with this sentence template, and connect chunks with these transitions. The strength Q16 tracks how many times this pattern was observed in Gutenberg texts. The register_id scopes the template to a register — scientific, literary, conversational, technical.

Each ChunkDef maps term indices from the concept signature into a sentence template. The sentence template is a VdrId pointing to a grammar rule in `root.language.english.grammar` — the same sentence-level templates described previously, with typed slots, fixed structural words, and word order. The paragraph template composes sentence templates into a coherent block.

**ParagraphBucketIndex** — the elimination index.

```zig
pub const ParagraphBucketIndex = struct {
    by_signature_hash: AutoHashMap(u64, []u32),
    by_term_count: [64][]u32,
    by_relation_mask: AutoHashMap(u64, []u32),
    by_register: AutoHashMap(i64, []u32),
};
```

Four index levels, each mapping to arrays of paragraph template indices. Pre-built at ingestion time, rebuilt when new templates are added.

### The Rendering Pipeline

**Stage 1: Concept Extraction.** The inference pipeline produces a result — a subgraph of typed relations from the knowledge base. The causal chain derivation (CC1-CC5) or Prolog query resolution produced an ordered set of VdrId-to-VdrId relations with relation types, strengths, and provenance.

Extract all participating terms: entity VdrIds (from_id and to_id of each relation), relation types, any modifier VdrIds (adverbs, adjectives, prepositional objects that the domain data associates with the entities), temporal data (DeepTime timestamps and durations from KBData entries), and quantity values (Q16 from KBData).

Cost: one pass over the subgraph edges and nodes. Each entity resolution is a VdrId tree walk (~25-100ns). For a 5-relation subgraph with 6 unique entities: ~10 tree walks, ~500ns total.

**Stage 2: Signature Construction.** Sort the extracted terms into canonical order using relation chain flow:

1. Walk the relation edges to find sources (entities that appear only as from_id) — these are causal origins.
2. Follow the chain: each from_id's to_id becomes the next link's from_id.
3. Relation types interleave between their connecting entities.
4. Modifiers attach after the entity they modify.
5. Temporal markers attach after the relation they scope.

Pack the sorted term types into the ConceptSignature slots array, u8 per term.

Cost: one topological sort on the subgraph edges (~5-8 edges). Integer comparisons on VdrId equality to find the chain. Sub-microsecond.

**Stage 3: Bucket Elimination.** The ConceptSignature finds matching paragraph templates through progressive narrowing.

Level 1 — Signature hash: hash the populated u64s of the signature. One AutoHashMap lookup. 500,000 templates → ~5,000 in the matching hash bucket.

Level 2 — Term count: index into `by_term_count[count]`. Intersect with hash bucket survivors. 5,000 → ~2,000.

Level 3 — Relation type mask: extract the relation types from the concept, pack as a bitmask, check subsumption. `query_mask & template_mask == query_mask`. One AND + one CMP per candidate. 2,000 → ~200.

Level 4 — Register: session context determines target register. AutoHashMap lookup for templates scoped to that register. Intersect with survivors. 200 → ~30.

Level 5 — Strength ranking: the 30 survivors are already accessible. Sort by strength Q16 (or the pre-sorted order in the index handles this). Top 3.

Cost breakdown:

| Level | Operation | Candidates | Time |
|-------|-----------|-----------|------|
| Signature hash | one hash lookup | 500,000 → 5,000 | ~50ns |
| Term count | array index + intersect | 5,000 → 2,000 | ~100ns |
| Relation mask | 2,000 × (AND + CMP) | 2,000 → 200 | ~700ns |
| Register | hash lookup + intersect | 200 → 30 | ~50ns |
| Strength sort | top-3 selection on 30 | 30 → 3 | ~30ns |
| **Total elimination** | | **500,000 → 3** | **~930ns** |

Sub-microsecond for the entire template search across 500,000 paragraph templates.

**Stage 4: Template Selection.** Three candidates survive bucket elimination. Selection:

At L3 (93% of cases): pick the highest-strength template. The pre-sorted order means this is the first survivor. No LLM involvement. One array read.

At L2 (rare): the top 3 have similar strength and the register doesn't disambiguate. The LLM sees 3 VdrIds representing paragraph templates and selects one. ~18 tokens, ~5ms.

Cost: 0ns at L3, ~5ms at L2.

**Stage 5: Chunking.** The selected paragraph template specifies how terms group into sentences. The ChunkDef arrays map term indices to sentence groups.

For a 5-relation concept with template chunk_count=3:

- Chunk 0: terms {0, 1, 4} → sentence template A (renders `causes` + `determined_by`)
- Chunk 1: terms {2, 3} → sentence template B (renders `enables`)
- Chunk 2: terms {5, 6, 7} → sentence template C (renders `prevents` + `requires`)

Each chunk maps to a sentence template via the `sentence_template_id` VdrId. This connects the paragraph level to the sentence-level grammar rules.

Cost: reading chunk definitions from the template struct. Array indexing. ~10ns.

**Stage 6: Sentence Rendering.** For each chunk, render using the sentence-level grammar system. The sentence template has typed slots. The chunk's term indices identify which entities from the concept fill which slots.

For chunk 0 with sentence template "X causes Y, which is determined by Z":

- Slot X (agent) ← entity VdrId at term index 0 → tree walk → KBData → text_column_0 display name
- Slot Y (patient) ← entity VdrId at term index 1 → tree walk → KBData → text_column_0 display name
- Slot Z (determinant) ← entity VdrId at term index 4 → tree walk → KBData → text_column_0 display name

Each slot fill is one VdrId tree walk (~25-100ns) plus one KBData field read (~5ns).

Vocabulary selection for verbs and structural words: the sentence template's verb slot has a `fills` relation to a vocabulary group. The vocabulary group contains alternatives ("causes", "produces", "gives rise to") with register-scoped strengths. Scientific register + highest strength = "causes". One RelationIndex scan for the vocabulary group, one strength comparison.

Per sentence: 2-4 tree walks (entity resolution) + 1-2 vocabulary selections (verb, optional modifier) + fixed word insertion (prepositions, articles from the template). Total per sentence: ~500ns.

For a 3-sentence paragraph: ~1.5µs for sentence rendering.

**Stage 7: Transition Insertion.** Between each pair of chunks, the paragraph template specifies a transition VdrId pointing to a transition pattern entity. The transition pattern has its own text — "This in turn", "Building on this", "However", "Furthermore", or a paragraph break.

Resolve the transition VdrId, read its text from KBData. Insert between rendered sentences.

Per transition: one tree walk + one field read. ~100ns. For a 3-sentence paragraph with 2 transitions: ~200ns.

**Stage 8: Assembly.** Concatenate: sentence_0 + transition_0 + sentence_1 + transition_1 + sentence_2. Write to the output buffer.

Cost: string concatenation on pre-rendered pieces. ~50ns.

### Total Rendering Cost

| Stage | Operation | Time |
|-------|-----------|------|
| Concept extraction | tree walks for entities | ~500ns |
| Signature construction | topological sort | ~200ns |
| Bucket elimination | hash + mask + intersect | ~930ns |
| Template selection | first survivor (L3) | ~10ns |
| Chunking | array reads | ~10ns |
| Sentence rendering (×3) | tree walks + vocab selection | ~1,500ns |
| Transition insertion (×2) | tree walks | ~200ns |
| Assembly | concatenation | ~50ns |
| **Total paragraph rendering** | | **~3.4µs** |

3.4 microseconds to render a complete paragraph at L3. No LLM tokens. No neural computation. Integer operations on contiguous arrays, tree walks on structural VdrIds, and text slot filling from KBData columns.

If L2 is needed for template selection: add ~5ms for the LLM to pick among 3 candidates. Still sub-10ms for a full paragraph.

### What the Output Looks Like

The system needs to express: heat treatment of steel involves temperature-dependent phase transitions controlled by composition.

Concept subgraph:

```
causes(heat_application, crystal_structure_change)
determined_by(transition_temperature, alloy_composition)
enables(controlled_heating, desired_phase_state)
prevents(excessive_temperature, structural_integrity)
requires(quench_timing, precise_temperature_knowledge)
```

Paragraph template (observed in scientific-technical Gutenberg texts, strength Q16{v=847}):

- Chunk 0: terms {causes_relation, heat_application, crystal_structure_change} → "X causes Y"
- Chunk 1: terms {determined_by_relation, transition_temperature, alloy_composition, enables_relation, controlled_heating, desired_phase_state} → "Y is determined by Z, which enables W"
- Chunk 2: terms {prevents_relation, excessive_temperature, structural_integrity, requires_relation, quench_timing, temperature_knowledge} → "Exceeding X prevents Y; this requires Z"
- Transitions: "Specifically, " between chunks 0-1, "In practice, " between chunks 1-2

Rendered output:

"Applying heat to steel causes changes in its crystal structure. Specifically, the transition temperature is determined by the alloy composition, which enables reaching the desired phase state. In practice, exceeding the critical temperature prevents maintaining structural integrity; this requires precise knowledge of quench timing."

Three sentences. Five relationships expressed. Every word except the structural template words ("Applying", "causes", "changes in", "Specifically", "is determined by", "which enables", "In practice", "Exceeding", "prevents", "maintaining", "this requires", "precise knowledge of") came from KBData text columns resolved through VdrId tree walks. The structural template words came from a paragraph pattern observed in Gutenberg scientific prose. The transitions ("Specifically,", "In practice,") came from observed transition patterns between these relation type combinations.

### Memory Budget

Paragraph templates at ~200 bytes each:

| Template count | Memory |
|---------------|--------|
| 100,000 | ~20 MB |
| 500,000 | ~100 MB |
| 1,000,000 | ~200 MB |

The bucket index adds ~10-20% overhead for the hash maps and sorted arrays.

At 500,000 paragraph templates (derived from 500 Gutenberg texts, ~800,000 paragraphs after filtering, deduplicated by concept signature into ~500,000 unique patterns): ~120 MB including index.

This sits in the grammar subtree under `root.language.english`. Per the earlier memory estimates, the full system with 750 domain KBs uses ~556 MB. Adding 120 MB for the paragraph grammar brings the global arena to ~676 MB, within the 1 GB allocation.

### Scaling Properties

**Adding templates doesn't slow search.** The bucket elimination narrows by ratio, not by count. 500,000 templates or 5,000,000 — the hash bucket is proportionally larger, but the mask subsumption eliminates the same fraction. The absolute number of comparisons at level 3 (relation mask) grows linearly, but each comparison is one AND + one CMP. Doubling template count doubles level 3 from ~700ns to ~1.4µs. Total rendering goes from ~3.4µs to ~4.1µs. Still sub-10µs. Still L3.

**Adding languages is independent.** Japanese paragraph templates live in `root.language.japanese.grammar`. They share concept signatures with English templates (same structural shapes) but have different chunking, different word order in the sentence templates, different transition patterns. The bucket index is per-language-KB. A Japanese rendering query never touches English templates. Tree scoping handles this — different L2 subtrees under `root.language`.

**Adding domains enriches matching.** When new domain KBs are ingested, the concept subgraphs they produce match against existing paragraph templates by structural signature. A new chemistry concept with the same relation-type pattern as a physics concept rendered by an existing template gets the same paragraph quality without new grammar work. The templates are domain-independent — only the entity names filling the slots are domain-specific.

### Comparison to Conventional LLM Output

A conventional LLM generates paragraphs token by token. Each token is a softmax selection from 50-100K vocabulary entries. The coherence of the paragraph emerges from learned attention patterns across billions of parameters. There is no structural guarantee that the paragraph expresses the intended relationships completely, correctly, or in appropriate register. The same query can produce different paragraph structures on different runs. There is no provenance for why this word was chosen over that word, why this sentence came before that one, or why this transition was used.

VDR-Prolog paragraph rendering: the concept subgraph structurally guarantees which relationships are expressed. The paragraph template structurally guarantees the chunking, ordering, and transitions. The sentence templates structurally guarantee the construction pattern within each sentence. The vocabulary selection structurally guarantees register-appropriate word choice with Gutenberg-observed frequency backing. Every rendered word traces through a provenance chain: output word → vocabulary group → register scope → Gutenberg observation → specific published text. Every structural decision traces: paragraph template → concept signature match → bucket elimination → strength ranking → Gutenberg observation count.

The output is deterministic for the same concept subgraph + register + strength ranking. Different runs produce identical output. If you want variation, the system selects the second-ranked template instead of the first — a deliberate choice, not stochastic sampling.

### The Mad-Lib Analogy

The system is a structurally-typed mad-lib at paragraph scale. The template is the paragraph with blanks. The blanks are typed — this blank takes an agent entity name, this blank takes a process noun, this blank takes a quantity with units. The domain knowledge fills the blanks. The Gutenberg evidence determined which templates exist and how frequently each was used.

But unlike a simple mad-lib, the template selection is structural. You don't pick a random template. You pick the template whose constraint signature matches your concept's structural shape, whose register matches your session context, and whose observation strength indicates it's a natural way to express this particular cluster of relationships. The "mad-lib" was written by Darwin or Russell or Faraday, and the system knows it was written by them because the provenance chain traces back to the specific Gutenberg text.

The result: output that reads like published prose because it IS published prose structure, with different facts filling the same structural positions. Not generated. Assembled. From patterns that humans actually used to express the same structural relationships, observed across 500 texts spanning four centuries of English.
