# VDR-Prolog CPU

**Exact integer LLM inference + Prolog knowledge system on laptop hardware**

CPU SIMD branch of [VDR-LLM-Prolog](https://sireus.cloud/vdr-llm-prolog/). 

- [VDR-LLM-Prolog project page](https://sireus.cloud/vdr-llm-prolog/), Introduction, explanation, and all papers.
- [Python vdr-math library](https://github.com/ghowland/vdr-math), Scientific use of VDR. All math domains with exact integer results.
- [Parked: GPU version of VDR-Prolog](https://github.com/ghowland/VDRProlog), The GPU path (PTX/SPIR-V) is parked pending Zig nvptx64 toolchain fixes.

---

## What This Is

A complete LLM inference and knowledge management system that runs on a single laptop. No GPU required. No cloud dependency. No floating point arithmetic anywhere in the compute path.

The system combines three things that don't normally go together:

1. **Exact integer LLM inference**, Q16 fixed-denominator rational arithmetic (D=65536) with two remainder slots. Softmax sums to D exactly, every time, on every device. No NaN, no Inf, no drift, no renormalization.

2. **Prolog knowledge bases**, Structured data at integer addresses, queryable by unification, with confidence propagation, provenance tracking, and grant-gated access control. The LLM doesn't hold data in its context window, it issues 8-token commands to read/write KB addresses.

3. **Self-reducing cost**, The LLM formalizes its judgments as Prolog rules. Next time the same pattern occurs, the rule fires without the LLM. At maturity, 93% of operations are zero-token Prolog rule firings (L3), not LLM forward passes (L1).

---

## Why No Float

Current LLM inference uses INT8/INT4 weights but dequantizes to FP16/BF16 for compute. Softmax runs in FP32 for stability. LayerNorm upcasts to FP32 and back. Each precision conversion is a rounding event. Over 80+ layers, hundreds of rounding events per token accumulate non-deterministically.

VDR-Prolog eliminates this entirely:

- **Softmax sums to 65536 exactly.** Not approximately. The remainder from integer division is tracked and the deficit is assigned to the element with the largest remainder (Fixed Remainder Unit). Proven in a toy model across 20 epochs with zero violations.
- **Deterministic across runs.** Same input, same output, bit-for-bit, every time. Integer arithmetic has no rounding modes, no thread-ordering dependence, no platform variation.
- **No failure modes from numerical instability.** No NaN propagation, no gradient explosion, no loss scaling, no denormal flushing.

For diffusion models generating 120K+ frames, exact unity is not a nice-to-have, it's the difference between temporal coherence and accumulated drift.

---

## Architecture

```
Single Process, N+1 Arenas, Pinned Threads

┌────────────────────────────────────────────────────┐
│              Global Arena (read-heavy)              │
│  Model Weights │ Seed KBs │ Text │ Grants │ Audit  │
├──────────┬──────────┬──────────┬──────────┬────────┤
│ Core 0   │ Core 1   │ Core 2   │ ...      │Core N  │
│ Arena    │ Arena    │ Arena    │          │Arena   │
│ Sessions │ Sessions │ Sessions │          │Sessions│
│ KV Cache │ KV Cache │ KV Cache │          │KV Cache│
│ Ephemeral│ Ephemeral│ Ephemeral│          │Ephemer.│
├──────────┴──────────┴──────────┴──────────┴────────┤
│  Engines: LLM (SIMD) │ KB Store │ Prolog │ Grammar │
└────────────────────────────────────────────────────┘
```

One process. Fixed-size arenas allocated at startup. No malloc after init. One thread per physical core, pinned for cache locality. All engine calls are direct function invocations, no bridge, no dispatch, no serialization.

---

## ID System, Sign-Bit Partitioned Dual Addressing

Every entity has a 64-bit ID. Bit 63 partitions the address space:

| Bit 63 | Meaning | Lifetime | Example |
|--------|---------|----------|---------|
| 0 | Global (positive) | Persistent, shared | `root.science.physics.qed` → UUID `+0x3A7F...` |
| 1 | Ephemeral (negative) | Session-local, dies with session | `session_root.notes.hypothesis` → `-5` |

**Dual addressing**, every KB is reachable two ways:

- **Walk path:** `root.science.physics.qed.alpha_em` → `1.12.17.13.25` (tree traversal)
- **Direct UUID:** Jump straight to `+0x3A7F...` (one hash lookup)

**Ephemeral tree**, each LLM session gets a scratch tree at ID `-1`:

```
session_root = -1
session_root.scratch = -2
session_root.notes = -3
session_root.notes.hypothesis_1 = -4
```

Ephemeral IDs monotonically decrement. They never collide with global IDs (positive). When the session dies, the ephemeral arena region resets. No per-entry cleanup needed.

The LLM writes working notes to its ephemeral tree between turns. This is persistent within the session (survives across turns) but dies with the session. Data worth keeping gets explicitly promoted to the global tree via a command.

---

## Q16, Exact Rational Arithmetic

```
Q16 { v: i32, r0: i16, r1: i16 }    // 8 bytes, two remainder slots
D = 65536 (2^16), implicit, never stored
```

Every value is a fraction: `v/D` with remainders `r0` and `r1` tracking sub-quantum precision. Two levels of remainder means you always know exactly what was lost.

| Operation | Implementation |
|-----------|---------------|
| Add | i64 widening, carry from r1→r0→v |
| Multiply | i64 product, divTrunc by D, remainder to r0, cross-term remainder to r1 |
| Compare | v first, then r0, then r1, three-level exact ordering |
| Softmax | int_exp + normalize + FRU deficit assignment → sum = D exactly |

SIMD: AVX2 processes 8 × i32 `v` fields simultaneously. `r0`/`r1` propagated in scalar post-pass when full precision is needed.

---

## Data Types

### Fact, The Atomic Unit of Knowledge

```
Fact { tag, value: Q16, provenance: Provenance }
```

Tag classifies the data (value, text, reference, timestamp, boolean, vector, matrix, counter, etc.). Provenance tracks where the fact came from (source type, confidence as exact Q16 fraction, derivation rule, timestamp).

### KB, The 256-Byte Knowledge Base Struct

Every KB is the same size (256 bytes, cache-line aligned). Contains:
- Identity: UUID, parent ID, name, dotted path, walk ID
- Stores: offsets + counts + capacities for facts, rules, constraints, connections, grammars
- Live state: LRUs, counters, locks, queues, stacks, rings, bitsets
- Children: subtree references, mount points
- Metadata: visibility (public/internal/owner_only), frozen flag, owner, timestamps

### Term, Prolog's Building Block

```
Term { type, primary_id, secondary_offset, secondary_aux, vdr_value: Q16 }
```

Types: atom, variable, integer, VDR value, text, list, compound, vector, matrix, pair. 24 bytes each.

### Rule, Head :- Body → Actions

Rules match against facts via unification. When all body conditions are satisfied, the rule fires and applies its actions (assert/retract facts). Rules track their own statistics: fire count, success rate, last fired timestamp.

---

## Confidence System

Every fact carries a confidence as an exact Q16 fraction:

| Source | Confidence |
|--------|-----------|
| VDR computation | 65536/65536 (1.0) |
| Prolog derivation | 65536/65536 (1.0) |
| Database | 64225/65536 (0.98) |
| Prometheus | 62259/65536 (0.95) |
| REST API | 55705/65536 (0.85) |
| Published | 52428/65536 (0.80) |
| User stated | 45875/65536 (0.70) |
| Web search | 32768/65536 (0.50) |
| LLM generated | 19660/65536 (0.30) |

Agreeing sources combine: `1 - ∏(1 - C_i)`. Two sources at 95% → 99.75%. Exact integer arithmetic, no float.

Confidence chains through derivation: if fact A (95%) derives fact B, B's confidence is 95%. Three-link chain at 85% each: `(55705/65536)³`, exact Q16.

---

## Execution Levels

| Level | LLM Tokens | What Happens | Cost |
|-------|-----------|--------------|------|
| L1 | 50-500 | Full LLM judgment, novel situation | 100% |
| L2 | ~18 | LLM invokes stored Prolog rule | ~3% |
| L3 | 0 | Prolog rule fires automatically | ~0% |

The system compiles away its own need for the expensive component. At investigation 100, 93% of operations are L3. The LLM's job shrinks to handling genuinely novel situations and formalizing new rules.

---

## Model as Knowledge Base

The model is not a monolithic weight blob. Each component is a KB:

```
root.model
├── embedding           (vocab × d_model, i16 weights)
├── layers
│   ├── layer_00
│   │   ├── attention
│   │   │   ├── qkv_weights
│   │   │   └── output_weights
│   │   ├── mlp
│   │   │   ├── up_weights
│   │   │   └── down_weights
│   │   └── norm
│   └── ...
├── final_norm
└── lm_head
```

Access to model weight KBs is grant-gated. Different users can see different model capabilities. User A gets all 16 layers. User B gets layers 0-7. User C gets no model access (L3-only KB operations).

Weights stored as i16 (2 bytes per parameter). 1B parameters = 2 GB. Fits in laptop RAM.

---

## Memory Model, Arenas Only

All memory allocated at startup. No malloc after init. No free until shutdown.

| Arena | Contents | Size (8-core laptop) |
|-------|----------|---------------------|
| Global | Model weights, seed KBs, fact store, text, grants, audit | ~2.65 GB |
| Per-core × 8 | Sessions, ephemeral KBs, KV cache, scratch | ~220 MB each |
| **Total** | | **~4.4 GB** |

Fits in 16 GB laptop with room for OS. Bump-pointer allocation: O(1) alloc, O(1) reset. Arena exhaustion returns a specific error code, never silent corruption.

---

## Compute, CPU SIMD (AVX2)

Target: 1B parameter model, 16 layers, d_model=2048, 16 heads.

GEMM is the bottleneck. Per token: ~640M multiply-accumulates across 16 layers.

| Cores | Throughput | Per Token | Tokens/sec |
|-------|-----------|-----------|------------|
| 1 | ~24 GMAC/s | ~27 ms | ~37 |
| 8 | ~192 GMAC/s | ~3.3 ms | ~300 |

GEMM rows split across cores. Atomic barrier synchronization between layers. No mutex, no condition variable, spin on atomic for microsecond-scale waits.

At L3 steady state (93% of operations), most work skips the forward pass entirely. Effective throughput is much higher than raw tok/s.

---

## Threading

One thread per physical core, pinned via OS affinity. Each thread owns its per-core arena. Session assigned to a core at creation; all session work runs on that core's thread using that core's arena.

GEMM parallelized: all cores contribute rows, synchronize via atomic counter per layer. NUMA alignment via first-touch policy, each pinned thread touches its arena pages at init, ensuring local memory placement on multi-socket systems. On single-socket laptops, this still helps cache locality.

---

## Grant System

Operations that touch the outside world (filesystem, network, process execution) require explicit grants:

| Grant Class | What It Gates |
|-------------|--------------|
| filesystem | Read/write/delete files |
| compile | Compile source code |
| execute | Run scripts/processes |
| lint | Code analysis |
| network | HTTP fetch, API calls |
| process | Process management |

Grants are integer-checked: user_id + grant_class + target pattern + expiry + use count. Every check writes an audit entry. No heuristics, no LLM evaluation, no prompt injection vector. The LLM doesn't execute the check, the system does.

---

## Access Control

Data is **absent**, not filtered. A query from a session without access to KB X returns zero results from X. The query path never touches X's data. This is structural, the access check runs before data is read, not after.

Visibility levels: public (anyone), internal (authenticated), owner_only (creator). Visibility walks the parent chain, an owner_only KB inside a public tree is still owner_only. A public KB inside an owner_only tree is invisible because the ancestor is unreachable.

---

## Audit

Every access check, grant check, fact assertion, fact retraction, rule firing, session creation, session destruction, and operational execution produces an audit entry. Ring buffer, fixed size, oldest overwritten. All entries are integers, filterable by session, user, action, KB, time range, result.

---

## Snapshot & Clone

Snapshots capture session state (global view + ephemeral tree) as a contiguous binary blob. CRC32 checksum. Restore is bit-identical, the session continues exactly where it left off, including ephemeral IDs.

Clone creates a new session sharing the parent's data via copy-on-write. First write triggers page copy. Kill clone → COW pages freed, parent untouched. Merge clone → dirty pages applied to parent with conflict detection.

---

## Project Files

```
vdr_types.zig        , All types: Q16, VdrId, Fact, KB, Term, Rule, Session, etc.
vdr_shared.zig       , Constants, D, exp table, enums
vdr_arena.zig        , Fixed-size arena allocator
vdr_numa.zig         , Core detection, thread pinning
vdr_thread_pool.zig  , Pinned threads, GEMM work distribution
vdr_ops.zig          , SIMD: gemm, dot, softmax, rmsnorm, attention, silu
vdr_model.zig        , KB-based model loading, forward pass
vdr_kb_store.zig     , KB CRUD, dual addressing, ephemeral resolution
vdr_prolog.zig       , Unification, query, rule firing
vdr_grammar.zig      , Template compile, render, inherit
vdr_session.zig      , Session lifecycle, ephemeral tree, clone/merge
vdr_snapshot.zig     , Save/restore, diff, merge
vdr_runner.zig       , Poller, processor, internal, batch runners
vdr_inference.zig    , Full inference loop, L1/L2/L3
vdr_command.zig      , Command parser, executor
vdr_access.zig       , Visibility check, ephemeral/global resolution
vdr_grant.zig        , Grant CRUD, check, cleanup
vdr_audit.zig        , Ring buffer, query, filter
vdr_confidence.zig   , Assign, combine, chain, propagate
vdr_seed.zig         , Seed layer init, model weight KB creation
vdr_builtin.zig      , 448 builtins, IOSE validation
vdr_system.zig       , Top-level init
vdr_test.zig         , Determinism, roundtrip, isolation tests
build.zig            , Single native x86_64 target
```

---

## Invariants

These hold at all times, in all states. Violation is a bug.

1. **Softmax outputs sum to D exactly.** Not approximately. Exactly.
2. **KB facts at integer addresses are exact.** Turn 1 or turn 1,000,000.
3. **Bounded primitives cannot exceed declared bounds.**
4. **Snapshot restore is bit-identical.**
5. **Clone COW is invisible to parent.**
6. **Access-denied data is absent, not filtered.**
7. **Grant denial happens before execution.**
8. **Integer arithmetic is deterministic across runs.**
9. **Prolog unification uses exact comparison.** All three Q16 fields.
10. **Audit log is append-only and complete.**
11. **Ephemeral IDs never collide with global IDs.** Sign bit guarantees it.
12. **Ephemeral data dies with its session.**
13. **Arena memory is never exhausted silently.**
14. **SIMD GEMM produces identical results to scalar GEMM.**

---

## Status

**src/vdr_types.zig**, Complete. All structs with defaults.

Everything else, pending implementation.

GPU path (PTX/SPIR-V) parked at [VDR-Prolog](https://github.com/ghowland/VDRProlog) pending Zig 0.16.0 nvptx64 toolchain fixes.

---

## Target Hardware

2019 Laptop or equivalent:
- x86_64 with AVX2
- 6-8 physical cores
- 16-32 GB RAM
- No GPU required

---

## License

MIT
