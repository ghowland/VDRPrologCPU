# VDR-Prolog Technical Specification

## CPU SIMD, Arena-Only, NUMA-Aligned

### Version 0.2 — Laptop Target

---

## 1. Scope

This spec defines the complete VDR-Prolog system running on a single laptop. No GPU. No device/host split. All compute is CPU with AVX2 SIMD. All memory is fixed-size arenas allocated at startup. No malloc after init. Target: Dell Legion 5 (~2019), 6-8 core x86_64, 16-32GB RAM, AVX2.

The model is not a monolith. Model weights live in KBs. Access to model weight KBs is grant-gated. Different users see different model capabilities. Each LLM session gets an ephemeral KB subtree for scratch work, addressed with negative IDs that never collide with global data.

---

## 2. System Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                     SINGLE PROCESS                            │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │                Global Arena (NUMA node 0)                │  │
│  │  Seed KBs │ Model Weights │ Text Store │ Path Index      │  │
│  │  Grant Store │ Audit Ring │ Confidence Table              │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                               │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │ Core 0   │ │ Core 1   │ │ Core 2   │ │ Core N   │       │
│  │ Arena    │ │ Arena    │ │ Arena    │ │ Arena    │       │
│  │ Thread   │ │ Thread   │ │ Thread   │ │ Thread   │       │
│  │ Sessions │ │ Sessions │ │ Sessions │ │ Sessions │       │
│  │ KV Cache │ │ KV Cache │ │ KV Cache │ │ KV Cache │       │
│  │ Scratch  │ │ Scratch  │ │ Scratch  │ │ Scratch  │       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
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

One process. N+1 arenas (1 global + N per-core). Pinned threads. Direct function calls. No IPC, no serialization, no bridge layer.

---

## 3. ID System — Dual Addressing with Sign-Bit Partitioning

### 3.1 ID Structure

Every entity (KB, fact slot, rule, term, grammar) has a 64-bit ID. Bit 63 (sign bit) partitions the address space:

```
Bit 63 = 0: Global (positive). Persistent. Shared across sessions.
Bit 63 = 1: Ephemeral (negative). Session-local. Dies with session.
```

Global IDs are UUID-derived, always positive. Ephemeral IDs are monotonically decrementing negative integers, unique within a session.

```
struct vlp_id {
    v: i64,   // positive = global, negative = ephemeral

    pub fn isGlobal(self: vlp_id) bool { return self.v >= 0; }
    pub fn isEphemeral(self: vlp_id) bool { return self.v < 0; }
};
```

### 3.2 UUID Generation

Global IDs are UUIDs with bit 63 cleared (always positive). Generated from a counter + hash at KB creation time. Immutable once assigned.

```
fn generateGlobalId(counter: *i64) vlp_id {
    counter.* += 1;
    // Hash counter to spread across space, clear sign bit
    const raw = hashU64(counter.*);
    return .{ .v = @as(i64, @intCast(raw & 0x7FFFFFFFFFFFFFFF)) };
}
```

### 3.3 Ephemeral ID Generation

Each session owns a decrementing counter starting at -1.

```
fn generateEphemeralId(counter: *i64) vlp_id {
    const id = counter.*;
    counter.* -= 1;
    return .{ .v = id };  // -1, -2, -3, ...
}
```

Ephemeral IDs never collide with global IDs. Session A's -5 and session B's -5 are in different session scopes — they never share an arena or namespace.

### 3.4 Dual Addressing — Walk and Direct

Every KB is addressable two ways:

**Walk path:** `root.science.physics.qed.alpha_em` → `1.12.17.13.25` (sequential tree position IDs)

**Direct UUID:** `alpha_em` has a global UUID, e.g. `0x3A7F...`. Any code can jump directly to it without walking the tree.

Both paths resolve to the same KB struct in the store. The path index maps dotted paths to IDs. The UUID is the canonical ID stored in the KB struct.

```
root.science.physics.qed.alpha_em
  walk:   1 → 12 → 17 → 13 → 25        (tree position, sequential)
  direct: UUID 0x3A7F...                  (hash-based, one hop)
```

### 3.5 Session Ephemeral Tree

Each session gets an ephemeral root at ID -1. The LLM writes scratch data here.

```
session_root = -1
session_root.scratch = -2
session_root.scratch.current_query = -3
session_root.notes = -4
session_root.notes.hypothesis_1 = -5
```

These IDs are local to the session. When the session dies, the ephemeral arena region is freed. No cleanup of individual entries needed — the arena bump pointer resets.

The LLM can write ephemeral notes to itself:

```
CMD_KB_ASSERT session_root.notes.hypothesis_1 fact(confidence_too_low, retry_with_source_b)
```

This is a scratchpad the LLM controls. It persists across turns within a session but dies with the session. It's in the session's per-core arena, so access is local memory — no contention.

### 3.6 Ephemeral-to-Global Promotion

When the LLM formalizes an ephemeral fact as a Prolog rule or asserts it to a global KB, the data crosses from negative to positive address space:

```
// LLM discovers something worth keeping
CMD_KB_ASSERT root.science.physics.qed.alpha_strong fact(value, 11800)
```

This writes to the global store with a new global UUID. The ephemeral version can be retracted or left to die with the session. Promotion is explicit — ephemeral data never leaks to global implicitly.

---

## 4. Core Data Types

### 4.1 VDR Value Types

```
// Q16 — the primary operational type
// 8 bytes. Two remainder slots. No wasted padding.
struct vlp_q16 {
    v: i32,       // numerator (value / D)
    r0: i16,      // remainder level 0
    r1: i16,      // remainder level 1 (sub-r0 precision)
};
// D = 65536 (2^16). Implicit. Never stored.
// sizeof(vlp_q16) = 8 bytes.
// r1 carries precision below r0.
// Two levels of remainder = you always know what was lost.

// Q32 — intermediate precision
struct vlp_q32 {
    v: i64,
    r0: i32,
    r1: i32,
};
// D = 4294967296 (2^32). sizeof = 16 bytes.

// Q335 — high precision / transcendentals
struct vlp_q335 {
    v: [6]i64,      // 384-bit value as 6 × 64-bit limbs
    r0: [6]i64,
    r1: [6]i64,
    r2: [6]i64,
    r3: [6]i64,
};
// D = 2^335. sizeof = 240 bytes. Depth 4 remainders fixed.
```

### 4.2 Fact Types

```
enum vlp_fact_tag: i32 {
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

struct vlp_provenance {
    source_type: i32,
    source_kb_id: vlp_id,     // now vlp_id (i64), not i32
    source_slot_id: i32,
    confidence: vlp_q16,
    timestamp: i32,
    derivation_rule_id: i32,
};
// sizeof = 32 bytes.

struct vlp_fact {
    tag: vlp_fact_tag,
    value: vlp_q16,
    provenance: vlp_provenance,
};
// sizeof = 44 bytes. Padded to 48 for alignment.
```

### 4.3 KB Type

```
struct vlp_kb {
    // Identity
    id: vlp_id,                  // i64: positive = global, negative = ephemeral
    parent_id: vlp_id,           // i64: -1 special = no parent (root)
    name_offset: i32,            // offset into text store
    name_length: i16,
    path_offset: i32,
    path_length: i16,
    walk_id: i32,                // sequential tree position (for walk addressing)

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

    // Children
    children_offset: i32,
    children_count: i16,
    children_capacity: i16,
    mounts_offset: i32,
    mounts_count: i16,

    // Metadata
    visibility: i8,              // 0=public, 1=internal, 2=owner_only
    frozen: i8,
    owner_id: vlp_id,            // i64: owner user ID
    created_at: i32,
    last_modified: i32,
};
// Padded to 256 bytes for cache line alignment.
```

### 4.4 Prolog Types

```
enum vlp_term_type: i8 {
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

struct vlp_term {
    type: vlp_term_type,
    primary_id: i32,         // atom_id | var_id | int_value | functor_id
    secondary_offset: i32,   // text_offset | list_head_offset | args_offset
    secondary_aux: i32,      // text_length | list_tail_offset | args_count
    vdr_value: vlp_q16,
};
// sizeof = 24 bytes.

struct vlp_rule {
    id: vlp_id,              // i64
    head: i32,               // offset to head term
    body_offset: i32,
    body_count: i16,
    action_offset: i32,
    action_count: i16,
    fire_count: i32,
    last_fired: i32,
    success_count: i32,
    failure_count: i32,
    created_at: i32,
    creator_session_id: vlp_id,
};
// sizeof = 48 bytes.

struct vlp_binding {
    var_id: i32,
    bound_term_offset: i32,
};

struct vlp_unification_result {
    unified: i8,
    bindings_offset: i32,
    bindings_count: i16,
};
```

### 4.5 Grammar Types

```
enum vlp_slot_type: i8 {
    SLOT_VDR_VALUE  = 0,
    SLOT_TEXT       = 1,
    SLOT_INTEGER    = 2,
    SLOT_ENUM       = 3,
    SLOT_KB_REF     = 4,
    SLOT_GRAMMAR    = 5,
};

struct vlp_grammar {
    id: vlp_id,
    template_offset: i32,
    template_length: i32,
    slots_offset: i32,
    slots_count: i16,
    validated: i8,
    created_at: i32,
    creator_session_id: vlp_id,
};
```

### 4.6 Session Types

```
enum vlp_session_state: i8 {
    SESSION_ACTIVE      = 0,
    SESSION_SNAPSHOTTED = 1,
    SESSION_KILLED      = 2,
    SESSION_FROZEN      = 3,
};

struct vlp_session {
    id: vlp_id,                  // global UUID for the session
    user_id: vlp_id,
    kb_root_id: vlp_id,          // global root KB
    ephemeral_root_id: vlp_id,   // always negative, session's scratch tree root
    ephemeral_next_id: i64,      // next ephemeral ID to assign (decrements)
    visibility_level: i8,
    state: vlp_session_state,

    // Core assignment
    core_id: i32,                // which physical core this session runs on
    arena_id: i32,               // which per-core arena

    // Resource bounds
    max_kb_count: i32,
    max_ephemeral_kbs: i32,      // max ephemeral KBs per session
    max_live_memory_bytes: i64,
    max_turns: i32,

    // Counters
    current_turn: i32,
    facts_asserted: i32,
    facts_retracted: i32,
    ephemeral_facts_asserted: i32,
    rules_fired: i64,
    prolog_queries: i64,
    primitive_calls: i64,
    grammar_renders: i64,
    llm_tokens_consumed: i64,
    command_tokens_consumed: i64,

    // Snapshot
    last_snapshot_id: vlp_id,
    last_snapshot_timestamp: i32,

    // Clone lineage
    parent_session_id: vlp_id,
    clone_generation: i32,
};
```

### 4.7 Runner, Grant, Audit, Command Types

These are identical to v0.1 except all `i32` ID fields become `vlp_id` (i64). The structures, enums, and semantics are unchanged. Runner types (poller, processor, internal, batch), grant classes (filesystem, compile, execute, lint, network, process), audit actions (15 types), and command types (15 types) remain the same.

### 4.8 Confidence Table

```
const CONFIDENCE_TABLE = [11]vlp_q16{
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

Every arena is a fixed-size contiguous block allocated at startup via `std.heap.ArenaAllocator` backed by `std.heap.page_allocator`. Bump pointer allocation only. No free. No reuse until arena reset.

```
struct vlp_arena {
    base: [*]u8,          // start of arena
    size: usize,          // total bytes
    cursor: usize,        // next free byte (bump pointer)
    
    fn alloc(self: *vlp_arena, bytes: usize, alignment: usize) ?[*]u8 {
        const aligned = (self.cursor + alignment - 1) & ~(alignment - 1);
        if (aligned + bytes > self.size) return null;
        const ptr = self.base + aligned;
        self.cursor = aligned + bytes;
        return ptr;
    }
    
    fn reset(self: *vlp_arena) void {
        self.cursor = 0;
    }
    
    fn usedBytes(self: *vlp_arena) usize {
        return self.cursor;
    }
};
```

### 5.2 Arena Layout

```
Global Arena (1 instance, read-heavy, write-rare):
    Model weights:        ~2 GB (1B params × 2 bytes i16)
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
    Ephemeral KB store:   ~8 MB (per-session scratch KBs)
    Ephemeral fact store: ~48 MB (per-session scratch facts)
    KV cache:             ~128 MB (partitioned across sessions on this core)
    Scratch buffers:      ~32 MB (matmul intermediates, attention scores)
    Binding buffers:      ~1 MB (Prolog unification)
    Render buffers:       ~1 MB (grammar output)
    Total per core:       ~220 MB

System total (8 cores): 2.65 GB + 8 × 220 MB = ~4.4 GB
Fits comfortably in 16 GB laptop with room for OS and other apps.
```

### 5.3 NUMA Alignment

```
vlp_numa_init() -> vlp_status
    1. Detect physical core count via std.Thread.getCpuCount().
    2. For each physical core:
       a. Allocate per-core arena via page_allocator (OS gives
          NUMA-local pages when thread is pinned).
       b. Spawn thread, pin to core via OS affinity API.
       c. Touch all pages from the pinned thread (first-touch policy
          ensures NUMA-local placement on multi-socket systems).
    3. Allocate global arena from core 0's NUMA node.
    4. All subsequent arena operations from a thread use only
       that thread's per-core arena for session-local data,
       and read-only access to global arena for shared data.
```

On a single-socket laptop (Dell Legion 5), all memory is on one NUMA node. The pinning and per-core arenas still help for cache locality — each core's working set stays in its L1/L2 cache without bouncing.

---

## 6. Compute Model — CPU SIMD

### 6.1 SIMD Strategy

All hot-path computation uses AVX2: 256-bit vectors, 8 × i32 lanes.

```
// VDR Q16 SIMD operations
// Process 8 Q16 values simultaneously on the .v field.
// r0 and r1 propagated in scalar post-pass for full precision.

const Vec8i32 = @Vector(8, i32);
const Vec4i64 = @Vector(4, i64);

fn simd_q16_mul_v(a: Vec8i32, b: Vec8i32) Vec8i32 {
    // Widening multiply: split into 4-wide i64 pairs
    const a_lo: Vec4i64 = ... ; // lower 4 elements widened
    const a_hi: Vec4i64 = ... ; // upper 4 elements widened
    const b_lo: Vec4i64 = ... ;
    const b_hi: Vec4i64 = ... ;
    const prod_lo = a_lo * b_lo;
    const prod_hi = a_hi * b_hi;
    // Divide by D (shift right 16)
    const result_lo = prod_lo >> @splat(16);
    const result_hi = prod_hi >> @splat(16);
    // Pack back to 8 × i32
    return pack_i64_to_i32(result_lo, result_hi);
}

fn simd_dot_product(a: []const i32, b: []const i32, n: i32) i64 {
    var acc = Vec4i64{ 0, 0, 0, 0 };
    var i: usize = 0;
    while (i + 8 <= n) : (i += 8) {
        const va: Vec8i32 = a[i..][0..8].*;
        const vb: Vec8i32 = b[i..][0..8].*;
        // Widening multiply-accumulate
        acc += widen_madd(va, vb);
    }
    // Horizontal sum + scalar tail
    return horizontal_sum(acc) + scalar_tail(a[i..], b[i..], n - i);
}
```

### 6.2 GEMM — The Bottleneck

Matrix multiply is the critical path. For a 1B model token:

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
    8 cores:     ~192 GMAC/s → 640M / 192G = ~3.3ms per token → ~300 tok/s
```

Parallelization: split GEMM rows across cores. Thread K computes rows [K×chunk, (K+1)×chunk). Synchronize via atomic counter after each layer.

```
vlp_gemm(A: []const i32, B: []const i32, C: []i32,
         M: i32, N: i32, K: i32,
         thread_pool: *vlp_thread_pool) void
    // Each thread computes a chunk of rows
    // Row i of C = dot(A[i,:], B[:,j]) for all j
    // Inner loop uses simd_dot_product
    // i32 accumulation in i64 to prevent overflow
    // Final divTrunc by D to get Q16 result
```

### 6.3 Softmax — Exact Unity

Same algorithm as the proven toy model. No float.

```
vlp_softmax_exact(logits: []i32, probs: []i32, n: i32, D: i32) void
    1. Find max (SIMD scan)
    2. Compute int_exp(logit[i] - max) for each i
    3. Sum all exp values
    4. probs[i] = (exp[i] * D) / total
    5. remainder[i] = (exp[i] * D) % total
    6. Find index with largest remainder
    7. Add deficit (D - sum(probs)) to that index
    // Sum is now exactly D. Every time.
```

### 6.4 Layer Norm (RMSNorm)

Integer RMSNorm using Newton-Raphson for inverse square root:

```
vlp_rmsnorm(input: []i32, output: []i32, gamma: []const i32, n: i32) void
    1. Compute mean of squares: sum(x[i]^2) / n (SIMD reduction)
    2. Newton-Raphson for 1/sqrt(mean_sq): 4 iterations in i64
    3. output[i] = (input[i] * inv_rms * gamma[i]) / D^2
```

### 6.5 Attention

```
vlp_attention(Q: []i32, K_cache: []i32, V_cache: []i32,
              output: []i32, config: *attn_config) void
    1. For each head:
       a. scores[pos] = dot(Q_head, K_cache[pos]) * scale / D
       b. Apply causal mask (set future to -MAXINT)
       c. vlp_softmax_exact(scores)  // exact unity
       d. output_head = weighted sum of V_cache by scores
    2. Concatenate heads, output projection via GEMM
```

### 6.6 Thread Pool

```
struct vlp_thread_pool {
    threads: [MAX_CORES]std.Thread,
    arenas: [MAX_CORES]*vlp_arena,
    n_cores: i32,
    
    // Work distribution for GEMM
    barrier_counter: std.atomic.Value(i32),
    current_work: *vlp_work_item,
};

struct vlp_work_item {
    op: enum { gemm, softmax, idle },
    // GEMM params
    A: []const i32, B: []const i32, C: []i32,
    M: i32, N: i32, K: i32,
    // Row range for this thread
    row_start: i32, row_end: i32,
};
```

Barrier: atomic decrement. Last thread to finish signals completion. No mutex, no condition variable. Spin-wait on atomic for the ~microsecond GEMM duration.

---

## 7. Model Architecture — KB-Distributed Weights

### 7.1 Model as KB Tree

The model is not a monolithic blob. Each component is a KB:

```
root.model
├── embedding                    # vocab_size × d_model, i16 weights
├── layers
│   ├── layer_00
│   │   ├── attention
│   │   │   ├── qkv_weights      # d_model × 3*d_model
│   │   │   └── output_weights   # d_model × d_model
│   │   ├── mlp
│   │   │   ├── up_weights       # d_model × mlp_dim
│   │   │   └── down_weights     # mlp_dim × d_model
│   │   └── norm
│   │       ├── attn_gamma       # d_model
│   │       └── mlp_gamma        # d_model
│   ├── layer_01
│   │   └── ...
│   └── layer_15
│       └── ...
├── final_norm                   # d_model
└── lm_head                     # d_model × vocab_size
```

### 7.2 Grant-Gated Model Access

Access to model weight KBs follows the same grant system as any KB:

```
// User A has full model access
grant(user_a, read, root.model.*)

// User B only gets layers 0-7 (reduced capability)
grant(user_b, read, root.model.embedding)
grant(user_b, read, root.model.layers.layer_0*)
grant(user_b, read, root.model.final_norm)
grant(user_b, read, root.model.lm_head)

// User C gets no model access (KB-only operations, L3 only)
// No grants to root.model.*
```

The forward pass checks access for each layer KB before loading weights. If a layer is denied, the forward pass skips it (or returns an error). This means different users literally see different models.

### 7.3 Weight Format

Weights stored as i16 in KBs (2 bytes per parameter). During forward pass, widened to i32 for computation. This halves model memory:

```
1B params × 2 bytes = 2 GB (fits in laptop RAM)
```

Weight KBs are frozen after loading. Immutable. Shared read-only across all sessions.

---

## 8. Inference Loop

### 8.1 Full Cycle

```
vlp_inference_cycle(session: vlp_session_handle, input: []const u8,
                    output: *vlp_output_buffer) -> vlp_status

    // Phase 1: Input Processing
    tokens = vlp_tokenize(input);

    // Phase 2: Context Assembly
    // Context is approximately constant size regardless of turn number.
    context = [];
    context.append(system_prompt);           // from seed KB, ~200 tokens
    context.append(scope_reference);         // active KB path, ~5 tokens
    context.append(input_tokens);            // current turn
    context.append(scratchpad);              // previous command results, ~0-50 tokens
    // Context does NOT contain prior turns, data, prior reasoning, or templates.
    // Those are in KBs (global or ephemeral).

    // Phase 3: Check which model KBs this session can access
    visible_layers = vlp_access_resolve_model(session);
    // If user has partial model access, forward pass uses only those layers.

    // Phase 4: LLM Forward Pass
    logits = vlp_forward(context, visible_layers, session.core_id);
    // SIMD GEMM across all cores, synchronized per layer.

    // Phase 5: Generation Loop
    loop {
        token = vlp_sample(logits, sampling_config);

        if is_command_start(token):
            command = vlp_generate_command(session);  // constrained vocab
            result = vlp_command_execute(session, command);
            // Result goes to scratchpad (ephemeral KB)
            vlp_kb_assert(session.ephemeral_root_id, scratchpad_slot, result);

        elif is_direct_output(token):
            kb_url = vlp_parse_kb_url(token_stream);
            data = vlp_kb_read(kb_url.kb_id, kb_url.slot_id);
            grammar = vlp_grammar_inherit(kb_url.kb_id);
            if grammar: vlp_grammar_render(grammar, data, output);
            else: vlp_render_fact(data, output);

        elif is_end_of_turn(token):
            break;

        else:
            // Prose token — judgment and framing
            output.append(token);

        logits = vlp_forward_single(token, visible_layers, session.core_id);
    }

    // Phase 6: Post-Processing
    session.current_turn += 1;
    session.llm_tokens_consumed += tokens_generated;

    // Phase 7: Auto-Snapshot
    if session.current_turn % auto_snapshot_interval == 0:
        vlp_session_snapshot(session);
```

### 8.2 Execution Levels

Identical to v0.1:

```
L1 — Full LLM Judgment:     50-500 tokens. No stored rule covers it.
L2 — LLM Invokes Rule:      ~8 command tokens + ~10 prose tokens. ~3% of L1 cost.
L3 — Automatic Rule Firing:  0 LLM tokens. Pure Prolog. 93% of ops at maturity.
```

### 8.3 Ephemeral Scratchpad Usage

The LLM uses its ephemeral KB for working memory between turns:

```
// Turn 1: LLM investigates an issue
CMD_KB_ASSERT session_root.notes.investigation fact(suspect, service_checkout)
CMD_KB_ASSERT session_root.notes.investigation fact(evidence, error_rate_spike)

// Turn 2: LLM reads its own notes from previous turn
CMD_KB_QUERY session_root.notes.investigation
// → Returns facts without them being in the context window

// Turn 3: LLM concludes and promotes to global
CMD_KB_ASSERT root.ops.incidents.inc_042 fact(root_cause, checkout_memory_leak)
CMD_KB_ASSERT root.ops.incidents.inc_042 fact(source, session_root.notes.investigation)
// Ephemeral data referenced in global provenance
```

---

## 9. KB Store — Direct Memory Access

### 9.1 Operations

No bridge layer. All operations are direct pointer arithmetic into arena memory:

```
vlp_kb_store_fact_write(kb_id: vlp_id, slot_id: i32, fact: *vlp_fact) -> vlp_status
    // Resolve arena: if kb_id.isGlobal() → global arena, else → session's per-core arena
    // Compute offset: kb.facts_offset + slot_id * sizeof(vlp_fact)
    // Direct memcpy into arena. O(1). No syscall.

vlp_kb_store_fact_read(kb_id: vlp_id, slot_id: i32) -> ?*vlp_fact
    // Same arena resolution. Return pointer directly into arena memory.
    // No copy. Caller reads from arena. Read-only for global, read-write for ephemeral.

vlp_kb_store_scoped_search(start_kb_id: vlp_id, tag: vlp_fact_tag, max_depth: i32) -> search_result
    // Walk parent chain. If start is ephemeral (-), walk ephemeral tree first,
    // then cross to global (+) at the session's kb_root_id junction.
    // Ephemeral KBs shadow global KBs at the same path position.
```

### 9.2 Ephemeral/Global Resolution

When the LLM queries a path, ephemeral takes priority:

```
Query: root.science.physics.qed.alpha_em

Resolution order:
1. Check session's ephemeral tree: session_root.science.physics.qed.alpha_em (-1.-2.-3.-4.-5)
   If found → return ephemeral version
2. Check global tree: root.science.physics.qed.alpha_em (1.12.17.13.25)
   If found → return global version
3. Not found → walk parent chain for scoped search
```

This means a session can override global data locally without modifying the global store. The override dies with the session.

### 9.3 COW for Clone Sessions

Clone sessions share the parent's global KB references and get a COW copy of the parent's ephemeral tree. Page-level dirty tracking, same as v0.1 but operating on arena memory pages instead of device memory pages.

---

## 10. Prolog Engine

Direct function calls into arena memory. No dispatch, no bridge:

```
vlp_prolog_unify(a: *vlp_term, b: *vlp_term, bindings: []vlp_binding, n: *i32) -> bool
    // ATOM-ATOM: a.primary_id == b.primary_id (integer comparison)
    // VARIABLE-anything: bind
    // VDR-VDR: a.vdr_value.v == b.vdr_value.v AND a.vdr_value.r0 == b.vdr_value.r0
    //          AND a.vdr_value.r1 == b.vdr_value.r1 (exact, all three fields)
    // COMPOUND-COMPOUND: functors match + recursive arg unification
    // All integer comparisons. No float. No epsilon.

vlp_prolog_query(kb_store: *vlp_kb_store, start_kb_id: vlp_id, query: *vlp_term) -> query_result
    // Depth-first search with backtracking.
    // Iterative with explicit stack (in per-core arena scratch).
    // Searches ephemeral tree first if start_kb_id is ephemeral.
    // Crosses to global tree at session junction point.

vlp_prolog_fire_and_commit(kb_store: *vlp_kb_store, kb_id: vlp_id) -> i32
    // Match rules against facts. Fire satisfied rules.
    // Write derived facts with PROLOG_DERIVATION confidence (1/1).
    // Returns number of rules fired.
```

---

## 11. Snapshot Format

### 11.1 Binary Layout

Same as v0.1 with two changes:
- All ID fields are now i64 (vlp_id) instead of i32
- Ephemeral region included in snapshot

```
struct vlp_snapshot_header {
    magic: [4]u8,            // "VLPS"
    version: i32,            // 2 (bumped for i64 IDs)
    timestamp: i32,
    session_id: vlp_id,      // i64
    user_id: vlp_id,         // i64

    // Global region sizes (bytes) — only session's visible subset
    kb_region_size: i64,
    fact_region_size: i64,
    rule_region_size: i64,
    term_region_size: i64,
    text_region_size: i64,
    grammar_region_size: i64,
    live_state_region_size: i64,
    grant_region_size: i64,

    // Ephemeral region sizes
    ephemeral_kb_region_size: i64,
    ephemeral_fact_region_size: i64,
    ephemeral_next_id: i64,

    // Session metadata
    session_metadata: vlp_session,

    // Integrity
    checksum: i32,           // CRC32
    total_size: i64,
};
```

Snapshot captures both global (session's view) and ephemeral state. Restore is bit-identical. Ephemeral IDs are preserved — the session continues exactly where it left off.

---

## 12. Seed Layer

Identical to v0.1 except IDs are now vlp_id (i64, positive):

```
root                          id: +1
├── system                    id: +2
│   ├── oso                   id: +3     (15 engineering principles)
│   ├── confidence            id: +4     (confidence table)
│   ├── builtins              id: +5     (448 IOSE declarations)
│   ├── command_vocab         id: +6     (~300 command tokens)
│   └── hygiene               id: +7     (self-maintenance rules)
├── templates                 id: +8
│   ├── sentences             id: +9
│   └── formats               id: +10
└── model                     id: +11    (NEW: model weights)
    ├── embedding             id: +12
    ├── layers                id: +13
    │   ├── layer_00          id: +14
    │   │   ├── attention     id: +15
    │   │   └── mlp           id: +16
    │   └── ...
    ├── final_norm            id: +...
    └── lm_head               id: +...

~23,400 seed entries + model weight KBs. Frozen after init.
```

---

## 13. Configuration

```
struct vlp_system_config {
    // Hardware
    n_cores: i32,                    // 0 = auto-detect
    
    // Model
    model_checkpoint_path: [256]u8,
    model_n_layers: i32,             // default 16
    model_d_model: i32,              // default 2048
    model_n_heads: i32,              // default 16
    model_d_head: i32,               // default 128
    model_vocab_size: i32,           // default 32000
    model_mlp_dim: i32,              // default 5632

    // Arenas
    global_arena_bytes: i64,         // default 3 GB
    per_core_arena_bytes: i64,       // default 256 MB

    // Limits
    max_total_kbs: i32,              // default 100,000
    max_total_facts: i64,            // default 10,000,000
    max_total_rules: i32,            // default 100,000
    max_total_terms: i64,            // default 1,000,000
    max_sessions_per_core: i32,      // default 500
    max_ephemeral_kbs_per_session: i32,  // default 1000

    // Sessions
    default_max_turns: i32,          // default 0 (unlimited)
    auto_snapshot_interval: i32,     // default 100

    // Runners
    max_runners: i32,                // default 64

    // Safety
    audit_ring_capacity: i32,        // default 1,000,000
    default_visibility: i8,          // default INTERNAL

    // Sampling
    default_temperature_v: i32,      // default 65536 (1.0)
    default_top_k: i32,             // default 50
    default_top_p_v: i32,           // default 58982 (0.9)
};
```

---

## 14. Error Handling

Identical to v0.1. ERR_CAT_DEVICE renamed to ERR_CAT_MEMORY (arena exhaustion instead of GPU OOM). Same deterministic recovery tree.

---

## 15. Invariants

All 10 invariants from v0.1 hold, plus:

```
INVARIANT_11: Ephemeral IDs never collide with global IDs.
    All ephemeral IDs are negative. All global IDs are positive.
    The sign bit guarantees disjoint address spaces.

INVARIANT_12: Ephemeral data dies with its session.
    When a session is killed, its per-core arena region for ephemeral
    data is reset. No ephemeral fact survives session death.
    Ephemeral data referenced in global provenance becomes a dead link
    (the reference persists but the data is gone — provenance records
    that the derivation came from an ephemeral source).

INVARIANT_13: Arena memory is never exhausted silently.
    Every arena allocation returns null on exhaustion.
    Callers check and return ERR_CAT_MEMORY with the arena ID.
    No silent data corruption from overflow.

INVARIANT_14: SIMD GEMM produces identical results to scalar GEMM.
    The SIMD path and scalar fallback produce bit-identical output.
    Tested by running both paths on same input and comparing.
    Integer arithmetic has no SIMD-vs-scalar precision difference.
```

---

## 16. Implementation Files

```
vlp_types.zig         — Q16 (v,r0,r1), vlp_id, Fact, KB, Term, Rule, Session, etc.
vlp_shared.zig        — constants, D, exp table, field offsets, enums
vlp_arena.zig         — fixed-size arena allocator, bump pointer, reset
vlp_numa.zig          — core detection, thread pinning, arena-per-core
vlp_thread_pool.zig   — pinned threads, GEMM work distribution, atomic barrier
vlp_ops.zig           — SIMD: gemm, dot, softmax, rmsnorm, attention, silu
vlp_model.zig         — KB-based model loading, layer dispatch, forward pass
vlp_kb_store.zig      — KB CRUD, fact/rule/term stores, path index, COW, ephemeral resolution
vlp_prolog.zig        — unification, query, rule firing, backtracking
vlp_grammar.zig       — template compile, render, inherit
vlp_session.zig       — session lifecycle, ephemeral tree, clone/merge/kill
vlp_snapshot.zig      — save/restore, diff, merge, CRC32
vlp_runner.zig        — poller, processor, internal, batch runners
vlp_inference.zig     — full inference loop, L1/L2/L3, context assembly
vlp_command.zig       — command parser, executor, KB/Prolog/grammar dispatch
vlp_access.zig        — visibility check, ephemeral/global resolution
vlp_grant.zig         — grant CRUD, check, cleanup
vlp_audit.zig         — ring buffer, query, filter
vlp_confidence.zig    — assign, combine, chain, propagate
vlp_seed.zig          — seed layer init, model weight KB creation
vlp_builtin.zig       — 448 builtins, IOSE validation, dispatch
vlp_system.zig        — top-level init, wire everything, config
vlp_test.zig          — determinism, roundtrip, isolation, SIMD correctness
build.zig             — single native x86_64 target

23 files. ~18K lines estimated.
```

---

## 17. Implementation Stages

```
Stage 1: Foundation
    vlp_types, vlp_shared, vlp_arena, vlp_numa, vlp_thread_pool
    vlp_kb_store (global + ephemeral), vlp_access
    vlp_ops (scalar only, no SIMD yet)
    Basic session with ephemeral tree
    Deliverable: KBs with dual addressing, arena allocation, ephemeral writes.
    ~4,000 lines.

Stage 2: Intelligence
    vlp_prolog, vlp_grammar, vlp_builtin (pure builtins)
    vlp_session (snapshot, clone, merge, kill)
    vlp_grant, vlp_audit, vlp_confidence
    vlp_command (parse + execute)
    Deliverable: full Prolog, grammars, grants, L1→L2→L3 possible.
    ~6,000 lines.

Stage 3: Compute
    vlp_ops (AVX2 SIMD: gemm, softmax, rmsnorm, attention, silu)
    vlp_model (KB-distributed weights, grant-gated forward pass)
    vlp_inference (full loop)
    vlp_thread_pool (multi-core GEMM)
    Deliverable: LLM inference at ~300 tok/s on laptop.
    ~4,000 lines.

Stage 4: Operations
    vlp_runner (all 4 types)
    vlp_builtin (44 operational builtins)
    vlp_seed (full seed layer + model loading)
    vlp_system (daemon mode)
    Deliverable: autonomous operation.
    ~3,000 lines.

Stage 5: Testing
    vlp_test (full suite)
    Determinism, SIMD correctness, snapshot roundtrip,
    ephemeral isolation, access control, confidence propagation.
    ~1,000 lines.

Total: ~18,000 lines.
```
