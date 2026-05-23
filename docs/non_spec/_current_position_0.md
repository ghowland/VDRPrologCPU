## VDR-Prolog Kernel — Current Implementation Specification

### Overview

An HTTP server with a layered thread architecture backed by an arena-allocated knowledge base system. Accepts POST and GET requests, routes work through handler threads to pinned runner threads via atomic ring buffers, returns responses. On startup, loads structured domain knowledge from compact files on disk, maps them to a hierarchical KB tree via a JSON configuration, creates KB structs with per-entry-type lookup maps, and populates those maps with LookupId-addressed facts and relations. Written in Zig 0.15.1, x86_64, linked against libc.

### Files

| File | Role |
|---|---|
| `root.zig` | Entry point. Loads config, creates global arena, creates resetable memory, loads KB config, loads compact files, creates KB tree, populates KB data, spawns HTTP thread, waits for shutdown |
| `vdr_config.zig` | Reads `config.json`, parses JSON into `SystemConfig`, strict validation, exits 1 on failure |
| `vdr_types.zig` | All type definitions: Q16, VdrId, VdrStructuralId, KBEntryType, LookupId, KB, KbLookup, Fact, Rule, Term, TypedRelation, RelationType, Session, Grant, Arena, and all supporting types |
| `vdr_arena.zig` | Arena lifecycle: `create(size) -> *Arena`, `destroy(*Arena)`. Backed by `page_allocator` |
| `resetable_memory.zig` | Module-level singleton arena for temporary allocations. Create/destroy/reset/lock. Exposes `std.mem.Allocator` interface via vtable |
| `text_big.zig` | `TextBig` — 100KB fixed stack buffer with length tracking. String operations: init, append, slice, replace, trim, split, escape, format |
| `vdr_compact_loader.zig` | Parses `.md` VDR-COMPACT files into arena-allocated structures. Table headers, data rows, relationships, relation mappings. Returns `LoadResult` in arena |
| `vdr_kb_config.zig` | Loads and saves `kb.json` mapping dotted tree paths to compact source files. Manages unmapped file assignment. Holds KB and LoadResult pointers per entry |
| `vdr_http.zig` | HTTP listener. Binds to configured port, polls with 100ms timeout, accepts connections, dispatches to accepter. Parses HTTP requests, writes responses |
| `vdr_http_accepter.zig` | Connection dispatch layer. Owns handler thread pool and connection ring buffer. Distributes connections to handlers via atomic CAS |
| `vdr_http_handler.zig` | Request routing. `/shutdown` sets flag, `/run` submits to runner pool, others get 404 |
| `vdr_runner_pool.zig` | Runner threads. Per-core incoming/outgoing atomic ring buffers. Currently echo with JSON escaping |

### Startup Sequence

The kernel starts in `root.zig` and executes the following steps in order.

Configuration loading reads `config.json` and populates a `SystemConfig` struct with hardware settings (core count, port), arena sizes, limits (max KBs, facts, rules, terms, sessions), model configuration, sampling parameters, and Prolog configuration. Bad config causes exit 1.

Global arena allocation creates a 1GB contiguous memory region via `page_allocator`. All subsequent allocations come from this arena by bumping a cursor. No free, no reuse until reset.

Resetable memory creates a 1MB singleton arena for HTTP response formatting. Exposes an `std.mem.Allocator` vtable that bumps its cursor. Free is a no-op.

KB config loading reads `kb.json` if it exists, parsing dotted-path-to-file-path mappings. If no file exists, starts with an empty config. The config struct and its entry array are allocated in the global arena.

Compact file loading scans `data/kb_raw/` for all `.md` files. For each file, checks if it has a mapping in `kb.json`. Unmapped files get assigned temporary paths (`root.0`, `root.1`, etc.) and `kb.json` is updated on disk. Each file is read into a stack buffer (max 100KB), parsed line by line extracting table headers with column schemas, data rows stored as byte ranges in arena, relationships with comma-separated target expansion, and relation-type mappings. Relationship names are resolved to canonical `RelationType` enum values. Results are stored as `LoadResult` structs in arena memory.

KB tree creation allocates a `KB` struct in arena for each config entry. Initializes `AutoHashMap(LookupId, i32)` for facts and relations on each KB using the arena's allocator interface.

KB data population walks each config entry that has both a `LoadResult` and a `KB`. For each row across all tables in the file, mints a `LookupId` via the KB's monotonic fact counter and inserts the mapping into the KB's facts hash map. For each resolved relationship, mints a relation `LookupId` and inserts into the relations hash map.

HTTP server spawns on an unpinned thread after all KB work completes. The main thread blocks on join until shutdown.

### Thread Architecture

One listener thread (unpinned) runs `vdr_http.run()`. Polls for incoming connections with 100ms timeout, pushes accepted sockets to the accepter's connection ring.

Four handler threads (unpinned) pop connections from the accepter ring using atomic CAS. Parse HTTP, route by path, submit work to runners, spin-wait for responses, write HTTP responses, close sockets.

Four runner threads (unpinned, will be pinned) pop work requests from per-core incoming rings, execute work (currently echo with JSON escaping), push responses to per-core outgoing rings.

### Ring Buffers

Three sets of atomic ring buffers, all 64 slots, all using `std.atomic.Value(usize)` with acquire/release ordering.

Accepter ring: single producer (listener), multi-consumer (handlers CAS to pop). Runner incoming rings: one per core, handler pushes, runner pops. Runner outgoing rings: one per core, runner pushes, handler polls by request_id.

### Memory Model

Global arena: 1GB allocated at startup via `page_allocator`. Holds all KB structs, fact data, relationship data, LoadResults, config entries, text from compact files, and AutoHashMap backing arrays. Bump pointer allocation. No free. Destroyed on shutdown.

Resetable memory: 1MB singleton for HTTP response formatting. Exposes `std.mem.Allocator` via vtable. Reset clears cursor to zero.

Stack memory: `TextBig` (100KB) structs live on thread stacks for request/response bodies and file reading. No heap allocation for these.

Arena allocator interface: the `Arena` struct exposes an `allocator()` method returning `std.mem.Allocator` with a vtable that delegates `alloc` to `arena.alloc`, returns false for resize, null for remap, and no-ops free. This allows `std.AutoHashMap` to allocate its backing arrays from the arena. When a hash map resizes, the new backing array is allocated from the arena and the old one is abandoned.

### Type System

Q16: exact rational arithmetic with implicit denominator D=65536. Fields: v (i32), r0 (i16), r1 (i16). Implemented operations: add with r1-to-r0-to-v carry chain, sub with borrow, mul with i64 widening and cross-term remainder capture, div with widened numerator and sub-remainder, compare (lexicographic v then r0 then r1), equality. Q32 and Q335 types defined but operations not implemented.

VdrId: signed i64 with structural bit packing via `VdrStructuralId` packed struct. Bit 63 is scope (0=global, 1=session). Bits 62-59 are entry type (4-bit KBEntryType). Bits 58-52 are level 1 (7-bit, 127 sentinel). Bits 51-44, 43-36, 35-28, 27-20 are levels 2-5 (8-bit each, 255 sentinel). Bits 19-0 are item_id (LookupId, u20). Methods: `structural()` bitcasts to packed struct, `fromStructural()` bitcasts back, `makeKb()` constructs a KB VdrId from scope and level values, `makeItem()` constructs an item VdrId from a host KB's VdrId plus entry type and LookupId, `makeChildKb()` creates a child KB VdrId at the next available depth, `depth()` counts non-sentinel levels, `sameSubtreeL1/L2/L3()` compares level prefixes.

KBEntryType: 4-bit enum with 15 types — kb, fact, rule, constraint, grammar, lru, counter, lock, queue, stack, ring, bitset, iose, relation, domain_relation.

LookupId: u20, max value 1,048,575. Per-entry-type monotonic counter on each KB.

KB: struct with identity (VdrId, parent_id, name, path), persistent store offsets and counts (facts, rules, constraints, grammars, relations, domain relation defs), weight references, live state offsets (lru, counters, locks, queues, stacks, rings, bitsets), children management, training state, metadata (visibility, frozen, owner, timestamps, version), functor index, FSM, behavior set, 14 per-entry-type monotonic LookupId counters, and a KbLookup struct.

KbLookup: struct with nullable `std.AutoHashMap(LookupId, i32)` fields for facts, rules, constraints, grammars, relations, domain_relations, lru, counters, locks, queues, stacks, rings, bitsets, iose, and children. Each is null until initialized. The i32 value maps to the index in the corresponding typed array.

RelationType: enum(i32) with approximately 130 variants across structural, identity, knowledge, agency, condition, grammar, toolchain, and domain categories. Methods: `inverse()`, `isSymmetric()`, `isTransitive()`.

TypedRelation: struct with rel_type, from_id, to_id, provenance, strength (Q16), scope_kb_id.

All remaining types (Fact, Rule, Term, Binding, Grammar, Session, Grant, Command, AuditEntry, Runner, Provenance, WeightMatrix, GemmCache, ModelConfig, etc.) are defined with defaults but not yet instantiated or populated by the running system.

### Compact File Format

Source files are pipe-delimited markdown with a consistent structure. Table headers use the format `# table_name(col1|col2|col3)`. Data rows follow as `value1|value2|value3`. A relationships section uses `from|rel|to` format where the to field can be comma-separated for expansion into multiple edges. A relation_mapping section maps document-local relation names to canonical names. A decode_legend section contains freeform documentation and is skipped during parsing.

The parser handles LLM-generated variation: comment lines with parentheses but no pipes in the column area are skipped, malformed rows increment a skip counter without crashing, unknown relation names are left as `.unknown` and reported.

### KB Configuration

The file `kb.json` maps dotted tree paths to source files. Paths follow the pattern `root.category.subcategory.domain`, for example `root.edu.physics` or `root.programming.zig`. On first run with no `kb.json`, all files are assigned sequential `root.N` placeholders and the file is written to disk for manual editing.

The current configuration maps 59 domain files across 10 top-level categories: edu (21 domains), programming (9), engineering (6), trades (8), language (4), literature (5), business (3), and system (4).

### Current Data

59 compact files loaded totaling 3.5MB of source text. 884 tables parsed with 12,756 data rows and 12,200 relationships. 99% of relationships resolved to canonical RelationType values. 59 KB structs created with AutoHashMaps populated: 12,756 fact LookupIds and 12,082 relation LookupIds minted and stored. Arena usage approximately 180MB of the 1GB allocation.

### HTTP Protocol

Listens on 127.0.0.1:1138. Accepts GET and POST. POST requires Content-Length. Response includes Connection: close. Maximum header size 64KB. Body limited by TextBig capacity (100KB).

### Request Flow

Client connects to listener, which pushes the connection to the accepter ring. A handler thread pops it via CAS, parses the HTTP request, routes by path. `/shutdown` sets the shutdown flag and returns JSON. `/run` submits to a runner via round-robin core selection, spin-waits for the response, and returns it. Unknown paths return 404.

### Current Work Payload

Echo with JSON escaping. The runner receives the body, wraps it in `{"echo":"..."}` with escaped special characters, returns it.

### Shutdown

GET or POST to `/shutdown`. Handler sets the shutdown flag. Listener sees it within 100ms, exits. Accepter joins handler threads, stops runner pool. Root joins HTTP thread, destroys resetable memory and global arena.

### Config

```json
{
    "n_cores": 4,
    "http_port": 1138,
    "global_arena_bytes": 1073741824,
    "per_core_arena_bytes": 234881024
}
```

Plus limits, model, sampling, prolog, and context sub-configs using defaults.

### Known Issues

Resetable memory is shared across handler threads without per-thread isolation. Runner threads are not yet pinned to cores. No per-core arenas allocated for runners. TextBig is copied by value through ring buffer slots (100KB per copy). KB tree hierarchy is flat — intermediate KBs (like `root.edu`) are not created, only terminal KBs for each config entry. KBs do not yet have VdrIds assigned from the structural bit-packing system. The AutoHashMap LookupId values are minted but the underlying typed arrays (facts, rules, relations) are not populated — the hash maps point to row indices in LoadResult data, not to Fact or TypedRelation structs.
