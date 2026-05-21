# Live Training with Temporary Arenas

## The Rule

No allocation after startup, with one exception: you can create a temporary arena for a bounded purpose, and when that purpose is done, the arena is destroyed and the pointer that referenced it is nulled. This is the only post-startup allocation pattern in the system.

## Training Mechanically

A KB's weight data lives in the global arena as normal. When you want to train that KB's weights:

1. **`canTrain(kb_id) → bool`** — Checks whether the system has enough headroom for a new temporary arena at the size this KB's training data requires. Also checks whether this KB is already locked for training. If either fails, return false.

2. **`train(kb_id) → ?TrainResult`** — If `canTrain()` is true, allocates a temporary arena sized to this specific KB's training needs. Locks the KB for training so no other session can train it simultaneously. The arena holds gradients, optimizer state, saved activations, transposed weight copies — whatever that training run needs. None of this lives in the KB struct permanently.

3. **Training runs.** The temporary arena is the workspace. The KB's weight facts in the global arena are read during forward pass. Final updated weights get written back to the KB when training completes.

4. **Cleanup.** The temporary arena is destroyed. The pointer to it is nulled. The lock on the KB is released. The system's available memory headroom goes back up.

If `canTrain()` returns false, `train()` returns null. No partial allocation, no cleanup needed, no silent degradation. Immediate test of `canTrain()` and exit if false.

Training should be put on a work queue ring buffer for a processor thread, not done on the kernel or non-processor threads. The pinned thread will NUMA-align the new temporary arena by reading through all its pages on first use.

## Temporary Arena Sizing

Small KB with a few thousand weights gets a small arena. Large KB with millions of weights gets a large arena. The sizing is per-KB, not a fixed global training buffer.

For a weight matrix of N parameters, the temporary arena needs:

| Component | Size | Purpose |
|-----------|------|---------|
| Gradient accumulator | N × 4 bytes (i32) | Same shape as weight v_data |
| Gradient r0 | N × 2 bytes (i16) | Remainder tracking on gradients |
| Gradient r1 | N × 2 bytes (i16) | Sub-r0 gradient precision |
| Optimizer momentum | N × 4 bytes (i32) | First moment (if Adam-like) |
| Optimizer variance | N × 4 bytes (i32) | Second moment (if Adam-like) |
| Saved activations | seq_len × d_model × 4 bytes | Per-layer forward pass intermediates |
| Transposed weight copy | N × 4 bytes (i32) | Built once for backward GEMM |
| Scratch | ~10% of above | Intermediate computation |

For a 2048×2048 weight matrix (4M params): ~100 MB temporary arena. For a 128-element layer norm vector: ~10 KB temporary arena. The arena scales with the data.

Multiple KBs can train concurrently as long as total temporary arena allocation stays under the system's max. If it doesn't fit, `canTrain()` says no and nothing breaks.

## What the KB Struct Looks Like

The KB struct stays 256 bytes. No gradient fields. No optimizer fields. No null pointers sitting there permanently. The training state exists only during training, in memory that doesn't exist outside of training.

```
Kb struct (always):
    weight_refs_offset: i32     // points to KbWeightRefs in global arena
    training_lock: i8           // 0=unlocked, 1=locked
    training_arena: ?*Arena     // null when not training, set during training
```

`training_arena` is null 99% of the time. When training starts, it points to the temporary arena. When training finishes, it's nulled. This is the only nullable pointer in the system and the only post-startup allocation.

## GEMM During Training

The GEMM kernel doesn't change. Forward pass during training is the same GEMM as inference — reads weight v_data from the KB's SoA-packed region. Backward pass is GEMM with transposed operands from the temporary arena. Weight update is element-wise, not GEMM.

The difference is where operands come from and where results go:

| Operation | Input Source | Output Destination |
|-----------|-------------|-------------------|
| Forward GEMM | KB weight v_data (global arena) | Activations (temporary arena) |
| Backward GEMM | Transposed weights (temporary arena) + activation gradients (temporary arena) | Weight gradients (temporary arena) |
| Weight update | Gradients (temporary arena) + current weights (global arena) | Updated weights (global arena) |

After the final weight update writes back to the KB's global arena v_data, the per-KB GEMM cache (if one exists in scratch) is marked dirty. Next inference read rebuilds it.

## Integration with Existing Design

- **Arena rule preserved.** Startup allocates all permanent arenas. Temporary training arenas are the single exception, bounded by `canTrain()` headroom check and destroyed after use.
- **Facts have GEMM data.** Weight facts in SoA-packed format with per-fact provenance. Training updates individual weight values and their provenance (source becomes `vdr_computation`, confidence 1/1, timestamp updated).
- **Per-KB GEMM cache.** The scratch cache for non-matrix facts rebuilds on demand when dirty. Training dirtying a weight KB invalidates any cached version.
- **Processor thread handles training.** Training requests go on the work queue ring buffer. A pinned processor thread picks them up, allocates the temporary arena, touches pages for NUMA alignment, runs training, writes results back, destroys arena. The kernel thread and HTTP threads never do training work.

## Per-Fact Provenance in Training

Every weight in the SoA-packed array has a corresponding entry in the KB's provenance tracking. After training updates a weight:

- `source_type` → `vdr_computation` (confidence 1/1)
- `timestamp` → training completion time
- `derivation_rule_id` → ID of the training rule/procedure that produced this update

This means you can trace any individual weight back to what training run produced it, when, and under what configuration. The provenance of what each fact contributes to the set is preserved — not just the aggregate model, but per-weight lineage.

---

## Security: Restricting Weight Access by Group

The grant system already controls which KBs a session can read. But within a single KB, you might want different groups to see different effective weights — different GEMM data for different access levels. Several approaches:

### Option 1: Per-Group GEMM Copies

Each KB stores multiple GEMM weight sets, indexed by group:

```
root.science.physics.qed
    weight_sets[0] = WeightMatrix { group_X weights — full capability }
    weight_sets[1] = WeightMatrix { group_Y weights — reduced capability }
    weight_sets[2] = WeightMatrix { default weights — baseline }
```

At inference time, the session's group membership determines which index to read. If the session belongs to group X, read index 0. Group Y, read index 1. No matching group, read the default.

**Pros:** Simple lookup. O(1) per KB. Each group gets pre-computed optimal weights. No runtime transformation.

**Cons:** Memory multiplied by group count. 3 groups × 4M params × 8 bytes = 96 MB per KB instead of 32 MB. Doesn't scale to many groups.

### Option 2: Weight Masking

Store one canonical weight set. Per group, store a binary mask and a replacement value set (sparse):

```
root.science.physics.qed
    weights[0] = WeightMatrix { canonical weights }
    masks[group_X] = SparseMask { positions to zero or replace }
    masks[group_Y] = SparseMask { different positions }
```

At inference, apply the mask before GEMM: for each masked position, replace the canonical weight with the mask's replacement value (typically zero).

**Pros:** Memory efficient if masks are sparse. Groups that see most of the weights only store the delta.

**Cons:** Runtime cost to apply mask before GEMM. Mask application breaks SIMD contiguity unless the mask is applied into a scratch copy.

### Option 3: Projection Matrices

Store one canonical weight set. Per group, store a small projection matrix that transforms the output:

```
weights = canonical W     [d_model × d_model]
project = group P         [d_model × d_reduced]
effective = W × P         (computed at session init, cached)
```

The projection reduces dimensionality — group Y gets a lower-rank approximation of the full weights.

**Pros:** Compact representation. A rank-128 projection of a 2048×2048 matrix is 2048×128 = 1 MB instead of 16 MB per group.

**Cons:** Information loss is controlled but not per-weight — it's a subspace projection. Computing the effective matrix at session init takes one GEMM. Cache the result in the session's per-core arena.

### Option 4: Row/Column Partitioning

Different groups see different rows or columns of the weight matrix:

```
weights = full W [2048 × 2048]
group_X sees rows 0-2047, cols 0-2047     (full)
group_Y sees rows 0-2047, cols 0-1023     (half the output dimensions)
group_Z sees rows 0-1023, cols 0-1023     (quarter capability)
```

No separate storage — just index bounds per group. The GEMM uses a subset of the existing contiguous array.

**Pros:** Zero additional memory. The restriction is just two integers (row_end, col_end) per group per KB. SIMD reads a contiguous sub-range — no masking, no copying.

**Cons:** Coarse granularity. You can't selectively remove individual weights — only contiguous blocks. Reduced dimensions change the model's interface (output size differs between groups), which propagates through the layer stack.

### Option 5: Encrypted Weight Regions

Weight data at rest is encrypted per group key. Only sessions with the correct group key can decrypt their region into the temporary inference scratch. Scratch is in the per-core arena and cleared after the forward pass.

```
weights_encrypted[group_X] = AES(canonical_weights, key_X)
weights_encrypted[group_Y] = AES(reduced_weights, key_Y)
```

At inference, decrypt into scratch, GEMM from scratch, zero scratch after.

**Pros:** Weight data is protected even against memory inspection. Different groups can have completely different weight values, not just subsets.

**Cons:** Decryption cost per forward pass. AES on 16 MB of weights adds ~1-2 ms per layer on AVX2 (AES-NI). Doubles memory (encrypted + scratch). Key management complexity. Integer AES-NI exists on x86_64 but adds implementation burden.

### Option 6: Capability Tokens in Provenance

No separate weight storage. Instead, each weight fact's provenance carries a capability tag:

```
weight_fact.provenance.capability_level = 3   // requires level 3 access
```

At GEMM time, weights whose capability level exceeds the session's level are read as zero. The access check is per-element during the GEMM cache rebuild, not during the GEMM itself. The GEMM cache contains only the weights the session is authorized to see — unauthorized positions are zero in the cache.

**Pros:** One weight set in storage. Per-weight granularity. No memory multiplication. Cache rebuild absorbs the access check cost.

**Cons:** Cache must be per-session-group, not per-KB. Different groups produce different caches from the same KB. Cache rebuild cost proportional to weight count. Zero-replaced weights still consume GEMM compute (multiplying by zero).

### Recommendation

For this system, **Option 1 (per-group GEMM copies)** for small group counts (2-4 groups) and **Option 6 (capability tokens in provenance)** for fine-grained per-weight control. They compose:

- 2-3 major capability tiers get pre-computed GEMM copies (fast, no runtime overhead)
- Within a tier, individual weights can be capability-tagged for fine-grained restriction (handled during cache rebuild, not during GEMM)
- The grant system controls which tier a session belongs to
- `canTrain()` can restrict training to specific tiers

This matches the existing design: grants control KB access (coarse), provenance tracks per-fact metadata (fine), GEMM caches are rebuilt on demand (absorbs the filtering cost into a cold path, not the hot GEMM loop).
