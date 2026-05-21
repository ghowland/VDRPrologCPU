// ============================================================
// vdr_types.zig
// All types for VDR-Prolog CPU SIMD system.
// Every struct has defaults so TypeName{} works.
// Zig 0.15.1 target. x86_64 only.
// ============================================================

// ============================================================
// Fundamental: VDR ID — sign-bit partitioned addressing
// Positive = global (persistent). Negative = ephemeral (session-local).
// ============================================================

pub const VdrId = struct {
    v: i64 = 0,

    pub const NONE: VdrId = .{ .v = 0 };
    pub const ROOT: VdrId = .{ .v = 1 };
    pub const EPHEMERAL_ROOT: VdrId = .{ .v = -1 };

    pub fn isGlobal(self: VdrId) bool {
        return self.v >= 0;
    }
    pub fn isEphemeral(self: VdrId) bool {
        return self.v < 0;
    }
    pub fn isNone(self: VdrId) bool {
        return self.v == 0;
    }
    pub fn eql(a: VdrId, b: VdrId) bool {
        return a.v == b.v;
    }
};

// ============================================================
// Fundamental: Q16 — exact rational arithmetic
// D = 65536 (2^16). Implicit. Never stored.
// Two remainder slots. No wasted padding.
// ============================================================

pub const D16: i32 = 65536;
pub const D32: i64 = 4294967296;

pub const Q16 = struct {
    v: i32 = 0,
    r0: i16 = 0,
    r1: i16 = 0,

    pub const D: i32 = D16;

    pub fn zero() Q16 {
        return .{};
    }
    pub fn one() Q16 {
        return .{ .v = D16 };
    }

    pub fn fromParts(v: i32, r0: i16, r1: i16) Q16 {
        return .{ .v = v, .r0 = r0, .r1 = r1 };
    }

    pub fn add(a: Q16, b: Q16) Q16 {
        const r1_sum: i32 = @as(i32, a.r1) + @as(i32, b.r1);
        const r1_carry: i32 = @divTrunc(r1_sum, 32768);
        const new_r1: i16 = @intCast(@mod(r1_sum, 32768));
        const r0_sum: i32 = @as(i32, a.r0) + @as(i32, b.r0) + r1_carry;
        const r0_carry: i64 = if (r0_sum >= D16) 1 else 0;
        const new_r0: i16 = @intCast(@mod(r0_sum, D16));
        const new_v: i32 = @intCast(@as(i64, a.v) + @as(i64, b.v) + r0_carry);
        return .{ .v = new_v, .r0 = new_r0, .r1 = new_r1 };
    }

    pub fn sub(a: Q16, b: Q16) Q16 {
        var r1_diff: i32 = @as(i32, a.r1) - @as(i32, b.r1);
        var r1_borrow: i32 = 0;
        if (r1_diff < 0) {
            r1_diff += 32768;
            r1_borrow = 1;
        }
        var r0_diff: i32 = @as(i32, a.r0) - @as(i32, b.r0) - r1_borrow;
        var r0_borrow: i64 = 0;
        if (r0_diff < 0) {
            r0_diff += D16;
            r0_borrow = 1;
        }
        const new_v: i32 = @intCast(@as(i64, a.v) - @as(i64, b.v) - r0_borrow);
        return .{ .v = new_v, .r0 = @intCast(r0_diff), .r1 = @intCast(r1_diff) };
    }

    pub fn mul(a: Q16, b: Q16) Q16 {
        const product: i64 = @as(i64, a.v) * @as(i64, b.v);
        const new_v: i32 = @intCast(@divTrunc(product, D16));
        const r0_full: i64 = @mod(product, D16);
        const r1_product: i64 = @as(i64, a.r0) * @as(i64, b.v) + @as(i64, b.r0) * @as(i64, a.v);
        const new_r1: i16 = @intCast(@mod(@divTrunc(r1_product, D16), 32768));
        return .{ .v = new_v, .r0 = @intCast(r0_full), .r1 = new_r1 };
    }

    pub fn div(a: Q16, b: Q16) Q16 {
        if (b.v == 0) return zero();
        const widened: i64 = @as(i64, a.v) * D16;
        const new_v: i32 = @intCast(@divTrunc(widened, @as(i64, b.v)));
        const r0_full: i64 = @mod(widened, @as(i64, b.v));
        const r1_widened: i64 = r0_full * D16;
        const new_r1: i16 = @intCast(@mod(@divTrunc(r1_widened, @as(i64, b.v)), 32768));
        return .{ .v = new_v, .r0 = @intCast(r0_full), .r1 = new_r1 };
    }

    pub fn compare(a: Q16, b: Q16) i32 {
        if (a.v < b.v) return -1;
        if (a.v > b.v) return 1;
        if (a.r0 < b.r0) return -1;
        if (a.r0 > b.r0) return 1;
        if (a.r1 < b.r1) return -1;
        if (a.r1 > b.r1) return 1;
        return 0;
    }

    pub fn eql(a: Q16, b: Q16) bool {
        return a.v == b.v and a.r0 == b.r0 and a.r1 == b.r1;
    }
};

pub const Q32 = struct {
    v: i64 = 0,
    r0: i32 = 0,
    r1: i32 = 0,

    pub fn zero() Q32 {
        return .{};
    }
    pub fn one() Q32 {
        return .{ .v = @intCast(D32) };
    }

    pub fn fromQ16(q: Q16) Q32 {
        const scaled: i64 = @as(i64, q.v) * (D32 / Q16.D);
        return .{ .v = scaled, .r0 = @as(i32, q.r0), .r1 = 0 };
    }

    pub fn toQ16(self: Q32) Q16 {
        const scaled: i64 = @divTrunc(self.v * Q16.D, D32);
        return .{ .v = @intCast(scaled), .r0 = @intCast(@mod(self.v, Q16.D)), .r1 = 0 };
    }
};

pub const Q335 = struct {
    v: [6]i64 = .{0} ** 6,
    r0: [6]i64 = .{0} ** 6,
    r1: [6]i64 = .{0} ** 6,
    r2: [6]i64 = .{0} ** 6,
    r3: [6]i64 = .{0} ** 6,

    pub fn zero() Q335 {
        return .{};
    }
};

// ============================================================
// KB Types — the data layer
// ============================================================

pub const FactTag = enum(i32) {
    value = 0,
    text = 1,
    reference = 2,
    timestamp = 3,
    enum_tag = 4,
    boolean = 5,
    vector = 6,
    matrix = 7,
    provenance_tag = 8,
    rule_ref = 9,
    grammar_ref = 10,
    counter = 11,
    relation = 12,
    column_schema = 13,
    empty = 255,
};

pub const SourceType = enum(i32) {
    vdr_computation = 0,
    prolog_derivation = 1,
    database = 2,
    prometheus = 3,
    script = 4,
    rest_api = 5,
    published = 6,
    user_stated = 7,
    web_search = 8,
    llm_generated = 9,
    unknown = 10,
};

pub const Provenance = struct {
    source_type: i32 = @intFromEnum(SourceType.unknown),
    source_kb_id: VdrId = .{},
    source_slot_id: i32 = -1,
    confidence: Q16 = .{},
    timestamp: i32 = 0,
    derivation_rule_id: i32 = -1,
    capability_level: i32 = 0, // for per-weight access control

    pub fn direct(source: SourceType, kb_id: VdrId, slot_id: i32, time: i32) Provenance {
        return .{
            .source_type = @intFromEnum(source),
            .source_kb_id = kb_id,
            .source_slot_id = slot_id,
            .confidence = confidence_table[@intCast(@intFromEnum(source))],
            .timestamp = time,
            .derivation_rule_id = -1,
            .capability_level = 0,
        };
    }

    pub fn derived(rule_id: i32, kb_id: VdrId, slot_id: i32, conf: Q16, time: i32) Provenance {
        return .{
            .source_type = @intFromEnum(SourceType.prolog_derivation),
            .source_kb_id = kb_id,
            .source_slot_id = slot_id,
            .confidence = conf,
            .timestamp = time,
            .derivation_rule_id = rule_id,
            .capability_level = 0,
        };
    }
};

// ============================================================
// GEMM Cache — contiguous, cache-line aligned, per-KB
// Rebuilt on demand from Facts. Ephemeral in scratch arena.
// ============================================================

pub const CACHE_LINE: usize = 64;

pub const GemmCache = struct {
    v_packed: []i32 = &.{}, // contiguous v fields, SIMD-ready
    fact_count: i32 = 0, // entries in cache
    kb_id: VdrId = .{}, // source KB
    kb_last_modified: i32 = 0, // timestamp at rebuild
    generation: i32 = 0, // increments on rebuild

    pub fn isDirty(self: GemmCache, kb_modified: i32) bool {
        return kb_modified > self.kb_last_modified;
    }
};

// ============================================================
// Weight Matrix — SoA packed, cache-line aligned per array
// Referenced by TAG_MATRIX Facts. GEMM reads v directly.
// ============================================================

pub const WeightMatrix = struct {
    v: []i32 = &.{}, // values, contiguous, GEMM-ready
    r0: []i16 = &.{}, // remainder level 0
    r1: []i16 = &.{}, // remainder level 1
    rows: i32 = 0,
    cols: i32 = 0,

    pub fn elementCount(self: WeightMatrix) i64 {
        return @as(i64, self.rows) * @as(i64, self.cols);
    }

    pub fn bytesV(self: WeightMatrix) i64 {
        return self.elementCount() * 4;
    }

    pub fn bytesTotal(self: WeightMatrix) i64 {
        return self.elementCount() * 8; // v:4 + r0:2 + r1:2
    }
};

// ============================================================
// Fact — the atomic unit of knowledge
// 48 bytes. Tag determines interpretation of value field.
// TAG_MATRIX/TAG_VECTOR facts reference WeightMatrix/WeightVector.
// ============================================================

pub const Fact = struct {
    tag: FactTag = .empty,
    value: Q16 = .{},
    provenance: Provenance = .{},

    // Matrix/vector reference — used when tag is TAG_MATRIX or TAG_VECTOR
    // value.v = index into KB's matrix_refs or vector_refs array
    // value.r0 = unused (0)
    // value.r1 = unused (0)
    // Dimensions and data pointers live in the referenced WeightMatrix/WeightVector.

    pub fn isEmpty(self: Fact) bool {
        return self.tag == .empty;
    }

    pub fn isMatrix(self: Fact) bool {
        return self.tag == .matrix;
    }
    pub fn isVector(self: Fact) bool {
        return self.tag == .vector;
    }

    pub fn matrixRefIndex(self: Fact) i32 {
        return self.value.v;
    }
};

// ============================================================
// Weight Vector — 1D version of WeightMatrix
// Same SoA layout, cache-line aligned.
// ============================================================

pub const WeightVector = struct {
    v: []i32 = &.{},
    r0: []i16 = &.{},
    r1: []i16 = &.{},
    length: i32 = 0,

    pub fn bytes(self: WeightVector) i64 {
        return @as(i64, self.length) * 8;
    }
};

// ============================================================
// KB extension — matrix/vector ref tables
// Each KB can hold references to its weight data.
// ============================================================

pub const KbWeightRefs = struct {
    matrix_refs: []WeightMatrix = &.{},
    matrix_count: i32 = 0,
    matrix_capacity: i32 = 0,

    vector_refs: []WeightVector = &.{},
    vector_count: i32 = 0,
    vector_capacity: i32 = 0,

    // Per-KB GEMM cache for non-matrix fact data
    gemm_cache: ?GemmCache = null,
};

pub const KB = struct {
    id: VdrId = .{},
    parent_id: VdrId = .{ .v = -1 },
    name_offset: i32 = 0,
    name_length: i16 = 0,
    path_offset: i32 = 0,
    path_length: i16 = 0,
    walk_id: i32 = 0,

    // Persistent stores
    facts_offset: i32 = 0,
    facts_count: i32 = 0,
    facts_capacity: i32 = 0,
    rules_offset: i32 = 0,
    rules_count: i32 = 0,
    rules_capacity: i32 = 0,
    constraints_offset: i32 = -1,
    constraints_count: i32 = 0,
    connections_offset: i32 = -1,
    connections_count: i32 = 0,
    grammars_offset: i32 = -1,
    grammars_count: i32 = 0,
    iose_offset: i32 = -1,

    // Weight references
    weight_refs_offset: i32 = -1,

    // Typed relations
    relations_offset: i32 = -1,
    relations_count: i32 = 0,
    relations_capacity: i32 = 0,
    relation_index_offset: i32 = -1,

    // Domain relation definitions (only on schema/document KBs)
    domain_rel_defs_offset: i32 = -1,
    domain_rel_defs_count: i32 = 0,

    // Compaction provenance
    compaction_profile_offset: i32 = -1,

    // Live state
    working_data_offset: i32 = -1,
    lru_table_offset: i32 = -1,
    lru_count: i16 = 0,
    counter_table_offset: i32 = -1,
    counter_count: i16 = 0,
    lock_table_offset: i32 = -1,
    lock_count: i16 = 0,
    queue_table_offset: i32 = -1,
    queue_count: i16 = 0,
    stack_table_offset: i32 = -1,
    stack_count: i16 = 0,
    ring_table_offset: i32 = -1,
    ring_count: i16 = 0,
    bitset_table_offset: i32 = -1,
    bitset_count: i16 = 0,

    // New facts since last training
    new_facts_since_training_offset: i32 = -1,
    new_facts_since_training_count: i32 = 0,

    // Children
    children_offset: i32 = -1,
    children_count: i16 = 0,
    children_capacity: i16 = 0,
    mounts_offset: i32 = -1,
    mounts_count: i16 = 0,

    // Training
    training_lock: bool = false,
    training_arena: ?*Arena = null,

    // Metadata
    visibility: i8 = 1,
    frozen: i8 = 0,
    owner_id: VdrId = .{},
    created_at: i32 = 0,
    last_modified: i32 = 0,
    version: i32 = 1,

    // Padded to 256 bytes for cache line alignment.
    // training_arena is the only nullable pointer in the system.

    pub fn isPublic(self: KB) bool {
        return self.visibility == 0;
    }
    pub fn isInternal(self: KB) bool {
        return self.visibility <= 1;
    }
    pub fn isFrozen(self: KB) bool {
        return self.frozen != 0;
    }
    pub fn isRoot(self: KB) bool {
        return self.parent_id.v == -1;
    }
    pub fn isEphemeral(self: KB) bool {
        return self.id.isEphemeral();
    }
    pub fn isTraining(self: KB) bool {
        return self.training_lock;
    }
    pub fn hasRelations(self: KB) bool {
        return self.relations_offset != -1 and self.relations_count > 0;
    }
    pub fn hasRelationIndex(self: KB) bool {
        return self.relation_index_offset != -1;
    }
    pub fn isFromCompaction(self: KB) bool {
        return self.compaction_profile_offset != -1;
    }
    pub fn hasDomainRelDefs(self: KB) bool {
        return self.domain_rel_defs_offset != -1 and self.domain_rel_defs_count > 0;
    }
};

// ============================================================
// Prolog Types — the deduction layer
// ============================================================

pub const TermType = enum(i8) {
    atom = 0,
    variable = 1,
    integer = 2,
    vdr = 3,
    text = 4,
    list = 5,
    compound = 6,
    vector = 7,
    matrix = 8,
    pair = 9,
};

pub const Term = struct {
    type: TermType = .atom,
    primary_id: i32 = 0,
    secondary_offset: i32 = 0,
    secondary_aux: i32 = 0,
    vdr_value: Q16 = .{},

    pub fn atom(id: i32) Term {
        return .{ .type = .atom, .primary_id = id };
    }
    pub fn variable(id: i32) Term {
        return .{ .type = .variable, .primary_id = id };
    }
    pub fn integer(val: i32) Term {
        return .{ .type = .integer, .primary_id = val };
    }
    pub fn vdr(val: Q16) Term {
        return .{ .type = .vdr, .vdr_value = val };
    }
    pub fn compound(functor_id: i32, args_offset: i32, args_count: i32) Term {
        return .{ .type = .compound, .primary_id = functor_id, .secondary_offset = args_offset, .secondary_aux = args_count };
    }
    pub fn list(head_offset: i32, tail_offset: i32) Term {
        return .{ .type = .list, .secondary_offset = head_offset, .secondary_aux = tail_offset };
    }
    pub fn textRef(offset: i32, length: i32) Term {
        return .{ .type = .text, .secondary_offset = offset, .secondary_aux = length };
    }

    pub fn isAtom(self: Term) bool {
        return self.type == .atom;
    }
    pub fn isVariable(self: Term) bool {
        return self.type == .variable;
    }
    pub fn isCompound(self: Term) bool {
        return self.type == .compound;
    }
};

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

    pub fn successRate(self: Rule) Q16 {
        const total = self.success_count + self.failure_count;
        if (total == 0) return Q16.zero();
        return Q16.fromParts(
            @intCast(@divTrunc(@as(i64, self.success_count) * Q16.D, @as(i64, total))),
            0,
            0,
        );
    }
};

pub const Binding = struct {
    var_id: i32 = 0,
    bound_term_offset: i32 = -1,
};

pub const UnificationResult = struct {
    unified: bool = false,
    bindings_offset: i32 = -1,
    bindings_count: i16 = 0,

    pub fn success(offset: i32, count: i16) UnificationResult {
        return .{ .unified = true, .bindings_offset = offset, .bindings_count = count };
    }
    pub fn failure() UnificationResult {
        return .{};
    }
};

pub const PrologAction = struct {
    is_assert: bool = true,
    target_kb_id: VdrId = .{},
    target_slot_id: i32 = 0,
    fact: Fact = .{},
};

// ============================================================
// Grammar Types — the structural token layer
// ============================================================

pub const SlotType = enum(i8) {
    vdr_value = 0,
    text = 1,
    integer = 2,
    enum_val = 3,
    kb_ref = 4,
    grammar = 5,
};

pub const GrammarSlot = struct {
    name_offset: i32 = 0,
    name_length: i16 = 0,
    type: SlotType = .text,
    enum_values_offset: i32 = -1,
    enum_count: i16 = 0,
    kb_id: VdrId = .{},
    kb_slot_id: i32 = -1,
};

pub const Grammar = struct {
    id: VdrId = .{},
    template_offset: i32 = 0,
    template_length: i32 = 0,
    slots_offset: i32 = 0,
    slots_count: i16 = 0,
    validated: i8 = 0,
    created_at: i32 = 0,
    creator_session_id: VdrId = .{},

    pub fn isValid(self: Grammar) bool {
        return self.validated != 0;
    }
};

pub const GrammarFill = struct {
    slot_index: i16 = 0,
    fill_type: SlotType = .text,
    vdr_value: Q16 = .{},
    text_offset: i32 = 0,
    text_length: i16 = 0,
    int_value: i32 = 0,
    enum_index: i16 = 0,
};

pub const GrammarKBMapping = struct {
    slot_index: i16 = 0,
    kb_id: VdrId = .{},
    slot_id: i32 = 0,
};

// ============================================================
// Session Types — the isolation layer
// ============================================================

pub const SessionState = enum(i8) {
    active = 0,
    snapshotted = 1,
    killed = 2,
    frozen = 3,
};

pub const Session = struct {
    id: VdrId = .{},
    user_id: VdrId = .{},
    kb_root_id: VdrId = VdrId.ROOT,
    ephemeral_root_id: VdrId = VdrId.EPHEMERAL_ROOT,
    ephemeral_next_id: i64 = -2,
    visibility_level: i8 = 1,
    state: SessionState = .active,

    // Core assignment
    core_id: i32 = 0,
    arena_id: i32 = 0,

    // Resource bounds
    max_kb_count: i32 = 100,
    max_ephemeral_kbs: i32 = 1000,
    max_facts_per_kb: i32 = 10000,
    max_live_memory_bytes: i64 = 50 * 1024 * 1024,
    max_turns: i32 = 0,

    // Counters
    current_turn: i32 = 0,
    facts_asserted: i32 = 0,
    facts_retracted: i32 = 0,
    ephemeral_facts_asserted: i32 = 0,
    rules_fired: i64 = 0,
    prolog_queries: i64 = 0,
    primitive_calls: i64 = 0,
    grammar_renders: i64 = 0,
    llm_tokens_consumed: i64 = 0,
    command_tokens_consumed: i64 = 0,

    // Snapshot
    last_snapshot_id: VdrId = .{},
    last_snapshot_timestamp: i32 = 0,

    // Clone lineage
    parent_session_id: VdrId = .{},
    clone_generation: i32 = 0,

    pub fn isActive(self: Session) bool {
        return self.state == .active;
    }
    pub fn isClone(self: Session) bool {
        return !self.parent_session_id.isNone();
    }
    pub fn hasSnapshot(self: Session) bool {
        return !self.last_snapshot_id.isNone();
    }

    pub fn nextEphemeralId(self: *Session) VdrId {
        const id = self.ephemeral_next_id;
        self.ephemeral_next_id -= 1;
        return .{ .v = id };
    }

    pub fn turnsRemaining(self: Session) i32 {
        if (self.max_turns == 0) return -1;
        return self.max_turns - self.current_turn;
    }
};

// ============================================================
// Runner Types — the autonomy layer
// ============================================================

pub const RunnerType = enum(i8) {
    poller = 0,
    processor = 1,
    internal = 2,
    batch = 3,
};

pub const RunnerState = enum(i8) {
    stopped = 0,
    running = 1,
    err = 2,
    recycling = 3,
};

pub const Runner = struct {
    id: VdrId = .{},
    type: RunnerType = .poller,
    state: RunnerState = .stopped,
    session_id: VdrId = .{},

    interval_ms: i32 = 0,
    max_turns_before_recycle: i32 = 200,
    max_consecutive_errors: i32 = 5,

    iterations_completed: i64 = 0,
    errors_consecutive: i32 = 0,
    errors_total: i64 = 0,
    last_iteration_ms: i32 = 0,
    last_iteration_timestamp: i32 = 0,

    recycle_count: i32 = 0,
    last_recycle_timestamp: i32 = 0,

    pub fn shouldRecycle(self: Runner) bool {
        if (self.type != .processor) return false;
        if (self.max_turns_before_recycle <= 0) return false;
        return self.iterations_completed >= self.max_turns_before_recycle;
    }

    pub fn shouldStop(self: Runner) bool {
        if (self.max_consecutive_errors <= 0) return false;
        return self.errors_consecutive >= self.max_consecutive_errors;
    }
};

// ============================================================
// Grant Types — the safety layer
// ============================================================

pub const GrantClass = enum(i8) {
    filesystem = 0,
    compile = 1,
    execute = 2,
    lint = 3,
    network = 4,
    process = 5,
};

pub const GrantState = enum(i8) {
    active = 0,
    expired = 1,
    exhausted = 2,
    revoked = 3,
};

pub const Grant = struct {
    id: VdrId = .{},
    class: GrantClass = .filesystem,
    state: GrantState = .active,
    holder_user_id: VdrId = .{},
    target_pattern_offset: i32 = 0,
    target_pattern_length: i16 = 0,
    max_uses: i32 = -1, // -1 = unlimited
    remaining_uses: i32 = -1,
    expires_at: i32 = 0, // 0 = never
    created_at: i32 = 0,
    created_by: VdrId = .{},
    revoked_at: i32 = 0,
    revoked_by: VdrId = .{},

    pub fn isActive(self: Grant) bool {
        return self.state == .active;
    }
    pub fn isUnlimited(self: Grant) bool {
        return self.max_uses == -1;
    }

    pub fn isExpired(self: Grant, now: i32) bool {
        if (self.expires_at == 0) return false;
        return now >= self.expires_at;
    }

    pub fn isExhausted(self: Grant) bool {
        if (self.max_uses == -1) return false;
        return self.remaining_uses <= 0;
    }

    pub fn consumeUse(self: *Grant) bool {
        if (self.max_uses == -1) return true;
        if (self.remaining_uses <= 0) return false;
        self.remaining_uses -= 1;
        if (self.remaining_uses == 0) self.state = .exhausted;
        return true;
    }
};

// ============================================================
// Command Types — LLM→System interface
// ============================================================

pub const CommandType = enum(i8) {
    kb_assert = 0,
    kb_query = 1,
    kb_retract = 2,
    prolog_query = 3,
    prolog_assert_rule = 4,
    builtin_call = 5,
    grammar_render = 6,
    direct_output = 7,
    op_filesystem = 8,
    op_compile = 9,
    op_execute = 10,
    op_network = 11,
    op_process = 12,
    session_snapshot = 13,
    session_clone = 14,
};

pub const Command = struct {
    type: CommandType = .kb_query,
    target_kb_id: VdrId = .{},
    target_slot_id: i32 = 0,
    builtin_id: i32 = 0,
    args_offset: i32 = 0,
    args_count: i16 = 0,
    grant_required: i8 = -1, // -1 = none

    pub fn requiresGrant(self: Command) bool {
        return self.grant_required >= 0;
    }

    pub fn grantClass(self: Command) ?GrantClass {
        if (self.grant_required < 0) return null;
        return @enumFromInt(self.grant_required);
    }

    pub fn isOperational(self: Command) bool {
        return switch (self.type) {
            .op_filesystem, .op_compile, .op_execute, .op_network, .op_process => true,
            else => false,
        };
    }
};

pub const CommandResult = struct {
    status: Status = .{},
    output_kb_id: VdrId = .{},
    output_slot_id: i32 = -1,
    output_bytes: i32 = 0,
    output_text: ?[]const u8 = null,
};

// ============================================================
// Audit Types — the accountability layer
// ============================================================

pub const AuditAction = enum(i8) {
    fact_assert = 0,
    fact_retract = 1,
    fact_query = 2,
    rule_fire = 3,
    rule_assert = 4,
    rule_retract = 5,
    grant_check = 6,
    grant_create = 7,
    grant_revoke = 8,
    session_create = 9,
    session_kill = 10,
    snapshot = 11,
    clone = 12,
    op_execute = 13,
    access_denied = 14,
};

pub const AuditEntry = struct {
    timestamp: i32 = 0,
    session_id: VdrId = .{},
    user_id: VdrId = .{},
    action: AuditAction = .fact_query,
    target_kb_id: VdrId = .{},
    target_slot_id: i32 = -1,
    grant_id: VdrId = .{},
    result: i8 = 0, // 0=denied, 1=allowed
    detail_offset: i32 = -1,

    pub fn allowed(time: i32, session: VdrId, user: VdrId, action: AuditAction, kb: VdrId, slot: i32) AuditEntry {
        return .{ .timestamp = time, .session_id = session, .user_id = user, .action = action, .target_kb_id = kb, .target_slot_id = slot, .result = 1 };
    }

    pub fn denied(time: i32, session: VdrId, user: VdrId, action: AuditAction, kb: VdrId, slot: i32) AuditEntry {
        return .{ .timestamp = time, .session_id = session, .user_id = user, .action = action, .target_kb_id = kb, .target_slot_id = slot, .result = 0 };
    }
};

// ============================================================
// Confidence Table — immutable, indexed by SourceType
// ============================================================

pub const confidence_table = [11]Q16{
    .{ .v = 65536 }, // vdr_computation 1/1
    .{ .v = 65536 }, // prolog_derivation 1/1
    .{ .v = 64225 }, // database 98/100
    .{ .v = 62259 }, // prometheus 95/100
    .{ .v = 62259 }, // script 95/100
    .{ .v = 55705 }, // rest_api 85/100
    .{ .v = 52428 }, // published 80/100
    .{ .v = 45875 }, // user_stated 70/100
    .{ .v = 32768 }, // web_search 50/100
    .{ .v = 19660 }, // llm_generated 30/100
    .{ .v = 0 }, // unknown 0/1
};

// ============================================================
// Error / Status Types
// ============================================================

pub const ErrorCategory = enum(i8) {
    none = 0,
    arithmetic = 1,
    kb = 2,
    prolog = 3,
    grammar = 4,
    session = 5,
    grant = 6,
    runner = 7,
    memory = 8, // arena exhaustion
    system = 9,
};

pub const ErrorCode = enum(i32) {
    ok = 0,
    // Arithmetic
    division_by_zero = 100,
    overflow = 101,
    // KB
    kb_not_found = 200,
    kb_full = 201,
    kb_frozen = 202,
    kb_access_denied = 203,
    slot_out_of_range = 204,
    slot_empty = 205,
    // Prolog
    depth_exceeded = 300,
    no_matching_rule = 301,
    unification_failed = 302,
    max_bindings_exceeded = 303,
    // Grammar
    invalid_template = 400,
    slot_type_mismatch = 401,
    render_capacity_exceeded = 402,
    // Session
    session_limit = 500,
    snapshot_failed = 501,
    snapshot_corrupt = 502,
    clone_failed = 503,
    merge_conflict = 504,
    // Grant
    grant_denied = 600,
    grant_expired = 601,
    grant_exhausted = 602,
    grant_revoked = 603,
    grant_admin_required = 604,
    // Runner
    runner_error_threshold = 700,
    runner_connection_lost = 701,
    // Memory
    arena_exhausted = 800,
    arena_not_found = 801,
    // System
    init_failed = 900,
    corrupt_state = 901,
    seed_load_failed = 902,
};

pub const Status = struct {
    category: ErrorCategory = .none,
    code: ErrorCode = .ok,
    detail: i32 = 0,

    pub fn ok() Status {
        return .{};
    }

    pub fn err(cat: ErrorCategory, code: ErrorCode, detail: i32) Status {
        return .{ .category = cat, .code = code, .detail = detail };
    }

    pub fn isOk(self: Status) bool {
        return self.category == .none;
    }
    pub fn isErr(self: Status) bool {
        return self.category != .none;
    }
};

pub const RecoveryAction = enum(i32) {
    none = 0,
    compact = 1,
    log_and_continue = 2,
    simplify_query = 3,
    retry_snapshot = 4,
    log_and_deny = 5,
    reconnect_with_backoff = 6,
    recycle_runner = 7,
    kill_oldest_clone = 8,
    restore_from_snapshot = 9,
};

pub fn recoverFromError(status: Status) RecoveryAction {
    return switch (status.code) {
        .kb_full => .compact,
        .kb_access_denied => .log_and_continue,
        .depth_exceeded => .simplify_query,
        .snapshot_failed => .retry_snapshot,
        .grant_denied, .grant_expired, .grant_exhausted, .grant_revoked => .log_and_deny,
        .runner_connection_lost => .reconnect_with_backoff,
        .runner_error_threshold => .recycle_runner,
        .arena_exhausted => .kill_oldest_clone,
        .corrupt_state => .restore_from_snapshot,
        else => .none,
    };
}

// ============================================================
// Level Stats — L1/L2/L3 tracking
// ============================================================

pub const LevelStats = struct {
    l1_count: i64 = 0,
    l1_tokens: i64 = 0,
    l2_count: i64 = 0,
    l2_tokens: i64 = 0,
    l3_count: i64 = 0,
    l3_relation_queries: i64 = 0,
    l3_transitive_closures: i64 = 0,
    l3_inverse_lookups: i64 = 0,

    pub fn totalCount(self: LevelStats) i64 {
        return self.l1_count + self.l2_count + self.l3_count;
    }

    pub fn autoTriageNum(self: LevelStats) i64 {
        return self.l3_count;
    }
    pub fn autoTriageDen(self: LevelStats) i64 {
        return self.totalCount();
    }

    pub fn avgTokensPerInteraction(self: LevelStats) Q16 {
        const total_tokens = self.l1_tokens + self.l2_tokens;
        const total_ops = self.totalCount();
        if (total_ops == 0) return Q16.zero();
        return Q16.fromParts(
            @intCast(@divTrunc(total_tokens * Q16.D, total_ops)),
            0,
            0,
        );
    }

    pub fn l3RelationRatio(self: LevelStats) Q16 {
        if (self.l3_count == 0) return Q16.zero();
        const relation_ops = self.l3_relation_queries + self.l3_transitive_closures + self.l3_inverse_lookups;
        return Q16.fromParts(
            @intCast(@divTrunc(relation_ops * Q16.D, self.l3_count)),
            0,
            0,
        );
    }
};

// ============================================================
// Handle Types — opaque references
// ============================================================

pub const SessionHandle = struct {
    id: VdrId = .{},
    index: i32 = 0,
};

pub const SnapshotHandle = struct {
    id: VdrId = .{},
    index: i32 = 0,
};

pub const RunnerHandle = struct {
    id: VdrId = .{},
    index: i32 = 0,
};

// ============================================================
// Arena Types — fixed-size, bump-pointer, no free
// ============================================================

pub const Arena = struct {
    base: [*]u8 = undefined,
    size: usize = 0,
    cursor: usize = 0,

    pub fn alloc(self: *Arena, bytes: usize, alignment: usize) ?[*]u8 {
        const mask = alignment - 1;
        const aligned = (self.cursor + mask) & ~mask;
        if (aligned + bytes > self.size) return null;
        const ptr = self.base + aligned;
        self.cursor = aligned + bytes;
        return ptr;
    }

    pub fn allocTyped(self: *Arena, comptime T: type) ?*T {
        const ptr = self.alloc(@sizeOf(T), @alignOf(T)) orelse return null;
        return @ptrCast(@alignCast(ptr));
    }

    pub fn allocSlice(self: *Arena, comptime T: type, count: usize) ?[]T {
        const bytes = @sizeOf(T) * count;
        const ptr = self.alloc(bytes, @alignOf(T)) orelse return null;
        return @as([*]T, @ptrCast(@alignCast(ptr)))[0..count];
    }

    pub fn reset(self: *Arena) void {
        self.cursor = 0;
    }
    pub fn usedBytes(self: Arena) usize {
        return self.cursor;
    }
    pub fn freeBytes(self: Arena) usize {
        return self.size - self.cursor;
    }
};

pub const ArenaId = enum(i32) {
    global = 0,
    core_0 = 1,
    core_1 = 2,
    core_2 = 3,
    core_3 = 4,
    core_4 = 5,
    core_5 = 6,
    core_6 = 7,
    core_7 = 8,
    core_8 = 9,
    core_9 = 10,
    core_10 = 11,
    core_11 = 12,
    core_12 = 13,
    core_13 = 14,
    core_14 = 15,
    core_15 = 16,
};

// ============================================================
// Thread Pool Types
// ============================================================

pub const MAX_CORES: i32 = 16;

pub const WorkOp = enum(i32) {
    idle = 0,
    gemm = 1,
    softmax = 2,
    rmsnorm = 3,
    attention = 4,
    dot_product = 5,
};

pub const WorkItem = struct {
    op: WorkOp = .idle,
    // Pointers into arena memory
    a_ptr: ?[*]const i32 = null,
    b_ptr: ?[*]const i32 = null,
    c_ptr: ?[*]i32 = null,
    m: i32 = 0,
    n: i32 = 0,
    k: i32 = 0,
    // Softmax/attention params
    seq_len: i32 = 0,
    n_heads: i32 = 0,
    d_head: i32 = 0,
    scale_v: i32 = 0,
    // Completion signaling
    completion: bool = false,
};

// ============================================================
// Model Config
// ============================================================

pub const ModelConfig = struct {
    n_layers: i32 = 16,
    d_model: i32 = 2048,
    n_heads: i32 = 16,
    d_head: i32 = 128,
    vocab_size: i32 = 32000,
    mlp_dim: i32 = 5632,
    max_seq_len: i32 = 2048,
    checkpoint_path: [256]u8 = [_]u8{0} ** 256,
    checkpoint_path_len: i32 = 0,
    activation_type: i32 = 0, // 0=SiLU

    pub fn totalParams(self: ModelConfig) i64 {
        const emb = @as(i64, self.vocab_size) * @as(i64, self.d_model);
        const per_layer = @as(i64, self.d_model) * @as(i64, self.d_model) * 3 // QKV
        + @as(i64, self.d_model) * @as(i64, self.d_model) // out proj
        + @as(i64, self.d_model) * @as(i64, self.mlp_dim) // MLP up
        + @as(i64, self.mlp_dim) * @as(i64, self.d_model) // MLP down
        + @as(i64, self.d_model) * 4; // 2 norms × (gamma+beta)
        const head = @as(i64, self.d_model) * @as(i64, self.vocab_size);
        return emb + per_layer * @as(i64, self.n_layers) + head;
    }

    pub fn weightBytes(self: ModelConfig) i64 {
        return self.totalParams() * 2; // i16 weights
    }
};

pub const SamplingMode = enum(i32) {
    greedy = 0,
    top_k = 1,
    top_p = 2,
    temperature = 3,
};

pub const SamplingConfig = struct {
    mode: SamplingMode = .greedy,
    temperature_v: i32 = D16, // 1.0
    top_k: i32 = 50,
    top_p_v: i32 = 58982, // ~0.9
};

// ============================================================
// KV Cache Config
// ============================================================

pub const KvCacheConfig = struct {
    max_seq_len: i32 = 2048,
    n_layers: i32 = 16,
    n_heads: i32 = 16,
    d_head: i32 = 128,

    pub fn totalElements(self: KvCacheConfig) i64 {
        return @as(i64, 2) * @as(i64, self.n_layers) * @as(i64, self.max_seq_len) * @as(i64, self.n_heads) * @as(i64, self.d_head);
    }

    pub fn totalBytes(self: KvCacheConfig) i64 {
        return self.totalElements() * 4; // i32 per element
    }
};

// ============================================================
// Builtin Types
// ============================================================

pub const BuiltinCategory = enum(i32) {
    text_ops = 0,
    collections = 1,
    sets = 2,
    mappings = 3,
    closed_arithmetic = 4,
    comparison = 5,
    rounding = 6,
    integer_bit_ops = 7,
    linear_algebra = 8,
    statistics = 9,
    active_arithmetic = 10,
    structure_ops = 11,
    number_theory = 12,
    polynomial = 13,
    finite_field = 14,
    discrete_calculus = 15,
    op_filesystem = 16,
    op_compile = 17,
    op_execute = 18,
    op_lint = 19,
    op_network = 20,
    op_process = 21,
};

pub const BuiltinArgs = struct {
    input_kb_id: VdrId = .{},
    input_slot_ids: []const i32 = &.{},
    output_kb_id: VdrId = .{},
    output_slot_id: i32 = 0,
    extra_params: []const i32 = &.{},
    input_array_length: i32 = 0,
};

pub const BuiltinResult = struct {
    status: Status = .{},
    output_kb_id: VdrId = .{},
    output_slot_id: i32 = -1,
    output_count: i32 = 0,

    pub fn success(kb_id: VdrId, slot_id: i32, count: i32) BuiltinResult {
        return .{ .output_kb_id = kb_id, .output_slot_id = slot_id, .output_count = count };
    }
    pub fn fail(status: Status) BuiltinResult {
        return .{ .status = status };
    }
};

// ============================================================
// Search / Query Results
// ============================================================

pub const SearchResult = struct {
    facts: []Fact = &.{},
    kb_ids: []VdrId = &.{},
    slot_ids: []i32 = &.{},
    count: i32 = 0,
};

pub const QueryResult = struct {
    bindings: []Binding = &.{},
    binding_count: i32 = 0,
    result_count: i32 = 0,
    depth_reached: i32 = 0,
    depth_exceeded: bool = false,
    status: Status = .{},
};

pub const FireResult = struct {
    firing_rule_ids: []VdrId = &.{},
    firing_count: i32 = 0,
    status: Status = .{},
};

// ============================================================
// Snapshot Header
// ============================================================

pub const SNAPSHOT_MAGIC = [4]u8{ 'V', 'D', 'R', 'S' };
pub const SNAPSHOT_VERSION: i32 = 4; // bumped for relation fields in KB

pub const SnapshotHeader = struct {
    timestamp: i32 = 0,
    session_id: VdrId = .{},
    user_id: VdrId = .{},

    kb_region_size: i64 = 0,
    fact_region_size: i64 = 0,
    rule_region_size: i64 = 0,
    term_region_size: i64 = 0,
    text_region_size: i64 = 0,
    grammar_region_size: i64 = 0,
    live_state_region_size: i64 = 0,
    grant_region_size: i64 = 0,

    ephemeral_kb_region_size: i64 = 0,
    ephemeral_fact_region_size: i64 = 0,
    ephemeral_next_id: i64 = -2,

    kb_count: i32 = 0,
    fact_count: i64 = 0,
    rule_count: i32 = 0,
    term_count: i64 = 0,
    grammar_count: i32 = 0,
    grant_count: i32 = 0,

    session_metadata: Session = .{},

    checksum: i32 = 0,
    total_size: i64 = 0,
};

// ============================================================
// Diff Types (for snapshot comparison)
// ============================================================

pub const DiffRegion = enum(i32) {
    kb = 0,
    fact = 1,
    rule = 2,
    term = 3,
    text = 4,
    grammar = 5,
    live_state = 6,
    grant = 7,
    ephemeral_kb = 8,
    ephemeral_fact = 9,
};

pub const DiffEntry = struct {
    region: DiffRegion = .kb,
    offset: i64 = 0,
    size: i64 = 0,
    a_hash: u32 = 0,
    b_hash: u32 = 0,
};

pub const DiffResult = struct {
    entries: []DiffEntry = &.{},
    count: i32 = 0,
    identical: bool = true,
};

// ============================================================
// COW Page Table (for clone sessions)
// ============================================================

pub const COW_PAGE_SIZE: i32 = 4096;

pub const CowPageTable = struct {
    parent_session_id: VdrId = .{},
    clone_session_id: VdrId = .{},
    n_pages: i32 = 0,
    dirty_bits: []u8 = &.{},
    private_base_offset: i64 = 0,
    parent_base_offset: i64 = 0,

    pub fn isDirty(self: CowPageTable, page: i32) bool {
        if (page < 0 or page >= self.n_pages) return false;
        const byte_idx: usize = @intCast(@divTrunc(page, 8));
        const bit_idx: u3 = @intCast(@mod(page, 8));
        if (byte_idx >= self.dirty_bits.len) return false;
        return (self.dirty_bits[byte_idx] & (@as(u8, 1) << bit_idx)) != 0;
    }

    pub fn markDirty(self: *CowPageTable, page: i32) void {
        if (page < 0 or page >= self.n_pages) return;
        const byte_idx: usize = @intCast(@divTrunc(page, 8));
        const bit_idx: u3 = @intCast(@mod(page, 8));
        if (byte_idx >= self.dirty_bits.len) return;
        self.dirty_bits[byte_idx] |= @as(u8, 1) << bit_idx;
    }
};

// ============================================================
// Path Index Entry
// ============================================================

pub const PathEntry = struct {
    path_hash: u32 = 0,
    id: VdrId = .{},
    occupied: bool = false,
};

// ============================================================
// Audit Filter (for querying audit log)
// ============================================================

pub const AuditFilter = struct {
    session_id: ?VdrId = null,
    user_id: ?VdrId = null,
    action: ?AuditAction = null,
    target_kb_id: ?VdrId = null,
    min_timestamp: ?i32 = null,
    max_timestamp: ?i32 = null,
    result: ?i8 = null,

    pub fn matchesEntry(self: AuditFilter, entry: *const AuditEntry) bool {
        if (self.session_id) |sid| {
            if (!entry.session_id.eql(sid)) return false;
        }
        if (self.user_id) |uid| {
            if (!entry.user_id.eql(uid)) return false;
        }
        if (self.action) |act| {
            if (entry.action != act) return false;
        }
        if (self.target_kb_id) |kid| {
            if (!entry.target_kb_id.eql(kid)) return false;
        }
        if (self.min_timestamp) |min_t| {
            if (entry.timestamp < min_t) return false;
        }
        if (self.max_timestamp) |max_t| {
            if (entry.timestamp > max_t) return false;
        }
        if (self.result) |r| {
            if (entry.result != r) return false;
        }
        return true;
    }
};

// ============================================================
// Grant Check Result
// ============================================================

pub const GrantResult = struct {
    granted: bool = false,
    grant_id: VdrId = .{},
    remaining_uses: i32 = 0,

    pub fn allowed(id: VdrId, remaining: i32) GrantResult {
        return .{ .granted = true, .grant_id = id, .remaining_uses = remaining };
    }
    pub fn deny() GrantResult {
        return .{};
    }
};

// ============================================================
// Merge Types
// ============================================================

pub const MergePolicy = enum(i32) {
    ours = 0,
    theirs = 1,
    fail_on_conflict = 2,
};

pub const MergeConflict = struct {
    kb_id: VdrId = .{},
    slot_id: i32 = 0,
    parent_timestamp: i32 = 0,
    child_timestamp: i32 = 0,
};

pub const MergeResult = struct {
    status: Status = .{},
    merged_count: i32 = 0,
    conflict_count: i32 = 0,
    conflicts: []MergeConflict = &.{},
};

// ============================================================
// Session Config
// ============================================================

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

pub const CloneConfig = struct {
    fresh_live: bool = true,
    inherit_rules: bool = true,
};

// ============================================================
// KB Create Config
// ============================================================

pub const KBCreateConfig = struct {
    name: []const u8 = "",
    path: []const u8 = "",
    parent_id: VdrId = VdrId.ROOT,
    max_facts: i32 = 500,
    max_rules: i32 = 50,
    visibility: i8 = 1,
    owner_id: VdrId = .{},
};

pub const ScopedSearchConfig = struct {
    start_kb_id: VdrId = .{},
    tag: FactTag = .value,
    max_depth: i32 = 100,
    max_results: i32 = 100,
};

// ============================================================
// Prolog Config
// ============================================================

pub const PrologConfig = struct {
    max_depth: i32 = 100,
    max_bindings: i32 = 1000,
    max_results: i32 = 100,
};

// ============================================================
// Inference Context Config
// ============================================================

pub const ContextConfig = struct {
    system_prompt_kb_id: VdrId = .{},
    scope_kb_id: VdrId = .{},
    max_scratchpad_tokens: i32 = 50,
    max_context_tokens: i32 = 4096,
};

// ============================================================
// Output Buffer
// ============================================================

pub const OutputBuffer = struct {
    data: []u8 = &.{},
    length: i32 = 0,
    capacity: i32 = 0,

    pub fn append(self: *OutputBuffer, bytes: []const u8) void {
        const avail = @as(usize, @intCast(self.capacity - self.length));
        const n = @min(bytes.len, avail);
        if (n > 0) {
            @memcpy(self.data[@intCast(self.length)..@intCast(self.length + @as(i32, @intCast(n)))], bytes[0..n]);
            self.length += @intCast(n);
        }
    }

    pub fn reset(self: *OutputBuffer) void {
        self.length = 0;
    }

    pub fn contents(self: OutputBuffer) []const u8 {
        return self.data[0..@intCast(self.length)];
    }
};

// ============================================================
// Scratchpad Entry (command results visible to LLM)
// ============================================================

pub const ScratchpadEntry = struct {
    command_index: i32 = 0,
    result: CommandResult = .{},
};

// ============================================================
// Relationships
// ============================================================

pub const RelationType = enum(i32) {
    // Structural (1000+)
    enables = 1000, // General: X makes Y possible or functional
    requires, // General: X cannot exist or work without Y
    prevents, // General: X blocks or forbids Y; symmetric
    implements, // Programming: X is a concrete realization of abstract Y
    extends, // General: X adds capability to Y without replacing
    overrides, // Programming: X replaces Y's behavior in a scope
    validates, // General: X confirms Y is correct
    verified_by, // General: Y was confirmed by X
    contradicts, // General: X and Y cannot both hold; symmetric
    causes, // History/Physics: X directly produces Y as effect
    determined_by, // Physics: Y's value or form is strictly fixed by X
    depends_on, // General: X needs Y to function
    equivalent_to, // General: X and Y are interchangeable; symmetric
    approximates, // Physics/Math: X and Y are close but not identical; symmetric
    specializes, // General: X is a more specific form of Y
    generalizes, // General: X is a more general form of Y
    part_of, // General: X is a component inside Y
    contains, // General: Y is a component inside X
    follows, // General: X comes after Y in sequence
    precedes, // General: X comes before Y in sequence
    forces, // History: disruption/pressure compels response/adaptation
    overcomes, // History: removes or breaks an active constraint
    triggered_by, // History: Y initiated X but doesn't fully determine it
    explains, // Physics/History: mechanism accounts for observed phenomenon
    replaces, // History/Programming: X supersedes Y in same functional role
    motivates, // Physics: failure/anomaly provides impetus for new development
    limits, // Physics: reveals boundary or incompleteness of
    confers, // Physics: grants a property or capability to
    unifies, // Physics: integrates separate entities into single framework
    foundation_for, // Math: provides axiomatic ground from which Y is built
    constrains, // Math/Algorithms: imposes limitation or restriction on Y
    produces, // Geography/Mechanical: X actively generates Y through ongoing process
    spans, // Geography: X extends across or operates through multiple Y
    borders, // Geography: X is spatially adjacent to Y; symmetric
    influences, // Geography: X affects value/behavior of Y without sole determination
    amplifies, // Geography/Neuro: X strengthens Y through positive feedback
    regulates, // Anatomy: X controls or modulates activity of Y via feedback/signaling
    supplies, // Anatomy: X provides essential material to Y
    flows_to, // Anatomy/Neuro: X delivers flow to Y directionally
    activates, // Neuroscience: X triggers Y into active state via binding/signaling
    encoded_by, // Neuroscience: X is represented through Y's activity pattern
    mediates, // Neuroscience: X is the mechanism through which Y occurs
    mitigated_by, // Engineering/DS: problem X is remedied by design choice Y
    degrades, // Engineering/DS: X worsens performance or quality of Y
    favors, // Engineering/DS: X preferentially benefits Y's performance
    solves, // Algorithms: X provides the solution to problem Y
    bounded_by, // Algorithms: X has Y as a proven performance bound
    simplifies, // Engineering/DS: X reduces complexity or difficulty of Y
    maintains, // Engineering/DS: X preserves or upholds Y across operations

    develops, // Athletics/Education: X progressively builds Y through repeated application
    // complements, // General: X and Y work cooperatively, each providing what the other lacks; symmetric
    models, // Science/Theory: X provides theoretical/mathematical framework representing Y
    founded, // History/Philosophy: X historically established or originated Y
    opposes, // Philosophy/Biology: X holds positions or functions contrary to Y
    responds_to, // Philosophy: X directly addresses or answers Y's arguments
    critiques, // Philosophy: X identifies problems or weaknesses in Y through argument
    synthesizes, // Philosophy: X combines elements from multiple Y into new framework
    transmits, // History: X conveys Y to a new context or tradition without fundamentally altering
    parallel_to, // Philosophy: X and Y are structurally similar but independently arising; symmetric

    // Identity and binding (2000+)
    instance_of = 2000, // General: X is a particular case of Y
    has_type, // Programming: X has type Y
    named, // General: X has the name Y
    aliases, // General: X is an alternative identifier for Y; symmetric
    references, // General: X points to or cites Y
    assigns, // Programming: X gives value Y in a binding context
    binds_to, // Programming: X is bound to Y in a scope
    returns, // Programming: X produces Y as function output
    accepts, // Programming: X takes Y as input parameter
    emits, // Programming: X produces Y as a side output
    complement_of, // Math: X is the set-theoretic complement of Y; symmetric in scope
    constructed_from, // Math: X is formally built using Y as axioms/definitions

    // Knowledge structure (3000+)
    knowledge_base = 3000, // VDR: X is stored in knowledge base Y
    domain, // General: X belongs to domain Y
    scoped_to, // Programming: X is valid only within scope Y
    context_of, // General: X is the broader situation Y occurs within
    defined_in, // General: X is defined in source Y
    documented_by, // General: X is documented by Y
    example_of, // General: X is an example of Y
    derived_from, // General: X is derived from source Y
    composed_of, // General: X is structurally built from parts Y
    decomposes_to, // General: X breaks down into components Y
    transforms_to, // General: X becomes Y through a defined operation
    measured_by, // Physics: X is quantified by measurement Y
    studies, // Math: field X has Y as its subject matter
    distinguishes, // General: criterion X separates Y into distinct categories
    anti_pattern_of, // Programming: X is a common misuse or failure mode of Y

    // Agency and action (4000+)
    agent_of = 4000, // Language: X is the agent performing action Y
    object_of, // Language: X is the object receiving action Y
    instrument_of, // Language: X is the tool used in action Y
    location_of, // Language/Geography: X is where Y occurs
    destination_of, // Language: X is where Y is directed toward
    source_of, // Language: X is where Y originates from
    purpose_of, // Language: X is the reason for Y
    result_of, // Language: X is the outcome of Y
    manner_of, // Language: X describes how Y is performed
    time_of, // Language: X is when Y occurs

    // Condition and logic (5000+)
    if_then = 5000, // Logic: if X holds then Y follows
    unless, // Logic: Y holds unless X is true
    while_true, // Logic: Y continues while X holds
    for_each, // Logic: Y applies to each instance of X
    exists, // Logic: at least one X satisfies Y
    not_exists, // Logic: no X satisfies Y
    and_also, // Logic: both X and Y hold
    or_else, // Logic: X or Y holds (inclusive)
    greater_than, // Logic: X > Y in ordered comparison
    less_than, // Logic: X < Y in ordered comparison

    // Grammar and language structure (6000+)
    governs = 6000, // Grammar: X dictates the form of Y
    applies_to, // Grammar: rule X is relevant to class Y
    violates, // Grammar: anti-pattern X breaks rule Y
    agrees_with, // Grammar: X matches Y in grammatical features
    selects, // Grammar: X determines which form Y takes
    modifies, // Grammar: X restricts or describes Y
    heads, // Grammar: X is the obligatory central word of phrase Y
    complements, // Grammar: X completes the meaning of head Y
    subcategorizes, // Grammar: head X requires complement type Y
    distributes_as, // Grammar: phrase X occupies same positions as category Y

    // Toolchain and operations (7000+)
    manages = 7000, // Programming: X is responsible for lifecycle/state of Y
    isolates, // Programming: X creates boundary separating Y from interference
    orchestrates, // Programming: X coordinates execution of Y components
    generates, // Programming: X produces Y as a primary artifact
    inspects, // Programming: X examines state of Y without modifying it

    // Domain-registerable (10000 to 20000)
    domain_0 = 1_000_000,
    domain_1,
    domain_2,

    unknown = -1,

    pub fn inverse(self: RelationType) RelationType {
        return switch (self) {
            // Structural — symmetric pairs and directional inverses
            .enables => .depends_on,
            .requires => .enables,
            .prevents => .prevents, // symmetric
            .implements => .unknown, // no clean inverse; "implemented_by" is query direction
            .extends => .generalizes,
            .overrides => .unknown, // context-dependent; no stable inverse
            .validates => .verified_by,
            .verified_by => .validates,
            .contradicts => .contradicts, // symmetric
            .causes => .result_of,
            .determined_by => .unknown, // forward "determines" handled by query reversal
            .depends_on => .enables,
            .equivalent_to => .equivalent_to, // symmetric
            .approximates => .approximates, // symmetric
            .specializes => .generalizes,
            .generalizes => .specializes,
            .part_of => .contains,
            .contains => .part_of,
            .follows => .precedes,
            .precedes => .follows,
            .forces => .unknown, // "forced_by" not distinct enough from triggered_by
            .overcomes => .unknown, // no clean inverse
            .triggered_by => .causes, // weak: triggering is a form of causing
            .explains => .unknown, // "explained_by" is query reversal, not a distinct type
            .replaces => .unknown, // "replaced_by" is query reversal
            .motivates => .unknown, // "motivated_by" is query reversal
            .limits => .unknown, // "limited_by" is query reversal
            .confers => .unknown, // "conferred_by" is query reversal
            .unifies => .part_of, // weak: unified things are parts of the unification
            .foundation_for => .constructed_from,
            .constrains => .unknown, // "constrained_by" is query reversal
            .produces => .result_of,
            .spans => .unknown, // no clean inverse; "spanned_by" is query reversal
            .borders => .borders, // symmetric
            .influences => .unknown, // "influenced_by" is query reversal
            .amplifies => .unknown, // "amplified_by" is query reversal
            .regulates => .unknown, // "regulated_by" is query reversal
            .supplies => .unknown, // "supplied_by" is query reversal
            .flows_to => .unknown, // "receives_from" not distinct enough
            .activates => .unknown, // "activated_by" is query reversal
            .encoded_by => .unknown, // forward "encodes" is query reversal
            .mediates => .unknown, // "mediated_by" is query reversal
            .mitigated_by => .unknown, // forward "mitigates" is query reversal
            .degrades => .unknown, // "degraded_by" is query reversal
            .favors => .unknown, // "favored_by" is query reversal
            .solves => .unknown, // "solved_by" is query reversal
            .bounded_by => .unknown, // "bounds" is query reversal
            .simplifies => .unknown, // "simplified_by" is query reversal
            .maintains => .unknown, // "maintained_by" is query reversal

            // Identity and binding
            .instance_of => .has_type,
            .has_type => .instance_of,
            .named => .unknown, // "name_of" is query reversal
            .aliases => .aliases, // symmetric
            .references => .unknown, // "referenced_by" is query reversal
            .assigns => .unknown, // "assigned_from" not distinct
            .binds_to => .unknown, // "bound_by" is query reversal
            .returns => .unknown, // "returned_by" is query reversal
            .accepts => .unknown, // "accepted_by" is query reversal
            .emits => .unknown, // "emitted_by" is query reversal
            .complement_of => .complement_of, // symmetric
            .constructed_from => .foundation_for,

            // Knowledge structure
            .knowledge_base => .unknown, // "stored_in" is query reversal
            .domain => .unknown, // "has_member" is query reversal
            .scoped_to => .contains, // scope contains the scoped thing
            .context_of => .scoped_to, // weak: context contains, scoped thing lives in context
            .defined_in => .contains, // definition source contains the defined thing
            .documented_by => .unknown, // "documents" is query reversal
            .example_of => .unknown, // "has_example" is query reversal
            .derived_from => .unknown, // "derives" is query reversal
            .composed_of => .decomposes_to,
            .decomposes_to => .composed_of,
            .transforms_to => .derived_from, // weak: transformed thing derives from source
            .measured_by => .unknown, // "measures" is query reversal
            .studies => .unknown, // "studied_by" is query reversal
            .distinguishes => .unknown, // "distinguished_by" is query reversal
            .anti_pattern_of => .unknown, // "has_anti_pattern" is query reversal

            // Agency and action
            .agent_of => .unknown, // "has_agent" is query reversal
            .object_of => .unknown, // "has_object" is query reversal
            .instrument_of => .unknown, // "has_instrument" is query reversal
            .location_of => .unknown, // "located_at" is query reversal
            .destination_of => .source_of,
            .source_of => .destination_of,
            .purpose_of => .unknown, // "has_purpose" is query reversal
            .result_of => .causes,
            .manner_of => .unknown, // "has_manner" is query reversal
            .time_of => .unknown, // "occurs_at" is query reversal

            // Condition and logic — no inverses; these are logical operators
            .if_then => .unknown,
            .unless => .unknown,
            .while_true => .unknown,
            .for_each => .unknown,
            .exists => .unknown,
            .not_exists => .unknown,
            .and_also => .and_also, // symmetric
            .or_else => .or_else, // symmetric
            .greater_than => .less_than,
            .less_than => .greater_than,

            // Grammar and language structure
            .governs => .unknown, // "governed_by" is query reversal
            .applies_to => .unknown, // "has_rule" is query reversal
            .violates => .unknown, // "violated_by" is query reversal
            .agrees_with => .agrees_with, // symmetric
            .selects => .unknown, // "selected_by" is query reversal
            .modifies => .unknown, // "modified_by" is query reversal
            .heads => .unknown, // "headed_by" is query reversal
            .complements => .unknown, // "complemented_by" is query reversal
            .subcategorizes => .unknown, // "subcategorized_by" is query reversal
            .distributes_as => .unknown, // "distribution_of" is query reversal

            // Toolchain and operations
            .manages => .unknown, // "managed_by" is query reversal
            .isolates => .unknown, // "isolated_by" is query reversal
            .orchestrates => .unknown, // "orchestrated_by" is query reversal
            .generates => .derived_from, // generated thing derives from generator
            .inspects => .unknown, // "inspected_by" is query reversal

            .develops => .unknown, // "developed_by" is query reversal
            .complements => .complements, // symmetric
            .models => .unknown, // "modeled_by" is query reversal
            .founded => .unknown, // "founded_by" is query reversal
            .opposes => .opposes, // typically mutual but assert both directions in compaction
            .responds_to => .unknown, // "responded_to_by" is query reversal
            .critiques => .unknown, // "critiqued_by" is query reversal
            .synthesizes => .unknown, // "synthesized_by" is query reversal
            .transmits => .unknown, // "transmitted_by" is query reversal
            .parallel_to => .parallel_to, // symmetric

            // Domain-registerable and unknown
            .unknown => .unknown,
            else => .unknown, // domain-registered types: inverse defined in DomainRelationDef
        };
    }

    pub fn isSymmetric(self: RelationType) bool {
        return switch (self) {
            .prevents,
            .contradicts,
            .equivalent_to,
            .approximates,
            .borders,
            .aliases,
            .complement_of,
            .agrees_with,
            .and_also,
            .or_else,
            .complements,
            .parallel_to,
            .opposes,
            => true,
            else => false,
        };
    }

    pub fn isTransitive(self: RelationType) bool {
        return switch (self) {
            .enables,
            .requires,
            .extends,
            .specializes,
            .generalizes,
            .part_of,
            .contains,
            .follows,
            .precedes,
            .depends_on,
            .scoped_to,
            .flows_to,
            => true,
            else => false,
        };
    }

    pub fn isSystemDefined(self: RelationType) bool {
        const v = @intFromEnum(self);
        return v >= 0 and v <= 19;
    }

    pub fn isDomain(self: RelationType) bool {
        const v = @intFromEnum(self);
        return v >= 64 and v <= 127;
    }
};

pub const TypedRelation = struct {
    rel_type: RelationType = .unknown,
    from_id: VdrId = .{},
    to_id: VdrId = .{},
    provenance: Provenance = .{},
    strength: Q16 = .{},
    scope_kb_id: VdrId = .{},

    pub fn isBinary(self: TypedRelation) bool {
        return self.strength.v == 0 and self.strength.r0 == 0;
    }

    pub fn isWeighted(self: TypedRelation) bool {
        return !self.isBinary();
    }

    pub fn matchesFrom(self: TypedRelation, id: VdrId) bool {
        return self.from_id.eql(id);
    }

    pub fn matchesTo(self: TypedRelation, id: VdrId) bool {
        return self.to_id.eql(id);
    }
};

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

pub const RELATION_TYPE_SLOTS: usize = 128;

pub const RelationIndex = struct {
    by_type_offset: i32 = -1,
    by_type_counts: [RELATION_TYPE_SLOTS]i32 = [_]i32{0} ** RELATION_TYPE_SLOTS,
    by_from_offset: i32 = -1,
    by_from_count: i32 = 0,
    by_to_offset: i32 = -1,
    by_to_count: i32 = 0,
    total_relations: i32 = 0,
    last_rebuilt: i32 = 0,

    pub fn countForType(self: RelationIndex, rel_type: RelationType) i32 {
        const slot = @intFromEnum(rel_type);
        if (slot < 0 or slot >= RELATION_TYPE_SLOTS) return 0;
        return self.by_type_counts[@intCast(slot)];
    }

    pub fn hasType(self: RelationIndex, rel_type: RelationType) bool {
        return self.countForType(rel_type) > 0;
    }

    pub fn isDirty(self: RelationIndex, kb_relations_count: i32) bool {
        return self.total_relations != kb_relations_count;
    }
};

pub const CompactionProfile = struct {
    source_document_id: VdrId = .{},
    tables_ingested: i32 = 0,
    rows_ingested: i32 = 0,
    facts_created: i32 = 0,
    relations_created: i32 = 0,
    rules_created: i32 = 0,
    relation_types_used: [RELATION_TYPE_SLOTS]bool = [_]bool{false} ** RELATION_TYPE_SLOTS,
    domain_types_registered: i32 = 0,
    text_bytes_stored: i32 = 0,
    numeric_values_stored: i32 = 0,
    compression_ratio: Q16 = .{},
    ingestion_timestamp: i32 = 0,
    validation_errors: i32 = 0,

    pub fn totalEntities(self: CompactionProfile) i32 {
        return self.facts_created + self.relations_created + self.rules_created;
    }

    pub fn relationTypeCount(self: CompactionProfile) i32 {
        var count: i32 = 0;
        for (self.relation_types_used) |used| {
            if (used) count += 1;
        }
        return count;
    }
};

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

    pub fn estimatedWeightBytes(self: ModelReductionConfig) i64 {
        const d: i64 = 2048;
        const bytes_per_param: i64 = if (self.use_i16_weights) 2 else 4;
        const n: i64 = self.reduced_n_layers;
        const mlp: i64 = self.reduced_mlp_dim;
        const d_head: i64 = @divTrunc(d, self.reduced_n_heads);
        const qkv = d * (3 * d_head);
        const o = d * d;
        const up = d * mlp;
        const down = mlp * d;
        const per_layer = (qkv + o + up + down) * bytes_per_param;
        const lm_head = d * @as(i64, self.reduced_vocab_size) * bytes_per_param;
        return n * per_layer + lm_head;
    }
};

// ============================================================
// Runner Configs
// ============================================================

pub const PollerConfig = struct {
    session: SessionHandle = .{},
    interval_ms: i32 = 60000,
    max_consecutive_errors: i32 = 5,
    kb_id: VdrId = .{},
};

pub const ProcessorConfig = struct {
    session: SessionHandle = .{},
    source_url: [512]u8 = [_]u8{0} ** 512,
    source_url_len: i32 = 0,
    max_turns_before_recycle: i32 = 200,
    max_consecutive_errors: i32 = 5,
    backoff_initial_ms: i32 = 1000,
    backoff_max_ms: i32 = 60000,
};

pub const InternalConfig = struct {
    session: SessionHandle = .{},
    interval_ms: i32 = 86400000, // daily
    compute_kb_id: VdrId = .{},
};

pub const BatchConfig = struct {
    session: SessionHandle = .{},
    task_queue_kb_id: VdrId = .{},
    task_queue_slot: i32 = 0,
    max_concurrent: i32 = 4,
};

// ============================================================
// Seed Config
// ============================================================

pub const SeedConfig = struct {
    snapshot_path: ?[]const u8 = null,
    create_fresh: bool = true,
};

// ============================================================
// System Config — top-level
// ============================================================

pub const SystemConfig = struct {
    // Hardware
    n_cores: i32 = 0,

    // Model
    model: ModelConfig = .{},

    // Model reduction (advisory)
    model_reduction: ModelReductionConfig = .{},

    // Arenas
    global_arena_bytes: i64 = 3 * 1024 * 1024 * 1024,
    per_core_arena_bytes: i64 = 256 * 1024 * 1024,

    // Limits
    max_total_kbs: i32 = 100_000,
    max_total_facts: i64 = 10_000_000,
    max_total_rules: i32 = 100_000,
    max_total_terms: i64 = 1_000_000,
    max_sessions_per_core: i32 = 500,
    max_ephemeral_kbs_per_session: i32 = 1000,
    max_facts_per_session_kb: i32 = 10000,

    // Sessions
    default_max_turns: i32 = 0,
    auto_snapshot_interval: i32 = 100,

    // HTTP
    http_port: i32 = 1138,

    // Runners
    max_runners: i32 = 64,

    // Safety
    audit_ring_capacity: i32 = 1_000_000,
    default_visibility: i8 = 1,

    // Ingestion
    ingestion: IngestionConfig = .{},

    // Relation index
    relation_index_rebuild_interval: i32 = 100,

    // Seed
    seed: SeedConfig = .{},

    // Sampling
    sampling: SamplingConfig = .{},

    // Prolog
    prolog: PrologConfig = .{},

    // Context
    context: ContextConfig = .{},
};

pub const IngestionConfig = struct {
    target_path: [256]u8 = [_]u8{0} ** 256,
    target_path_length: i32 = 0,
    source_type: SourceType = .published,
    generate_rules: bool = true,
    generate_typed_relations: bool = true,
    detect_numeric: bool = true,
    max_facts_per_table: i32 = 10000,
    freeze_after_ingest: bool = true,
    max_domain_relation_defs: i32 = 64,
};

// ============================================================
// System Status
// ============================================================

pub const SystemStatus = struct {
    initialized: bool = false,
    n_cores: i32 = 0,
    n_sessions: i32 = 0,
    n_runners: i32 = 0,
    n_kbs: i32 = 0,
    total_facts: i64 = 0,
    total_rules: i32 = 0,
    total_grants: i32 = 0,
    audit_entries: i32 = 0,
    audit_total_written: i64 = 0,
    global_arena_used: i64 = 0,
    global_arena_total: i64 = 0,
    per_core_arena_used: [MAX_CORES]i64 = [_]i64{0} ** MAX_CORES,
    per_core_arena_total: [MAX_CORES]i64 = [_]i64{0} ** MAX_CORES,
};

// ============================================================
// IOSE Declaration (builtin input/output/side-effects/errors)
// ============================================================

pub const IoSe = struct {
    builtin_id: i32 = 0,
    category: BuiltinCategory = .text_ops,
    name: [64]u8 = [_]u8{0} ** 64,
    name_len: i32 = 0,
    input_count: i32 = 0,
    input_types: [8]TermType = [_]TermType{.atom} ** 8,
    output_type: TermType = .vdr,
    side_effects: bool = false,
    grant_class: i8 = -1,
    max_input_elements: i32 = -1,
    bounded: bool = true,
    deterministic: bool = true,

    pub fn requiresGrant(self: IoSe) bool {
        return self.grant_class >= 0;
    }
    pub fn isPure(self: IoSe) bool {
        return !self.side_effects and self.deterministic;
    }
};

// ============================================================
// Shared Constants
// ============================================================

pub const exp_table = [11]i32{
    65536, 24109, 8874, 3263, 1201, 442, 162, 60, 22, 8, 3,
};

// ============================================================
// Well-Known Seed KB IDs (positive, global)
// ============================================================

pub const SEED = struct {
    pub const ROOT: VdrId = .{ .v = 1 };
    pub const SYSTEM: VdrId = .{ .v = 2 };
    pub const OSO: VdrId = .{ .v = 3 };
    pub const CONFIDENCE: VdrId = .{ .v = 4 };
    pub const BUILTINS: VdrId = .{ .v = 5 };
    pub const COMMAND_VOCAB: VdrId = .{ .v = 6 };
    pub const HYGIENE: VdrId = .{ .v = 7 };
    pub const EMBEDDING: VdrId = .{ .v = 8 };
    pub const OUTPUT: VdrId = .{ .v = 9 };
    pub const TEMPLATES: VdrId = .{ .v = 10 };
    pub const SENTENCES: VdrId = .{ .v = 11 };
    pub const FORMATS: VdrId = .{ .v = 12 };
    pub const RELATION_TYPES: VdrId = .{ .v = 13 };
    pub const INGESTION: VdrId = .{ .v = 14 };
    pub const SEED_KB_COUNT: i32 = 14;
};
