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

---

# VDR-Prolog Technical Specification — Appendices

## Supporting Tables, Reference Data, and Cross-References

---

## Appendix A: Q16 Arithmetic Verification Reference

### A.1 Remainder Propagation Test Vectors

```
# q16_add_vectors(a_v|a_r0|a_r1|b_v|b_r0|b_r1|expect_v|expect_r0|expect_r1|notes)
65536|0|0|65536|0|0|131072|0|0|1.0 + 1.0 = 2.0, clean
32768|16384|0|32768|16384|0|65537|0|0|0.5+0.25 + 0.5+0.25, r0 carry into v
100|100|16000|200|200|16000|300|301|32000|r1 sum below carry threshold
100|100|16384|200|200|16384|300|301|0|r1 sum hits 32768, carries to r0
1|32767|16383|1|32767|16383|3|32766|32766|near-max r0 carry chain
-1|0|0|1|0|0|0|0|0|cancellation to exact zero
```

### A.2 Multiplication Cross-Term Verification

```
# q16_mul_vectors(a_v|a_r0|a_r1|b_v|b_r0|b_r1|expect_v|expect_r0|expect_r1|notes)
65536|0|0|65536|0|0|65536|0|0|1.0 × 1.0 = 1.0
32768|0|0|32768|0|0|16384|0|0|0.5 × 0.5 = 0.25
65536|100|0|65536|200|0|65536|0|300|cross-term: 100×65536 + 200×65536 / D
2|0|0|3|0|0|0|6|0|small × small, result below 1/D, lives in r0
0|1|0|0|1|0|0|0|0|sub-D × sub-D, a.r0×b.r0 not captured (sub-r1 structure)
```

### A.3 Division Remainder Saturation Cases

```
# q16_div_vectors(a_v|b_v|expect_v|expect_r0|r1_saturates|notes)
65536|3|21845|21845|no|1.0 / 3: remainder 1/3 of D, r1 stable
65536|7|9362|9362|no|1.0 / 7: clean
65536|65536|65536|0|no|1.0 / 1.0: exact
1|3|0|21845|yes after chains|chained /3 pushes r1 toward saturation
65536|127|516|4|yes after 8 chains|prime divisor, worst case for remainder
65536|65536|65536|0|never|power-of-two divisors always clean
65536|256|256|0|never|factors of D never produce remainder
```

### A.4 Softmax FRU Deficit Assignment Examples

```
# softmax_fru(input_logits|exp_values|raw_probs|remainders|deficit|assigned_to|final_probs|sum)
[3,1,1]|[exp(3),exp(1),exp(1)]|[47083,8946,8946]|[47083%t,8946%t,8946%t]|561|0|[47644,8946,8946]|65536
[0,0,0]|[1,1,1]|[21845,21845,21845]|[r0,r1,r2]|1|largest_r|[21846,21845,21845]|65536
[10,0,0,0]|[exp(10),..]|[65131,135,135,135]|[..]|0|none|[65131,135,135,135]|65536
# Sum is exactly D=65536 in every case. No exceptions. Proven across 20 benchmark epochs.
```

---

## Appendix B: Confidence Table Derivations

### B.1 Confidence Values with Fraction Origins

```
# confidence_derivations(source_type|fraction|decimal|q16_v|q16_exact|derivation)
vdr_computation|1/1|1.000|65536|yes|system computed, no external dependency
prolog_derivation|1/1|1.000|65536|yes|derived from rules with confidence 1/1 inputs
database|98/100|0.980|64225|truncated from 64224.8|structured, schema-validated, occasionally stale
prometheus|95/100|0.950|62259|truncated from 62259.2|metrics pipeline, sampling granularity
script|95/100|0.950|62259|same as prometheus|deterministic but authored code, bugs possible
rest_api|85/100|0.850|55705|truncated from 55705.6|external service, versioning, schema drift
published|80/100|0.800|52428|truncated from 52428.8|peer reviewed or editorial process, still human error
user_stated|70/100|0.700|45875|truncated from 45875.2|human assertion, no verification
web_search|50/100|0.500|32768|exact|unverified internet content, SEO manipulation
llm_generated|30/100|0.300|19660|truncated from 19660.8|hallucination risk, no ground truth
unknown|0/1|0.000|0|exact|no provenance, no trust
```

### B.2 Confidence Combination Rules

```
# confidence_combination(operation|formula|example|result)
chain|min(a, b)|published(52428) → llm_generated(19660)|19660
parallel_agree|max(a, b)|user_stated(45875) + database(64225)|64225
contradiction|0|source_a says X, source_b says not-X|0
derivation|min(inputs) if rule confidence=1/1|prolog(65536) on inputs [52428, 45875]|45875
promotion|direct_set|admin verifies llm_generated → published|52428
degradation_by_age|v - (age_days * decay_rate)|stale database entry after 30 days|depends on decay
```

### B.3 Ingestion Confidence Chain

```
# ingestion_confidence(source_type|compaction_stage|combined|rationale)
published|llm_generated|19660|min(52428, 19660) — compaction is weakest link
database|llm_generated|19660|min(64225, 19660)
user_stated|llm_generated|19660|min(45875, 19660)
published|verified_compaction|52428|after human review promotes compaction to published
vdr_computation|n/a|65536|training output, full confidence
prolog_derivation|n/a|65536|derived from verified facts
```

---

## Appendix C: Arena Sizing Worksheets

### C.1 Global Arena Detailed Breakdown (Reduced Model)

```
# global_arena_budget(component|calculation|bytes|MB|notes)
embedding_weights_v|8192 × 2048 × 2|33554432|32.0|i16 vocab embedding
embedding_weights_r0|8192 × 2048 × 2|33554432|32.0|i16 remainder
embedding_weights_r1|8192 × 2048 × 2|33554432|32.0|i16 remainder
layer_qkv_v|6 × 2048 × 4096 × 2|100663296|96.0|6 layers, i16
layer_qkv_r|6 × 2048 × 4096 × 4|201326592|192.0|r0+r1 combined
layer_o_v|6 × 2048 × 2048 × 2|50331648|48.0|output projection
layer_o_r|6 × 2048 × 2048 × 4|100663296|96.0|r0+r1
layer_mlp_up_v|6 × 2048 × 2048 × 2|50331648|48.0|narrow MLP
layer_mlp_up_r|6 × 2048 × 2048 × 4|100663296|96.0|r0+r1
layer_mlp_down_v|6 × 2048 × 2048 × 2|50331648|48.0|narrow MLP
layer_mlp_down_r|6 × 2048 × 2048 × 4|100663296|96.0|r0+r1
lm_head_v|2048 × 8192 × 2|33554432|32.0|reduced vocab
lm_head_r|2048 × 8192 × 4|67108864|64.0|r0+r1
layer_norms|6 × 2 × 2048 × 8|196608|0.2|gamma per norm, Q16
kb_store|100000 × 256|25600000|24.4|KB structs
fact_store|10000000 × 48|480000000|457.8|maximum facts
typed_relations|1000000 × 48|48000000|45.8|maximum relations
relation_indices|10000 × 640|6400000|6.1|~10K KBs with indices
rule_store|100000 × 48|4800000|4.6|rules
term_store|1000000 × 24|24000000|22.9|terms
text_store|67108864|67108864|64.0|64 MB text
grammar_store|5242880|5242880|5.0|grammars
path_index|1000000 × 16|16000000|15.3|path hash → ID
grant_store|5242880|5242880|5.0|grants
audit_ring|1000000 × 28|28000000|26.7|audit entries
compaction_profiles|10000 × 256|2560000|2.4|ingested documents
confidence_table|88|88|0.0|11 × Q16
total|||~1270|
```

### C.2 Per-Core Arena Breakdown

```
# per_core_arena_budget(component|calculation|bytes|MB|notes)
session_table|500 × 256|128000|0.1|max sessions per core
session_kb_store|1000 × 500 × 256|128000000|122.1|ephemeral KBs per session × sessions ÷ sharing
session_fact_store|10000 × 500 × 48|240000000|228.9|theoretical max, actual sharing reduces
kv_cache|2 × 6 × 2048 × 12 × 170 × 4|401080320|382.5|K+V × layers × seq × heads × d_head × i32
scratch_buffers|33554432|33554432|32.0|GEMM intermediates, attention scores
binding_buffers|1048576|1048576|1.0|Prolog unification
render_buffers|1048576|1048576|1.0|grammar output
work_queue|1024 × 128|131072|0.1|ring buffer items
# NOTE: actual per-core usage is ~220 MB because sessions share ephemeral structure
# via COW and most sessions are idle at any moment. The theoretical max above
# exceeds the arena size; the arena is sized for actual concurrent working set.
```

### C.3 Training Temporary Arena Sizing

```
# training_arena_sizing(weight_shape|params|grad_v|grad_r0r1|momentum|variance|transpose|activations|scratch|total_MB)
2048×4096|8388608|32|16|32|32|32|16|16|176
2048×2048|4194304|16|8|16|16|16|16|9|97
2048×2048|4194304|16|8|16|16|16|16|9|97
1024×1024|1048576|4|2|4|4|4|4|2|24
512×512|262144|1|0.5|1|1|1|1|0.6|6
128 (vector)|128|0.0005|0.0003|0.0005|0.0005|0.0005|0.0005|0.0001|0.003
# formula per param: 4(grad_v) + 2(grad_r0) + 2(grad_r1) + 4(momentum) + 4(variance) + 4(transpose) = 20 bytes
# plus activations: seq_len × d_model × 4 bytes (one layer's worth)
# plus scratch: ~10% overhead
```

---

## Appendix D: RelationType Property Matrix

### D.1 System-Defined Relations (Slots 0-19)

```
# relation_properties(slot|name|inverse|symmetric|transitive|usage)
0|enables|depends_on|no|yes|X makes Y possible or functional
1|requires|enables|no|yes|X cannot exist or work without Y
2|prevents|prevents|yes|no|X blocks or forbids Y; mutual
3|implements|unknown|no|no|X is a concrete realization of abstract Y
4|extends|generalizes|no|yes|X adds capability to Y without replacing
5|overrides|unknown|no|no|X replaces Y's behavior in a scope
6|validates|verified_by|no|no|X confirms Y is correct
7|verified_by|validates|no|no|Y was confirmed by X
8|contradicts|contradicts|yes|no|X and Y cannot both hold; mutual
9|causes|determined_by|no|no|X directly produces Y as effect
10|determined_by|causes|no|no|Y's value or form is fixed by X
11|depends_on|enables|no|yes|X needs Y to function; transitive chain
12|equivalent_to|equivalent_to|yes|no|X and Y are interchangeable
13|approximates|approximates|yes|no|X and Y are close but not identical
14|specializes|generalizes|no|yes|X is a more specific form of Y
15|generalizes|specializes|no|yes|X is a more general form of Y
16|part_of|contains|no|yes|X is a component inside Y
17|contains|part_of|no|yes|Y is a component inside X
18|follows|precedes|no|yes|X comes after Y in sequence
19|precedes|follows|no|yes|X comes before Y in sequence
```

### D.2 Transitive Closure Semantics

```
# transitive_behavior(type|chain_example|derived_fact|cost)
enables|enables(A,B) + enables(B,C)|enables(A,C)|BFS integer scan
requires|requires(A,B) + requires(B,C)|requires(A,C)|BFS integer scan
extends|extends(A,B) + extends(B,C)|extends(A,C)|BFS integer scan
specializes|specializes(A,B) + specializes(B,C)|specializes(A,C)|BFS integer scan
generalizes|generalizes(A,B) + generalizes(B,C)|generalizes(A,C)|BFS integer scan
part_of|part_of(A,B) + part_of(B,C)|part_of(A,C)|BFS integer scan
contains|contains(A,B) + contains(B,C)|contains(A,C)|BFS integer scan
follows|follows(A,B) + follows(B,C)|follows(A,C)|BFS integer scan
precedes|precedes(A,B) + precedes(B,C)|precedes(A,C)|BFS integer scan
depends_on|depends_on(A,B) + depends_on(B,C)|depends_on(A,C)|BFS integer scan
# Non-transitive types: implements, overrides, validates, verified_by,
#   contradicts, causes, determined_by, equivalent_to, approximates
# These do NOT chain. A implements B and B implements C does NOT mean A implements C.
```

### D.3 Domain Slot Registration Rules

```
# domain_slot_rules(rule|detail)
allocation|first-come within slots 64-127; never reassigned within a running instance
registration_source|decode legend of compacted document during ingestion
properties_required|name, is_symmetric, is_transitive; inverse_slot optional
property_inference|if inverse not declared, set to -1 (no automatic inverse)
cross-document|once registered, usable system-wide by any document or query
persistence|DomainRelationDef saved as facts in root.system.relation_types KB
max_domains|64 slots (64 through 127 inclusive)
collision|second document registering same name reuses existing slot; properties must match or error
```

---

## Appendix E: Error Code Reference

### E.1 Complete Error Codes with Recovery Actions

```
# error_codes(code|value|category|recovery_action|detail_field_meaning)
ok|0|none|none|unused
division_by_zero|100|arithmetic|log_and_continue|operand index
overflow|101|arithmetic|log_and_continue|operation type
kb_not_found|200|kb|log_and_continue|requested VdrId.v
kb_full|201|kb|compact|kb VdrId.v
kb_frozen|202|kb|log_and_continue|kb VdrId.v
kb_access_denied|203|kb|log_and_deny|kb VdrId.v
slot_out_of_range|204|kb|log_and_continue|requested slot index
slot_empty|205|kb|log_and_continue|requested slot index
depth_exceeded|300|prolog|simplify_query|depth reached
no_matching_rule|301|prolog|log_and_continue|query term offset
unification_failed|302|prolog|log_and_continue|term offset pair
max_bindings_exceeded|303|prolog|simplify_query|bindings count
invalid_template|400|grammar|log_and_continue|template offset
slot_type_mismatch|401|grammar|log_and_continue|slot index
render_capacity_exceeded|402|grammar|log_and_continue|buffer size needed
session_limit|500|session|kill_oldest_clone|core_id
snapshot_failed|501|session|retry_snapshot|session VdrId.v
snapshot_corrupt|502|session|restore_from_snapshot|checksum expected
clone_failed|503|session|log_and_continue|parent session VdrId.v
merge_conflict|504|session|log_and_continue|conflict count
grant_denied|600|grant|log_and_deny|grant class
grant_expired|601|grant|log_and_deny|grant VdrId.v
grant_exhausted|602|grant|log_and_deny|grant VdrId.v
grant_revoked|603|grant|log_and_deny|grant VdrId.v
grant_admin_required|604|grant|log_and_deny|operation type
runner_error_threshold|700|runner|recycle_runner|consecutive error count
runner_connection_lost|701|runner|reconnect_with_backoff|last attempt timestamp
arena_exhausted|800|memory|kill_oldest_clone|arena_id
arena_not_found|801|memory|log_and_continue|requested arena_id
init_failed|900|system|restore_from_snapshot|init phase number
corrupt_state|901|system|restore_from_snapshot|detection point
seed_load_failed|902|system|restore_from_snapshot|seed kb VdrId.v
```

### E.2 HTTP Status Code Mapping

```
# http_status_mapping(condition|http_status|error_code|body)
client not found|401|n/a|{"error": "unknown client"}
auth failed|401|n/a|{"error": "invalid auth_token"}
client suspended|403|n/a|{"error": "client not active"}
session not owned|403|kb_access_denied|{"error": "session belongs to different client"}
session not found|404|n/a|{"error": "no session with this UUID"}
session gone (ejected, no snapshot)|410|n/a|{"error": "session ejected, no snapshot"}
malformed request|400|n/a|{"error": "JSON parse error", "detail": "..."}
queue full|503|n/a|{"error": "core queue full, retry later"}
request timeout|504|n/a|{"error": "compute thread timeout"}
arena exhausted during request|503|arena_exhausted|{"error": "memory pressure", "arena": N}
kb access denied during compute|200|kb_access_denied|{"status": "error", "code": 203}
prolog depth exceeded|200|depth_exceeded|{"status": "error", "code": 300}
successful inference|200|ok|{"status": "ok", "output": "...", "tokens": N}
successful kb query|200|ok|{"status": "ok", "facts": [...]}
```

---

## Appendix F: Struct Size and Alignment Verification

### F.1 Core Struct Sizes

```
# struct_sizes(struct|target_size|alignment|cache_lines|notes)
Q16|8|4|0.125|v:4 + r0:2 + r1:2, no padding
Q32|16|8|0.25|v:8 + r0:4 + r1:4
Q335|240|8|3.75|5 arrays × 6 × i64
VdrId|8|8|0.125|single i64
Fact|48|8|0.75|tag:4 + Q16:8 + Provenance:36, padded to 48
Provenance|36|8|0.5625|7 fields, i32/i64 mix with capability_level
KB|256|8|4.0|exactly 4 cache lines, padded
Term|24|4|0.375|type:1 + pad:3 + 3×i32 + Q16:8
Rule|48|8|0.75|id:8 + 10 fields + creator:8
TypedRelation|48|8|0.75|rel:2 + pad + 2×VdrId:16 + Prov:36 + Q16:8 + VdrId:8, padded
RelationIndex|528|4|8.25|128×i32 counts + 6 fields
DomainRelationDef|32|8|0.5|slot:2 + offset:4 + length:2 + 2×bool + inverse:2 + VdrId:8 + time:4, padded
CompactionProfile|256|4|4.0|128×bool + 12 integer fields + Q16
Session|~200|8|~3.1|~25 fields, fits in 256 with padding
Grant|~80|8|1.25|12 fields
AuditEntry|~44|8|0.6875|9 fields
Command|~24|4|0.375|7 fields
WeightMatrix|~32|8|0.5|3 slices + 2×i32
GemmCache|~32|8|0.5|slice + 4 fields
```

### F.2 Array Stride Impact on Cache

```
# stride_analysis(struct|stride_bytes|elements_per_cacheline|elements_per_L1_32KB|GEMM_relevant)
Fact|48|1.33|682|no — GEMM reads WeightMatrix.v not facts
WeightMatrix.v element|4|16|8192|yes — inner loop
WeightMatrix.r0 element|2|32|16384|no — scalar post-pass only
TypedRelation|48|1.33|682|no — integer scan, not SIMD
Term|24|2.67|1365|no — Prolog traversal
Rule|48|1.33|682|no — rule matching
i32 (GEMM operand)|4|16|8192|yes — this is the hot path
```

---

## Appendix G: SIMD Operation Coverage

### G.1 AVX2 Operation Mapping

```
# simd_operations(operation|simd_path|scalar_path|remainder_handling|invariant_check)
GEMM dot product|8×i32 → 2×4×i64 widen-madd-accumulate|tail elements|r0 from final divTrunc, r1=0|INVARIANT_11: SIMD == scalar
GEMM output|single divTrunc of i64 accumulator|same|r0 = mod(sum, D)|INVARIANT_1: mod captured
softmax max scan|8×i32 horizontal max|tail|no remainder (integer max)|n/a
softmax exp|scalar (table lookup)|same|per-element exact|n/a
softmax prob|scalar (integer division)|same|per-element r0 = mod(exp×D, total)|INVARIANT_3: FRU
softmax FRU|scalar (find max remainder, assign deficit)|same|deficit = D - sum(probs)|INVARIANT_3: sum == D
attention Q·K dot|8×i32 widen-madd|tail|r0 on final result|INVARIANT_5: i64 accumulate
attention V weighted sum|8×i32 multiply + accumulate|tail|r0 on final result|same
RMSNorm variance|8×i32 square + accumulate in i64|tail|r0 on mean|INVARIANT_5
RMSNorm inv_sqrt|scalar Newton-Raphson in Q32|same|Q32 → Q16 conversion captures r0|INVARIANT_7 check
RMSNorm scale|8×i32 multiply (input × inv_rms × gamma)|tail|r0 from final divTrunc|INVARIANT_1
SiLU activation|scalar (piecewise integer approx)|same|r0 on each element|n/a
residual add|8×i32 add|tail|full r1→r0→v carry chain per element|INVARIANT_2: r0,r1 propagated
```

### G.2 SIMD Verification Requirements

```
# simd_verification(test|method|pass_criterion)
bit_identity|run SIMD and scalar on same input, compare all output bytes|byte-identical
overflow_safety|max-range i32 inputs (±2^31-1), K=2048|i64 accumulator doesn't overflow
remainder_capture|known-remainder inputs (e.g., 1/3 chain)|r0 matches expected mod
FRU_determinism|same logits 1000 times|same deficit assignment every time
lane_independence|corrupt one SIMD lane, verify others unaffected|fault isolation
tail_handling|input lengths 1-7 (non-multiple of 8)|correct results, no buffer overread
alignment|unaligned input pointers|correct results (Zig vectors handle alignment)
```

---

## Appendix H: Execution Level Decision Tree

### H.1 L1/L2/L3 Classification

```
# level_decision(condition|level|tokens|cost_ratio|example)
typed relation in index, exact match|L3|0|0%|"what does P1 enable?" → index scan
transitive closure, all edges in index|L3|0|0%|"what does P1 transitively enable?"
inverse lookup, type has inverse()|L3|0|0%|"what depends on AR1?" via enables inverse
prolog rule matches, no LLM needed|L3|0|0%|fire_and_commit on satisfied rules
prolog rule needs LLM to select|L2|~18|~3%|LLM picks which rule, Prolog executes
novel query, no rule coverage|L1|50-500|100%|full forward pass, judgment required
ambiguous user intent|L1|50-500|100%|LLM interprets, may emit commands
multi-step reasoning, partial L3|L2|~18 per step|~3% per step|LLM orchestrates, Prolog executes steps
output formatting via grammar|L3|0|0%|grammar render from KB URL
output requiring judgment/framing|L1|variable|100%|prose generation for user
```

### H.2 L3 Ratio Maturity Curve

```
# l3_maturity(phase|typed_relations|prolog_rules|estimated_l3_pct|description)
cold_start|0|~50 seed|5%|only seed hygiene rules fire at L3
early_ingestion|200|100|25%|first few compacted documents
moderate_coverage|2000|500|60%|~50 documents across several domains
good_coverage|5000|1500|80%|domain KB weight begins to matter
mature|10000+|3000+|93%|most structural queries handled at L3
# Target is 93% at maturity. Below 80% means compaction pipeline isn't feeding enough structure.
# Above 95% may mean the model is being underused for judgment calls it should handle.
```

---

## Appendix I: File Format Reference

### I.1 File Types

```
# file_formats(extension|magic|version|purpose|location)
.kb|VDKB|1|KB struct + facts + rules + terms + children + text + weight_refs + new_facts|data/kb/
.wt|VDWT|1|weight SoA arrays (v, r0, r1) for one matrix or vector|data/weights/
.snap|VDRS|4|full session snapshot (global view + session tree)|data/snapshots/
.dat|VDMF|1|manifest: index of all persisted KBs|data/manifest.dat
.compact|n/a|n/a|pipe-delimited compacted document for ingestion|data/incoming/
.json|n/a|n/a|system configuration|config.json
```

### I.2 KB File Section Order

```
# kb_file_sections(order|section|size_formula|required)
1|KbFileHeader|fixed (~128 bytes)|yes
2|KB struct|256 bytes|yes
3|Facts array|facts_count × 48|if facts_count > 0
4|Rules array|rules_count × 48|if rules_count > 0
5|Terms array|terms_count × 24|if terms_count > 0
6|Children ID array|children_count × 8|if children_count > 0
7|Text blob|variable|if text_length > 0
8|KbWeightRefs struct|~64 bytes|if has_weight_refs
9|TypedRelation array|relations_count × 48|if relations_count > 0
10|RelationIndex|~528 bytes|if has_relation_index
11|New-facts indices|new_facts_count × 4|if new_facts_count > 0
12|CompactionProfile|~256 bytes|if from_compaction
```

### I.3 Weight File Section Order

```
# weight_file_sections(order|section|size_formula)
1|WeightFileHeader|fixed (~64 bytes)
2|v array|element_count × 4 (i32)
3|r0 array|element_count × 2 (i16)
4|r1 array|element_count × 2 (i16)
```

---

## Appendix J: Compaction Format Quick Reference

### J.1 Table Types for Source Document Characters

```
# compaction_table_selection(source_character|required_tables|optional_tables)
philosophy/principles|concepts, principles, claims|axes, distinctions, examples
architecture spec|commitments, components, flows, boundaries|rules, validation
schema spec|entities, fields, discriminators, enumerations|lifecycle, validation
operational patterns|operations, rules, validation, failure_modes|examples, boundaries
API/protocol spec|operations, lifecycle, validation|flows, enumerations
construction/build|vocabulary, rules|anti_patterns (merged as concept category)
methodology/process|phases, steps, deliverables, criteria|validation, roles
data/reference|preserve source table structure|domain-specific
# Always include: relationships, section_index, decode_legend
# Anti-patterns always merge into concepts with category=anti_pattern
```

### J.2 Claim Type Vocabulary

```
# claim_types(type|meaning|prolog_handling|example)
axiom|foundational assumption, not derived|asserted unconditionally|"Remainder is not error"
derivation|follows from other stated principles|has dependency chain in rules|"Softmax sums to D because FRU"
observation|empirical finding|asserted with source provenance|"Division worse than mul for remainder"
prescription|recommended action|generates advisory rule|"Escalate to Q32 when r1 saturates"
reframe|existing concept redefined|shadows prior definition in scope|"Attention window is the KB tree"
distinction|boundary between two things|generates prevents/distinguishes edges|"System vs performance scalability"
```

### J.3 Compression Ratio Targets

```
# compression_targets(source_type|target_reduction_pct|reason)
philosophy/synthesis|85-93|most prose-heavy, most repetition to remove
architecture/methodology|80-85|moderate prose, some existing structure
schema specs|75-85|already partially structured
data/reference|60-75|mostly reformatting, minimal prose removal
# If output > target: keeping too much prose. If output < target: dropping data.
```

---

## Appendix K: Seed KB Contents

### K.1 Seed KB Summary

```
# seed_kbs(id|path|content_type|entry_count|frozen|notes)
+1|root|container|0|no|tree root, not frozen (domain KBs added as children)
+2|root.system|container|0|yes|system KB parent
+3|root.system.oso|principles|15|yes|15 engineering principles
+4|root.system.confidence|table|11|yes|confidence table as facts
+5|root.system.builtins|declarations|448|yes|IOSE declarations for all builtins
+6|root.system.command_vocab|vocabulary|~300|yes|command token definitions
+7|root.system.hygiene|rules|~50|yes|self-maintenance Prolog rules
+8|root.system.embedding|weights|1|yes|vocab embedding WeightMatrix (8192 × 2048)
+9|root.system.output|weights|2|yes|lm_head WeightMatrix + final norm WeightVector
+10|root.templates|container|0|yes|template parent
+11|root.templates.sentences|grammars|~100|yes|sentence-level grammar templates
+12|root.templates.formats|grammars|~50|yes|output format templates
+13|root.system.relation_types|registry|20+|no|system-defined (frozen) + domain-registered (appendable)
+14|root.system.ingestion|queue|0|no|ingestion queue and CompactionProfile records
```

### K.2 Builtin Categories

```
# builtin_categories(id|name|count|grant_required|pure|examples)
0|text_ops|~40|no|yes|concat, split, trim, length, find, replace
1|collections|~30|no|yes|sort, reverse, unique, flatten, zip
2|sets|~15|no|yes|union, intersect, difference, subset, member
3|mappings|~20|no|yes|get, put, delete, keys, values, merge
4|closed_arithmetic|~25|no|yes|add, sub, mul, div, mod, abs, negate
5|comparison|~10|no|yes|eq, lt, gt, le, ge, between, clamp
6|rounding|~8|no|yes|floor, ceil, round, truncate (Q16 → integer)
7|integer_bit_ops|~12|no|yes|and, or, xor, shift_left, shift_right, popcount
8|linear_algebra|~20|no|yes|dot, matmul, transpose, scale, norm
9|statistics|~15|no|yes|mean, median, variance, min, max, sum, count
10|active_arithmetic|~15|no|yes|accumulate, running_sum, ema, derivative
11|structure_ops|~20|no|yes|path_resolve, tree_walk, depth, ancestors
12|number_theory|~12|no|yes|gcd, lcm, is_prime, factorize, modpow
13|polynomial|~8|no|yes|evaluate, roots, degree, coefficient
14|finite_field|~6|no|yes|ff_add, ff_mul, ff_inv, ff_pow
15|discrete_calculus|~8|no|yes|difference, summation, falling_factorial
16|op_filesystem|~20|yes(fs)|no|read_file, write_file, list_dir, stat
17|op_compile|~8|yes(compile)|no|compile_zig, check_syntax
18|op_execute|~10|yes(execute)|no|run_process, capture_output
19|op_lint|~6|yes(lint)|no|lint_check, format_check
20|op_network|~15|yes(network)|no|http_get, http_post, dns_resolve
21|op_process|~10|yes(process)|no|spawn, signal, wait, pid_info
# Total: 448 builtins across 22 categories
# Categories 0-15: pure, no grants, deterministic, cacheable
# Categories 16-21: operational, grant-gated, side effects, audited
```

---

## Appendix L: Model Architecture Comparison

### L.1 Conventional vs. Reduced Configuration

```
# model_comparison(parameter|conventional_16L|reduced_6L|reduction|what_replaced_it)
n_layers|16|6|62.5%|multi-hop → Prolog transitive closure
d_model|2048|2048|0%|unchanged, attention needs capacity
n_heads|16|12|25%|typed relation enum dispatch replaces some
d_head|128|170|+33%|fewer heads, each wider
mlp_dim|5632|2048|63.6%|facts in KBs, not weight patterns
vocab_size|32000|8192|74.4%|grammar rendering replaces token generation
total_params|~1B|~143M|85.7%|
weight_bytes_i16|~2 GB|~286 MB|85.7%|
per_token_MACs|~640M|~126M|80.3%|
single_core_tok_s|~37|~190|5.1×|
system_8core_tok_s|~296|~1520|5.1×|
```

### L.2 What Each Layer Does in Reduced Model

```
# layer_roles(layer|primary_function|what_it_replaced|KB_interaction)
1|token embedding, positional encoding|unchanged|reads embedding from root.system.embedding
2|basic syntactic patterns, phrase structure|unchanged|none
3|semantic understanding, intent classification|was layers 3-6 in conventional|reads prompt_input, prompt_last
4|KB address resolution, command recognition|was layers 7-10|resolves which KBs and rules are relevant
5|output planning, response strategy|was layers 11-14|decides: command, prose, or KB URL output
6|judgment calls, ambiguity handling, nuance|was layers 15-16|handles what L3 cannot
# Layers 1-2: understanding what was said
# Layers 3-4: deciding what to do about it
# Layers 5-6: deciding how to respond
# Everything structural (fact retrieval, relationship reasoning, transitive composition,
# inverse lookup, grammar rendering) runs at L3 on typed relations and Prolog rules.
```

---

## Appendix M: Build Step Validation Criteria

```
# build_validation(step|files|validation_command|pass_criterion)
1|build.zig, root.zig, vdr_arena.zig, vdr_types.zig|zig build && ./zig-out/bin/vdr-prolog-cpu|prints arena info, exits code 0
2|vdr_config.zig, config.json|load config, print parsed values|correct values printed, bad JSON exits code 1 with field name
3|vdr_arena.zig (ArenaSet)|allocate global + N per-core|prints arena layout matching config totals
4|vdr_thread_pool.zig|spawn N threads, join|all N threads spawn, pin, touch memory, join cleanly
5|vdr_http.zig|curl http://localhost:1138/health|returns {"status": "ok"}, clean shutdown on SIGTERM
6|vdr_work_queue.zig|POST request processed on pinned thread|response from pinned core, concurrent requests distribute
```

---

## Appendix N: Cross-Reference Index

### N.1 Struct → Spec Section Mapping

```
# struct_sections(struct|defined_in|primary_spec_section|related_sections)
VdrId|vdr_types.zig|3.1|3.2, 3.3, 3.4
Q16|vdr_types.zig|4.1|7.2, 7.3, 10.2, A.1-A.4
Q32|vdr_types.zig|4.2|7.4 (RMSNorm Newton-Raphson)
Q335|vdr_types.zig|4.2|domain KB physics data
Fact|vdr_types.zig|4.3|8.2, 9.1, 14
FactTag|vdr_types.zig|4.3|9.1 (relation, column_schema variants)
Provenance|vdr_types.zig|4.4|9.1, 10.2, B.1-B.3
KB|vdr_types.zig|4.5|8.1, 9.1, 10.1, 14, 15
WeightMatrix|vdr_types.zig|8.4|7.2, 8.2, 10.2, 15
GemmCache|vdr_types.zig|8.2|7.2
KbWeightRefs|vdr_types.zig|8.2|8.2, 8.3
RelationType|vdr_types.zig|4.7|9.1, 13.2-13.4, D.1-D.3
TypedRelation|vdr_types.zig|4.7|9.1, 13.2
RelationIndex|vdr_types.zig|4.7|13.2
DomainRelationDef|vdr_types.zig|4.7|D.3
CompactionProfile|vdr_types.zig|9.1|9.4
ModelReductionConfig|vdr_types.zig|18.2|19, L.1
Term|vdr_types.zig|4.6|13.1
Rule|vdr_types.zig|4.6|13.1
Session|vdr_types.zig|6.3, 11|6.2, 11.4
Arena|vdr_types.zig|5.1|5.2, 5.3, 10.1
SystemConfig|vdr_types.zig|18.1|all
LevelStats|vdr_types.zig|12.1|H.1, H.2
```

### N.2 File → Spec Section Mapping

```
# file_sections(file|spec_sections|description)
vdr_types.zig|4, 4.7|all persistent structs and enums
vdr_ingestion.zig|9|parse-time structs, parser, validator
vdr_arena.zig|5|arena allocator, ArenaSet
vdr_config.zig|18|JSON config loading
vdr_thread_pool.zig|6.1, 7|pinned threads, lifecycle
vdr_work_queue.zig|6.2|atomic ring buffer
vdr_http.zig|6|HTTP listener and handlers
vdr_ops.zig|7|SIMD operations
vdr_model.zig|8|weight retrieval, forward pass
vdr_kb_store.zig|14|KB CRUD, path index
vdr_relation.zig|4.7, 13.2-13.4|relation index, typed queries
vdr_prolog.zig|13|unification, query, backtracking
vdr_grammar.zig|4.5 (Grammar)|template compile, render
vdr_session.zig|6.3, 11|session lifecycle, _llm.* subtree
vdr_persist.zig|15|save/load KB and weight files, manifest
vdr_snapshot.zig|16|session snapshots
vdr_training.zig|10|training arenas, weight update
vdr_runner.zig|K.1 (runners)|poller, processor, internal, batch
vdr_inference.zig|12|inference loop, prompt cycle
vdr_command.zig|4.8 (Command)|command parser, executor
vdr_access.zig|8.3, 14|visibility, group weight access
vdr_grant.zig|4.8 (Grant)|grant CRUD
vdr_audit.zig|4.8 (AuditEntry)|ring buffer, query
vdr_confidence.zig|4.9, B|confidence operations
vdr_seed.zig|17|seed layer init
vdr_builtin.zig|K.2|448 builtins
vdr_system.zig|23|top-level init
vdr_test.zig|24 (Stage 7)|test suite
```

### N.3 Invariant → Enforcement Location

```
# invariant_enforcement(invariant|number|enforced_in|how)
remainder never discarded|1|vdr_ops.zig|every divTrunc followed by mod capture
r0 r1 carry meaning|2|vdr_ops.zig, vdr_types.zig (Q16)|all arithmetic propagates both
softmax exact unity|3|vdr_ops.zig (softmax)|FRU deficit assignment, tested per call
three-field comparison|4|vdr_types.zig (Q16.compare)|lexicographic across v, r0, r1
i64 accumulation|5|vdr_ops.zig (GEMM, dot)|widen before multiply
no float|6|build.zig, all files|no f32/f64 imports or casts anywhere
r1 sentinel|7|vdr_ops.zig, vdr_training.zig|check after chains, escalate to Q32
sign-bit partition|8|vdr_types.zig (VdrId)|isGlobal/isEphemeral methods
session death|9|vdr_session.zig|arena reset on kill
arena exhaustion|10|vdr_arena.zig|alloc returns null, callers check
SIMD == scalar|11|vdr_test.zig|bit-identical comparison test
training arenas only post-init|12|vdr_training.zig|canTrain + cleanupTraining
fixed _llm.* subtree|13|vdr_session.zig|template clone, no top-level creation
ArrayListManaged rule|14|all files|code review enforcement
fromParts three args|15|vdr_types.zig|function signature enforces
relation slots frozen|16|vdr_types.zig (RelationType)|enum is compile-time
domain slots first-come|17|vdr_relation.zig|registration checks existing slot
TAG_RELATION provenance|18|vdr_relation.zig, vdr_kb_store.zig|assert Fact alongside TypedRelation
index eventually consistent|19|vdr_relation.zig|rebuild on interval, not per-assertion
typed bypass unification|20|vdr_relation.zig|separate query path, no Term construction
model reduction advisory|21|vdr_config.zig|config JSON sets, estimatedWeightBytes computes
profiles immutable|22|vdr_ingestion.zig|no update after initial write
per-thread GEMM|23|vdr_ops.zig|no thread_pool param, no row splitting
lazy loading|24|vdr_persist.zig|manifest only at startup, load on access
```

---

# VDR-Prolog Technical Specification — Addendum

## Prolog Knowledge Composition, Utility AI Scoring, and Finite State Machine Integration

### Addendum to Version 0.4

---

## A1. Purpose

This addendum specifies how three mechanical reasoning systems compose into a unified decision pipeline:

**Finite State Machines** determine what state the system is in and which behavior sets are valid. State transitions are Prolog rules — when conditions match, the state updates.

**Utility AI Scoring** evaluates candidate behaviors within the current state's behavior set, scoring each against multiple considerations and selecting the winner via compensated multiplication.

**Prolog Knowledge Composition** provides the reasoning substrate — typed relations, transitive closure, inheritance, inverse dispatch — that both FSMs and UAI considerations read from.

The LLM is the judgment layer. It sees the mechanical results (which state, which behavior was scored highest, what the scores were), can accept or override, and handles situations where the mechanical pipeline has no coverage. The pipeline logs everything to `session_root._llm.prompt_current` so the LLM can direct attention to what changed.

---

## A2. The Unified Pipeline

```
Current FSM State
    ↓
State determines valid BehaviorSet
    ↓
UAI evaluates all Behaviors in the set
    (each Consideration reads context via Prolog queries / KB facts / relation index)
    ↓
Scores combined via Dave Mark compensation
    ↓
Selection method picks winner
    ↓
Result logged to prompt_current (new_items_counter incremented)
    ↓
Winner executed (Prolog query, builtin call, KB assert, command)
    OR
LLM reads result, overrides, or frames response
    ↓
Post-execution: check FSM transition rules
    ↓
If transition fires → new state → new behavior set available next cycle
```

This pipeline runs at L3 when all components resolve mechanically. It drops to L2 when the LLM must select between ambiguous candidates. It drops to L1 when no FSM state, behavior set, or rule covers the situation.

---

## A3. FSM as State Manager

### A3.1 FSM Representation in KBs

An FSM is a KB subtree. The machine definition, states, transitions, and output associations are facts and rules:

```
root.system.fsm.session_lifecycle          ← machine definition KB
    states: [created, active, suspended, ejected, killed]
    initial: created
    current: active                         ← mutable fact, updated on transition

root.system.fsm.session_lifecycle.transitions   ← transition rules KB
    rule: evolves_to(created, active) :- session_initialized(Session).
    rule: evolves_to(active, suspended) :- idle_timeout_exceeded(Session).
    rule: evolves_to(active, ejected) :- arena_pressure_high, lru_coldest(Session).
    rule: evolves_to(ejected, active) :- snapshot_exists(Session), restore_requested.
    rule: evolves_to(active, killed) :- kill_requested(Session).

root.system.fsm.session_lifecycle.outputs      ← state→behavior_set mapping
    fact: state_behavior_set(active, root.system.scoring.active_session_behaviors)
    fact: state_behavior_set(suspended, root.system.scoring.suspended_behaviors)
    fact: state_behavior_set(ejected, root.system.scoring.ejection_behaviors)
```

### A3.2 FSM Types

The system uses four FSM patterns, each a different KB shape:

**Moore (output per state).** State determines the behavior set. Session lifecycle, KB lifecycle, inference cycle. The behavior set doesn't change until the state changes.

**Mealy (output per transition).** Transition determines the action. HTTP request lifecycle. The action fires during the transition, not after settling into a state.

**DFA (recognition).** Accepts or rejects input patterns. Query classification (is this an L3/L2/L1 query). Level selection FSM.

**Statechart (hierarchical + concurrent).** Nested states with parallel regions. Complex domain AI (boss AI with strategic/tactical/moment layers). Uses `extends` relation on base Moore/Mealy types.

### A3.3 Current State Tracking

Each FSM instance has a mutable `current_state` fact in its machine KB. Updated atomically on transition:

```
root.system.fsm.session_lifecycle
    facts[0] = TAG_VALUE: current_state = state_atom_id    ← updated on transition
    facts[1] = TAG_VALUE: previous_state = state_atom_id   ← set before update
    facts[2] = TAG_VALUE: last_transition_time = timestamp
    facts[3] = TAG_VALUE: transition_count = counter
```

Session-local FSMs (per-session state machines like conversation phase tracking) live in the session's ephemeral tree:

```
session_root._llm.fsm.conversation_phase
    current_state = greeting
    transitions: greeting → information_gathering → deliberation → response → follow_up
```

### A3.4 Transition Evaluation

Transitions are Prolog rules. The engine checks them on every cycle (or on demand):

```zig
fn evaluateTransitions(
    fsm_kb: *KB,
    engine: *PrologEngine,
) ?StateTransition {
    const current = readCurrentState(fsm_kb, engine.global_arena);
    const transitions_kb = resolveChild(fsm_kb, "transitions", engine.store);

    const rules = getRuleSlice(transitions_kb, engine.global_arena);
    for (rules) |*rule| {
        // Rule head: evolves_to(CurrentState, NextState)
        const head = engine.getTerm(rule.head);
        if (!head.isCompound()) continue;

        const args = engine.getCompoundArgs(head);
        const from_state = &args[0];
        const to_state = &args[1];

        // Check if from_state matches current
        if (!engine.termMatchesAtom(from_state, current)) continue;

        // Try to satisfy body (transition conditions)
        const body_result = engine.satisfyBody(rule, engine.config);
        if (body_result) {
            return StateTransition{
                .from = current,
                .to = engine.termToAtomId(to_state),
                .rule_id = rule.id,
                .timestamp = currentTimestamp(),
            };
        }
    }

    return null; // no transition fires
}
```

When a transition fires:

1. `previous_state` set to `current_state`.
2. `current_state` set to the new state.
3. `last_transition_time` updated.
4. `transition_count` incremented.
5. Transition logged to `prompt_current` with the triggering rule ID.
6. If the FSM is Mealy, the transition's output action executes immediately.
7. The new state's behavior set becomes active for the next scoring cycle.

---

## A4. State-to-BehaviorSet Binding

### A4.1 The Mapping

Each FSM state maps to a BehaviorSet via `state_behavior_set` facts in the FSM's outputs KB:

```prolog
state_behavior_set(active, root.system.scoring.active_session_behaviors).
state_behavior_set(suspended, root.system.scoring.suspended_behaviors).
state_behavior_set(ejected, root.system.scoring.ejection_behaviors).
```

Resolution is a single Prolog query:

```prolog
current_behavior_set(Session, SetId) :-
    session_fsm(Session, FsmKb),
    current_state(FsmKb, State),
    state_behavior_set(State, SetId).
```

This is L3 — three fact reads, no LLM tokens.

### A4.2 Hierarchical State Machines

For statecharts with nested states, the behavior set is the union of the active states across all hierarchy levels:

```
root.domain.game.boss_ai.fsm
    strategic_layer:  current_state = phase_2
    tactical_layer:   current_state = ranged_attack
    moment_layer:     current_state = aiming

    state_behavior_set(phase_2, boss_phase2_behaviors)
    state_behavior_set(ranged_attack, ranged_attack_behaviors)
    state_behavior_set(aiming, aiming_behaviors)
```

The scoring system evaluates each layer's behavior set independently (parallel reasoners, RS6 from the UAI spec). Each layer produces a winner. The results compose: strategic decides the phase, tactical decides the action type, moment decides the immediate response.

---

## A5. UAI Scoring Within State Context

### A5.1 Scoring Cycle

On each inference cycle (or on demand), the scoring pipeline runs:

```
1. Read current FSM state.
2. Resolve behavior set for this state.
3. Build ScoringContext from session state, KB data, relation index.
4. Evaluate all behaviors in the set:
   a. For each behavior, evaluate all considerations.
   b. Separate gates from soft preferences.
   c. Gates checked first — any gate failure eliminates the behavior.
   d. Soft scores combined via compensated multiplication.
   e. Behavior weight and floor applied.
5. Sort behaviors by final score descending.
6. Select winner via selection method (argmax, weighted random, etc.).
7. Log result to prompt_current.
8. Execute winner's action (or defer to LLM).
```

### A5.2 Considerations Read from Prolog

Considerations can read their input values from any system data source. The critical ones for system-level decisions:

**Relation coverage.** "How many typed relations of the needed type exist?" Reads from RelationIndex `by_type_counts`. High coverage → L3 viable.

**Rule match count.** "How many Prolog rules match this query's functor?" Reads from functor scan or FunctorIndex. High match count → L2 viable.

**Confidence level.** "How confident is the available data?" Reads from Provenance on matching facts. High confidence → trust the mechanical result.

**Arena pressure.** "How full is the global arena?" Reads from `arena.usedBytes() / arena.size`. High pressure → prefer eviction and conservation behaviors.

**Session activity.** "How recently was this session used?" Reads from `last_active_timestamp`. Low recency → candidate for eviction.

**LevelStats ratios.** "What fraction of queries resolve at L3?" Reads from `l3_count / totalCount()`. Declining ratio → compaction pipeline needs more data.

Each of these is a Consideration with an InputSource, a ResponseCurve, and a weight. The curves and weights are facts in KBs — tunable without code changes.

### A5.3 Dave Mark Compensation in Q16

The compensation formula runs entirely in Q16 exact integer arithmetic:

```
For n considerations with scores s₁..sₙ:
    modification_factor = (n-1)/n       ← Q16 division with remainder
    For each sᵢ:
        make_up = (D - sᵢ) × modification_factor / D
        compensated_i = sᵢ + (make_up × sᵢ / D)
    final = ∏(compensated_i)            ← Q16 multiplication chain

No float. No NaN. No infinity. Remainder tracked at every step.
```

An epsilon floor (default Q16 v=655, approximately 1% of D) prevents true-zero veto in multiplication. Gate considerations are evaluated separately and do not participate in compensation — they are binary pass/fail prerequisites.

---

## A6. Logging to prompt_current

### A6.1 What Gets Logged

Every mechanical decision logs a structured fact to `session_root._llm.prompt_current`:

```
FSM transition:
    TAG_TEXT fact: "fsm_transition|session_lifecycle|active→suspended|idle_timeout|t=1234567"

UAI scoring result:
    TAG_TEXT fact: "uai_result|active_behaviors|winner=behavior_l3|score=58200|method=argmax"
    TAG_TEXT fact: "uai_scores|behavior_l3=58200|behavior_l2=42100|behavior_l1=12400"

Typed relation query result:
    TAG_TEXT fact: "relation_result|enables(P1,X)|results=3|AR1,AR2,AR3"

Prolog rule fire:
    TAG_TEXT fact: "rule_fire|escalation_rule|kb=root.ops.incidents|success=true"
```

### A6.2 The Attention Counter

The session tracks how many items the LLM has already seen in `prompt_current` versus how many exist:

```
session_root._llm.prompt_current
    facts[0] = TAG_VALUE: items_seen_by_llm = 5      ← LLM updates after reading
    facts[1] = TAG_VALUE: items_total = 8             ← system updates on each log
    facts[2..N] = logged results
```

The LLM reads `items_total - items_seen_by_llm` to know how many new items it hasn't processed. After reading and incorporating them, it updates `items_seen_by_llm`. This prevents the LLM from re-reading old results or missing new ones.

The counter mechanism is simple: two i32 facts. The system increments `items_total` on every log write. The LLM increments `items_seen_by_llm` after reading. The difference is the unread count. No ring buffer, no complex synchronization — the `prompt_current` KB is cleared every cycle anyway, so the counters reset to 0 at cycle boundaries.

### A6.3 What the LLM Does With It

The LLM reads the logged results during generation (Phase 5 of the inference loop). It sees:

- Which FSM state the system is in.
- Which behavior set was evaluated.
- What the top scores were and which behavior won.
- What relation queries were resolved at L3.
- What rules fired.

It can then:

- **Accept the mechanical result.** Frame it as a user-facing response. Cost: ~20 tokens of framing prose. This is the common case.
- **Override.** The LLM disagrees with the scoring — maybe the highest-scoring behavior is contextually inappropriate. It selects a different behavior or generates a fully custom response. Cost: L1 (50-500 tokens).
- **Augment.** The mechanical result is correct but incomplete. The LLM adds context, caveats, or follow-up questions. Cost: ~30-50 tokens.
- **Escalate.** The mechanical result indicates uncertainty (multiple behaviors scored within 5% of each other, or the winning score is below a threshold). The LLM asks for clarification or takes a conservative action. Cost: L2-L1.

---

## A7. The Full Decision Loop

### A7.1 One Complete Cycle

```
1. User input arrives in prompt_input.

2. Pre-resolution:
   a. Classify query pattern (structural pattern detection).
   b. If L3 candidate found → attempt typed relation query / Prolog rule.
   c. Log result to prompt_current, increment items_total.

3. FSM evaluation:
   a. For each active FSM (system + session-local):
      - Check transition rules against current context.
      - If transition fires: update state, log to prompt_current.
   b. Resolve current behavior set from current state.

4. UAI scoring:
   a. Build ScoringContext from session state.
   b. Evaluate behavior set for current FSM state.
   c. Select winner.
   d. Log scores and winner to prompt_current.

5. Execution decision:
   a. If pre-resolution answered the query completely (L3):
      → Log answer. LLM frames response.
   b. If UAI winner has a direct action (Prolog query, builtin, KB assert):
      → Execute action. Log result. LLM frames response.
   c. If UAI winner is "defer_to_llm" or score is below confidence threshold:
      → LLM runs full forward pass (L1).

6. LLM generation:
   a. LLM reads prompt_last for continuity.
   b. LLM reads prompt_current for new items (items_total - items_seen_by_llm).
   c. LLM generates response:
      - Frames mechanical results as user-facing text.
      - Overrides if judgment says mechanical result is wrong.
      - Fills gaps where no mechanical coverage exists.
   d. LLM writes to prompt_next for continuity.
   e. LLM updates items_seen_by_llm.

7. Post-generation:
   a. Re-evaluate FSM transitions (generation may have changed context).
   b. If transition fires: update state for next cycle.
   c. System copies prompt_next → prompt_last.
   d. prompt_next and prompt_current cleared (counters reset to 0).
```

### A7.2 Execution Levels in the Full Loop

```
L3 (zero tokens):
    - Pre-resolution typed relation query succeeds.
    - FSM transition fires from ground facts.
    - UAI scoring evaluates and selects winner.
    - Winner's action executes (Prolog query, KB assert).
    - All results logged mechanically.
    → LLM frames (~20 tokens). Total: ~20 tokens.

L2 (~18 tokens):
    - Pre-resolution finds candidates but can't disambiguate.
    - UAI has multiple behaviors within 5% of each other.
    - LLM selects from candidates, emits command.
    - Prolog executes the selected command.
    → LLM selects + frames (~38 tokens). Total: ~38 tokens.

L1 (50-500 tokens):
    - No FSM state covers this situation.
    - No behavior set applies.
    - No typed relations or rules match.
    - LLM runs full forward pass from weights.
    → Full generation. Total: 50-500 tokens.
```

---

## A8. System-Level FSMs

### A8.1 Defined FSMs

The system ships with these FSMs as seed KBs:

**Session Lifecycle FSM** (Moore, root.system.fsm.session_lifecycle):
```
States: created → active ↔ suspended → ejected ↔ active → killed
Output: behavior set per state
Transitions: Prolog rules checking session counters, timestamps, arena pressure
```

**HTTP Request Lifecycle FSM** (Mealy, root.system.fsm.http_lifecycle):
```
States: received → parsed → queued → processing → responded
Error states: error_400 (malformed), error_503 (queue full), error_504 (timeout)
Output: action per transition (push to queue, signal completion, send response)
```

**Inference Cycle FSM** (Moore, root.system.fsm.inference_cycle):
```
States: input → read → resolve_weights → forward → generate → postprocess → snapshot_check → (cycle)
Output: which engine function to call per state
Transition: sequential, always proceeds to next state
```

**Level Selection FSM** (DFA, root.system.fsm.level_selection):
```
States: query_received → classify_l3 → (execute_l3 | classify_l2) → (execute_l2 | execute_l1)
Accepts: the query, classified into L3/L2/L1 terminal states
Transitions: based on QueryClassification results
```

**KB Lifecycle FSM** (Moore, root.system.fsm.kb_lifecycle):
```
States: unloaded → loading → loaded ↔ training → loaded → frozen
                                    ↔ saving → loaded
Output: which operations are valid per state (e.g., training only valid in loaded state)
```

### A8.2 Session-Local FSMs

Sessions can create their own FSMs in the ephemeral tree for domain-specific state tracking:

```
session_root._llm.fsm.conversation_phase
    States: greeting → understanding → deliberation → response → follow_up
    Transitions fire based on prompt_input content classification

session_root._llm.fsm.task_tracker
    States: idle → planning → executing → reviewing → complete
    Transitions fire based on command results and user feedback

session_root.domain.game.npc_42.combat_fsm
    States: patrol → alert → engage → flee → dead
    Transitions fire based on threat level, health, distance considerations
```

Session-local FSMs die with the session (negative IDs, ephemeral arena). They are snapshotted with the session and restored on reconnection.

---

## A9. Domain-Agnostic Prolog Rules for the Pipeline

### A9.1 FSM Rules

```prolog
%% Get current behavior set from FSM state
current_behavior_set(FsmKb, SetId) :-
    current_state(FsmKb, State),
    state_behavior_set(State, SetId).

%% Check if a transition is available
transition_available(FsmKb, NextState) :-
    current_state(FsmKb, Current),
    evolves_to(Current, NextState).

%% Check if current state is terminal (no outgoing transitions)
is_terminal_state(FsmKb) :-
    current_state(FsmKb, State),
    \+ evolves_to(State, _).
```

### A9.2 UAI Rules

```prolog
%% Evaluate and select best behavior for current state
select_behavior(FsmKb, WinnerId, Score) :-
    current_behavior_set(FsmKb, SetId),
    evaluate_behavior_set(SetId, WinnerId, Score).

%% Check if selected behavior meets confidence threshold
behavior_confident(SetId, Threshold) :-
    evaluate_behavior_set(SetId, _, Score),
    Score >= Threshold.

%% Fall back to LLM when scoring is ambiguous
needs_llm_judgment(SetId) :-
    evaluate_behavior_set(SetId, _, TopScore),
    second_best_score(SetId, SecondScore),
    Margin is TopScore - SecondScore,
    Margin < 3277.    %% less than 5% of D
```

### A9.3 Structural Rules That Feed Considerations

```prolog
%% Relation coverage for a query type (feeds UAI consideration)
relation_coverage(RelType, Count) :-
    relation_type_count(RelType, Count).

%% Rule match count for a functor (feeds UAI consideration)
rule_coverage(Functor, Arity, Count) :-
    functor_rule_count(Functor, Arity, Count).

%% Confidence of best available data for a query
best_confidence(KbId, Slot, Confidence) :-
    fact_confidence(KbId, Slot, Confidence).

%% Inheritance-expanded requirements (feeds gate considerations)
all_requirements(Entity, Requirements) :-
    findall(R, requires(Entity, R), DirectReqs),
    findall(R, (specializes(Entity, Ancestor), requires(Ancestor, R)), InheritedReqs),
    append(DirectReqs, InheritedReqs, Requirements).
```

---

## A10. Cross-Domain Knowledge Composition

### A10.1 How Documents Connect Through Typed Relations

Every compacted document produces typed relations using canonical RelationType values. Documents connect through shared edges without explicit cross-references. The structural rules fire identically whether two edges are in the same document or different documents. The engine sees only VdrIds and RelationType — no document boundary.

**Transitive chain across documents:**
```prolog
%% Movement: enables(force, acceleration)
%% Physics: enables(acceleration, velocity_change)
%% Derived: enables(force, velocity_change)   ← L3 BFS, zero tokens
```

**Inheritance across documents:**
```prolog
%% Data Structures: specializes(avl_tree, bst)
%% Data Structures: validates(invariant, bst)
%% Derived: validates(invariant, avl_tree)     ← inheritance rule, L3
```

**Inverse bridging across documents:**
```prolog
%% Philosophy: enables(syllogism, propositional_logic)
%% Query: depends_on(propositional_logic, X)
%% Derived: X = syllogism                      ← inverse dispatch, L3
```

### A10.2 Bridge Documents

Certain documents serve as structural bridges between otherwise independent domains:

- **English** (grammar + phrasing + vocabulary) bridges all domains to human communication.
- **Connections** bridges all domains via a taxonomy of relatedness.
- **Movement** bridges all domains via a taxonomy of change.
- **Math Logic** bridges all domains via formalization of inference.
- **Math Foundations** bridges all domains via mathematical structures.

These five bridge documents plus domain-specific documents form a lattice where any two domains connect through at most two bridge hops. All connections are typed relations with known algebraic properties. All traversal is L3.

### A10.3 The RelationType Algebra

Three compile-time properties generate all structural inference:

**Transitivity** (10 system types): `enables`, `requires`, `specializes`, `generalizes`, `part_of`, `contains`, `follows`, `precedes`, `depends_on`, `extends`. Chain composition via BFS.

**Symmetry** (4 system types): `prevents`, `contradicts`, `equivalent_to`, `approximates`. Auto-query with swapped from/to.

**Inverse** (10 pairs): `enables`↔`depends_on`, `specializes`↔`generalizes`, `part_of`↔`contains`, `follows`↔`precedes`, `validates`↔`verified_by`, `causes`↔`determined_by`. One index serves both directions.

These properties compose. Transitive + inverse means the closure of `enables` automatically provides the closure of `depends_on`. Symmetric + transitive (`equivalent_to`) produces equivalence classes via BFS.

Domain-registered relation types (slots 64-127) declare their properties at registration time and participate in the same algebraic inference.

---

## A11. Confidence Propagation Through the Pipeline

### A11.1 Through Typed Relations

Every TypedRelation carries Provenance with a confidence Q16 value. Derived facts from transitive closure, inverse dispatch, or inheritance get confidence = minimum of the input confidences in the chain.

### A11.2 Through UAI Scoring

UAI considerations can read confidence values as inputs. A consideration that reads confidence and applies a sigmoid curve produces high scores for high-confidence data and low scores for low-confidence data. This means the scoring system naturally prefers behaviors backed by confident data.

### A11.3 Through FSM Transitions

Transition rules can include confidence checks in their body:

```prolog
evolves_to(tentative, confirmed) :-
    fact_confidence(TargetKb, TargetSlot, Confidence),
    Confidence >= 52428.     %% published level (80/100)
```

This means the FSM won't transition to a "confirmed" state until the underlying data reaches a confidence threshold. The mechanical pipeline self-regulates based on data quality.

---

## A12. New Invariants

```
25. FSM current_state is always a valid atom in the machine's state set.
26. FSM transitions fire only from the current state — not from arbitrary states.
27. Every FSM state maps to exactly one behavior set (or none for terminal states).
28. UAI scoring never produces NaN or infinity — Q16 arithmetic prevents this structurally.
29. Dave Mark compensation factor (1-1/n) is computed in Q16 with exact remainder.
30. Gate considerations do not participate in compensation — they are binary pass/fail.
31. The items_seen_by_llm counter never exceeds items_total.
32. prompt_current counters reset to 0 when the KB is cleared at cycle boundary.
33. Session-local FSMs die with the session. Their states do not leak to global.
34. Transition evaluation and UAI scoring both run on the pinned compute thread — never on HTTP threads.
35. BehaviorSet evaluation is deterministic for argmax selection. Weighted random uses the session's deterministic PRNG seeded from session ID + turn count.
```

---

## A13. New Seed KB

```
root.system.scoring             id: +15    (behavior sets for system decisions)
root.system.fsm                 id: +16    (system-level FSM definitions)

SEED.SCORING = .{ .v = 15 };
SEED.FSM = .{ .v = 16 };
SEED_KB_COUNT = 16;             // was 15
```

---

## A14. Implementation File

```
vdr_scoring.zig    — ResponseCurve, Consideration, Behavior, BehaviorSet,
                     ScoringContext, ScoringResult, compensation pipeline,
                     curve evaluation, selection methods, scoring builtins
vdr_fsm.zig        — FSM state management, transition evaluation,
                     state→behavior_set resolution, FSM lifecycle,
                     system FSM definitions
```

Both files import from `vdr_types.zig` for all struct definitions. The scoring builtins register in `vdr_builtin.zig` under category 22 (scoring). The FSM-specific builtins (current_state, evolves_to, transition_available) register under a new category 23 (fsm).

Total estimated addition: ~3,000 lines across both files. Stage 4 (Ingestion + Relations) in the implementation plan expands to include these, or they form a new Stage 4b after relations are working.
