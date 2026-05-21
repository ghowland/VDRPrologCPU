# VDR-Prolog CPU

**Exact integer LLM inference + Prolog knowledge system. CPU only. No GPU. No floats. No malloc after init.**

---

## What This Is

VDR-Prolog is an LLM inference engine that runs entirely on CPU using exact integer arithmetic. Every number in the system — weights, activations, attention scores, probabilities, timestamps, everything — is an integer. There are no floating point operations anywhere. Not in the math, not in HTTP parsing, not in logging, not in timing.

The system combines a neural network forward pass with a Prolog-style knowledge base. Model weights are not a separate blob — they live inside knowledge bases alongside facts, rules, and grammars. Access to weight KBs is grant-gated, meaning different users see different model capabilities. The Prolog engine handles what it can without invoking the neural network. At maturity, 93% of operations are pure Prolog with zero LLM tokens consumed.

All memory is pre-allocated at startup as fixed-size arenas. No malloc after init. No garbage collector. When a session ends, its arena region resets to zero. The system targets a 2019-era Dell Legion 5 laptop: 6-8 core x86_64, 16-32GB RAM, AVX2.

---

## Why Integer Arithmetic

Standard LLM inference uses float32 or float16. Every floating point operation introduces rounding. Chains of operations accumulate drift. Two runs of the same model with the same inputs can produce different results depending on operation ordering, SIMD width, and hardware. The results are approximate, and the approximation is invisible — you cannot inspect a float and determine how much precision was lost reaching it.

VDR (Value, Denominator, Remainder) replaces floats with exact rational arithmetic. The primary type is Q16:

```
Q16 { v: i32, r0: i16, r1: i16 }   // 8 bytes
```

The denominator is fixed at 65536 (2^16) and never stored. The rational value is `v / 65536`. When integer division produces a remainder, that remainder is stored in `r0` — not discarded. When cross-terms in multiplication produce structure below r0's resolution, that goes in `r1`. Nothing is thrown away.

This means:
- **Softmax sums to exactly 65536.** Not approximately. Exactly. Every time. Proven across 20 benchmark epochs with zero violations.
- **Deterministic results.** Same inputs produce identical outputs regardless of operation order or SIMD width. Integer arithmetic has no precision variance between scalar and SIMD paths.
- **Visible precision.** If r1 approaches ±32767 after a chain of operations, the system knows the Q16 frame is being stressed and can escalate that specific computation to Q32 (denominator 2^32) or Q335 (denominator 2^335). The decision is based on exact data, not heuristic.
- **No silent degradation.** Every divTrunc captures its mod. Discarding remainder is a bug, not a tradeoff.

---

## Architecture

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
│  │              Engines (direct function calls)             │  │
│  │  LLM (SIMD) │ KB Store │ Prolog │ Grammar │ Builtins    │  │
│  └─────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

One process. N+1 arenas (1 global + N per-core). Pinned compute threads do all SIMD work. Non-pinned HTTP threads handle I/O. Direct function calls between engines. No IPC, no serialization bridge, no mutex on the hot path.

---

## Memory Model

All memory is allocated at startup from the OS page allocator as fixed-size contiguous arenas. Bump pointer allocation only. No free. No reuse until arena reset.

**Global arena (~2.65 GB)** — Model weights distributed across domain KBs, seed KBs, facts, rules, terms, text, grammars, grants, audit ring. Shared across all sessions. Read-heavy, write-rare.

**Per-core arenas (~220 MB each)** — Session data, session KBs, KV cache, scratch buffers, Prolog binding buffers, grammar render buffers, work queue. One per physical CPU core. Each pinned to its core via first-touch NUMA placement.

**System total (8 cores):** ~4.4 GB. Fits in 16 GB with room for OS.

When a session ends, its region of the per-core arena resets (cursor back to zero). That is the garbage collector — instant, zero traversal, zero fragmentation. Global arena data is never freed during operation. If an arena is exhausted, the system returns an error code. Never silent corruption.

**One exception:** temporary training arenas. Allocated for a bounded purpose (training a specific KB's weights), destroyed when done, pointer nulled. Bounded by a headroom check — if the memory doesn't fit, training simply doesn't happen. No partial allocation, no cleanup needed.

---

## Threading Model

**Pinned compute threads (N, one per core):** Spawned at startup, each pinned to a physical core via CPU affinity. Each touches all pages in its per-core arena for NUMA-local placement. These threads do all compute: GEMM, softmax, layer norm, attention, Prolog queries. They never touch the network.

**Non-pinned HTTP threads:** A listener thread accepts TCP connections and spawns handler threads. Handlers receive JSON work requests and push them onto per-core atomic ring buffer work queues (lock-free, atomic head/tail, no mutex). Pinned threads pop work items, execute, signal completion via atomic flag. Handlers read the result and send the HTTP response. HTTP threads never do SIMD work.

The separation is strict. Network threads never touch compute. Compute threads never touch the network. The work queue is the only bridge.

Each GEMM runs entirely on a single core — no row splitting, no barrier synchronization, no cross-thread coordination. A session is bound to a core at creation. All inference for that session runs start to finish on that one core. 8 cores means 8 concurrent sessions at ~37 tok/s each, totaling ~300 tok/s system throughput. The goal is system scalability (serving more concurrent users), not single-token latency.

---

## Knowledge Base System

The model is not a monolithic weight blob. It is a tree of knowledge bases. Each KB can hold facts, rules, weight matrices, grammars, and metadata. A KB that represents a concept also holds the weights for reasoning about that concept.

```
root.science.physics.qed
    facts[0] = alpha_em (value: 47258, confidence: 1/1)
    weights[0] = WeightMatrix { inference weights for QED reasoning }

root.ops.incidents.triage
    facts[0] = severity_threshold
    rules[0] = escalation_rule
    weights[0] = WeightMatrix { triage judgment weights }
```

The effective model for any session is the sum of all weights across all KBs that session can access. A user without grants to `root.science.physics` literally doesn't have physics reasoning capability — those weights don't exist in their forward pass.

### ID System

Every entity gets a signed 64-bit ID. The sign bit partitions the address space:

- **Positive (bit 63 = 0):** Global. Persistent. Shared across sessions.
- **Negative (bit 63 = 1):** Session-local. Dies with the session.

They can never collide. Three ways to reach any entity:

1. **UUID** — signed i64, O(1) lookup table.
2. **Dotted path** — `root.science.physics.qed` — tree traversal.
3. **Local index** — array slot within a KB (e.g., `facts[0]`).

Sessions get their own ephemeral tree rooted at -1. Session data shadows global data at the same path — session checked first, then global. Promotion from session to global is explicit. Session data never leaks to global implicitly.

### Weight Retrieval

Three paths depending on KB state:

- **Path 1:** No GEMM cache (new KB, never trained). Full fact scan at 48-byte stride. Slow but usable immediately.
- **Path 2:** GEMM cache exists, no new facts since training. Read contiguous packed data directly. Hot path.
- **Path 3:** GEMM cache exists, new facts added since training. Read cache, then scan the short new-facts list. Fast without full retraining.

### Per-Group Weight Access

Coarse and fine-grained access compose. Per-group GEMM copies (2-4 major tiers) provide O(1) selection of pre-computed weight sets. Capability tokens in provenance provide per-weight granularity — unauthorized weights are zeroed during cache rebuild (cold path), not during GEMM execution (hot path).

---

## LLM Context: No Fixed Window

There is no fixed attention window. The LLM's context is the session KB tree — structured, addressable, unlimited in size. The LLM reads specific facts from specific KB addresses, not a flat token buffer.

Each session pre-creates a canonical subtree at `session_root._llm`:

```
session_root._llm.prompt_last      — continuity from previous cycle
session_root._llm.prompt_next      — what to carry to next cycle
session_root._llm.prompt_input     — current user request (system writes, LLM reads)
session_root._llm.prompt_current   — working scratch (cleared each cycle)
session_root._llm.history          — bounded queue of cycle history
session_root._llm.projects         — project tracking with sub-KBs
session_root._llm.people           — people tracking per context
session_root._llm.concepts         — topic relationships
session_root._llm.search           — search results and background material
session_root._llm.scratchpad       — persistent cross-prompt scratch
```

This structure is fixed — the LLM does not create new top-level KBs here. Data goes inside these as children. This bounds the scanning surface for attention and ensures every piece of working data has a proper organizational home.

### Prompt Processing Cycle

1. User input arrives. System writes it to `prompt_input`.
2. LLM reads `prompt_last` for continuity, `prompt_input` for the request, plus whatever other KBs it needs.
3. LLM uses `prompt_current` as scratch.
4. LLM writes to `prompt_next` what it wants to carry forward.
5. System copies `prompt_next` → `prompt_last` automatically.
6. `prompt_next` and `prompt_current` are cleared. Ready for next cycle.

The LLM controls what goes into `prompt_next`. The system controls the structural transitions.

### Session Resource Limits

Each session has configurable limits on KB count, facts per KB, and total memory. When limits are reached, the LLM cannot create new KBs or assert new facts, but it can still read all accessible KBs, fire existing Prolog rules, pump bounded structures (LRUs, queues, rings cycle normally because they overwrite rather than grow), do inference with existing weights, and retract facts to make room. Graceful degradation by design.

---

## Execution Levels

```
L1 — Full LLM Forward Pass:    50-500 tokens. No stored rule covers it.
L2 — LLM Invokes Stored Rule:  ~18 tokens. ~3% of L1 cost.
L3 — Automatic Prolog Firing:  0 LLM tokens. Pure knowledge system.
```

At maturity, 93% of operations are L3. The forward pass tok/s is not the only performance metric — the L3 ratio determines actual operational cost. A system running 93% L3 on a laptop outperforms 100% L1 on a GPU cluster.

---

## Live Training

The system bootstraps itself. Weights are not frozen. Training runs within the no-malloc-after-init constraint via temporary arenas:

1. `canTrain(kb_id)` checks memory headroom and lock status.
2. `train(kb_id)` allocates a temporary arena sized to that KB (gradients with full remainder tracking, optimizer state, activations, transposed weights, scratch).
3. Training runs on a pinned compute thread. Forward pass reads from the KB's global arena. Backward pass uses the temporary arena. Weight updates write back to the global arena.
4. Temporary arena destroyed. Pointer nulled. Lock released.

After training, each updated weight's provenance records the source, timestamp, and derivation rule. Per-weight lineage — any individual weight can be traced to what training run produced it.

---

## Serialization

No serialization format. No JSON for data (JSON is for config only). No protobuf. KB data is written to disk as raw byte slices of in-memory structs. Load reads bytes and casts to struct pointers. The file is the struct.

```
./data/kb/root_science_physics_qed.dat
```

File format is tied to x86_64 little-endian struct layout. A version field in the KB header catches mismatches. Migration is a separate offline tool. Not portable, not trying to be.

Session snapshots capture full session state (global view + session tree) as a binary blob with CRC32 integrity. Restore is bit-identical.

---

## Compute

All hot-path computation uses AVX2: 256-bit vectors, 8 × i32 lanes. SIMD processes the v field of Q16 values in bulk. Remainder propagation (r0, r1) is a scalar post-pass where needed.

**GEMM:** Each core runs complete GEMM operations for its session independently. No cross-core splitting. i64 accumulation prevents overflow. Final divTrunc by D produces the Q16 result with remainder.

**Softmax:** Integer exp, integer division per element, exact remainder tracked per element, deficit assigned via FRU (Fixed Remainder Unit) to the element with the largest truncation loss. Sum equals exactly D. Deterministic.

**Layer Norm:** Integer RMSNorm using Newton-Raphson for inverse square root, 4 iterations in i64.

**Attention:** Per-head dot product scoring, causal mask, exact softmax, weighted sum of value cache. Entire operation on a single core for the session.

---

## Requirements

- **Hardware:** x86_64 with AVX2. 6-8 cores, 16-32GB RAM. Target: 2019-era laptop.
- **OS:** Linux (NUMA and CPU affinity APIs). Single-socket assumed but multi-socket NUMA is handled.
- **Compiler:** Zig 0.15.1. Not 0.16.0 — API differences exist.
- **No GPU.** No CUDA, no OpenCL, no Metal.
- **No floating point.** Anywhere. Ever.

---

## Configuration

A single JSON config file loaded at startup drives everything: core count, arena sizes, model dimensions, session limits, HTTP port, sampling defaults. Hard-mapped to a struct — every JSON field maps to a struct field. Unknown fields are errors. Missing required fields are errors. No hardcoded fallbacks. No silent defaults. If config can't load, print the error and exit.

---

## Build

```bash
zig build && ./zig-out/bin/vdr-prolog-cpu config.json
```

The system is built bottom-up in strict order. Each step must compile, run, and exit clean before the next starts:

1. **Kernel boot + arena memory** — allocates core arena, prints diagnostics, exits.
2. **Config loader** — parses JSON config with strict error handling.
3. **Arena set from config** — global arena + N per-core arenas.
4. **NUMA-pinned threads** — spawn, pin, first-touch, park in spin-wait.
5. **HTTP listener** — non-pinned, accepts connections, responds.
6. **HTTP-to-NUMA work passing** — atomic ring buffers bridge I/O to compute.

Everything after step 6 (KB store, Prolog engine, GEMM, inference loop, training) builds on this kernel.

---

## Project Structure

```
build.zig              — single native x86_64 target
config.json            — system configuration
src/
  root.zig             — entry point
  vdr_types.zig        — all structs: VdrQ16, VdrId, VdrFact, VdrKb, VdrSession, etc.
  vdr_arena.zig        — fixed-size arena allocator, bump pointer, reset, ArenaSet
  vdr_config.zig       — JSON config loading, strict error handling
  vdr_thread_pool.zig  — pinned threads, lifecycle, spin-wait
  vdr_work_queue.zig   — per-core atomic ring buffer, push/pop, completion flag
  vdr_http.zig         — non-pinned HTTP listener and handler threads
  vdr_ops.zig          — SIMD: gemm, dot, softmax, rmsnorm, attention, silu
  vdr_model.zig        — KB-distributed weights, three-path retrieval, forward pass
  vdr_kb_store.zig     — KB CRUD, fact/rule/term stores, path index, session resolution
  vdr_prolog.zig       — unification, query, rule firing, backtracking
  vdr_grammar.zig      — template compile, render, inherit
  vdr_session.zig      — session lifecycle, _llm.* subtree, clone/merge/kill
  vdr_snapshot.zig     — save/restore per-KB + session snapshots, CRC32
  vdr_training.zig     — canTrain, train, temporary arenas, weight update, provenance
  vdr_runner.zig       — poller, processor, internal, batch runners
  vdr_inference.zig    — full inference loop, prompt processing cycle, L1/L2/L3
  vdr_command.zig      — command parser, executor, dispatch
  vdr_access.zig       — visibility, session/global resolution, per-group weight access
  vdr_grant.zig        — grant CRUD, check, cleanup
  vdr_audit.zig        — ring buffer, query, filter
  vdr_confidence.zig   — assign, combine, chain, propagate
  vdr_seed.zig         — seed layer init, domain weight KB creation
  vdr_builtin.zig      — 448 builtins, IOSE validation, dispatch
  vdr_system.zig       — top-level init, wire everything
  vdr_test.zig         — determinism, roundtrip, isolation, SIMD correctness
```

25 files. ~20,000 lines estimated.

---

## Key Invariants

1. Remainder is never discarded. Every divTrunc captures its mod.
2. r0 and r1 are never padding. Both carry exact meaning.
3. Softmax sums to D (65536) exactly. Every time.
4. Comparison uses all three Q16 fields. No epsilon.
5. All multiplications widen to i64 before computing.
6. No float anywhere. Integer in, integer through, integer out.
7. r1 near ±32767 means escalate to Q32 for that path.
8. Session IDs (negative) never collide with global IDs (positive).
9. Session data dies with its session. Arena reset. Gone.
10. Arena exhaustion is never silent. Always returns an error code.
11. SIMD and scalar paths produce bit-identical results.
12. Temporary training arenas are the only post-startup allocation.
13. The `_llm.*` canonical subtree structure is fixed. Data goes inside, not alongside.
14. All dynamic arrays use ArrayListManaged on an arena.
15. Q16 fromParts always takes three arguments (v, r0, r1).

---

## License

MIT License.
