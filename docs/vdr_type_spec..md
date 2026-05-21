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
