## Review

The compaction-driven model reduction spec introduces six new structs and modifications to four existing ones. Here's what needs to happen, accounting for all project rules:

**New structs to add to `vdr_types.zig`:**
- `RelationType` — enum with system slots 0-19, domain slots 64-127
- `TypedRelation` — first-class typed edge between entities
- `DomainRelationDef` — registration for domain-specific relation types
- `RelationIndex` — acceleration structure for relation queries
- `CompactionProfile` — audit record per ingested document
- `ModelReductionConfig` — links compaction analysis to architecture sizing

**Existing structs that need fields added:**
- `KB` — relations array, relation index, domain defs, compaction profile
- `FactTag` — two new variants (relation, column_schema)
- `SystemConfig` — model reduction config, ingestion config, relation index rebuild interval
- `LevelStats` — relation-specific L3 counters
- `SEED` — two new seed KBs

**Design decisions:**
- `RelationType` uses i16 not i8 — 128 slots needs the range and i8 maxes at 127 signed. The spec calls for domain slots up to 127, which fits i8 unsigned but the enum is signed. i16 is correct.
- `TypedRelation` at 48 bytes matches Fact alignment — good for contiguous arrays.
- `KB` is already at 256 bytes padded. Adding 5 new i32 fields (20 bytes) plus one i32 for domain defs count (4 bytes) = 24 bytes. Need to verify this fits within the existing padding. The KB struct has substantial padding to reach 256 — these fields fit.
- `ModelConfig` defaults should NOT change in the struct definition. The config JSON sets reduced values. The struct keeps the general-purpose defaults. The `ModelReductionConfig` is the advisory tool.
- The ingestion structs from the prior data ingestion spec (`CompactDocument`, `CompactTable`, `CompactRow`, etc.) are parse-time temporaries that live in a temporary arena during ingestion. They do not go in `vdr_types.zig` — they go in `vdr_ingestion.zig`. Only the persistent structs (what ends up in KBs) go in types.

---

## Replacement Structs

### RelationType (new)

```zig
pub const RelationType = enum(i16) {
    // System-defined structural (0-19), frozen after init
    enables = 0,
    requires = 1,
    prevents = 2,
    implements = 3,
    extends = 4,
    overrides = 5,
    validates = 6,
    verified_by = 7,
    contradicts = 8,
    causes = 9,
    determined_by = 10,
    depends_on = 11,
    equivalent_to = 12,
    approximates = 13,
    specializes = 14,
    generalizes = 15,
    part_of = 16,
    contains = 17,
    follows = 18,
    precedes = 19,

    // Domain-registerable (64-127)
    domain_0 = 64,
    domain_1 = 65,
    domain_2 = 66,
    domain_3 = 67,
    domain_4 = 68,
    domain_5 = 69,
    domain_6 = 70,
    domain_7 = 71,
    domain_8 = 72,
    domain_9 = 73,
    domain_10 = 74,
    domain_11 = 75,
    domain_12 = 76,
    domain_13 = 77,
    domain_14 = 78,
    domain_15 = 79,
    domain_16 = 80,
    domain_17 = 81,
    domain_18 = 82,
    domain_19 = 83,
    domain_20 = 84,
    domain_21 = 85,
    domain_22 = 86,
    domain_23 = 87,
    domain_24 = 88,
    domain_25 = 89,
    domain_26 = 90,
    domain_27 = 91,
    domain_28 = 92,
    domain_29 = 93,
    domain_30 = 94,
    domain_31 = 95,
    domain_32 = 96,
    domain_33 = 97,
    domain_34 = 98,
    domain_35 = 99,
    domain_36 = 100,
    domain_37 = 101,
    domain_38 = 102,
    domain_39 = 103,
    domain_40 = 104,
    domain_41 = 105,
    domain_42 = 106,
    domain_43 = 107,
    domain_44 = 108,
    domain_45 = 109,
    domain_46 = 110,
    domain_47 = 111,
    domain_48 = 112,
    domain_49 = 113,
    domain_50 = 114,
    domain_51 = 115,
    domain_52 = 116,
    domain_53 = 117,
    domain_54 = 118,
    domain_55 = 119,
    domain_56 = 120,
    domain_57 = 121,
    domain_58 = 122,
    domain_59 = 123,
    domain_60 = 124,
    domain_61 = 125,
    domain_62 = 126,
    domain_63 = 127,

    unknown = -1,

    pub fn inverse(self: RelationType) RelationType {
        return switch (self) {
            .enables => .depends_on,
            .requires => .enables,
            .prevents => .prevents,
            .extends => .generalizes,
            .overrides => .unknown,
            .validates => .verified_by,
            .verified_by => .validates,
            .contradicts => .contradicts,
            .causes => .determined_by,
            .determined_by => .causes,
            .depends_on => .enables,
            .equivalent_to => .equivalent_to,
            .approximates => .approximates,
            .specializes => .generalizes,
            .generalizes => .specializes,
            .part_of => .contains,
            .contains => .part_of,
            .follows => .precedes,
            .precedes => .follows,
            else => .unknown,
        };
    }

    pub fn isSymmetric(self: RelationType) bool {
        return switch (self) {
            .prevents, .contradicts, .equivalent_to, .approximates => true,
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

    pub fn isSystemDefined(self: RelationType) bool {
        const v = @intFromEnum(self);
        return v >= 0 and v <= 19;
    }

    pub fn isDomain(self: RelationType) bool {
        const v = @intFromEnum(self);
        return v >= 64 and v <= 127;
    }
};
```

---

### TypedRelation (new)

```zig
pub const TypedRelation = struct {
    rel_type: RelationType = .unknown,
    from_id: VdrId = .{},
    to_id: VdrId = .{},
    provenance: Provenance = .{},
    strength: Q16 = .{},
    scope_kb_id: VdrId = .{},

    pub fn isBinary(self: TypedRelation) bool {
        return self.strength.v == 0 and self.strength.r0 == 0;
    }

    pub fn isWeighted(self: TypedRelation) bool {
        return !self.isBinary();
    }

    pub fn matchesFrom(self: TypedRelation, id: VdrId) bool {
        return self.from_id.eql(id);
    }

    pub fn matchesTo(self: TypedRelation, id: VdrId) bool {
        return self.to_id.eql(id);
    }
};
```

---

### DomainRelationDef (new)

```zig
pub const DomainRelationDef = struct {
    slot: i16 = 64,
    name_offset: i32 = 0,
    name_length: i16 = 0,
    is_symmetric: bool = false,
    is_transitive: bool = false,
    inverse_slot: i16 = -1,
    source_document_id: VdrId = .{},
    registered_at: i32 = 0,
};
```

---

### RelationIndex (new)

```zig
pub const RELATION_TYPE_SLOTS: usize = 128;

pub const RelationIndex = struct {
    by_type_offset: i32 = -1,
    by_type_counts: [RELATION_TYPE_SLOTS]i32 = [_]i32{0} ** RELATION_TYPE_SLOTS,
    by_from_offset: i32 = -1,
    by_from_count: i32 = 0,
    by_to_offset: i32 = -1,
    by_to_count: i32 = 0,
    total_relations: i32 = 0,
    last_rebuilt: i32 = 0,

    pub fn countForType(self: RelationIndex, rel_type: RelationType) i32 {
        const slot = @intFromEnum(rel_type);
        if (slot < 0 or slot >= RELATION_TYPE_SLOTS) return 0;
        return self.by_type_counts[@intCast(slot)];
    }

    pub fn hasType(self: RelationIndex, rel_type: RelationType) bool {
        return self.countForType(rel_type) > 0;
    }

    pub fn isDirty(self: RelationIndex, kb_relations_count: i32) bool {
        return self.total_relations != kb_relations_count;
    }
};
```

---

### CompactionProfile (new)

```zig
pub const CompactionProfile = struct {
    source_document_id: VdrId = .{},
    tables_ingested: i32 = 0,
    rows_ingested: i32 = 0,
    facts_created: i32 = 0,
    relations_created: i32 = 0,
    rules_created: i32 = 0,
    relation_types_used: [RELATION_TYPE_SLOTS]bool = [_]bool{false} ** RELATION_TYPE_SLOTS,
    domain_types_registered: i32 = 0,
    text_bytes_stored: i32 = 0,
    numeric_values_stored: i32 = 0,
    compression_ratio: Q16 = .{},
    ingestion_timestamp: i32 = 0,
    validation_errors: i32 = 0,

    pub fn totalEntities(self: CompactionProfile) i32 {
        return self.facts_created + self.relations_created + self.rules_created;
    }

    pub fn relationTypeCount(self: CompactionProfile) i32 {
        var count: i32 = 0;
        for (self.relation_types_used) |used| {
            if (used) count += 1;
        }
        return count;
    }
};
```

---

### ModelReductionConfig (new)

```zig
pub const ModelReductionConfig = struct {
    base_n_layers: i32 = 16,
    base_mlp_dim: i32 = 5632,
    base_n_heads: i32 = 16,
    base_vocab_size: i32 = 32000,

    reduced_n_layers: i32 = 6,
    reduced_mlp_dim: i32 = 2048,
    reduced_n_heads: i32 = 12,
    reduced_vocab_size: i32 = 8192,

    relation_types_covered: i32 = 0,
    total_typed_relations: i32 = 0,
    total_prolog_rules: i32 = 0,
    estimated_l3_coverage: Q16 = .{},

    use_i16_weights: bool = true,

    pub fn estimatedWeightBytes(self: ModelReductionConfig) i64 {
        const d: i64 = 2048;
        const bytes_per_param: i64 = if (self.use_i16_weights) 2 else 4;
        const n: i64 = self.reduced_n_layers;
        const mlp: i64 = self.reduced_mlp_dim;
        const d_head: i64 = @divTrunc(d, self.reduced_n_heads);
        const qkv = d * (3 * d_head);
        const o = d * d;
        const up = d * mlp;
        const down = mlp * d;
        const per_layer = (qkv + o + up + down) * bytes_per_param;
        const lm_head = d * @as(i64, self.reduced_vocab_size) * bytes_per_param;
        return n * per_layer + lm_head;
    }
};
```

---

### FactTag (replacement — two new variants)

```zig
pub const FactTag = enum(i32) {
    value = 0,
    text = 1,
    reference = 2,
    timestamp = 3,
    enum_tag = 4,
    boolean = 5,
    vector = 6,
    matrix = 7,
    provenance_tag = 8,
    rule_ref = 9,
    grammar_ref = 10,
    counter = 11,
    relation = 12,
    column_schema = 13,
    empty = 255,
};
```

---

### KB (replacement — full struct with new fields)

```zig
pub const KB = struct {
    id: VdrId = .{},
    parent_id: VdrId = .{ .v = -1 },
    name_offset: i32 = 0,
    name_length: i16 = 0,
    path_offset: i32 = 0,
    path_length: i16 = 0,
    walk_id: i32 = 0,

    // Persistent stores
    facts_offset: i32 = 0,
    facts_count: i32 = 0,
    facts_capacity: i32 = 0,
    rules_offset: i32 = 0,
    rules_count: i32 = 0,
    rules_capacity: i32 = 0,
    constraints_offset: i32 = -1,
    constraints_count: i32 = 0,
    connections_offset: i32 = -1,
    connections_count: i32 = 0,
    grammars_offset: i32 = -1,
    grammars_count: i32 = 0,
    iose_offset: i32 = -1,

    // Weight references
    weight_refs_offset: i32 = -1,

    // Typed relations
    relations_offset: i32 = -1,
    relations_count: i32 = 0,
    relations_capacity: i32 = 0,
    relation_index_offset: i32 = -1,

    // Domain relation definitions (only on schema/document KBs)
    domain_rel_defs_offset: i32 = -1,
    domain_rel_defs_count: i32 = 0,

    // Compaction provenance
    compaction_profile_offset: i32 = -1,

    // Live state
    working_data_offset: i32 = -1,
    lru_table_offset: i32 = -1,
    lru_count: i16 = 0,
    counter_table_offset: i32 = -1,
    counter_count: i16 = 0,
    lock_table_offset: i32 = -1,
    lock_count: i16 = 0,
    queue_table_offset: i32 = -1,
    queue_count: i16 = 0,
    stack_table_offset: i32 = -1,
    stack_count: i16 = 0,
    ring_table_offset: i32 = -1,
    ring_count: i16 = 0,
    bitset_table_offset: i32 = -1,
    bitset_count: i16 = 0,

    // New facts since last training
    new_facts_since_training_offset: i32 = -1,
    new_facts_since_training_count: i32 = 0,

    // Children
    children_offset: i32 = -1,
    children_count: i16 = 0,
    children_capacity: i16 = 0,
    mounts_offset: i32 = -1,
    mounts_count: i16 = 0,

    // Training
    training_lock: bool = false,
    training_arena: ?*Arena = null,

    // Metadata
    visibility: i8 = 1,
    frozen: i8 = 0,
    owner_id: VdrId = .{},
    created_at: i32 = 0,
    last_modified: i32 = 0,
    version: i32 = 1,

    // Padded to 256 bytes for cache line alignment.
    // training_arena is the only nullable pointer in the system.

    pub fn isPublic(self: KB) bool {
        return self.visibility == 0;
    }
    pub fn isInternal(self: KB) bool {
        return self.visibility <= 1;
    }
    pub fn isFrozen(self: KB) bool {
        return self.frozen != 0;
    }
    pub fn isRoot(self: KB) bool {
        return self.parent_id.v == -1;
    }
    pub fn isEphemeral(self: KB) bool {
        return self.id.isEphemeral();
    }
    pub fn isTraining(self: KB) bool {
        return self.training_lock;
    }
    pub fn hasRelations(self: KB) bool {
        return self.relations_offset != -1 and self.relations_count > 0;
    }
    pub fn hasRelationIndex(self: KB) bool {
        return self.relation_index_offset != -1;
    }
    pub fn isFromCompaction(self: KB) bool {
        return self.compaction_profile_offset != -1;
    }
    pub fn hasDomainRelDefs(self: KB) bool {
        return self.domain_rel_defs_offset != -1 and self.domain_rel_defs_count > 0;
    }
};
```

---

### LevelStats (replacement)

```zig
pub const LevelStats = struct {
    l1_count: i64 = 0,
    l1_tokens: i64 = 0,
    l2_count: i64 = 0,
    l2_tokens: i64 = 0,
    l3_count: i64 = 0,
    l3_relation_queries: i64 = 0,
    l3_transitive_closures: i64 = 0,
    l3_inverse_lookups: i64 = 0,

    pub fn totalCount(self: LevelStats) i64 {
        return self.l1_count + self.l2_count + self.l3_count;
    }

    pub fn autoTriageNum(self: LevelStats) i64 {
        return self.l3_count;
    }
    pub fn autoTriageDen(self: LevelStats) i64 {
        return self.totalCount();
    }

    pub fn avgTokensPerInteraction(self: LevelStats) Q16 {
        const total_tokens = self.l1_tokens + self.l2_tokens;
        const total_ops = self.totalCount();
        if (total_ops == 0) return Q16.zero();
        return Q16.fromParts(
            @intCast(@divTrunc(total_tokens * Q16.D, total_ops)),
            0,
            0,
        );
    }

    pub fn l3RelationRatio(self: LevelStats) Q16 {
        if (self.l3_count == 0) return Q16.zero();
        const relation_ops = self.l3_relation_queries + self.l3_transitive_closures + self.l3_inverse_lookups;
        return Q16.fromParts(
            @intCast(@divTrunc(relation_ops * Q16.D, self.l3_count)),
            0,
            0,
        );
    }
};
```

---

### SystemConfig (replacement)

```zig
pub const SystemConfig = struct {
    // Hardware
    n_cores: i32 = 0,

    // Model
    model: ModelConfig = .{},

    // Model reduction (advisory)
    model_reduction: ModelReductionConfig = .{},

    // Arenas
    global_arena_bytes: i64 = 3 * 1024 * 1024 * 1024,
    per_core_arena_bytes: i64 = 256 * 1024 * 1024,

    // Limits
    max_total_kbs: i32 = 100_000,
    max_total_facts: i64 = 10_000_000,
    max_total_rules: i32 = 100_000,
    max_total_terms: i64 = 1_000_000,
    max_sessions_per_core: i32 = 500,
    max_ephemeral_kbs_per_session: i32 = 1000,
    max_facts_per_session_kb: i32 = 10000,

    // Sessions
    default_max_turns: i32 = 0,
    auto_snapshot_interval: i32 = 100,

    // HTTP
    http_port: i32 = 1138,

    // Runners
    max_runners: i32 = 64,

    // Safety
    audit_ring_capacity: i32 = 1_000_000,
    default_visibility: i8 = 1,

    // Ingestion
    ingestion: IngestionConfig = .{},

    // Relation index
    relation_index_rebuild_interval: i32 = 100,

    // Seed
    seed: SeedConfig = .{},

    // Sampling
    sampling: SamplingConfig = .{},

    // Prolog
    prolog: PrologConfig = .{},

    // Context
    context: ContextConfig = .{},
};
```

---

### IngestionConfig (replacement — was in ingestion spec, now in types for SystemConfig embedding)

```zig
pub const IngestionConfig = struct {
    target_path: [256]u8 = [_]u8{0} ** 256,
    target_path_length: i32 = 0,
    source_type: SourceType = .published,
    generate_rules: bool = true,
    generate_typed_relations: bool = true,
    detect_numeric: bool = true,
    max_facts_per_table: i32 = 10000,
    freeze_after_ingest: bool = true,
    max_domain_relation_defs: i32 = 64,
};
```

---

### SEED (replacement)

```zig
pub const SEED = struct {
    pub const ROOT: VdrId = .{ .v = 1 };
    pub const SYSTEM: VdrId = .{ .v = 2 };
    pub const OSO: VdrId = .{ .v = 3 };
    pub const CONFIDENCE: VdrId = .{ .v = 4 };
    pub const BUILTINS: VdrId = .{ .v = 5 };
    pub const COMMAND_VOCAB: VdrId = .{ .v = 6 };
    pub const HYGIENE: VdrId = .{ .v = 7 };
    pub const EMBEDDING: VdrId = .{ .v = 8 };
    pub const OUTPUT: VdrId = .{ .v = 9 };
    pub const TEMPLATES: VdrId = .{ .v = 10 };
    pub const SENTENCES: VdrId = .{ .v = 11 };
    pub const FORMATS: VdrId = .{ .v = 12 };
    pub const RELATION_TYPES: VdrId = .{ .v = 13 };
    pub const INGESTION: VdrId = .{ .v = 14 };
    pub const SEED_KB_COUNT: i32 = 14;
};
```

---

### SnapshotHeader (replacement — magic and version bump)

```zig
pub const SNAPSHOT_MAGIC = [4]u8{ 'V', 'D', 'R', 'S' };
pub const SNAPSHOT_VERSION: i32 = 4; // bumped for relation fields in KB
```

---

That covers all struct changes. Summary of what changed and why:

**6 new structs:** `RelationType`, `TypedRelation`, `DomainRelationDef`, `RelationIndex`, `CompactionProfile`, `ModelReductionConfig`. These are the compaction-driven model reduction infrastructure.

**7 modified structs:** `FactTag` (+2 variants), `KB` (+7 fields for relations, domain defs, compaction profile), `LevelStats` (+3 relation counters, +1 method), `SystemConfig` (+3 fields), `IngestionConfig` (+1 field for typed relations), `SEED` (+2 seed KBs), `SnapshotHeader` (version bump).

**Parse-time ingestion structs** (`CompactDocument`, `CompactTable`, `CompactRow`, `CompactCell`, `CompactColumn`, `CompactRelationship`, `CompactLegendEntry`, `CompactSectionEntry`, `ValidationResult`, `ValidationError`) stay in `vdr_ingestion.zig`, not in `vdr_types.zig`. They live in temporary arenas during ingestion and are destroyed after facts and rules are asserted. They don't need to be in the core type file.