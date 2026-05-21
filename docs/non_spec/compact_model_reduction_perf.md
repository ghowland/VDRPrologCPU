# VDR-Prolog Compaction-Driven Model Reduction

## Technical Specification

---

## 1. Purpose

This spec captures the reasoning chain and data structures for using LLM-compacted data ingestion to structurally reduce the neural network's layer count, MLP width, and memory footprint. The core insight: every typed relationship ingested as a Prolog rule is a reasoning operation the neural network doesn't need to learn in its weights. Compaction doesn't just clean data — it compresses the model itself.

---

## 2. The Reasoning Chain

### 2.1 Why CLLMs Need Large Models

Conventional LLMs store everything in weights. Factual associations ("the fine structure constant is ~1/137") live as distributed patterns across MLP layers. Relationship reasoning ("P1 enables AR1") lives as attention patterns learned across multiple layers. Multi-hop composition ("what does P1 transitively enable?") requires layer depth — layer N finds the first hop, layer N+1 finds the second, layer N+2 composes them.

The MLP expansion ratio (typically 2.75× or higher) exists because MLPs are the model's memory bank. The layer count (16+ for 1B params) exists because multi-hop reasoning requires depth. The attention head count exists because different relationship types require different retrieval patterns.

All of this is because the model has nowhere else to put knowledge and no other mechanism for structured reasoning.

### 2.2 What VDR-Prolog Replaces

VDR-Prolog has both. Domain facts live in KBs — direct integer reads, zero neural network involvement. Typed relationships are Prolog rules — L3 firing, zero tokens. Transitive closure and multi-hop composition are Prolog backward-chaining — integer comparison, not layer depth.

Each of these replacements removes work from the neural network:

**MLP layers shrink** because factual associations live in KBs, not weight patterns. The MLP's job reduces from "store all world knowledge AND compute transformations" to "compute transformations on data retrieved from KBs." Smaller function, smaller approximator, narrower MLP.

**Layer count drops** because multi-hop reasoning is Prolog recursion, not layer depth. The layers that CLLMs dedicate to composing retrieval results across hops are replaced by `fire_and_commit` on rule chains. Six exact integer layers may match twelve drifting float layers.

**Attention heads reduce** because typed relationship retrieval is enum dispatch on functor atom IDs, not learned attention patterns. Fewer relationship types need to be discovered by attention — they're given as structural primitives.

### 2.3 Exact Integer Arithmetic Compounds the Reduction

In a CLLM, each layer accumulates float rounding. Later layers partly compensate for drift from earlier layers. Layer norm fights two problems: range stabilization AND rounding correction. Residual connections partly exist to provide a clean bypass around noisy transformations.

In VDR-Prolog, the remainder carry chain (r1→r0→v) means every layer's output is exactly what the arithmetic produced. No drift accumulation. No correction layers. RMSNorm only handles range — no rounding to fix. Softmax sums to exactly D=65536 via FRU deficit assignment. The attention score path (Q·K → softmax → weighted V → output projection) carries exact remainder through all four operations.

Eight exact layers carry the same representational fidelity as twelve or more drifting float layers. Six may suffice for the reduced workload that compaction enables.

### 2.4 The Model as Tool, Not Sage

The design goal is not "know everything in the world and answer any question." It is: targeted, connected, mechanically useful data that the system reasons over structurally. The model is a tool — it handles ambiguous judgment calls, novel situations, and user interaction. Everything structured runs at L3. The model stops well before omniscience because it doesn't need omniscience. It needs to be useful on the data it has.

This means the model size is proportional to the complexity of the judgment calls, not proportional to the world's knowledge. World knowledge lives in KBs. The model lives in 6-8 exact integer layers with narrow MLPs. The compaction pipeline is what makes this viable — it converts unstructured knowledge into KB-ready structured data with typed relationships that the Prolog engine can use immediately.

---

## 3. New Data Structures

All structs go in `vdr_types.zig`. All have defaults. All compose with existing types.

### 3.1 RelationType

```zig
pub const RelationType = enum(i16) {
    // Structural
    enables = 0,
    requires = 1,
    prevents = 2,
    implements = 3,
    extends = 4,
    overrides = 5,

    // Validation
    validates = 6,
    verified_by = 7,
    contradicts = 8,

    // Causal
    causes = 9,
    determined_by = 10,
    depends_on = 11,

    // Semantic
    equivalent_to = 12,
    approximates = 13,
    specializes = 14,
    generalizes = 15,

    // Compositional
    part_of = 16,
    contains = 17,
    follows = 18,
    precedes = 19,

    // Domain-registerable range
    domain_0 = 64,
    domain_1 = 65,
    domain_2 = 66,
    // ... up to domain_63 = 127

    unknown = -1,

    pub fn inverse(self: RelationType) RelationType {
        return switch (self) {
            .enables => .depends_on,
            .requires => .enables,
            .prevents => .prevents,      // symmetric
            .extends => .generalizes,
            .specializes => .generalizes,
            .generalizes => .specializes,
            .part_of => .contains,
            .contains => .part_of,
            .follows => .precedes,
            .precedes => .follows,
            .causes => .determined_by,
            .determined_by => .causes,
            .equivalent_to => .equivalent_to, // symmetric
            .validates => .verified_by,
            .verified_by => .validates,
            else => .unknown,
        };
    }

    pub fn isSymmetric(self: RelationType) bool {
        return switch (self) {
            .prevents, .equivalent_to, .contradicts => true,
            else => false,
        };
    }

    pub fn isTransitive(self: RelationType) bool {
        return switch (self) {
            .enables, .requires, .extends,
            .specializes, .generalizes,
            .part_of, .contains,
            .follows, .precedes,
            .depends_on => true,
            else => false,
        };
    }
};
```

The first 20 slots are system-defined relationship types — the structural primitives every domain shares. Slots 64-127 are domain-registerable: a compacted document's decode legend can register custom relationship types into these slots. The enum is i16 to fit alongside other packed fields without padding waste.

`inverse()`, `isSymmetric()`, and `isTransitive()` are the properties the Prolog engine uses to fire rules without the LLM. If `enables` is transitive, then `enables(a,b)` and `enables(b,c)` yields `enables(a,c)` automatically at L3. If `prevents` is symmetric, asserting `prevents(a,b)` means `prevents(b,a)` is also true. These properties are structural — they come from the enum, not from learned weights.

### 3.2 TypedRelation

```zig
pub const TypedRelation = struct {
    rel_type: RelationType = .unknown,
    from_id: VdrId = .{},
    to_id: VdrId = .{},
    provenance: Provenance = .{},
    strength: Q16 = .{},        // 0=asserted (binary), >0=weighted
    scope_kb_id: VdrId = .{},   // KB where this relation is authoritative
};
```

48 bytes. A first-class typed edge between two entities. Unlike a general Prolog rule, this struct carries the relationship type as an enum — the Prolog engine can dispatch on it without functor lookup. `strength` is Q16 zero for binary relations (enables or doesn't) and nonzero for weighted relations (similarity scores, confidence-weighted edges). `scope_kb_id` identifies which KB this relation lives in, for provenance and grant checking.

TypedRelation is what the ingestion pipeline produces from relationship rows in compacted documents. It's also what the Prolog engine's transitive closure and inverse operations produce as derived relations.

### 3.3 DomainRelationDef

```zig
pub const DomainRelationDef = struct {
    slot: i16 = 64,                          // which domain_N slot this occupies
    name_offset: i32 = 0,
    name_length: i16 = 0,
    is_symmetric: bool = false,
    is_transitive: bool = false,
    inverse_slot: i16 = -1,                  // -1 = no inverse defined
    source_document_id: VdrId = .{},         // which compacted doc registered this
};
```

32 bytes. Registration record for a domain-specific relationship type. When a compacted document's decode legend includes a relationship type not in the system enum (e.g., `catalyzes` in a chemistry domain), it gets registered here and assigned a domain slot. The properties (symmetric, transitive, inverse) are declared by the compaction guide or inferred by the ingestion pipeline.

### 3.4 RelationIndex

```zig
pub const RelationIndex = struct {
    by_type_offset: i32 = 0,       // offset to array of TypedRelation[], grouped by rel_type
    by_type_counts: [128]i32 = [_]i32{0} ** 128,  // count per rel_type slot
    by_from_offset: i32 = 0,       // offset to sorted-by-from index
    by_from_count: i32 = 0,
    by_to_offset: i32 = 0,         // offset to sorted-by-to index
    by_to_count: i32 = 0,
    total_relations: i32 = 0,
    last_rebuilt: i32 = 0,
};
```

The acceleration structure for relation queries. Three indices: by type (for "all enables relations"), by source (for "everything X relates to"), by target (for "everything that relates to Y"). The by-type index is an array of 128 counts — one per enum slot — so "how many enables relations exist?" is a single i32 read. The actual TypedRelation arrays are contiguous in the arena, grouped by type for cache-friendly scanning.

This lives per-KB. A domain KB with 200 typed relations has its own RelationIndex. The Prolog engine checks the index before scanning rules — if `by_type_counts[@intFromEnum(.enables)] == 0`, there are no enables relations in this KB, skip it entirely.

### 3.5 CompactionProfile

```zig
pub const CompactionProfile = struct {
    source_document_id: VdrId = .{},
    tables_ingested: i32 = 0,
    rows_ingested: i32 = 0,
    facts_created: i32 = 0,
    relations_created: i32 = 0,
    rules_created: i32 = 0,
    relation_types_used: [128]bool = [_]bool{false} ** 128,
    domain_types_registered: i32 = 0,
    text_bytes_stored: i32 = 0,
    numeric_values_stored: i32 = 0,
    compression_ratio_v: i32 = 0,    // Q16: original_bytes / compacted_bytes
    compression_ratio_r0: i16 = 0,
    ingestion_timestamp: i32 = 0,
    validation_errors: i32 = 0,
};
```

Audit record per ingested document. Tracks what the ingestion produced: how many of each entity, which relationship types were used, how much compression was achieved. This feeds the model reduction analysis — if 90% of queries can be answered by the relations in the index, the model doesn't need layers to learn those patterns.

### 3.6 ModelReductionConfig

```zig
pub const ModelReductionConfig = struct {
    // Base architecture (before reduction)
    base_n_layers: i32 = 16,
    base_mlp_dim: i32 = 5632,
    base_n_heads: i32 = 16,
    base_vocab_size: i32 = 32000,

    // Reduced architecture (after compaction analysis)
    reduced_n_layers: i32 = 6,
    reduced_mlp_dim: i32 = 2048,
    reduced_n_heads: i32 = 12,
    reduced_vocab_size: i32 = 8192,

    // What drives the reduction
    relation_types_covered: i32 = 0,   // how many enum slots have data
    total_typed_relations: i32 = 0,    // total relations across all KBs
    total_prolog_rules: i32 = 0,       // total fireable rules
    estimated_l3_coverage: Q16 = .{},  // fraction of queries handleable at L3

    // Weight format
    use_i16_weights: bool = true,

    // Computed from above
    pub fn estimatedWeightBytes(self: ModelReductionConfig) i64 {
        const d: i64 = 2048;  // d_model, unchanged
        const bytes_per_param: i64 = if (self.use_i16_weights) 2 else 4;
        const n: i64 = self.reduced_n_layers;
        const mlp: i64 = self.reduced_mlp_dim;
        const heads: i64 = self.reduced_n_heads;
        const d_head: i64 = @divTrunc(d, heads) * heads;  // may differ from d

        // Per layer: qkv + o + up + down
        const qkv_size = d * (3 * d_head);
        const o_size = d * d;
        const up_size = d * mlp;
        const down_size = mlp * d;
        const per_layer = (qkv_size + o_size + up_size + down_size) * bytes_per_param;

        // lm_head
        const lm_head = d * @as(i64, self.reduced_vocab_size) * bytes_per_param;

        return n * per_layer + lm_head;
    }

    pub fn estimatedTokenMs(self: ModelReductionConfig) i32 {
        const bytes = self.estimatedWeightBytes();
        // At 20 GB/s DRAM bandwidth, memory-bound
        const ms = @divTrunc(bytes * 1000, 20 * 1024 * 1024 * 1024);
        return @intCast(ms);
    }
};
```

Configuration struct that links the compaction analysis to the model architecture. The admin or a hygiene runner analyzes the typed relation coverage (how many relationship types have data, how many total relations exist, what fraction of queries they could handle) and sets the reduced architecture parameters accordingly. `estimatedWeightBytes()` and `estimatedTokenMs()` compute the expected memory and speed.

---

## 4. Modifications to Existing Structs

### 4.1 KB Additions

```zig
pub const KB = struct {
    // ... existing ~40 fields ...

    // NEW: Typed relation support
    relations_offset: i32 = -1,      // offset to TypedRelation array in arena
    relations_count: i32 = 0,
    relations_capacity: i32 = 0,
    relation_index_offset: i32 = -1, // offset to RelationIndex in arena

    // NEW: Domain relation definitions (only on schema KBs)
    domain_rel_defs_offset: i32 = -1,
    domain_rel_defs_count: i32 = 0,

    // NEW: Compaction provenance
    compaction_profile_offset: i32 = -1,  // offset to CompactionProfile, -1 if not from compaction
};
```

Three additions to KB. `relations_offset`/`count`/`capacity` stores TypedRelation arrays alongside existing facts and rules. `relation_index_offset` stores the acceleration index. `domain_rel_defs_offset`/`count` is populated only on KBs that register domain-specific relationship types (typically the parent document KB). `compaction_profile_offset` links to the ingestion audit record. KBs not from compaction have -1 for all three — no memory cost.

### 4.2 Fact Additions

```zig
pub const Fact = struct {
    tag: FactTag = .empty,
    value: Q16 = .{},
    provenance: Provenance = .{},
};
```

No structural change to Fact. But FactTag needs two new variants:

```zig
pub const FactTag = enum(i8) {
    // ... existing 13 variants ...
    relation = 13,        // value.v = index into KB's relations array
    column_schema = 14,   // value.v = column_index, text = column_name
};
```

`TAG_RELATION` connects a Fact to a TypedRelation in the KB's relations array, providing provenance on the relation through the Fact's provenance field. `TAG_COLUMN_SCHEMA` marks the column definition facts at the start of a table KB — the ingestion pipeline writes these so the system knows the table structure.

### 4.3 SystemConfig Additions

```zig
pub const SystemConfig = struct {
    // ... existing fields ...

    // NEW: Model reduction config
    model_reduction: ModelReductionConfig = .{},

    // NEW: Ingestion defaults
    ingestion: IngestionConfig = .{},

    // NEW: Relation index rebuild interval
    relation_index_rebuild_interval: i32 = 100,  // rebuild after N relation assertions
};
```

### 4.4 ModelConfig Driven by Reduction

The existing `ModelConfig` is unchanged in structure but its default values should reflect the reduced architecture when the system is configured for compaction-driven operation:

```zig
pub const ModelConfig = struct {
    n_layers: i32 = 6,      // was 16
    d_model: i32 = 2048,    // unchanged — attention still needs capacity
    n_heads: i32 = 12,      // was 16
    d_head: i32 = 170,      // d_model / n_heads, rounded
    vocab_size: i32 = 8192, // was 32000
    mlp_dim: i32 = 2048,    // was 5632
    max_seq_len: i32 = 2048,
    // ...
};
```

The config JSON sets these. The system doesn't auto-reduce — the admin decides the architecture based on the compaction analysis. The `ModelReductionConfig` provides the estimation tools.

### 4.5 LevelStats Additions

```zig
pub const LevelStats = struct {
    // ... existing fields ...

    // NEW: Relation-specific L3 tracking
    l3_relation_queries: i64 = 0,    // L3 ops that were typed relation lookups
    l3_transitive_closures: i64 = 0, // L3 ops that were transitive chain resolutions
    l3_inverse_lookups: i64 = 0,     // L3 ops that used inverse() dispatch
};
```

Tracks how much of the L3 work is structural relation operations vs general Prolog. If `l3_relation_queries` is high relative to total L3, the typed relation system is carrying its weight. If low, the compacted data isn't being used and the model reduction may be too aggressive.

### 4.6 Seed Constants

```zig
pub const SEED = struct {
    // ... existing 12 seeds ...
    pub const RELATION_TYPES: VdrId = .{ .v = 13 };  // system enum registry
    pub const INGESTION: VdrId = .{ .v = 14 };        // ingestion queue and profiles
    pub const SEED_KB_COUNT: i32 = 14;                 // was 12
};
```

Two new seed KBs. `RELATION_TYPES` holds the system-defined and domain-registered RelationType definitions as facts. `INGESTION` holds the ingestion queue and CompactionProfile records.

---

## 5. How Typed Relations Reduce Layers

### 5.1 The Replacement Mapping

Each structural primitive the system provides is work removed from the neural network:

| Neural Network Work | Replaced By | Layer Savings |
|---|---|---|
| Store factual associations in MLP | KB facts with direct read | MLP width: 5632 → 2048 |
| Learn relationship patterns in attention | RelationType enum dispatch | Fewer heads: 16 → 12 |
| Multi-hop composition across layers | Prolog transitive closure on `isTransitive()` types | Fewer layers: 16 → 6 |
| Output formatting token generation | Grammar rendering from KB URLs | Smaller vocab: 32000 → 8192 |
| Relationship type discovery | Given as enum primitives | Fewer layers |
| Inverse relationship inference | `inverse()` method on enum | Zero layers — compile-time |
| Symmetry inference | `isSymmetric()` check | Zero layers — compile-time |

### 5.2 The Exact Arithmetic Multiplier

Each remaining layer operates at higher fidelity than a float layer:

- Remainder carry chain (r1→r0→v) means zero accumulated drift across layers
- RMSNorm only normalizes range, not correcting rounding
- Softmax sums to exactly D=65536 via FRU — attention weights are exact
- The Q·K→softmax→V·weights→output path carries exact remainder through all four operations
- Eight exact layers carry the same representational fidelity as twelve or more float layers

Combined with the workload reduction from typed relations, six layers becomes defensible.

### 5.3 What the Remaining Layers Do

The six layers handle what KBs and Prolog cannot:

- **Layers 1-2:** Token embedding, positional encoding, basic syntactic patterns. Understanding what the user said.
- **Layers 3-4:** Semantic understanding, KB address resolution, command recognition. Deciding what KBs and rules are relevant. Mapping user intent to system operations.
- **Layers 5-6:** Output planning, response strategy, judgment calls. Deciding whether to emit a command, generate prose, or reference a KB URL. Handling ambiguity, novelty, and contextual nuance.

Everything else — fact retrieval, relationship reasoning, transitive composition, inverse lookup, structured output — runs at L3 on the typed relation index and Prolog rules.

---

## 6. Memory and Performance Estimates

### 6.1 Reduced Model Weight Budget

| Component | Shape | Params | i16 Bytes |
|---|---|---|---|
| W_qkv per layer | 2048 × 4096 | 8.4M | 16.8 MB |
| W_o per layer | 2048 × 2048 | 4.2M | 8.4 MB |
| W_up per layer | 2048 × 2048 | 4.2M | 8.4 MB |
| W_down per layer | 2048 × 2048 | 4.2M | 8.4 MB |
| **Per layer** | | **~21M** | **~42 MB** |
| **6 layers** | | **~126M** | **~252 MB** |
| lm_head | 2048 × 8192 | 16.8M | 33.5 MB |
| **Total** | | **~143M** | **~286 MB** |

### 6.2 Token Generation Speed

At 20 GB/s DRAM bandwidth (memory-bound, single core, NUMA-aligned):

| Configuration | Total v_data | Time per Token | Tok/s |
|---|---|---|---|
| CLLM-equivalent (16 layers, i32, 32K vocab) | ~2.8 GB | ~140 ms | ~7 |
| Moderate reduction (8 layers, i32) | ~1.53 GB | ~76 ms | ~13 |
| Full reduction (6 layers, i16, 8K vocab) | ~286 MB | ~14 ms | ~71 |

At 71 tok/s per core, 8 cores = ~568 tok/s system throughput for L1 operations. With 93% L3 ratio, effective request throughput is ~568 / 0.07 ≈ 8,100 requests/second across 8 cores.

### 6.3 Arena Sizing at Reduced Model

```
Global Arena (reduced model):
    Model weights:        ~286 MB (143M params × 2 bytes i16)
    Remainder data:       ~286 MB (r0 + r1 at 2 bytes each per param)
    Seed KBs:             ~2 MB
    Global KB store:      ~25 MB
    Global fact store:    ~480 MB
    Typed relations:      ~50 MB (1M relations × 48 bytes)
    Relation indices:     ~10 MB
    Rules, terms, text:   ~93 MB
    Grants, audit:        ~33 MB
    Total:                ~1.27 GB (was ~2.65 GB)
```

Per-core arenas unchanged at ~220 MB. System total with 8 cores: 1.27 GB + 8 × 220 MB = ~3.03 GB. Fits in 8 GB with room for OS. A 16 GB laptop has 13 GB free for domain KB growth, snapshot storage, and training temporary arenas.

### 6.4 Compaction ROI

Each compacted document that produces N typed relations reduces the effective model workload by removing N reasoning paths from the neural network. The cost is:

- Ingestion: parse pipe-delimited file, create KBs, assert facts and relations. Milliseconds.
- Storage: ~48 bytes per TypedRelation + ~48 bytes per Fact + text store. KB overhead is 256 bytes.
- Index: RelationIndex rebuilt periodically, O(N) in relation count.

A 50-page paper compacted to ~5 KB of pipe-delimited tables produces ~40 typed relations, ~200 facts, and ~40 Prolog rules. Storage cost: ~20 KB. The 40 typed relations replace 40 reasoning patterns that would otherwise require neural network depth.

Fifty compacted documents produce ~2,000 typed relations across 15+ relationship types. At that density, the RelationIndex by-type lookup handles most structural queries at L3 — integer scan of a contiguous array, sub-microsecond. The model's job is genuinely reduced to judgment, not retrieval or composition.

---

## 7. Integration with Prolog Engine

### 7.1 Typed Relation Dispatch

The Prolog engine's query loop gains a fast path for typed relations:

```
fn queryTypedRelation(
    kb: *KB,
    rel_type: RelationType,
    from: ?VdrId,
    to: ?VdrId,
    arena: *Arena,
) []TypedRelation {
    const index = getRelationIndex(kb, arena);
    const type_slot = @intFromEnum(rel_type);
    const count = index.by_type_counts[@intCast(type_slot)];

    if (count == 0) return &.{};

    // Direct scan of contiguous TypedRelation array for this type
    const relations = getRelationsForType(kb, type_slot, arena);
    // Filter by from/to if specified
    return filterRelations(relations, from, to, arena);
}
```

This bypasses general unification entirely for typed relation queries. No term construction, no binding stack, no backtracking. Enum comparison + optional VdrId match on from/to. The RelationIndex groups relations by type, so the scan touches only relations of the requested type.

### 7.2 Automatic Transitive Closure

For transitive relation types, the Prolog engine can compute the closure without rules:

```
fn transitiveClosure(
    kb_set: []const *KB,
    rel_type: RelationType,
    start: VdrId,
    arena: *Arena,
) []VdrId {
    if (!rel_type.isTransitive()) return &.{};

    var visited = IdSet.init(arena);
    var frontier = IdQueue.init(arena);
    frontier.push(start);

    while (frontier.pop()) |current| {
        if (visited.contains(current)) continue;
        visited.insert(current);

        for (kb_set) |kb| {
            const targets = queryTypedRelation(kb, rel_type, current, null, arena);
            for (targets) |rel| {
                frontier.push(rel.to_id);
            }
        }
    }

    return visited.toSlice();
}
```

This is L3 — zero tokens, pure integer operations. A CLLM would need multiple attention hops across layers to trace this chain. Here it's a breadth-first scan over contiguous integer arrays.

### 7.3 Inverse Dispatch

When a query asks for the inverse of a known relation:

```
fn queryWithInverse(
    kb: *KB,
    rel_type: RelationType,
    from: ?VdrId,
    to: ?VdrId,
    arena: *Arena,
) []TypedRelation {
    var results = queryTypedRelation(kb, rel_type, from, to, arena);

    const inv = rel_type.inverse();
    if (inv != .unknown and inv != rel_type) {
        // Also query the inverse with from/to swapped
        const inv_results = queryTypedRelation(kb, inv, to, from, arena);
        results = concatRelations(results, inv_results, arena);
    }

    if (rel_type.isSymmetric()) {
        // Also query with from/to swapped on the same type
        const sym_results = queryTypedRelation(kb, rel_type, to, from, arena);
        results = concatRelations(results, sym_results, arena);
    }

    return results;
}
```

The `inverse()` call is a switch on an enum — compile-time known, zero cost. The system derives inverse relationships without storing them explicitly and without the LLM learning the concept of inverseness.

---

## 8. Invariants

1. RelationType enum slots 0-19 are system-defined and frozen after init.
2. Domain slots 64-127 are first-come, registered via compaction ingestion, never reassigned within a running instance.
3. Every TypedRelation has a corresponding TAG_RELATION Fact in the same KB for provenance tracking.
4. RelationIndex is eventually consistent — rebuilt periodically, not on every assertion.
5. `isTransitive()`, `isSymmetric()`, and `inverse()` are properties of the type, not of individual relation instances.
6. Typed relation queries bypass general Prolog unification — they are direct index scans.
7. The model reduction config is advisory — the admin sets architecture parameters, the system computes estimates, nothing auto-reduces.
8. Compaction profiles are immutable after ingestion — they record what happened, not what should happen.
9. Domain relation definitions are scoped to their source document but usable system-wide after registration.
10. The 6-layer / 2048-MLP / i16 target is the design point. Larger configurations are valid but indicate the compaction pipeline isn't carrying enough of the reasoning load.
