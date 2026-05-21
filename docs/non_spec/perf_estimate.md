Let me check the project docs for the performance numbers and GEMM specs first.Now I have all the numbers. Let me build the analysis.

Noted — remainder, not residual. Remainder is first-class, always.

---

## GEMM Cached Lookup Performance Estimates

All estimates assume Path 2 (GEMM cache exists, no new facts, hot path). Single core, NUMA-aligned, AVX2. The baseline hardware numbers from the spec:

- AVX2: 8 × i32 MACs/cycle
- ~3 GHz clock (Coffee Lake / Zen 2 era laptop)
- Single core throughput: ~24 GMAC/s
- L1d: 32 KB per core, ~200 GB/s bandwidth
- L2: 256 KB per core, ~50-80 GB/s
- L3: shared, ~30-40 GB/s
- Main memory: ~20 GB/s

Per layer: 4 GEMMs totaling ~40M MACs. 16 layers = ~640M MACs per token. At 24 GMAC/s = ~27ms per token = ~37 tok/s. That's the compute-bound ceiling. But GEMM is often memory-bound, not compute-bound, because the weight data has to reach the core. The question is where the weights live in the memory hierarchy.

---

### What Determines Speed: Compute-Bound vs Memory-Bound

For a single-token GEMM (M=1), the operation is a matrix-vector multiply. It reads the entire weight matrix once and does one MAC per element. The arithmetic intensity is ~1 MAC per 4 bytes read. At 24 GMAC/s compute and 20 GB/s main memory bandwidth, the memory-bound throughput is 20 GB/s ÷ 4 bytes = 5 GMAC/s. So for weights streaming from main memory, GEMM is **memory-bound at ~5 GMAC/s**, not compute-bound at 24 GMAC/s.

This means the real question isn't "how fast can the ALU go" — it's "where do the weights live."

For weights in L1 (~200 GB/s): 200 ÷ 4 = 50 GMAC/s — compute-bound at 24. Full speed.
For weights in L2 (~60 GB/s): 60 ÷ 4 = 15 GMAC/s — still above compute. Full speed.
For weights in L3 (~35 GB/s): 35 ÷ 4 = ~9 GMAC/s — below compute. Memory-bound.
For weights in DRAM (~20 GB/s): 20 ÷ 4 = 5 GMAC/s — hard memory-bound.

With SoA-packed weight matrices, GEMM reads the `v` array directly — contiguous, cache-line aligned, perfect prefetcher pattern. No 12× stride waste. The only question is how much of the total weight `v` data fits in each cache level.

---

### Model Configurations and Weight Memory

The spec uses i32 for `v` fields (4 bytes per parameter for GEMM reads). Per parameter total storage is 8 bytes (v + r0 + r1), but GEMM only reads the 4-byte `v` array.

The spec also notes an i16 weight option (2 bytes per parameter, 1B params = 2 GB). In that case the `v` array would be i16 and GEMM reads 2 bytes per parameter, halving memory bandwidth pressure. The estimates below use the i32 `v` spec as the conservative case, with i16 noted where it changes the picture.

**Fixed overhead per token (shared across all configurations):**
- Embedding lookup: one row of vocab embedding table. 2048 × 4 = 8 KB. Trivial.
- lm_head projection: 2048 × 32000 = 65.5M params. v_data = 262 MB. Always streams from DRAM.
- Final norm vectors: 2048 × 4 = 8 KB. Trivial.

The lm_head is the single largest matrix and always streams from DRAM. At 20 GB/s, reading 262 MB takes ~13ms. This is a fixed cost per token regardless of model size. With i16 weights, this drops to 131 MB / ~6.5ms.

**Per-layer weight sizes (i32 v_data only):**

| Matrix | Shape | Params | v_data Size |
|--------|-------|--------|-------------|
| W_qkv | 2048 × 6144 | 12.6M | 50.3 MB |
| W_o | 2048 × 2048 | 4.2M | 16.8 MB |
| W_up | 2048 × 5632 | 11.5M | 46.1 MB |
| W_down | 5632 × 2048 | 11.5M | 46.1 MB |
| **Per layer total** | | **~39.8M** | **~159 MB** |

16 layers × 159 MB = **~2.55 GB** of v_data for the full infrastructure model (before domain KBs).

With i16 weights: 16 layers × ~80 MB = ~1.27 GB v_data.

---

### Scenario Analysis

The hierarchy layout determines how many KBs the forward pass touches and where their weight data sits in the memory hierarchy. All scenarios assume Path 2 (cached, hot path). The key variable is total v_data that must stream through the core per token.

#### Scenario A: Minimal — System Weights Only (No Domain KBs)

Just embedding + 16 transformer layers + lm_head. No domain-specific weights. Every session sees the same model.

**Total v_data per token:** ~2.55 GB (layers) + 262 MB (lm_head) + negligible (embedding, norms) ≈ **2.8 GB**

At 20 GB/s DRAM bandwidth: 2.8 GB / 20 = **~140ms per token → ~7 tok/s**

With i16 weights: ~1.4 GB / 20 = ~70ms → ~14 tok/s.

This is pure DRAM streaming. Nothing fits in L3 (typically 6-12 MB on laptop). Every layer's weight matrices are 159 MB — far beyond any cache level. The prefetcher handles the sequential pattern well, so bandwidth utilization should be near theoretical.

The spec's estimate of ~27ms / ~37 tok/s is compute-bound math. The actual memory-bound throughput for a full model is significantly lower. The 37 tok/s figure would apply only if the weights were somehow all in L2 or better — which they aren't for a full model.

#### Scenario B: Small Domain Set — 3 Domain KBs with Weights

System weights + 3 domain KBs (e.g., physics, chemistry, ops), each with one 1024×1024 reasoning matrix.

**Per domain KB:** 1M params × 4 bytes = 4 MB v_data.
**3 domain KBs:** 12 MB additional.

**Total v_data per token:** ~2.8 GB + 12 MB ≈ **2.81 GB**

Negligible impact. The domain KB weight matrices are small relative to the transformer layers. At 4 MB each, they fit in L3 on a warm pass. The first token pays the DRAM cost; subsequent tokens for the same session might see these in L3 if nothing evicts them.

**Speed: ~7 tok/s** (same as Scenario A, domain weights are rounding error)

The interesting thing here is the **weight resolution scan**. The forward pass must identify which KBs contribute weights. With 3 domain KBs + ~12 system seed KBs, that's ~15 KBs to check for weight_refs. Each KB is 256 bytes. Scanning 15 × 256 = 3.8 KB — fits in L1. The scan cost is sub-microsecond. Irrelevant.

#### Scenario C: Deep Hierarchy — 50 Domain KBs, Mixed Sizes

A production-like layout:

```
root.system.embedding          (1 large matrix: 32K × 2048)
root.system.output             (1 large matrix: 2048 × 32K)
root.science.physics           (1 × 1024×1024 = 4 MB)
root.science.physics.qed       (1 × 512×512 = 1 MB)
root.science.physics.thermo    (1 × 512×512 = 1 MB)
root.science.chemistry         (1 × 1024×1024 = 4 MB)
root.science.chemistry.organic (1 × 512×512 = 1 MB)
root.ops.incidents             (1 × 1024×1024 = 4 MB)
root.ops.incidents.triage      (1 × 256×256 = 256 KB)
... (40 more small domain KBs at 256×256 to 512×512)
```

Assuming the session has grants to all 50:

**Domain v_data:** ~3 × 4 MB + ~7 × 1 MB + ~40 × 256 KB ≈ 19 MB + 10 MB ≈ **29 MB**

**Total v_data per token:** ~2.8 GB + 29 MB ≈ **2.83 GB**

Still dominated by the 16 transformer layers and lm_head. **Speed: ~7 tok/s.**

The weight resolution scan is now 50 KBs × 256 bytes = 12.8 KB. Still fits in L1. Sub-microsecond.

But now there's a different cost: the forward pass must integrate domain weights into layer computation. The doc says "the forward pass collects weights from all KBs visible to the session." How these domain weights combine with the base transformer layers matters. If they're additional projection matrices applied after the base layer, that's 50 extra small GEMMs per token. At 256K params each, that's 50 × 256K = 12.8M extra MACs — about one-third of one transformer layer. At 5 GMAC/s (memory-bound from DRAM): 12.8M / 5G ≈ 2.6ms extra. But many of these small matrices (256 KB–4 MB) fit in L3 or even L2 on warm passes. At L3 bandwidth (35 GB/s → 9 GMAC/s): 12.8M / 9G ≈ 1.4ms. Negligible.

**Speed: still ~7 tok/s, maybe ~6.8 tok/s accounting for domain weight integration.**

#### Scenario D: Grant-Restricted — Session Sees Only 4 Domain KBs

Same 50-KB hierarchy, but the session has grants to only physics + physics.qed + ops.incidents + ops.incidents.triage.

**Domain v_data:** 4 MB + 1 MB + 4 MB + 256 KB ≈ **9.25 MB**

The excluded KBs don't exist in this session's forward pass. Their weights are never read, never cached, never streamed. The effective model is smaller.

**Speed: identical to Scenario A** (domain weights are negligible). But with a smaller effective model, quality may differ. The system delivers different capability per session based on grants, without any per-session weight copying.

#### Scenario E: Reduced Layer Model — 8 Layers Instead of 16

If the model uses 8 transformer layers instead of 16 (halving the base parameters):

**Per-layer v_data:** ~159 MB
**8 layers:** ~1.27 GB
**lm_head:** 262 MB
**Total:** ~1.53 GB

At 20 GB/s: 1.53 / 20 = **~76ms → ~13 tok/s**

With i16 weights: ~765 MB / 20 = ~38ms → **~26 tok/s**

#### Scenario F: i16 Weights Throughout + 8 Layers

The spec mentions i16 as an option: "i16 weights without r0/r1 until training modifies them (1B × 2 bytes = 2 GB)."

If weights are i16, the `v` array is half the size. GEMM reads 2 bytes per parameter instead of 4. The SIMD inner loop processes 16 × i16 per AVX2 load instead of 8 × i32, doubling the elements per cycle (though the widening to i32/i64 for accumulation means the throughput gain is less than 2×).

**8 layers, i16 weights:**
Per layer v_data: ~80 MB. 8 layers: ~640 MB. lm_head: ~131 MB.
Total: ~770 MB.

At 20 GB/s: 770 MB / 20 = **~38ms → ~26 tok/s**

This gets close to the spec's compute-bound estimate. The bandwidth cost is now competitive with the ALU speed.

---

### Summary Table

| Scenario | Layers | Weight Type | Domain KBs | Total v_data/token | Bandwidth-Limited Speed | 
|----------|--------|-------------|------------|-------------------|------------------------|
| A: System only | 16 | i32 | 0 | ~2.8 GB | ~7 tok/s |
| B: +3 domain | 16 | i32 | 3 | ~2.81 GB | ~7 tok/s |
| C: +50 domain | 16 | i32 | 50 | ~2.83 GB | ~7 tok/s |
| D: Grant-restricted | 16 | i32 | 4 | ~2.81 GB | ~7 tok/s |
| E: Half layers | 8 | i32 | 0 | ~1.53 GB | ~13 tok/s |
| F: Half + i16 | 8 | i16 | 0 | ~770 MB | ~26 tok/s |
| A with i16 | 16 | i16 | 0 | ~1.4 GB | ~14 tok/s |
| Spec estimate | 16 | i32 | — | (compute-bound) | ~37 tok/s |

---

### Where Domain KBs Actually Matter

The domain KB weight contribution is negligible for per-token GEMM speed because the base transformer layers dominate. Where domain KBs matter is:

**Weight resolution cost.** Scanning KBs for weight_refs. At 256 bytes per KB struct, even 1000 KBs = 256 KB scan. Fits in L2. Sub-millisecond. Not a bottleneck.

**GEMM cache rebuild cost.** When a domain KB's GEMM cache is dirty (after training or new fact assertion), the rebuild is O(facts_count). For non-matrix KBs with scattered facts, the cache rebuild copies v fields at 48-byte stride. For 1000 facts: ~48 KB read, ~4 KB write. Microseconds. For matrix KBs, the v_data is already contiguous — no cache needed.

**Tree walk cost.** Resolving dotted paths like `root.science.physics.qed` walks the KB tree. Each level is a children array scan. Typical KB has <20 children, each child reference is a VdrId (8 bytes). Walk depth 4 × scan 20 × 8 = 640 bytes. L1. Sub-microsecond. The alternative is direct UUID lookup — O(1) from the VdrId→arena LUT.

**The real performance lever is L3 ratio.** Domain KBs with good Prolog rules that handle 93% of queries at zero tokens make the per-token GEMM speed nearly irrelevant for system throughput. A system doing 7 L1 inference requests per second but handling 93 requests via L3 Prolog is effectively doing 100 requests/second. The forward pass cost is amortized across the L3 ratio.

---

### Non-Matrix KB GEMM Cache Behavior

For data KBs (not weight matrices) where scattered facts feed into computation — Prolog query results used in dot products, builtin operations over fact collections:

| KB Fact Count | Cache Size (v_packed) | Fits In | Rebuild Cost |
|--------------|----------------------|---------|-------------|
| 16 | 64 bytes | L1 (1 cache line) | <1 μs |
| 64 | 256 bytes | L1 | <1 μs |
| 1,000 | 4 KB | L1 | ~2 μs |
| 8,000 | 32 KB | L1 boundary | ~10 μs |
| 64,000 | 256 KB | L2 | ~50 μs |
| 4M (weight matrix) | 16 MB | DRAM | ~1 ms |

These caches are ephemeral — per-core arena scratch, rebuilt on demand, destroyed on scratch reset. For a session touching 20 small data KBs with ~100 facts each: 20 × 400 bytes = 8 KB total cache. All in L1. All rebuilt in microseconds. The computation over these cached values runs at L1 bandwidth (~200 GB/s), which is compute-bound at 24 GMAC/s.

---

### The Bandwidth Wall and What Crosses It

The honest picture: for a full 16-layer, i32-weight model on a 2019 laptop, single-core token generation is memory-bandwidth-limited at ~7 tok/s, not the ~37 tok/s compute-bound figure. The compute-bound number is what the ALU can sustain if weights were delivered instantly. They aren't — they stream from DRAM at 20 GB/s.

Three things cross the bandwidth wall toward the compute-bound limit:

1. **Smaller models.** Fewer layers, smaller dimensions. At 8 layers with i16 weights, you're at ~26 tok/s — within striking distance of compute-bound.

2. **i16 weights.** Half the bandwidth per parameter. The spec already identifies this as an option. Training promotes individual weights to i32 (with full r0/r1 remainder) as needed, but untrained weights stay i16.

3. **The L3 ratio.** The system's actual throughput metric isn't tok/s — it's requests/second. At 93% L3, the neural network fires on 7% of operations. 7 tok/s × (1/0.07) = 100 effective requests/second on a single core. Eight cores = 800 requests/second. The GEMM speed matters only for the 7% that actually need it.
