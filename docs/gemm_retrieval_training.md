# VDR-Prolog GEMM, Weight Retrieval, and Training

## Technical Specification

---

## 1. Overview

GEMM (General Matrix Multiply) is the critical path for LLM inference. Every token passes through 16 layers, each with 4 GEMM operations. The system processes ~640M multiply-accumulate operations per token on a single core.

Weights live in KBs as SoA-packed arrays. Retrieval has three paths depending on KB state. Training is live — weights improve during operation via bounded temporary arenas that are the single exception to no-allocation-after-init.

All arithmetic is integer. All accumulation is i64 to prevent overflow. All results are Q16 with remainder captured. No float anywhere.

---

## 2. Weight Storage

### 2.1 SoA Layout

Weights are stored in Structure-of-Arrays format for SIMD access:

```
WeightMatrix {
    v:    [N]i32    // values, contiguous, GEMM-ready
    r0:   [N]i16    // remainder level 0
    r1:   [N]i16    // remainder level 1
    rows: i32
    cols: i32
}
```

For a 2048×2048 matrix (4,194,304 parameters):

| Array | Element Size | Total Size | Purpose |
|-------|-------------|------------|---------|
| v | 4 bytes (i32) | 16 MB | GEMM reads this at full bandwidth |
| r0 | 2 bytes (i16) | 8 MB | Training reads, precision checks |
| r1 | 2 bytes (i16) | 8 MB | Training reads, precision sentinel |
| **Total** | **8 bytes** | **32 MB** | |

Each array is cache-line aligned (64 bytes) in the arena. The `v` array is what GEMM reads — one contiguous block, no stride penalty, no interleaving with metadata. The `r0` and `r1` arrays are adjacent in memory but in separate allocations, not interleaved with `v`.

### 2.2 How Weights Get Into KBs

A KB holds weight data through its KbWeightRefs extension:

```
KB.weight_refs_offset → KbWeightRefs {
    matrix_refs: []WeightMatrix    // array of weight matrices
    matrix_count: i32
    matrix_capacity: i32
    vector_refs: []WeightVector    // array of weight vectors
    vector_count: i32
    vector_capacity: i32
    gemm_cache: ?GemmCache         // cache for non-matrix facts
}
```

A domain KB like `root.science.physics.qed` might have:

```
facts[0] = TAG_VALUE  alpha_em (v=47258, confidence=1/1)
facts[1] = TAG_VALUE  coupling_constant (v=...)
facts[2] = TAG_MATRIX (v=0, r0=0, r1=0)  → matrix_refs[0]
    matrix_refs[0] = WeightMatrix { v: [2048*2048]i32, ... rows=2048, cols=2048 }
```

The TAG_MATRIX Fact's `value.v` is the index into `matrix_refs`. The Fact provides provenance, confidence, timestamps. The WeightMatrix provides the data. This separation means facts are 48 bytes (cheap to scan) and weight data is contiguous (fast for GEMM).

### 2.3 Model Weight Distribution

There is no `root.model` tree. Weights are distributed across domain KBs. The inference forward pass collects weights from all KBs visible to the session:

```
root.system.embedding     → vocab embedding table (WeightMatrix)
root.system.output        → lm_head projection + final norm (WeightMatrix + WeightVector)
root.science.physics      → physics reasoning weights
root.science.chemistry    → chemistry reasoning weights
root.ops.incidents        → incident triage weights
```

A session with grants to `root.science.physics` but not `root.science.chemistry` has a forward pass that includes physics weights and excludes chemistry weights. The effective model is the union of all accessible weight KBs.

Shared infrastructure weights (embedding, output projection, final norm) live in `root.system.*` KBs with broad grants — every session sees them. Domain-specific weights are narrowly granted.

---

## 3. GEMM Execution

### 3.1 Per-Thread, No Coordination

Each pinned compute thread executes complete GEMM operations independently. No row splitting across cores. No barrier synchronization. No atomic counters for progress. A session's inference runs entirely on one core, start to finish.

```
fn vdr_gemm(
    A: [*]const i32,   // input activations [M × K]
    B: [*]const i32,   // weight matrix v array [K × N]
    C: [*]i32,         // output [M × N]
    M: i32,            // rows of A (typically 1 for single token)
    N: i32,            // cols of B (output dimension)
    K: i32,            // shared dimension
) void {
    var i: i32 = 0;
    while (i < M) : (i += 1) {
        var j: i32 = 0;
        while (j < N) : (j += 1) {
            C[@intCast(i * N + j)] = simd_dot_product(
                A[@intCast(i * K)..],
                B[@intCast(j * K)..],   // B is stored column-major for this access
                K,
            );
        }
    }
}
```

### 3.2 SIMD Dot Product

The inner loop processes 8 i32 values per cycle using AVX2:

```
fn simd_dot_product(a: [*]const i32, b: [*]const i32, n: i32) i32 {
    const Vec8i32 = @Vector(8, i32);
    const Vec4i64 = @Vector(4, i64);

    var acc_lo: Vec4i64 = .{ 0, 0, 0, 0 };
    var acc_hi: Vec4i64 = .{ 0, 0, 0, 0 };

    var i: usize = 0;
    const len: usize = @intCast(n);

    while (i + 8 <= len) : (i += 8) {
        const va: Vec8i32 = a[i..][0..8].*;
        const vb: Vec8i32 = b[i..][0..8].*;

        // Widening multiply-accumulate into i64
        // Split 8×i32 into 2×4×i64, multiply, accumulate
        const a_lo: Vec4i64 = .{va[0], va[1], va[2], va[3]};
        const a_hi: Vec4i64 = .{va[4], va[5], va[6], va[7]};
        const b_lo: Vec4i64 = .{vb[0], vb[1], vb[2], vb[3]};
        const b_hi: Vec4i64 = .{vb[4], vb[5], vb[6], vb[7]};

        acc_lo += a_lo * b_lo;
        acc_hi += a_hi * b_hi;
    }

    // Horizontal sum
    const combined = acc_lo + acc_hi;
    var sum: i64 = combined[0] + combined[1] + combined[2] + combined[3];

    // Scalar tail for remaining elements
    while (i < len) : (i += 1) {
        sum += @as(i64, a[i]) * @as(i64, b[i]);
    }

    // Final divTrunc by D to get Q16 result
    // The remainder from this division is the GEMM output's r0
    return @intCast(@divTrunc(sum, Q16.D));
}
```

Key properties:

- **i64 accumulation.** i32 × i32 produces i64. Accumulated over K=2048 elements, the sum can reach ~2048 × (2^31)^2 = ~2048 × 2^62. This fits in i64 (2^63 - 1). If K exceeds ~4096 with max-range weights, the accumulator could overflow — a production system checks K against weight magnitude and splits the accumulation if needed.

- **divTrunc by D at the end.** The entire dot product accumulates in i64 without any intermediate division. One division at the end. The remainder from this division is the output's r0. This is captured, not discarded.

- **No remainder propagation inside the dot product.** The v fields of the weights are what GEMM reads. The r0 and r1 fields of individual weights are not involved in the GEMM inner loop. They exist for training weight updates and precision auditing.

### 3.3 Remainder Capture on GEMM Output

After the dot product computes the i64 sum, the Q16 result is:

```
fn gemm_output_q16(sum: i64) Q16 {
    const v: i32 = @intCast(@divTrunc(sum, Q16.D));
    const r0: i16 = @intCast(@mod(sum, Q16.D));
    // r1 is zero for GEMM output — there are no cross-terms
    // at this level. r1 becomes meaningful if this output
    // feeds into further Q16 multiplication.
    return Q16.fromParts(v, r0, 0);
}
```

For inference, only `v` feeds forward to the next layer. The `r0` is captured and available for precision analysis but does not participate in the hot path. For training, the captured remainder matters — it tells the backward pass exactly how much structure the forward pass couldn't represent.

### 3.4 Per-Layer GEMM Operations

For a single token through one transformer layer:

```
// Layer input: x [1 × d_model] where d_model = 2048

// 1. QKV Projection: x × W_qkv → qkv [1 × 3*d_model]
//    W_qkv is [d_model × 3*d_model] = [2048 × 6144]
//    12.6M MACs
vdr_gemm(x, W_qkv.v.ptr, qkv, 1, 6144, 2048);

// 2. Attention (not GEMM — dot products + softmax + weighted sum)
//    See attention spec.

// 3. Output Projection: attn_out × W_o → projected [1 × d_model]
//    W_o is [d_model × d_model] = [2048 × 2048]
//    4.2M MACs
vdr_gemm(attn_out, W_o.v.ptr, projected, 1, 2048, 2048);

// 4. Residual add (with full remainder propagation)
//    x = x + projected
//    This is element-wise Q16 add with r1→r0→v carry chain.

// 5. RMSNorm

// 6. MLP Up: norm_out × W_up → mlp_hidden [1 × mlp_dim]
//    W_up is [d_model × mlp_dim] = [2048 × 5632]
//    11.5M MACs
vdr_gemm(norm_out, W_up.v.ptr, mlp_hidden, 1, 5632, 2048);

// 7. SiLU activation (integer approximation, element-wise)

// 8. MLP Down: mlp_hidden × W_down → mlp_out [1 × d_model]
//    W_down is [mlp_dim × d_model] = [5632 × 2048]
//    11.5M MACs
vdr_gemm(mlp_hidden, W_down.v.ptr, mlp_out, 1, 2048, 5632);

// 9. Residual add
//    x = x + mlp_out

// Total per layer: ~40M MACs
// Total 16 layers: ~640M MACs per token
```

### 3.5 Weight Memory Layout for GEMM

GEMM reads the `v` array of each WeightMatrix sequentially. For optimal cache behavior, the weight matrix is stored in column-major order so that the dot product between an input row and a weight column reads a contiguous span:

```
Weight matrix W [K × N] stored as:
    Column 0: W[0,0], W[1,0], W[2,0], ..., W[K-1,0]
    Column 1: W[0,1], W[1,1], W[2,1], ..., W[K-1,1]
    ...
    Column N-1: W[0,N-1], W[1,N-1], ..., W[K-1,N-1]

v array layout: [col0_elem0, col0_elem1, ..., col0_elemK-1,
                 col1_elem0, col1_elem1, ..., col1_elemK-1,
                 ...]
```

This means `simd_dot_product(input, &W.v[j * K], K)` reads a contiguous block for column `j`. No stride. No gather. Full cache line utilization.

If weights arrive in row-major order (from checkpoint loading), they are transposed once during seed layer initialization. The transposition cost is paid once at startup.

---

## 4. Three-Path Weight Retrieval

When the inference engine needs weights from a KB, the retrieval path depends on the KB's current state. This is a simple if/else chain — no polymorphism, no vtable.

### 4.1 Path 1: Full Fact Scan

**When:** The KB has facts with weight data but no GEMM cache. This happens for freshly populated KBs that have never been trained.

**Test:** `kb.weight_refs_offset == -1` or the KbWeightRefs has no gemm_cache.

```
fn fullFactScan(kb: *KB, arena: *Arena) WeightView {
    const facts = getFactArray(kb, arena);
    // facts is a contiguous array of 48-byte Fact structs

    var result = WeightView{};
    var i: i32 = 0;
    while (i < kb.facts_count) : (i += 1) {
        const fact = &facts[@intCast(i)];
        switch (fact.tag) {
            .matrix => {
                // fact.value.v is the index into matrix_refs
                const wrefs = getWeightRefs(kb, arena);
                const matrix = &wrefs.matrix_refs[@intCast(fact.matrixRefIndex())];
                result.addMatrix(matrix, fact);
            },
            .vector => {
                const wrefs = getWeightRefs(kb, arena);
                const vector = &wrefs.vector_refs[@intCast(fact.matrixRefIndex())];
                result.addVector(vector, fact);
            },
            .value => {
                // Non-matrix fact with a Q16 value
                // These contribute to the KB's conceptual weight
                // but are not GEMM operands until cached
                result.addScalar(fact);
            },
            else => {},  // skip non-weight facts
        }
    }
    return result;
}
```

**Performance:** 48-byte stride per fact. For a KB with 1000 facts, that's 48KB of sequential reads — fits in L1 cache. For a KB with 100K facts, that's 4.8MB — fits in L2 but not ideal. This is why GEMM caches exist.

**Used for:** First inference after KB creation. Also used as a correctness reference — the GEMM cache is validated against full scan results during testing.

### 4.2 Path 2: GEMM Cache Only

**When:** The KB has been trained. A GEMM cache exists for the session's access group. No new facts have been added since the last training run.

**Test:** `gemm_cache != null` and `kb.new_facts_since_training_count == 0`.

```
fn cacheOnly(cache: *GemmCache) WeightView {
    // The cache is a contiguous i32 array of all v fields
    // from the KB's weight facts, packed and cache-line aligned.
    // GEMM reads this directly. No fact scanning.
    return WeightView{
        .v_data = cache.v_packed,
        .count = cache.fact_count,
        .source = .cache,
    };
}
```

**Performance:** The cache is a single contiguous allocation. GEMM reads it sequentially. No 48-byte-per-fact overhead. No tag checking. No provenance skipping. Pure data.

**Used for:** Every inference after training. This is the hot path. The vast majority of GEMM operations use this path at maturity.

### 4.3 Path 3: GEMM Cache + New Facts Scan

**When:** The KB has a GEMM cache from a previous training run, but new facts have been added since then. The new facts haven't been incorporated into the cache yet.

**Test:** `gemm_cache != null` and `kb.new_facts_since_training_count > 0`.

```
fn cachePlusNewFacts(cache: *GemmCache, kb: *KB, arena: *Arena) WeightView {
    // Start with the cached data (bulk of the weights)
    var result = WeightView{
        .v_data = cache.v_packed,
        .count = cache.fact_count,
        .source = .cache_plus_new,
    };

    // Scan only the new facts added since training
    const new_indices = getNewFactIndices(kb, arena);
    // new_indices is ArrayListManaged(i32) — typically short
    const facts = getFactArray(kb, arena);

    for (new_indices.items) |fact_idx| {
        const fact = &facts[@intCast(fact_idx)];
        switch (fact.tag) {
            .matrix => {
                const wrefs = getWeightRefs(kb, arena);
                result.addMatrix(&wrefs.matrix_refs[@intCast(fact.matrixRefIndex())], fact);
            },
            .vector => {
                const wrefs = getWeightRefs(kb, arena);
                result.addVector(&wrefs.vector_refs[@intCast(fact.matrixRefIndex())], fact);
            },
            .value => result.addScalar(fact),
            else => {},
        }
    }

    return result;
}
```

**Performance:** Reads the bulk data from the cache (fast), then scans a short list of new fact indices. Each new fact is accessed by its index — O(1) per fact. If 5 facts were added since training, only 5 × 48 bytes are scanned beyond the cache read.

**Used for:** Inference after new facts are asserted to a trained KB but before the next training run. Avoids the cost of full fact scan while incorporating new data.

### 4.4 New-Facts Tracking

Each KB maintains an `ArrayListManaged(i32)` tracking fact indices added since the last training:

```
// On fact assertion:
fn assertFact(kb: *KB, fact: Fact, arena: *Arena) Status {
    const slot = kb.facts_count;
    writeFact(kb, slot, fact, arena);
    kb.facts_count += 1;
    kb.last_modified = currentTimestamp();

    // Track for Path 3 retrieval
    if (hasGemmCache(kb, arena)) {
        var new_facts = getNewFactsList(kb, arena);
        new_facts.append(@intCast(slot)) catch return Status.err(.memory, .arena_exhausted, 0);
    }

    return Status.ok();
}

// After training completes:
fn clearNewFactsList(kb: *KB, arena: *Arena) void {
    var new_facts = getNewFactsList(kb, arena);
    new_facts.clearRetainingCapacity();
    kb.new_facts_since_training_count = 0;
}
```

### 4.5 Per-Group GEMM Caches

Different access groups see different effective weights. The GEMM cache is per-group:

```
fn cacheForGroup(wrefs: *KbWeightRefs, group_id: i32) ?*GemmCache {
    // Each KbWeightRefs can hold caches for up to N_GROUPS (2-4)
    // Indexed by group_id
    if (wrefs.group_caches[group_id]) |cache| {
        return cache;
    }
    return wrefs.gemm_cache;  // fallback to default cache
}
```

During cache rebuild, weights are filtered by capability level:

```
fn rebuildCacheForGroup(kb: *KB, group_level: i32, arena: *Arena) GemmCache {
    const facts = getFactArray(kb, arena);
    var packed = arena.allocSlice(i32, @intCast(kb.facts_count)) orelse return .{};
    var count: i32 = 0;

    var i: i32 = 0;
    while (i < kb.facts_count) : (i += 1) {
        const fact = &facts[@intCast(i)];
        if (fact.provenance.capability_level > group_level) {
            packed[@intCast(count)] = 0;  // zeroed — unauthorized weight
        } else {
            packed[@intCast(count)] = fact.value.v;
        }
        count += 1;
    }

    return GemmCache{
        .v_packed = packed[0..@intCast(count)],
        .fact_count = count,
        .kb_id = kb.id,
        .kb_last_modified = kb.last_modified,
        .generation = wrefs.gemm_cache.?.generation + 1,
    };
}
```

The capability check happens during cache rebuild (cold path). During GEMM execution (hot path), the cache is read without any per-element access check. The unauthorized weights are already zeroed in the cache data.

---

## 5. Training

### 5.1 The Single Exception

Training is the only operation that allocates memory after startup. Every other allocation happens during init. Training requires temporary workspace that scales with the KB being trained — gradients, optimizer state, activations, transposed weights. This workspace is:

- Bounded by a headroom check before allocation.
- Sized per-KB, not a fixed global buffer.
- Destroyed after training completes.
- Never leaked — the pointer is nulled and the lock is released in all code paths.

### 5.2 canTrain Check

Before any allocation:

```
fn canTrain(kb: *KB, system: *SystemState) CanTrainResult {
    // Check 1: Is this KB already being trained?
    if (kb.training_lock) {
        return .{ .allowed = false, .reason = .already_locked };
    }

    // Check 2: Does this KB have trainable weights?
    if (kb.weight_refs_offset == -1) {
        return .{ .allowed = false, .reason = .no_weights };
    }

    // Check 3: Is the KB frozen?
    if (kb.isFrozen()) {
        return .{ .allowed = false, .reason = .frozen };
    }

    // Check 4: Calculate required temporary arena size
    const required = calculateTrainingArenaSize(kb, system);

    // Check 5: Does the system have enough free memory?
    const available = system.trainingHeadroomBytes();
    if (required > available) {
        return .{ .allowed = false, .reason = .insufficient_memory, .required = required, .available = available };
    }

    // Check 6: Would this exceed max concurrent training arenas?
    if (system.active_training_count >= system.max_concurrent_training) {
        return .{ .allowed = false, .reason = .max_concurrent };
    }

    return .{ .allowed = true, .required_bytes = required };
}
```

If `canTrain` returns false, `train` is never called. No partial allocation. No cleanup. The caller decides whether to retry later or skip training for this KB.

### 5.3 Training Arena Sizing

The temporary arena is sized to the specific KB's weight dimensions:

```
fn calculateTrainingArenaSize(kb: *KB, system: *SystemState) i64 {
    const wrefs = getWeightRefs(kb, system.global_arena);
    var total: i64 = 0;

    // For each weight matrix in this KB:
    for (wrefs.matrix_refs[0..@intCast(wrefs.matrix_count)]) |matrix| {
        const N = @as(i64, matrix.rows) * @as(i64, matrix.cols);

        // Gradient accumulator: same shape as weight v_data
        total += N * 4;  // i32 per element

        // Gradient r0: remainder tracking on gradients
        total += N * 2;  // i16 per element

        // Gradient r1: sub-r0 gradient precision
        total += N * 2;  // i16 per element

        // Optimizer momentum (first moment, Adam-like)
        total += N * 4;  // i32 per element

        // Optimizer variance (second moment, Adam-like)
        total += N * 4;  // i32 per element

        // Transposed weight copy (built once for backward GEMM)
        total += N * 4;  // i32 per element

        // Per-matrix subtotal: 20 bytes per parameter
    }

    // Saved activations: depends on sequence length and model dim
    // This is per-layer, so we only need one layer's worth at a time
    const seq_len = system.config.model.max_seq_len;
    const d_model = system.config.model.d_model;
    total += @as(i64, seq_len) * @as(i64, d_model) * 4;  // i32 activations

    // Scratch: 10% of above for intermediate computation
    total += @divTrunc(total, 10);

    // Alignment padding: round up to page size
    total = (total + 4095) & ~@as(i64, 4095);

    return total;
}
```

Sizing examples:

| KB Weight Shape | Parameters | Training Arena Size |
|----------------|------------|-------------------|
| 2048 × 2048 | 4,194,304 | ~100 MB |
| 1024 × 1024 | 1,048,576 | ~25 MB |
| 512 × 512 | 262,144 | ~6.5 MB |
| 128 (vector) | 128 | ~10 KB |

### 5.4 Training Arena Lifecycle

```
fn train(kb: *KB, system: *SystemState, core_id: i32) ?TrainResult {
    // Pre-check (already passed canTrain, but double-check lock)
    if (kb.training_lock) return null;

    // === PHASE 1: Allocate ===
    const arena_size = calculateTrainingArenaSize(kb, system);
    const arena = allocateTemporaryArena(arena_size) orelse return null;

    // Lock the KB
    kb.training_lock = true;
    kb.training_arena = arena;
    system.active_training_count += 1;

    // Touch all pages from the pinned thread for NUMA alignment
    touchAllPages(arena);

    // === PHASE 2: Prepare workspace ===
    const workspace = initTrainingWorkspace(kb, arena, system) orelse {
        // Allocation within the arena failed (shouldn't happen if sizing is correct)
        cleanupTraining(kb, arena, system);
        return null;
    };

    // Build transposed weight copy for backward GEMM
    transposeWeights(kb, workspace, system.global_arena);

    // === PHASE 3: Training loop ===
    const result = runTrainingLoop(kb, workspace, system) catch |err| {
        // Training failed — cleanup and return error
        cleanupTraining(kb, arena, system);
        return .{ .status = Status.err(.system, .corrupt_state, 0) };
    };

    // === PHASE 4: Write back ===
    writeUpdatedWeights(kb, workspace, system.global_arena);

    // === PHASE 5: Update metadata ===
    updateProvenanceAfterTraining(kb, workspace, system);
    markGemmCacheDirty(kb, system);
    clearNewFactsList(kb, system.global_arena);

    // === PHASE 6: Cleanup ===
    cleanupTraining(kb, arena, system);

    return result;
}

fn cleanupTraining(kb: *KB, arena: *Arena, system: *SystemState) void {
    // Destroy temporary arena
    destroyTemporaryArena(arena);

    // Null the pointer — this is the only nullable pointer in the system
    kb.training_arena = null;

    // Release the lock
    kb.training_lock = false;

    // Decrement active count
    system.active_training_count -= 1;
}
```

The cleanup function runs in every exit path — success, failure, or error. There is no code path where the lock stays held or the arena stays allocated after `train` returns. The temporary arena pointer is nulled, the lock is cleared, and the training count is decremented atomically.

### 5.5 Training Workspace Layout

Inside the temporary arena, workspace is allocated as contiguous regions:

```
fn initTrainingWorkspace(kb: *KB, arena: *Arena, system: *SystemState) ?TrainingWorkspace {
    const wrefs = getWeightRefs(kb, system.global_arena);
    const matrix = &wrefs.matrix_refs[0];  // primary weight matrix
    const N: usize = @intCast(@as(i64, matrix.rows) * @as(i64, matrix.cols));

    var ws: TrainingWorkspace = .{};

    // Gradient accumulator (same shape as weights)
    ws.grad_v = arena.allocSlice(i32, N) orelse return null;
    ws.grad_r0 = arena.allocSlice(i16, N) orelse return null;
    ws.grad_r1 = arena.allocSlice(i16, N) orelse return null;

    // Optimizer state
    ws.momentum = arena.allocSlice(i32, N) orelse return null;
    ws.variance = arena.allocSlice(i32, N) orelse return null;

    // Transposed weights (for backward pass GEMM)
    ws.weights_transposed = arena.allocSlice(i32, N) orelse return null;

    // Saved activations
    const act_size: usize = @intCast(
        @as(i64, system.config.model.max_seq_len) * @as(i64, system.config.model.d_model)
    );
    ws.activations = arena.allocSlice(i32, act_size) orelse return null;

    // Scratch
    ws.scratch = arena.allocSlice(i32, N / 10) orelse return null;

    // Zero all buffers
    @memset(std.mem.sliceAsBytes(ws.grad_v), 0);
    @memset(std.mem.sliceAsBytes(ws.grad_r0), 0);
    @memset(std.mem.sliceAsBytes(ws.grad_r1), 0);
    @memset(std.mem.sliceAsBytes(ws.momentum), 0);
    @memset(std.mem.sliceAsBytes(ws.variance), 0);

    return ws;
}
```

### 5.6 GEMM During Training

The GEMM kernel does not change between inference and training. The same `vdr_gemm` function is called. What changes is the operand source:

| Operation | A Source | B Source | Output Destination |
|-----------|---------|---------|-------------------|
| Forward GEMM | Input activations (per-core arena) | KB weight v_data (global arena) | Activations (temporary arena) |
| Score GEMM (attention) | Q vectors (temporary arena) | K cache (per-core arena) | Attention scores (per-core arena scratch) |
| Backward GEMM (activation gradients) | Output gradients (temporary arena) | Transposed weights (temporary arena) | Input gradients (temporary arena) |
| Backward GEMM (weight gradients) | Input activations transposed (temporary arena) | Output gradients (temporary arena) | Weight gradients (temporary arena) |

The forward pass during training is identical to inference — it reads weight `v` data from the KB's global arena region. The backward pass reads the transposed weight copy from the temporary arena.

### 5.7 Weight Transposition

The backward pass needs weights transposed relative to the forward pass layout. This copy is built once at the start of training:

```
fn transposeWeights(kb: *KB, workspace: *TrainingWorkspace, global_arena: *Arena) void {
    const wrefs = getWeightRefs(kb, global_arena);
    const matrix = &wrefs.matrix_refs[0];
    const rows = matrix.rows;
    const cols = matrix.cols;

    // matrix.v is stored column-major for forward GEMM
    // Transposed copy is row-major of the transposed matrix
    // = column-major with rows and cols swapped
    var r: i32 = 0;
    while (r < rows) : (r += 1) {
        var c: i32 = 0;
        while (c < cols) : (c += 1) {
            // Original: v[c * rows + r] (column-major, column c, row r)
            // Transposed: v_t[r * cols + c] (column-major of transpose)
            workspace.weights_transposed[@intCast(r * cols + c)] =
                matrix.v[@intCast(c * rows + r)];
        }
    }
}
```

This is a one-time O(N) copy at the start of training. The transposed copy lives in the temporary arena and is destroyed with it.

### 5.8 Weight Update

After the backward pass produces gradients, the weight update applies them:

```
fn updateWeight(
    current_v: *i32,
    current_r0: *i16,
    current_r1: *i16,
    grad_v: i32,
    grad_r0: i16,
    grad_r1: i16,
    momentum: *i32,
    variance: *i32,
    step: i32,
    lr: Q16,
) void {
    // Adam-like optimizer in Q16 arithmetic
    // All operations use Q16.mul, Q16.add — full remainder propagation

    // Update momentum: m = beta1 * m + (1 - beta1) * grad
    const beta1 = Q16.fromParts(60293, 0, 0);  // ~0.92
    const one_minus_beta1 = Q16.sub(Q16.one(), beta1);
    const grad_q16 = Q16.fromParts(grad_v, grad_r0, grad_r1);

    const m_scaled = Q16.mul(beta1, Q16.fromParts(momentum.*, 0, 0));
    const g_scaled = Q16.mul(one_minus_beta1, grad_q16);
    const new_m = Q16.add(m_scaled, g_scaled);
    momentum.* = new_m.v;

    // Update variance: v = beta2 * v + (1 - beta2) * grad^2
    const beta2 = Q16.fromParts(64880, 0, 0);  // ~0.99
    const one_minus_beta2 = Q16.sub(Q16.one(), beta2);
    const grad_sq = Q16.mul(grad_q16, grad_q16);

    const v_scaled = Q16.mul(beta2, Q16.fromParts(variance.*, 0, 0));
    const gsq_scaled = Q16.mul(one_minus_beta2, grad_sq);
    const new_var = Q16.add(v_scaled, gsq_scaled);
    variance.* = new_var.v;

    // Compute update: lr * m / (sqrt(v) + epsilon)
    // sqrt uses Newton-Raphson in Q32 for precision
    const sqrt_var = integerSqrt(new_var);
    const epsilon = Q16.fromParts(1, 0, 0);  // small stabilizer
    const denom = Q16.add(sqrt_var, epsilon);
    const update = Q16.div(Q16.mul(lr, new_m), denom);

    // Apply to weight
    const current = Q16.fromParts(current_v.*, current_r0.*, current_r1.*);
    const updated = Q16.sub(current, update);

    current_v.* = updated.v;
    current_r0.* = updated.r0;
    current_r1.* = updated.r1;
}
```

Key properties of the weight update:

- **Full Q16 remainder propagation.** The gradient, momentum, variance, and update are all Q16 with remainder. The optimizer tracks precision at every step.
- **Gradient r0 and r1 are captured.** The backward pass captures remainders on gradients the same way the forward pass captures remainders on activations. Gradient precision is not lost.
- **Integer sqrt via Newton-Raphson.** The Adam denominator requires square root. This is computed in Q32 (escalated from Q16 for the sqrt iterations) and then converted back.
- **Per-element update.** Each weight parameter is updated independently. The update reads from the temporary arena (gradients, optimizer state) and writes to the global arena (weight v, r0, r1 arrays).

### 5.9 Writing Back to Global Arena

After training, updated weights are written back to the KB's weight arrays in the global arena:

```
fn writeUpdatedWeights(kb: *KB, workspace: *TrainingWorkspace, global_arena: *Arena) void {
    const wrefs = getWeightRefs(kb, global_arena);
    const matrix = &wrefs.matrix_refs[0];
    const N: usize = @intCast(@as(i64, matrix.rows) * @as(i64, matrix.cols));

    // The weight update already modified current_v/r0/r1 in place
    // in the global arena during updateWeight calls.
    // Nothing to copy — the writes went directly to the WeightMatrix arrays.

    // Mark the GEMM cache as dirty
    if (wrefs.gemm_cache) |*cache| {
        cache.kb_last_modified = 0;  // force dirty on next isDirty check
    }
}
```

The weight update function writes directly to the global arena's WeightMatrix arrays. There is no copy-back step — the `current_v`, `current_r0`, `current_r1` pointers in `updateWeight` point into the global arena's weight data. The temporary arena holds only the training-specific data (gradients, optimizer state, transposed copy, activations).

### 5.10 Provenance Update After Training

After training modifies weights, provenance is updated on each weight's associated Fact:

```
fn updateProvenanceAfterTraining(kb: *KB, workspace: *TrainingWorkspace, system: *SystemState) void {
    const facts = getFactArray(kb, system.global_arena);
    const now = currentTimestamp();

    var i: i32 = 0;
    while (i < kb.facts_count) : (i += 1) {
        const fact = &facts[@intCast(i)];
        if (fact.tag == .matrix or fact.tag == .vector) {
            fact.provenance.source_type = @intFromEnum(SourceType.vdr_computation);
            fact.provenance.confidence = confidence_table[@intFromEnum(SourceType.vdr_computation)];
            // confidence = 1/1 (65536) — computed values have full confidence
            fact.provenance.timestamp = now;
            fact.provenance.derivation_rule_id = workspace.training_rule_id;
        }
    }
}
```

After this, every trained weight's provenance records:
- `source_type = vdr_computation` (confidence 1/1)
- `timestamp` = when training completed
- `derivation_rule_id` = the training procedure's rule ID

Any individual weight can be traced back to what training run produced it, when, and under what configuration.

### 5.11 GEMM Cache Invalidation After Training

Training modifies the weight `v` values in the global arena. The GEMM cache (which contains a packed copy of those `v` values) is now stale.

```
fn markGemmCacheDirty(kb: *KB, system: *SystemState) void {
    const wrefs = getWeightRefs(kb, system.global_arena);
    if (wrefs.gemm_cache) |*cache| {
        // Set kb_last_modified to 0, which is always < any real timestamp
        // isDirty() compares cache.kb_last_modified against kb.last_modified
        cache.kb_last_modified = 0;
    }

    // Also clear the new-facts-since-training list
    // (training incorporated all existing facts)
    clearNewFactsList(kb, system.global_arena);
    kb.new_facts_since_training_count = 0;
}
```

The next inference read from this KB will call `cache.isDirty(kb.last_modified)`, get true, and rebuild the cache. The rebuild reads the updated `v` values from the global arena and packs them into a fresh contiguous array. This is a cold-path operation — it happens once after training, not per-token.

---

## 6. Concurrent Training and Inference

### 6.1 Single-Core Independence

Training runs on a pinned compute thread, submitted via the work queue like any other operation. While one core trains a KB, other cores continue serving inference independently. They read the KB's pre-training weight data from the global arena (read-only access) until the training core writes back and invalidates the cache.

### 6.2 Training Lock Prevents Concurrent Training

`kb.training_lock` (bool) prevents two cores from training the same KB simultaneously. The lock is checked in `canTrain` and set at the start of `train`. There is no contention — if the lock is held, the second caller gets `already_locked` and tries again later or skips.

### 6.3 Weight Update Atomicity

The weight update writes to individual i32/i16 values in the global arena. These writes are not atomic at the Q16 level (v, r0, r1 are three separate writes). An inference read on another core during a weight update could read a partially updated Q16 (new v, old r0).

This is acceptable because:

- For inference GEMM, only the `v` field is read. A single i32 write is atomic on x86_64.
- The r0 and r1 fields are not read during inference GEMM.
- After training completes and the GEMM cache is rebuilt, the cache contains a consistent snapshot of all `v` values.
- Between training completion and cache rebuild, any inference that reads the stale cache gets pre-training values (consistent, just old).

No lock on the GEMM read path. No memory barrier beyond what x86_64 provides by default (strong memory ordering). The worst case is one inference request sees stale weights during the brief window between write-back and cache invalidation — this produces a slightly less optimal token, not corrupted output.

### 6.4 Multiple KBs Training Concurrently

Different KBs can train on different cores simultaneously. Each training operation has its own temporary arena, its own lock, its own workspace. The `system.active_training_count` tracks how many temporary arenas are currently allocated for the global headroom check.

```
Core 0: training root.science.physics     (100 MB temp arena)
Core 1: serving inference for session A    (no temp arena)
Core 2: training root.ops.incidents        (25 MB temp arena)
Core 3: serving inference for session B    (no temp arena)
```

Total temporary arena usage: 125 MB. The headroom check in `canTrain` ensures this doesn't exceed available system memory.

---

## 7. Integer Square Root for Adam Optimizer

The Adam optimizer requires `1 / sqrt(variance)`. Integer square root uses Newton-Raphson in Q32:

```
fn integerSqrt(val: Q16) Q16 {
    if (val.v <= 0) return Q16.zero();

    // Escalate to Q32 for precision during iterations
    var x = Q32.fromQ16(val);

    // Initial guess: rough integer sqrt
    var guess: i64 = 1;
    var temp: i64 = x.v;
    while (temp > 1) : (temp >>= 2) {
        guess <<= 1;
    }

    // Newton-Raphson: x_next = (x_curr + val / x_curr) / 2
    // 4 iterations is sufficient for Q32 precision
    var i: i32 = 0;
    while (i < 4) : (i += 1) {
        if (guess == 0) break;
        guess = @divTrunc(guess + @divTrunc(x.v, guess), 2);
    }

    // Convert back to Q16
    // The sqrt of a Q16 value needs scaling:
    // sqrt(v / D) = sqrt(v) / sqrt(D) = sqrt(v) / 256
    const result_v: i32 = @intCast(@divTrunc(guess, 256));
    const result_r0: i16 = @intCast(@mod(guess, 256));

    return Q16.fromParts(result_v, result_r0, 0);
}
```

Four Newton-Raphson iterations in i64 arithmetic provide sufficient precision for the Adam denominator. The escalation to Q32 and back is cheap — two multiplications and a division.
