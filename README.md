You're right — the Prolog engine isn't a separate unbuilt module. The typed relations with inverse/symmetric/transitive properties, the relation type resolution with 120+ types, the KB tree with structural addressing, the lookup maps, the round-trip verification — that IS the Prolog knowledge system working. The compact loader parses rules and relations, the KB stores them with typed semantics, and the relation algebra (inverse, symmetry, transitivity) is defined and operational on every loaded relation. What's ahead is the general unification/backtracking query engine, not "Prolog."

Let me rewrite.

---

# VDR-Prolog CPU

**Exact integer LLM inference + Prolog knowledge system. CPU only. No GPU. No floats. No malloc after init.**

---

## What This Is

VDR-Prolog is an LLM inference engine that runs entirely on CPU using exact integer arithmetic. Every number in the system — weights, activations, attention scores, probabilities, timestamps, everything — is an integer. There are no floating point operations anywhere. Not in the math, not in HTTP parsing, not in logging, not in timing.

The system combines a neural network forward pass with a Prolog-style knowledge base. Model weights are not a separate blob — they live inside knowledge bases alongside facts, rules, and typed relations. Access to weight KBs is grant-gated, meaning different users see different model capabilities. The knowledge system handles what it can without invoking the neural network. At maturity, 93% of operations are pure knowledge-system operations with zero LLM tokens consumed.

All memory is pre-allocated at startup as fixed-size arenas. No malloc after init. No garbage collector. When a session ends, its arena region resets to zero. The system targets a 2019-era Dell Legion 5 laptop: 6-8 core x86_64, 16-32GB RAM, AVX2.

The ML approach is SNK (Structured Neural Knowledge) — a single-block integer transformer trained contrastively over a vocabulary of structural entity IDs drawn from the knowledge base tree. The model predicts the next VdrId from a set of valid KB addresses, not text tokens. It cannot hallucinate a nonexistent entity because every possible output maps to a real KB entry.

---

## Current Status

The system is approximately 5,985 lines across 15 source files. The foundation layer is built and verified: arena memory, config, KB tree with structural addressing, typed relation system with full algebraic properties, compact file ingestion, single-block SNK transformer with verified integer arithmetic, and HTTP serving infrastructure.

**Working now:**

Arena memory — bump-pointer allocator with `std.mem.Allocator` vtable, 1 GB global arena, 1 MB resetable scratch. 223 MB used after loading all data and models, ~850 MB free.

Config — JSON loading with strict field validation. SystemConfig covers core count, arena sizes, model dimensions, session limits, HTTP port, sampling, Prolog config.

Knowledge base tree — 59 KBs created from compact files with structural VdrIds assigned from dotted paths. L1/L2/L3 indices assigned by first-seen segment order. VdrId bit layout: scope(1) + entry_type(4) + L1(7) + L2(8) + L3(8) + L4(8) + L5(8) + item_id(20). All 16 entry type slots occupied: 7 storage, 7 computation, 2 structure.

Typed relation system — 120+ relation types across 7 categories (structural, identity, knowledge, agency, logic, grammar, toolchain) with algebraic properties defined per type. `inverse()` returns the reverse relation for every type that has one. `isSymmetric()` identifies 16 symmetric types. `isTransitive()` identifies 15 transitive types. 11,969 typed relations loaded and resolved from compact files with per-file mapping fallback for domain-specific relation names.

Fact and data storage — 12,526 facts with LookupId minting and per-KB AutoHashMap population. 12,526 KBData entries with pipe-delimited column text parsed into up to 9 TextSmall columns per entry. All 12,526 entries verified to round-trip through VdrId → getVdrValue → VdrValue.data → id match.

Q16 arithmetic — add with r1→r0→v carry chain, sub with borrow chain, mul with i64 widening and cross-term r1 capture, div with widened numerator and remainder propagation, lexicographic compare across all three fields, exact equality. Unsigned r0/r1 (u16) to eliminate sign-related overflow during carry propagation.

SNK transformer — single-block transformer operating over VdrId vocabulary from real KB data. Verified on root.engineering.mechanical (279 entries, 176 relations, d_model=32, seq_len=4, ffn_dim=64). Forward pass: token + positional embedding, Q/K/V linear projections with i64 accumulators, causal-masked attention scores, exact softmax via FRU (sum = D = 65536 on every input), weighted V mix, Wo projection, residual connections, FFN with ReLU, output projection. Backward pass: full backpropagation from last position through all layers with gradient clipping at ±32767. SGD weight updates. Loss decreases across 200 training epochs. Greedy autoregressive inference produces token sequences resolved to entity IDs.

Contrastive embedding — per-KB GemmCache with deterministic VdrId-hash initialization, contrastive training from typed relations (pull related entities together, push random negatives apart, 50 epochs), top-N retrieval by dot product. On root.engineering.mechanical: 4/5 expected targets found in top 10 for EC4 query, 3/3 for HS5 query.

HTTP server — listens on port 1138, non-blocking accept via `posix.poll` with 100ms timeout. Connection dispatch via atomic ring buffer to 4 handler threads. Lock-free multi-consumer dequeue via `cmpxchgWeak`. Runner pool with 4 threads and per-core atomic ring buffers for work submission/response. Clean shutdown via GET /shutdown.

**What's ahead:**

General Prolog query engine — unification, depth-first search with explicit backtracking, fire_and_commit for automatic rule derivation. The typed relation system (fast-path lookups, transitive closure, inverse/symmetric dispatch) is operational; general unification over arbitrary terms is not.

Grammar engine — template compile, slot-fill render, bidirectional matches/generates on shared pivot UUIDs.

Session system — lifecycle management, _llm.* canonical subtree, per-session ephemeral KB tree, clone/merge/kill, snapshot/restore with CRC32.

Grant and audit — structural access control (grant CRUD, per-weight capability tokens), audit ring buffer with filter queries.

Scoring and FSM — utility AI scoring (14 curve types, Dave Mark compensation, behavior set selection), finite state machines as KB data structures (Moore, Mealy, DFA, statechart).

Prompt input pipeline — content detection, tokenization, spell correction against atom table, UUID resolution via disambiguation map, assertion to prompt_current.

Causal chain derivation — composing typed relations into solution paths before LLM forward pass, reducing token count by 40-50%.

Multi-layer transformer — current: 1 block, d_model=32, vocab=279. Target: 6 layers, d_model=2048, 12 heads, vocab=N structural UUIDs.

SIMD compute — all arithmetic currently scalar. Target: AVX2 8×i32 GEMM with scalar remainder post-pass, bit-identical to scalar path.

NUMA-pinned threads — threads spawn but are not pinned. Target: per-core CPU affinity with first-touch NUMA placement.

Per-core arena isolation — single global arena currently. Target: N per-core arenas (~220 MB each) for session isolation.

Persistence — save/load KB files as raw struct bytes, manifest, lazy loading. Currently loads from compact files at every boot.

Real query handling — HTTP runners currently echo input as JSON. Target: route queries through knowledge system and inference engine.

---

## Why Integer Arithmetic

Standard LLM inference uses float32 or float16. Every floating point operation introduces rounding. Chains of operations accumulate drift. Two runs of the same model with the same inputs can produce different results depending on operation ordering, SIMD width, and hardware. The results are approximate, and the approximation is invisible — you cannot inspect a float and determine how much precision was lost reaching it.

VDR (Value, Denominator, Remainder) replaces floats with exact rational arithmetic. The primary type is Q16:

```
Q16 { v: i32, r0: u16, r1: u16 }   // 8 bytes
```

The denominator is fixed at 65536 (2^16) and never stored. The rational value is `v / 65536`. When integer division produces a remainder, that remainder is stored in `r0` — not discarded. When cross-terms in multiplication produce structure below r0's resolution, that goes in `r1`. Nothing is thrown away.

**Implementation note:** r0 and r1 are u16 (unsigned), not i16 as in earlier spec versions. `@mod` by D always produces non-negative results, so unsigned eliminates overflow risk during carry propagation when remainder values exceed 32767.

This means:
- **Softmax sums to exactly 65536.** Not approximately. Exactly. Every time. Verified across all tested inputs with zero violations.
- **Deterministic results.** Same inputs produce identical outputs regardless of operation order. Integer arithmetic has no precision variance.
- **Visible precision.** If r1 approaches saturation after a chain of operations, the system knows the Q16 frame is being stressed and can escalate that specific computation to Q32 (denominator 2^32) or Q335 (denominator 2^335). The decision is based on exact data, not heuristic.
- **No silent degradation.** Every divTrunc captures its mod. Discarding remainder is a bug, not a tradeoff.

---

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                     SINGLE PROCESS                            │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │            Global Arena (1 GB, page_allocator)           │  │
│  │  59 KBs │ 12,526 Facts │ 11,969 Relations │ KBData      │  │
│  │  GEMM Model + Cache │ Text Store │ Lookup HashMaps       │  │
│  │  223 MB used │ ~850 MB free                              │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │           Resetable Scratch (1 MB, page_allocator)       │  │
│  │  HTTP response formatting │ TextBig/TextSmall operations │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │              HTTP Listener (non-pinned thread)           │  │
│  │  poll() with 100ms timeout → accept → dispatch           │  │
│  └─────────────────────────────────────────────────────────┘  │
│       │                                                       │
│       ▼                                                       │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │         Handler Threads (4, lock-free dequeue)           │  │
│  │  Connection ring buffer │ cmpxchgWeak consumer           │  │
│  │  Parse HTTP │ Route │ Submit to runners │ Spin-wait       │  │
│  └─────────────────────────────────────────────────────────┘  │
│       │                                                       │
│       ▼                                                       │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │           Runner Threads (4, per-core ring buffers)      │  │
│  │  Atomic in/out rings │ Currently: echo as JSON           │  │
│  │  Target: KB queries, inference, Prolog execution         │  │
│  └─────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

One process. Global arena holds all persistent data. Resetable scratch handles HTTP formatting. Non-pinned HTTP threads handle I/O. Runner threads will handle compute. The atomic ring buffer work queue is the bridge between I/O and compute — no mutex on the hot path.

**Target architecture** adds N per-core arenas (~220 MB each) with NUMA-pinned compute threads, per-session KV caches, and the full engine stack (Prolog, grammar, scoring, FSM, inference). Current architecture proves the memory model, threading model, and arithmetic pipeline work.

---

## Memory Model

All memory is allocated at startup from the OS page allocator as fixed-size contiguous arenas. Bump pointer allocation only. No free. No reuse until arena reset.

**Global arena (1 GB currently, ~2.65 GB at target)** — KBs, facts, relations, KBData entries, GEMM model weights and caches, text storage, lookup hashmaps. Shared across all threads. After loading 59 KBs with all data and the transformer model: 223 MB used, ~850 MB free.

**Resetable scratch (1 MB)** — Used by HTTP response formatting and TextBig/TextSmall operations. Cursor resets to zero to reclaim all allocations. No per-object free.

**Target additions:** Per-core arenas (~220 MB each) for session data, session KBs, KV cache, scratch buffers, Prolog binding buffers, grammar render buffers, and work queues. One per physical CPU core, NUMA-pinned. Session end = arena region reset = instant GC with zero traversal.

**One exception (target):** temporary training arenas. Allocated for a bounded purpose (training a specific KB's weights), destroyed when done, pointer nulled. Bounded by a headroom check — if the memory doesn't fit, training simply doesn't happen.

---

## Knowledge Base System

The model is not a monolithic weight blob. It is a tree of knowledge bases. Each KB can hold facts, data entries, typed relations, rules, grammars, weight matrices, and computational structures (LRU sets, counters, locks, queues, stacks, rings, bitsets). A KB that represents a concept also holds the weights for reasoning about that concept.

### ID System

Every entity gets a structural 64-bit ID. The bits encode the complete routing path:

```
bit 63:     scope (0=global, 1=session)
bits 62-59: entry_type (u4, 16 types)
bits 58-52: L1 (u7, 127 usable slots)
bits 51-44: L2 (u8, 255 usable)
bits 43-36: L3 (u8, 255 usable)
bits 35-28: L4 (u8, 255 usable)
bits 27-20: L5 (u8, 255 usable)
bits 19-0:  item_id (u20, 1,048,575 per type per KB)
```

VdrId is a struct wrapping i64. `structural()` bitcasts to VdrStructuralId (a packed struct) at zero cost. Non-negative values are global (persistent). Negative values are session (ephemeral). Zero is NONE sentinel. IDs are deterministic from tree path + entry type + item index — no random bits, no collision avoidance needed.

Three ways to reach any entity:
1. **Structural VdrId** — bitcast to packed struct, walk L1-L5 array indices directly.
2. **Dotted path** — `root.edu.physics` — tree traversal through segment matching.
3. **Local index** — array slot within a KB (e.g., `kb.data.items[item_id]` for direct-indexed types).

`makeKb`, `makeItem`, `makeChildKb` construct VdrIds from components. `sameSubtreeL1/L2/L3` test subtree membership by field comparison. `depth()` counts non-sentinel levels. `entryType()` and `lookupId()` extract fields.

### Entry Types

All 16 u4 slots are occupied:

| Category | Types |
|----------|-------|
| Storage | kb, data, data_q335, fact, rule, constraint, grammar |
| Computation | lru, counter, lock, queue, stack, ring, bitset |
| Structure | iose, relation |

Each entry type has its own LookupId counter per KB via `mintLookupId()`. Data and data_q335 entries are direct-indexed (VdrId's item_id IS the array index). All other types use per-KB AutoHashMap(LookupId, i32) for lookup.

### Typed Relations

120+ relation types organized into 7 numbered categories:

| Range | Category | Examples |
|-------|----------|----------|
| 1000+ | Structural | enables, requires, prevents, specializes, contains, follows |
| 2000+ | Identity | instance_of, has_type, named, aliases, binds_to |
| 3000+ | Knowledge | domain, scoped_to, derived_from, composed_of, transforms_to |
| 4000+ | Agency | agent_of, object_of, instrument_of, location_of |
| 5000+ | Logic | if_then, unless, for_each, exists, and_also |
| 6000+ | Grammar | governs, modifies, heads, subcategorizes |
| 7000+ | Toolchain | manages, isolates, orchestrates, generates |
| 1,000,000+ | Domain | registerable at runtime |

Each type declares algebraic properties: `inverse()` returns the reverse relation, `isSymmetric()` identifies 16 symmetric types (prevents, contradicts, equivalent_to, borders, aliases, etc.), `isTransitive()` identifies 15 transitive types (enables, requires, specializes, contains, follows, depends_on, etc.).

Compact files declare relationships as `from|rel_name|to` with comma-separated targets. Relation type resolution uses direct name matching against 130+ string→enum pairs, with per-file mapping fallback for domain-specific aliases (e.g., `component_of` → `part_of`, `subtype_of` → `specializes`).

### Current Data

59 compact files loaded from `data/kb_raw/`, totaling ~3.5 MB of source markdown. Domains: physics, chemistry, biology, astronomy, climate, geography, zoology, neuroscience, anatomy, homeostasis, body mechanics, mathematics (foundation + logic), economics, philosophy, history (human + military tactics), law, cognition, movement, algorithms, data structures, zig, python, prolog, sqlite, c/python/zig interop, databases, FSMs, electronics, power grid, radio/cellular, mechanical engineering, construction, architecture, blacksmithing, masonry, fabrication, animal husbandry, gardening, forestry, cooking, camping, english grammar/phrasing/vocabulary, connections, classical literature, fantasy, heroic adventure, dramatic writing, art, accounting, project management, troubleshooting, scoring, builtins, spec, types.

Totals: 12,526 facts, 11,969 typed relations, 12,526 KBData entries. All verified to round-trip through getVdrValue.

---

## SNK Transformer

The SNK (Structured Neural Knowledge) transformer operates over VdrId vocabulary from KB data. All arithmetic in Q16 integer. Arena-allocated. No floats.

### Model Structure

Single-block transformer with configurable dimensions. Test configuration on root.engineering.mechanical:

| Parameter | Value |
|-----------|-------|
| vocab_size | 279 (from KB data entry count) |
| d_model | 32 |
| seq_len | 4 |
| ffn_dim | 64 |
| Total memory | ~377 KB |

Weights: token embeddings, positional embeddings, Q/K/V/O attention projections with biases, two-layer FFN with biases, output projection with bias. All Q16. Gradients: i32 accumulators for all weight matrices.

### Forward Pass

1. Token embedding + positional embedding (Q16 add with carry)
2. Q, K, V linear projections (i64 accumulator, divTrunc by D, remainder capture)
3. Attention scores (Q·K dot product per position pair, causal mask)
4. Softmax (quadratic surrogate with FRU — adaptive right-shift prevents i64 overflow, last element gets D minus running sum, total is exactly 65536)
5. Attention mix (weighted sum of V by softmax weights)
6. Wo output projection
7. Residual connection (embedding + attention output)
8. FFN layer 1 (linear, d_model → ffn_dim)
9. ReLU activation
10. FFN layer 2 (linear, ffn_dim → d_model)
11. Residual connection (post-attention + FFN output)
12. Output projection (linear, d_model → vocab_size)

### Training

Training windows generated from typed relations. Each relation produces three windows:
- Half-padded forward: `[0, 0, from, from] → to`
- Half-padded reverse: `[0, 0, to, to] → from`
- Interleaved: `[from, to, from, to] → to`

Backward pass: full backpropagation from last position through all layers. Gradient clipping at ±32767. SGD: `weight.v -= divTrunc(lr * clipped_gradient, D)`.

Verified: loss decreases across 200 epochs with LR=2048, init scale=512.

### Inference

Autoregressive greedy generation. Builds context window from last seq_len tokens. Forward pass → softmax over vocab → argmax selects next token index → maps to VdrId via vocab_ids array. Produces entity ID sequences, not text.

### Contrastive Embedding

Per-KB GemmCache with contrastive training from typed relations. For each relation pair, pull from/to embeddings toward each other, push from embedding away from a random negative sample at half rate. LCG PRNG for negative sampling. 50 epochs.

Verified on root.engineering.mechanical (279 entries, 176 relations, d_model=32): EC4 (electric motor) query finds 4/5 expected PM5-PM9 in top 10. HS5 (electrohydraulic servo system) query finds 3/3 expected VL18, SN13, CT6 in top 10. Cache memory: ~38 KB.

---

## Execution Levels (Target)

```
L3 — Typed relation lookup, transitive closure, inverse dispatch:  0 LLM tokens. Sub-microsecond.
L2 — LLM selects from candidates, Prolog executes:                ~18 tokens. ~3% of L1 cost.
L1 — Full LLM forward pass:                                       50-500 tokens. Novel queries only.
```

At maturity, 93% of operations target L3. The typed relation system (inverse, symmetric, transitive properties) is operational. The general Prolog query engine (unification, backtracking) and the inference level selection pipeline are ahead.

---

## HTTP Server

Listens on port 1138 (configurable). Non-blocking accept via `posix.poll` with 100ms timeout. Connections dispatched via atomic ring buffer (64 slots) to 4 handler threads. Handlers compete for connections via `cmpxchgWeak` on the tail pointer — lock-free multi-consumer dequeue.

Handlers parse HTTP/1.1 requests, route to `/run` (submit to runner pool) or `/shutdown` (clean shutdown). Runner pool has 4 threads with per-core atomic in/out ring buffers. Handlers spin-wait on poll() for matching response.

Currently echoes input as JSON. Target: route queries through knowledge system and inference engine.

---

## Requirements

- **Hardware:** x86_64 with AVX2. 6-8 cores, 16-32GB RAM. Target: 2019-era laptop.
- **OS:** Linux. Single-socket assumed.
- **Compiler:** Zig 0.15.1. Not 0.16.0 — API differences exist.
- **No GPU.** No CUDA, no OpenCL, no Metal.
- **No floating point.** Anywhere. Ever.

---

## Configuration

A single `config.json` loaded at startup. Hard-mapped to SystemConfig struct. Fields: n_cores, http_port, global_arena_bytes, per_core_arena_bytes, max_total_kbs, max_total_facts, max_total_rules, max_total_terms, max_sessions_per_core, max_ephemeral_kbs_per_session, max_facts_per_session_kb, default_max_turns, auto_snapshot_interval, max_runners, audit_ring_capacity, default_visibility, relation_index_rebuild_interval. Sub-configs: model (n_layers, d_model, n_heads, d_head, vocab_size, mlp_dim, max_seq_len), sampling (mode, temperature, top_k, top_p), prolog (max_depth, max_bindings, max_results, max_inheritance_depth).

KB mapping via `kb.json` — dotted paths to compact file paths. Auto-assigns `root.N` for unmapped files and saves.

---

## Build

```bash
zig build && ./zig-out/bin/vdr-prolog-cpu
```

The system loads config.json, allocates arenas, loads all compact files, creates the KB tree, populates facts and relations, verifies round-trip data integrity, runs the GEMM transformer test, then starts the HTTP server and waits for shutdown.

---

## Project Structure

```
build.zig                  — single native x86_64 target
config.json                — system configuration
kb.json                    — KB dotted path → compact file mapping
data/kb_raw/*.md           — 59 compact domain files (~3.5 MB)
src/
  root.zig                 — entry point, boot sequence, KB tree creation, data population
  vdr_types.zig            — all type definitions (~1900 lines)
  vdr_arena.zig            — arena create/destroy from page_allocator
  resetable_memory.zig     — scratch arena with reset and std.mem.Allocator vtable
  vdr_config.zig           — JSON config loading with strict validation
  vdr_kb_config.zig        — kb.json load/save, dotted path mapping
  vdr_compact_loader.zig   — .md compact file parser (tables, relations, mappings)
  vdr_gemm.zig             — single-block Q16 transformer (forward, backward, SGD, inference)
  vdr_http.zig             — HTTP listener, connection handling, response writing
  vdr_http_accepter.zig    — connection ring buffer, handler thread pool
  vdr_http_handler.zig     — route dispatch, runner submission
  vdr_runner_pool.zig      — per-core work rings, runner threads
  text_big.zig             — 100KB fixed-size text buffer with string operations
  text_small.zig           — 64-byte fixed-size text buffer with string operations
  time_deep.zig            — u64 millisecond timestamps, 100M year anchor
```

15 files. ~5,985 lines.

---

## Key Invariants

1. Remainder is never discarded. Every divTrunc captures its mod.
2. r0 and r1 are never padding. Both carry exact meaning.
3. Softmax sums to D (65536) exactly. Every time. Verified.
4. Comparison uses all three Q16 fields. No epsilon.
5. All multiplications widen to i64 before computing.
6. No float anywhere. Integer in, integer through, integer out.
7. r1 near saturation means escalate to Q32 for that path.
8. Session IDs (negative) never collide with global IDs (positive).
9. Session data dies with its session. Arena reset. Gone.
10. Arena exhaustion is never silent. Returns null.
11. All dynamic arrays use Managed on an arena allocator.
12. Q16 fromParts always takes three arguments (v, r0, r1).
13. VdrId structural bits are deterministic from tree position — no random component.
14. Data and data_q335 are direct-indexed: item_id IS the array index.

---

## License

MIT License.
