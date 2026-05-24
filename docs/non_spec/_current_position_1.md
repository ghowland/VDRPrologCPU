## SNK (Structured Neural Knowledge) — Technical Specification v0.6

### System Overview

SNK is an exact integer knowledge system written in Zig 0.15.1, targeting x86_64. CPU only. No floats. No GPU. No malloc after init. Arena-only memory. The system loads structured knowledge from pipe-delimited compact files, stores it in a tree of knowledge bases addressable by structural 64-bit integer IDs, and serves queries over HTTP.

### Architecture

The system consists of 14 source files:

| File | Role | Lines (approx) |
|------|------|---------|
| vdr_types.zig | All type definitions | ~1800 |
| root.zig | Main entry, KB loading, data population, verification | ~500 |
| vdr_compact_loader.zig | Parses .md compact files into arena structures | ~450 |
| vdr_kb_config.zig | Loads/saves kb.json mapping dotted paths to files | ~200 |
| vdr_config.zig | Loads config.json into SystemConfig | ~130 |
| vdr_arena.zig | Creates/destroys page-allocated arenas | ~35 |
| resetable_memory.zig | Scratch arena with reset capability and std.mem.Allocator vtable | ~70 |
| vdr_http.zig | HTTP listener, connection handling, response writing | ~200 |
| vdr_http_accepter.zig | Connection ring buffer, handler thread pool | ~100 |
| vdr_http_handler.zig | Route dispatch, runner submission | ~60 |
| vdr_runner_pool.zig | Per-core work rings, runner threads | ~150 |
| text_big.zig | 100KB fixed-size text buffer with string operations | ~500 |
| text_small.zig | 64-byte fixed-size text buffer with string operations | ~500 |
| time_deep.zig | DeepTime u64 millisecond timestamps, 100M year anchor | ~40 |

### Boot Sequence

1. Load `config.json` into SystemConfig (model params, arena sizes, limits, HTTP port)
2. Allocate global arena from page_allocator (default 1 GB)
3. Allocate resetable scratch memory (1 MB)
4. Load `kb.json` mapping (dotted paths → compact file paths)
5. Scan `data/kb_raw/` directory, load all .md compact files into arena
6. Create KB tree with structural VdrIds assigned from dotted paths
7. Populate facts and relations into KB lookup hashmaps
8. Populate KBData columns from compact row text
9. Verify all KBData entries round-trip through getVdrValue
10. Print sample data entry
11. Spawn HTTP server on port 1138 with 4 handler threads and 4 runner threads
12. Wait for shutdown signal (GET /shutdown)
13. Join all threads, free arenas, exit

### Addressing: VdrId

Every addressable entity has a VdrId — a signed 64-bit integer whose bits encode the complete routing path:

```
bit 63:     scope (0=global, 1=session)
bits 62-59: entry_type (u4, 16 types)
bits 58-52: L1 (u7, 127 usable slots, 127=sentinel)
bits 51-44: L2 (u8, 255 usable, 255=sentinel)
bits 43-36: L3 (u8, 255 usable, 255=sentinel)
bits 35-28: L4 (u8, 255 usable, 255=sentinel)
bits 27-20: L5 (u8, 255 usable, 255=sentinel)
bits 19-0:  item_id (u20, 1,048,575 per type per KB)
```

VdrId is a struct wrapping i64 with methods: `structural()` bitcasts to VdrStructuralId packed struct at zero cost. `makeKb()` and `makeItem()` construct VdrIds from components. `makeChildKb()` produces child KB ids. `depth()` counts non-sentinel levels (0-5). `sameSubtreeL1/L2/L3()` test subtree membership by field comparison. `entryType()` and `lookupId()` extract fields.

Non-negative values are global (persistent). Negative values are session (ephemeral). Zero is NONE sentinel.

### Entry Types

All 16 u4 slots are occupied:

**Storage:** kb (0), data (1), data_q335 (2), fact (3), rule (4), constraint (5), grammar (6)

**Computation:** lru (7), counter (8), lock (9), queue (10), stack (11), ring (12), bitset (13)

**Structure:** iose (14), relation (15)

### Arithmetic: Q16

Primary arithmetic type. D = 65536, implicit, never stored.

```zig
Q16 { v: i32, r0: i16, r1: i16 }
```

- v: integer value
- r0: exact remainder from divTrunc by D
- r1: sub-remainder from cross-terms

Remainder is exact unresolved structure, not error. Implemented operations: add (with r1→r0→v carry chain), sub (with borrow chain), mul (i64 widening, divTrunc/mod, cross-term r1), div (widened numerator, divTrunc/mod, r1 from r0 widening), compare (lexicographic v→r0→r1), eql (all three fields).

Q32 (i64/i32/i32, D=2³²) and Q335 ([6]i64 × 5 components) exist for escalation and physics precision.

### KB Tree

KBs are allocated in the global arena. Each KB gets a structural VdrId derived from its dotted path:

- `root.edu.physics` → L1=0, L2=0, L3-L5=sentinel
- `root.edu.chemistry` → L1=0, L2=1, L3-L5=sentinel
- `root.programming.algorithms` → L1=1, L2=0, L3-L5=sentinel
- `root.edu.mathematics.foundation` → L1=0, L2=11, L3=0, L4-L5=sentinel

L1 indices are assigned by first-seen order of the segment after "root." (edu=0, programming=1, engineering=2, etc.). L2 indices are per-L1, assigned by first-seen order. L3 indices are per-L1+L2 pair, counted from previously seen KBs with the same L1+L2.

Segment tracking uses stack-allocated arrays (127 L1 slots × 64-byte names, 127×255 L2 slots × 64-byte names).

### KB Structure

Each KB struct holds:

- `id: VdrId` — structural address
- `data: ?std.array_list.Managed(KBData)` — raw data entries, direct-indexed by item_id
- `data_q335: ?std.array_list.Managed(KBDataQ335)` — high-precision data entries
- `facts: ?std.array_list.Managed(Fact)` — interpreted knowledge
- `rules: ?std.array_list.Managed(Rule)` — Prolog rules
- `constraints: ?std.array_list.Managed(Constraint)` — allow/deny rules
- `grammars: ?std.array_list.Managed(GrammarRule)` — parse/generate rules
- `lru_entries`, `counters`, `locks`, `queues`, `stacks`, `rings`, `bitsets` — computation types
- `iose_entries: ?std.array_list.Managed(IoSe)` — I/O/side-effects declarations
- `relations: ?std.array_list.Managed(TypedRelation)` — typed edges
- `lookup: KbLookup` — per-entry-type AutoHashMap(LookupId, i32) for non-direct-indexed types
- Per-entry-type monotonic LookupId counters (`next_fact_id`, `next_rule_id`, etc.)
- `mintLookupId(entry_type)` — returns next u20 for that type, increments counter

All Managed array lists are nullable — null until first entry of that type. Backed by the global arena allocator via vtable.

### KBData — Raw Data Record

Each row from a compact table becomes a KBData entry:

```zig
KBData {
    id: VdrId,                          // self-referencing address
    v_0..v_3: Q16 + i8 column ref,     // 4 numeric slots with source column (-1=unused)
    text_column_0..8: ?KBDataValue,     // 9 text/value columns
    timestamp: ?DeepTime,               // millisecond timestamp
    timestamp_duration: ?DeepTime,      // duration for ranges
    timestamp_scope: KBDataDurationScope, // rendering granularity
}
```

KBDataValue is either text (64-byte TextSmall buffer with length) or Q16 numeric. Discrimination by `text != null`.

KBData entries are direct-indexed: `kb.data.?.items[item_id]`. No hashmap needed. The VdrId's item_id IS the array index. The `mintLookupId(.data)` method returns the current `.items.len` as the LookupId, so append order matches index.

### KBDataQ335 — High-Precision Data Record

Same structure as KBData but v_0 through v_3 are Q335 instead of Q16. For fundamental constants exceeding i32 range. Entry type `.data_q335`, stored in `kb.data_q335`.

### Compact Loading Pipeline

The compact loader (`vdr_compact_loader.zig`) parses .md files containing pipe-delimited tables:

1. Reads file (max 100KB) into stack buffer
2. Scans lines for table headers: `# table_name(col1|col2|col3)`
3. Stores column names per table (up to 32 columns, 64 tables)
4. For data rows, copies full pipe-delimited line into arena, records offset/length
5. Extracts entity ID (text before first pipe) separately
6. Parses `# relationships(from|rel|to)` section into RawRelationship structs
7. Parses `# relation_mapping(doc_rel|canonical_rel|notes)` section
8. Resolves relationship canonical types via `nameToRelationType()` (120+ relation types) plus per-file mapping table
9. Skips `# decode_legend` sections

Output: `LoadResult` with tables (TableInfo[]), relationships (RawRelationship[]), mappings (RelationMapping[]), counts, and arena text usage.

### KB Population

Three phases populate KB data from LoadResults:

**Phase 1: `populate_kb_data`** — mints LookupIds for facts and relations, inserts into KbLookup hashmaps. Facts keyed by LookupId, relations filtered to exclude unknown canonical types.

**Phase 2: `populate_kb_data_columns`** — for each table row in each KB's LoadResult, creates a KBData entry. Splits the raw pipe-delimited row text on `|`, skips column 0 (entity ID), copies remaining columns into text_column_0 through text_column_8 as KBDataValue with TextSmall. Truncates at 64 bytes per column. Appends to `kb.data` Managed array list. Mints VdrId with `entry_type = .data` using `VdrId.makeItem(kb.id, .data, lid)`.

**Phase 3: `verify_kb_data_lookup`** — iterates every KBData entry in every KB, calls `getVdrValue()` with its id, verifies `.ok == true`, `.entry_type == .data`, `.data != null`, and `data.id.eql(original.id)`. Also counts entries with text_column_0 populated.

### VdrValue — Resolution Return Type

Resolving a VdrId produces a VdrValue carrying the original VdrId, entry type, success flag, and exactly one non-null typed pointer:

```zig
VdrValue {
    id: VdrId,
    entry_type: KBEntryType,
    ok: bool,
    kb: ?*KB, data: ?*KBData, data_q335: ?*KBDataQ335,
    fact: ?*Fact, rule: ?*Rule, constraint: ?*Constraint,
    grammar: ?*GrammarRule, lru: ?*LruEntry, counter_entry: ?*CounterEntry,
    lock: ?*LockEntry, queue: ?*QueueEntry, stack: ?*StackEntry,
    ring: ?*RingEntry, bitset: ?*BitsetEntry, iose: ?*IoSe,
    relation: ?*TypedRelation,
}
```

Factory methods (`fromData`, `fromFact`, `fromKb`, etc.) each take VdrId as first argument to keep the address with the data.

### getVdrValue Resolution

Current implementation:

1. Check for VdrId.NONE → return failed
2. Extract structural fields via bitcast
3. Linear scan of config entries, match KB by L1-L5 field comparison
4. Dispatch on entry_type:
   - `.kb` → return the KB itself
   - `.data` → bounds-check item_id against `kb.data.?.items.len`, direct index
   - `.data_q335` → same pattern against data_q335
   - `.fact` → lookup item_id in `kb.lookup.facts` hashmap
   - `.relation` → lookup item_id in `kb.lookup.relations` hashmap
   - others → return failed (storage not yet populated)

The KB-finding step is currently O(n) over config entries. Future: tree walk via children arrays replaces this with O(depth) array dereferences.

### Relation Types

120+ relation types in the RelationType enum, organized into 7 categories (structural 1000+, identity 2000+, knowledge 3000+, agency 4000+, logic 5000+, grammar 6000+, toolchain 7000+) plus domain-registerable slots at 1,000,000+.

Each type declares algebraic properties via methods: `inverse()` returns the reverse relation type, `isSymmetric()` returns true for bidirectional types (16 symmetric types), `isTransitive()` returns true for chainable types (15 transitive types).

TypedRelation struct (48 bytes): rel_type, from_id (VdrId), to_id (VdrId), provenance, strength (Q16), scope_kb_id.

### DeepTime

u64 millisecond timestamps anchored 100 million years before CE. Covers geological time through far future at millisecond precision. Conversion functions: `fromUnixMillis`, `toUnixMillis`, `fromUnixSeconds`, `toUnixSeconds`. The Big Bang at 13.8 billion years does not fit at millisecond resolution.

KBDataDurationScope enum provides 12 rendering granularities: millisecond through million_year.

### HTTP Server

Listens on port 1138 (configurable). Non-blocking accept via `posix.poll` with 100ms timeout. Connection dispatch via atomic ring buffer to 4 handler threads. Handlers parse HTTP/1.1 requests, dispatch to handler module. Runner pool (4 runners) processes work via per-core atomic ring buffers. Currently echoes input as JSON.

Routes: `/run` submits to runner pool, `/shutdown` signals clean shutdown, all others return 404.

### Memory Layout

Global arena: 1 GB default. After loading 59 KBs with 12,526 facts, 11,969 relations, and 12,526 KBData entries: ~223 MB used, ~851 MB free.

Resetable scratch: 1 MB for TextBig formatting and std.array_list.Managed operations in HTTP path.

Arena allocator exposes `std.mem.Allocator` interface via vtable: alloc delegates to bump pointer, resize returns false, remap returns null, free is no-op. This backs all `std.AutoHashMap` and `std.array_list.Managed` instances.

### Current Data

59 compact files loaded from `data/kb_raw/`, totaling ~3.5 MB of source markdown across domains: physics, chemistry, biology, astronomy, climate, geography, zoology, neuroscience, anatomy, homeostasis, body mechanics, mathematics (foundation + logic), economics, philosophy, history (human + military tactics), law, cognition, movement, programming (algorithms, data structures, zig, python, prolog, sqlite, c/python/zig interop, databases, FSMs), engineering (electronics, power grid, radio/cellular, mechanical, construction, architecture), trades (blacksmithing, masonry, fabrication, animal husbandry, gardening, forestry, cooking, camping), language (english grammar, phrasing, vocabulary, connections), literature (classical, fantasy, heroic adventure, dramatic writing, art), business (accounting, project management, troubleshooting), system (scoring, builtins, spec, types).

Total loaded: 12,526 facts, 11,969 typed relations, 12,526 KBData entries. All 12,526 KBData entries verified to round-trip through getVdrValue.

### Verified Working

- Config loading from JSON
- Arena allocation and allocator vtable
- Compact file parsing (tables, rows, relationships, relation mappings)
- Relation type resolution (120+ types with per-file mapping fallback)
- KB tree creation with structural VdrId assignment from dotted paths
- Fact and relation LookupId minting and hashmap population
- KBData column population from pipe-delimited row text
- VdrId construction via `makeItem`, `makeKb`, `makeChildKb`
- VdrId structural field extraction via bitcast
- getVdrValue resolution for .kb, .data, .data_q335, .fact, .relation entry types
- Full round-trip verification: VdrId → getVdrValue → VdrValue.data → id match
- HTTP server with handler/runner thread pools
- Clean shutdown via /shutdown endpoint
