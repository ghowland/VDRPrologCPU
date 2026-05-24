## SNK VdrId Resolution — Implementation Notebook

### System Context

SNK (Structured Neural Knowledge) is an exact integer LLM inference engine combined with a Prolog knowledge system. Written in Zig 0.15.1, x86_64 only, CPU only. No floats anywhere. No GPU. No malloc after init. Arena-only memory, NUMA-pinned threads.

The system stores structured knowledge in a tree of KBs (knowledge bases). Every addressable entity — data entries, facts, rules, relations, grammars — has a VdrId, a signed 64-bit integer whose bits encode the complete routing path from the tree root to the item. Resolution is mechanical: extract bits, walk arrays, index into storage.

The system currently loads 59 domain knowledge bases from pipe-delimited compact files (physics, chemistry, biology, programming languages, engineering, trades, literature, etc.), producing 12,756 facts and 12,082 typed relations. It starts up, loads the KBs, spawns HTTP handlers and runners, listens on port 1138, and shuts down cleanly. What it cannot yet do is resolve an arbitrary VdrId to the data it points to and return a typed result. That is the goal of this task.

### What a VdrId Is

A VdrId is a struct wrapping an i64:

```zig
pub const VdrId = struct {
    v: i64 = 0,
    pub const NONE: VdrId = .{ .v = 0 };
};
```

The i64 is a packed struct when viewed through `@bitCast`:

```zig
pub const VdrStructuralId = packed struct(u64) {
    item_id: u20 = 0,        // bits 19-0: index within host KB's typed array
    l5: u8 = LEVEL_SENTINEL,  // bits 27-20: level 5 child index (255=unused)
    l4: u8 = LEVEL_SENTINEL,  // bits 35-28: level 4 child index
    l3: u8 = LEVEL_SENTINEL,  // bits 43-36: level 3 child index
    l2: u8 = LEVEL_SENTINEL,  // bits 51-44: level 2 child index
    l1: u7 = L1_SENTINEL,     // bits 58-52: level 1 child index (127=unused)
    entry_type: u4 = 0,       // bits 62-59: what kind of thing this addresses
    scope: u1 = 0,            // bit 63: 0=global, 1=session
};
```

The scope bit partitions the address space: non-negative i64 values are global (persistent), negative values are session-local (ephemeral, die with session). Zero is the NONE sentinel.

The entry_type field (4 bits, 16 values) identifies what storage the item lives in:

```zig
pub const KBEntryType = enum(u4) {
    kb = 0,             // KB node itself
    data,               // Raw data (KBData struct)
    data_q335,          // High-precision data (KBDataQ335 struct)
    fact,               // Q16 value with Provenance
    rule,               // Prolog rule
    constraint,         // Prolog constraint rule
    grammar,            // Grammar rule (parse/generate)
    lru,                // Least Recently Used set
    counter,            // Counter
    lock,               // Lock
    queue,              // FIFO
    stack,              // Stack
    ring,               // Ring buffer
    bitset,             // Bitset
    iose,               // Input/Output/Side-Effects declaration
    relation,           // Typed relation
};
```

All 16 slots are occupied.

The level fields (L1 through L5) encode the tree path from root to the host KB. L1 is 7 bits (127 usable slots, 127 = sentinel). L2 through L5 are 8 bits each (255 usable, 255 = sentinel). The tree walk terminates at the first sentinel. Maximum depth is 5 levels.

The item_id field (20 bits, u20) is a monotonic counter per entry type per host KB. Maximum 1,048,575 items per type per KB. Never decremented, never reused.

### How Resolution Works

Given a VdrId, resolution proceeds in fixed steps:

1. **Bitcast.** `id.structural()` converts i64 to VdrStructuralId via `@bitCast`. Zero cost.

2. **Scope selection.** If scope = 0, start at the global root KB. If scope = 1, start at the session root KB.

3. **Tree walk.** L1 indexes into the starting KB's children array → L1 KB. L2 indexes into L1 KB's children array → L2 KB. Repeat for L3, L4, L5. Stop at the first sentinel value. The KB you land on is the host. Worst case: 5 array dereferences, ~25 nanoseconds.

4. **Entry type dispatch.** The 4-bit entry_type tells you which storage to look in on the host KB. For `.data`, the item_id is a direct array index into `kb.data[item_id]`. For other types, the KbLookup hashmaps map item_id to array slot.

5. **Item retrieval.** Index into the typed array. You have the item.

### The KB Structure (Relevant Fields)

```zig
pub const KB = struct {
    id: VdrId = .{},
    parent_id: VdrId = .{ .v = -1 },
    name_offset: i32 = 0,
    name_length: i16 = 0,
    path_offset: i32 = 0,
    path_length: i16 = 0,
    walk_id: i32 = 0,

    // Direct-indexed data arrays
    data: []KBData align(64) = &[_]KBData{},
    data_q335: []KBDataQ335 align(64) = &[_]KBDataQ335{},

    // Lookup maps for other entry types (LookupId → array slot)
    lookup: KbLookup = .{},

    // Children array for tree walk
    children: []?*KB = &[_]?*KB{},

    // Per-entry-type monotonic counters
    next_data_id: LookupId = 0,
    next_data_q335_id: LookupId = 0,
    next_fact_id: LookupId = 0,
    next_rule_id: LookupId = 0,
    // ... one per entry type
};
```

### The KbLookup Structure

```zig
pub const KbLookup = struct {
    facts: ?std.AutoHashMap(LookupId, i32) = null,
    rules: ?std.AutoHashMap(LookupId, i32) = null,
    constraints: ?std.AutoHashMap(LookupId, i32) = null,
    grammars: ?std.AutoHashMap(LookupId, i32) = null,
    relations: ?std.AutoHashMap(LookupId, i32) = null,
    domain_relations: ?std.AutoHashMap(LookupId, i32) = null,
    lru: ?std.AutoHashMap(LookupId, i32) = null,
    counters: ?std.AutoHashMap(LookupId, i32) = null,
    locks: ?std.AutoHashMap(LookupId, i32) = null,
    queues: ?std.AutoHashMap(LookupId, i32) = null,
    stacks: ?std.AutoHashMap(LookupId, i32) = null,
    rings: ?std.AutoHashMap(LookupId, i32) = null,
    bitsets: ?std.AutoHashMap(LookupId, i32) = null,
    iose: ?std.AutoHashMap(LookupId, i32) = null,
    children: ?std.AutoHashMap(LookupId, i32) = null,
};
```

Each map is optional — null if the KB has no entries of that type. Maps are backed by the arena allocator (no heap). LookupId is u20, the item_id from the VdrId.

Note: `.data` and `.data_q335` entry types do NOT use KbLookup hashmaps. They are direct-indexed arrays on the KB struct: `kb.data[item_id]` and `kb.data_q335[item_id]`. The item_id IS the array index.

### The Data Types

**KBData** — the primary data record (~880 bytes per entry):

```zig
pub const KBData = struct {
    id: VdrId = .{},                          // self-referencing address
    v_0: Q16 = .{}, v_0_column: i8 = -1,     // up to 4 extracted numeric values
    v_1: Q16 = .{}, v_1_column: i8 = -1,     // with column back-references
    v_2: Q16 = .{}, v_2_column: i8 = -1,     // (-1 = unused)
    v_3: Q16 = .{}, v_3_column: i8 = -1,
    text_column_0: ?KBDataValue = null,       // 9 text/value columns
    text_column_1: ?KBDataValue = null,
    text_column_2: ?KBDataValue = null,
    text_column_3: ?KBDataValue = null,
    text_column_4: ?KBDataValue = null,
    text_column_5: ?KBDataValue = null,
    text_column_6: ?KBDataValue = null,
    text_column_7: ?KBDataValue = null,
    text_column_8: ?KBDataValue = null,
    timestamp: ?DeepTime = null,
    timestamp_duration: ?DeepTime = null,
    timestamp_scope: KBDataDurationScope = .unknown,
};
```

Each text column is a nullable KBDataValue:

```zig
pub const KBDataValue = struct {
    v: Q16 = .{},
    text: ?TextSmall = null,  // if non-null, this column is text; if null, it's Q16

    pub fn isText(self: KBDataValue) bool { return self.text != null; }
    pub fn isValue(self: KBDataValue) bool { return self.text == null; }
};
```

TextSmall is a fixed 64-byte buffer:

```zig
pub const TextSmall = struct {
    text: [64]u8 = [_]u8{0} ** 64,
    len: usize = 0,
};
```

**KBDataQ335** — same structure as KBData but with Q335 values instead of Q16 for high-precision numeric data (fundamental constants, etc.). ~1,800 bytes per entry.

**Q16** — the primary arithmetic type:

```zig
pub const Q16 = struct {
    v: i32 = 0,    // integer value
    r0: i16 = 0,   // remainder from divTrunc by D (65536)
    r1: i16 = 0,   // sub-remainder from cross-terms
};
```

D = 65536 implicit. Remainder is exact unresolved structure, not error. Never discarded.

**Fact** — interpreted knowledge (48 bytes):

```zig
pub const Fact = struct {
    tag: FactTag,          // what kind of fact
    value: Q16,            // the quantized value
    provenance: Provenance, // where this came from
};
```

**Provenance** — source tracking:

```zig
pub const Provenance = struct {
    source_type: i32 = @intFromEnum(SourceType.unknown),
    source_id: VdrId = .{},           // VdrId pointing to source (e.g., a KBData entry)
    confidence: Q16 = .{},
    timestamp: i32 = 0,
    derivation_rule_id: VdrId = .{},  // VdrId of the rule that derived this, if any
    capability_level: i32 = 0,
};
```

**TypedRelation** — edge between two entities (48 bytes):

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

### The VdrValue Return Type

This is the result of resolving a VdrId. It carries the original VdrId, the entry type, a success flag, and exactly one non-null typed pointer:

```zig
pub const VdrValue = struct {
    id: VdrId = VdrId.NONE,
    entry_type: KBEntryType = .kb,
    ok: bool = false,

    kb: ?*KB = null,
    fact: ?*Fact = null,
    rule: ?*Rule = null,
    constraint: ?*Fact = null,
    grammar: ?*Grammar = null,
    lru: ?*Fact = null,
    counter_entry: ?*Fact = null,
    lock: ?*Fact = null,
    queue: ?*Fact = null,
    stack: ?*Fact = null,
    ring: ?*Fact = null,
    bitset: ?*Fact = null,
    iose: ?*IoSe = null,
    relation: ?*TypedRelation = null,

    pub fn failed() VdrValue { return .{}; }

    pub fn fromFact(id: VdrId, f: *Fact) VdrValue {
        return .{ .id = id, .entry_type = .fact, .ok = true, .fact = f };
    }
    pub fn fromRule(id: VdrId, r: *Rule) VdrValue {
        return .{ .id = id, .entry_type = .rule, .ok = true, .rule = r };
    }
    pub fn fromKb(id: VdrId, k: *KB) VdrValue {
        return .{ .id = id, .entry_type = .kb, .ok = true, .kb = k };
    }
    // ... one factory per entry type, each takes VdrId as first arg
};
```

Note: VdrValue currently lacks `data: ?*KBData` and `data_q335: ?*KBDataQ335` fields. These need to be added for `.data` and `.data_q335` entry types.

### The Task

#### Goal

Implement `getVdrValue(root_kb: *KB, session_root_kb: ?*KB, id: VdrId) VdrValue` that:

1. Takes any VdrId
2. Walks the KB tree to find the host KB
3. Dispatches on entry_type to the correct storage
4. Returns a VdrValue with the typed pointer populated

#### Specifically for this task, verify that:

1. All 12,756 facts loaded from the 59 compact files are properly inserted into their host KB's KbLookup.facts AutoHashMap, keyed by LookupId
2. A `getVdrValue` call with a fact's VdrId returns a VdrValue where `.ok == true`, `.entry_type == .fact`, and `.fact != null`
3. A `getVdrValue` call with an invalid VdrId returns `VdrValue.failed()`

#### What needs to happen

**Step 1: Add missing VdrValue fields.** Add `data: ?*KBData` and `data_q335: ?*KBDataQ335` fields with corresponding factory methods `fromData` and `fromDataQ335`.

**Step 2: Implement getVdrValue.** The function:

```
fn getVdrValue(root_kb: *KB, session_root_kb: ?*KB, id: VdrId) VdrValue {
    if id is NONE → return failed()
    
    extract structural fields from id
    select starting KB based on scope bit
    
    walk L1 → L2 → L3 → L4 → L5, stopping at sentinel
    if any level's child is null → return failed()
    
    host_kb = the KB we landed on
    
    switch on entry_type:
        .kb → return fromKb(id, host_kb)
        .data → bounds check item_id against host_kb.data.len
                 return fromData(id, &host_kb.data[item_id])
        .data_q335 → same pattern against data_q335 array
        .fact → look up item_id in host_kb.lookup.facts hashmap
                if found → index into facts array → return fromFact(id, fact_ptr)
        .rule → look up in host_kb.lookup.rules → fromRule
        .relation → look up in host_kb.lookup.relations → fromRelation
        ... same pattern for each entry type
        
    return failed()  // entry type has no storage on this KB
}
```

**Step 3: Verify fact loading.** During or after ingestion, confirm:

- Each KB's `lookup.facts` hashmap is initialized (not null)
- Each loaded fact has an entry in the hashmap: `lookup.facts.get(lookup_id) != null`
- The hashmap value (i32) is a valid index into the facts array
- Total facts across all KBs equals 12,756

**Step 4: Write tests.** Test cases:

- `getVdrValue` with VdrId.NONE returns `failed()`
- `getVdrValue` with a valid fact VdrId returns `.ok == true, .entry_type == .fact, .fact != null`
- `getVdrValue` with a valid KB VdrId returns `.ok == true, .entry_type == .kb, .kb != null`
- `getVdrValue` with an out-of-range item_id returns `failed()`
- `getVdrValue` with a valid tree path but wrong entry_type returns `failed()`
- Iterate all loaded facts, call `getVdrValue` on each, verify all return `.ok == true`

### Current System State

The system boots, loads config, allocates arenas, loads 59 compact files into KB tree, populates facts and relations, spawns threads, and serves HTTP. The loading output confirms:

```
total facts:     12756
total relations: 12082
```

KBs are created with correct tree paths. Facts are populated into each KB. The question is whether the KbLookup hashmaps are correctly populated during ingestion and whether the getVdrValue resolution path correctly traverses the tree and dispatches to the right storage.

### Files Involved

- `vdr_types.zig` — all type definitions (VdrId, VdrStructuralId, KBEntryType, KB, KbLookup, Fact, VdrValue, etc.)
- `vdr_kb_store.zig` — KB CRUD, tree management, fact insertion
- `vdr_ingestion.zig` — compact file parsing, fact assertion, relation assertion
- `vdr_test.zig` — test suite

### Zig 0.15.1 Notes

- Use `std.debug.print` for output (not std.io.getStdOut)
- Build: `.root_module = b.createModule(...)` pattern
- Integer timestamps only
- All types defined in and imported from `vdr_types.zig`
- No float anywhere
- Arena allocator backs AutoHashMap via vtable: `arena.allocator()` returns `std.mem.Allocator`
