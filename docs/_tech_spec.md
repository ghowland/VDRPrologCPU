# VDR-Prolog Technical Specification

## CPU SIMD, Arena-Only, NUMA-Aligned, Compaction-Driven

### Version 0.5 — Laptop Target

---

## 1. Scope

This spec defines the complete VDR-Prolog system running on a single laptop. No GPU. No device/host split. All compute is CPU with AVX2 SIMD. All memory is fixed-size arenas allocated at startup. No malloc after init (one bounded exception: temporary training arenas, destroyed after use). Target: Dell Legion 5 (~2019), 6-8 core x86_64, 16-32GB RAM, AVX2. Zig 0.15.1.

The model is not a monolith. Model weights live in KBs alongside the domain data they serve. Access to weight KBs is grant-gated — different users see different model capabilities. Each LLM session gets a structured session KB subtree for context management, addressed with negative IDs that never collide with global data.

LLM-compacted data ingestion converts unstructured documents into typed facts, Prolog rules, and typed relations, stripping prose noise and preserving every named concept, relationship, and data point. Every typed relationship ingested is a reasoning operation the neural network does not need to learn. The compaction pipeline structurally reduces the required model size: 6 exact integer layers with narrow MLPs replace 16 drifting float layers because facts live in KBs, relationships fire as Prolog rules at L3, and exact remainder arithmetic eliminates drift correction layers.

Finite state machines track operational state. Each FSM state maps to a behavior set. Utility AI scoring evaluates candidate behaviors within the current state's behavior set, combining considerations via Dave Mark's compensated multiplication in exact Q16 arithmetic. The LLM is the judgment layer — it sees the mechanical results and can accept, override, or augment.

No floating point anywhere. Not in arithmetic, not in HTTP parsing, not in timing, not in logging, not in scoring curves. Every number in the system is an integer.

---

## 2. System Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                     SINGLE PROCESS                            │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │                Global Arena (NUMA node 0)                │  │
│  │  Seed KBs │ Domain KBs + Weights │ Typed Relations       │  │
│  │  Relation Indices │ Text Store │ Path Index               │  │
│  │  Grant Store │ Audit Ring │ Confidence Table              │  │
│  │  Compaction Profiles │ FSM Definitions │ Behavior Sets    │  │
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
│  │  LLM (SIMD) │ KB Store │ Prolog │ Typed Relations        │  │
│  │  Grammar │ Builtins │ Scoring │ FSM │ Ingestion           │  │
│  └─────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

One process. N+1 arenas (1 global + N per-core). Pinned compute threads do all SIMD work. Non-pinned HTTP threads handle I/O and push work to per-core atomic ring buffer queues. Direct function calls between engines. No IPC, no serialization bridge, no mutex on the hot path.

---

## 3. ID System — Sign-Bit Partitioned Dual Addressing

### 3.1 VdrId

Every entity has a 64-bit ID. Bit 63 partitions the address space: positive = global (persistent, shared), negative = session-local (ephemeral, dies with session). Zero = none/null sentinel.

```zig
pub const VdrId = struct {
    v: i64 = 0,
    pub fn isGlobal(self: VdrId) bool { return self.v >= 0; }
    pub fn isEphemeral(self: VdrId) bool { return self.v < 0; }
    pub fn isNone(self: VdrId) bool { return self.v == 0; }
    pub fn eql(a: VdrId, b: VdrId) bool { return a.v == b.v; }
};
```

### 3.2 Three Addressing Levels

**UUID** — signed i64, O(1) lookup table. Canonical identifier.

**Dotted path** — hierarchical walk from root. `root.science.physics.qed` for global, `session_root._llm.prompt_last` for session.

**Local index** — array slot within a KB. `facts[0]` within a specific KB.

Resolution order: session tree first (negative IDs), then global (positive IDs). Promotion from session to global is explicit — session data never leaks implicitly.

### 3.3 Client and Organization Tree

```
root
├── _organization.{org_uuid}.clients.{client_uuid}
├── _client.{client_uuid}.sessions.{session_uuid}
├── system (oso, confidence, builtins, command_vocab, hygiene,
│           embedding, output, relation_types, ingestion, scoring, fsm)
├── templates (sentences, formats)
├── knowledge (compacted document KBs)
└── (domain KBs with their own weights)
```

Sessions persist across HTTP disconnects. LRU ejects cold sessions from per-core arenas, snapshotting first. Restoration from snapshot on reconnection.

---

## 4. Core Data Types

### 4.1 Q16 — Primary Arithmetic Type

```zig
pub const Q16 = struct {
    v: i32 = 0,   // numerator (value / D)
    r0: i16 = 0,  // remainder level 0 — exact remainder from divTrunc
    r1: i16 = 0,  // remainder level 1 — sub-r0 precision from cross-terms
};
// D = 65536 (2^16). Implicit. Never stored. sizeof = 8 bytes.
```

Remainder is not error. It is exact unresolved structure. Every divTrunc captures its mod. Addition propagates r1→r0→v carry chain. Multiplication widens to i64, captures r0 from mod, r1 from cross-terms. Division is worse than multiplication for remainder — divisors not factoring into D push r1 toward saturation. Comparison is lexicographic across all three fields, no epsilon. r1 near ±32767 = escalate to Q32.

Q32 (D=2^32, 16 bytes) for Newton-Raphson and escalated computations. Q335 (D=2^335, 240 bytes, 4 remainder slots) for physics and transcendentals.

### 4.2 Fact and Provenance

```zig
pub const Fact = struct {
    tag: FactTag = .empty,       // value, text, reference, timestamp, enum, boolean,
                                  // vector, matrix, provenance, rule_ref, grammar_ref,
                                  // counter, relation, column_schema, empty
    value: Q16 = .{},
    provenance: Provenance = .{},
};
// 48 bytes, padded for alignment.

pub const Provenance = struct {
    source_type: i32,             // indexes confidence table (11 levels)
    source_kb_id: VdrId,
    source_slot_id: i32,
    confidence: Q16,              // from confidence table
    timestamp: i32,               // integer epoch seconds
    derivation_rule_id: i32,
    capability_level: i32,        // per-weight access control
};
```

Every Fact carries full provenance. TAG_MATRIX facts reference WeightMatrix via `value.v` as index. TAG_RELATION facts reference TypedRelation via `value.v` as index. TAG_COLUMN_SCHEMA marks column definitions in ingested table KBs.

### 4.3 KB — Knowledge Base

```zig
pub const KB = struct {
    // Identity: id, parent_id, name, path, walk_id
    // Persistent stores: facts, rules, constraints, connections, grammars, iose
    // Weight references: weight_refs_offset
    // Typed relations: relations_offset/count/capacity, relation_index_offset
    // Domain relation definitions: domain_rel_defs_offset/count
    // Compaction provenance: compaction_profile_offset
    // Live state: LRU, counters, locks, queues, stacks, rings, bitsets
    // FSM: fsm_offset (-1 if no state machine)
    // Behavior set: behavior_set_offset (-1 if no scoring)
    // New facts since training: offset/count
    // Children: offset/count/capacity, mounts
    // Training: training_lock (bool), training_arena (?*Arena — only nullable pointer)
    // Metadata: visibility, frozen, owner_id, timestamps, version
    // Functor index: functor_index_offset (-1 if not built)
};
// 256 bytes, cache-line aligned.
```

KBs form a tree. Each can hold facts, rules, weight matrices, grammars, typed relations, an FSM, a behavior set, and metadata. An FSM lives inside a KB the same way an LRU or queue does — it's a data structure the KB uses, not a type of KB. A behavior set lives inside a KB the same way — it's a scoreable set of candidate actions owned by that KB.

### 4.4 Prolog Types

```zig
pub const Term = struct {
    type: TermType,           // atom, variable, integer, vdr, text, list,
                               // compound, vector, matrix, pair
    primary_id: i32,
    secondary_offset: i32,
    secondary_aux: i32,
    vdr_value: Q16,
};
// 24 bytes.

pub const Rule = struct {
    id: VdrId, head: i32, body_offset: i32, body_count: i16,
    action_offset: i32, action_count: i16,
    fire_count: i32, last_fired: i32, success_count: i32, failure_count: i32,
    created_at: i32, creator_session_id: VdrId,
};
// 48 bytes. Rules carry their own statistics.
```

Unification: atom-atom by ID match, variable-anything binds, VDR-VDR all three Q16 fields match exactly, compound-compound functors match plus recursive argument unification. All integer. No epsilon.

### 4.5 Typed Relation System

```zig
pub const RelationType = enum(i16) {
    // System-defined (0-25): enables, requires, prevents, implements, extends,
    //   overrides, validates, verified_by, contradicts, causes, determined_by,
    //   depends_on, equivalent_to, approximates, specializes, generalizes,
    //   part_of, contains, follows, precedes, instance_of, scoped_to,
    //   flows_to, transforms_to, derived_from, composed_of
    // Domain-registerable (64-127): assigned during compaction ingestion
    // unknown = -1

    pub fn inverse(self: RelationType) RelationType { ... }
    pub fn isSymmetric(self: RelationType) bool { ... }
    pub fn isTransitive(self: RelationType) bool { ... }
};
```

Three compile-time properties generate all structural inference rules. `inverse()` returns the reverse edge type. `isTransitive()` identifies types where chains compose via BFS. `isSymmetric()` identifies bidirectional types.

```zig
pub const TypedRelation = struct {
    rel_type: RelationType,
    from_id: VdrId,
    to_id: VdrId,
    provenance: Provenance,
    strength: Q16,          // zero = binary, nonzero = weighted
    scope_kb_id: VdrId,
};
// 48 bytes. First-class typed edge between entities.

pub const RelationIndex = struct {
    by_type_counts: [128]i32,  // count per slot — O(1) type check
    // Plus sorted indices by_from and by_to
    total_relations: i32,
    last_rebuilt: i32,
};
// ~528 bytes. Eventually consistent — rebuilt periodically.
```

Domain-specific relation types registered via `DomainRelationDef` during compaction ingestion, assigned slots 64-127, with declared symmetric/transitive/inverse properties.

### 4.6 Weight Storage

```zig
pub const WeightMatrix = struct {
    v: []i32,    // contiguous, GEMM-ready, cache-line aligned, column-major
    r0: []i16,   // remainder level 0
    r1: []i16,   // remainder level 1
    rows: i32, cols: i32,
};
// Per param: 4(v) + 2(r0) + 2(r1) = 8 bytes.
```

Referenced via `KbWeightRefs` from KB's `weight_refs_offset`. Three-path retrieval: full fact scan (new KB), GEMM cache only (trained KB, hot path), cache + new facts (trained KB with additions since training).

### 4.7 FSM

```zig
pub const FsmType = enum(i8) { moore = 0, mealy = 1, dfa = 2, statechart = 3 };

pub const Fsm = struct {
    id: VdrId,
    fsm_type: FsmType,
    current_state: i32,          // atom ID — mutable, updated on transition
    previous_state: i32,
    initial_state: i32,
    states_offset: i32,          // state atom IDs in owning KB's fact array
    states_count: i16,
    transitions_kb_id: VdrId,    // child KB with evolves_to/2 rules
    outputs_kb_id: VdrId,        // child KB with state→behavior_set facts
    parent_fsm_id: VdrId,        // for statechart nesting
    children_offset: i32,        // concurrent region child FSM IDs
    children_count: i16,
    last_transition_time: i32,
    transition_count: i32,
    is_terminal: bool,
};
```

An FSM lives inside a KB via `kb.fsm_offset`, the same way an LRU or queue does. States are atoms. Transitions are Prolog rules in a child KB. State→BehaviorSet mappings are facts in another child KB. The FSM reads these — it does not own them.

### 4.8 Utility AI Scoring

```zig
pub const ResponseCurve = struct {
    curve_type: CurveType,  // linear, polynomial, logistic, gaussian, step,
                             // smoothstep, piecewise, etc. (14 types)
    param_a: Q16,           // slope/exponent/steepness
    param_b: Q16,           // intercept/midpoint/center
    param_c: Q16,           // width/decay rate
    inverted: bool,
    breakpoints_offset: i32, // for piecewise curves
    breakpoints_count: i16,
};

pub const Consideration = struct {
    input: InputSource,      // where to read (kb_fact, session_counter,
                              // relation_count, confidence, time_elapsed,
                              // arena_usage, builtin_result, constant,
                              // level_stats, resource_ratio)
    curve: ResponseCurve,
    weight: Q16,             // multiplier, D = no effect
    floor: Q16,              // minimum output score
    is_gate: bool,           // binary pass/fail, excluded from compensation
    last_score: Q16,         // scratch for debugging
    last_raw_input: Q16,
};

pub const Behavior = struct {
    id: VdrId,
    name_offset: i32, name_length: i16,
    action: BehaviorAction,          // what to do when selected
    considerations_offset: i32,
    considerations_count: i16,
    compensation: CompensationConfig, // default: Dave Mark compensated multiply
    weight: Q16,                      // behavior-level multiplier
    floor: Q16,                       // minimum score (idle uses this)
    selection_count: i64,
    last_selected: i32,
};

pub const BehaviorSet = struct {
    id: VdrId,
    behaviors_offset: i32,
    behaviors_count: i16,
    selection: SelectionMethod,    // argmax, weighted_random_top_n, boltzmann,
                                    // argmax_with_hysteresis, threshold_then_argmax
    top_n: i16,                    // for weighted random
    temperature: Q16,              // for boltzmann
    hysteresis_bonus: Q16,         // for argmax with hysteresis
    eligibility_threshold: Q16,    // for threshold gate
    current_behavior_id: VdrId,    // for hysteresis tracking
    owner_kb_id: VdrId,
    evaluation_count: i64,
    last_evaluated: i32,
};
```

`BehaviorAction` maps the winner to execution: Prolog query, builtin call, LLM command, KB assert, nested behavior set, rule fire, or grammar render.

All scoring is Q16. Dave Mark compensation: `modification_factor = (n-1)/n`, `make_up = (D - score) × mf / D`, `compensated = score + (make_up × score / D)`, `final = ∏(compensated_i)`. Epsilon floor (default v=655 ≈ 1%) prevents true-zero veto. Gate considerations evaluated separately — binary pass/fail, no compensation.

### 4.9 Session Types

Session struct tracks identity, core binding, resource limits (max_kb_count, max_ephemeral_kbs, max_facts_per_kb, max_live_memory_bytes, max_turns), counters for all operations, snapshot/clone lineage, atom-to-RelationType cache offset, and surface staleness tracking.

### 4.10 Confidence Table

```
vdr_computation=65536 (1/1), prolog_derivation=65536, database=64225 (98/100),
prometheus=62259 (95/100), script=62259, rest_api=55705 (85/100),
published=52428 (80/100), user_stated=45875 (70/100), web_search=32768 (50/100),
llm_generated=19660 (30/100), unknown=0 (0/1)
```

Chain rule: min(inputs). Parallel agreement: max(sources). Contradiction: zero. Ingestion combined: min(source_type, compaction_stage).

### 4.11 KbStore

```zig
pub const KbStore = struct {
    global_arena: *Arena,
    path_index_offset: i32,        // path hash → VdrId LUT
    loaded_lut_offset: i32,        // VdrId → *KB LUT
    loaded_count: i32,
    manifest_offset: i32,
    manifest_count: i32,
    next_global_id: i64,           // counter for new positive VdrIds
    atom_table_offset: i32,        // string → atom_id mapping
    atom_count: i32,
    text_store_offset: i32,        // shared text data
    text_store_cursor: i32,
    data_dir: [256]u8,             // persistence directory
};
```

Single instance, shared by all sessions. Owns all KB data and global arena organizational structure. Every engine holds a pointer to it.

---

## 5. Memory Architecture — Arenas Only

### 5.1 Arena Design

Fixed-size contiguous blocks from `std.heap.page_allocator`. Bump pointer only. No free. No reuse until reset. `ArenaSet` holds global + N per-core arenas. All dynamic arrays use `ArrayListManaged` on an arena.

### 5.2 Arena Layout

```
Global Arena (~1.27 GB for reduced model):
    Model weights v+r0+r1:  ~572 MB (143M params × 4 bytes v + 2×2 bytes r)
    Seed KBs:               ~2 MB
    KB store:               ~25 MB (100K × 256)
    Fact store:             ~480 MB (10M × 48)
    Typed relations:        ~50 MB (1M × 48)
    Relation indices:       ~10 MB
    Rules, terms, text:     ~93 MB
    Grants, audit:          ~33 MB
    Compaction profiles:    ~2 MB
    Confidence table:       88 bytes
    Total:                  ~1.27 GB

Per-Core Arena (~220 MB each):
    Sessions, session KBs, session facts, KV cache,
    scratch, bindings, render, work queue.

System total (8 cores): ~3.03 GB. Fits in 8 GB.
```

### 5.3 Arena Reset as GC

Session dies → arena region resets (cursor = 0). Instant. No traversal. Arena exhaustion returns error, never silent corruption.

### 5.4 Temporary Training Arenas

Single exception to no-allocation-after-init. `canTrain` checks headroom and lock. `train` allocates sized to KB, runs on pinned thread, writes back weights, destroys arena, nulls pointer, releases lock. All code paths clean up.

---

## 6. HTTP Interface

### 6.1 Architecture

One non-pinned listener thread (port from config, default 1138). Spawns non-pinned handler threads per connection. Handlers parse JSON, resolve client/session, push to per-core atomic ring buffer, spin-wait on completion, send response. Lock-free ring buffer, no mutex. Queue full = HTTP 503.

### 6.2 Session Lifecycle

Sessions persist across HTTP disconnects. Creation clones from template (COW) with canonical `_llm.*` subtree. Reconnection resolves `root._client.{uuid}.sessions.{uuid}` — if in RAM, route to core; if ejected, restore from snapshot. LRU ejects coldest on per-core limit, snapshotting first.

### 6.3 Separation Rule

Pinned threads only compute. HTTP threads only I/O. Work queue is the only bridge.

---

## 7. Compute Model — CPU SIMD

### 7.1 GEMM — Per-Thread, No Coordination

Each pinned thread executes complete GEMM independently. No row splitting, no barrier, no cross-thread coordination. i64 accumulation. divTrunc by D at end with remainder captured. Column-major weight layout for stride-free dot products.

```
d_model=2048, n_layers=6, n_heads=12, d_head=170, mlp_dim=2048, vocab=8192

Per layer: ~21M MACs. 6 layers: ~126M MACs per token.
Single core at AVX2 (~24 GMAC/s): ~5.3ms → ~190 tok/s.
8 cores: 8 × ~190 = ~1520 tok/s system throughput.
```

### 7.2 Softmax — Exact Unity

Integer exp, integer division, per-element remainder tracked, deficit assigned to largest-remainder element via FRU. Sum equals exactly D=65536. Every time. Deterministic.

### 7.3 RMSNorm, Attention, SiLU

Integer RMSNorm via Newton-Raphson (4 iterations in i64). Per-head attention with exact softmax. Integer piecewise SiLU approximation. All SIMD on v fields, scalar post-pass for r0/r1 where needed.

---

## 8. Model Weights as KB Data

### 8.1 Weights Live Where They Serve

No separate model tree. Domain KBs carry weights alongside facts and rules. System embedding and output are normal global KBs with grants. Effective model = union of all accessible weight KBs.

### 8.2 Three-Path Weight Retrieval

Path 1: full fact scan (new KB). Path 2: GEMM cache only (trained, hot path). Path 3: cache + new facts scan (trained with additions). Per-group GEMM caches for access tiers. Capability tokens in provenance for per-weight granularity.

### 8.3 Weight Format

i16 weights in SoA layout. 2 bytes per param for v, plus 2 bytes r0, 2 bytes r1. Reduced model: ~143M params, ~286 MB v data, ~572 MB total with remainders.

---

## 9. Compaction-Driven Data Ingestion

### 9.1 Pipeline

External LLM compresses raw documents into pipe-delimited tables (75-93% smaller, pure signal). Ingestion pipeline: validate → create KBs → assert facts (text→TAG_TEXT, numeric→TAG_VALUE, column schema→TAG_COLUMN_SCHEMA) → assert relationships as TypedRelation structs + Prolog rules → register domain relation types → record CompactionProfile → freeze.

### 9.2 How Compaction Reduces the Model

Every typed relation replaces a reasoning path the neural network doesn't need. MLP shrinks (facts in KBs), layers drop (multi-hop is Prolog transitive closure), heads reduce (relations are enum dispatch), vocab shrinks (grammar rendering replaces token generation). Exact arithmetic eliminates correction layers. Six exact layers carry the fidelity of twelve float layers.

### 9.3 Signal Density

50-page paper → ~5 KB compacted → ~40 typed relations, ~200 facts, ~40 Prolog rules. Storage: ~20 KB. 50 documents → ~2000 relations across 15+ types → RelationIndex handles most structural queries at L3.

---

## 10. Prolog Engine

### 10.1 Query Dispatch — Priority Chain

Every query passes through a priority chain, each level faster than the next, short-circuiting at first success:

1. **Typed relation fast path.** Functor matches RelationType enum → RelationIndex scan. Integer comparison on struct fields. Sub-microsecond.
2. **Transitive closure.** BFS over contiguous integer arrays for transitive types. Zero tokens.
3. **Inverse lookup.** Rewrite `depends_on(X, target)` to `enables(target, X)`. One index serves both directions.
4. **Symmetric swap.** Auto-query with from/to swapped for symmetric types.
5. **Structural inheritance.** Collect ancestors via `specializes`/`instance_of` transitive closure, scan inherited `requires`/`prevents`/`contains`.
6. **General Prolog.** Full unification with depth-first search, explicit backtracking stack in per-core scratch.

### 10.2 PrologEngine

```zig
pub const PrologEngine = struct {
    store: *KbStore,
    scratch: *Arena,
    session: *Session,
    global_arena: *Arena,
    atom_rel_cache: *AtomRelTypeCache,
    level_stats: *LevelStats,
    config: PrologConfig,
};
```

One per session. Holds no mutable state between queries. All per-query state in scratch arena, freed implicitly.

### 10.3 Fire and Commit

Scans rules against facts, fires satisfied rules, asserts derived facts with `prolog_derivation` confidence (1/1). Returns count of rules fired. This is the L3 mechanism for automatic knowledge derivation.

### 10.4 Domain-Agnostic Core Rules

Generated from RelationType properties. No domain document adds structural rules — it adds only facts:

- Taxonomy: `specializes` transitive closure, `instance_of` inheritance of `requires`/`prevents`/`contains`
- Containment: `contains`/`part_of` transitive closure, mutual inverse
- Enablement: `enables` transitive closure, `depends_on` inverse
- Requirement: `requires` transitive closure, inheritance through `extends`
- Symmetry: auto-swap for `prevents`, `contradicts`, `equivalent_to`, `approximates`
- Inverse: all 10+ pairs dispatch automatically
- Sequence: `follows`/`precedes` transitive closure, mutual inverse
- Scope: `scoped_to` transitive through `part_of`

### 10.5 Cross-Document Composition

Documents connect through shared RelationType edges. Structural rules fire identically across document boundaries. The engine sees VdrIds and RelationType — no document boundary. Bridge documents (English, Connections, Movement, Math Logic, Math Foundations) create a lattice where any two domains connect through at most two hops.

---

## 11. Unified Decision Pipeline

### 11.1 The Full Cycle

```
1. User input arrives. System writes to prompt_input.

2. Pre-resolution:
   a. Classify query pattern (keyword scan, not LLM).
   b. Attempt L3: typed relation query / Prolog rule fire.
   c. Log result to prompt_current, increment items_total.

3. FSM evaluation:
   a. Check transition rules for all active FSMs.
   b. If transition fires: update state, log to prompt_current.
   c. Resolve current behavior set from current state.

4. UAI scoring:
   a. Build ScoringContext from session state.
   b. Evaluate behavior set: gate checks → soft consideration scoring
      → Dave Mark compensated multiplication → selection.
   c. Log scores and winner to prompt_current.

5. Execution:
   a. Pre-resolution answered completely → LLM frames (~20 tokens).
   b. UAI winner has action → execute, LLM frames.
   c. UAI winner is defer_to_llm or score below threshold → L1.

6. LLM generation:
   a. Read prompt_last (continuity) + prompt_current (new items).
   b. Accept, override, or augment mechanical results.
   c. Write to prompt_next for continuity.
   d. Update items_seen_by_llm counter.

7. Post-generation:
   a. Re-evaluate FSM transitions (generation may have changed context).
   b. Copy prompt_next → prompt_last. Clear transients.
   c. Counters reset to 0.
```

### 11.2 Execution Levels

```
L3 (zero LLM tokens): typed relation query, transitive closure, inverse,
    FSM transition fire, UAI scoring, rule fire.
    → LLM frames result (~20 tokens). 93% of ops at maturity.

L2 (~18 tokens): LLM selects from candidates, emits command, Prolog executes.
    → ~38 tokens total. ~3% of L1 cost.

L1 (50-500 tokens): full forward pass. Novel queries, ambiguity, judgment.
```

### 11.3 Attention Counter

```
prompt_current.items_seen_by_llm: i32 — LLM updates after reading
prompt_current.items_total: i32        — system increments on each log
Unread count = items_total - items_seen_by_llm
Reset to 0 when prompt_current cleared at cycle boundary.
```

---

## 12. Attention, Context, and Session LLM Tree

### 12.1 No Fixed Attention Window

The LLM's attention is the session KB tree — structured, addressable, unlimited. Reads specific facts from specific KB addresses.

### 12.2 Canonical `_llm.*` Subtree

Fixed structure. No new top-level KBs here. Data goes inside as children.

```
session_root._llm.prompt_last      — continuity from previous cycle
session_root._llm.prompt_next      — what to carry forward
session_root._llm.prompt_input     — current user request (system writes)
session_root._llm.prompt_current   — working scratch + logged results (cleared each cycle)
session_root._llm.history          — bounded queue of cycle history
session_root._llm.projects         — project tracking
session_root._llm.people           — people tracking per context
session_root._llm.concepts         — topic relationships + availability surface
session_root._llm.search           — search results and background
session_root._llm.scratchpad       — persistent cross-prompt scratch
```

### 12.3 Session Resource Limits

At limit, LLM cannot create new KBs or assert. Can still: read, fire rules, pump bounded structures, do inference, retract to make room.

---

## 13. Live Training

`canTrain` checks headroom and lock. `train` allocates temporary arena (gradients with r0/r1, optimizer state, activations, transposed weights, scratch). Forward from global arena, backward from temp arena, update writes back to global. Per-fact provenance updated: `source_type=vdr_computation`, timestamp, rule ID. GEMM cache marked dirty. New-facts list cleared. Cleanup destroys arena, nulls pointer, releases lock.

---

## 14. Persistence and Lazy Loading

### 14.1 Save Format

Raw byte slices of structs. KB files (.kb): header + KB struct + facts + rules + terms + children + text + weight_refs + relations + RelationIndex + new-facts + CompactionProfile. Weight files (.wt): header + v/r0/r1 SoA arrays. CRC32 on every file. Manifest (.dat): index of all persisted KBs.

### 14.2 Lazy Loading

At startup, only manifest + seed KBs loaded. All others load on first access. Unaccessed KBs = zero arena memory, zero I/O. Weights load separately from KB data on first GEMM need.

### 14.3 Version Mismatch

File headers store struct sizes. Mismatch → reject, run `vdr-convert`. No in-process migration.

---

## 15. Seed Layer

```
root                          id: +1
├── system                    id: +2
│   ├── oso                   id: +3     (15 engineering principles)
│   ├── confidence            id: +4     (confidence table)
│   ├── builtins              id: +5     (448 IOSE declarations, 24 categories)
│   ├── command_vocab         id: +6     (~300 command tokens)
│   ├── hygiene               id: +7     (self-maintenance rules)
│   ├── embedding             id: +8     (vocab embedding weights 8192×2048)
│   ├── output                id: +9     (lm_head + final norm weights)
│   ├── relation_types        id: +13    (system + domain relation registry)
│   ├── ingestion             id: +14    (queue + CompactionProfile records)
│   ├── scoring               id: +15    (system behavior sets)
│   └── fsm                   id: +16    (system FSM definitions)
├── templates                 id: +10
│   ├── sentences             id: +11    (~100 sentence grammars)
│   └── formats               id: +12    (~50 output format grammars)
└── (domain KBs, knowledge KBs, domain weight KBs)

16 seed KBs. System KBs frozen after init (relation_types appendable for domain range).
```

---

## 16. Configuration

JSON loaded at startup via `std.json`. Hard-mapped — unknown fields error, missing required fields error. No silent defaults. Single source of truth.

Key fields: `n_cores`, `model` (ModelConfig), `model_reduction` (ModelReductionConfig — advisory), `global_arena_bytes`, `per_core_arena_bytes`, all limits, `http_port`, `ingestion` (IngestionConfig), `relation_index_rebuild_interval`, session/runner/sampling/prolog/context configs.

ModelReductionConfig: base architecture (16 layers/5632 MLP/16 heads/32K vocab) vs. reduced (6/2048/12/8K). Compaction metrics (relation_types_covered, total_typed_relations, estimated_l3_coverage). Admin sets architecture, system computes estimates.

---

## 17. Performance Estimates

```
Reduced model: ~143M params, ~286 MB i16 weights, ~126M MACs/token.
Single core: ~190 tok/s. 8 cores: ~1520 tok/s.
With 93% L3: ~1520/0.07 ≈ ~21,700 effective requests/second.
System memory: ~3.03 GB total. Fits in 8 GB.
```

---

## 18. Error Handling

Deterministic recovery tree. 40+ error codes across 10 categories (arithmetic, KB, prolog, grammar, session, grant, runner, memory, system). Every arena allocation returns null on exhaustion. Recovery actions: compact, log, simplify, retry, deny, reconnect, recycle, kill oldest clone, restore from snapshot.

---

## 19. Invariants

```
 1. Remainder never discarded. Every divTrunc captures its mod.
 2. r0 and r1 carry exact meaning. Never padding.
 3. Softmax sums to D exactly. Every time.
 4. Comparison uses all three Q16 fields. No epsilon.
 5. All multiplications widen to i64.
 6. No float anywhere.
 7. r1 near ±32767 = escalate to Q32.
 8. Session IDs (negative) never collide with global (positive).
 9. Session data dies with session. Arena reset.
10. Arena exhaustion never silent.
11. SIMD and scalar produce bit-identical results.
12. Temporary training arenas are the only post-startup allocation.
13. _llm.* canonical subtree structure is fixed.
14. All dynamic arrays use ArrayListManaged on arena.
15. fromParts always takes three arguments (v, r0, r1).
16. RelationType slots 0-25 system-defined and frozen.
17. Domain relation slots 64-127 first-come, never reassigned.
18. Every TypedRelation has a TAG_RELATION Fact for provenance.
19. RelationIndex eventually consistent — rebuilt periodically.
20. Typed relation queries bypass general Prolog unification.
21. Model reduction config is advisory.
22. Compaction profiles immutable after ingestion.
23. GEMM per-thread, no cross-core coordination.
24. KBs lazy-load from manifest. Unaccessed = zero memory.
25. FSM current_state always valid atom in machine's state set.
26. FSM transitions fire only from current state.
27. Every FSM state maps to exactly one behavior set (or none for terminal).
28. UAI scoring never produces NaN or infinity — Q16 prevents structurally.
29. Dave Mark compensation (1-1/n) computed in Q16 with exact remainder.
30. Gate considerations do not participate in compensation.
31. items_seen_by_llm never exceeds items_total.
32. prompt_current counters reset to 0 when cleared at cycle boundary.
33. Session-local FSMs die with session. States do not leak to global.
34. Transition evaluation and UAI scoring run on pinned compute thread.
35. BehaviorSet evaluation deterministic for argmax. Weighted random uses session PRNG.
```

---

## 20. Zig 0.15.1 Specifics

`std.debug.print` for output. `.root_module = b.createModule(...)` for build. Integer timestamps only. x86_64 only. All persistent types in `vdr_types.zig`. Ingestion parse-time types in `vdr_ingestion.zig`.

---

## 21. Build Order

Strict bottom-up. Each step compiles and exits clean before next.

1. Kernel boot + arena memory.
2. Config loader (JSON, strict errors).
3. Arena set from config (global + N per-core).
4. NUMA-pinned threads (spawn, pin, first-touch, spin-wait).
5. HTTP listener (non-pinned, port from config).
6. HTTP-to-NUMA work passing (atomic ring buffers).

Everything after builds on this kernel.

---

## 22. Implementation Stages

```
Stage 1: Foundation (~5,000 lines)
    vdr_types, vdr_arena, vdr_config, vdr_thread_pool,
    vdr_http, vdr_work_queue, vdr_kb_store, vdr_access
    vdr_ops (scalar only). Basic session with _llm.* subtree.

Stage 2: Intelligence (~6,000 lines)
    vdr_prolog, vdr_grammar, vdr_builtin, vdr_session,
    vdr_grant, vdr_audit, vdr_confidence, vdr_command.

Stage 3: Compute (~4,000 lines)
    vdr_ops (AVX2), vdr_model, vdr_inference.

Stage 4: Ingestion + Relations (~3,000 lines)
    vdr_ingestion, vdr_relation.

Stage 4b: Scoring + FSM (~3,000 lines)
    vdr_scoring, vdr_fsm.

Stage 5: Training + Operations (~4,000 lines)
    vdr_training, vdr_runner, vdr_seed, vdr_system.

Stage 6: Persistence (~2,000 lines)
    vdr_persist, vdr_snapshot.

Stage 7: Testing (~1,000 lines)
    vdr_test.

Total: ~28,000 lines.
```

---

## 23. Implementation Files

```
vdr_types.zig         — all persistent structs, enums, constants, KbStore
vdr_ingestion.zig     — parse-time structs, parser, validator
vdr_arena.zig         — arena allocator, ArenaSet
vdr_config.zig        — JSON config loading
vdr_thread_pool.zig   — pinned threads, lifecycle
vdr_work_queue.zig    — per-core atomic ring buffer
vdr_http.zig          — non-pinned HTTP listener and handlers
vdr_ops.zig           — SIMD: gemm, dot, softmax, rmsnorm, attention, silu
vdr_model.zig         — KB-distributed weights, three-path retrieval
vdr_kb_store.zig      — KB CRUD, path index, session resolution
vdr_relation.zig      — RelationIndex, typed queries, transitive closure, inverse
vdr_prolog.zig        — unification, query, backtracking, fire_and_commit
vdr_grammar.zig       — template compile, render, inherit
vdr_session.zig       — session lifecycle, _llm.* subtree, clone/merge/kill
vdr_persist.zig       — save/load KB/weight files, manifest, lazy loading
vdr_snapshot.zig      — session snapshots, CRC32
vdr_training.zig      — canTrain, train, temporary arenas, weight update
vdr_runner.zig        — poller, processor, internal, batch
vdr_inference.zig     — full inference loop, prompt cycle, L1/L2/L3
vdr_command.zig       — command parser, executor, dispatch
vdr_access.zig        — visibility, session/global resolution, per-group weight access
vdr_grant.zig         — grant CRUD, check, cleanup
vdr_audit.zig         — ring buffer, query, filter
vdr_confidence.zig    — assign, combine, chain, propagate
vdr_seed.zig          — seed layer init, domain weight KB creation
vdr_builtin.zig       — 448 builtins, 24 categories, IOSE validation
vdr_system.zig        — top-level init, wire everything
vdr_scoring.zig       — response curves, compensation, behavior selection, scoring builtins
vdr_fsm.zig           — FSM state management, transition evaluation, FSM builtins
vdr_test.zig          — full test suite
build.zig             — single native x86_64 target

31 files. ~28K lines estimated.
```

---

# VDR-PROLOG SPECIFICATION ADDENDUM v0.5 — SESSION DESIGN EXTENSIONS

## Preface

This document extends the VDR-Prolog Technical Specification v0.5 with design additions developed through iterative analysis. It assumes the reader has access to the v0.5 spec and the vdr_types.zig compacted type definitions. All additions preserve existing invariants (IN1-IN35) and add new ones (IN36-IN47). All additions operate within the existing arena-only memory model, integer-only arithmetic, and grant-gated security architecture. References to existing spec elements use the established ID prefix system (PR=principle, DT=data type, IS=id system, etc.).

---

## 1. Structural UUID (VdrId Bit Layout Redesign)

### 1.1 Motivation

The v0.5 VdrId is an opaque signed i64 with sign-bit partitioning (IS1: positive=global, negative=session). Lookup requires either a global loaded LUT (KbStore.loaded_lut) or a dotted-path walk from root. Both work but neither exploits the tree structure of the KB hierarchy. As the system scales to millions of facts across thousands of KBs, a self-describing address that encodes tree position in its bits enables navigation by bit extraction rather than hash lookup or sequential walk.

### 1.2 Bit Layout

The 64-bit VdrId decomposes as a Zig packed struct:

```
Bit 63:      sign (u1)     — 0=global/persistent, 1=session/ephemeral
Bits 62-55:  level_1 (u8)  — index into root's children array (256 max)
Bits 54-45:  level_2 (u10) — index into L1 KB's children (1024 max)
Bits 44-35:  level_3 (u10) — index into L2 KB's children (1024 max)
Bits 34-25:  level_4 (u10) — index into L3 KB's children (1024 max)
Bits 24-20:  remaining_depth (u5) — additional levels below L4 (0-31)
Bits 19-0:   random (u20)  — collision-resistant disambiguator
```

Total: 1 + 8 + 10 + 10 + 10 + 5 + 20 = 64 bits. The packed struct converts to and from i64 via `@bitCast` at zero runtime cost. The sentinel value for unused levels is `std.math.maxInt(u10)` (1023), meaning level slots are consumed only as needed — a depth-2 entity sets level_3 and level_4 to 1023, and the tree walk short-circuits on encountering a sentinel.

### 1.3 Construction

Creating a structural VdrId follows a fixed procedure: determine the entity's tree path, encode level_1 through level_4 from the path's indices at each depth, compute remaining_depth as max(0, total_depth - 4), generate a random 20-bit value, test for collision against existing IDs in the target KB's UUID map, and regenerate on collision. Birthday paradox collision probability for a typical L4 KB population of 1000 entities is approximately 0.05%, making regeneration rare.

### 1.4 Capabilities

The structural encoding enables four operations that the opaque i64 cannot perform without data structure access:

**Tree navigation by bit extraction.** Reading level_1 through level_4 yields array indices for direct children-array access at each tree level. Four array dereferences navigate to any KB within four levels of root, without hash computation or path string parsing.

**Subtree membership testing.** Two VdrIds sharing a prefix (after masking to the desired depth) are in the same subtree. This is a single AND plus CMP — one CPU instruction pair replacing a full tree traversal. The prefix mask for L1+L2 scope is 0x7FFC000000000000.

**GEMM scope narrowing.** Extracting L1+L2 bits from query VdrIds determines which per-KB GEMM caches are relevant before any weight data is touched. One AND and one CMP per cache eliminates irrelevant domain subtrees from the forward sweep.

**Query cost estimation.** The remaining_depth field indicates how deep below the fourth encoded level an entity lives. The pre-resolution pipeline can estimate traversal cost before executing, enabling informed decisions about whether to attempt L3 resolution or defer to L1.

### 1.5 Reparenting Constraint

Structural VdrId bits must match the entity's actual tree position. Reparenting a KB requires recomputation of its VdrId and all descendant VdrIds. This is intentionally expensive — reparenting is architecturally rare because KBs are typically frozen after ingestion and session KBs are ephemeral. The cost enforces tree stability as a structural property.

---

## 2. Two-Tier Lookup System

### 2.1 Per-KB UUID Map

Every KB carries an `AutoHashMap(i64, u32)` mapping full VdrIds to local fact slot indices within that KB. The map key is the complete 64-bit VdrId. The map value is a u32 slot index into the KB's fact array, so `kb.facts[slot_index]` yields the Fact struct directly.

The map is populated during ingestion or fact assertion. On fact retraction, the corresponding entry is removed. The map is serialized as part of the KB's persistence format: a count (i32) followed by key-value pairs (i64 + u32). On load, the map is pre-allocated via `ensureTotalCapacity` and populated via `putAssumeCapacity` — one hash computation and one array write per entry. The map lives in the KB's arena allocation, meaning it incurs no heap fragmentation, vanishes on session arena reset, and is captured in session snapshots.

The critical property is that map size is proportional to KB population, not system population. A KB with 200 facts has a 200-entry map. A system with 2 million facts across 12,750 KBs has 12,750 small maps, not one giant map. Hash lookup performance stays constant regardless of system scale.

For entities deeper than four encoded levels (remaining_depth > 0), the L4 KB's UUID map contains entries for all entities in its entire subtree. This makes the L4 map larger for deep hierarchies but the four preceding levels were navigated by array access at nanosecond cost, so the hash lookup is only for the residual depth.

### 2.2 Global Hot Cache

A single `AutoHashMap(i64, *anyopaque)` at the KbStore level with a fixed capacity of approximately 256 entries. The 16 seed KBs (SD1-SD16) are pre-populated at startup. Additional entries are promoted when a KB's access counter crosses a configurable threshold. When the cache reaches capacity, the least recently accessed entry is evicted.

The global hot cache adapts to workload patterns without configuration. A system primarily handling Python queries promotes python-subtree KBs. A system handling Japanese translation promotes language KBs. Workload shift causes LRU eviction of cold entries and promotion of newly hot ones.

### 2.3 Lookup Sequence

For any VdrId resolution:

1. Check global hot cache. On hit, return pointer immediately (10-50 nanoseconds).
2. On miss, bitcast to StructuralId packed struct. Read sign bit to select global or session arena.
3. Walk tree: `root.children[level_1]`, then `.children[level_2]` if not sentinel, then `.children[level_3]` if not sentinel, then `.children[level_4]` if not sentinel. Each step is one array access (approximately 5 nanoseconds each).
4. At the target KB, call `uuid_map.get(full_vdr_id)` to retrieve slot index (30-50 nanoseconds for a typical KB-sized map).
5. Access `kb.facts[slot_index]` (direct array access).

Total: 50-200 nanoseconds for the common case. All sub-microsecond. All without touching the system-wide loaded LUT.

### 2.4 Disambiguation Map

A separate `AutoHashMap(i64, []VdrId)` at the KbStore level maps atom IDs to all entities sharing that name across the KB tree. When the prompt input pipeline encounters a token like "list" that resolves to multiple entities (Python list type, English verb, data structure concept, HTML element), the disambiguation map provides the complete candidate set.

Domain filtering narrows the candidate set based on session context and availability surface. Surviving candidates determine the GEMM scope — their KB subtree prefixes are collected, and all GEMM caches matching any surviving prefix are included in the forward sweep. This enables multi-domain GEMM scoping: a query touching both Python and data structures gets weights from both subtrees, not just one.

The disambiguation map is built from the atom table at startup, updated on ingestion. Cost is one hash lookup per input token to get the candidate list, then one prefix mask check per candidate for domain filtering.

---

## 3. Prompt Input Pipeline

### 3.1 Overview

The prompt input pipeline transforms raw user text into structured UUID-addressed facts before the LLM executes its forward pass. By the time the LLM sees the input, it is not reading English — it is reading a sequence of VdrIds encoding what the user said as references into the knowledge graph. This eliminates natural language understanding from the LLM's workload, which is a significant fraction of what layers 1-4 do in a conventional transformer.

### 3.2 Content Detection Pass (Stage 0)

Before word-level tokenization, pattern matchers scan the raw input bytes for embedded structured content. These are deterministic builtins in the text_ops category (EN18, BuiltinCategory=0), pure per IoSe declaration, requiring no grants.

Matchers detect: JSON (valid → parsed to native terms; invalid → tagged as `.json_broken` and preserved as text with error annotation), YAML, code blocks (by fence markers or indentation with language-characteristic patterns), CSV/TSV, and XML/HTML. Each matcher produces a segment boundary. The raw input becomes a typed segment array:

```
segments[0] = {type=.prose, content=...}
segments[1] = {type=.json, content=parsed_native_terms}
segments[2] = {type=.prose, content=...}
```

JSON parsed to native terms means the values become Term structs directly: integers as `type=.integer` with `primary_id` holding the value, strings as `type=.text` with offset/length into text store, and floating-point values converted to Q16 with exact remainder capture. No float is ever stored — `0.12` becomes `Q16{v=7864, r0=33, r1=0}` (0.12 × 65536 = 7864.32, remainder preserved).

Broken structured content is never silently dropped. A malformed JSON block becomes a segment with `type=.json_broken`, the raw text preserved, and an error annotation describing the parse failure. The LLM sees this annotation in prompt_current and can mention it in its response.

Attachments accompanying the HTTP request are processed similarly. Each attachment gets metadata extracted (filename, MIME type, size, validity) as facts, then content-type-appropriate matchers parse the payload. Parsed attachment content joins the segment array after the user's text input.

Matchers are enabled per-session via configuration facts. A session processing raw user chat doesn't need code pattern matching. A session ingesting source code does. Disabled matchers cost zero.

### 3.3 Code Pattern Matching (Stage 0.5)

Code segments receive structural pattern matching via Prolog-integrated grammar matching. Each line of code matches against pattern rules in the programming KBs:

```prolog
matches(Line, assignment_pattern(VarName, list_literal(Elements))) :-
    has_operator(Line, '='),
    rhs_is_list(Line, Elements),
    lhs_is_identifier(Line, VarName).
```

Pattern matching is bidirectional. Every `matches` rule has a corresponding `generates` rule that produces the code from the same structural description:

```prolog
generates(assignment_pattern(VarName, list_literal(Elements)), Line) :-
    render_identifier(VarName, VarText),
    render_list(Elements, ListText),
    concat(VarText, " = ", ListText, Line).
```

The structural pivot (e.g., `assignment_pattern(VarName, list_literal(Elements))`) is a UUID regardless of direction. Parsing produces it. Generation consumes it. Round-trip fidelity is testable: `matches(Line, P), generates(P, Out), Line == Out`.

Patterns are composable. A for-each loop containing a function call and a conditional guard decomposes into nested patterns, each with its own `matches`/`generates` pair. The nesting structure is captured as typed relations between pattern VdrIds:

```
fact(tag=.relation, value=VdrId(iteration.contains.function_call))
fact(tag=.relation, value=VdrId(iteration.contains.conditional_guard))
fact(tag=.relation, value=VdrId(conditional_guard.contains.logging_call))
```

Patterns are cross-language. The structural pivot `for_each(ItemVar, Collection, Body)` is the same UUID whether parsing Python or generating Zig. Language-specific `generates` rules produce the appropriate surface syntax. Code translation is typed relation traversal: parse source language → get structural UUIDs → generate target language.

### 3.4 Tokenization (Stage 1)

Prose segments tokenize on whitespace and punctuation boundaries, producing candidate tokens for atom table lookup.

### 3.5 Spell Correction (Stage 2)

Each candidate token checks against the atom table. Correction aggressiveness is controlled by a client session property on a continuous scale:

- "off": no corrections under any circumstances
- "max only": correct only when exactly one candidate exists at edit distance 1 with zero ambiguity
- Lower settings: progressively allow fuzzier matching

Context modifies correction decisions. Tokens inside quotation marks are never corrected (the misspelling may be intentional). Tokens with multiple equidistant candidates are left uncorrected and flagged as ambiguous. Tokens with no close match at any distance are left as raw text terms with `resolved=false`.

Correction confidence feeds into the fact's provenance. A corrected token receives `user_stated` confidence (CF8: 45875, 70%) minus a penalty proportional to edit distance. An exact match receives full CF8 confidence.

### 3.6 UUID Resolution (Stage 3)

Accepted tokens resolve against the KB tree through the disambiguation map. Each token may match multiple entities across different domains. The availability surface filters candidates to entities accessible by the current session's grants.

### 3.7 Disambiguation (Stage 4)

Multiple resolution candidates per token are narrowed through typed relation co-occurrence. Tokens co-occurring in the input are checked for connecting relations in the KB graph. "list" plus "files" activates the filesystem domain because typed relations connect them through directory listing concepts. "order" in the presence of "list" and "files" activates sorting rather than purchasing because the relation paths between file listing and sorting are stronger.

A domain anchor is the most unambiguous token in the input — one that resolves to a single entity or a small set within one domain. Other tokens filter against the anchor. "pathlib" resolves only within `root.programming.python.library`, anchoring the entire query to Python. "list" then filters: Python list type survives, HTML list element drops.

All disambiguation is L3 — typed relation queries and relation index scans, no LLM involvement.

### 3.8 Assertion to prompt_current (Stage 5)

The resolved interpretation becomes facts in `session_root._llm.prompt_current`:

- Each resolved token: `fact(tag=.reference, value=VdrId(...), confidence=CF8)`
- Structural annotations from grammar KB: sentence pattern, speech act
- GEMM scope markers: `fact(tag=.vector, value=VdrId(gemm_scope.subtree))`
- Unresolved tokens: `fact(tag=.text, value="...", resolved=false)`
- Original raw text: `fact(tag=.text, value="full original input")`

Unresolved tokens are never silently dropped. They remain as flagged text facts. If the causal chain derivation cannot incorporate an unresolved token, the system reports the gap explicitly and requests clarification rather than fabricating a meaning.

---

## 4. LLM as UUID Predictor

### 4.1 Core Identity

The LLM in VDR-Prolog does not generate text. It predicts the next UUID in a sequence from a vocabulary of 8,192 structural addresses. The forward pass sees a sequence of i64 values — command tokens, KB addresses, argument values, template references. The embedding layer maps each to a learned vector. The attention layers predict which i64 comes next. The output layer selects via exact softmax (sum = D = 65536, enforced by FRU per IN3).

The LLM is indifferent to the semantic meaning of its output. It does not distinguish between emitting the UUID for `kb_query` (reads facts), `op_execute` (launches a process), `grammar_render` (formats text), or a greeting template reference. They are all i64 values processed through the same GEMM, attention, and softmax. The difference in consequence exists entirely outside the LLM — in the grant system, the execution engine, and the KB tree.

### 4.2 Security Implications

The grant system enforces what UUIDs are allowed to execute. The LLM can predict `op_execute` with maximum softmax probability — without an active grant of class `execute` (EN7: GrantClass), the builtin engine returns `grant_denied` (ER6: error code 600) and the audit engine logs the attempt. Security is structural, not behavioral. The system does not instruct the LLM to avoid dangerous operations. It prevents the operations from executing regardless of what the LLM predicts.

### 4.3 Scratchpad as UUID Sequence

The scratchpad (`session_root._llm.scratchpad`) stores cross-turn notes as VdrId reference facts, not text. Each "note" is a fact with `tag=.reference` pointing to a structural address in the KB tree. On subsequent turns, the LLM reads these VdrIds — compact i64 values encoding what the user wants, which tools apply, and how they connect — rather than re-reading paragraphs of text context. The pre-resolution pipeline can follow these addresses, check for changes (KB modification timestamps), and present updated state before the LLM runs.

Four VdrId reference facts (32 bytes of payload) encode cross-turn context that would consume thousands of tokens in a CLLM's context window.

### 4.4 Computational Identity

VDR-Prolog is not a chatbot. It is a UUID matching and execution engine. Every operation — asserting a fact, retracting a fact, firing a rule, transitioning an FSM, scoring a behavior, rendering a grammar template, launching a process, correcting an error — is a KB operation on structural addresses.

A correction is not a conversational act. It is a retract of the incorrect fact followed by an assert of the correct fact. The provenance chain updates. The confidence reflects the new source. Every future query that touches the corrected entity gets the right answer. No apology. No performative acknowledgment. Two KB operations.

The system produces no ceremony because ceremony is not a KB operation. Every token of output traces to a UUID, every UUID traces to a fact, every fact traces to a provenance source.

---

## 5. Causal Chain Derivation

### 5.1 Mechanism

Before the LLM runs its forward pass, the Prolog engine composes typed relations into solution paths. The relation types involved are primarily `enables`, `requires`, `produces`, `accepts`, `instance_of`, `part_of`, and `transforms_to`. A query decomposes through these relations mechanically:

User desires file listing → file listing enabled by os.listdir → os.listdir requires import os → os.listdir produces list → sorted accepts iterable → list instance_of iterable → sorted transforms list to ordered list.

Each link is a typed relation lookup at L3. Sub-microsecond per link. Zero LLM tokens.

### 5.2 Meta-Reasoning Rules

The derivation is driven by Prolog rules in system KBs that encode general causal composition patterns, not domain-specific knowledge:

```prolog
solution_candidate(F, Operation) :-
    enables(F, Operation),
    part_of(F, PythonStdlib),
    instance_of(PythonStdlib, python_standard_library).

prerequisite(I, F) :-
    requires(F, Module),
    requires(Module, I),
    instance_of(I, import_statement).

postprocess(T, Output, Goal) :-
    produces(X, Output),
    enables(T, Goal),
    accepts(T, OutputType),
    instance_of(Output, OutputType).
```

These rules fire against domain-specific facts to produce domain-specific chains. The same meta-reasoning rules produce different chains for different domains because the underlying facts differ.

### 5.3 Chain Output

The derived chain is logged to prompt_current as structured facts: an ordered sequence of steps, each referencing the VdrId of the relevant entity, each carrying provenance from the source facts. Overall chain confidence equals the minimum confidence of its component facts (CR1: chain rule from confidence_rules).

### 5.4 Gap Handling

When the derivation encounters a token that maps to no entity in the KB graph, the chain reports a gap. The system delivers completed portions alongside an explicit report of what it could not resolve, and requests clarification. It does not fabricate a meaning for unresolved terms, does not skip them silently, and does not guess. An unresolved token at any confidence setting produces no resolution, only a gap flag.

### 5.5 Impact on Token Generation

With causal chain pre-derivation, the LLM assembles from a mechanically-verified solution path rather than inventing from scratch. Typical token reduction is 40-50% compared to generation without pre-derivation, because the chain provides the structural skeleton and the LLM fills only judgment gaps — which framework to choose, which of two equally-valid approaches to prefer, how much explanation to include.

---

## 6. Error Model

### 6.1 CLLM Error Mode

In a conventional LLM, low token probability produces a flat softmax distribution across the full vocabulary. Float rounding noise at the precision boundary can push any token above the others, producing hallucinated words, malformed syntax, or fabricated function names. The error is indistinguishable from correct output in the output stream.

### 6.2 VDR-Prolog Error Mode

In VDR-Prolog, low token probability produces a flat softmax distribution across 8,192 UUIDs. Every possible output is a valid UUID pointing to a real entity in the KB tree. The system cannot hallucinate a function that does not exist because there is no UUID for a nonexistent function. It cannot emit malformed syntax because formatting is handled by grammar templates, not token-by-token generation.

The failure mode is selecting the wrong UUID — choosing `os.listdir` when `pathlib.Path.iterdir` would be more appropriate. Both are real functions. Both exist. Both work. The error is suboptimal choice, not fabrication.

### 6.3 Detection

Low-confidence selection is detectable. When the winning token's softmax score is barely above alternatives, the system can:

- Check whether the selected UUID has typed relations that connect coherently to preceding UUIDs in the sequence
- Compare the top-N candidates against the causal chain from pre-resolution
- If no candidate connects well, defer entirely to the mechanical systems
- If multiple candidates connect equally well, present the ambiguity to the user

### 6.4 Error Floor

The error floor is bounded by the contents of the KB tree. The worst possible output is a real entity chosen for the wrong reasons. This is detectable (provenance chain doesn't support the selection), recoverable (retract and re-derive), and bounded (the entity exists and has known properties). Compare to a CLLM where the worst possible output is an arbitrarily convincing fabrication indistinguishable from truth.

---

## 7. Translation Architecture

### 7.1 Structure-to-Structure Translation

Translation operates as structure-to-structure transformation with cultural rules applied mechanically, not as text-to-text neural generation.

Input decomposes into language-independent semantic UUIDs through the prompt input pipeline. "I want the key" becomes VdrIds for speaker, desire action, and key object, plus structural annotations from English grammar and phrasing compacts: SVO sentence pattern, first-person subject, volition verb, definite noun.

### 7.2 Cultural Rule Application

Cultural rules fire as Prolog rules over session participant facts. The session carries facts about speaker and listener — age, role, institutional context, social relationship. Rules in cultural KBs compute social hierarchy mechanically:

```prolog
senpai_kohai(Listener, Speaker) :-
    role_rank(Listener, LR), role_rank(Speaker, SR), LR > SR.
```

The hierarchy determines honorific level (teineigo, sonkeigo, kenjougo, casual), which selects verb forms, hesitation markers, sentence-final particles, and pragmatic additions. A student requesting something from a teacher produces: hesitation marker, pragmatic pause, attention request, object reference, polite desire verb, trailing softener. A teacher requesting the same from a student produces: the object noun alone. Same semantic input, completely different surface realization, determined mechanically by social hierarchy facts.

### 7.3 Pragmatic Additions

Cultural compacts include gesture and physical behavior annotations as typed relations. A student making a request is annotated with slight bow, avoidance of direct eye contact, clasped hand position. A teacher making a request is annotated with direct eye contact and open palm gesture. These apply whether the output target is text, animation data, or stage directions.

### 7.4 Grammar Transformation

Grammar templates handle structural transformation. English SVO reorders to Japanese SOV. Particle insertion follows rules: object role requires を, topic role requires は. Subject dropping follows a rule: first-person subject omitted in polite speech. Bilingual vocabulary relations (`equivalent_to`) connect words across languages with register and formality metadata.

### 7.5 LLM Role in Translation

Minimal — approximately 10-15 tokens of judgment: confirming mechanical output sounds natural, selecting among equivalent phrasings when multiple template renderings are valid, and adding contextual adjustments from conversation history.

### 7.6 Adding Languages

A new target language requires a new language compact (grammar rules, vocabulary KB with bilingual relations, cultural rules) ingested into the KB tree. The semantic UUID decomposition of the source language is unchanged. The Prolog engine runs the same rules with different facts. No retraining.

---

## 8. Word Group Selection and Poetry Mode

### 8.1 Session Flag

Poetry mode is controlled by `poetry_mode: bool` on the Session struct (default false). In core mode, the system emits the canonical UUID for each content word. In poetry mode, the system generates word groups: the canonical choice plus thesaurus expansions.

### 8.2 Degree-Bounded Expansion

First-degree expansion retrieves direct synonyms and register variants via `synonym_of`, `similar_to`, and `register_variant_of` typed relations from vocabulary KBs. These are safe substitutions preserving meaning while varying flavor.

Second-degree expansion retrieves synonyms of synonyms, with a mandatory relevance check: does the candidate maintain a typed relation path (`enables`, `equivalent_to`, or `similar_to`) back to the original concept? If the path breaks, the candidate is excluded. This boundary prevents semantic drift. Third-degree or further expansions are prohibited.

### 8.3 LLM Selection

The LLM receives the word group as a small candidate set (typically 4-8 UUIDs) and makes a contextual selection via a small attention pass. Per-KB GEMM weights trained on vocabulary usage patterns assist selection.

### 8.4 Cost Model

Poetry mode costs more: additional GEMM passes for word group evaluation, approximately 60-80 LLM tokens versus 20 for core mode, and more KB access for thesaurus traversal. The cost difference is measurable and billable, making it suitable for tiered access.

### 8.5 Self-Building Vocabulary KBs

Thesaurus KBs are built through normal KB operations. The LLM can be instructed to create vocabulary KBs and populate them from compacted thesaurus data. Users can build and share vocabulary compacts through the mod store (Steam Workshop), with user-contributed data ingesting at appropriate confidence levels. Domain-specific vocabulary KBs (literary Japanese, business Japanese, regional dialects) extend word group palettes for specific registers.

---

## 9. Cross-Domain Composition

### 9.1 Principle

The system's power comes from composing multiple compacted knowledge domains through shared typed relations. A single query may traverse programming, project management, connections, and language compacts simultaneously. The disambiguation map determines which domains are relevant. The GEMM scope includes all surviving domain subtrees. The causal chain traverses cross-domain relations.

### 9.2 Project Management Integration

When a user requests the system to build something, the PM compact (project_management.md) provides structural decomposition. The user's request maps against PM foundations mechanically:

- FD2 (scope): what is in and out, derived from what was and wasn't mentioned
- FD10 (assumptions): unmentioned requirements become documented assumptions, each carrying risk
- FD12 (WBS): scope decomposes hierarchically through `part_of` relations
- FD13 (critical path): dependency chain derived from `requires` relations between WBS elements
- FD18 (acceptance criteria): testable conditions derived from stated requirements
- RK1-RK8 (risk): unspecified requirements generate risk facts with appropriate response strategies

### 9.3 Narrative Structure Integration

When a user requests a story, the dramatic writing compact provides narrative architecture with the same mechanical precision the PM compact provides for software. Character roles (CH1-CH15), plot mechanics (PL1-PL15), theme derivation (TH1-TH6), and structure selection (SS1-SS12) compose into story outlines through typed relation traversal.

The biology compact provides factual animal behaviors for a shapeshifter story. The military tactics compact provides doctrinal frameworks for a military narrative. The connections compact provides protocol mechanics for a networking story. Each domain contributes typed relations that compose with the narrative structure mechanically.

### 9.4 Language Rendering Integration

Regardless of domain, the final rendering passes through the language compacts. The English grammar compact provides sentence patterns (SP1-SP7), clause types (CL1-CL14), and agreement rules (AG1-AG11). The English phrasing compact provides constructions (CX1-CX20) with slot constraints, information structure (IS1-IS9), discourse functions (DC1-DC10), register patterns (RP1-RP7), and coherence relations (CR1-CR12). The vocabulary compact provides word selection governed by frequency tiers (FT1-FT6), etymology layers (EL1-EL6) influencing register appropriateness, and semantic fields (SF1-SF18) clustering related words.

For each beat in generated content, the grammar engine: selects a sentence pattern, selects a construction from the phrasing compact, fills argument roles, selects register-appropriate words from the vocabulary compact (preferring Anglo-Saxon origin for action and immediacy, Latinate for formality and distance), and applies coherence relations between sequential outputs.

---

## 10. Bidirectional Pattern System

### 10.1 matches/generates Duality

Every code pattern in the programming KBs is defined as a structural description traversable in two directions. The `matches` direction destructures text into typed terms. The `generates` direction composes typed terms into text. The structural pivot — the pattern UUID — is shared between both directions.

### 10.2 Composability

Patterns compose by nesting. A for-each loop containing a function call containing a conditional guard is three patterns with typed relations between them:

```
for_each.contains → function_call
for_each.contains → conditional_guard  
conditional_guard.contains → logging_call
```

The `generates` direction renders by recursive descent. The outer pattern generates its header, then calls `generates` on each body element with an incremented indentation depth parameter (an integer in the Term struct). Indentation is computed, not guessed. Style configuration (tabs vs spaces, indent width, brace style) is a fact in the session KB — change the fact, regenerate, get differently-formatted but structurally identical code.

### 10.3 Cross-Language Code Translation

The pattern UUID is language-independent. Parse Python → get structural UUIDs → generate Zig. The translation is structural, not textual. `for_each(ItemVar, Collection, Body)` generates `for item in items:` in Python and `for (items) |item| {` in Zig, through different language-specific `generates` rules applied to the same structural pivot.

### 10.4 Round-Trip Verification

Round-trip fidelity is testable via Prolog:

```prolog
?- matches(OriginalLine, Pattern), generates(Pattern, OutputLine), 
   OriginalLine == OutputLine.
```

Failure indicates a bug in either the matcher or the generator. This test runs in the standard test suite.

---

## 11. User Feedback System

### 11.1 Thumbs Up/Down

The UI provides thumbs up and thumbs down buttons on each output element (generated code block, story beat, translation, explanation section). Thumbs up increments a `success_count` fact on the pattern or rule that produced the output. Thumbs down increments a `failure_count` fact. Both push the producing entity's VdrId into a review queue KB with the session context (query, output, chain).

### 11.2 Review Queue Processing

The review queue (`session_root._llm.review_queue` or global if the user has write access) accumulates flagged items. Processing — by the user through the UI, or by an autonomous runner session on a schedule — presents each entry with its VdrId, thumbs direction, provenance chain, and session context.

### 11.3 Response Options

**Fix:** Edit the fact or `generates` rule directly through the UI. The change is live immediately. The GEMM cache's `isDirty` check triggers rebuild on next access.

**Delete:** Retract the pattern fact. The system loses that specific pattern and falls back to alternatives or defers to L1. If a future compact re-ingests the corrected version, it returns clean.

**Demote:** Leave the pattern but let its success rate (success_count / (success_count + failure_count) in Q16) naturally deprioritize it. RuleCandidate ranking uses success_rate — low-rated patterns sink below alternatives.

### 11.4 Live Editing

The UI allows direct editing of any fact, rule, or relation through a context menu on any output element. Click on wrong output → see provenance chain → navigate to source fact → edit → save. The change propagates: the GEMM cache dirty check triggers rebuild, every future query sees the corrected data. No retraining, no recompilation, no redeployment. A typo in an import path that would persist in a CLLM's weights until the next training run is fixed in two seconds.

All edits are audited. The audit log records who changed what, when, and what the old value was. Reverts are possible if an edit was incorrect.

---

## 12. Memory Model at Scale

### 12.1 Scale Parameters

At 2 million facts distributed across approximately 12,750 KBs at 6-7 depth levels with 150 root-level KBs:

### 12.2 Memory Budget

| Component | Calculation | Size |
|---|---|---|
| Facts | 2,000,000 × 48 bytes | 96 MB |
| KB structs | 12,750 × 256 bytes | 3.3 MB |
| Per-KB UUID maps | 12,750 × 157 avg entries × 16 bytes × 1.25 overhead | 39.5 MB |
| Typed relations | 600,000 × 48 bytes | 28.8 MB |
| Relation indices | 8,000 × 528 bytes | 4.2 MB |
| Rules | 100,000 × 48 bytes | 4.8 MB |
| Terms | 300,000 × 24 bytes | 7.2 MB |
| Text storage | Source code, names, templates | ~100 MB |
| Weight matrices | Per-KB GEMM (dominant) | ~1,500 MB |
| Overhead | Profiles, grants, audit, FSMs, behavior sets | ~16 MB |
| **Total** | | **~1,800 MB** |

This fits within the spec's global arena budget with substantial headroom. Per-core arenas (~220 MB each) are unchanged.

### 12.3 Depth Distribution

Depth 1 (150 root KBs): ~75,000 structurally important facts. Depths 2-4 (~6,600 KBs): ~1,180,000 domain knowledge facts. Depths 5-7 (~6,000 KBs): ~745,000 leaf-level facts (source code, specific data).

---

## 13. Performance Model

### 13.1 L1 Query (Full LLM Forward Pass)

| Phase | Time | Percentage |
|---|---|---|
| HTTP receipt (TCP, JSON parse, session resolve, queue push) | 60-130 µs | 0.03% |
| Query classification (tokenize, atom lookup, cache checks) | 1.5-2.5 µs | <0.001% |
| FSM evaluation (state check, transition scan) | 0.2 µs | <0.001% |
| UAI scoring (considerations, curves, compensation, selection) | 1.7 µs | <0.001% |
| Prolog pre-fetch / causal chain derivation | 2.5-3.5 µs | <0.001% |
| **LLM forward pass** (prefill + generation) | **320-570 ms** | **99.96%** |
| Grammar rendering (template selection, slot fill, composition) | 2-3 µs | <0.001% |
| Post-generation (prompt copy, counters, FSM re-eval) | 1.2 µs | <0.001% |
| HTTP response (buffer write, TCP send) | 50-100 µs | 0.03% |
| **Total** | **~320-570 ms** | |

LLM dominates. All mechanical processing combined: under 10 microseconds.

### 13.2 L3 Query (Zero LLM Tokens)

The LLM forward pass is eliminated. Total wall clock: 70-140 microseconds, dominated by HTTP I/O. Mechanical processing: under 10 microseconds. Per-core throughput: over 200,000 L3 requests per second before HTTP becomes the bottleneck.

### 13.3 Structural UUID Contribution

2-5 microseconds saved per request compared to global hash lookup. Negligible for L1 but significant for L3 where it represents 30-50% of mechanical processing time.

### 13.4 Causal Chain Token Reduction

With pre-derivation, the LLM generates approximately 30-45 UUIDs instead of 85-120 for a typical code generation request. At 5.3 ms per token, this saves 290-400 ms — a 40-50% reduction in L1 wall time for queries where the causal chain provides a complete solution skeleton.

---

## 14. GEMM Scope and Multi-Domain Queries

### 14.1 Single-Domain Scoping

When all query VdrIds share a structural prefix (e.g., all within `root.programming.python`), only GEMM caches matching that prefix are included in the forward sweep. Prefix comparison is one AND plus one CMP per cache.

### 14.2 Multi-Domain Scoping

When disambiguation produces survivors across multiple domains (e.g., Python + data structures + English grammar), the GEMM scope includes all surviving domain subtrees. The disambiguation map tells the system which subtrees. Domain filtering removes irrelevant ones. Prefix matching assembles the exact set of relevant weight caches.

### 14.3 Irrelevant Domain Exclusion

In a system with 150 root KBs, a typical query touches 3-7 domain subtrees. The remaining 143-147 subtrees' GEMM caches are never loaded, never scanned, and their weight data does not participate in the forward pass. The filtering happens in microseconds through disambiguation map lookups and prefix mask checks.

---

## 15. Product Architecture

### 15.1 Frontend

The game engine UI renders interactive elements, accepts text input, draws sprites, and plays sounds. It uses SQLite as its local persistence backend. The UI serves as the display layer for VDR-Prolog — the user sees a visual application, under the hood it is session KBs, Prolog rules, FSMs, behavior sets, grammar templates, and the LLM orchestrating all of it.

### 15.2 Provenance-Traced Editing

The UI provides context menus on every output element. Clicking through shows the provenance chain: which fact produced this output, which rule selected it, which KB it lives in, what confidence it carries. The user can navigate to the source fact and edit it in place. The edit is live immediately — the GEMM cache dirty check triggers rebuild on next access. All edits are audited.

### 15.3 Feedback Loop

Thumbs up/down on output elements feed the review queue. Success and failure counts on patterns and rules enable natural deprioritization of bad patterns and promotion of good ones through the existing RuleCandidate success_rate scoring. Direct deletion of bad patterns acts as an instant purge — the system falls back to alternatives or L1, and future compacts may re-introduce corrected versions.

### 15.4 Distribution

Steam for consumer distribution with Workshop as the mod store for user-contributed compacted knowledge domains.

### 15.5 Knowledge Base Distribution

The product ships with approximately 500 compacted knowledge domains covering a civilization-scale breadth: agriculture, construction, medicine, law, engineering, all sciences, all major programming languages and libraries, trade skills, military tactics, cooking, languages, philosophy, mathematics, history, and more. Users extend through Workshop. User-contributed compacts ingest at appropriate confidence levels (CF8 or lower).

### 15.6 Autonomous Operation

Configured sessions can be snapshotted and bound to runners for autonomous operation. A session configured as an SMTP server, an HTTP server rendering HTMX-driven UI, a data ingestion pipeline, or a monitoring agent runs without human interaction after initial configuration. Eight cores support eight concurrent autonomous sessions, with hundreds more suspended and restored on demand through LRU session management.

---

## 16. New Invariants

**IN36:** Structural VdrId bits must match the entity's actual position in the KB tree. Reparenting requires VdrId recomputation for the entity and all descendants.

**IN37:** Per-KB UUID map is always consistent with the KB's fact array. Every fact assertion adds to the map; every retraction removes. Serialization captures both atomically.

**IN38:** Global hot cache entries are valid pointers to resident KBs. Eviction removes only the fast path, not the KB. The KB remains accessible through structural walk.

**IN39:** Unresolved tokens in the prompt input pipeline are never silently dropped. Every input token is either resolved to a VdrId, corrected and resolved, or flagged as unresolved and preserved as a text fact.

**IN40:** Poetry mode does not affect mechanical correctness. Honorific selection, grammar transformation, cultural rules, and causal chain derivation produce identical results regardless of the poetry_mode flag. Only content word selection among semantically-equivalent candidates is affected.

**IN41:** Second-degree thesaurus expansion must maintain a typed relation path back to the original concept. Candidates without a verifiable path are excluded from the word group.

**IN42:** The LLM's output vocabulary contains only valid VdrIds referencing real entities in the KB tree. The system cannot produce a reference to a nonexistent entity through neural inference.

**IN43:** Every `matches` rule has a corresponding `generates` rule operating on the same structural pivot. Round-trip fidelity (parse then generate equals original) is tested in the standard test suite.

**IN44:** Content detection matchers never silently discard malformed input. Broken structured content (invalid JSON, malformed YAML) is tagged with its error and preserved as text in a typed segment.

**IN45:** Thumbs up/down counters are exact integers on pattern facts. Success rate computation is Q16 with exact remainder. No floating-point approximation in feedback scoring.

**IN46:** Direct fact edits through the UI trigger GEMM cache dirty checks. Corrected data is visible to the next access without retraining.

**IN47:** The disambiguation map contains every entity name mapping in the system. An atom not in the disambiguation map has no KB representation and resolves to unresolved status in the prompt input pipeline.

---

## 17. Relationship to v0.5 Spec

### 17.1 Preserved

All principles (PR1-PR14), data types (DT1-DT40), arithmetic rules (AR1-AR5), arena layout (AM1-AM4), KB tree (KT1-KT16), components (CO1-CO28), HTTP interface (HT1-HT6), compute model (CM1-CM6), model parameters (MD1-MD16), Prolog engine (PL1-PL8), core rules (PC1-PC8), relation types (RT1-RT27), ingestion pipeline (IG1-IG6), confidence system (CF1-CF11, CR1-CR4), scoring system (SC1-SC6), FSM system (FS1-FS8), inference pipeline (PX1-PX9), inference levels (IF1-IF3), LLM tree (LT1-LT10), persistence (PS1-PS6), errors (ER1-ER9), invariants (IN1-IN35), build stages (BS1-BS6), and implementation stages (IM1-IM8) are unchanged.

### 17.2 Extended

**IS1 (VdrId):** Internal bit layout redesigned from opaque i64 to structural packed struct. External interface unchanged — still 8 bytes, still sign-bit partitioned, still O(1) lookup. Internal navigation now exploits tree structure.

**DT8 (KB):** Gains `uuid_map` field — `AutoHashMap(i64, u32)` for per-KB entity lookup. Serialized with KB on persistence. Approximately 3.1 KB overhead per average KB.

**DT29 (KbStore):** Gains `disambiguation_map` field — `AutoHashMap(i64, []VdrId)` for multi-entity name resolution. Gains `global_hot_cache` field — `AutoHashMap(i64, *anyopaque)` with fixed capacity.

**DT28 (Session):** Gains `poetry_mode: bool` field (default false). Gains `spell_correction_level` field for prompt input pipeline configuration.

**PX1 (input step):** Expanded from "system writes user input to prompt_input" to full five-stage pipeline: content detection, code pattern matching, tokenization, spell correction with confidence tuning, UUID resolution with disambiguation, and structured fact assertion.

**PX2 (pre-resolution):** Now includes causal chain derivation composing typed relations into solution paths before LLM execution.

### 17.3 Added

Structural UUID system (Section 1). Two-tier lookup (Section 2). Full prompt input pipeline (Section 3). LLM-as-UUID-predictor formalization (Section 4). Causal chain derivation (Section 5). Error model formalization (Section 6). Translation architecture (Section 7). Poetry mode (Section 8). Cross-domain composition framework (Section 9). Bidirectional pattern system (Section 10). User feedback system (Section 11). Memory model at 2M scale (Section 12). Detailed performance model (Section 13). Multi-domain GEMM scoping (Section 14). Product architecture (Section 15). Twelve new invariants IN36-IN47 (Section 16).

---

# Structured Neural Knowledge

SNK decomposes what an LLM does into explicit subsystems. Knowledge is stored as 48-byte Fact structs in a hierarchical KB tree, each carrying provenance (source type, confidence as Q16, timestamp, derivation rule). Relations between facts are typed (120+ types across 8 semantic groups) with compile-time known algebraic properties — transitivity, symmetry, and inverse mappings — enabling multi-hop reasoning through BFS on contiguous integer arrays without neural computation. A Prolog engine with six priority levels (typed relation scan → transitive closure → inverse lookup → symmetric swap → structural inheritance → general unification) resolves queries mechanically, with `fire_and_commit` chaining derived facts forward through rule matching. All arithmetic uses Q16 (i32 value, i16 r0, i16 r1, implicit D=65536) with full remainder propagation: addition carry-chains r1→r0→v, multiplication captures cross-terms in i64 then divTrunc/mod, softmax sums to D exactly via FRU deficit assignment. No float exists anywhere in the system. The neural component is a 6-layer 143M-parameter transformer predicting the next i64 from a vocabulary of 8,192 structural UUIDs — command tokens, KB addresses, pattern references, argument values — not text tokens. It does not know what its outputs do; the grant system, execution engine, and KB tree determine consequences.

The VdrId (i64) is a packed struct encoding tree position: 1-bit sign (global/session), 8-bit L1, 10-bit L2/L3/L4 indices, 5-bit remaining depth, 20-bit collision-resistant random. Navigation is bit extraction into array indices — four dereferences reach any KB within four levels of root. Per-KB `AutoHashMap(i64, u32)` maps full VdrIds to local fact slots, keeping lookup proportional to KB population (~200 entries) not system population (~2M). A global hot cache (256 entries, LRU eviction) accelerates seed KBs and frequently accessed domains. A disambiguation map (`AutoHashMap(i64, []VdrId)`) resolves polysemous atoms to all matching entities across the tree; domain filtering by typed relation co-occurrence and structural prefix matching narrows GEMM scope to relevant subtrees (typically 3-7 of 150 root KBs). The prompt input pipeline runs before neural inference: content detection splits embedded JSON/code into natively-typed segments (numbers become Q16, never stored as float; malformed content tagged and preserved, never dropped), spell correction operates at configurable confidence with provenance penalty, UUID resolution maps tokens to KB addresses through the disambiguation map, and the resolved interpretation is asserted to session working memory as reference facts. The neural network reads structural addresses, not English.

Causal chain derivation composes typed relations (`enables`, `requires`, `produces`, `accepts`, `instance_of`) into solution paths via Prolog meta-reasoning rules before the forward pass executes. The chain is logged to working memory as ordered step facts with min-of-chain confidence propagation. Unresolved tokens produce explicit gaps, never fabrication. Bidirectional code patterns share a structural pivot between `matches` (text→structure) and `generates` (structure→text) rules, enabling parse/generate round-trip verification and cross-language translation through the same UUID. The neural network selects pattern compositions and judgment calls from mechanically-derived scaffolding — typically 30 UUIDs at 5.3ms each (~160ms) versus 400 text tokens in a CLLM (~15 seconds). 93% of queries resolve at L3 (zero neural tokens, sub-microsecond). FSMs track session and domain state as KB data structures with Prolog-evaluated transitions. UAI scoring evaluates candidate behaviors through Q16 response curves with Dave Mark compensation. Grammar templates with typed slots render output through vocabulary KBs encoding frequency, etymology, register, and semantic field. Memory is arena-only (global ~1.8GB at 2M facts, per-core ~220MB), zero allocation after init, session death by cursor reset. Grants gate execution structurally — the neural network's prediction is irrelevant without matching capability tokens. The full system is ~28,000 lines of Zig, CPU-only, no GPU, no float, no external dependencies.
