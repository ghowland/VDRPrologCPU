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