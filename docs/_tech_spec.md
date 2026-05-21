# VDR-Prolog Technical Specification

## CPU SIMD, Arena-Only, NUMA-Aligned, Compaction-Driven

### Version 0.4 — Laptop Target

---

## 1. Scope

This spec defines the complete VDR-Prolog system running on a single laptop. No GPU. No device/host split. All compute is CPU with AVX2 SIMD. All memory is fixed-size arenas allocated at startup. No malloc after init (one bounded exception: temporary training arenas, destroyed after use). Target: Dell Legion 5 (~2019), 6-8 core x86_64, 16-32GB RAM, AVX2. Zig 0.15.1.

The model is not a monolith. Model weights live in KBs alongside the domain data they serve. Access to weight KBs is grant-gated — different users see different model capabilities. Each LLM session gets a structured session KB subtree for context management and scratch work, addressed with negative IDs that never collide with global data.

LLM-compacted data ingestion converts unstructured documents into typed facts and Prolog rules, stripping prose noise and preserving every named concept, relationship, and data point. Every typed relationship ingested is a reasoning operation the neural network does not need to learn in its weights. The compaction pipeline structurally reduces the required model size: 6 exact integer layers with narrow MLPs replace 16 drifting float layers because facts live in KBs, relationships fire as Prolog rules at L3, and exact remainder arithmetic eliminates drift correction layers.

No floating point anywhere. Not in arithmetic, not in HTTP parsing, not in timing, not in logging. Every number in the system is an integer.

---

## 2. System Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                     SINGLE PROCESS                            │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │                Global Arena (NUMA node 0)                │  │
│  │  Seed KBs │ Domain KBs + Weights │ Text Store │ Path Idx │  │
│  │  Typed Relations │ Relation Indices │ Grant Store         │  │
│  │  Audit Ring │ Confidence Table │ Compaction Profiles      │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                               │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │ Core 0   │ │ Core 1   │ │ Core 2   │ │ Core N   │       │
│  │ Arena    │ │ Arena    │ │ Arena    │ │ Arena    │       │
│  │ Pinned   │ │ Pinned   │ │ Pinned   │ │ Pinned   │       │
│  │ Sessions │ │ Sessions │ │ Sessions │ │ Sessions │       │
│  │ KV Cache │ │ KV Cache │ │ KV Cache │ │ KV Cache │       │
│  │ Scratch  │ │ Scratch  │ │ Scratch  │ │ Scratch  │       │
│  │ WorkQueue│ │ WorkQueue│ │ WorkQueue│ │ WorkQueue│       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │              HTTP Listener (non-pinned thread)           │  │
│  │  Accepts connections → spawns non-pinned handlers        │  │
│  │  Handlers push work items to per-core work queues        │  │
│  │  Never touches SIMD compute. Port from config.           │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │              Engines (direct function calls)             │  │
│  │  LLM (SIMD) │ KB Store │ Prolog │ Grammar │ Builtins    │  │
│  │  Typed Relation Index │ Ingestion Pipeline               │  │
│  └─────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

One process. N+1 arenas (1 global + N per-core). Pinned compute threads do all SIMD work. Non-pinned HTTP threads handle I/O and push work to per-core atomic ring buffer queues. Direct function calls between engines. No IPC, no serialization bridge, no mutex on the hot path.

---

## 3. ID System — Dual Addressing with Sign-Bit Partitioning

### 3.1 ID Structure

Every entity (KB, fact slot, rule, term, grammar, relation) has a 64-bit ID. Bit 63 (sign bit) partitions the address space:

```
Bit 63 = 0: Global (positive). Persistent. Shared across sessions.
Bit 63 = 1: Session (negative). Session-local. Dies with session.
```

```zig
pub const VdrId = struct {
    v: i64 = 0,

    pub fn isGlobal(self: VdrId) bool { return self.v >= 0; }
    pub fn isEphemeral(self: VdrId) bool { return self.v < 0; }
    pub fn isNone(self: VdrId) bool { return self.v == 0; }
    pub fn eql(a: VdrId, b: VdrId) bool { return a.v == b.v; }
};
```

Global IDs are UUIDs with bit 63 cleared (always positive). Generated from a counter + hash at KB creation time. Session IDs decrement from -1 within each session. They never collide.

### 3.2 Three Levels of Addressing

Every entity is reachable three ways:

**UUID** — signed i64, O(1) lookup table. The canonical identifier.

**Dotted path** — hierarchical walk from root. `root.science.physics.qed.alpha_em` for global, `session_root._llm.prompt_last` for session.

**Local index** — array slot within a KB. `facts[0]` within a specific KB.

All three resolve to the same data.

### 3.3 Session Tree

Each session gets a session root at ID -1. Session KBs mirror global structure for shadowing or create new paths for scratch work. Session IDs are always negative. Global IDs are always positive. Resolution order: session first, then global. Promotion from session to global is explicit — session data never leaks to global implicitly.

### 3.4 Client and Organization Tree

```
root
├── _organization
│   └── {org_uuid}
│       └── clients
│           ├── {client_uuid_0}     ← admin owner (client 0)
│           ├── {client_uuid_1}
│           └── ...
├── _client
│   ├── {client_uuid}
│   │   ├── (preferences, settings, usage counters)
│   │   └── sessions
│   │       ├── {session_uuid_a}    ← core_id, state, snapshot_ref
│   │       └── {session_uuid_b}
│   └── ...
├── system
│   ├── oso, confidence, builtins, command_vocab, hygiene
│   ├── embedding                    ← vocab embedding weights
│   ├── output                       ← lm_head + final norm weights
│   ├── relation_types               ← system + domain relation registry
│   └── ingestion                    ← ingestion queue + profiles
├── templates
│   ├── sentences
│   └── formats
├── knowledge                        ← compacted document KBs
│   ├── math.math_4
│   │   ├── principles
│   │   ├── basis_constants
│   │   └── relationships
│   └── ...
└── (domain KBs with their own weights)
```

Sessions are persistent — they survive HTTP disconnects. A client connects, works, disconnects, reconnects later, resumes the same session. Sessions live in per-core arenas and are managed by LRU ejection when the per-core session limit is reached. Ejected sessions are snapshotted to disk and restored on reconnection.

---

## 4. Core Data Types

### 4.1 Q16 — Primary Arithmetic Type

```zig
pub const Q16 = struct {
    v: i32 = 0,      // numerator (value / D)
    r0: i16 = 0,     // remainder level 0
    r1: i16 = 0,     // remainder level 1 (sub-r0 precision)
};
// D = 65536 (2^16). Implicit. Never stored. sizeof = 8 bytes.
```

Remainder is not error. It is exact unresolved structure. Every divTrunc must capture its mod. Discarding remainder is the bug float arithmetic normalized.

**Addition:** r1 sums first, carries into r0, r0 carries into v. No information lost.

**Multiplication:** product = i64(a.v × b.v), v = divTrunc(product, D), r0 = mod(product, D), r1 from cross-terms a.r0×b.v + b.r0×a.v.

**Division:** widened = a.v × D, v = divTrunc(widened, b.v), r0 = mod(widened, b.v), r1 from r0×D/b.v. Division is worse than multiplication for remainder accumulation — divisors not factoring into D push r1 toward saturation.

**Comparison:** Lexicographic across all three fields. No epsilon. Equal means all three fields match.

**Precision sentinel:** r1 near ±32767 means escalate to Q32 for that computation path.

### 4.2 Q32 and Q335

```zig
pub const Q32 = struct { v: i64 = 0, r0: i32 = 0, r1: i32 = 0 };
// D = 2^32. 16 bytes. For Newton-Raphson, escalated computations.

pub const Q335 = struct {
    v: [6]i64, r0: [6]i64, r1: [6]i64, r2: [6]i64, r3: [6]i64,
};
// D = 2^335. 240 bytes. 4 remainder slots. Physics, transcendentals.
```

### 4.3 Fact — Atomic Unit of Knowledge

```zig
pub const Fact = struct {
    tag: FactTag = .empty,
    value: Q16 = .{},
    provenance: Provenance = .{},
};
// 48 bytes, padded for alignment.
```

FactTag determines interpretation: value, text, reference, timestamp, enum, boolean, vector, matrix, provenance, rule_ref, grammar_ref, counter, relation, column_schema, empty.

TAG_MATRIX facts reference WeightMatrix structs via `value.v` as an index into the KB's `matrix_refs` array. TAG_RELATION facts reference TypedRelation structs via `value.v` as an index into the KB's relations array. TAG_COLUMN_SCHEMA facts mark column definitions at the start of ingested table KBs.

### 4.4 Provenance

```zig
pub const Provenance = struct {
    source_type: i32 = @intFromEnum(SourceType.unknown),
    source_kb_id: VdrId = .{},
    source_slot_id: i32 = -1,
    confidence: Q16 = .{},
    timestamp: i32 = 0,
    derivation_rule_id: i32 = -1,
    capability_level: i32 = 0,
};
```

Every Fact carries full provenance. `source_type` indexes into the confidence table (11 levels from vdr_computation at 1/1 to unknown at 0/1). `capability_level` provides per-weight access control — unauthorized weights are zeroed during GEMM cache rebuild. For ingested compacted data, confidence is the minimum of the source document's level and the compaction stage (llm_generated at 30/100), promoted on verification.

### 4.5 KB — Knowledge Base

```zig
pub const KB = struct {
    // Identity (id, parent_id, name, path, walk_id)
    // Persistent stores (facts, rules, constraints, connections, grammars, iose)
    // Weight references (weight_refs_offset)
    // Typed relations (relations_offset/count/capacity, relation_index_offset)
    // Domain relation definitions (domain_rel_defs_offset/count)
    // Compaction provenance (compaction_profile_offset)
    // Live state (LRU, counters, locks, queues, stacks, rings, bitsets)
    // New facts since training (offset/count)
    // Children (offset/count/capacity, mounts)
    // Training (training_lock: bool, training_arena: ?*Arena)
    // Metadata (visibility, frozen, owner_id, timestamps, version)
};
// 256 bytes, cache-line aligned. training_arena is the only nullable pointer.
```

KBs form a tree. Each KB can hold facts, rules, weight matrices, grammars, typed relations, and metadata. A domain KB carries its own weights alongside its data — the effective model is the union of all accessible weight KBs.

### 4.6 Prolog Types

```zig
pub const Term = struct {
    type: TermType,          // atom, variable, integer, vdr, text, list, compound, vector, matrix, pair
    primary_id: i32,
    secondary_offset: i32,
    secondary_aux: i32,
    vdr_value: Q16,
};
// 24 bytes.

pub const Rule = struct {
    id: VdrId, head: i32, body_offset: i32, body_count: i16,
    action_offset: i32, action_count: i16,
    fire_count: i32, last_fired: i32, success_count: i32, failure_count: i32,
    created_at: i32, creator_session_id: VdrId,
};
// 48 bytes. Rules carry their own statistics.
```

Unification: atom-atom by ID match. Variable-anything creates binding. VDR-VDR: all three Q16 fields must match exactly. No epsilon. Compound-compound: functors match plus recursive argument unification. All integer comparisons.

### 4.7 Typed Relation System

```zig
pub const RelationType = enum(i16) {
    // System-defined (0-19): enables, requires, prevents, implements, extends,
    //   overrides, validates, verified_by, contradicts, causes, determined_by,
    //   depends_on, equivalent_to, approximates, specializes, generalizes,
    //   part_of, contains, follows, precedes
    // Domain-registerable (64-127): assigned during compaction ingestion
    // unknown = -1
};
```

Each system-defined type has structural properties known at compile time: `inverse()` returns the reverse edge type, `isSymmetric()` identifies bidirectional types (prevents, contradicts, equivalent_to), `isTransitive()` identifies types where chains compose (enables, requires, specializes, part_of, follows, depends_on). The Prolog engine uses these properties to fire rules without the LLM.

```zig
pub const TypedRelation = struct {
    rel_type: RelationType,
    from_id: VdrId,
    to_id: VdrId,
    provenance: Provenance,
    strength: Q16,         // zero = binary, nonzero = weighted
    scope_kb_id: VdrId,
};
// 48 bytes. First-class typed edge between entities.
```

```zig
pub const RelationIndex = struct {
    by_type_counts: [128]i32,    // count per RelationType slot
    // Plus sorted indices by_from and by_to for directional queries
};
```

The RelationIndex is the acceleration structure. `by_type_counts` makes "how many enables relations exist?" a single i32 read. Relations are grouped by type in contiguous arrays for cache-friendly scanning. The index is rebuilt periodically (configurable interval), not on every assertion.

Domain-specific relation types (e.g., `catalyzes` in chemistry) are registered via `DomainRelationDef` during compaction ingestion, assigned a slot in the 64-127 range, and given their symmetric/transitive/inverse properties.

### 4.8 Grammar, Session, Runner, Grant, Audit, Command Types

Grammar structs (Grammar, GrammarSlot, GrammarFill) define structural templates for rendering KB data as text. Session structs track isolation, resource bounds, counters, snapshot/clone lineage. Runner structs (poller, processor, internal, batch) handle autonomous agents. Grant structs provide authorization tokens with usage limits and expiry. Audit structs record every security-relevant action in a ring buffer. Command structs carry parsed LLM commands (15 types) with grant requirements.

All ID fields are VdrId (i64). All structs have defaults. All live in `vdr_types.zig`.

### 4.9 Confidence Table

```zig
pub const confidence_table = [11]Q16{
    .{ .v = 65536 },  // vdr_computation 1/1
    .{ .v = 65536 },  // prolog_derivation 1/1
    .{ .v = 64225 },  // database 98/100
    .{ .v = 62259 },  // prometheus 95/100
    .{ .v = 62259 },  // script 95/100
    .{ .v = 55705 },  // rest_api 85/100
    .{ .v = 52428 },  // published 80/100
    .{ .v = 45875 },  // user_stated 70/100
    .{ .v = 32768 },  // web_search 50/100
    .{ .v = 19660 },  // llm_generated 30/100
    .{ .v = 0 },      // unknown 0/1
};
```

---

## 5. Memory Architecture — Arenas Only

### 5.1 Arena Design

Every arena is a fixed-size contiguous block from `std.heap.page_allocator`. Bump pointer only. No free. No reuse until arena reset.

```zig
pub const Arena = struct {
    base: [*]u8, size: usize, cursor: usize,
    pub fn alloc(self: *Arena, bytes: usize, alignment: usize) ?[*]u8 { ... }
    pub fn reset(self: *Arena) void { self.cursor = 0; }
};
```

Two arena types: general (global arena, any thread reads) and pinned (per-core, NUMA-locked, pages touched from pinned thread for first-touch placement). ArenaSet holds global + N per-core arenas. All dynamic arrays use `ArrayListManaged` on an arena — no other dynamic allocation pattern.

### 5.2 Arena Layout

```
Global Arena (reduced model):
    Model weights:        ~286 MB (143M params × 2 bytes i16)
    Remainder data:       ~286 MB (r0 + r1 at 2 bytes each)
    Seed KBs:             ~2 MB
    Global KB store:      ~25 MB (100K KBs × 256 bytes)
    Global fact store:    ~480 MB (10M facts × 48 bytes)
    Typed relations:      ~50 MB (1M relations × 48 bytes)
    Relation indices:     ~10 MB
    Rules, terms, text:   ~93 MB
    Grants, audit:        ~33 MB
    Compaction profiles:  ~2 MB
    Total:                ~1.27 GB

Per-Core Arena (~220 MB each):
    Session table, session KBs, session facts, KV cache,
    scratch buffers, binding buffers, render buffers, work queue.

System total (8 cores): 1.27 GB + 8 × 220 MB = ~3.03 GB
Fits in 8 GB with room for OS. 16 GB laptop has 13 GB free.
```

### 5.3 Arena Reset as GC

No garbage collector. Session dies → arena region resets (cursor = 0). All session data gone instantly. No traversal, no fragmentation. Arena exhaustion returns error code, never silent corruption.

### 5.4 Temporary Training Arenas

The single exception to no-allocation-after-init. Bounded by headroom check. Destroyed after use. Pointer nulled. See Section 10.

---

## 6. HTTP Interface

### 6.1 Thread Architecture

One non-pinned listener thread on configurable port (default 1138). Spawns non-pinned handler threads per connection. Handlers parse JSON requests, resolve client/session, build work items, push to per-core atomic ring buffer queues, spin-wait on completion flag, send HTTP response. HTTP threads never do SIMD. Compute threads never touch the network.

### 6.2 Work Queue

```zig
pub const VdrWorkQueue = struct {
    items: [QUEUE_CAPACITY]VdrWorkItem,
    head: std.atomic.Value(i32),   // written by producers
    tail: std.atomic.Value(i32),   // written by consumer
    capacity: i32,
};
```

Lock-free ring buffer. Push from HTTP handlers. Pop from owning pinned thread. Atomic head/tail, no mutex. Queue full returns HTTP 503 (backpressure). A session is bound to a core at creation — all requests route to that core.

### 6.3 Session Lifecycle

Sessions persist across HTTP disconnects. Creation clones from a pre-built template with the canonical `_llm.*` subtree (COW pages). Reconnection looks up `root._client.{client_uuid}.sessions.{session_uuid}` — if in RAM, route to core; if ejected, restore from snapshot. LRU ejects coldest sessions on per-core limit, snapshotting first. Sessions die only on explicit kill, admin action, or hygiene runner purge.

---

## 7. Compute Model — CPU SIMD

### 7.1 SIMD Strategy

All hot-path computation uses AVX2: 256-bit vectors, 8 × i32 lanes. SIMD processes `v` fields in bulk. Remainder propagation (r0, r1) is a scalar post-pass where full precision is needed.

### 7.2 GEMM — Per-Thread, No Coordination

Each pinned compute thread executes complete GEMM independently. No row splitting, no barrier, no cross-thread coordination. A session's inference runs entirely on one core.

```
d_model = 2048, n_layers = 6, n_heads = 12, mlp_dim = 2048

Per layer: ~21M MACs
6 layers: ~126M MACs per token

Single core at AVX2 (~24 GMAC/s): ~5.3ms → ~190 tok/s
8 cores: 8 × ~190 = ~1520 tok/s system throughput
```

The goal is system scalability — 8 cores means 8 concurrent sessions. Adding cores adds sessions linearly with zero coordination overhead.

```zig
fn vdr_gemm(A: [*]const i32, B: [*]const i32, C: [*]i32,
            M: i32, N: i32, K: i32) void
// i64 accumulation. divTrunc by D at end. Remainder captured.
```

### 7.3 Softmax — Exact Unity

Integer exp, integer division per element, exact remainder per element, deficit assigned to element with largest truncation loss via FRU (Fixed Remainder Unit). Sum equals exactly D=65536. Every time. Deterministic. Proven across 20 benchmark epochs.

### 7.4 Layer Norm (RMSNorm)

Integer RMSNorm via Newton-Raphson for inverse square root, 4 iterations in i64. RMSNorm only handles range — no rounding correction needed because remainder carry eliminates drift.

### 7.5 Attention

Per-head Q·K dot product, causal mask, exact softmax, weighted V sum. Entire operation on one core. Exact remainder carried through all four operations.

---

## 8. Model Weights as KB Data

### 8.1 Weights Live Where They Serve

No separate model tree. Weights live in domain KBs alongside facts and rules. System embedding and output KBs are normal global KBs with grant-based access. The effective model for any session is the union of all accessible weight KBs.

### 8.2 Three-Path Weight Retrieval

**Path 1: Full Fact Scan.** No GEMM cache (new KB). Scan facts at 48-byte stride. Slow, correct, immediately usable.

**Path 2: GEMM Cache Only.** Trained KB, no new facts. Read contiguous packed `v_data` directly. Hot path.

**Path 3: Cache + New Facts.** Trained KB with additions since training. Read cache, then scan short new-facts list by index.

### 8.3 Per-Group Weight Access

Per-group GEMM copies (2-4 tiers) at the coarse level. Capability tokens in provenance for per-weight granularity. Unauthorized weights zeroed during cache rebuild (cold path), not during GEMM (hot path).

### 8.4 Weight Storage — SoA Layout

```zig
pub const WeightMatrix = struct {
    v: []i32,     // contiguous, GEMM-ready, cache-line aligned
    r0: []i16,    // remainder level 0
    r1: []i16,    // remainder level 1
    rows: i32, cols: i32,
};
// Per param: 4 (v) + 2 (r0) + 2 (r1) = 8 bytes.
// Weights stored column-major for stride-free GEMM dot products.
```

---

## 9. Compaction-Driven Data Ingestion

### 9.1 The Pipeline

Raw documents are compressed by an external conventional LLM into pipe-delimited table format: 75-93% smaller, pure signal, zero prose noise. The compacted form maps directly to VDR-Prolog types: tables become KBs, rows become Facts, relationships become Prolog Rules and TypedRelations.

```
Stage 1: EXTERNAL LLM COMPACTION (outside VDR-Prolog)
    Raw document → LLM → .compact file (pipe-delimited tables)
    Trust level: llm_generated (30/100)

Stage 2: VALIDATION
    All IDs unique. All relationship targets exist.
    Column counts match headers. Decode legend present.

Stage 3: KB CREATION
    Parent document KB + child KB per table.

Stage 4: FACT ASSERTION
    Text cells → TAG_TEXT facts. Numeric cells → TAG_VALUE facts.
    Column schema facts mark table structure.

Stage 5: RELATION AND RULE ASSERTION
    Relationships → TypedRelation structs + Prolog rules.
    Multi-target and range notation expanded.
    Domain relation types registered from decode legend.

Stage 6: PROFILE AND FREEZE
    CompactionProfile recorded. KBs frozen if configured.
```

### 9.2 Compacted Format

```
# table_name(col1|col2|col3)
ID1|value|value
ID2|value|value

# relationships(from|rel|to)
ID1|enables|ID3
ID2|requires|ID4

# section_index(section|title|ids)
1|Introduction|ID1,ID2

# decode_legend
id_prefixes: P=principle, C=concept
rel_types: enables|requires|prevents
```

Pipe-delimited. One concept per row. ~30% fewer tokens than JSON. Parseable in a single pass — split on pipes, map to column names from header.

### 9.3 How Compaction Reduces the Model

Every typed relationship ingested is a reasoning operation the neural network does not need to learn. Each replacement removes work from the model:

- **MLP layers shrink** because facts live in KBs, not weight patterns. MLP job reduces from "store all knowledge AND compute" to "compute on retrieved data."
- **Layer count drops** because multi-hop reasoning is Prolog transitive closure, not layer depth.
- **Attention heads reduce** because typed relationship retrieval is enum dispatch, not learned attention patterns.
- **Exact integer arithmetic multiplies the reduction** — zero drift across layers, no correction layers, RMSNorm only handles range. Six exact layers carry the fidelity of twelve or more float layers.

The remaining 6 layers handle: token embedding and syntax (layers 1-2), semantic understanding and KB address resolution (layers 3-4), output planning and judgment calls (layers 5-6). Everything structured runs at L3.

### 9.4 Signal Density

A 50-page paper compacted to ~5 KB of tables produces ~40 typed relations, ~200 facts, ~40 Prolog rules. Storage: ~20 KB. The 40 typed relations replace 40 reasoning patterns that would otherwise require neural network depth. Fifty compacted documents produce ~2,000 typed relations across 15+ relationship types — enough for the RelationIndex to handle most structural queries at L3.

---

## 10. Live Training

### 10.1 Temporary Arena Pattern

The single exception to no-allocation-after-init. `canTrain(kb_id)` checks memory headroom and lock status. `train(kb_id)` allocates a temporary arena sized to the specific KB (gradients with r0/r1, optimizer state, activations, transposed weights, scratch). Training runs on a pinned compute thread. Cleanup destroys arena, nulls pointer, releases lock. All code paths clean up — no leaked allocations.

Sizing per-KB: 2048×2048 matrix ≈ 100 MB temp arena. 128-element vector ≈ 10 KB.

### 10.2 GEMM During Training

Same kernel as inference. Forward pass reads from global arena (KB weights). Backward pass reads transposed copy from temporary arena. Weight update writes back to global arena. Per-fact provenance updated: `source_type = vdr_computation`, timestamp, derivation rule ID. GEMM cache marked dirty — next inference rebuilds it.

### 10.3 Concurrent Training and Inference

One core trains one KB. Other cores serve inference independently. `training_lock` (bool) prevents concurrent training of the same KB. Weight update writes to individual i32/i16 values — atomic on x86_64 for the v field that inference reads. Between write-back and cache rebuild, inference sees stale cache (consistent, just old).

---

## 11. Attention, Context, and the Session LLM Tree

### 11.1 No Fixed Attention Window

The LLM's attention is the session KB tree — structured, addressable, unlimited in size. The LLM reads specific facts from specific KB addresses, not a flat token buffer.

### 11.2 Canonical `_llm.*` Subtree

Fixed structure. The LLM does not create new top-level KBs here. Data goes inside as children. This bounds the scanning surface for attention.

```
session_root._llm.prompt_last      — continuity from previous cycle
session_root._llm.prompt_next      — what to carry to next cycle
session_root._llm.prompt_input     — current user request (system writes)
session_root._llm.prompt_current   — working scratch (cleared each cycle)
session_root._llm.history          — bounded queue of cycle history
session_root._llm.projects         — project tracking with sub-KBs
session_root._llm.people           — people tracking per context
session_root._llm.concepts         — topic relationships
session_root._llm.search           — search results and background material
session_root._llm.scratchpad       — persistent cross-prompt scratch
```

### 11.3 Prompt Processing Cycle

1. System writes user input to `prompt_input`.
2. LLM reads `prompt_last` for continuity, `prompt_input` for request, other KBs as needed.
3. LLM uses `prompt_current` as scratch.
4. LLM writes to `prompt_next` what to carry forward.
5. System copies `prompt_next` → `prompt_last` automatically.
6. `prompt_next` and `prompt_current` cleared. Ready for next cycle.

### 11.4 Session Resource Limits

`max_kb_count`, `max_ephemeral_kbs`, `max_facts_per_kb` from config. At limit, LLM cannot create new KBs or assert new facts but can still: read all KBs, fire rules, pump bounded structures (LRUs/queues cycle by overwriting), do inference, retract facts to make room. Graceful degradation.

---

## 12. Inference Loop

```
vdr_inference_cycle(session, input, output) -> Status

    // Phase 1: Write input to prompt_input
    // Phase 2: LLM reads prompt_last + prompt_input + other KBs
    // Phase 3: Resolve visible model weights (grant-gated)
    // Phase 4: Forward pass on single core (SIMD GEMM per layer)
    // Phase 5: Generation loop
    //   - Command tokens → execute, result to prompt_current
    //   - Direct output → KB read, grammar render
    //   - Prose tokens → output buffer
    //   - End of turn → break
    // Phase 6: System copies prompt_next → prompt_last, clears transients
    // Phase 7: Post-processing (turn counter, token counter)
    // Phase 8: Auto-snapshot if interval reached
```

### 12.1 Execution Levels

```
L1 — Full LLM Forward Pass:   50-500 tokens. No stored rule covers it.
L2 — LLM Invokes Stored Rule: ~18 tokens. ~3% of L1 cost.
L3 — Automatic Prolog/Relation Firing: 0 LLM tokens.
     Includes: typed relation queries, transitive closure, inverse lookup.
     93% of ops at maturity.
```

---

## 13. Prolog Engine

### 13.1 General Unification and Query

Direct function calls into arena memory. Depth-first search with backtracking via explicit stack in per-core scratch. Session tree searched first, then global.

### 13.2 Typed Relation Fast Path

For queries matching the `rel_type(from, to)` pattern, the engine bypasses general unification and dispatches to the RelationIndex:

```
queryTypedRelation(kb, rel_type, from, to) → []TypedRelation
    1. Check by_type_counts[@intFromEnum(rel_type)] — if 0, skip KB.
    2. Scan contiguous TypedRelation array for this type.
    3. Filter by from/to if specified.
    // No term construction, no binding stack, no backtracking.
```

### 13.3 Automatic Transitive Closure

For transitive types (`enables`, `requires`, `specializes`, `part_of`, `follows`, `depends_on`): BFS over contiguous integer arrays. L3 — zero tokens.

### 13.4 Inverse and Symmetry Dispatch

`inverse()` is a switch on enum — compile-time known. Querying `enables(X, target)` automatically also queries `depends_on(target, X)`. Symmetric types (`prevents`, `contradicts`, `equivalent_to`) auto-query with from/to swapped.

---

## 14. KB Store — Direct Memory Access

No bridge layer. All operations are direct pointer arithmetic into arena memory. O(1) fact read/write via KB offset + slot × sizeof(Fact). Scoped search walks parent chain — session first, then global at junction point. COW for clone sessions with page-level dirty tracking.

---

## 15. Persistence and Lazy Loading

### 15.1 Save Format

KBs saved as raw byte slices of in-memory structs. No serialization format. The bytes in the file are the struct. KB files (`.kb`) contain header, KB struct, facts, rules, terms, children, text, weight refs, new-facts indices. Weight files (`.wt`) contain header + v/r0/r1 SoA arrays. CRC32 checksum on every file.

### 15.2 Manifest

Single `manifest.dat` loaded at startup — index of all persisted KBs. Contains ID, path, parent, version, sizes, flags. ~100 bytes per entry. The only file that must be read at startup.

### 15.3 Lazy Loading

At startup, only manifest + seed KBs are loaded. All other KBs load on first access. A KB never accessed is never loaded — zero arena memory, zero disk I/O. Weight data loads separately from KB data — the first inference needing a domain KB's weights pays the disk cost. Subsequently, all sessions share the loaded weights from the global arena.

### 15.4 Version Mismatch

File headers store struct sizes at save time. If sizes don't match the current binary, reject and tell user to run `vdr-convert`. No in-process migration. Offline converter reads old structs, maps to new, writes new files.

---

## 16. Serialization — Session Snapshots

Binary snapshot captures full session state (global view + session tree):

```zig
pub const SNAPSHOT_MAGIC = [4]u8{ 'V', 'D', 'R', 'S' };
pub const SNAPSHOT_VERSION: i32 = 4;
```

Header contains region sizes, entity counts, full Session struct, CRC32. Restore is bit-identical. Session IDs preserved.

---

## 17. Seed Layer

```
root                          id: +1
├── system                    id: +2
│   ├── oso                   id: +3     (15 engineering principles)
│   ├── confidence            id: +4     (confidence table)
│   ├── builtins              id: +5     (448 IOSE declarations)
│   ├── command_vocab         id: +6     (~300 command tokens)
│   ├── hygiene               id: +7     (self-maintenance rules)
│   ├── embedding             id: +8     (vocab embedding weights)
│   ├── output                id: +9     (lm_head + final norm weights)
│   ├── relation_types        id: +13    (system + domain relation registry)
│   └── ingestion             id: +14    (ingestion queue + profiles)
├── templates                 id: +10
│   ├── sentences             id: +11
│   └── formats               id: +12
└── (domain KBs with their own weights + compacted knowledge KBs)

14 seed KBs. System KBs frozen after init.
Domain KBs carry their own weights alongside data, rules, and typed relations.
```

---

## 18. Configuration

### 18.1 SystemConfig

JSON config loaded at startup via `std.json`. Hard-mapped — unknown fields are errors, missing required fields are errors. No silent defaults. Single source of truth.

Key fields: `n_cores`, `model` (ModelConfig), `model_reduction` (ModelReductionConfig), `global_arena_bytes`, `per_core_arena_bytes`, all limits, `http_port` (default 1138), `ingestion` (IngestionConfig), `relation_index_rebuild_interval`, session/runner/sampling/prolog/context configs.

### 18.2 ModelReductionConfig

Advisory struct linking compaction analysis to architecture sizing:

```zig
pub const ModelReductionConfig = struct {
    base_n_layers: i32 = 16,      reduced_n_layers: i32 = 6,
    base_mlp_dim: i32 = 5632,     reduced_mlp_dim: i32 = 2048,
    base_n_heads: i32 = 16,       reduced_n_heads: i32 = 12,
    base_vocab_size: i32 = 32000, reduced_vocab_size: i32 = 8192,
    // Compaction metrics
    relation_types_covered: i32, total_typed_relations: i32,
    total_prolog_rules: i32, estimated_l3_coverage: Q16,
    use_i16_weights: bool = true,
    pub fn estimatedWeightBytes(self) i64 { ... }
};
```

The admin sets architecture parameters based on compaction analysis. Nothing auto-reduces.

---

## 19. Performance Estimates

### 19.1 Reduced Model (6 layers, i16 weights, 8K vocab)

```
Total params:     ~143M
Weight memory:    ~286 MB (i16)
Per-token MACs:   ~126M
Single core:      ~5.3ms per token → ~190 tok/s
8 cores:          ~1520 tok/s system throughput (8 concurrent sessions)
```

### 19.2 With L3 Ratio

At 93% L3 (typed relations + Prolog handling most queries):

```
Effective request throughput: ~1520 / 0.07 ≈ ~21,700 requests/second
```

Most requests never invoke the forward pass. Typed relation queries are sub-microsecond integer scans. Prolog rule firing is integer comparison chains. The LLM only runs for judgment calls, novel situations, and ambiguous queries.

### 19.3 System Memory

```
Global arena:     ~1.27 GB (reduced model + all stores)
Per-core arenas:  8 × ~220 MB = ~1.76 GB
System total:     ~3.03 GB
```

Fits in 8 GB. A 16 GB laptop has 13 GB free for domain growth, snapshots, and training.

---

## 20. Error Handling

Same deterministic recovery tree. ERR_CAT_MEMORY for arena exhaustion. Every allocation returns null on exhaustion — callers check and return error with arena ID. Recovery actions: compact, log, simplify query, retry snapshot, deny, reconnect, recycle runner, kill oldest clone, restore from snapshot.

---

## 21. Invariants

```
 1. Remainder is never discarded. Every divTrunc captures its mod.
 2. r0 and r1 are never padding. Both carry exact meaning.
 3. Softmax sums to D (65536) exactly. Every time.
 4. Comparison uses all three Q16 fields. No epsilon.
 5. All multiplications widen to i64 before computing.
 6. No float anywhere. Integer in, integer through, integer out.
 7. r1 near ±32767 means escalate to Q32 for that path.
 8. Session IDs (negative) never collide with global IDs (positive).
 9. Session data dies with its session. Arena reset. Gone.
10. Arena exhaustion is never silent. Always returns error.
11. SIMD and scalar paths produce bit-identical results.
12. Temporary training arenas are the only post-startup allocation.
13. The _llm.* canonical subtree structure is fixed.
14. All dynamic arrays use ArrayListManaged on an arena.
15. fromParts always takes three arguments (v, r0, r1).
16. RelationType slots 0-19 are system-defined and frozen.
17. Domain relation slots 64-127 are first-come, never reassigned.
18. Every TypedRelation has a TAG_RELATION Fact for provenance.
19. RelationIndex is eventually consistent — rebuilt periodically.
20. Typed relation queries bypass general Prolog unification.
21. Model reduction config is advisory — admin sets, system estimates.
22. Compaction profiles are immutable after ingestion.
23. GEMM executes per-thread with no cross-core coordination.
24. KBs lazy-load from manifest. Unaccessed KBs use zero arena memory.
```

---

## 22. Zig 0.15.1 Specifics

- `std.debug.print` for output. No `std.io.getStdOut()`.
- `.root_module = b.createModule(...)` for build.
- Integer timestamps only. `std.time.timestamp()` → i32.
- x86_64 only. No ARM, no WASM.
- All types in `vdr_types.zig`. Ingestion parse-time structs in `vdr_ingestion.zig`.

---

## 23. Build Order

Strict bottom-up. Each step compiles and exits clean before the next.

1. **Kernel boot + arena memory.** Zig project compiles, allocates arena, prints diagnostics.
2. **Config loader.** JSON → SystemConfig. Strict errors.
3. **Arena set from config.** Global + N per-core arenas.
4. **NUMA-pinned threads.** Spawn, pin, first-touch, park in spin-wait.
5. **HTTP listener.** Non-pinned, accepts, responds 200 OK.
6. **HTTP-to-NUMA work passing.** Atomic ring buffers bridge I/O to compute.

Everything after step 6 builds on this kernel.

---

## 24. Implementation Stages

```
Stage 1: Foundation (~5,000 lines)
    vdr_types, vdr_arena, vdr_config, vdr_thread_pool,
    vdr_http, vdr_work_queue, vdr_kb_store, vdr_access
    vdr_ops (scalar only)
    Basic session with _llm.* subtree

Stage 2: Intelligence (~6,000 lines)
    vdr_prolog, vdr_grammar, vdr_builtin
    vdr_session (snapshot, clone, merge, kill)
    vdr_grant, vdr_audit, vdr_confidence, vdr_command

Stage 3: Compute (~4,000 lines)
    vdr_ops (AVX2: gemm, softmax, rmsnorm, attention, silu)
    vdr_model (KB-distributed weights, three-path retrieval)
    vdr_inference (full loop with prompt cycle)

Stage 4: Ingestion + Relations (~3,000 lines)
    vdr_ingestion (parser, validator, KB assertion, relation assertion)
    vdr_relation (RelationIndex, typed queries, transitive closure, inverse)
    Domain relation registration

Stage 5: Training + Operations (~4,000 lines)
    vdr_training (canTrain, train, temporary arenas, weight update, provenance)
    vdr_runner (all 4 types), vdr_seed, vdr_system

Stage 6: Persistence (~2,000 lines)
    vdr_persist (save/load KB files, weight files, manifest)
    vdr_snapshot (session snapshots)
    Lazy loading, version detection

Stage 7: Testing (~1,000 lines)
    Determinism, SIMD correctness, snapshot roundtrip,
    session isolation, access control, confidence propagation,
    softmax exact unity, remainder chains, three-path retrieval,
    training arena lifecycle, typed relation queries,
    transitive closure, compaction ingestion roundtrip

Total: ~25,000 lines.
```

---

## 25. Implementation Files

```
vdr_types.zig         — all persistent structs, enums, constants
vdr_ingestion.zig     — parse-time structs, parser, validator (temporary arena)
vdr_arena.zig         — arena allocator, ArenaSet, bump pointer, reset
vdr_config.zig        — JSON config loading, strict errors
vdr_thread_pool.zig   — pinned threads, lifecycle, spin-wait
vdr_work_queue.zig    — per-core atomic ring buffer, push/pop, completion
vdr_http.zig          — non-pinned HTTP listener and handlers
vdr_ops.zig           — SIMD: gemm, dot, softmax, rmsnorm, attention, silu
vdr_model.zig         — KB-distributed weights, three-path retrieval, forward pass
vdr_kb_store.zig      — KB CRUD, fact/rule/term stores, path index, session resolution
vdr_relation.zig      — RelationIndex, typed queries, transitive closure, inverse, domain registration
vdr_prolog.zig        — unification, query, rule firing, backtracking
vdr_grammar.zig       — template compile, render, inherit
vdr_session.zig       — session lifecycle, _llm.* subtree, clone/merge/kill
vdr_persist.zig       — save/load KB files, weight files, manifest, lazy loading
vdr_snapshot.zig      — session snapshots, save/restore, CRC32
vdr_training.zig      — canTrain, train, temporary arenas, weight update, provenance
vdr_runner.zig        — poller, processor, internal, batch runners
vdr_inference.zig     — full inference loop, prompt cycle, L1/L2/L3
vdr_command.zig       — command parser, executor, dispatch
vdr_access.zig        — visibility, session/global resolution, per-group weight access
vdr_grant.zig         — grant CRUD, check, cleanup
vdr_audit.zig         — ring buffer, query, filter
vdr_confidence.zig    — assign, combine, chain, propagate
vdr_seed.zig          — seed layer init, domain weight KB creation
vdr_builtin.zig       — 448 builtins, IOSE validation, dispatch
vdr_system.zig        — top-level init, wire everything
vdr_test.zig          — full test suite
build.zig             — single native x86_64 target

27 files. ~25K lines estimated.
```
