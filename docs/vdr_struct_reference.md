# VDR-Prolog Struct Reference

Every struct in the system lives in `vdr_types.zig`. No struct is defined anywhere else. All modules import from this single file. Every struct has defaults so `TypeName{}` produces a valid zero-state instance.

---

## Fundamental Types

### VdrId

```zig
pub const VdrId = struct {
    v: i64 = 0,
};
```

The universal identifier for every entity in the system. The sign bit of `v` partitions the address space: positive values are global (persistent, shared across sessions), negative values are session-local (ephemeral, die with the session). Zero is the null/none sentinel.

Every KB, fact, rule, term, grammar, session, grant, runner, and audit entry has a VdrId. Global IDs are generated from a counter + hash with bit 63 cleared. Session IDs decrement from -1 within each session. They can never collide because they occupy disjoint halves of the i64 range.

Three well-known constants: `NONE` (0, null sentinel), `ROOT` (1, global tree root), `EPHEMERAL_ROOT` (-1, session tree root).

Used everywhere. Every struct that references another entity does so through a VdrId. The KB store maintains a lookup table mapping VdrId to arena memory location for O(1) direct access. Path traversal (dotted walk) is the alternative addressing mode — both resolve to the same data.

---

### Q16

```zig
pub const Q16 = struct {
    v: i32 = 0,
    r0: i16 = 0,
    r1: i16 = 0,
};
```

The primary arithmetic type. 8 bytes. Denominator D=65536 is implicit and never stored. The rational value is `v / 65536`. `r0` is the exact remainder from the last integer division that produced this value. `r1` is the sub-r0 precision from cross-terms in multiplication and division.

Remainder is not error. It is exact unresolved structure. Every arithmetic operation (add, sub, mul, div) propagates all three fields. Comparison is lexicographic across all three — two values with equal `v` but different `r0` are different values.

Used for: model weights (the `v` field in SoA-packed weight matrices), attention scores, softmax probabilities, confidence values in provenance, sampling parameters (temperature, top_p), and any computed value in the system. The GEMM inner loop operates on the `v` field via SIMD; `r0` and `r1` are propagated in scalar post-passes where full precision is needed.

---

### Q32

```zig
pub const Q32 = struct {
    v: i64 = 0,
    r0: i32 = 0,
    r1: i32 = 0,
};
```

Intermediate precision. D=2^32. 16 bytes. Used when Q16's r1 approaches saturation (±32767), indicating the Q16 frame is too small for that computation path. The system escalates specific operations to Q32 — not the entire model, just the computation chain that needs it. Provides `fromQ16` and `toQ16` for conversion.

Used for: Newton-Raphson iterations in RMSNorm (inverse square root needs more precision than Q16 provides), long multiplication chains where r1 would saturate, and any computation where the precision sentinel fires.

---

### Q335

```zig
pub const Q335 = struct {
    v: [6]i64 = .{0} ** 6,
    r0: [6]i64 = .{0} ** 6,
    r1: [6]i64 = .{0} ** 6,
    r2: [6]i64 = .{0} ** 6,
    r3: [6]i64 = .{0} ** 6,
};
```

High precision. D=2^335. 240 bytes. 384-bit value as 6 × 64-bit limbs. Four remainder slots instead of two. Used for transcendental functions, physics constants, and any computation requiring arbitrary precision. Not used in the inference hot path — this is for offline computation, seed data preparation, and scientific work stored in domain KBs.

---

## Knowledge Base Types

### Fact

```zig
pub const Fact = struct {
    tag: FactTag = .empty,
    value: Q16 = .{},
    provenance: Provenance = .{},
};
```

The atomic unit of knowledge. 48 bytes (padded for alignment). Every piece of data in the system is a Fact: a domain value, a weight matrix reference, a text pointer, a boolean flag, a timestamp.

The `tag` field (FactTag enum, 13 variants) determines how the `value` Q16 is interpreted. For `TAG_VALUE`, the Q16 is a direct numeric value. For `TAG_MATRIX`, `value.v` is an index into the KB's matrix_refs array — the actual weight data lives in a WeightMatrix struct elsewhere in the arena. For `TAG_TEXT`, `value.v` and `value.r0` encode offset and length into the text store. For `TAG_BOOLEAN`, `value.v` is 0 or 1.

Every Fact carries full `provenance` — where the data came from, its confidence level, when it was created, and what rule derived it. This means any individual fact (including any individual weight in a trained matrix) can be traced to its origin.

Facts are stored in contiguous arrays within KBs. The 48-byte stride means scanning facts for non-matrix data costs 12× the bandwidth of reading just the `v` fields. This is why weight matrices use SoA-packed WeightMatrix structs instead of individual Facts per parameter, and why GEMM caches exist for non-matrix fact collections.

---

### Provenance

```zig
pub const Provenance = struct {
    source_type: i32 = @intFromEnum(SourceType.unknown),
    source_kb_id: VdrId = .{},
    source_slot_id: i32 = -1,
    confidence: Q16 = .{},
    timestamp: i32 = 0,
    derivation_rule_id: i32 = -1,
    capability_level: i32 = 0,
};
```

Attached to every Fact. Records the complete lineage of a piece of data. `source_type` indexes into the confidence table (11 levels from `vdr_computation` at 1/1 to `unknown` at 0/1). `source_kb_id` and `source_slot_id` point back to the originating data. `derivation_rule_id` records which Prolog rule produced a derived fact. `timestamp` is integer epoch seconds.

`capability_level` is for per-weight access control. During GEMM cache rebuild, weights whose capability level exceeds the session's access level are read as zero. This check happens on the cold path (cache rebuild), not during GEMM execution.

Two constructors: `direct` for data from external sources (sets confidence from the table based on source type) and `derived` for Prolog-derived facts (carries the derivation rule ID and a computed confidence).

---

### KB

```zig
pub const KB = struct {
    id: VdrId = .{},
    parent_id: VdrId = .{ .v = -1 },
    // ... ~40 fields ...
    training_lock: bool = false,
    training_arena: ?*Arena = null,
    version: i32 = 1,
};
```

The knowledge base struct. 256 bytes, padded for cache line alignment. This is the central organizational unit of the system. Every piece of data, every rule, every weight matrix, every grammar lives inside a KB.

The struct is mostly offsets and counts pointing into arena memory regions: `facts_offset`/`facts_count`/`facts_capacity` for the fact array, `rules_offset`/`rules_count`/`rules_capacity` for rules, and so on for constraints, connections, grammars, and all live state structures (LRUs, counters, locks, queues, stacks, rings, bitsets).

`weight_refs_offset` points to a KbWeightRefs struct that holds the KB's weight matrices and vectors. `new_facts_since_training_offset`/`count` tracks facts added since the last training run — this drives Path 3 weight retrieval (cache + new facts scan).

`training_lock` and `training_arena` support live training. `training_arena` is the only nullable pointer in the entire system. It is null 99% of the time — set only while a temporary training arena is active for this KB. `training_lock` prevents concurrent training of the same KB.

`children_offset`/`children_count`/`children_capacity` and `mounts_offset`/`mounts_count` define the tree structure. KBs form a hierarchy: `root.science.physics.qed` is a child of `root.science.physics`, which is a child of `root.science`.

`visibility` (0=public, 1=internal, 2=owner_only), `frozen` (immutable seed KBs), and `owner_id` control access. `version` catches struct layout mismatches when loading from disk.

---

### KbWeightRefs

```zig
pub const KbWeightRefs = struct {
    matrix_refs: []WeightMatrix = &.{},
    matrix_count: i32 = 0,
    matrix_capacity: i32 = 0,
    vector_refs: []WeightVector = &.{},
    vector_count: i32 = 0,
    vector_capacity: i32 = 0,
    gemm_cache: ?GemmCache = null,
};
```

Extension struct for KBs that hold weight data. Referenced from `KB.weight_refs_offset`. Contains arrays of WeightMatrix and WeightVector references (the actual SoA-packed weight data in the arena), plus an optional GemmCache for non-matrix fact data that needs to feed into SIMD operations.

A domain KB like `root.science.physics.qed` might have one WeightMatrix (its reasoning weights) alongside its facts and rules. A system KB like `root.system.embedding` holds the vocabulary embedding table as a large WeightMatrix. KBs without weights have `weight_refs_offset = -1` and no KbWeightRefs is allocated.

The three-path weight retrieval checks this struct: if `gemm_cache` is null, full fact scan (Path 1). If `gemm_cache` exists and no new facts, read the cache directly (Path 2). If `gemm_cache` exists but new facts were added since training, read cache then scan the new-facts list (Path 3).

---

### WeightMatrix

```zig
pub const WeightMatrix = struct {
    v: []i32 = &.{},
    r0: []i16 = &.{},
    r1: []i16 = &.{},
    rows: i32 = 0,
    cols: i32 = 0,
};
```

SoA-packed (Structure of Arrays) weight storage. Three contiguous arrays: `v` (the values, GEMM-ready, read directly by SIMD), `r0` (remainder level 0), `r1` (remainder level 1). Each array is cache-line aligned (64 bytes) in the arena.

Per parameter: 4 (v) + 2 (r0) + 2 (r1) = 8 bytes. For a 2048×2048 matrix: 4M params × 8 bytes = 32 MB. The `v` array alone is 16 MB — this is what GEMM reads at full memory bandwidth. The `r0` and `r1` arrays are read during training weight updates and precision checks, not during inference GEMM.

Referenced by TAG_MATRIX Facts via an index into the KB's `matrix_refs` array. The Fact provides metadata (provenance, confidence). The WeightMatrix provides the data.

---

### WeightVector

```zig
pub const WeightVector = struct {
    v: []i32 = &.{},
    r0: []i16 = &.{},
    r1: []i16 = &.{},
    length: i32 = 0,
};
```

1D version of WeightMatrix. Same SoA layout, same cache-line alignment. Used for layer norm gamma/beta vectors, bias terms, and any 1D weight data. Referenced by TAG_VECTOR Facts via an index into the KB's `vector_refs` array.

---

### GemmCache

```zig
pub const GemmCache = struct {
    v_packed: []i32 = &.{},
    fact_count: i32 = 0,
    kb_id: VdrId = .{},
    kb_last_modified: i32 = 0,
    generation: i32 = 0,
};
```

Contiguous packed cache of `v` fields from a KB's individual Facts, built for SIMD access. This exists because individual Facts are 48 bytes each — reading just the 4-byte `v` field from each wastes 12× memory bandwidth. The cache copies all `v` fields into a contiguous, cache-line-aligned i32 array.

Only needed for non-matrix KBs where scattered facts feed into computation (Prolog query results used in dot products, builtin operations over fact collections). Weight matrices already have contiguous `v` arrays via WeightMatrix and don't need this cache.

The cache is ephemeral — lives in per-core arena scratch, rebuilt when `kb_last_modified` exceeds `kb_last_modified` on the cache. Sized exactly to the KB's fact count. `generation` increments on each rebuild.

---

## Prolog Types

### Term

```zig
pub const Term = struct {
    type: TermType = .atom,
    primary_id: i32 = 0,
    secondary_offset: i32 = 0,
    secondary_aux: i32 = 0,
    vdr_value: Q16 = .{},
};
```

The unit of Prolog expression. 24 bytes. The `type` field (10 variants: atom, variable, integer, vdr, text, list, compound, vector, matrix, pair) determines how the other fields are interpreted.

For atoms: `primary_id` is the atom ID (an integer in the atom table). For variables: `primary_id` is the variable ID (used in binding tables during unification). For compounds: `primary_id` is the functor ID, `secondary_offset` points to the args array, `secondary_aux` is the arg count. For lists: `secondary_offset` is the head, `secondary_aux` is the tail. For VDR values: `vdr_value` holds the Q16 directly.

Unification compares terms structurally. Atom-atom: IDs must match. Variable-anything: creates a binding. VDR-VDR: all three Q16 fields must match exactly (no epsilon). Compound-compound: functors match plus recursive argument unification.

Terms are stored in contiguous arrays in the global or session arena. Rules and queries reference terms by offset into these arrays.

---

### Rule

```zig
pub const Rule = struct {
    id: VdrId = .{},
    head: i32 = 0,
    body_offset: i32 = 0,
    body_count: i16 = 0,
    action_offset: i32 = 0,
    action_count: i16 = 0,
    fire_count: i32 = 0,
    last_fired: i32 = 0,
    success_count: i32 = 0,
    failure_count: i32 = 0,
    created_at: i32 = 0,
    creator_session_id: VdrId = .{},
};
```

A Prolog rule. 48 bytes. `head` is the offset to the head Term. `body_offset`/`body_count` reference the body terms (conditions). `action_offset`/`action_count` reference what happens when the rule fires (assert/retract operations).

Rules carry their own statistics: `fire_count`, `last_fired`, `success_count`, `failure_count`. The `successRate()` method computes a Q16 ratio from these. This means the system tracks how well each rule performs over time — useful for hygiene rules that prune or adjust underperforming rules.

`creator_session_id` tracks which session created the rule. If the rule was created in a session (negative ID), it dies with that session. If it was promoted to global (positive ID), it persists.

Rules are stored in contiguous arrays within KBs. The Prolog engine's `fire_and_commit` function scans rules against facts, fires matches, and writes derived facts with `PROLOG_DERIVATION` confidence (1/1). This is the L3 execution level — zero LLM tokens consumed.

---

### Binding

```zig
pub const Binding = struct {
    var_id: i32 = 0,
    bound_term_offset: i32 = -1,
};
```

A variable-to-term binding produced during Prolog unification. `var_id` is the variable's ID, `bound_term_offset` is the offset to the Term it was bound to. Bindings are stored in arrays in the per-core arena scratch during query execution. They are ephemeral — used to instantiate rule actions and then discarded when the query completes.

---

### UnificationResult

```zig
pub const UnificationResult = struct {
    unified: bool = false,
    bindings_offset: i32 = -1,
    bindings_count: i16 = 0,
};
```

Result of attempting to unify two terms. `unified` is true if unification succeeded. `bindings_offset`/`bindings_count` reference the binding array in scratch memory. The Prolog engine's query loop uses this to drive backtracking — on failure, it pops the binding stack and tries the next candidate.

---

### PrologAction

```zig
pub const PrologAction = struct {
    is_assert: bool = true,
    target_kb_id: VdrId = .{},
    target_slot_id: i32 = 0,
    fact: Fact = .{},
};
```

What a rule does when it fires. Either asserts a new fact to a target KB or retracts one. The `fact` field holds the fully instantiated fact (variables replaced with their bound values from unification). This is how Prolog rules modify the knowledge base — a rule fires, produces PrologActions, and the KB store applies them.

---

## Grammar Types

### Grammar

```zig
pub const Grammar = struct {
    id: VdrId = .{},
    template_offset: i32 = 0,
    template_length: i32 = 0,
    slots_offset: i32 = 0,
    slots_count: i16 = 0,
    validated: i8 = 0,
    created_at: i32 = 0,
    creator_session_id: VdrId = .{},
};
```

A structural template for rendering KB data as text. The template is a string with slot placeholders. `slots_offset`/`slots_count` reference an array of GrammarSlot structs that define what fills each placeholder.

Grammars are how the LLM outputs structured data. Instead of generating prose about a fact, the LLM emits a direct output token referencing a KB URL. The grammar attached to that KB (or inherited from an ancestor) renders the data in the correct format. This is the separation between data (in KBs) and presentation (in grammars).

`validated` indicates whether the template has been checked for slot consistency. Grammars inherit down the KB tree — a child KB without its own grammar uses its parent's.

---

### GrammarSlot

```zig
pub const GrammarSlot = struct {
    name_offset: i32 = 0,
    name_length: i16 = 0,
    type: SlotType = .text,
    enum_values_offset: i32 = -1,
    enum_count: i16 = 0,
    kb_id: VdrId = .{},
    kb_slot_id: i32 = -1,
};
```

A placeholder in a grammar template. Has a name (for human readability), a type (vdr_value, text, integer, enum, kb_ref, grammar), and optionally a reference to a specific KB and slot for data binding. Enum slots have a fixed set of allowed values referenced by `enum_values_offset`/`enum_count`.

---

### GrammarFill

```zig
pub const GrammarFill = struct {
    slot_index: i16 = 0,
    fill_type: SlotType = .text,
    vdr_value: Q16 = .{},
    text_offset: i32 = 0,
    text_length: i16 = 0,
    int_value: i32 = 0,
    enum_index: i16 = 0,
};
```

The concrete value to fill into a grammar slot during rendering. The renderer walks the template, encounters a slot placeholder, finds the corresponding GrammarFill, and writes the value into the output buffer. The `fill_type` determines which field holds the actual data.

---

## Session Types

### Session

```zig
pub const Session = struct {
    id: VdrId = .{},
    user_id: VdrId = .{},
    kb_root_id: VdrId = VdrId.ROOT,
    ephemeral_root_id: VdrId = VdrId.EPHEMERAL_ROOT,
    ephemeral_next_id: i64 = -2,
    // ... resource bounds, counters, snapshot, clone lineage ...
};
```

The isolation unit. Every user interaction runs inside a session. A session is bound to a specific core at creation (`core_id`/`arena_id`) and all its inference runs on that core.

`kb_root_id` is the global tree root this session can see (usually `ROOT`). `ephemeral_root_id` is the session's own tree root (always -1). `ephemeral_next_id` is the counter for generating new session-local IDs (decrements from -2).

Resource bounds control how much the session can grow: `max_kb_count`, `max_ephemeral_kbs`, `max_facts_per_kb`, `max_live_memory_bytes`, `max_turns`. When limits are reached, the LLM cannot create new KBs or assert new facts, but it can still read, query, fire existing rules, pump bounded structures (LRUs, queues), and retract facts to make room.

Counters track everything: facts asserted/retracted, rules fired, Prolog queries, builtin calls, grammar renders, LLM tokens consumed, command tokens consumed. These feed into the LevelStats tracking (L1/L2/L3 ratios).

Sessions support snapshots (full binary capture of session state for restore) and cloning (COW copy of session tree for branching). Clone lineage is tracked via `parent_session_id`/`clone_generation`.

---

### SessionConfig

```zig
pub const SessionConfig = struct {
    user_id: VdrId = .{},
    kb_root_id: VdrId = VdrId.ROOT,
    visibility_level: i8 = 1,
    max_kb_count: i32 = 100,
    max_ephemeral_kbs: i32 = 1000,
    max_live_memory_bytes: i64 = 50 * 1024 * 1024,
    max_turns: i32 = 0,
    auto_snapshot_interval: i32 = 100,
};
```

Parameters for creating a new session. The session manager reads these, allocates the session in a per-core arena, creates the `_llm.*` canonical subtree, and returns a SessionHandle. `auto_snapshot_interval` controls how often the system automatically snapshots the session (every N turns).

---

## Runner Types

### Runner

```zig
pub const Runner = struct {
    id: VdrId = .{},
    type: RunnerType = .poller,
    state: RunnerState = .stopped,
    session_id: VdrId = .{},
    // ... interval, error tracking, recycle tracking ...
};
```

An autonomous agent that operates on a session. Four types:

**Poller** — periodically checks an external source (database, API) and updates KB facts. Runs on a configurable interval.

**Processor** — continuously processes incoming work from a source URL. Has backoff logic for failures and recycles after a configurable number of turns to prevent state accumulation.

**Internal** — runs periodic maintenance tasks (hygiene rules, consistency checks). Typically on a long interval (daily).

**Batch** — processes a queue of tasks from a KB. Supports configurable concurrency.

Runners track their own health: `iterations_completed`, `errors_consecutive`, `errors_total`, `last_iteration_ms`. `shouldRecycle()` checks if a processor has exceeded its turn limit. `shouldStop()` checks if consecutive errors have hit the threshold. The runner scheduler manages lifecycle based on these checks.

---

## Grant Types

### Grant

```zig
pub const Grant = struct {
    id: VdrId = .{},
    class: GrantClass = .filesystem,
    state: GrantState = .active,
    holder_user_id: VdrId = .{},
    // ... pattern, usage limits, expiry, revocation ...
};
```

An authorization token. Grants control access to operational capabilities: filesystem, compile, execute, lint, network, process. When the LLM emits a command that requires one of these capabilities, the grant system checks whether the session's user holds an active grant of the required class matching the target pattern.

Grants have usage limits (`max_uses`/`remaining_uses`, -1 for unlimited), expiry (`expires_at`, 0 for never), and revocation tracking. `consumeUse()` decrements remaining uses and transitions to `exhausted` when they hit zero. The audit system logs every grant check (allowed or denied).

---

## Command Types

### Command

```zig
pub const Command = struct {
    type: CommandType = .kb_query,
    target_kb_id: VdrId = .{},
    target_slot_id: i32 = 0,
    builtin_id: i32 = 0,
    args_offset: i32 = 0,
    args_count: i16 = 0,
    grant_required: i8 = -1,
};
```

A parsed LLM command. 15 command types covering KB operations (assert, query, retract), Prolog operations (query, assert_rule), builtins, grammar rendering, direct output, operational commands (filesystem, compile, execute, network, process), and session management (snapshot, clone).

`grant_required` is -1 if no grant is needed (most KB and Prolog operations), or a GrantClass value for operational commands. The command executor checks grants before executing operational commands.

---

### CommandResult

```zig
pub const CommandResult = struct {
    status: Status = .{},
    output_kb_id: VdrId = .{},
    output_slot_id: i32 = -1,
    output_bytes: i32 = 0,
    output_text: ?[]const u8 = null,
};
```

What comes back from executing a command. The status indicates success or failure. For KB operations, `output_kb_id`/`output_slot_id` reference where the result was written. For operations that produce text output, `output_text` points to it. The LLM reads command results from the scratchpad (`_llm.prompt_current`) during the generation loop.

---

## Audit Types

### AuditEntry

```zig
pub const AuditEntry = struct {
    timestamp: i32 = 0,
    session_id: VdrId = .{},
    user_id: VdrId = .{},
    action: AuditAction = .fact_query,
    target_kb_id: VdrId = .{},
    target_slot_id: i32 = -1,
    grant_id: VdrId = .{},
    result: i8 = 0,
    detail_offset: i32 = -1,
};
```

A record in the audit ring buffer. 15 action types covering fact operations, rule operations, grant operations, session lifecycle, operational execution, and access denials. Every security-relevant action writes an audit entry. The ring buffer has a configurable capacity (default 1M entries) — oldest entries are overwritten when full.

`result` is 0 for denied, 1 for allowed. Two constructors: `allowed()` and `denied()` for the common patterns.

---

### AuditFilter

```zig
pub const AuditFilter = struct {
    session_id: ?VdrId = null,
    user_id: ?VdrId = null,
    action: ?AuditAction = null,
    // ... timestamp range, result filter ...
};
```

Query parameters for searching the audit log. All fields are optional — null means "don't filter on this field." `matchesEntry()` checks an entry against all non-null filter criteria. Used by administrators and hygiene runners to review access patterns.

---

## Error Types

### Status

```zig
pub const Status = struct {
    category: ErrorCategory = .none,
    code: ErrorCode = .ok,
    detail: i32 = 0,
};
```

The universal error type. Every function that can fail returns a Status. `category` (10 categories: none, arithmetic, kb, prolog, grammar, session, grant, runner, memory, system) groups errors. `code` (40+ specific codes) identifies the exact failure. `detail` carries context — for arena exhaustion, it's the arena ID; for slot errors, it's the slot index.

`recoverFromError()` maps error codes to recovery actions: `kb_full` → compact, `arena_exhausted` → kill oldest clone, `corrupt_state` → restore from snapshot, etc. This is the deterministic recovery tree — every error has a defined recovery path.

---

## Memory Types

### Arena

```zig
pub const Arena = struct {
    base: [*]u8 = undefined,
    size: usize = 0,
    cursor: usize = 0,
};
```

The memory allocator. Fixed-size contiguous block. Bump pointer only. No free. `alloc()` advances the cursor with alignment, returns null on exhaustion. `reset()` sets cursor to 0 — instant deallocation of everything. `allocTyped()` and `allocSlice()` are convenience wrappers that handle sizing and casting.

Global arena is general (any thread). Per-core arenas are pinned (NUMA-locked). Both are the same struct, different init path. The pinned arenas have their pages touched from the pinned thread for first-touch NUMA placement.

---

## Infrastructure Types

### WorkItem

```zig
pub const WorkItem = struct {
    op: WorkOp = .idle,
    a_ptr: ?[*]const i32 = null,
    b_ptr: ?[*]const i32 = null,
    c_ptr: ?[*]i32 = null,
    m: i32 = 0,
    n: i32 = 0,
    k: i32 = 0,
    seq_len: i32 = 0,
    n_heads: i32 = 0,
    d_head: i32 = 0,
    scale_v: i32 = 0,
    completion: bool = false,
};
```

A unit of work pushed from an HTTP handler thread to a pinned compute thread via the per-core atomic ring buffer. `op` identifies what to do (gemm, softmax, rmsnorm, attention, dot_product, idle). The pointer and dimension fields carry the operands. `completion` is set to true by the compute thread when done — the HTTP handler spins on this flag waiting for the result.

The pointers reference arena memory directly — no copying. The HTTP handler sets up the work item with pointers into the session's arena region, pushes it to the core's queue, and waits. The pinned thread pops, executes, sets completion. Zero-copy throughout.

---

### SnapshotHeader

```zig
pub const SnapshotHeader = struct {
    magic: [4]u8 = SNAPSHOT_MAGIC,  // "VDRS"
    version: i32 = SNAPSHOT_VERSION, // 3
    // ... region sizes, counts, session metadata, checksum ...
};
```

Binary header for session snapshots. Contains the sizes of every region (KB, fact, rule, term, text, grammar, live state, grant, ephemeral KB, ephemeral fact), counts of each entity type, the full Session struct as metadata, and a CRC32 checksum for integrity.

The snapshot body follows the header as raw byte slices of each region. Restore reads the header, validates the checksum, allocates arena space for each region, and reads the bytes directly into structs. Bit-identical round trip. Session IDs are preserved — the session continues exactly where it left off.

---

### CowPageTable

```zig
pub const CowPageTable = struct {
    parent_session_id: VdrId = .{},
    clone_session_id: VdrId = .{},
    n_pages: i32 = 0,
    dirty_bits: []u8 = &.{},
    // ...
};
```

Copy-on-write tracking for cloned sessions. When a session is cloned, the clone shares the parent's arena pages. The dirty_bits bitmap tracks which pages have been written by the clone. `isDirty()` checks a specific page. `markDirty()` sets the bit when the clone writes to a page, triggering a copy of that page into the clone's private memory.

This means cloning a session is nearly instant — no data copying until the clone actually modifies something. Most clones read far more than they write, so the majority of pages are never copied.

---

## Configuration Types

### SystemConfig

```zig
pub const SystemConfig = struct {
    n_cores: i32 = 0,
    model: ModelConfig = .{},
    global_arena_bytes: i64 = 3 * 1024 * 1024 * 1024,
    per_core_arena_bytes: i64 = 256 * 1024 * 1024,
    http_port: i32 = 1138,
    // ... limits, sessions, runners, safety, seed, sampling, prolog, context ...
};
```

The single source of truth for system sizing. Loaded from a JSON config file at startup via `std.json`. Hard-mapped — every JSON field maps to a struct field. Unknown fields are errors. Missing required fields are errors. No hardcoded fallbacks.

Contains nested configs: `ModelConfig` (layer count, dimensions, vocab size), `SamplingConfig` (mode, temperature, top_k, top_p), `PrologConfig` (depth limits, binding limits), `ContextConfig` (system prompt KB, scope KB, token limits), `SeedConfig` (snapshot path, fresh creation flag).

---

### ModelConfig

```zig
pub const ModelConfig = struct {
    n_layers: i32 = 16,
    d_model: i32 = 2048,
    n_heads: i32 = 16,
    d_head: i32 = 128,
    vocab_size: i32 = 32000,
    mlp_dim: i32 = 5632,
    max_seq_len: i32 = 2048,
    // ...
};
```

Model architecture parameters. `totalParams()` computes the total parameter count from dimensions (embedding + per-layer QKV/output/MLP + lm_head). `weightBytes()` returns total memory for i16 weights. These drive arena sizing — the system knows at startup exactly how much memory model weights will require.

---

### LevelStats

```zig
pub const LevelStats = struct {
    l1_count: i64 = 0,
    l1_tokens: i64 = 0,
    l2_count: i64 = 0,
    l2_tokens: i64 = 0,
    l3_count: i64 = 0,
};
```

Tracks execution level distribution. L1 is full LLM forward pass (50-500 tokens). L2 is LLM invoking a stored rule (~18 tokens). L3 is pure Prolog (0 tokens). `autoTriageNum()`/`autoTriageDen()` give the L3 ratio as a fraction — at maturity, this should be 93% or higher. `avgTokensPerInteraction()` returns the mean token cost as a Q16 value.

---

### IoSe

```zig
pub const IoSe = struct {
    builtin_id: i32 = 0,
    category: BuiltinCategory = .text_ops,
    name: [64]u8 = [_]u8{0} ** 64,
    // ... input/output types, side effects, grant class, bounds ...
};
```

IOSE (Input, Output, Side-effects, Errors) declaration for a builtin function. 448 builtins across 22 categories (text_ops, collections, sets, mappings, arithmetic, comparison, linear_algebra, statistics, etc.). Each declaration specifies its input types, output type, whether it has side effects, whether it requires a grant, its maximum input size, and whether it's bounded and deterministic.

`isPure()` returns true for builtins with no side effects and deterministic behavior — these can be freely cached and reordered. `requiresGrant()` returns true for operational builtins that need filesystem, compile, execute, network, or process grants.

---

## Seed Constants

### SEED

```zig
pub const SEED = struct {
    pub const ROOT: VdrId = .{ .v = 1 };
    pub const SYSTEM: VdrId = .{ .v = 2 };
    pub const OSO: VdrId = .{ .v = 3 };
    // ...
    pub const EMBEDDING: VdrId = .{ .v = 8 };
    pub const OUTPUT: VdrId = .{ .v = 9 };
    pub const TEMPLATES: VdrId = .{ .v = 10 };
    pub const SENTENCES: VdrId = .{ .v = 11 };
    pub const FORMATS: VdrId = .{ .v = 12 };
    pub const SEED_KB_COUNT: i32 = 12;
};
```

Well-known IDs for the seed KBs created at startup. These are the first 12 global KBs in the tree. `SYSTEM` and its children (OSO, CONFIDENCE, BUILTINS, COMMAND_VOCAB, HYGIENE, EMBEDDING, OUTPUT) are frozen after init. `EMBEDDING` and `OUTPUT` are normal global KBs with grant-based access — they hold the vocabulary embedding table and lm_head/final norm weights respectively. Domain KBs with their own weights are created beyond these seed IDs.

---

# VDR-Prolog Struct Reference — Addendum

## Compaction-Driven Model Reduction Structs

This addendum covers the typed relation system, compaction ingestion infrastructure, and model reduction analysis structs added to support LLM-compacted data ingestion and the structural reduction of the neural network.

---

## New Structs

### RelationType

```zig
pub const RelationType = enum(i16) {
    enables = 0, requires = 1, prevents = 2, implements = 3,
    // ... 20 system-defined slots (0-19)
    // ... 64 domain-registerable slots (64-127)
    unknown = -1,
};
```

The vocabulary of structural relationships in the system. An i16 enum with two ranges: system-defined slots 0-19 are frozen after init and carry compile-time-known structural properties; domain-registerable slots 64-127 are assigned during compaction ingestion when a document introduces relationship types not in the system set.

The enum is i16 because the domain slots reach 127 — signed i8 maxes at 127 but the `unknown = -1` sentinel needs the negative range too, and squeezing both into i8 leaves zero headroom. i16 gives clean range for all 128 slots plus the sentinel with no ambiguity.

Three methods encode structural properties that the Prolog engine uses for L3 reasoning without the LLM:

**`inverse()`** — returns the reverse edge type. `enables.inverse()` returns `depends_on`. `part_of.inverse()` returns `contains`. Symmetric types return themselves. This is a switch on the enum — compile-time known, zero cost. When a query asks "what depends on X?", the engine automatically also queries "X enables what?" via the inverse. No rule needed. No LLM token consumed.

**`isTransitive()`** — returns true for types where chains compose. `enables(A,B)` and `enables(B,C)` yields `enables(A,C)`. Ten of the twenty system types are transitive: enables, requires, extends, specializes, generalizes, part_of, contains, follows, precedes, depends_on. The Prolog engine computes transitive closure via BFS over contiguous integer arrays at L3 — what a conventional LLM would need multiple attention layers to discover.

**`isSymmetric()`** — returns true for bidirectional types. `prevents(A,B)` means `prevents(B,A)` is also true. Four system types are symmetric: prevents, contradicts, equivalent_to, approximates. The engine auto-queries the swapped direction without storing the reverse edge.

**`isSystemDefined()`** and **`isDomain()`** — range checks for slot classification. System slots are 0-19, domain slots are 64-127. The gap (20-63) is reserved for future system types.

Used by: the ingestion pipeline (maps relationship strings from compacted documents to enum values), the Prolog engine's typed relation fast path (dispatches on enum for index lookup, transitive closure, inverse), the RelationIndex (groups relations by enum slot), and domain relation registration (assigns custom types to domain slots).

---

### TypedRelation

```zig
pub const TypedRelation = struct {
    rel_type: RelationType = .unknown,
    from_id: VdrId = .{},
    to_id: VdrId = .{},
    provenance: Provenance = .{},
    strength: Q16 = .{},
    scope_kb_id: VdrId = .{},
};
```

A first-class typed edge between two entities. 48 bytes — same as Fact, which keeps contiguous arrays cache-aligned at the same stride.

This is what the ingestion pipeline produces from relationship rows in compacted documents. The row `P1|enables|AR1` becomes a TypedRelation with `rel_type = .enables`, `from_id` = P1's VdrId, `to_id` = AR1's VdrId. It is also what the Prolog engine's transitive closure and inverse operations produce as derived relations.

**`rel_type`** — the RelationType enum value. This is what makes typed relations faster than general Prolog rules for structural queries: the engine dispatches on an integer enum, not a functor lookup through the term store.

**`from_id` and `to_id`** — the source and target entities as VdrIds. These are the actual IDs of facts or concepts in KBs, not Prolog term offsets. The engine matches them via `VdrId.eql()` — a single i64 comparison.

**`provenance`** — full provenance, same as on Facts. For ingested relations, this carries the confidence chain: the source document's confidence combined with the compaction stage's confidence (minimum of the two). `capability_level` in provenance enables per-relation access control through the same mechanism as per-weight access.

**`strength`** — Q16 value for weighted relations. Zero (all three fields: v=0, r0=0, r1=0) means binary — the relation either holds or doesn't. Nonzero means weighted — similarity scores, confidence-weighted edges, partial membership. `isBinary()` and `isWeighted()` check this. Most ingested relations from compacted documents are binary. Weighted relations come from computed similarity, training-derived association strength, or explicit confidence annotations.

**`scope_kb_id`** — which KB this relation is authoritative in. Used for provenance tracking and grant checking — a session without access to the scope KB cannot query this relation. Also used by the RelationIndex to group relations per KB.

Every TypedRelation in a KB has a corresponding TAG_RELATION Fact in the same KB. The Fact provides the standard provenance interface (the same provenance that every other piece of data carries), and its `value.v` field is the index into the KB's relations array. This means relations participate in the normal fact scanning, confidence propagation, and access control systems without special cases.

---

### DomainRelationDef

```zig
pub const DomainRelationDef = struct {
    slot: i16 = 64,
    name_offset: i32 = 0,
    name_length: i16 = 0,
    is_symmetric: bool = false,
    is_transitive: bool = false,
    inverse_slot: i16 = -1,
    source_document_id: VdrId = .{},
    registered_at: i32 = 0,
};
```

Registration record for a domain-specific relationship type. 32 bytes. When a compacted document's decode legend includes a relationship type not in the system enum (e.g., `catalyzes` in chemistry, `refutes` in philosophy, `depends_on_version` in software), the ingestion pipeline registers it here and assigns it a domain slot.

**`slot`** — which domain_N slot (64-127) this definition occupies. Assigned first-come during ingestion. Never reassigned within a running instance. If a second document uses the same relationship name, it reuses the existing slot — the properties must match or the ingestion fails with a validation error.

**`name_offset` / `name_length`** — the relationship name in the text store. "catalyzes", "refutes", etc. This is what the ingestion parser matches against when it encounters a relationship type string not in the system enum.

**`is_symmetric` and `is_transitive`** — structural properties declared by the compaction guide or inferred by the ingestion pipeline. These drive the Prolog engine's automatic behavior for this domain type — if `catalyzes` is declared transitive, transitive closure works for it just like for system-defined transitive types. If not declared, the engine treats it as non-transitive (no automatic chaining).

**`inverse_slot`** — i16 pointing to the domain slot of the inverse type, or -1 if no inverse is defined. If a chemistry domain declares both `catalyzes` (slot 64) and `catalyzed_by` (slot 65), they reference each other as inverses. The Prolog engine uses this for automatic inverse dispatch the same way it uses `RelationType.inverse()` for system types.

**`source_document_id`** — which compacted document registered this type. Provenance. If the document is later retracted, the domain slot can be noted as orphaned (but not reassigned during this instance).

**`registered_at`** — integer timestamp of registration.

DomainRelationDefs are stored as facts in `root.system.relation_types` (seed KB +13). They persist across restarts via normal KB persistence. The system-defined types (slots 0-19) are stored as frozen facts in the same KB. Domain types are appended — the KB is not frozen for the domain range.

---

### RelationIndex

```zig
pub const RELATION_TYPE_SLOTS: usize = 128;

pub const RelationIndex = struct {
    by_type_offset: i32 = -1,
    by_type_counts: [128]i32 = [_]i32{0} ** 128,
    by_from_offset: i32 = -1,
    by_from_count: i32 = 0,
    by_to_offset: i32 = -1,
    by_to_count: i32 = 0,
    total_relations: i32 = 0,
    last_rebuilt: i32 = 0,
};
```

The acceleration structure for typed relation queries. Lives per-KB — each KB with relations has its own RelationIndex. The struct is ~528 bytes (dominated by the 128-slot count array).

**`by_type_counts`** — 128 i32 values, one per RelationType slot. `by_type_counts[@intFromEnum(.enables)]` tells you instantly how many `enables` relations this KB has. If zero, the Prolog engine skips this KB entirely for `enables` queries — no scanning, no allocation, no wasted cycles. This is the first check in the typed relation fast path.

**`by_type_offset`** — offset into the arena where TypedRelation arrays are stored, grouped by type. All `enables` relations are contiguous, then all `requires` relations, etc. This means scanning all `enables` relations in a KB reads a contiguous memory block — cache-friendly, no interleaving with other types.

**`by_from_offset` / `by_from_count`** — offset to a sorted-by-from-id index. Used for "everything that X relates to" queries. The index maps VdrId → range of TypedRelation entries. Binary search on VdrId.v finds the range, then linear scan within the range.

**`by_to_offset` / `by_to_count`** — same structure sorted by to_id. Used for "everything that relates to Y" queries.

**`total_relations`** — total count across all types. Used by `isDirty()` to detect when the index needs rebuilding — if `total_relations != kb.relations_count`, new relations were asserted since the last rebuild.

**`last_rebuilt`** — integer timestamp of last rebuild. The index is eventually consistent — rebuilt periodically (configurable via `relation_index_rebuild_interval` in SystemConfig, default every 100 relation assertions), not on every assertion. Between rebuilds, new relations are in the KB's relations array but not in the index. The Prolog engine falls back to linear scan of the relations array for unindexed relations. At maturity, rebuilds are infrequent because ingestion is batch, not continuous.

`countForType()` reads a single i32 from the count array. `hasType()` checks if the count is nonzero. Both are O(1). The typed relation fast path in the Prolog engine calls `hasType()` first — if the KB has zero relations of the requested type, the entire KB is skipped in microseconds.

---

### CompactionProfile

```zig
pub const CompactionProfile = struct {
    source_document_id: VdrId = .{},
    tables_ingested: i32 = 0,
    rows_ingested: i32 = 0,
    facts_created: i32 = 0,
    relations_created: i32 = 0,
    rules_created: i32 = 0,
    relation_types_used: [128]bool = [_]bool{false} ** 128,
    domain_types_registered: i32 = 0,
    text_bytes_stored: i32 = 0,
    numeric_values_stored: i32 = 0,
    compression_ratio: Q16 = .{},
    ingestion_timestamp: i32 = 0,
    validation_errors: i32 = 0,
};
```

Audit record per ingested compacted document. ~256 bytes. Created during ingestion, immutable afterward. Stored as a fact in the `root.system.ingestion` seed KB and referenced by the parent document KB via `compaction_profile_offset`.

**`source_document_id`** — VdrId of the parent document KB created during ingestion (e.g., the KB at `root.knowledge.math.math_4`).

**`tables_ingested`** — how many tables the compacted document contained (each becomes a child KB).

**`rows_ingested`** — total rows across all tables (each becomes a group of facts).

**`facts_created`, `relations_created`, `rules_created`** — the output counts. These are what the ingestion actually produced. `totalEntities()` sums all three.

**`relation_types_used`** — boolean array indexed by RelationType slot. Shows which relationship types appeared in this document. `relationTypeCount()` counts the trues. This feeds model reduction analysis: if a document covers 12 of the 20 system-defined relationship types, it provides significant structural coverage.

**`domain_types_registered`** — how many new domain slots this document's decode legend registered. Typically 0-5 per document.

**`text_bytes_stored`** — total text content stored in the text store from this document's cells.

**`numeric_values_stored`** — how many cells were detected as numeric and stored as TAG_VALUE facts instead of TAG_TEXT.

**`compression_ratio`** — Q16 value of original_bytes / compacted_bytes. For a 50,000-byte paper compacted to 5,000 bytes, this is Q16.fromParts(10, 0, 0) representing 10×. Stored as Q16 for fractional ratios.

**`ingestion_timestamp`** — when the ingestion completed.

**`validation_errors`** — how many validation errors were encountered (and resolved or accepted) during ingestion. Zero means clean ingestion. Nonzero means some references were missing or column counts mismatched — the document was still ingested but with warnings recorded.

Used by: model reduction analysis (aggregate `relations_created` and `relation_types_used` across all profiles to estimate L3 coverage), hygiene runners (monitor ingestion quality over time), and admin queries ("how much structure have we ingested?").

---

### ModelReductionConfig

```zig
pub const ModelReductionConfig = struct {
    base_n_layers: i32 = 16,
    base_mlp_dim: i32 = 5632,
    base_n_heads: i32 = 16,
    base_vocab_size: i32 = 32000,

    reduced_n_layers: i32 = 6,
    reduced_mlp_dim: i32 = 2048,
    reduced_n_heads: i32 = 12,
    reduced_vocab_size: i32 = 8192,

    relation_types_covered: i32 = 0,
    total_typed_relations: i32 = 0,
    total_prolog_rules: i32 = 0,
    estimated_l3_coverage: Q16 = .{},

    use_i16_weights: bool = true,

    pub fn estimatedWeightBytes(self: ModelReductionConfig) i64 { ... }
};
```

Advisory struct that links compaction analysis to model architecture sizing. Lives in SystemConfig. The admin or a hygiene runner populates the analysis fields (`relation_types_covered`, `total_typed_relations`, `total_prolog_rules`, `estimated_l3_coverage`) from CompactionProfile aggregates, then decides the reduced architecture parameters.

**`base_*` fields** — the conventional architecture this system would need without compaction. 16 layers, 5632 MLP width, 16 heads, 32K vocab. These are reference values for comparison, not operational parameters.

**`reduced_*` fields** — the target architecture with compaction carrying the structural reasoning load. 6 layers, 2048 MLP width, 12 heads, 8K vocab. These are what the admin sets in the config JSON and what ModelConfig reads.

**`relation_types_covered`** — how many of the 128 RelationType slots have at least one relation in any KB. Aggregated from CompactionProfile `relation_types_used` arrays across all ingested documents. Higher means more structural diversity is covered by L3.

**`total_typed_relations`** — total TypedRelation count across all KBs. Each one is a reasoning path the neural network doesn't need. 2,000+ relations across 15+ types is where the model reduction becomes defensible.

**`total_prolog_rules`** — total Prolog rules across all KBs. Includes both relation-derived rules and general rules from seed and domain KBs.

**`estimated_l3_coverage`** — Q16 fraction estimating what percentage of typical queries can be handled at L3 given the current relation and rule coverage. This is the admin's judgment — the system provides the data, the admin interprets it.

**`use_i16_weights`** — whether model weights are stored as i16 (2 bytes, half the i32 weight budget). The reduced model at 143M params × 2 bytes = 286 MB. At i32 it would be 572 MB. i16 is the design point.

**`estimatedWeightBytes()`** — computes total weight memory from the reduced architecture parameters. Used for arena sizing verification: if the estimated weight bytes exceed the global arena's weight budget, the config is invalid.

The design decision to keep this advisory (not auto-reducing) is important. The admin sees the compaction metrics, understands the domain coverage, and decides whether 6 layers is appropriate or whether 8 are needed because the domain has unusual reasoning patterns. The system provides estimates, not mandates.

---

## Modified Structs

### FactTag — Two New Variants

Two new enum values added at slots 12 and 13 (empty remains at 255):

**`relation = 12`** — marks a Fact whose `value.v` is an index into the KB's relations array. The Fact exists to provide standard provenance on the TypedRelation (every TypedRelation gets a companion TAG_RELATION Fact). This means relations participate in normal fact scanning, confidence queries, and access control without any special-case code paths. The Provenance on the Fact is the canonical provenance for the relation.

**`column_schema = 13`** — marks a Fact that defines a column in an ingested table KB. `value.v` is the column index (0, 1, 2, ...), the text store holds the column name. These are the first N facts in any table KB created by the ingestion pipeline. The system reads them to reconstruct the table schema — "column 0 is 'id', column 1 is 'principle', column 2 is 'rationale'." Without these, the column names would be lost after ingestion and the data would be positional-only.

### KB — Seven New Fields

Six new i32 offset/count fields and one i32 for compaction provenance, totaling 28 bytes. These fit within the existing padding to 256 bytes. The KB struct was already padded — these fields consume slack space, not new space.

**`relations_offset: i32 = -1`** — offset into the arena where this KB's TypedRelation array begins. -1 means no relations. Set during ingestion when relationships are asserted, or during Prolog rule firing when derived relations are created.

**`relations_count: i32 = 0`** — current number of TypedRelations in the array.

**`relations_capacity: i32 = 0`** — allocated capacity of the relations array. Same grow-or-fail pattern as facts and rules.

**`relation_index_offset: i32 = -1`** — offset to this KB's RelationIndex in the arena. -1 means no index built yet. Built on first query or during periodic rebuild. `hasRelationIndex()` checks this.

**`domain_rel_defs_offset: i32 = -1`** — offset to DomainRelationDef array. Only populated on KBs that register domain-specific relationship types — typically the parent document KB whose decode legend introduced new types. Most KBs have -1 here. `hasDomainRelDefs()` checks this.

**`domain_rel_defs_count: i32 = 0`** — count of domain definitions registered by this KB.

**`compaction_profile_offset: i32 = -1`** — offset to CompactionProfile for this KB. Only set on KBs created by the ingestion pipeline. -1 for all other KBs. `isFromCompaction()` checks this — useful for distinguishing hand-created KBs from ingested ones in queries and hygiene operations.

### SystemConfig — Three New Fields

**`model_reduction: ModelReductionConfig = .{}`** — the advisory model reduction analysis. Loaded from the `model_reduction` section of config.json. The admin fills in the reduced architecture parameters and the system uses `estimatedWeightBytes()` for arena sizing verification.

**`ingestion: IngestionConfig = .{}`** — defaults for compaction ingestion. Contains `source_type` (default published), `generate_rules` (default true), `generate_typed_relations` (default true), `detect_numeric` (default true), `max_facts_per_table` (default 10000), `freeze_after_ingest` (default true), `max_domain_relation_defs` (default 64). Loaded from the `ingestion` section of config.json.

**`relation_index_rebuild_interval: i32 = 100`** — how many relation assertions trigger an index rebuild. Default 100. Lower values mean more frequent rebuilds (more current index, more rebuild CPU cost). Higher values mean less frequent rebuilds (staler index, less CPU cost). At maturity, ingestion is batch and infrequent, so this value matters mainly during initial data loading.

### LevelStats — Three New Counters and One New Method

**`l3_relation_queries: i64 = 0`** — L3 operations that were typed relation index lookups. Incremented when the Prolog engine's typed relation fast path handles a query without general unification.

**`l3_transitive_closures: i64 = 0`** — L3 operations that were transitive chain resolutions. Incremented when the engine computes a transitive closure (BFS over relation chains) at L3.

**`l3_inverse_lookups: i64 = 0`** — L3 operations that used `inverse()` dispatch to find reverse edges. Incremented when the engine automatically queries the inverse type.

**`l3RelationRatio()`** — returns a Q16 fraction: (relation_queries + transitive_closures + inverse_lookups) / total l3_count. This tells you how much of L3 is structural relation operations vs. general Prolog. If high (>70%), the typed relation system is carrying its weight — compaction is paying off. If low (<30%), the compacted data isn't being used for queries and the model reduction may be too aggressive, or the wrong kinds of questions are being asked.

### SEED — Two New Seed KBs

**`RELATION_TYPES: VdrId = .{ .v = 13 }`** — `root.system.relation_types`. Holds the system-defined RelationType definitions as frozen facts (slots 0-19) and domain-registered DomainRelationDefs as appendable facts (slots 64-127). The KB is not fully frozen — the system range is frozen, the domain range accepts new registrations during ingestion.

**`INGESTION: VdrId = .{ .v = 14 }`** — `root.system.ingestion`. Holds the ingestion queue (facts referencing pending .compact files) and CompactionProfile records (one per successfully ingested document). Batch ingestion runners read the queue. Admin and hygiene queries read the profiles for coverage analysis.

**`SEED_KB_COUNT`** bumps from 12 to 14.

---

## Structs That Live Elsewhere

The ingestion pipeline has its own parse-time structs that do not go in `vdr_types.zig`. These live in `vdr_ingestion.zig` and exist only in temporary arenas during ingestion:

**`CompactDocument`** — top-level container for a parsed .compact file. Holds arrays of CompactTable, CompactRelationship, CompactLegendEntry, and CompactSectionEntry. Destroyed after facts and rules are asserted.

**`CompactTable`** — a parsed table with column definitions and row arrays. Up to 32 columns, up to 10,000 rows per table.

**`CompactRow`** — a parsed row with an array of CompactCell values. One cell per column.

**`CompactCell`** — a single cell value with text offset/length, numeric detection flag, and parsed numeric value if applicable.

**`CompactColumn`** — column definition with name, index, and detected type (text, integer, q16_value, id_ref, id_list).

**`CompactRelationship`** — a parsed relationship row with from/rel/to text references.

**`CompactLegendEntry`** — a key-value pair from the decode legend.

**`CompactSectionEntry`** — a section index entry mapping section ID to title and referenced IDs.

**`ValidationResult`** and **`ValidationError`** — validation output. Error types: duplicate_id, undefined_reference, column_mismatch, missing_legend, invalid_table_header, empty_document.

These structs are deliberately kept out of `vdr_types.zig` because they serve no purpose after ingestion completes. They exist for the duration of one function call (`ingestDocument`), in a temporary arena that is destroyed afterward. Putting them in the core types file would imply they are part of the system's persistent data model, which they are not. They are the scaffolding, not the building.
