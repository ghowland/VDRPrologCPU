# VDR-Prolog Utility AI Scoring and Behavior Selection

## Technical Specification

---

## 1. Overview

The system needs to make decisions. Not just "which Prolog rule covers this query" but "given 12 possible behaviors the LLM could invoke, which one is best for this situation right now." The typed relation index answers structural questions. The Prolog engine fires rules. But when multiple valid options exist — multiple applicable rules, multiple KB paths to search, multiple response strategies — the system needs a principled way to score, rank, and select.

Utility AI provides this. Each candidate behavior is scored by evaluating a set of considerations against current context. Each consideration reads a value from the world (session state, KB contents, relation coverage, confidence levels, resource usage), maps it through a response curve to produce a [0, 65536] score, and the scores are combined via Dave Mark's compensated multiplication. The highest-scoring behavior wins.

Everything is Q16. No floats. The response curves are integer approximations. The compensation formula uses exact remainder arithmetic. Scores are i32 values in [0, D] where D=65536. The scoring pipeline is deterministic — same inputs always produce the same selection.

Behaviors, considerations, curves, and scoring configurations are facts and rules in KBs. They are dynamically added like everything else. A domain KB can define its own behavior sets with domain-specific considerations. The system's own operational decisions (execution level selection, session eviction, ingestion priority) use the same scoring infrastructure.

---

## 2. How It Connects

### 2.1 Where Scoring Decisions Happen

The system faces scoring decisions at multiple levels:

**LLM prompt-level decisions.** The LLM has N possible actions (invoke Prolog query, emit KB command, generate prose, render grammar, invoke builtin). The availability surface tells it what is available. Utility scoring ranks the options by fitness for the current query. The LLM reads the ranking and acts on the top choice, or overrides with judgment at L1.

**System-level decisions.** Session LRU eviction (which session to eject), ingestion priority (which compacted document to process next), training scheduling (which KB to train next), weight eviction under arena pressure. These are not LLM decisions — they are system operational decisions that run at L3 as Prolog builtins.

**Domain-level decisions.** A utility AI game engine running on VDR-Prolog defines its own behavior sets for NPC combat, dialogue, exploration. The same scoring infrastructure serves both the system's internal decisions and user-defined domain AI.

### 2.2 What Already Exists

The Prolog engine can fire rules. The typed relation index can answer structural queries. LevelStats tracks L1/L2/L3 ratios. The confidence table scores trust levels. Session counters track resource usage. The availability surface summarizes what relations and rules exist.

What is missing: a way to take multiple candidate actions, score each one against multiple axes of the current context, combine the scores with compensation, and select the winner. The structs below provide this.

---

## 3. Core Concepts Mapped to VDR-Prolog Types

### 3.1 The Scoring Pipeline

```
Context (world state snapshot)
    ↓
Consideration (one axis: reads input, normalizes, applies curve)
    ↓
Score per consideration: Q16 in [0, D]
    ↓
Compensation (Dave Mark: prevent single-zero veto)
    ↓
Combined score per behavior: Q16
    ↓
Selection (argmax, weighted random top-N, threshold gate)
    ↓
Selected behavior → execute (Prolog query, builtin call, command)
```

Every stage operates on Q16 values with full remainder propagation. The pipeline is a chain of Q16 operations — no float conversion anywhere.

### 3.2 Mapping to KB Data

Behaviors, considerations, and curve configurations live as facts in KBs. A behavior set is a KB. Each behavior is a child KB or a group of facts within the set KB. Considerations are facts within a behavior's KB. Curve parameters are Q16 values in facts.

```
root.system.scoring
├── level_selection          ← behavior set for L1/L2/L3 decision
│   ├── behavior_l3          ← use typed relations
│   ├── behavior_l2          ← invoke Prolog rule
│   └── behavior_l1          ← full LLM forward pass
├── session_eviction         ← behavior set for LRU decisions
│   ├── behavior_evict       ← snapshot and evict
│   └── behavior_keep        ← retain in memory
└── ingestion_priority       ← behavior set for queue ordering

root.domain.game.combat_ai
├── behavior_attack
│   ├── consideration_health
│   ├── consideration_distance
│   └── consideration_ammo
├── behavior_flee
│   ├── consideration_health
│   └── consideration_threat
└── behavior_idle
```

---

## 4. New Structs

### 4.1 ResponseCurve

```zig
/// Defines a mathematical response curve that maps a normalized Q16
/// input in [0, D] to a Q16 output in [0, D].
/// Lives as a fact in a consideration's KB or in root.system.scoring.curves.
/// All curve evaluation is integer arithmetic — no float.
pub const CurveType = enum(i8) {
    /// y = mx/D + b. Linear proportional response.
    linear = 0,
    /// y = x^n / D^(n-1). Slow start, fast finish (n>1) or fast start (n<1).
    polynomial = 1,
    /// y = D / (1 + exp_int(-k * (x - midpoint) / D)). S-curve threshold.
    logistic = 2,
    /// y = D * ln(x/D + 1) / ln(2). Rapid rise, diminishing returns.
    logarithmic = 3,
    /// y = D * (exp_int(k*x/D) - 1) / (exp_int(k) - 1). Slow start, explosive finish.
    exponential = 4,
    /// y = D * exp_int(-(x - center)^2 / (2 * width^2)). Peak at center.
    gaussian = 5,
    /// y = D - gaussian(x). Trough at center, high at extremes.
    inverse_gaussian = 6,
    /// y = 0 if x < threshold, D if x >= threshold. Binary gate.
    step = 7,
    /// y = D * (3t^2 - 2t^3) where t = x/D. Smooth S without parameters.
    smoothstep = 8,
    /// y = D * (1 - cos(pi * x / D)) / 2. Trigonometric S-curve.
    sine_ease = 9,
    /// y = interpolated from breakpoint array. Arbitrary designer-defined shape.
    piecewise = 10,
    /// y = D * (1 - exp_int(-k * x / D)) / (1 - exp_int(-k)). Bounded exponential.
    bounded_exponential = 11,
    /// y = D * 4 * ((x/D) - 0.5)^2. U-shaped, minimum at center.
    parabolic_trough = 12,
    /// y = D * (1 + cos(pi * x / D)) / 2. Smooth decay.
    cosine_decay = 13,
};

pub const ResponseCurve = struct {
    /// which curve shape to use
    curve_type: CurveType = .linear,

    /// slope for linear curves, exponent for polynomial, steepness for logistic/exponential
    /// Q16 value. For polynomial: v=2*D means quadratic, v=D/2 means sqrt.
    param_a: Q16 = Q16.one(),

    /// y-intercept for linear, midpoint for logistic, center for gaussian
    /// Q16 value in [0, D] range.
    param_b: Q16 = .{},

    /// width for gaussian, decay rate for exponential
    /// Q16 value. Gaussian: larger = broader peak.
    param_c: Q16 = .{},

    /// whether to invert output: result = D - curve(x)
    inverted: bool = false,

    /// breakpoints offset for piecewise curves (offset into KB's fact array)
    /// each breakpoint is two consecutive Q16 facts: (x, y) pair
    breakpoints_offset: i32 = -1,

    /// number of breakpoint pairs for piecewise curves
    breakpoints_count: i16 = 0,

    /// evaluate this curve at input x (Q16 in [0, D])
    /// returns Q16 in [0, D]
    pub fn evaluate(self: ResponseCurve, x: Q16) Q16 {
        var result = switch (self.curve_type) {
            .linear => evaluateLinear(x, self.param_a, self.param_b),
            .polynomial => evaluatePolynomial(x, self.param_a),
            .logistic => evaluateLogistic(x, self.param_a, self.param_b),
            .logarithmic => evaluateLogarithmic(x, self.param_a),
            .exponential => evaluateExponential(x, self.param_a),
            .gaussian => evaluateGaussian(x, self.param_b, self.param_c),
            .inverse_gaussian => evaluateInverseGaussian(x, self.param_b, self.param_c),
            .step => evaluateStep(x, self.param_b),
            .smoothstep => evaluateSmoothstep(x),
            .sine_ease => evaluateSineEase(x),
            .bounded_exponential => evaluateBoundedExponential(x, self.param_a),
            .parabolic_trough => evaluateParabolicTrough(x),
            .cosine_decay => evaluateCosineDecay(x),
            .piecewise => Q16.zero(), // requires arena access, handled separately
        };

        if (self.inverted) {
            result = Q16.sub(Q16.one(), result);
        }

        return clampScore(result);
    }
};
```

### 4.2 InputSource

```zig
/// Defines where a consideration reads its raw input value from.
/// The source is resolved at evaluation time by reading session state,
/// KB facts, relation indices, or computed values.
pub const InputSourceType = enum(i8) {
    /// read a Q16 fact from a specific KB and slot
    kb_fact = 0,
    /// read a session counter (facts_asserted, rules_fired, etc.)
    session_counter = 1,
    /// read from the relation index (count of a relation type)
    relation_count = 2,
    /// read a confidence value from a fact's provenance
    confidence = 3,
    /// read elapsed time since a timestamp
    time_elapsed = 4,
    /// read arena usage (used bytes / total bytes)
    arena_usage = 5,
    /// read a computed value from a builtin
    builtin_result = 6,
    /// fixed constant value (for testing or baseline behaviors)
    constant = 7,
    /// read from LevelStats (l3 ratio, token count, etc.)
    level_stats = 8,
    /// read a session resource limit ratio (current / max)
    resource_ratio = 9,
};

pub const InputSource = struct {
    /// what kind of source to read
    source_type: InputSourceType = .constant,

    /// for kb_fact: which KB to read from
    source_kb_id: VdrId = .{},

    /// for kb_fact: which fact slot. For session_counter: which counter (enum value).
    /// For relation_count: RelationType slot. For builtin_result: builtin_id.
    source_slot: i32 = 0,

    /// for constant: the fixed value to return
    constant_value: Q16 = .{},

    /// minimum expected raw value (for normalization)
    range_min: Q16 = .{},

    /// maximum expected raw value (for normalization)
    range_max: Q16 = Q16.one(),

    /// read and normalize the input to [0, D]
    /// normalization: (raw - range_min) / (range_max - range_min), clamped to [0, D]
    pub fn read(self: InputSource, ctx: *ScoringContext) Q16 {
        const raw = self.readRaw(ctx);
        return normalize(raw, self.range_min, self.range_max);
    }

    /// read the raw unnormalized value from the source
    fn readRaw(self: InputSource, ctx: *ScoringContext) Q16 {
        return switch (self.source_type) {
            .kb_fact => ctx.readKbFact(self.source_kb_id, self.source_slot),
            .session_counter => ctx.readSessionCounter(self.source_slot),
            .relation_count => ctx.readRelationCount(self.source_slot),
            .confidence => ctx.readConfidence(self.source_kb_id, self.source_slot),
            .time_elapsed => ctx.readTimeElapsed(self.source_slot),
            .arena_usage => ctx.readArenaUsage(self.source_slot),
            .builtin_result => ctx.readBuiltinResult(self.source_slot),
            .constant => self.constant_value,
            .level_stats => ctx.readLevelStats(self.source_slot),
            .resource_ratio => ctx.readResourceRatio(self.source_slot),
        };
    }
};
```

### 4.3 Consideration

```zig
/// A single scoring axis for a behavior. Reads an input, normalizes it,
/// applies a response curve, and produces a Q16 score in [0, D].
/// Lives as facts in a behavior's KB.
pub const Consideration = struct {
    /// where to read the raw input value
    input: InputSource = .{},

    /// the response curve to apply after normalization
    curve: ResponseCurve = .{},

    /// weight multiplier applied after curve. Q16.
    /// D = 1.0 (no effect). 2*D = double importance. D/2 = half importance.
    /// in compensated multiplication, weight affects the score before compensation.
    weight: Q16 = Q16.one(),

    /// minimum output score. prevents this consideration from going below a floor.
    /// Q16 in [0, D]. Zero means no floor (true zero possible).
    floor: Q16 = .{},

    /// if true, this consideration is a hard gate: score is 0 or D, no intermediate.
    /// gates should NOT participate in compensation — they are prerequisites.
    is_gate: bool = false,

    /// scratch: last computed score, for debugging and logging
    last_score: Q16 = .{},

    /// scratch: last raw input value, for debugging
    last_raw_input: Q16 = .{},

    /// evaluate this consideration against current context
    pub fn evaluate(self: *Consideration, ctx: *ScoringContext) Q16 {
        // Read and normalize input
        const normalized = self.input.read(ctx);
        self.last_raw_input = normalized;

        // Apply curve
        var score = self.curve.evaluate(normalized);

        // Apply weight
        if (!Q16.eql(self.weight, Q16.one())) {
            score = Q16.mul(score, self.weight);
            // Re-normalize: weight can push above D
            score = clampScore(score);
        }

        // Apply floor
        if (Q16.compare(score, self.floor) < 0) {
            score = self.floor;
        }

        self.last_score = score;
        return score;
    }
};
```

### 4.4 CompensationConfig

```zig
/// Configures how consideration scores are combined within a behavior.
/// Default is Dave Mark compensated multiplication.
pub const CompositionMethod = enum(i8) {
    /// ∏(score_i). Pure AND. Single zero kills everything.
    pure_multiply = 0,
    /// Σ(score_i) / n. Pure OR. One high score compensates all lows.
    mean = 1,
    /// Σ(w_i × score_i) / Σ(w_i). Weighted average.
    weighted_sum = 2,
    /// Dave Mark: compensate then multiply. Default.
    compensated_multiply = 3,
    /// min(score_i). Bottleneck — worst consideration wins.
    minimum = 4,
    /// max(score_i). Optimistic — best consideration wins.
    maximum = 5,
};

pub const CompensationConfig = struct {
    /// how to combine consideration scores
    method: CompositionMethod = .compensated_multiply,

    /// epsilon floor: no consideration score goes below this before combination.
    /// prevents true-zero veto in multiplicative systems.
    /// Q16 value. Typical: 655 (≈ 0.01 * D). Zero = no floor.
    epsilon_floor: Q16 = .{ .v = 655 },

    /// whether gate considerations (is_gate=true) are evaluated separately.
    /// if true: gates are checked first as binary pass/fail, then soft considerations
    /// are scored and combined. if false: gates participate in combination normally.
    separate_gates: bool = true,
};
```

### 4.5 Behavior

```zig
/// A candidate action the system can take. Scored by evaluating its
/// considerations against context and combining the scores.
/// Lives as a KB or a group of facts within a behavior set KB.
pub const Behavior = struct {
    /// unique identifier within the behavior set
    id: VdrId = .{},

    /// human-readable name, offset into text store
    name_offset: i32 = 0,
    /// name length
    name_length: i16 = 0,

    /// what to do when this behavior is selected
    action: BehaviorAction = .{},

    /// considerations array offset in KB
    considerations_offset: i32 = -1,
    /// number of considerations
    considerations_count: i16 = 0,

    /// how to combine consideration scores
    compensation: CompensationConfig = .{},

    /// behavior-level weight multiplier. Applied after consideration combination.
    /// Q16. D = no effect.
    weight: Q16 = Q16.one(),

    /// minimum final score. "idle" behavior uses this to always be selectable.
    /// Q16 in [0, D]. Zero = no floor.
    floor: Q16 = .{},

    /// scratch: last combined score before behavior weight
    last_raw_score: Q16 = .{},

    /// scratch: final score after weight and floor
    last_final_score: Q16 = .{},

    /// statistics: how many times this behavior has been selected
    selection_count: i64 = 0,

    /// statistics: cumulative score across all selections (for averaging)
    cumulative_score: Q16 = .{},

    /// timestamp of last selection
    last_selected: i32 = 0,
};
```

### 4.6 BehaviorAction

```zig
/// What happens when a behavior is selected.
/// Maps the scoring result to a system operation.
pub const BehaviorActionType = enum(i8) {
    /// no action (for testing or placeholder behaviors)
    none = 0,
    /// execute a Prolog query
    prolog_query = 1,
    /// call a builtin function
    builtin_call = 2,
    /// emit an LLM command
    llm_command = 3,
    /// assert a fact to a KB
    kb_assert = 4,
    /// invoke another behavior set (hierarchical)
    nested_behavior_set = 5,
    /// fire a specific Prolog rule
    rule_fire = 6,
    /// render output via grammar
    grammar_render = 7,
};

pub const BehaviorAction = struct {
    /// what kind of action to execute
    action_type: BehaviorActionType = .none,

    /// target KB for prolog_query, kb_assert, grammar_render
    target_kb_id: VdrId = .{},

    /// target slot, rule ID, builtin ID, or nested behavior set ID
    target_id: i32 = 0,

    /// for prolog_query: term offset of the query pattern
    query_term_offset: i32 = -1,

    /// for llm_command: command type to emit
    command_type: CommandType = .kb_query,

    /// for builtin_call: arguments offset
    args_offset: i32 = -1,
    /// for builtin_call: argument count
    args_count: i16 = 0,

    /// grant required to execute this action (-1 = none)
    grant_required: i8 = -1,
};
```

### 4.7 BehaviorSet

```zig
/// A complete set of candidate behaviors to score and select from.
/// The reasoner. Evaluates all behaviors and picks one (or ranks them).
/// Lives as a KB with child KBs per behavior, or as a group of facts.
pub const SelectionMethod = enum(i8) {
    /// highest score wins. Deterministic.
    argmax = 0,
    /// random selection weighted by score from top N candidates.
    weighted_random_top_n = 1,
    /// Boltzmann/softmax selection with temperature parameter.
    boltzmann = 2,
    /// highest score wins, but current behavior gets hysteresis bonus.
    argmax_with_hysteresis = 3,
    /// threshold gate eliminates low scorers, then argmax on remainder.
    threshold_then_argmax = 4,
};

pub const BehaviorSet = struct {
    /// unique identifier
    id: VdrId = .{},

    /// human-readable name
    name_offset: i32 = 0,
    name_length: i16 = 0,

    /// behaviors array offset in KB
    behaviors_offset: i32 = -1,
    /// number of behaviors in this set
    behaviors_count: i16 = 0,

    /// how to select the winning behavior
    selection: SelectionMethod = .argmax,

    /// for weighted_random_top_n: how many top candidates to consider
    top_n: i16 = 3,

    /// for boltzmann: temperature parameter. Q16.
    /// high = more random, low = more greedy. D = neutral.
    temperature: Q16 = Q16.one(),

    /// for argmax_with_hysteresis: score bonus for current behavior. Q16.
    /// typical: 3277-9830 (5-15% of D).
    hysteresis_bonus: Q16 = .{ .v = 6554 },

    /// for threshold_then_argmax: minimum score to be eligible. Q16.
    eligibility_threshold: Q16 = .{},

    /// currently active behavior VdrId (for hysteresis). Updated on selection.
    current_behavior_id: VdrId = .{},

    /// KB that owns this behavior set
    owner_kb_id: VdrId = .{},

    /// statistics: total evaluations run on this set
    evaluation_count: i64 = 0,

    /// statistics: last evaluation timestamp
    last_evaluated: i32 = 0,
};
```

### 4.8 ScoringContext

```zig
/// Snapshot of world state that considerations read from during evaluation.
/// Built once per scoring cycle from session state, KB data, and system metrics.
/// Lives in per-core scratch — ephemeral, destroyed after scoring.
pub const ScoringContext = struct {
    /// the session being scored for
    session: *Session = undefined,

    /// KB store for fact reads
    store: *KbStore = undefined,

    /// global arena for KB data access
    global_arena: *Arena = undefined,

    /// scratch arena for temporary allocations during scoring
    scratch: *Arena = undefined,

    /// current timestamp (integer epoch seconds)
    now: i32 = 0,

    /// read a Q16 fact value from a KB
    pub fn readKbFact(self: *ScoringContext, kb_id: VdrId, slot: i32) Q16 {
        const kb = self.store.resolveKb(kb_id) orelse return Q16.zero();
        const fact = self.store.readFact(kb, slot) orelse return Q16.zero();
        return fact.value;
    }

    /// read a session counter by index
    /// 0=current_turn, 1=facts_asserted, 2=rules_fired, 3=prolog_queries,
    /// 4=llm_tokens_consumed, 5=command_tokens_consumed
    pub fn readSessionCounter(self: *ScoringContext, counter_id: i32) Q16 {
        const val: i64 = switch (counter_id) {
            0 => self.session.current_turn,
            1 => self.session.facts_asserted,
            2 => @as(i64, @intCast(self.session.rules_fired)),
            3 => @as(i64, @intCast(self.session.prolog_queries)),
            4 => @as(i64, @intCast(self.session.llm_tokens_consumed)),
            5 => @as(i64, @intCast(self.session.command_tokens_consumed)),
            else => 0,
        };
        // Truncate to i32 range for Q16
        return Q16.fromParts(@intCast(@min(val, std.math.maxInt(i32))), 0, 0);
    }

    /// read count of typed relations of a given type across accessible KBs
    pub fn readRelationCount(self: *ScoringContext, rel_type_slot: i32) Q16 {
        var count: i32 = 0;
        // walk accessible KBs, sum relation counts for this type
        const kbs = getAccessibleKbs(self.store, self.session);
        for (kbs) |kb| {
            if (kb.hasRelationIndex()) {
                const index = getRelationIndex(kb, self.global_arena);
                if (rel_type_slot >= 0 and rel_type_slot < RELATION_TYPE_SLOTS) {
                    count += index.by_type_counts[@intCast(rel_type_slot)];
                }
            }
        }
        return Q16.fromParts(count, 0, 0);
    }

    /// read confidence value of a specific fact
    pub fn readConfidence(self: *ScoringContext, kb_id: VdrId, slot: i32) Q16 {
        const kb = self.store.resolveKb(kb_id) orelse return Q16.zero();
        const fact = self.store.readFact(kb, slot) orelse return Q16.zero();
        return fact.provenance.confidence;
    }

    /// read elapsed time since a stored timestamp
    pub fn readTimeElapsed(self: *ScoringContext, timestamp_slot: i32) Q16 {
        _ = timestamp_slot;
        // difference between now and the stored timestamp, as Q16
        return Q16.fromParts(self.now, 0, 0);
    }

    /// read arena usage ratio
    pub fn readArenaUsage(self: *ScoringContext, arena_id: i32) Q16 {
        _ = arena_id;
        // used / total as Q16 fraction
        const used = self.global_arena.usedBytes();
        const total = self.global_arena.size;
        if (total == 0) return Q16.zero();
        const ratio: i32 = @intCast(@divTrunc(@as(i64, @intCast(used)) * Q16.D, @as(i64, @intCast(total))));
        return Q16.fromParts(ratio, 0, 0);
    }

    /// read a builtin result (evaluated on demand)
    pub fn readBuiltinResult(self: *ScoringContext, builtin_id: i32) Q16 {
        _ = self;
        _ = builtin_id;
        // placeholder: builtin dispatch would go here
        return Q16.zero();
    }

    /// read from LevelStats
    /// 0=l3_ratio, 1=avg_tokens, 2=pre_resolution_hit_rate
    pub fn readLevelStats(self: *ScoringContext, stat_id: i32) Q16 {
        _ = self;
        _ = stat_id;
        return Q16.zero();
    }

    /// read session resource ratio (current / max)
    /// 0=kb_count/max, 1=ephemeral_kbs/max, 2=facts/max
    pub fn readResourceRatio(self: *ScoringContext, ratio_id: i32) Q16 {
        _ = self;
        _ = ratio_id;
        return Q16.zero();
    }
};
```

### 4.9 ScoringResult

```zig
/// Result of evaluating a behavior set. Contains ranked behaviors
/// and the selected winner.
/// Lives in per-core scratch — ephemeral.
pub const ScoredBehavior = struct {
    /// behavior ID
    behavior_id: VdrId = .{},
    /// final combined score after compensation, weight, and floor
    final_score: Q16 = .{},
    /// rank (0 = highest)
    rank: i16 = 0,
    /// whether all gate considerations passed
    gates_passed: bool = true,
};

pub const MAX_SCORED_BEHAVIORS: usize = 64;

pub const ScoringResult = struct {
    /// ranked behaviors, sorted by final_score descending
    scored: [MAX_SCORED_BEHAVIORS]ScoredBehavior =
        [_]ScoredBehavior{.{}} ** MAX_SCORED_BEHAVIORS,
    /// how many behaviors were scored
    count: i16 = 0,
    /// index into scored[] of the selected winner
    selected_index: i16 = 0,
    /// the selected behavior's ID (convenience)
    selected_id: VdrId = .{},
    /// the selected behavior's score (convenience)
    selected_score: Q16 = .{},
    /// which selection method was used
    method_used: SelectionMethod = .argmax,
    /// total microseconds spent scoring (integer)
    scoring_time_us: i32 = 0,
};
```

---

## 5. The Compensation Pipeline in Q16

Dave Mark's compensation formula, implemented entirely in Q16 exact integer arithmetic:

```zig
/// Dave Mark compensated multiplication.
/// Prevents single-zero veto while preserving multiplicative discrimination.
///
/// For each consideration i with score s_i and n total considerations:
///   modification_factor = 1 - 1/n = (n-1)/n
///   make_up_value = (1 - s_i) * modification_factor
///   compensated_i = s_i + (make_up_value * s_i)
///                 = s_i * (1 + (1 - s_i) * modification_factor)
///
/// Final score = ∏(compensated_i) for all non-gate considerations.
pub fn compensatedMultiply(
    scores: []Q16,
    n: i32,
    config: CompensationConfig,
) Q16 {
    if (n <= 0) return Q16.zero();
    if (n == 1) return scores[0];

    // modification_factor = (n - 1) / n as Q16
    // In Q16: v = D * (n-1) / n, with remainder captured
    const n_minus_1 = Q16.fromParts(@intCast((n - 1) * Q16.D / n), 0, 0);
    // More precise: use Q16.div
    const mod_factor = Q16.div(
        Q16.fromParts(@intCast((n - 1) * Q16.D), 0, 0),
        Q16.fromParts(@intCast(n * Q16.D), 0, 0),
    );
    _ = n_minus_1;

    var product = Q16.one();

    for (scores[0..@intCast(n)]) |score_raw| {
        var s = score_raw;

        // Apply epsilon floor
        if (Q16.compare(s, config.epsilon_floor) < 0) {
            s = config.epsilon_floor;
        }

        // make_up_value = (D - s) * modification_factor / D
        const deficit = Q16.sub(Q16.one(), s);
        const make_up = Q16.mul(deficit, mod_factor);

        // compensated = s + (make_up * s / D)
        //             = s * (1 + make_up / D)
        const boost = Q16.mul(make_up, s);
        const compensated = Q16.add(s, boost);

        // multiply into running product
        product = Q16.mul(product, compensated);
    }

    return clampScore(product);
}
```

---

## 6. Scoring Execution

### 6.1 Evaluate a Behavior Set

```zig
pub fn evaluateBehaviorSet(
    set: *BehaviorSet,
    ctx: *ScoringContext,
    arena: *Arena,
) ScoringResult {
    var result = ScoringResult{};
    result.method_used = set.selection;

    const behaviors = getBehaviors(set, ctx.store, ctx.global_arena);

    var bi: i16 = 0;
    while (bi < set.behaviors_count and bi < MAX_SCORED_BEHAVIORS) : (bi += 1) {
        const behavior = &behaviors[@intCast(bi)];
        const score_result = evaluateBehavior(behavior, ctx, arena);

        result.scored[@intCast(bi)] = ScoredBehavior{
            .behavior_id = behavior.id,
            .final_score = score_result.final_score,
            .gates_passed = score_result.gates_passed,
        };
        result.count = bi + 1;
    }

    // Sort by final_score descending (insertion sort — small array)
    sortScoredBehaviors(result.scored[0..@intCast(result.count)]);

    // Assign ranks
    var ri: i16 = 0;
    while (ri < result.count) : (ri += 1) {
        result.scored[@intCast(ri)].rank = ri;
    }

    // Select winner based on method
    result.selected_index = selectWinner(&result, set, arena);
    if (result.selected_index >= 0 and result.selected_index < result.count) {
        result.selected_id = result.scored[@intCast(result.selected_index)].behavior_id;
        result.selected_score = result.scored[@intCast(result.selected_index)].final_score;
    }

    // Update behavior set stats
    set.evaluation_count += 1;
    set.last_evaluated = ctx.now;
    set.current_behavior_id = result.selected_id;

    return result;
}
```

### 6.2 Evaluate a Single Behavior

```zig
const BehaviorEvalResult = struct {
    final_score: Q16 = .{},
    gates_passed: bool = true,
};

fn evaluateBehavior(
    behavior: *Behavior,
    ctx: *ScoringContext,
    arena: *Arena,
) BehaviorEvalResult {
    var result = BehaviorEvalResult{};

    const considerations = getConsiderations(behavior, ctx.store, ctx.global_arena);
    if (behavior.considerations_count == 0) {
        result.final_score = behavior.floor;
        return result;
    }

    // Phase 1: evaluate gate considerations
    if (behavior.compensation.separate_gates) {
        for (considerations[0..@intCast(behavior.considerations_count)]) |*con| {
            if (!con.is_gate) continue;
            const score = con.evaluate(ctx);
            // Gate must score above zero (or above epsilon)
            if (score.v == 0 and score.r0 == 0) {
                result.gates_passed = false;
                result.final_score = Q16.zero();
                return result;
            }
        }
    }

    // Phase 2: evaluate soft considerations
    var soft_scores_buf: [32]Q16 = undefined;
    var soft_count: i32 = 0;

    for (considerations[0..@intCast(behavior.considerations_count)]) |*con| {
        if (behavior.compensation.separate_gates and con.is_gate) continue;
        if (soft_count >= 32) break;

        soft_scores_buf[@intCast(soft_count)] = con.evaluate(ctx);
        soft_count += 1;
    }

    // Phase 3: combine scores
    _ = arena;
    const combined = switch (behavior.compensation.method) {
        .compensated_multiply => compensatedMultiply(
            &soft_scores_buf,
            soft_count,
            behavior.compensation,
        ),
        .pure_multiply => pureMultiply(soft_scores_buf[0..@intCast(soft_count)]),
        .mean => arithmeticMean(soft_scores_buf[0..@intCast(soft_count)]),
        .weighted_sum => arithmeticMean(soft_scores_buf[0..@intCast(soft_count)]),
        .minimum => minimumScore(soft_scores_buf[0..@intCast(soft_count)]),
        .maximum => maximumScore(soft_scores_buf[0..@intCast(soft_count)]),
    };

    // Phase 4: apply behavior weight
    var final = combined;
    if (!Q16.eql(behavior.weight, Q16.one())) {
        final = Q16.mul(final, behavior.weight);
    }

    // Phase 5: apply floor
    if (Q16.compare(final, behavior.floor) < 0) {
        final = behavior.floor;
    }

    result.final_score = clampScore(final);

    // Update behavior scratch
    behavior.last_raw_score = combined;
    behavior.last_final_score = result.final_score;

    return result;
}
```

### 6.3 Selection Methods

```zig
fn selectWinner(
    result: *ScoringResult,
    set: *BehaviorSet,
    arena: *Arena,
) i16 {
    if (result.count == 0) return -1;

    return switch (set.selection) {
        .argmax => 0, // already sorted, index 0 is highest

        .weighted_random_top_n => selectWeightedTopN(result, set.top_n, arena),

        .boltzmann => selectBoltzmann(result, set.temperature, arena),

        .argmax_with_hysteresis => selectWithHysteresis(result, set),

        .threshold_then_argmax => selectThresholdArgmax(result, set.eligibility_threshold),
    };
}

fn selectWithHysteresis(result: *ScoringResult, set: *BehaviorSet) i16 {
    // Give current behavior a bonus, then pick highest
    var best_idx: i16 = 0;
    var best_score = result.scored[0].final_score;

    var i: i16 = 0;
    while (i < result.count) : (i += 1) {
        var score = result.scored[@intCast(i)].final_score;
        if (result.scored[@intCast(i)].behavior_id.eql(set.current_behavior_id)) {
            score = Q16.add(score, set.hysteresis_bonus);
        }
        if (Q16.compare(score, best_score) > 0) {
            best_score = score;
            best_idx = i;
        }
    }
    return best_idx;
}

fn selectThresholdArgmax(result: *ScoringResult, threshold: Q16) i16 {
    // Find first (highest-scoring) behavior above threshold
    var i: i16 = 0;
    while (i < result.count) : (i += 1) {
        if (Q16.compare(result.scored[@intCast(i)].final_score, threshold) >= 0) {
            return i;
        }
    }
    return -1; // nothing above threshold
}
```

---

## 7. Curve Evaluation in Q16

All curve evaluation is integer arithmetic. No `@sin`, no `@cos`, no `@exp`, no `@log` from std.math. Integer approximations using the exp_table, lookup tables, and polynomial approximations.

```zig
fn evaluateLinear(x: Q16, slope: Q16, intercept: Q16) Q16 {
    // y = slope * x / D + intercept
    return clampScore(Q16.add(Q16.mul(slope, x), intercept));
}

fn evaluatePolynomial(x: Q16, exponent: Q16) Q16 {
    // y = x^n where n = exponent.v / D
    // For n=2 (exponent.v = 2*D): y = x * x / D
    // For n=3: y = x * x * x / D^2
    // Integer power via repeated multiplication
    if (exponent.v <= 0) return Q16.one();
    if (exponent.v == Q16.D) return x; // n=1, linear

    // For integer exponents (n*D), do exact repeated multiply
    const n = @divTrunc(exponent.v, Q16.D);
    if (n * Q16.D == exponent.v and n >= 1 and n <= 8) {
        var result = x;
        var i: i32 = 1;
        while (i < n) : (i += 1) {
            result = Q16.mul(result, x);
        }
        return clampScore(result);
    }

    // Fractional exponent: use exp(n * ln(x)) approximation
    // For now, fall back to quadratic for n=2 region
    return Q16.mul(x, x);
}

fn evaluateStep(x: Q16, threshold: Q16) Q16 {
    if (Q16.compare(x, threshold) >= 0) return Q16.one();
    return Q16.zero();
}

fn evaluateSmoothstep(x: Q16) Q16 {
    // y = 3x^2 - 2x^3 on [0, D]
    // = x^2 * (3*D - 2*x) / D^2
    const x_sq = Q16.mul(x, x);
    const three_d = Q16.fromParts(3 * Q16.D, 0, 0);
    const two_x = Q16.fromParts(2 * x.v, 0, 0);
    const bracket = Q16.sub(three_d, two_x);
    return clampScore(Q16.mul(x_sq, bracket));
}

fn evaluateGaussian(x: Q16, center: Q16, width: Q16) Q16 {
    // y = D * exp(-(x - center)^2 / (2 * width^2))
    // integer exp approximation via table lookup + interpolation
    if (width.v == 0) return Q16.zero();

    const diff = Q16.sub(x, center);
    const diff_sq = Q16.mul(diff, diff);
    const two_width_sq = Q16.mul(Q16.fromParts(2 * Q16.D, 0, 0), Q16.mul(width, width));

    if (two_width_sq.v == 0) return Q16.zero();

    // exponent_arg = diff_sq / two_width_sq (both Q16)
    const arg = Q16.div(diff_sq, two_width_sq);

    // Integer exponential decay lookup
    return integerExpDecay(arg);
}

fn evaluateInverseGaussian(x: Q16, center: Q16, width: Q16) Q16 {
    return Q16.sub(Q16.one(), evaluateGaussian(x, center, width));
}

fn evaluateParabolicTrough(x: Q16) Q16 {
    // y = 4 * (x/D - 0.5)^2 * D
    const half = Q16.fromParts(Q16.D / 2, 0, 0);
    const centered = Q16.sub(x, half);
    const sq = Q16.mul(centered, centered);
    return clampScore(Q16.mul(Q16.fromParts(4 * Q16.D, 0, 0), sq));
}

/// Integer approximation of exp(-x) for x in Q16.
/// Uses the system exp_table for coarse lookup and linear interpolation.
fn integerExpDecay(x: Q16) Q16 {
    if (x.v <= 0) return Q16.one();
    if (x.v >= 10 * Q16.D) return Q16.zero(); // exp(-10) ≈ 0

    // exp_table has 11 entries for integer arguments 0-10
    const idx = @divTrunc(x.v, Q16.D);
    if (idx >= 10) return Q16.zero();

    const frac = @mod(x.v, Q16.D);
    const lo = exp_table[@intCast(idx)];
    const hi = exp_table[@intCast(idx + 1)];

    // Linear interpolation between table entries
    const interp = @as(i64, lo) + @divTrunc(@as(i64, hi - lo) * @as(i64, frac), Q16.D);
    return Q16.fromParts(@intCast(interp), 0, 0);
}

/// Clamp a Q16 score to [0, D]
fn clampScore(x: Q16) Q16 {
    if (x.v < 0) return Q16.zero();
    if (x.v > Q16.D) return Q16.one();
    return x;
}

/// Normalize raw input to [0, D] given min/max range
fn normalize(raw: Q16, range_min: Q16, range_max: Q16) Q16 {
    const range = Q16.sub(range_max, range_min);
    if (range.v <= 0) return Q16.zero();
    const shifted = Q16.sub(raw, range_min);
    return clampScore(Q16.div(shifted, range));
}
```

---

## 8. Combination Helpers

```zig
fn pureMultiply(scores: []Q16) Q16 {
    if (scores.len == 0) return Q16.zero();
    var product = scores[0];
    for (scores[1..]) |s| {
        product = Q16.mul(product, s);
    }
    return product;
}

fn arithmeticMean(scores: []Q16) Q16 {
    if (scores.len == 0) return Q16.zero();
    var sum = Q16.zero();
    for (scores) |s| {
        sum = Q16.add(sum, s);
    }
    return Q16.div(sum, Q16.fromParts(@intCast(scores.len * Q16.D), 0, 0));
}

fn minimumScore(scores: []Q16) Q16 {
    if (scores.len == 0) return Q16.zero();
    var min_s = scores[0];
    for (scores[1..]) |s| {
        if (Q16.compare(s, min_s) < 0) min_s = s;
    }
    return min_s;
}

fn maximumScore(scores: []Q16) Q16 {
    if (scores.len == 0) return Q16.zero();
    var max_s = scores[0];
    for (scores[1..]) |s| {
        if (Q16.compare(s, max_s) > 0) max_s = s;
    }
    return max_s;
}
```

---

## 9. Prolog Integration

### 9.1 Builtins for Scoring

The scoring system exposes builtins that Prolog rules can invoke:

```
evaluate_behavior_set(SetKbId, WinnerId, WinnerScore)
evaluate_consideration(ConsiderationKbId, Slot, Score)
select_curve(CurveType, Input, ParamA, ParamB, ParamC, Output)
compensated_multiply(Scores, N, Output)
normalize_value(Raw, Min, Max, Normalized)
```

These are registered in the builtin categories (category = scoring, new category 22 in BuiltinCategory enum, pure, no grants, deterministic).

### 9.2 Prolog Rules for Decision Making

Domain-specific selection rules compose the scoring builtins:

```prolog
%% Select execution level based on scoring
select_level(Query, Level) :-
    evaluate_behavior_set(system_level_selection, WinnerId, _Score),
    behavior_maps_to_level(WinnerId, Level).

%% Select best ingestion target from queue
select_next_ingestion(DocId) :-
    evaluate_behavior_set(ingestion_priority, WinnerId, _Score),
    behavior_maps_to_document(WinnerId, DocId).

%% Domain: select best combat action
select_combat_action(AgentId, Action) :-
    agent_behavior_set(AgentId, SetId),
    evaluate_behavior_set(SetId, WinnerId, _Score),
    behavior_maps_to_action(WinnerId, Action).
```

### 9.3 Dynamic Behavior Registration

Behaviors and considerations are facts in KBs. They can be asserted, retracted, and modified like any other data:

```prolog
%% Add a new consideration to an existing behavior
CMD_KB_ASSERT root.domain.game.combat_ai.behavior_attack
    consideration(health_urgency, input=session_health, curve=ease_in, weight=1.0)

%% Modify a curve parameter
CMD_KB_UPDATE root.domain.game.combat_ai.behavior_attack.consideration_health
    SET curve.param_a = 131072   %% steeper quadratic (2*D)

%% Add a new behavior to a set
CMD_KB_ASSERT root.domain.game.combat_ai.behavior_retreat
    behavior(retreat, action=prolog_query, target=retreat_plan)
```

---

## 10. System-Level Behavior Sets

### 10.1 Execution Level Selection

```
root.system.scoring.level_selection
├── behavior_l3
│   ├── consideration: relation_coverage (how many relation types match query)
│   ├── consideration: index_hit (does RelationIndex have the query type)
│   └── consideration: confidence (confidence of available data)
├── behavior_l2
│   ├── consideration: rule_match_count (how many rules match)
│   ├── consideration: rule_success_rate (historical success of matching rules)
│   └── consideration: confidence
└── behavior_l1
    ├── consideration: novelty (inverse of L3+L2 coverage)
    └── consideration: floor = 655 (always selectable as fallback)
```

### 10.2 Session Eviction

```
root.system.scoring.session_eviction
├── behavior_evict
│   ├── consideration: time_since_active (ease-in: longer idle = higher score)
│   ├── consideration: arena_pressure (linear: higher pressure = higher eviction score)
│   └── consideration: session_value (inverse: more valuable sessions resist eviction)
└── behavior_keep
    ├── consideration: recent_activity (high recent activity = keep)
    └── consideration: floor = 32768 (default to keeping unless evict scores higher)
```

---

## 11. Targeted Additions to Existing Structs

### BuiltinCategory — add scoring category

```zig
pub const BuiltinCategory = enum(i32) {
    // ... existing 0-21 ...
    scoring = 22,          // utility AI scoring builtins
};
```

### SEED — add scoring KB

```zig
pub const SEED = struct {
    // ... existing 1-14 ...
    pub const SCORING: VdrId = .{ .v = 15 };       // root.system.scoring
    pub const SEED_KB_COUNT: i32 = 16;              // was 14
};
```

### KB — add behavior set reference

```zig
pub const KB = struct {
    // ... all existing fields ...

    /// offset to BehaviorSet struct if this KB is a behavior set, -1 otherwise
    behavior_set_offset: i32 = -1,

    // ... existing methods ...

    pub fn isBehaviorSet(self: KB) bool {
        return self.behavior_set_offset != -1;
    }
};
```
