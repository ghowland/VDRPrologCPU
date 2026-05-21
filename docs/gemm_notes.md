# GEMM Stride Penalty and Cache Strategy

## The Problem

Facts are 48 bytes. GEMM needs the 4-byte v field. Reading weight matrices as Facts means 12× memory bandwidth waste. For a 2048×6144 QKV projection:

- Packed: 12.6M × 4 bytes = ~50 MB read
- Strided Facts: 12.6M × 48 bytes = ~600 MB read
- At ~20 GB/s laptop bandwidth: 2.5ms packed vs 30ms strided per layer
- 16 layers: 40ms packed vs 480ms strided per token
- That's 25 tok/s vs 2 tok/s. The stride kills performance.

## The Principle

The weight data lives in Facts because weights are living data. They have provenance, confidence, can be rescored, retrained, updated in place through the normal command interface. There is no separate training phase. The system bootstraps itself and improves itself. Weights are facts like any other facts.

But GEMM doesn't need provenance during the multiply. It needs contiguous i32 values at full memory bandwidth.

So we store both: the authoritative data in Facts (wide stride, full metadata, living) and an optimized cache (packed contiguous, GEMM-ready, rebuilt on demand).

We waste memory. We get a live system and a fast system.

## Solution: Per-KB GEMM Cache

Each weight KB can have an associated GEMM cache — a packed contiguous `[]i32` array of just the v fields, laid out for SIMD access.

```
Weight KB (authoritative):
    facts[0] = Fact { tag, value: Q16{v, r0, r1}, provenance }   // 48 bytes
    facts[1] = Fact { ... }
    ...
    facts[N] = Fact { ... }

GEMM Cache (derived, expendable):
    v_packed[0..N]: []i32    // 4 bytes each, contiguous, SIMD-ready
    dirty: bool              // true if Facts changed since last rebuild
    generation: i32          // increments on rebuild
    kb_generation: i32       // matches KB.last_modified at rebuild time
```

## Rebuild Policy

The cache is not forced to stay in sync. It can lag. Rebuild happens when:

1. **Explicit request** — admin command triggers rebuild of a specific weight KB's cache
2. **Before inference** — if the cache is dirty and the session is about to use those weights, rebuild first
3. **Background** — a hygiene runner periodically scans weight KBs for stale caches and rebuilds them
4. **Never during training** — while weights are being updated, the cache stays stale. Rebuild after the training batch completes.

The dirty flag is set whenever any fact in the weight KB is written. Checking dirty is O(1). Rebuilding is O(N) — one pass through N facts copying v fields to the packed array.

## Memory Cost

Per weight KB, the cache adds 4 bytes per weight (the packed v). For a 1B parameter model:

- Facts: 1B × 48 bytes = 48 GB — too large for laptop
- Wait. At 1B params stored as individual Facts, 48 bytes each, that's 48 GB. That doesn't fit.

This reveals a design constraint: individual Facts per weight parameter is too expensive at 48 bytes each. Weight KBs need a bulk storage format.

## Revised: Weight Facts as Matrix References

A weight KB doesn't store one Fact per parameter. It stores a small number of Facts that reference packed arrays:

```
root.model.layers.layer_00.attention.qkv_weights (KB)
    facts[0] = Fact {
        tag: TAG_MATRIX,
        value: Q16 { v: matrix_offset, r0: rows, r1: cols },
        provenance: { source: vdr_computation, confidence: 1/1, ... }
    }
```

The single Fact points to a contiguous packed region in the arena:

```
Arena region at matrix_offset:
    v_data:  [rows * cols]i32    // the weight values, GEMM-ready
    r0_data: [rows * cols]i16   // remainder level 0
    r1_data: [rows * cols]i16   // remainder level 1
```

Structure of Arrays within the packed region. The Fact is the metadata wrapper. The actual weight data is SoA-packed and contiguous.

## Memory with SoA Packing

Per parameter: 4 (v) + 2 (r0) + 2 (r1) = 8 bytes. For 1B parameters:

- Weight data: 1B × 8 bytes = 8 GB
- Fact metadata: ~50 Facts (one per weight matrix) × 48 bytes = ~2.4 KB
- Total: ~8 GB

With GEMM cache (packed v only): 1B × 4 bytes = 4 GB additional.

Total: ~12 GB. Tight on a 16 GB laptop. Options:

- Smaller model (500M params = 4 GB weights + 2 GB cache = 6 GB)
- i16 weights without r0/r1 until training modifies them (1B × 2 bytes = 2 GB + 2 GB cache = 4 GB)
- Load only accessed layers (grant-gated, partial model)

## Revised Cache Strategy with SoA

Since weight data is already SoA-packed (v_data contiguous), the GEMM cache may be unnecessary. The v_data region IS the packed format. GEMM reads v_data directly. No copy needed.

The cache becomes relevant only when:

1. **Training updates weights** — training writes to individual positions in v_data. Between training updates, v_data is contiguous and GEMM-ready. No cache needed.
2. **Rescoring changes confidence** — provenance lives in the Fact, not in v_data. Rescoring doesn't touch v_data. No cache needed.
3. **Sparse updates fragment the array** — if training deletes and re-inserts weights (unlikely for matrix data), the array could fragment. But matrix weights are always dense — every position has a value. No fragmentation.

So with SoA-packed weight matrices referenced by Facts, GEMM reads the v_data region directly at full bandwidth. The Fact provides metadata (provenance, confidence, dimensions). The packed data provides SIMD performance. No separate cache needed.

## Where the Cache IS Needed

Non-matrix KB data used in computation. If a Prolog query produces a set of facts that need to be used in a GEMM-like operation (e.g., a builtin computing dot products over a collection of KB values), those facts are individual Fact structs at 48-byte stride. For these cases, a per-operation scratch cache makes sense:

1. Query returns N facts from various KBs
2. Copy v fields to contiguous scratch array in per-core arena
3. SIMD operates on scratch array
4. Result written back to KB as new fact(s)

This scratch cache is ephemeral — lives in the per-core arena scratch region, rebuilt per operation, freed implicitly on arena reset.

## Summary

| Data Type | Storage | GEMM Access | Cache Needed? |
|-----------|---------|-------------|---------------|
| Weight matrices | SoA-packed region, referenced by TAG_MATRIX Fact | Direct read of v_data, contiguous | No |
| Weight metadata | Fact struct (provenance, confidence) | Not read during GEMM | No |
| Weight remainders | r0_data, r1_data in SoA region | Read during precision check or training | No |
| Scattered KB facts used in computation | Individual Fact structs, 48-byte stride | Copy v fields to scratch, then SIMD | Yes, ephemeral per-operation |

## Enumerated Alternatives Considered

1. **AoS Facts with stride penalty** — 12× bandwidth waste. Rejected for weight matrices. Acceptable for small fact sets.
2. **SoA-packed weight regions referenced by Facts** — best of both. Living data with metadata. Contiguous GEMM access. Chosen.
3. **Per-KB GEMM cache rebuilt on demand** — useful concept but unnecessary for SoA-packed weights. Retained for scattered-fact computation only.
4. **Separate packed model blob outside KB system** — fast but loses living-data properties. Rejected.
5. **Interleaved v/r0/r1 packing (AoSoA)** — 8 v's then 8 r0's then 8 r1's. Matches AVX2 lane width. More complex addressing. Consider if SoA proves insufficient.
6. **Lazy cache with dirty flag and generation counter** — deferred rebuild, can lag behind writes. Good for training scenarios where writes are bursty. Retained as option for non-weight KB computation.
7. **Copy-on-read to per-core scratch** — ephemeral, per-operation. Right answer for scattered facts from Prolog queries feeding into SIMD builtins.

---

## Addendum: Per-KB Sized GEMM Caches

The SoA-packed weight regions are already GEMM-ready for matrix weights. But for non-matrix KBs where scattered facts feed into computation, the GEMM cache should be exactly the size of the data it caches. No fixed-size buffers. No worst-case allocation.

### Sizing

A KB with 50 facts gets a 50 × sizeof(i32) = 200 byte cache. A KB with 10,000 facts gets a 40 KB cache. The cache is allocated from the per-core arena at exactly `kb.facts_count * 4` bytes. Bump pointer, no waste.

```
GEMM Cache per KB:
    v_packed: [kb.facts_count]i32    // exactly sized
    fact_count: i32                   // how many entries
    kb_id: VdrId                     // which KB this caches
    kb_last_modified: i32            // timestamp at rebuild
```

### Allocation

The cache lives in the per-core arena scratch region. It is allocated when first needed and rebuilt when the KB's `last_modified` timestamp exceeds `kb_last_modified` on the cache. The allocation is a bump pointer advance — one integer add.

Small KB (10 facts): 40 bytes + 16 bytes header = 56 bytes.
Medium KB (1,000 facts): 4 KB + 16 bytes header.
Large KB (100,000 facts): 400 KB + 16 bytes header.

Each cache is exactly the size it needs to be. A session that touches 20 small KBs and 2 large KBs allocates exactly what those KBs require.

### Lifecycle

The cache is not persistent. It lives in per-core arena scratch. When the scratch region resets (between inference cycles, after a session completes, or when the arena needs reclaiming), all caches are gone. Next access rebuilds only the caches actually needed.

This means cold start pays the rebuild cost. Warm operation reuses caches across turns within a session. The cache survives across turns but not across sessions or arena resets.

### Rebuild Cost

Rebuilding is one pass through the KB's fact array, copying v fields:

```
for (0..kb.facts_count) |i| {
    cache.v_packed[i] = facts[kb.facts_offset + i].value.v;
}
```

For 1,000 facts: 1,000 iterations, ~48 KB read (strided), ~4 KB write (contiguous). Microseconds. The rebuild is cheap enough that lagging is optional, not required. But lagging is still allowed — the dirty check is a single timestamp comparison.

### Multiple Caches Per Session

A session might use several KBs in one computation. Each gets its own right-sized cache. The caches are independent — rebuilding one doesn't affect others. A session doing a Prolog query across 5 KBs builds 5 caches, each sized to its KB. Total scratch used is the sum of what's actually needed.

### No Fragmentation

Because arenas are bump-pointer only, there's no fragmentation. Caches allocated sequentially in the scratch region pack tightly. When scratch resets, all space is reclaimed at once. No free-list, no compaction, no holes.

### Interaction with SoA Weight Matrices

Weight matrices already have contiguous v_data regions. They don't need this cache. The per-KB cache is specifically for non-matrix KBs — fact collections, rule results, query outputs, builtin inputs. The two mechanisms coexist:

- Weight KBs: SoA-packed at creation, GEMM reads v_data directly, never needs cache
- Data KBs: individual Facts at 48-byte stride, cache built on demand at exact size, ephemeral in scratch

---

## Addendum: Cache Line Alignment

Intel Coffee Lake and AMD Zen 2 (2019 laptop era) use 64-byte cache lines. L1 data cache is 32 KB per core, 8-way associative. L2 is 256 KB per core. L3 shared.

### Alignment Rules

Every GEMM cache allocation must be 64-byte aligned. The arena bump pointer advances to the next 64-byte boundary before allocating:

```
aligned_cursor = (cursor + 63) & ~63
```

This wastes at most 63 bytes per cache allocation. For a 200-byte cache (50 facts), that's up to 31% overhead. For a 4 KB cache (1,000 facts), it's 1.5%. For anything over 1 KB the waste is negligible.

### Size Rounding

Cache size rounded up to the next multiple of 64 bytes. A 50-fact cache needs 200 bytes of i32 data — rounded to 256 bytes (4 cache lines). The extra 56 bytes are padding, never read. This guarantees that the start of the next allocation is also cache-line aligned without an additional alignment step.

```
cache_bytes = ((kb.facts_count * 4) + 63) & ~63
```

### Why This Matters for GEMM

SIMD dot products read sequentially through the v_packed array. Each AVX2 load pulls 32 bytes (8 × i32). Two loads fill one cache line. If the array starts mid-cache-line, the first and last loads straddle two cache lines each, causing two cache misses instead of one. Over a 4 KB array that's ~60 cache lines — two extra misses is noise. Over a 40 KB array, misalignment causes the hardware prefetcher to mispredict stride, potentially stalling the pipeline.

Cache-line alignment guarantees the hardware prefetcher sees a clean sequential pattern from the first load. No warmup penalty, no stride misprediction.

### L1/L2 Residency

At 32 KB L1d per core, a single KB cache of up to ~8,000 facts (32 KB of packed v) fits entirely in L1. The GEMM inner loop runs at L1 bandwidth — roughly 200 GB/s on Coffee Lake, 10× main memory bandwidth.

For the weight matrix SoA regions, a single 2048×2048 matrix v_data is 16 MB — far larger than L2. These stream from L3 or main memory. Cache-line alignment still matters here because it keeps the prefetcher efficient, but the data won't be L1-resident.

The per-KB GEMM caches for data KBs (typically hundreds to low thousands of facts) will be L1 or L2 resident. This is where alignment pays the biggest dividend — the entire cache fits in fast memory and the SIMD reads never stall.

### Summary

| Cache Size | Facts | Cache Lines | Fits In | Alignment Waste |
|-----------|-------|-------------|---------|----------------|
| 64 bytes | 1-16 | 1 | L1 | up to 63 bytes |
| 256 bytes | 17-64 | 4 | L1 | up to 63 bytes |
| 4 KB | ~1,000 | 64 | L1 | negligible |
| 32 KB | ~8,000 | 512 | L1 boundary | negligible |
| 256 KB | ~64,000 | 4,096 | L2 | negligible |
| 16 MB | ~4M (weight matrix) | 262,144 | L3/main memory | negligible |

---

Zig's `@alignCast` and `align` keyword handle this. The arena allocator already has an alignment parameter:

```zig
// In Arena.alloc, alignment is already a parameter:
pub fn alloc(self: *Arena, bytes: usize, alignment: usize) ?[*]u8 {
    const mask = alignment - 1;
    const aligned = (self.cursor + mask) & ~mask;
    if (aligned + bytes > self.size) return null;
    const ptr = self.base + aligned;
    self.cursor = aligned + bytes;
    return ptr;
}

// Allocate a cache-line aligned GEMM cache:
const CACHE_LINE = 64;

fn allocGemmCache(arena: *Arena, fact_count: usize) ?[]i32 {
    const raw_bytes = fact_count * @sizeOf(i32);
    const aligned_bytes = (raw_bytes + CACHE_LINE - 1) & ~(CACHE_LINE - 1);
    const ptr = arena.alloc(aligned_bytes, CACHE_LINE) orelse return null;
    return @as([*]i32, @ptrCast(@alignCast(ptr)))[0..fact_count];
}
```

The `arena.alloc(aligned_bytes, CACHE_LINE)` does both things: aligns the start to 64 bytes and rounds the size up to 64 bytes. The returned `[]i32` slice starts on a cache line boundary and occupies whole cache lines.

For the SoA weight matrix regions, same call at init time:

```zig
fn allocWeightMatrix(arena: *Arena, rows: i32, cols: i32) ?WeightMatrix {
    const n: usize = @intCast(rows * cols);
    const v_data = allocGemmCache(arena, n) orelse return null;
    const r0_ptr = arena.alloc(n * 2, CACHE_LINE) orelse return null;
    const r1_ptr = arena.alloc(n * 2, CACHE_LINE) orelse return null;
    return .{
        .v = v_data,
        .r0 = @as([*]i16, @ptrCast(@alignCast(r0_ptr)))[0..n],
        .r1 = @as([*]i16, @ptrCast(@alignCast(r1_ptr)))[0..n],
        .rows = rows,
        .cols = cols,
    };
}
```

Each SoA array (v, r0, r1) starts on its own cache line. No straddling between arrays.

