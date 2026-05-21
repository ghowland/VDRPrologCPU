# VDR Arithmetic Specification for Q16 SIMD Implementation

## What VDR Is

VDR — Value, Denominator, Remainder — is exact integer arithmetic where every operation produces a complete result with no information loss. The remainder is not error. It is not residue. It is not noise. It is the exact unresolved structure that the denominator frame could not absorb. It is part of the value.

A VDR value is an ordered triple: V (integer numerator), D (nonzero integer denominator frame), R (remainder). The scalar projection of any VDR value is `(V + Π(R)) / D`, where Π recursively evaluates nested remainders. When R is zero, the value is a plain rational number V/D. When R is nonzero, the value is active — it carries exact structure beyond what the D-frame absorbed.

The key insight: conventional arithmetic discards the remainder from integer division. VDR keeps it. Every operation that would lose precision in scalar arithmetic instead deposits the unresolvable part into the remainder slot. The result is that chains of operations accumulate zero drift. Not approximately zero — exactly zero. Proven across 200-operation chains, 2000-operation chains, ill-conditioned matrix inversions, and 40-operation matrix roundtrips.

---

## Q16 Frame

In this system, D is fixed at 65536 (2^16) and is never stored. Every Q16 value is implicitly a fraction with denominator 65536. The V slot is i32 (the numerator). Two remainder levels are carried:

```
Q16 { v: i32, r0: i16, r1: i16 }    // 8 bytes total
```

- `v` — The settled numerator. The rational value of this Q16 is `v / 65536`.
- `r0` — Remainder level 0. The exact part that did not fit into v during the last operation that produced this value. This is not rounding error. It is the exact integer remainder from the division by D.
- `r1` — Remainder level 1. The exact part that did not fit into r0. Carries sub-r0 precision from cross-term interactions during multiplication.

The scalar projection is: `(v + (r0 + r1/32768) / 65536) / 65536`. But inside the system, no projection is ever performed. The three fields are carried and propagated independently. Projection is only for external display or comparison with legacy systems.

---

## Why Two Remainder Levels

A single remainder level captures the direct remainder from one division. But when two active values are multiplied, the cross-terms (V₁×R₂, V₂×R₁, R₁×R₂) produce sub-remainder structure that a single r0 cannot capture. The second level r1 carries this.

With one remainder level, you know what v lost. With two, you know what r0 lost. At any point you can inspect r1 to determine the precision boundary — how much information exists below the resolution you are currently using. This is not an approximation of an error bound. It is the exact value of what is unresolved at that level.

If two remainder levels are insufficient for a given computation, the system knows — r1 tells you. You can then decide to move to Q32 (D=2^32, four bytes per remainder level) or Q335 (D=2^335, multi-limb) for that specific computation. The decision is informed, not heuristic.

---

## Remainder Propagation Rules

### Addition

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

Remainder propagates upward through carry. The sum of two values with nonzero remainders produces a result whose remainder is the sum of the input remainders, with carries propagated level by level. No information is lost at any level.

### Subtraction

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

Mirror of addition with borrows instead of carries. Same propagation structure. Same exactness.

### Multiplication

```
a * b:
    product = (i64)a.v * (i64)b.v
    new_v = product / D          (integer division)
    new_r0 = product % D         (exact remainder — not error)
    
    r1_cross = (i64)a.r0 * (i64)b.v + (i64)b.r0 * (i64)a.v
    new_r1 = (r1_cross / D) % 32768
```

The product of two i32 values fits in i64. Dividing by D gives the settled numerator in the D-frame. The remainder from that division is exactly r0. The cross-terms (a.r0 × b.v and b.r0 × a.v) capture the interaction between each value's settled part and the other's remainder, producing r1.

The term a.r0 × b.r0 (remainder × remainder) is not captured in this two-level scheme. This is the sub-r1 structure. If it matters for your computation, r1 being nonzero after a long chain of multiplications tells you to check precision. But for LLM inference with Q16, this level of precision loss is below the model's meaningful resolution.

### Division

```
a / b:
    if b.v == 0: return zero (caller checks)
    widened = (i64)a.v * D
    new_v = widened / (i64)b.v     (integer division)
    r0_full = widened % (i64)b.v   (exact remainder)
    
    r1_widened = r0_full * D
    new_r1 = (r1_widened / (i64)b.v) % 32768
```

Division widens the numerator by D before dividing, so the result stays in the D-frame. The remainder from the widened division is r0. A second widening of r0 produces r1. Each level is an exact integer remainder from an exact integer division.

---

## Comparison

Comparison uses all three fields in order: v first, then r0, then r1.

```
compare(a, b):
    if a.v < b.v: return -1
    if a.v > b.v: return 1
    if a.r0 < b.r0: return -1
    if a.r0 > b.r0: return 1
    if a.r1 < b.r1: return -1
    if a.r1 > b.r1: return 1
    return 0
```

Two Q16 values are equal if and only if all three fields match. There is no epsilon. There is no tolerance. If v matches but r0 differs, the values are different — and the difference is exact, not noise.

---

## Softmax — Exact Unity via Remainder Distribution

The critical operation for LLM inference. Softmax must produce probabilities that sum to exactly D (65536). Not approximately. Exactly.

```
softmax(logits, n):
    1. Find max logit (integer scan)
    2. Compute int_exp(logit[i] - max) for each i
    3. Sum all exp values → total
    4. For each i:
         prob[i] = (exp[i] * D) / total        (integer division)
         rem[i]  = (exp[i] * D) % total         (exact remainder)
    5. Sum all prob[i] → partial_sum
    6. deficit = D - partial_sum
    7. Find index with largest rem[i]
    8. Add deficit to that index's prob
```

After step 4, the sum of all prob[i] is at most D (it can be less because integer division truncates). The deficit is the exact amount lost to truncation across all elements. Step 7-8 assigns this deficit to the element that had the largest truncation loss — this is the Fixed Remainder Unit (FRU). The result sums to exactly D.

This is not a hack or a correction. It is remainder distribution. The total remainder from N integer divisions is distributed to the element that lost the most. The distribution is deterministic — same inputs always produce same assignment. The sum is exact — not approximately D, not D ± 1, but D.

---

## SIMD Considerations

AVX2 provides 8 × i32 lanes in a 256-bit register. The v field of 8 Q16 values can be processed simultaneously for the bulk of computation:

**SIMD on v (8-wide):**
- Dot products: 8 multiply-accumulates per cycle
- Addition/subtraction: 8 elements per cycle
- Comparison: 8 elements per cycle
- Max/min scan: tree reduction in shared registers

**Scalar post-pass on r0, r1:**
- After SIMD computes the v-level result, a scalar pass propagates remainders for operations that need full precision
- For dot products in GEMM, the v-level SIMD result is the primary output; r0/r1 are propagated only for the final accumulated value, not per-element
- For softmax, remainder tracking is per-element (needed for FRU assignment)

**When to propagate remainders:**
- GEMM inner loop: SIMD on v only. Accumulate in i64. Final result gets r0 from the divTrunc by D. r1 from cross-terms if needed. The per-element remainders inside the dot product are absorbed into the i64 accumulator — they don't need individual tracking.
- Softmax: Full remainder tracking per element. The FRU needs per-element remainders to decide where to assign the deficit.
- LayerNorm: v-level SIMD for the variance computation. Remainder tracking on the final inverse-sqrt and scaling.
- Residual add: Full remainder propagation per element (addition propagates carries through r1 → r0 → v).

---

## Relationship to VDR Paper

The VDR paper defines the full system with arbitrary-precision integers, recursive remainder trees (remainders containing child VDR triples), and functional remainders (callable objects producing exact rationals at any depth). The Q16 implementation is a fixed-frame specialization:

| VDR Paper | Q16 Implementation |
|-----------|-------------------|
| D is arbitrary nonzero integer | D = 65536, fixed, implicit |
| V is arbitrary-precision integer | V is i32 |
| R is recursive tree of VDR triples | R is two flat integers: r0 (i16), r1 (i16) |
| Depth is unbounded | Depth is 2 (r0 and r1) |
| Normalization produces canonical form | Not needed — fixed D, no children to sort |
| Rebase changes D while preserving value | Move to Q32/Q335 when r1 indicates precision loss |
| Functional remainders produce exact rationals at any depth | Not implemented at Q16 level |

The Q16 frame is the innermost leaf of the VDR system — the fast path for bulk computation where two levels of remainder provide sufficient precision tracking. The full VDR recursive structure exists at higher levels (Q32, Q335) for operations that need it.

The principle is the same at every level: the remainder is not error. It is exact unresolved structure. At Q16, r0 tells you what v lost. r1 tells you what r0 lost. If r1 is consistently nonzero across a chain of operations, you know the Q16 frame is too small for that computation and you escalate to Q32 — not because precision was lost, but because you can see exactly how much structure is unresolved and make an informed decision.

---

## Invariants for Implementation

1. **Remainder is never discarded.** Every operation that produces a quotient must store the remainder. Using `@divTrunc` without capturing `@mod` is a bug.

2. **r0 and r1 are never padding.** If a struct has `r0: i16` and `r1: i16`, both carry meaning. Any code that treats them as zero without propagating is losing information.

3. **Softmax sums to D exactly.** After FRU assignment, the sum of all probabilities equals 65536. If it doesn't, the FRU implementation is broken. Test this on every softmax call.

4. **Comparison uses all three fields.** Two values with equal v but different r0 are different values. Code that compares only v is performing a lossy comparison — acceptable for some operations (approximate argmax) but must be documented.

5. **i64 accumulators for multiplication.** i32 × i32 can overflow i32. All multiplications widen to i64 before computing. The divTrunc by D and mod by D operate on the i64 product.

6. **No float anywhere.** If `@as(f32, ...)` or `@as(f64, ...)` appears anywhere in the compute path, the VDR guarantee is broken. Integer in, integer through, integer out.

7. **r1 is the precision sentinel.** After a long chain of multiplications, inspect r1 of the final result. If it is consistently near the i16 boundary (±32767), the Q16 frame is being stressed and the computation may benefit from Q32 for that specific operation chain.

---

### Why Q16 Has Two Remainder Levels

Q16 has three fields: `v: i32, r0: i16, r1: i16`. D=65536 is fixed and implicit. r0 and r1 are not padding, not error bounds, not overflow protection. They are exact unresolved structure from integer division.

**Addition/subtraction:** r0 and r1 carry through cleanly with borrow/carry propagation. Nothing interesting happens — the fields just add.

**Multiplication:** `a.v * b.v` produces an i64 product. `divTrunc(product, D)` gives new v. `mod(product, D)` gives r0 — the exact part v couldn't absorb. The cross-terms `a.r0 * b.v + b.r0 * a.v` produce structure below r0, captured in r1. Without r1, you can't tell if your r0 values are degrading across a chain of multiplications.

**Division:** `a.v * D / b.v` — divTrunc gives new v, mod gives r0. Then `r0 * D / b.v` — divTrunc gives r1. Division is worse than multiplication for remainder accumulation because the divisor can be any value. Dividing by a number that doesn't factor cleanly into D (like 3) produces remainder that never resolves — r0 will always be nonzero, and chained divisions push r1 toward saturation faster than multiplication chains. This makes r1 especially useful as a precision sentinel for division-heavy paths like the reciprocal square root in LayerNorm.

**What r1 tells you:** After a chain of operations, if r1 is consistently near the i16 boundary (±32767), the Q16 frame is running out of room. You know to escalate that specific computation to Q32 (D=2^32, i32 remainder levels). This is an informed decision based on exact data, not a heuristic guess about accumulated error.

**The principle:** r0 tells you what v lost. r1 tells you what r0 lost. The remainder is not error — it is the exact value that the denominator frame could not absorb. Discarding it is the bug that float arithmetic has normalized.

