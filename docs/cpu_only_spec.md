# VDR-Prolog Technical Specification

## CPU SIMD, Arena-Only, NUMA-Aligned

### Version 0.3 — Laptop Target

---

## 1. Scope

This spec defines the complete VDR-Prolog system running on a single laptop. No GPU. No device/host split. All compute is CPU with AVX2 SIMD. All memory is fixed-size arenas allocated at startup. No malloc after init (one bounded exception: temporary training arenas, destroyed after use). Target: Dell Legion 5 (~2019), 6-8 core x86_64, 16-32GB RAM, AVX2. Zig 0.15.1.

The model is not a monolith. Model weights live in KBs alongside the domain data they serve. Access to weight KBs is grant-gated. Different users see different model capabilities. Each LLM session gets a structured session KB subtree for context management and scratch work, addressed with negative IDs that never collide with global data.

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
│  │  Grant Store │ Audit Ring │ Confidence Table              │  │
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
│  │              Orchestration                               │  │
│  │  Session Mgr │ Runner Sched │ Grant Enforcer │ Snapshot  │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │              Engines (direct function calls)             │  │
│  │  LLM (SIMD) │ KB Store │ Prolog │ Grammar │ Builtins    │  │
│  └─────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

One process. N+1 arenas (1 global + N per-core). Pinned compute threads do all SIMD work. Non-pinned HTTP threads handle I/O and push work to per-core atomic ring buffer queues. Direct function calls between engines. No IPC, no serialization bridge, no mutex on the hot path.

---

## 3. ID System — Dual Addressing with Sign-Bit Partitioning

### 3.1 ID Structure

Every entity (KB, fact slot, rule, term, grammar) has a 64-bit ID. Bit 63 (sign bit) partitions the address space:

```
Bit 63 = 0: Global (positive). Persistent. Shared across sessions.
Bit 63 = 1: Session (negative). Session-local. Dies with session.
```

Global IDs are UUID-derived, always positive. Session IDs are monotonically decrementing negative integers, unique within a session.

```
struct VdrId {
    v: i64,   // positive = global, negative = session

    pub fn isGlobal(self: VdrId) bool { return self.v >= 0; }
    pub fn isSession(self: VdrId) bool { return self.v < 0; }
};
```

### 3.2 UUID Generation

Global IDs are UUIDs with bit 63 cleared (always positive). Generated from a counter + hash at KB creation time. Immutable once assigned.

```
fn generateGlobalId(counter: *i64) VdrId {
    counter.* += 1;
    const raw = hashU64(counter.*);
    return .{ .v = @as(i64, @intCast(raw & 0x7FFFFFFFFFFFFFFF)) };
}
```

### 3.3 Session ID Generation

Each session owns a decrementing counter starting at -1.

```
fn generateSessionId(counter: *i64) VdrId {
    const id = counter.*;
    counter.* -= 1;
    return .{ .v = id };  // -1, -2, -3, ...
}
```

Session IDs never collide with global IDs. Session A's -5 and session B's -5 are in different session scopes — they never share an arena or namespace.

### 3.4 Three Levels of Addressing

Every entity is reachable three ways:

**UUID** — signed 64-bit, globally unique. Stored in a LUT for O(1) direct access. KBs, facts, rules, grammars — everything gets a UUID. Positive for global, negative for session.

**Dotted path** — hierarchical mount path from root. Global paths start from `root` (ID 0). Session paths start from `session_root` (ID -1). Used for tree traversal and human-readable references.

**Local index** — array slot within a KB for a given data type. Position in the KB's array. First fact is 0, second is 1, etc. Meaningful only within that KB.

```
root.science.physics.qed.alpha_em
  walk:   0.0.0.0.0                   (tree position, local indices)
  direct: UUID +9153                   (hash-based, one hop via LUT)
  local:  facts[0] within qed KB      (array slot)
```

All three resolve to the same data.

### 3.5 Session Tree

Each session gets a session root at ID -1. The session can create KBs that mirror global structure for shadowing, or create entirely new paths for scratch work.

```
session_root                           UUID: -1
session_root.science                   UUID: -2     local index: 0
session_root.science.physics           UUID: -3     local index: 0
session_root.science.physics.qed       UUID: -4     local index: 0
```

Session KBs copy the structure of the global path at the mount point. From there, the session adds its own data with negative UUIDs:

```
session_root.science.physics.qed.alpha_strong    UUID: -5    local index: 0
session_root.science.physics.qed.notes           UUID: -6    local index: 1
```

Session UUIDs are always negative. Global UUIDs are always positive. They never collide.

### 3.6 Session-to-Global Resolution

When the LLM queries a path, session takes priority:

```
Query: root.science.physics.qed.alpha_em

Resolution order:
1. Check session tree: session_root.science.physics.qed.alpha_em
   If found → return session version
2. Check global tree: root.science.physics.qed.alpha_em
   If found → return global version
3. Not found → walk parent chain for scoped search
```

A session can override global data locally without modifying the global store. The override dies with the session.

### 3.7 Session-to-Global Promotion

When the LLM decides session data is worth keeping globally, it explicitly asserts to a global KB path. The data crosses from negative to positive address space with a new positive UUID. Session data never leaks to global implicitly.

```
CMD_KB_ASSERT root.science.physics.qed.alpha_strong fact(value, 11800)
```

The session version can be retracted or left to die with the session.

---

## 4. Core Data Types

### 4.1 VDR Value Types

```
// Q16 — the primary operational type
// 8 bytes. Two remainder slots.
struct VdrQ16 {
    v: i32,       // numerator (value / D)
    r0: i16,      // remainder level 0
    r1: i16,      // remainder level 1 (sub-r0 precision)
};
// D = 65536 (2^16). Implicit. Never stored.
// sizeof(VdrQ16) = 8 bytes.
// r0 = exact remainder from divTrunc by D. Not error.
// r1 = sub-r0 precision from cross-terms in mul/div. Not padding.
// Scalar projection: (v + (r0 + r1/32768) / 65536) / 65536
// But no projection is ever performed inside the system.

// Q32 — intermediate precision
struct VdrQ32 {
    v: i64,
    r0: i32,
    r1: i32,
};
// D = 4294967296 (2^32). sizeof = 16 bytes.

// Q335 — high precision / transcendentals / physics work
struct VdrQ335 {
    v: [6]i64,      // 384-bit value as 6 × 64-bit limbs
    r0: [6]i64,
    r1: [6]i64,
    r2: [6]i64,
    r3: [6]i64,
};
// D = 2^335. sizeof = 240 bytes. 4 remainder slots.
```

### 4.2 Q16 Remainder Propagation Rules

**Addition:**
```
a + b:
    r1_sum = a.r1 + b.r1
    r1_carry = r1_sum / 32768
    new_r1 = r1_sum % 32768

    r0_sum = a.r0 + b.r0 + r1_carry
    r0_carry = 1 if r0_sum >= D else 0
    new_r0 = r0_sum % D

    new_v = a.v + b.v + r0_carry
```

**Subtraction:** Mirror of addition with borrows instead of carries.

```
a - b:
    r1_diff = a.r1 - b.r1
    r1_borrow = 1 if r1_diff < 0 else 0
    if r1_diff < 0: r1_diff += 32768

    r0_diff = a.r0 - b.r0 - r1_borrow
    r0_borrow = 1 if r0_diff < 0 else 0
    if r0_diff < 0: r0_diff += D

    new_v = a.v - b.v - r0_borrow
```

**Multiplication:**
```
a * b:
    product = (i64)a.v * (i64)b.v
    new_v = product / D          (integer division)
    new_r0 = product % D         (exact remainder)

    r1_cross = (i64)a.r0 * (i64)b.v + (i64)b.r0 * (i64)a.v
    new_r1 = (r1_cross / D) % 32768
```

The a.r0 × b.r0 cross-term is not captured in the two-level scheme. This is sub-r1 structure. If it matters, r1 tells you.

**Division:**
```
a / b:
    if b.v == 0: return zero (caller checks)
    widened = (i64)a.v * D
    new_v = widened / (i64)b.v
    r0_full = widened % (i64)b.v

    r1_widened = r0_full * D
    new_r1 = (r1_widened / (i64)b.v) % 32768
```

Division is worse than multiplication for remainder accumulation. Divisors that don't factor cleanly into D (like 3) produce remainder that never resolves. Chained divisions push r1 toward saturation faster than multiplication chains.

**Comparison:** Lexicographic across all three fields:
```
compare(a, b):
    if a.v != b.v: return sign(a.v - b.v)
    if a.r0 != b.r0: return sign(a.r0 - b.r0)
    if a.r1 != b.r1: return sign(a.r1 - b.r1)
    return 0
```

No epsilon. No tolerance. Equal means all three fields match.

**Precision sentinel:** r1 near ±32767 after a chain of operations means the Q16 frame is being stressed. Escalate that specific computation path to Q32. The decision is based on exact data, not heuristic.

### 4.3 Fact Types

```
enum VdrFactTag: i32 {
    TAG_VALUE       = 0,
    TAG_TEXT        = 1,
    TAG_REFERENCE   = 2,
    TAG_TIMESTAMP   = 3,
    TAG_ENUM        = 4,
    TAG_BOOLEAN     = 5,
    TAG_VECTOR      = 6,
    TAG_MATRIX      = 7,
    TAG_PROVENANCE  = 8,
    TAG_RULE_REF    = 9,
    TAG_GRAMMAR_REF = 10,
    TAG_COUNTER     = 11,
    TAG_EMPTY       = 255,
};

struct VdrProvenance {
    source_type: i32,
    source_kb_id: VdrId,
    source_slot_id: i32,
    confidence: VdrQ16,
    timestamp: i32,
    derivation_rule_id: i32,
    capability_level: i32,     // for per-weight access control
};
// sizeof = 36 bytes.

struct VdrFact {
    tag: VdrFactTag,
    value: VdrQ16,
    provenance: VdrProvenance,
};
// sizeof = 48 bytes (padded for alignment).
```

### 4.4 KB Type

```
struct VdrKb {
    // Identity
    id: VdrId,
    parent_id: VdrId,
    name_offset: i32,
    name_length: i16,
    path_offset: i32,
    path_length: i16,
    walk_id: i32,

    // Persistent stores (offsets into respective arena regions)
    facts_offset: i32,
    facts_count: i32,
    facts_capacity: i32,
    rules_offset: i32,
    rules_count: i32,
    rules_capacity: i32,
    constraints_offset: i32,
    constraints_count: i32,
    connections_offset: i32,
    connections_count: i32,
    grammars_offset: i32,
    grammars_count: i32,
    iose_offset: i32,

    // Weight references
    weight_refs_offset: i32,     // points to VdrKbWeightRefs in arena

    // Live state
    working_data_offset: i32,
    lru_table_offset: i32,
    lru_count: i16,
    counter_table_offset: i32,
    counter_count: i16,
    lock_table_offset: i32,
    lock_count: i16,
    queue_table_offset: i32,
    queue_count: i16,
    stack_table_offset: i32,
    stack_count: i16,
    ring_table_offset: i32,
    ring_count: i16,
    bitset_table_offset: i32,
    bitset_count: i16,

    // New facts since last training
    new_facts_since_training_offset: i32,
    new_facts_since_training_count: i32,

    // Children
    children_offset: i32,
    children_count: i16,
    children_capacity: i16,
    mounts_offset: i32,
    mounts_count: i16,

    // Training
    training_lock: bool,
    training_arena: ?*VdrArena,

    // Metadata
    visibility: i8,
    frozen: i8,
    owner_id: VdrId,
    created_at: i32,
    last_modified: i32,
    version: i32,
};
// Padded to 256 bytes for cache line alignment.
// training_arena is the only nullable pointer in the system.
// null 99% of the time — set only during active training.
```

### 4.5 Prolog Types

```
enum VdrTermType: i8 {
    TERM_ATOM       = 0,
    TERM_VARIABLE   = 1,
    TERM_INTEGER    = 2,
    TERM_VDR        = 3,
    TERM_TEXT       = 4,
    TERM_LIST       = 5,
    TERM_COMPOUND   = 6,
    TERM_VECTOR     = 7,
    TERM_MATRIX     = 8,
    TERM_PAIR       = 9,
};

struct VdrTerm {
    type: VdrTermType,
    primary_id: i32,
    secondary_offset: i32,
    secondary_aux: i32,
    vdr_value: VdrQ16,
};
// sizeof = 24 bytes.

struct VdrRule {
    id: VdrId,
    head: i32,
    body_offset: i32,
    body_count: i16,
    action_offset: i32,
    action_count: i16,
    fire_count: i32,
    last_fired: i32,
    success_count: i32,
    failure_count: i32,
    created_at: i32,
    creator_session_id: VdrId,
};
// sizeof = 48 bytes.

struct VdrBinding {
    var_id: i32,
    bound_term_offset: i32,
};

struct VdrUnificationResult {
    unified: bool,
    bindings_offset: i32,
    bindings_count: i16,
};
```

### 4.6 Grammar Types

```
enum VdrSlotType: i8 {
    SLOT_VDR_VALUE  = 0,
    SLOT_TEXT       = 1,
    SLOT_INTEGER    = 2,
    SLOT_ENUM       = 3,
    SLOT_KB_REF     = 4,
    SLOT_GRAMMAR    = 5,
};

struct VdrGrammar {
    id: VdrId,
    template_offset: i32,
    template_length: i32,
    slots_offset: i32,
    slots_count: i16,
    validated: bool,
    created_at: i32,
    creator_session_id: VdrId,
};
```

### 4.7 Session Types

```
enum VdrSessionState: i8 {
    SESSION_ACTIVE      = 0,
    SESSION_SNAPSHOTTED = 1,
    SESSION_KILLED      = 2,
    SESSION_FROZEN      = 3,
};

struct VdrSession {
    id: VdrId,
    user_id: VdrId,
    kb_root_id: VdrId,
    session_root_id: VdrId,
    session_next_id: i64,
    visibility_level: i8,
    state: VdrSessionState,

    // Core assignment
    core_id: i32,
    arena_id: i32,

    // Resource bounds
    max_kb_count: i32,
    max_session_kbs: i32,
    max_facts_per_kb: i32,
    max_live_memory_bytes: i64,
    max_turns: i32,

    // Counters
    current_turn: i32,
    facts_asserted: i32,
    facts_retracted: i32,
    session_facts_asserted: i32,
    rules_fired: i64,
    prolog_queries: i64,
    primitive_calls: i64,
    grammar_renders: i64,
    llm_tokens_consumed: i64,
    command_tokens_consumed: i64,

    // Snapshot
    last_snapshot_id: VdrId,
    last_snapshot_timestamp: i32,

    // Clone lineage
    parent_session_id: VdrId,
    clone_generation: i32,
};
```

### 4.8 Runner, Grant, Audit, Command Types

All ID fields are VdrId (i64). Runner types (poller, processor, internal, batch), grant classes (filesystem, compile, execute, lint, network, process), audit actions (15 types), and command types (15 types) carry the same semantics as prior versions.

### 4.9 Confidence Table

```
const CONFIDENCE_TABLE = [11]VdrQ16{
    .{ .v = 65536, .r0 = 0, .r1 = 0 },   // vdr_computation 1/1
    .{ .v = 65536, .r0 = 0, .r1 = 0 },   // prolog_derivation 1/1
    .{ .v = 64225, .r0 = 0, .r1 = 0 },   // database 98/100
    .{ .v = 62259, .r0 = 0, .r1 = 0 },   // prometheus 95/100
    .{ .v = 62259, .r0 = 0, .r1 = 0 },   // script 95/100
    .{ .v = 55705, .r0 = 0, .r1 = 0 },   // rest_api 85/100
    .{ .v = 52428, .r0 = 0, .r1 = 0 },   // published 80/100
    .{ .v = 45875, .r0 = 0, .r1 = 0 },   // user_stated 70/100
    .{ .v = 32768, .r0 = 0, .r1 = 0 },   // web_search 50/100
    .{ .v = 19660, .r0 = 0, .r1 = 0 },   // llm_generated 30/100
    .{ .v = 0,     .r0 = 0, .r1 = 0 },   // unknown 0/1
};
```

---

## 5. Memory Architecture — Arenas Only

### 5.1 Arena Design

Every arena is a fixed-size contiguous block allocated at startup via `std.heap.page_allocator`. Bump pointer allocation only. No free. No reuse until arena reset.

```
struct VdrArena {
    base: [*]u8,
    size: usize,
    cursor: usize,

    fn alloc(self: *VdrArena, bytes: usize, alignment: usize) ?[*]u8 {
        const aligned = (self.cursor + alignment - 1) & ~(alignment - 1);
        if (aligned + bytes > self.size) return null;
        const ptr = self.base + aligned;
        self.cursor = aligned + bytes;
        return ptr;
    }

    fn reset(self: *VdrArena) void {
        self.cursor = 0;
    }

    fn usedBytes(self: *VdrArena) usize {
        return self.cursor;
    }
};
```

Two arena types: **general** (any thread can use, used for the global arena) and **pinned** (NUMA-locked to a specific core, used for per-core arenas). Both are bump-pointer, same struct, different init path. Pinned arenas have their pages touched from the pinned thread to ensure first-touch NUMA placement.

**ArenaSet** holds the global arena plus an array of per-core arenas. Single init call creates everything. Single deinit frees everything.

**Temporary training arenas** are the single exception to no-allocation-after-init. Bounded by headroom check, destroyed after use, pointer nulled. See Section 9.

### 5.2 Arena Layout

```
Global Arena (1 instance, read-heavy, write-rare):
    Domain KB weights:    ~2 GB (1B params × 2 bytes i16, distributed across KBs)
    Seed KBs:             ~2 MB (23,400 entries)
    Global KB store:      ~25 MB (100K KBs × 256 bytes)
    Global fact store:    ~480 MB (10M facts × 48 bytes)
    Global rule store:    ~5 MB (100K rules × 48 bytes)
    Global term store:    ~24 MB (1M terms × 24 bytes)
    Text store:           ~64 MB
    Grammar store:        ~5 MB
    Path index:           ~16 MB (1M entries × 16 bytes)
    Grant store:          ~5 MB
    Audit ring:           ~28 MB (1M entries × 28 bytes)
    Confidence table:     88 bytes
    Total:                ~2.65 GB

Per-Core Arena (N instances, one per physical core):
    Session table:        ~64 KB (up to 500 sessions per core)
    Session KB store:     ~8 MB (per-session KBs)
    Session fact store:   ~48 MB (per-session facts)
    KV cache:             ~128 MB (partitioned across sessions on this core)
    Scratch buffers:      ~32 MB (matmul intermediates, attention scores)
    Binding buffers:      ~1 MB (Prolog unification)
    Render buffers:       ~1 MB (grammar output)
    Work queue:           ~64 KB (atomic ring buffer for HTTP→compute bridge)
    Total per core:       ~220 MB

System total (8 cores): 2.65 GB + 8 × 220 MB = ~4.4 GB
Fits comfortably in 16 GB laptop with room for OS and other apps.
```

### 5.3 NUMA Alignment

```
vdr_numa_init() -> VdrStatus
    1. Detect physical core count via std.Thread.getCpuCount()
       (or from config if n_cores > 0).
    2. For each physical core:
       a. Allocate per-core arena via page_allocator.
       b. Spawn thread, pin to core via OS affinity API.
       c. Touch all pages from the pinned thread (first-touch policy
          ensures NUMA-local placement on multi-socket systems).
    3. Allocate global arena from core 0's NUMA node.
    4. All subsequent arena operations from a thread use only
       that thread's per-core arena for session-local data,
       and read-only access to global arena for shared data.
```

On a single-socket laptop, all memory is on one NUMA node. The pinning and per-core arenas still help for cache locality — each core's working set stays in its L1/L2 cache without bouncing.

### 5.4 Arena Reset as GC

No free. No garbage collector. When a session dies, its arena region resets (cursor = 0). All session data gone instantly. No traversal, no fragmentation. Global arena data is never freed during operation. Arena exhaustion returns `ErrorCode.arena_exhausted`, never silent corruption.

### 5.5 Dynamic Arrays

All dynamic arrays in the system use `ArrayListManaged` on an arena. This is an operational rule. No ad-hoc dynamic allocation patterns. Every list that can grow (new-facts-since-training, children lists, etc.) uses `ArrayListManaged` backed by arena memory.

---

## 6. HTTP Interface — Non-Pinned Connector

### 6.1 HTTP Listener

A non-pinned thread listens on a configurable port (from config, default 1138). Uses `std.net` for TCP accept. Each accepted connection spawns a new non-pinned thread that reads the HTTP request, processes it, and sends a response. The listener thread and handler threads are never pinned and never do SIMD compute.

HTTP is a connector, not a web server. It receives JSON work requests and bridges them to the NUMA-pinned compute threads.

### 6.2 Work Queue

Each per-core arena contains an atomic ring buffer work queue. Fixed-size. Push from any thread (HTTP handler), pop from the owning pinned thread only. Atomic head/tail pointers. No mutex.

```
struct VdrWorkQueue {
    items: [QUEUE_CAPACITY]VdrWorkItem,
    head: std.atomic.Value(i32),    // written by producer (HTTP handler)
    tail: std.atomic.Value(i32),    // written by consumer (pinned thread)
    capacity: i32,
};

struct VdrWorkItem {
    op: VdrWorkOp,
    input_offset: i32,
    input_length: i32,
    output_offset: i32,
    output_length: i32,
    completion: std.atomic.Value(bool),
};
```

HTTP handlers create a work item, push to a selected core's queue (round-robin or least-loaded), wait for completion flag, send result as HTTP response. The pinned compute thread pops work items each spin iteration, executes, signals completion.

### 6.3 Separation Rule

Pinned threads only do compute — they never touch the network. HTTP threads only do I/O — they never do SIMD work. The work queue is the only bridge between them.

---

## 7. Compute Model — CPU SIMD

### 7.1 SIMD Strategy

All hot-path computation uses AVX2: 256-bit vectors, 8 × i32 lanes.

```
const Vec8i32 = @Vector(8, i32);
const Vec4i64 = @Vector(4, i64);

fn simd_q16_mul_v(a: Vec8i32, b: Vec8i32) Vec8i32 {
    const a_lo: Vec4i64 = ... ;
    const a_hi: Vec4i64 = ... ;
    const b_lo: Vec4i64 = ... ;
    const b_hi: Vec4i64 = ... ;
    const prod_lo = a_lo * b_lo;
    const prod_hi = a_hi * b_hi;
    const result_lo = prod_lo >> @splat(16);
    const result_hi = prod_hi >> @splat(16);
    return pack_i64_to_i32(result_lo, result_hi);
}

fn simd_dot_product(a: []const i32, b: []const i32, n: i32) i64 {
    var acc = Vec4i64{ 0, 0, 0, 0 };
    var i: usize = 0;
    while (i + 8 <= n) : (i += 8) {
        const va: Vec8i32 = a[i..][0..8].*;
        const vb: Vec8i32 = b[i..][0..8].*;
        acc += widen_madd(va, vb);
    }
    return horizontal_sum(acc) + scalar_tail(a[i..], b[i..], n - i);
}
```

**SIMD on v (8-wide):** Dot products, addition/subtraction, comparison, max/min scan.

**Scalar post-pass on r0, r1:** After SIMD computes the v-level result, a scalar pass propagates remainders for operations that need full precision.

**When to propagate remainders:**
- GEMM inner loop: SIMD on v only. Accumulate in i64. Final result gets r0 from divTrunc by D, r1 from cross-terms. Per-element remainders inside the dot product are absorbed into the i64 accumulator.
- Softmax: Full remainder tracking per element. The FRU needs per-element remainders.
- LayerNorm: v-level SIMD for variance computation. Remainder tracking on final inverse-sqrt and scaling.
- Residual add: Full remainder propagation per element (carry chain through r1 → r0 → v).

### 7.2 GEMM — Per-Thread, No Coordination

**This section replaces the prior version which incorrectly described cross-core GEMM splitting with barrier synchronization. See the GEMM Execution Model Addendum for full rationale.**

```
d_model = 2048, n_heads = 16, d_head = 128, mlp_dim = 5632, n_layers = 16

Per layer:
    QKV projection:    2048 × 6144  = 12.6M MACs
    Output projection: 2048 × 2048  = 4.2M MACs
    MLP up:            2048 × 5632  = 11.5M MACs
    MLP down:          5632 × 2048  = 11.5M MACs
    Total per layer:   ~40M MACs

16 layers: ~640M MACs per token

At AVX2 throughput (8 i32 MACs/cycle, 3 GHz, 1 port):
    Single core: ~24 GMAC/s → 640M / 24G = ~27ms per token → ~37 tok/s
    8 cores:     8 independent sessions × ~37 tok/s = ~296 tok/s system throughput
```

Each pinned thread executes its own complete GEMM independently. No row splitting, no barrier, no atomic counter, no cross-thread coordination. A session is bound to a core at creation. All inference for that session — every layer, every GEMM, every softmax, every attention head — runs start to finish on that one core.

The goal is system scalability, not single-token latency. 8 cores means 8 concurrent sessions, each at full single-core throughput. Adding cores adds sessions linearly with zero coordination overhead.

```
vdr_gemm(A: []const i32, B: []const i32, C: []i32,
         M: i32, N: i32, K: i32) void
    // Called by a single pinned thread on its own session's data.
    // No thread pool parameter. No row range.
    // Inner loop uses simd_dot_product with i64 accumulation.
    // Final divTrunc by D to get Q16 result.
```

### 7.3 Softmax — Exact Unity

Integer softmax producing probabilities that sum to exactly D (65536). Every time. Not approximately.

```
vdr_softmax_exact(logits: []i32, probs: []i32, n: i32, D: i32) void
    1. Find max logit (SIMD scan)
    2. Compute int_exp(logit[i] - max) for each i
    3. Sum all exp values → total
    4. For each i:
         probs[i] = (exp[i] * D) / total        (integer division)
         remainder[i] = (exp[i] * D) % total     (exact remainder)
    5. Sum all probs[i] → partial_sum
    6. deficit = D - partial_sum
    7. Find index with largest remainder[i]
    8. Add deficit to that index's prob
```

The deficit is the exact amount lost to truncation across all elements. Assigned to the element that lost the most — the Fixed Remainder Unit (FRU). Deterministic. Same inputs always produce same assignment. Sum is exactly D.

Proven in CPU toy model benchmark: 20 epochs, zero violations.

### 7.4 Layer Norm (RMSNorm)

Integer RMSNorm using Newton-Raphson for inverse square root:

```
vdr_rmsnorm(input: []i32, output: []i32, gamma: []const i32, n: i32) void
    1. Compute mean of squares: sum(x[i]^2) / n (SIMD reduction)
    2. Newton-Raphson for 1/sqrt(mean_sq): 4 iterations in i64
    3. output[i] = (input[i] * inv_rms * gamma[i]) / D^2
```

### 7.5 Attention

```
vdr_attention(Q: []i32, K_cache: []i32, V_cache: []i32,
              output: []i32, config: *AttnConfig) void
    1. For each head:
       a. scores[pos] = dot(Q_head, K_cache[pos]) * scale / D
       b. Apply causal mask (set future to -MAXINT)
       c. vdr_softmax_exact(scores)  // exact unity
       d. output_head = weighted sum of V_cache by scores
    2. Concatenate heads, output projection via GEMM
```

### 7.6 Thread Pool

```
struct VdrThreadPool {
    threads: [MAX_CORES]std.Thread,
    arenas: [MAX_CORES]*VdrArena,
    work_queues: [MAX_CORES]*VdrWorkQueue,
    n_cores: i32,
    done: std.atomic.Value(bool),

    barrier_counter: std.atomic.Value(i32),
    current_work: *VdrWorkItem,
};
```

Each pinned thread: sets CPU affinity to its core ID, touches all pages in its per-core arena, enters spin-wait checking its work queue. On work item: execute, signal completion. On done flag: exit. Main thread joins all.

---

## 8. Model Weights as KB Data

### 8.1 Weights Live Where They Serve

There is no separate model tree. Weights live in the KBs they serve. A KB that represents a concept also holds the weights for reasoning about that concept.

```
root.science.physics.qed
    facts[0] = alpha_em (value: 47258, confidence: 1/1)
    facts[1] = coupling_constant (value: ...)
    weights[0] = WeightMatrix { inference weights for QED reasoning }

root.ops.incidents.triage
    facts[0] = severity_threshold (value: ...)
    rules[0] = escalation_rule
    weights[0] = WeightMatrix { triage judgment weights }
```

The model is the sum of all weights across all KBs the session has access to. Each domain carries its own weights alongside its own data, rules, and grammars. System-level KBs for embedding and output projection are global KBs with a security group scope like any other KB — there is nothing special about them. They exist as KBs at paths like `root.system.embedding` and `root.system.output`, gated by grants the same way every other KB is.

### 8.2 Grant-Gated Capability

A user with access to `root.science.physics` gets the physics reasoning weights. A user without that grant doesn't — their model literally doesn't include physics capability. The forward pass collects weights from all visible KBs and assembles the effective model from the available pieces.

### 8.3 Weight Format

Weight data stored as TAG_MATRIX or TAG_VECTOR facts referencing SoA-packed arrays in the arena. The Fact provides metadata (provenance, confidence, dimensions). The packed arrays provide SIMD-friendly contiguous access.

### 8.4 Three-Path Weight Retrieval

When the inference engine needs weights from a KB, there are three retrieval paths based on KB state:

**Path 1: Full Fact Scan.** KB has no GEMM cache (freshly populated, never trained). Scan all facts at 48-byte stride. Slow but correct. Data is usable immediately without waiting for training.

Test: `kb.weight_refs == null or kb.weight_refs.gemm_cache == null`. If true, full scan.

**Path 2: GEMM Cache Only.** KB has been trained. GEMM cache exists for the session's access group. Read contiguous packed v_data directly. No fact scanning. This is the hot path.

Test: GEMM cache exists and new-facts-since-training list is empty. If true, use cache directly.

**Path 3: GEMM Cache Plus New Fact Scan.** KB has a GEMM cache from training, but new facts have been added since training. Read the GEMM cache first, then scan the new-facts-since-training list. Each new fact is looked up by its index — O(1) per fact.

Test: GEMM cache exists and new-facts-since-training list is non-empty. If true, read cache then scan list.

```
fn resolveWeights(kb: *VdrKb, group: GroupId) WeightView {
    if (kb.weight_refs == null or kb.weight_refs.gemm_cache == null) {
        return fullFactScan(kb);
    }
    const cache = kb.weight_refs.gemm_cache_for_group(group);
    if (kb.new_facts_since_training.items.len == 0) {
        return cacheOnly(cache);
    }
    return cachePlusNewFacts(cache, kb);
}
```

### 8.5 New-Facts Tracking

Each KB has an `ArrayListManaged(i32)` on the KB's arena storing fact indices of items added since the last GEMM training. When training completes, this list is cleared. When a new fact is written, its index is appended.

### 8.6 Per-Group Weight Access

Two mechanisms compose for weight access control:

**Per-group GEMM copies (2-4 major tiers):** Each KB stores multiple GEMM weight sets indexed by group. At inference time, the session's group membership determines which index to read. Pre-computed, no runtime transformation. O(1) per KB.

**Capability tokens in provenance (fine-grained):** Each weight fact's provenance carries a `capability_level`. At GEMM cache rebuild time, weights whose capability level exceeds the session's level are read as zero. The access check is per-element during cache rebuild (cold path), not during GEMM execution (hot path).

The grant system controls which KB tier a session belongs to. Provenance tracks per-fact capability. The GEMM cache is per-access-group — different groups produce different caches from the same KB.

---

## 9. Live Training

### 9.1 Temporary Arena Pattern

Training is the single exception to no-allocation-after-init. When a KB needs training:

1. **`canTrain(kb_id) → bool`** — Checks whether the system has enough memory headroom for a temporary arena at the size this KB's training data requires. Also checks whether this KB is already locked for training. If either fails, return false.

2. **`train(kb_id) → ?TrainResult`** — If `canTrain()` is true, allocates a temporary arena sized to this specific KB's needs. Sets `training_lock = true` on the KB. The arena holds gradients, optimizer state, saved activations, transposed weight copies, scratch.

3. **Training runs** on a pinned compute thread (submitted via work queue, not on kernel or HTTP threads). The pinned thread touches all pages in the temporary arena for NUMA alignment.

4. **Cleanup.** Updated weights written back to the KB's global arena. Temporary arena destroyed. `training_arena` pointer nulled. `training_lock` set to false. System's available memory headroom goes back up.

If `canTrain()` returns false, `train()` returns null. No partial allocation, no cleanup needed.

### 9.2 Temporary Arena Sizing

Per-KB, not a fixed global buffer. For a weight matrix of N parameters:

| Component | Size | Purpose |
|-----------|------|---------|
| Gradient accumulator | N × 4 bytes (i32) | Same shape as weight v_data |
| Gradient r0 | N × 2 bytes (i16) | Remainder tracking on gradients |
| Gradient r1 | N × 2 bytes (i16) | Sub-r0 gradient precision |
| Optimizer momentum | N × 4 bytes (i32) | First moment (Adam-like) |
| Optimizer variance | N × 4 bytes (i32) | Second moment (Adam-like) |
| Saved activations | seq_len × d_model × 4 bytes | Per-layer forward pass intermediates |
| Transposed weight copy | N × 4 bytes (i32) | Built once for backward GEMM |
| Scratch | ~10% of above | Intermediate computation |

For a 2048×2048 weight matrix (4M params): ~100 MB temporary arena. For a 128-element layer norm vector: ~10 KB. The arena scales with the data.

Multiple KBs can train concurrently as long as total temporary arena allocation stays under the system's max.

### 9.3 GEMM During Training

The GEMM kernel does not change. Forward pass during training is the same GEMM as inference.

| Operation | Input Source | Output Destination |
|-----------|-------------|-------------------|
| Forward GEMM | KB weight v_data (global arena) | Activations (temporary arena) |
| Backward GEMM | Transposed weights (temporary arena) + activation gradients (temporary arena) | Weight gradients (temporary arena) |
| Weight update | Gradients (temporary arena) + current weights (global arena) | Updated weights (global arena) |

After weight update writes back to the KB's global arena v_data, the per-KB GEMM cache is marked dirty. Next inference read rebuilds it.

### 9.4 Per-Fact Provenance in Training

After training updates a weight:
- `source_type` → `vdr_computation` (confidence 1/1)
- `timestamp` → training completion time
- `derivation_rule_id` → ID of the training rule/procedure

Per-weight lineage. Any individual weight can be traced back to what training run produced it, when, and under what configuration.

---

## 10. Attention, Context, and the Session LLM Tree

### 10.1 Attention Window is the Session KB Tree

There is no fixed attention window. The LLM's attention is the session KB tree — structured data under its own management, unlimited in size, exact in precision, learnable at any time.

The LLM reads specific facts from specific KB addresses. The "window" is every KB the session can access, queried by address, not attended to by position.

### 10.2 Session LLM Subtree — Canonical Structure

Each session pre-creates a structured subtree for the LLM's own use. These are the canonical top-level KBs under `session_root._llm`. This set is fixed — the LLM does not create new top-level KBs here. Data goes inside these KBs as children. The structure exists to bound the scanning surface for attention and ensure every piece of LLM working data has a proper organizational home.

```
session_root._llm
session_root._llm.prompt_last
session_root._llm.prompt_next
session_root._llm.prompt_input
session_root._llm.prompt_current
session_root._llm.history
session_root._llm.projects
session_root._llm.people
session_root._llm.concepts
session_root._llm.search
session_root._llm.scratchpad
```

**`prompt_last`** — What the LLM tracked from the previous prompt cycle. The continuity record. Read at the start of each new prompt to reconstruct context.

**`prompt_next`** — Where the LLM writes what it wants to track for the next prompt. Continuity and planning. The LLM decides mid-response what state matters going forward.

**`prompt_input`** — What the client gave us. The raw user request for this cycle. Written by the system, read by the LLM. The LLM does not write here.

**`prompt_current`** — Scratchpad for this current prompt. Working memory for mid-prompt computation. Cleared every prompt cycle.

**`history`** — Bounded queue where the LLM puts cycle history of the session. Oldest items drain when the queue reaches capacity. Capacity set at session init. Bounded growth by design.

**`projects`** — Tracks different projects in sub-KBs. Metadata about how they link, ordering, active/dead status. Each project gets its own child KB under this node for its actual data.

**`people`** — Tracks people. Child KBs per context — different books, movies, organizations, friends. A person appearing in multiple contexts gets sub-KBs per context under their person KB. People get their own space because confusing them across contexts is a common LLM failure.

**`concepts`** — Tracks topics being discussed. Can reference searches stored in `._llm.search`. Organizes concept relationships — what connects to what, depends on what, contradicts what.

**`search`** — Stores search results and background material. Referenced by `concepts` and other KBs as source material. Provenance tracks origin and confidence.

**`scratchpad`** — Whole-session scratchpad. Persists across prompts unlike `prompt_current`. The LLM can delete things or keep adding. Bounded by session arena capacity. If it grows large enough to be useful, it can be trained to produce a GEMM cache.

### 10.3 Prompt Processing Flow

```
1. User input arrives. System writes it to prompt_input.
2. Attention phase: LLM reads prompt_last for continuity.
   LLM reads prompt_input for current request.
   LLM reads any other KBs it needs — history, projects,
   people, concepts, whatever is relevant.
3. LLM uses prompt_current as scratch for this prompt.
4. LLM writes to prompt_next what it wants to carry forward.
5. After attention phase completes, system automatically copies
   prompt_next → prompt_last. This always happens.
6. prompt_next is cleared. prompt_current is cleared.
   Ready for next cycle.
```

The LLM controls what goes into `prompt_next`. The system controls the structural transitions. The LLM manages everything under `history`, `projects`, `people`, `concepts`, `search`, `scratchpad` freely — creating child KBs, writing facts, retracting, organizing — within its per-session resource limits.

### 10.4 Session Resource Limits

Each session has `max_kb_count` and `max_session_kbs` from config. When the limit is reached, the LLM cannot create new KBs or assert new facts. But it can still:
- Read all accessible KBs
- Fire existing Prolog rules
- Pump LRUs and queues (bounded structures cycle normally)
- Do inference with existing weights
- Retract facts to make room

This means a session hitting its limit degrades gracefully. Bounded structures (queues, rings, LRUs) continue to cycle because they don't grow — they overwrite. The LLM just can't expand its working set further.

---

## 11. Inference Loop

### 11.1 Full Cycle

```
vdr_inference_cycle(session: VdrSession, input: []const u8,
                    output: *VdrOutputBuffer) -> VdrStatus

    // Phase 1: Input Processing
    tokens = vdr_tokenize(input);
    vdr_kb_write(session.session_root_id, "_llm.prompt_input", tokens);

    // Phase 2: Context Assembly from KB Tree
    // LLM reads structured KB data, not a flat token buffer.
    continuity = vdr_kb_read(session, "_llm.prompt_last");
    input_data = vdr_kb_read(session, "_llm.prompt_input");
    // LLM reads additional KBs as needed:
    //   _llm.history, _llm.projects, _llm.people, _llm.concepts, etc.

    // Phase 3: Resolve Visible Model Weights
    visible_weights = vdr_access_resolve_model(session);
    // Forward pass uses only weights from KBs this session can access.

    // Phase 4: LLM Forward Pass
    logits = vdr_forward(context, visible_weights, session.core_id);
    // SIMD GEMM across all cores, synchronized per layer.

    // Phase 5: Generation Loop
    loop {
        token = vdr_sample(logits, sampling_config);

        if is_command_start(token):
            command = vdr_generate_command(session);
            result = vdr_command_execute(session, command);
            vdr_kb_assert(session, "_llm.prompt_current", result);

        elif is_direct_output(token):
            kb_url = vdr_parse_kb_url(token_stream);
            data = vdr_kb_read(kb_url.kb_id, kb_url.slot_id);
            grammar = vdr_grammar_inherit(kb_url.kb_id);
            if grammar: vdr_grammar_render(grammar, data, output);
            else: vdr_render_fact(data, output);

        elif is_end_of_turn(token):
            break;

        else:
            output.append(token);

        logits = vdr_forward_single(token, visible_weights, session.core_id);
    }

    // Phase 6: LLM writes continuity
    // (LLM has been writing to prompt_next during generation)

    // Phase 7: System transitions
    vdr_kb_copy(session, "_llm.prompt_next", "_llm.prompt_last");
    vdr_kb_clear(session, "_llm.prompt_next");
    vdr_kb_clear(session, "_llm.prompt_current");

    // Phase 8: Post-Processing
    session.current_turn += 1;
    session.llm_tokens_consumed += tokens_generated;

    // Phase 9: Auto-Snapshot
    if session.current_turn % auto_snapshot_interval == 0:
        vdr_session_snapshot(session);
```

### 11.2 Execution Levels

```
L1 — Full LLM Judgment:     50-500 tokens. No stored rule covers it.
L2 — LLM Invokes Rule:      ~8 command tokens + ~10 prose tokens. ~3% of L1 cost.
L3 — Automatic Rule Firing:  0 LLM tokens. Pure Prolog. 93% of ops at maturity.
```

At maturity, the vast majority of operations are L3. The Prolog knowledge system handles what it can without invoking the neural network. The forward pass tok/s is not the only performance metric — the L3 ratio determines actual cost.

### 11.3 Session Scratchpad Usage

```
// Turn 1: LLM investigates
CMD_KB_ASSERT session_root._llm.scratchpad.investigation fact(suspect, service_checkout)
CMD_KB_ASSERT session_root._llm.scratchpad.investigation fact(evidence, error_rate_spike)

// Turn 2: LLM reads its own notes (from prompt_last continuity + direct KB read)
CMD_KB_QUERY session_root._llm.scratchpad.investigation

// Turn 3: LLM concludes and promotes to global
CMD_KB_ASSERT root.ops.incidents.inc_042 fact(root_cause, checkout_memory_leak)
```

---

## 12. KB Store — Direct Memory Access

### 12.1 Operations

No bridge layer. All operations are direct pointer arithmetic into arena memory:

```
vdr_kb_store_fact_write(kb_id: VdrId, slot_id: i32, fact: *VdrFact) -> VdrStatus
    // Resolve arena: if kb_id.isGlobal() → global arena, else → session's per-core arena
    // Compute offset: kb.facts_offset + slot_id * sizeof(VdrFact)
    // Direct memcpy into arena. O(1). No syscall.

vdr_kb_store_fact_read(kb_id: VdrId, slot_id: i32) -> ?*VdrFact
    // Same arena resolution. Return pointer directly into arena memory.
    // No copy. Caller reads from arena.

vdr_kb_store_scoped_search(start_kb_id: VdrId, tag: VdrFactTag, max_depth: i32) -> SearchResult
    // Walk parent chain. If start is session (-), walk session tree first,
    // then cross to global (+) at the session's kb_root_id junction.
```

### 12.2 Session/Global Resolution

When the LLM queries a path, session takes priority:

```
Query: root.science.physics.qed.alpha_em

1. Check session tree: session_root.science.physics.qed.alpha_em
   If found → return session version
2. Check global tree: root.science.physics.qed.alpha_em
   If found → return global version
3. Not found → walk parent chain for scoped search
```

Session overrides global locally without modifying the global store. Override dies with the session.

### 12.3 COW for Clone Sessions

Clone sessions share the parent's global KB references and get a COW copy of the parent's session tree. Page-level dirty tracking on arena memory pages.

---

## 13. Prolog Engine

Direct function calls into arena memory. No dispatch, no bridge:

```
vdr_prolog_unify(a: *VdrTerm, b: *VdrTerm, bindings: []VdrBinding, n: *i32) -> bool
    // ATOM-ATOM: a.primary_id == b.primary_id
    // VARIABLE-anything: bind
    // VDR-VDR: all three fields match (v, r0, r1). Exact. No epsilon.
    // COMPOUND-COMPOUND: functors match + recursive arg unification
    // All integer comparisons. No float.

vdr_prolog_query(kb_store: *VdrKbStore, start_kb_id: VdrId, query: *VdrTerm) -> QueryResult
    // Depth-first search with backtracking.
    // Iterative with explicit stack (in per-core arena scratch).
    // Searches session tree first if start_kb_id is session.

vdr_prolog_fire_and_commit(kb_store: *VdrKbStore, kb_id: VdrId) -> i32
    // Match rules against facts. Fire satisfied rules.
    // Write derived facts with PROLOG_DERIVATION confidence (1/1).
    // Returns number of rules fired.
```

---

## 14. Serialization

### 14.1 Per-KB Persistence — Byte-Exact Struct Data

No serialization format. No JSON for data (JSON is for config only). No protobuf. The data is structs and we byteslice them to disk.

```
./data/kb/root_science_physics_qed.dat
```

The dotted path becomes the filename with dots replaced by underscores. The file contains raw bytes of the VdrKb struct, the facts array, the rules array, the terms, the weight SoA-packed arrays if present, the new-facts-since-training list, and the GEMM cache data if present. Each section is a byte slice of the in-memory struct.

```zig
fn saveKb(kb: *VdrKb, path: []const u8) !void {
    const file = try std.fs.cwd().createFile(path, .{});
    defer file.close();
    try file.writeAll(std.mem.asBytes(kb));
    const facts_bytes = @as([*]const u8, @ptrCast(facts_ptr))[0..kb.facts_count * @sizeOf(VdrFact)];
    try file.writeAll(facts_bytes);
    // ... each section as raw byte slice
}

fn loadKb(path: []const u8, arena: *VdrArena) ?*VdrKb {
    const file = std.fs.cwd().openFile(path, .{}) catch return null;
    defer file.close();
    const kb = arena.allocTyped(VdrKb) orelse return null;
    const kb_bytes = @as([*]u8, @ptrCast(kb))[0..@sizeOf(VdrKb)];
    _ = file.readAll(kb_bytes) catch return null;
    // ... read each section
    return kb;
}
```

No parsing. The bytes in the file are the struct. The struct in memory is the bytes. Byte-exact round trip.

File format is tied to the struct layout. If the struct changes, old files are incompatible. The `version` field in VdrKb catches mismatches on load. Migration is a separate offline tool. x86_64 only, little-endian, fixed struct sizes, no padding ambiguity.

### 14.2 Session Snapshot Format

Binary snapshot captures both global (session's view) and session state for session continuity:

```
struct VdrSnapshotHeader {
    magic: [4]u8,            // "VDRS"
    version: i32,
    timestamp: i32,
    session_id: VdrId,
    user_id: VdrId,

    // Global region sizes (bytes) — session's visible subset only
    kb_region_size: i64,
    fact_region_size: i64,
    rule_region_size: i64,
    term_region_size: i64,
    text_region_size: i64,
    grammar_region_size: i64,
    live_state_region_size: i64,
    grant_region_size: i64,

    // Session region sizes
    session_kb_region_size: i64,
    session_fact_region_size: i64,
    session_next_id: i64,

    // Session metadata
    session_metadata: VdrSession,

    // Integrity
    checksum: i32,           // CRC32
    total_size: i64,
};
```

Restore is bit-identical. Session IDs are preserved — the session continues exactly where it left off.

---

## 15. Seed Layer

```
root                          id: +1
├── system                    id: +2
│   ├── oso                   id: +3     (15 engineering principles)
│   ├── confidence            id: +4     (confidence table)
│   ├── builtins              id: +5     (448 IOSE declarations)
│   ├── command_vocab         id: +6     (~300 command tokens)
│   ├── hygiene               id: +7     (self-maintenance rules)
│   ├── embedding             id: +8     (vocab embedding weights)
│   └── output                id: +9     (lm_head + final norm weights)
├── templates                 id: +10
│   ├── sentences             id: +11
│   └── formats               id: +12
└── (domain KBs with their own weights go here)

~23,400 seed entries. System KBs frozen after init.
Domain KBs carry their own weights alongside data and rules.
System embedding and output KBs are normal global KBs with
grant-based access like every other KB.
```

---

## 16. Configuration

### 16.1 Config Struct

```
struct VdrSystemConfig {
    // Hardware
    n_cores: i32,                        // 0 = auto-detect

    // Model
    model_checkpoint_path: [256]u8,
    model_n_layers: i32,                 // default 16
    model_d_model: i32,                  // default 2048
    model_n_heads: i32,                  // default 16
    model_d_head: i32,                   // default 128
    model_vocab_size: i32,               // default 32000
    model_mlp_dim: i32,                  // default 5632

    // Arenas
    global_arena_bytes: i64,             // default 3 GB
    per_core_arena_bytes: i64,           // default 256 MB

    // Limits
    max_total_kbs: i32,                  // default 100,000
    max_total_facts: i64,                // default 10,000,000
    max_total_rules: i32,                // default 100,000
    max_total_terms: i64,                // default 1,000,000
    max_sessions_per_core: i32,          // default 500
    max_session_kbs_per_session: i32,    // default 1000
    max_facts_per_session_kb: i32,       // default 10000

    // Sessions
    default_max_turns: i32,              // default 0 (unlimited)
    auto_snapshot_interval: i32,         // default 100

    // HTTP
    http_port: i32,                      // default 1138

    // Runners
    max_runners: i32,                    // default 64

    // Safety
    audit_ring_capacity: i32,            // default 1,000,000
    default_visibility: i8,              // default INTERNAL

    // Sampling
    default_temperature_v: i32,          // default 65536 (1.0)
    default_top_k: i32,                  // default 50
    default_top_p_v: i32,               // default 58982 (0.9)
};
```

### 16.2 Config Loading

JSON config file loaded at startup via `std.json`. Hard-mapped — every JSON field maps to a struct field. Unknown fields are errors. Missing required fields are errors. On any parse failure, print the field name and expected type, then exit with code 1. Missing file prints usage and exits.

The config is not optional. No hardcoded fallbacks. No silent defaults. If config can't load and parse into `VdrSystemConfig`, print the error and exit. Silent defaults hide misconfiguration.

The config is the single source of truth for system sizing. Everything downstream reads from the parsed config.

---

## 17. Error Handling

Same deterministic recovery tree. ERR_CAT_MEMORY covers arena exhaustion. Every arena allocation returns null on exhaustion. Callers check and return the appropriate error with the arena ID. No silent data corruption from overflow.

---

## 18. Invariants

```
INVARIANT_1:  Remainder is never discarded. Every divTrunc must capture its mod.
              Using divTrunc without capturing mod is a bug.

INVARIANT_2:  r0 and r1 are never padding. Both carry meaning. Code that treats
              them as zero without propagating is losing information.

INVARIANT_3:  Softmax sums to D exactly. After FRU assignment, sum of all
              probabilities equals 65536. Test this on every softmax call.

INVARIANT_4:  Comparison uses all three fields. Two values with equal v but
              different r0 are different values. v-only comparison is lossy —
              acceptable for some operations but must be documented.

INVARIANT_5:  i64 accumulators for multiplication. i32 × i32 can overflow i32.
              All multiplications widen to i64 before computing.

INVARIANT_6:  No float anywhere. If @as(f32, ...) or @as(f64, ...) appears
              anywhere in the compute path, the VDR guarantee is broken.
              Integer in, integer through, integer out.

INVARIANT_7:  r1 is the precision sentinel. Near ±32767 after a chain means
              escalate to Q32 for that computation path.

INVARIANT_8:  Session IDs never collide with global IDs. All session IDs are
              negative. All global IDs are positive. Sign bit guarantees
              disjoint address spaces.

INVARIANT_9:  Session data dies with its session. Arena region reset. No session
              fact survives session death. Session data referenced in global
              provenance becomes a dead link.

INVARIANT_10: Arena memory is never exhausted silently. Every allocation returns
              null on exhaustion. Callers check and return ERR_CAT_MEMORY.

INVARIANT_11: SIMD GEMM produces identical results to scalar GEMM. Integer
              arithmetic has no SIMD-vs-scalar precision difference. Tested by
              running both paths on same input and comparing.

INVARIANT_12: Temporary training arenas are the only post-startup allocation.
              Created bounded by canTrain() headroom check. Destroyed after use.
              Pointer nulled.

INVARIANT_13: The _llm.* canonical subtree structure is fixed. The LLM does not
              create new top-level KBs under session_root._llm. Data goes inside
              the existing canonical KBs as children.

INVARIANT_14: All dynamic arrays use ArrayListManaged on an arena. No other
              dynamic allocation pattern.

INVARIANT_15: fromParts always takes three arguments (v, r0, r1). Two-argument
              calls are bugs.
```

---

## 19. Zig 0.15.1 Specifics

- **Version:** Zig 0.15.1. Not 0.16.0. API differences exist.
- **Output:** `std.debug.print` for all output. No `std.io.getStdOut()`.
- **Build:** `.root_module = b.createModule(...)` pattern for `addExecutable`. Verify against 0.15.1 — the API changed across versions.
- **Linking:** `linkLibC()` and `linkSystemLibrary()` may be on the module, not the compile step. Check 0.15.1 docs.
- **Timestamps:** Integer only. `std.time.timestamp()` returns epoch seconds, truncate to i32. `std.time.nanoTimestamp()` for benchmarks as i64. Never convert to float.
- **Target:** x86_64 only. No ARM, no WASM, no cross-compilation.
- **Types:** All types in `vdr_types.zig`. Modules import from there. Never duplicate struct definitions.

---

## 20. Build Order

The system is built bottom-up. Each step must compile, run, and exit clean before the next step starts.

### Step 1: Kernel Boot + Arena Memory
Zig project compiles on 0.15.1, allocates a core arena, prints diagnostics, exits.

Files: `build.zig`, `src/root.zig`, `src/vdr_arena.zig`, `src/vdr_types.zig`.

Validation: `zig build && ./zig-out/bin/vdr-prolog-cpu` prints arena info and exits with code 0.

### Step 2: Config Loader
Load JSON config into `VdrSystemConfig`. Hard-mapped. Unknown fields are errors. Missing required fields are errors.

Files: `src/vdr_config.zig`, `config.json`.

Validation: Load config, print parsed values, exit. Bad JSON prints specific error and exits with code 1.

### Step 3: Core Arena + N Pinned Core Arenas
Based on config, allocate global arena and N per-core arenas. No threads yet — just memory.

Validation: Prints arena layout matching config. Total memory matches expected sum.

### Step 4: NUMA-Pinned Processing Threads
Spawn N threads, pin each to its core, touch arena pages, park in spin-wait. Clean shutdown and join.

Files: `src/vdr_thread_pool.zig`.

Validation: All N threads spawn, pin, touch memory, and join cleanly.

### Step 5: HTTP Listener
Non-pinned HTTP listener accepts connections, spawns non-pinned handlers. Handlers read request, respond 200 OK, close.

Files: `src/vdr_http.zig`.

Validation: `curl http://localhost:1138/health` returns `{"status": "ok"}`. Clean shutdown.

### Step 6: HTTP-to-NUMA Work Passing
Per-core atomic ring buffer work queues. HTTP handlers push work, pinned threads pop and execute.

Files: `src/vdr_work_queue.zig`.

Validation: POST request processed on a pinned NUMA thread, result returned via HTTP. Concurrent requests distribute across cores.

### After Step 6
Kernel infrastructure done. Everything after builds on top: KB store, Prolog engine, SIMD GEMM, grammar, inference loop.

---

## 21. Implementation Stages

```
Stage 1: Foundation (includes Steps 1-6 above)
    vdr_types, vdr_arena, vdr_config, vdr_thread_pool,
    vdr_http, vdr_work_queue
    vdr_kb_store (global + session), vdr_access
    vdr_ops (scalar only, no SIMD yet)
    Basic session with _llm.* subtree
    Deliverable: KBs with dual addressing, arena allocation,
    session writes, HTTP→NUMA bridge.
    ~5,000 lines.

Stage 2: Intelligence
    vdr_prolog, vdr_grammar, vdr_builtin (pure builtins)
    vdr_session (snapshot, clone, merge, kill)
    vdr_grant, vdr_audit, vdr_confidence
    vdr_command (parse + execute)
    Deliverable: full Prolog, grammars, grants, L1→L2→L3 possible.
    ~6,000 lines.

Stage 3: Compute
    vdr_ops (AVX2 SIMD: gemm, softmax, rmsnorm, attention, silu)
    vdr_model (KB-distributed weights, grant-gated forward pass,
               three-path weight retrieval)
    vdr_inference (full loop with prompt processing cycle)
    vdr_thread_pool (multi-core GEMM)
    Deliverable: LLM inference at ~300 tok/s on laptop.
    ~4,000 lines.

Stage 4: Training + Operations
    vdr_training (canTrain, train, temporary arenas, weight update,
                  provenance tracking)
    vdr_runner (all 4 types)
    vdr_builtin (44 operational builtins)
    vdr_seed (full seed layer)
    vdr_system (daemon mode)
    Deliverable: live training, autonomous operation.
    ~4,000 lines.

Stage 5: Testing
    vdr_test (full suite)
    Determinism, SIMD correctness, snapshot roundtrip,
    session isolation, access control, confidence propagation,
    softmax exact unity, remainder propagation chains,
    three-path weight retrieval, training arena lifecycle.
    ~1,000 lines.

Total: ~20,000 lines.
```

---

## 22. Implementation Files

```
vdr_types.zig         — VdrQ16, VdrId, VdrFact, VdrKb, VdrTerm, VdrRule, VdrSession, etc.
vdr_arena.zig         — Fixed-size arena allocator, bump pointer, reset, ArenaSet
vdr_config.zig        — JSON config loading, hard-mapped, strict error handling
vdr_thread_pool.zig   — Pinned threads, GEMM work distribution, atomic barrier
vdr_work_queue.zig    — Per-core atomic ring buffer, push/pop, completion flag
vdr_http.zig          — Non-pinned HTTP listener, handler threads, JSON request/response
vdr_ops.zig           — SIMD: gemm, dot, softmax, rmsnorm, attention, silu
vdr_model.zig         — KB-distributed weights, three-path retrieval, grant-gated forward pass
vdr_kb_store.zig      — KB CRUD, fact/rule/term stores, path index, COW, session resolution
vdr_prolog.zig        — Unification, query, rule firing, backtracking
vdr_grammar.zig       — Template compile, render, inherit
vdr_session.zig       — Session lifecycle, _llm.* subtree, clone/merge/kill
vdr_snapshot.zig      — Save/restore per-KB + session snapshots, CRC32
vdr_training.zig      — canTrain, train, temporary arenas, weight update, provenance
vdr_runner.zig        — Poller, processor, internal, batch runners
vdr_inference.zig     — Full inference loop, prompt processing cycle, L1/L2/L3
vdr_command.zig       — Command parser, executor, KB/Prolog/grammar dispatch
vdr_access.zig        — Visibility check, session/global resolution, per-group weight access
vdr_grant.zig         — Grant CRUD, check, cleanup
vdr_audit.zig         — Ring buffer, query, filter
vdr_confidence.zig    — Assign, combine, chain, propagate
vdr_seed.zig          — Seed layer init, domain weight KB creation
vdr_builtin.zig       — 448 builtins, IOSE validation, dispatch
vdr_system.zig        — Top-level init, wire everything, config
vdr_test.zig          — Determinism, roundtrip, isolation, SIMD correctness
build.zig             — Single native x86_64 target

25 files. ~20K lines estimated.
```
