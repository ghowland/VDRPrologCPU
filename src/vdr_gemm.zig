// ============================================================
// vdr_gemm.zig
// Single-block transformer over VdrId vocabulary.
// Q16 integer arithmetic throughout. Arena-allocated.
// No floats. No malloc. No SIMD (scalar first).
// ============================================================

const std = @import("std");
const types = @import("vdr_types.zig");
const kb_config = @import("vdr_kb_config.zig");
const compact_loader = @import("vdr_compact_loader.zig");

const VdrId = types.VdrId;
const Q16 = types.Q16;
const KB = types.KB;
const Arena = types.Arena;

// ============================================================
// Constants
// ============================================================

const DEFAULT_D_MODEL: i32 = 32;
const DEFAULT_SEQ_LEN: i32 = 4;
const DEFAULT_FFN_DIM: i32 = 64;
// const DEFAULT_EPOCHS: i32 = 50;
// const DEFAULT_LR: i32 = 512; // ~1/128 in Q16
// const DEFAULT_LR: i32 = 4096; // ~1/16 in Q16, much more aggressive
const DEFAULT_EPOCHS: i32 = 200;
const DEFAULT_LR: i32 = 8192; // ~1/8 in Q16
const D: i32 = types.D16; // 65536

// ============================================================
// LCG RNG (deterministic, no float)
// ============================================================

const LCG = struct {
    state: u32,

    fn init(seed: u32) LCG {
        return .{ .state = seed };
    }

    fn next(self: *LCG) u32 {
        self.state = self.state *% 1103515245 +% 12345;
        self.state &= 0x7FFFFFFF;
        return self.state;
    }

    fn nextQ16(self: *LCG, scale: i32) Q16 {
        const raw = self.next();
        const range: u32 = 7; // -3 to 3
        const val: i32 = @as(i32, @intCast(raw % range)) - 3;
        return Q16.fromParts(val * scale, 0, 0);
    }
};

// ============================================================
// Forward Cache
// ============================================================

const GemmForwardCache = struct {
    // All slices are seq_len × dim or seq_len × seq_len etc
    // Indexed as [pos * dim + d] for 2D
    embedded: []Q16,
    q_proj: []Q16,
    k_proj: []Q16,
    v_proj: []Q16,
    scores: []i32, // seq_len × seq_len, Q16.v values
    shifted: []i32, // seq_len × seq_len
    weights: []i32, // seq_len × seq_len, softmax output
    attn_out: []Q16,
    post_wo: []Q16,
    post_attn_res: []Q16,
    ffn_pre_relu: []Q16,
    ffn_post_relu: []Q16,
    ffn_out: []Q16,
    post_ffn_res: []Q16,
    logits: []Q16,

    // Dimensions for indexing
    seq_len: usize,
    d_model: usize,
    ffn_dim: usize,
    vocab_size: usize,
};

// ============================================================
// Model
// ============================================================

pub const GemmModel = struct {
    // Config
    vocab_size: i32,
    d_model: i32,
    seq_len: i32,
    ffn_dim: i32,

    // Vocabulary
    vocab_ids: []VdrId,

    // Weights (Q16)
    token_emb: []Q16, // vocab_size × d_model
    pos_emb: []Q16, // seq_len × d_model
    wq: []Q16, // d_model × d_model
    wq_b: []Q16, // d_model
    wk: []Q16,
    wk_b: []Q16,
    wv: []Q16,
    wv_b: []Q16,
    wo: []Q16,
    wo_b: []Q16,
    ffn1: []Q16, // ffn_dim × d_model
    ffn1_b: []Q16, // ffn_dim
    ffn2: []Q16, // d_model × ffn_dim
    ffn2_b: []Q16, // d_model
    out_w: []Q16, // vocab_size × d_model
    out_b: []Q16, // vocab_size

    // Gradients (i32)
    wq_g: []i32,
    wk_g: []i32,
    wv_g: []i32,
    wo_g: []i32,
    ffn1_g: []i32,
    ffn2_g: []i32,
    out_g: []i32,
    wq_b_g: []i32,
    wk_b_g: []i32,
    wv_b_g: []i32,
    wo_b_g: []i32,
    ffn1_b_g: []i32,
    ffn2_b_g: []i32,
    out_b_g: []i32,

    // Forward cache
    cache: *GemmForwardCache,

    // Source
    kb_id: VdrId,
    generation: i32,
};

// ============================================================
// Training Window
// ============================================================

const TrainingWindow = struct {
    context: [16]i32, // max seq_len=16, token indices
    target: i32,
};

// ============================================================
// Create Model
// ============================================================

pub fn createModel(
    arena: *Arena,
    kb: *KB,
    d_model: i32,
    seq_len: i32,
    ffn_dim: i32,
    seed: u32,
) ?*GemmModel {
    const data_list = kb.data orelse return null;
    const vocab_size: i32 = @intCast(data_list.items.len);
    if (vocab_size == 0) return null;

    const model = arena.allocTyped(GemmModel) orelse return null;
    model.* = GemmModel{
        .vocab_size = vocab_size,
        .d_model = d_model,
        .seq_len = seq_len,
        .ffn_dim = ffn_dim,
        .vocab_ids = &.{},
        .token_emb = &.{},
        .pos_emb = &.{},
        .wq = &.{},
        .wq_b = &.{},
        .wk = &.{},
        .wk_b = &.{},
        .wv = &.{},
        .wv_b = &.{},
        .wo = &.{},
        .wo_b = &.{},
        .ffn1 = &.{},
        .ffn1_b = &.{},
        .ffn2 = &.{},
        .ffn2_b = &.{},
        .out_w = &.{},
        .out_b = &.{},
        .wq_g = &.{},
        .wk_g = &.{},
        .wv_g = &.{},
        .wo_g = &.{},
        .ffn1_g = &.{},
        .ffn2_g = &.{},
        .out_g = &.{},
        .wq_b_g = &.{},
        .wk_b_g = &.{},
        .wv_b_g = &.{},
        .wo_b_g = &.{},
        .ffn1_b_g = &.{},
        .ffn2_b_g = &.{},
        .out_b_g = &.{},
        .cache = undefined,
        .kb_id = kb.id,
        .generation = 0,
    };

    const vs: usize = @intCast(vocab_size);
    const dm: usize = @intCast(d_model);
    const sl: usize = @intCast(seq_len);
    const fd: usize = @intCast(ffn_dim);

    // Vocabulary IDs
    model.vocab_ids = arena.allocSlice(VdrId, vs) orelse return null;
    for (0..vs) |i| {
        model.vocab_ids[i] = data_list.items[i].id;
    }

    // Allocate weights
    model.token_emb = arena.allocSlice(Q16, vs * dm) orelse return null;
    model.pos_emb = arena.allocSlice(Q16, sl * dm) orelse return null;
    model.wq = arena.allocSlice(Q16, dm * dm) orelse return null;
    model.wq_b = arena.allocSlice(Q16, dm) orelse return null;
    model.wk = arena.allocSlice(Q16, dm * dm) orelse return null;
    model.wk_b = arena.allocSlice(Q16, dm) orelse return null;
    model.wv = arena.allocSlice(Q16, dm * dm) orelse return null;
    model.wv_b = arena.allocSlice(Q16, dm) orelse return null;
    model.wo = arena.allocSlice(Q16, dm * dm) orelse return null;
    model.wo_b = arena.allocSlice(Q16, dm) orelse return null;
    model.ffn1 = arena.allocSlice(Q16, fd * dm) orelse return null;
    model.ffn1_b = arena.allocSlice(Q16, fd) orelse return null;
    model.ffn2 = arena.allocSlice(Q16, dm * fd) orelse return null;
    model.ffn2_b = arena.allocSlice(Q16, dm) orelse return null;
    model.out_w = arena.allocSlice(Q16, vs * dm) orelse return null;
    model.out_b = arena.allocSlice(Q16, vs) orelse return null;

    // Allocate gradients
    model.wq_g = arena.allocSlice(i32, dm * dm) orelse return null;
    model.wk_g = arena.allocSlice(i32, dm * dm) orelse return null;
    model.wv_g = arena.allocSlice(i32, dm * dm) orelse return null;
    model.wo_g = arena.allocSlice(i32, dm * dm) orelse return null;
    model.ffn1_g = arena.allocSlice(i32, fd * dm) orelse return null;
    model.ffn2_g = arena.allocSlice(i32, dm * fd) orelse return null;
    model.out_g = arena.allocSlice(i32, vs * dm) orelse return null;
    model.wq_b_g = arena.allocSlice(i32, dm) orelse return null;
    model.wk_b_g = arena.allocSlice(i32, dm) orelse return null;
    model.wv_b_g = arena.allocSlice(i32, dm) orelse return null;
    model.wo_b_g = arena.allocSlice(i32, dm) orelse return null;
    model.ffn1_b_g = arena.allocSlice(i32, fd) orelse return null;
    model.ffn2_b_g = arena.allocSlice(i32, dm) orelse return null;
    model.out_b_g = arena.allocSlice(i32, vs) orelse return null;

    // Allocate forward cache
    model.cache = arena.allocTyped(GemmForwardCache) orelse return null;
    model.cache.* = GemmForwardCache{
        .embedded = arena.allocSlice(Q16, sl * dm) orelse return null,
        .q_proj = arena.allocSlice(Q16, sl * dm) orelse return null,
        .k_proj = arena.allocSlice(Q16, sl * dm) orelse return null,
        .v_proj = arena.allocSlice(Q16, sl * dm) orelse return null,
        .scores = arena.allocSlice(i32, sl * sl) orelse return null,
        .shifted = arena.allocSlice(i32, sl * sl) orelse return null,
        .weights = arena.allocSlice(i32, sl * sl) orelse return null,
        .attn_out = arena.allocSlice(Q16, sl * dm) orelse return null,
        .post_wo = arena.allocSlice(Q16, sl * dm) orelse return null,
        .post_attn_res = arena.allocSlice(Q16, sl * dm) orelse return null,
        .ffn_pre_relu = arena.allocSlice(Q16, sl * fd) orelse return null,
        .ffn_post_relu = arena.allocSlice(Q16, sl * fd) orelse return null,
        .ffn_out = arena.allocSlice(Q16, sl * dm) orelse return null,
        .post_ffn_res = arena.allocSlice(Q16, sl * dm) orelse return null,
        .logits = arena.allocSlice(Q16, sl * vs) orelse return null,
        .seq_len = sl,
        .d_model = dm,
        .ffn_dim = fd,
        .vocab_size = vs,
    };

    // Initialize weights — scale down for larger vocab
    var rng = LCG.init(seed);
    initWeightsQ16(model.token_emb, &rng, 1024);
    initWeightsQ16(model.pos_emb, &rng, 1024);
    initWeightsQ16(model.wq, &rng, 512);
    initBiasQ16(model.wq_b, &rng, 256);
    initWeightsQ16(model.wk, &rng, 512);
    initBiasQ16(model.wk_b, &rng, 256);
    initWeightsQ16(model.wv, &rng, 512);
    initBiasQ16(model.wv_b, &rng, 256);
    initWeightsQ16(model.wo, &rng, 512);
    initBiasQ16(model.wo_b, &rng, 256);
    initWeightsQ16(model.ffn1, &rng, 512);
    initBiasQ16(model.ffn1_b, &rng, 256);
    initWeightsQ16(model.ffn2, &rng, 512);
    initBiasQ16(model.ffn2_b, &rng, 256);
    initWeightsQ16(model.out_w, &rng, 512);
    initBiasQ16(model.out_b, &rng, 256);

    // Zero gradients
    zeroGrad(model);

    return model;
}

fn initWeightsQ16(slice: []Q16, rng: *LCG, scale: i32) void {
    for (slice) |*w| {
        w.* = rng.nextQ16(scale);
    }
}

fn initBiasQ16(slice: []Q16, rng: *LCG, scale: i32) void {
    for (slice) |*b| {
        const raw = rng.next();
        const val: i32 = @as(i32, @intCast(raw % 3)) - 1; // -1, 0, 1
        b.* = Q16.fromParts(val * scale, 0, 0);
    }
}

// ============================================================
// Zero Gradients
// ============================================================

pub fn zeroGrad(model: *GemmModel) void {
    @memset(model.wq_g, 0);
    @memset(model.wk_g, 0);
    @memset(model.wv_g, 0);
    @memset(model.wo_g, 0);
    @memset(model.ffn1_g, 0);
    @memset(model.ffn2_g, 0);
    @memset(model.out_g, 0);
    @memset(model.wq_b_g, 0);
    @memset(model.wk_b_g, 0);
    @memset(model.wv_b_g, 0);
    @memset(model.wo_b_g, 0);
    @memset(model.ffn1_b_g, 0);
    @memset(model.ffn2_b_g, 0);
    @memset(model.out_b_g, 0);
}

// ============================================================
// Linear Forward: out = W @ input + bias (Q16)
// W is [rows × cols], input is [cols], out is [rows]
// ============================================================

fn linearForward(
    weight: []const Q16,
    bias: []const Q16,
    input: []const Q16,
    output: []Q16,
    rows: usize,
    cols: usize,
) void {
    for (0..rows) |i| {
        var acc: i64 = 0;
        for (0..cols) |j| {
            acc += @as(i64, weight[i * cols + j].v) * @as(i64, input[j].v);
        }
        const v_raw: i64 = @divTrunc(acc, D) + @as(i64, bias[i].v);
        const r_raw: i64 = @mod(acc, D);
        const v_clamped: i32 = if (v_raw > std.math.maxInt(i32))
            std.math.maxInt(i32)
        else if (v_raw < std.math.minInt(i32))
            std.math.minInt(i32)
        else
            @intCast(v_raw);
        const r_clamped: u16 = @intCast(r_raw);
        output[i] = Q16.fromParts(v_clamped, r_clamped, 0);
    }
}

// ============================================================
// Linear Backward
// ============================================================

fn linearBackward(
    weight: []const Q16,
    weight_grad: []i32,
    bias_grad: []i32,
    input: []const Q16,
    grad_output: []const i32,
    grad_input: []i32,
    rows: usize,
    cols: usize,
) void {
    // grad_input = W^T @ grad_output
    for (0..cols) |j| {
        var acc: i64 = 0;
        for (0..rows) |i| {
            acc += @as(i64, weight[i * cols + j].v) * @as(i64, grad_output[i]);
        }
        grad_input[j] = @intCast(@divTrunc(acc, D));
    }

    // weight_grad += outer(grad_output, input)
    for (0..rows) |i| {
        for (0..cols) |j| {
            const prod: i64 = @as(i64, grad_output[i]) * @as(i64, input[j].v);
            weight_grad[i * cols + j] += @intCast(@divTrunc(prod, D));
        }
    }

    // bias_grad += grad_output
    for (0..rows) |i| {
        bias_grad[i] += grad_output[i];
    }
}

// ============================================================
// Softmax (FRU — sums to D exactly)
// ============================================================

fn softmaxExact(
    input: []const i32,
    output: []i32,
    shifted_out: []i32,
    count: usize,
) void {
    const d_i64: i64 = @as(i64, D);

    // Find min
    var min_val: i32 = input[0];
    for (1..count) |i| {
        if (input[i] < min_val) min_val = input[i];
    }

    // Shift and find max shifted value
    var max_shifted: i64 = 0;
    for (0..count) |i| {
        const diff: i64 = @as(i64, input[i]) - @as(i64, min_val);
        const clamped: i32 = if (diff > std.math.maxInt(i32))
            std.math.maxInt(i32)
        else if (diff < 0)
            0
        else
            @intCast(diff);
        shifted_out[i] = clamped;
        if (@as(i64, clamped) > max_shifted) max_shifted = @as(i64, clamped);
    }

    // Compute right-shift to keep count * (max >> shift)^2 in i64 range
    var shift: u6 = 0;
    if (max_shifted > 0) {
        var test_max = max_shifted;
        const limit: i64 = @divTrunc(std.math.maxInt(i64), @as(i64, @intCast(count)) + 1);
        while (test_max > 0 and test_max * test_max > limit) {
            test_max = test_max >> 1;
            shift += 1;
        }
    }

    // Sum of squares with shift applied
    var sum_sq: i64 = 0;
    for (0..count) |i| {
        const s: i64 = @as(i64, shifted_out[i]) >> shift;
        sum_sq += s * s;
    }

    // Uniform fallback if all values equal
    if (sum_sq == 0) {
        const uniform: i32 = @intCast(@divTrunc(d_i64, @as(i64, @intCast(count))));
        for (0..count) |i| {
            output[i] = uniform;
        }
        const total: i64 = @as(i64, uniform) * @as(i64, @intCast(count));
        const deficit: i32 = @intCast(d_i64 - total);
        output[0] += deficit;
        return;
    }

    // Compute probabilities: p[i] = s[i]^2 * D / sum_sq
    // Using same shift for numerator and denominator preserves ratio
    // Further reduce s_sq and sum_sq together if product with D would overflow
    var running: i64 = 0;
    for (0..count - 1) |i| {
        const s: i64 = @as(i64, shifted_out[i]) >> shift;
        var s_sq_local: i64 = s * s;
        var sq_local: i64 = sum_sq;

        // Reduce until s_sq_local * D fits in i64
        while (s_sq_local > std.math.maxInt(i32) and sq_local > 1) {
            s_sq_local = s_sq_local >> 1;
            sq_local = sq_local >> 1;
        }
        if (sq_local == 0) sq_local = 1;

        const p: i64 = @divTrunc(s_sq_local * d_i64, sq_local);
        const p_clamped: i64 = if (p < 0) 0 else if (p > d_i64) d_i64 else p;
        output[i] = @intCast(p_clamped);
        running += p_clamped;
    }

    // FRU: last element gets remainder so sum = D exactly
    const last_val: i64 = d_i64 - running;
    output[count - 1] = @intCast(if (last_val < 0) 0 else last_val);
}

// ============================================================
// Softmax Backward
// ============================================================

fn softmaxBackward(
    grad_probs: []const i32,
    probs: []const i32,
    shifted: []const i32,
    grad_scores: []i32,
    count: usize,
) void {
    // Find max shifted to compute safe shift amount
    var max_shifted: i64 = 0;
    for (0..count) |i| {
        const abs_s: i64 = if (shifted[i] < 0) -@as(i64, shifted[i]) else @as(i64, shifted[i]);
        if (abs_s > max_shifted) max_shifted = abs_s;
    }

    var shift: u6 = 0;
    if (max_shifted > 0) {
        var test_max = max_shifted;
        const limit: i64 = @divTrunc(std.math.maxInt(i64), @as(i64, @intCast(count)) + 1);
        while (test_max > 0 and test_max * test_max > limit) {
            test_max = test_max >> 1;
            shift += 1;
        }
    }

    var sum_sq: i64 = 0;
    for (0..count) |i| {
        const s: i64 = @as(i64, shifted[i]) >> shift;
        sum_sq += s * s;
    }

    if (sum_sq == 0) {
        for (0..count) |i| grad_scores[i] = 0;
        return;
    }

    var dot_gp: i64 = 0;
    for (0..count) |i| {
        dot_gp += @as(i64, grad_probs[i]) * @as(i64, probs[i]);
    }

    for (0..count) |i| {
        const diff: i64 = @as(i64, grad_probs[i]) * D - dot_gp;
        const s: i64 = @as(i64, shifted[i]) >> shift;
        const numer: i64 = 2 * s * diff;
        // Reduce numer and sum_sq together if numer too large for divTrunc
        var numer_local: i64 = numer;
        var sq_local: i64 = sum_sq;
        while ((numer_local > std.math.maxInt(i32) or numer_local < std.math.minInt(i32)) and sq_local > 1) {
            numer_local = numer_local >> 1;
            sq_local = sq_local >> 1;
        }
        if (sq_local == 0) sq_local = 1;
        const result: i64 = @divTrunc(numer_local, sq_local);
        grad_scores[i] = if (result > std.math.maxInt(i32))
            std.math.maxInt(i32)
        else if (result < std.math.minInt(i32))
            std.math.minInt(i32)
        else
            @intCast(result);
    }
}

// ============================================================
// ReLU Forward / Backward
// ============================================================

fn reluForward(input: []const Q16, output: []Q16, count: usize) void {
    for (0..count) |i| {
        if (input[i].v > 0) {
            output[i] = input[i];
        } else {
            output[i] = Q16.zero();
        }
    }
}

fn reluBackward(pre_relu: []const Q16, grad_out: []const i32, grad_in: []i32, count: usize) void {
    for (0..count) |i| {
        grad_in[i] = if (pre_relu[i].v > 0) grad_out[i] else 0;
    }
}

// ============================================================
// Residual Add (Q16)
// ============================================================

fn residualAdd(a: []const Q16, b: []const Q16, output: []Q16, count: usize) void {
    for (0..count) |i| {
        output[i] = Q16.add(a[i], b[i]);
    }
}

// ============================================================
// Attention Scores: scores[i][j] = dot(Q[i], K[j]) / D
// With causal mask: j > i → -maxInt
// ============================================================

fn attentionScores(cache: *GemmForwardCache) void {
    const sl = cache.seq_len;
    const dm = cache.d_model;

    for (0..sl) |i| {
        for (0..sl) |j| {
            if (j > i) {
                cache.scores[i * sl + j] = -std.math.maxInt(i32);
                continue;
            }
            var acc: i64 = 0;
            for (0..dm) |d| {
                acc += @as(i64, cache.q_proj[i * dm + d].v) * @as(i64, cache.k_proj[j * dm + d].v);
            }
            cache.scores[i * sl + j] = @intCast(@divTrunc(acc, D));
        }
    }
}

// ============================================================
// Attention Mix: attn_out[i] = sum_j(weights[i][j] * V[j])
// ============================================================

fn attentionMix(cache: *GemmForwardCache) void {
    const sl = cache.seq_len;
    const dm = cache.d_model;

    for (0..sl) |i| {
        for (0..dm) |d| {
            var acc: i64 = 0;
            for (0..sl) |j| {
                acc += @as(i64, cache.weights[i * sl + j]) * @as(i64, cache.v_proj[j * dm + d].v);
            }
            cache.attn_out[i * dm + d] = Q16.fromParts(
                @intCast(@divTrunc(acc, D)),
                0,
                0,
            );
        }
    }
}

// ============================================================
// Attention Mix Backward
// ============================================================

fn attentionMixBackward(
    cache: *const GemmForwardCache,
    grad_attn_out: []const i32,
    grad_weights: []i32,
    grad_v: []i32,
) void {
    const sl = cache.seq_len;
    const dm = cache.d_model;

    // grad_weights[i][j] = dot(grad_attn_out[i], V[j])
    for (0..sl) |i| {
        for (0..sl) |j| {
            var acc: i64 = 0;
            for (0..dm) |d| {
                acc += @as(i64, grad_attn_out[i * dm + d]) * @as(i64, cache.v_proj[j * dm + d].v);
            }
            grad_weights[i * sl + j] = @intCast(@divTrunc(acc, D));
        }
    }

    // grad_v[j][d] = sum_i(weights[i][j] * grad_attn_out[i][d])
    for (0..sl) |j| {
        for (0..dm) |d| {
            var acc: i64 = 0;
            for (0..sl) |i| {
                acc += @as(i64, cache.weights[i * sl + j]) * @as(i64, grad_attn_out[i * dm + d]);
            }
            grad_v[j * dm + d] = @intCast(@divTrunc(acc, D));
        }
    }
}

// ============================================================
// Score Backward
// ============================================================

fn scoreBackward(
    cache: *const GemmForwardCache,
    grad_scores: []const i32,
    grad_q: []i32,
    grad_k: []i32,
) void {
    const sl = cache.seq_len;
    const dm = cache.d_model;

    for (0..sl) |i| {
        for (0..dm) |d| {
            var acc: i64 = 0;
            for (0..sl) |j| {
                acc += @as(i64, grad_scores[i * sl + j]) * @as(i64, cache.k_proj[j * dm + d].v);
            }
            grad_q[i * dm + d] = @intCast(@divTrunc(acc, D));
        }
    }

    for (0..sl) |j| {
        for (0..dm) |d| {
            var acc: i64 = 0;
            for (0..sl) |i| {
                acc += @as(i64, grad_scores[i * sl + j]) * @as(i64, cache.q_proj[i * dm + d].v);
            }
            grad_k[j * dm + d] = @intCast(@divTrunc(acc, D));
        }
    }
}

// ============================================================
// Full Forward Pass
// ============================================================

pub fn forward(model: *GemmModel, token_indices: []const i32) void {
    const sl = @as(usize, @intCast(model.seq_len));
    const dm = @as(usize, @intCast(model.d_model));
    const fd = @as(usize, @intCast(model.ffn_dim));
    const vs = @as(usize, @intCast(model.vocab_size));
    const cache = model.cache;

    // Embed: token_emb[tid] + pos_emb[pos]
    for (0..sl) |pos| {
        const tid: usize = @intCast(token_indices[pos]);
        for (0..dm) |d| {
            cache.embedded[pos * dm + d] = Q16.add(
                model.token_emb[tid * dm + d],
                model.pos_emb[pos * dm + d],
            );
        }
    }

    // Q, K, V projections
    for (0..sl) |pos| {
        linearForward(model.wq, model.wq_b, cache.embedded[pos * dm .. (pos + 1) * dm], cache.q_proj[pos * dm .. (pos + 1) * dm], dm, dm);
        linearForward(model.wk, model.wk_b, cache.embedded[pos * dm .. (pos + 1) * dm], cache.k_proj[pos * dm .. (pos + 1) * dm], dm, dm);
        linearForward(model.wv, model.wv_b, cache.embedded[pos * dm .. (pos + 1) * dm], cache.v_proj[pos * dm .. (pos + 1) * dm], dm, dm);
    }

    // Attention scores + softmax + mix
    attentionScores(cache);

    for (0..sl) |i| {
        softmaxExact(
            cache.scores[i * sl .. (i + 1) * sl],
            cache.weights[i * sl .. (i + 1) * sl],
            cache.shifted[i * sl .. (i + 1) * sl],
            sl,
        );
    }

    attentionMix(cache);

    // Wo projection
    for (0..sl) |pos| {
        linearForward(model.wo, model.wo_b, cache.attn_out[pos * dm .. (pos + 1) * dm], cache.post_wo[pos * dm .. (pos + 1) * dm], dm, dm);
    }

    // Residual: embedded + post_wo
    for (0..sl) |pos| {
        residualAdd(
            cache.embedded[pos * dm .. (pos + 1) * dm],
            cache.post_wo[pos * dm .. (pos + 1) * dm],
            cache.post_attn_res[pos * dm .. (pos + 1) * dm],
            dm,
        );
    }

    // FFN: linear1 → relu → linear2
    for (0..sl) |pos| {
        linearForward(model.ffn1, model.ffn1_b, cache.post_attn_res[pos * dm .. (pos + 1) * dm], cache.ffn_pre_relu[pos * fd .. (pos + 1) * fd], fd, dm);
        reluForward(cache.ffn_pre_relu[pos * fd .. (pos + 1) * fd], cache.ffn_post_relu[pos * fd .. (pos + 1) * fd], fd);
        linearForward(model.ffn2, model.ffn2_b, cache.ffn_post_relu[pos * fd .. (pos + 1) * fd], cache.ffn_out[pos * dm .. (pos + 1) * dm], dm, fd);
    }

    // Residual: post_attn_res + ffn_out
    for (0..sl) |pos| {
        residualAdd(
            cache.post_attn_res[pos * dm .. (pos + 1) * dm],
            cache.ffn_out[pos * dm .. (pos + 1) * dm],
            cache.post_ffn_res[pos * dm .. (pos + 1) * dm],
            dm,
        );
    }

    // Output projection → logits
    for (0..sl) |pos| {
        linearForward(model.out_w, model.out_b, cache.post_ffn_res[pos * dm .. (pos + 1) * dm], cache.logits[pos * vs .. (pos + 1) * vs], vs, dm);
    }
}

// ============================================================
// Full Backward Pass (from last position only)
// ============================================================

pub fn backward(model: *GemmModel, grad_logits_last: []const i32) void {
    const sl = @as(usize, @intCast(model.seq_len));
    const dm = @as(usize, @intCast(model.d_model));
    const fd = @as(usize, @intCast(model.ffn_dim));
    const vs = @as(usize, @intCast(model.vocab_size));
    const cache = model.cache;
    const last = sl - 1;

    // Scratch buffers (stack allocated, bounded by dimensions)
    var grad_post_ffn: [4096]i32 = [_]i32{0} ** 4096;
    var grad_ffn2_out: [4096]i32 = [_]i32{0} ** 4096;
    var grad_post_relu: [4096]i32 = [_]i32{0} ** 4096;
    var grad_pre_relu: [4096]i32 = [_]i32{0} ** 4096;
    var grad_from_ffn1: [4096]i32 = [_]i32{0} ** 4096;
    var grad_post_attn_res: [4096]i32 = [_]i32{0} ** 4096;
    var grad_post_wo_last: [4096]i32 = [_]i32{0} ** 4096;
    var grad_attn_out: [4096]i32 = [_]i32{0} ** 4096;
    var grad_weights_buf: [256]i32 = [_]i32{0} ** 256; // sl × sl max 16×16
    var grad_v_buf: [4096]i32 = [_]i32{0} ** 4096;
    var grad_scores_buf: [256]i32 = [_]i32{0} ** 256;
    var grad_q_buf: [4096]i32 = [_]i32{0} ** 4096;
    var grad_k_buf: [4096]i32 = [_]i32{0} ** 4096;
    var discard: [4096]i32 = [_]i32{0} ** 4096;

    // Backward through output projection
    linearBackward(
        model.out_w,
        model.out_g,
        model.out_b_g,
        cache.post_ffn_res[last * dm .. (last + 1) * dm],
        grad_logits_last,
        grad_post_ffn[0..dm],
        vs,
        dm,
    );

    // FFN residual: grad splits to FFN path and skip
    @memcpy(grad_ffn2_out[0..dm], grad_post_ffn[0..dm]);
    const grad_skip_ffn = grad_post_ffn[0..dm];

    // Backward through ffn2
    linearBackward(
        model.ffn2,
        model.ffn2_g,
        model.ffn2_b_g,
        cache.ffn_post_relu[last * fd .. (last + 1) * fd],
        grad_ffn2_out[0..dm],
        grad_post_relu[0..fd],
        dm,
        fd,
    );

    // Backward through relu
    reluBackward(
        cache.ffn_pre_relu[last * fd .. (last + 1) * fd],
        grad_post_relu[0..fd],
        grad_pre_relu[0..fd],
        fd,
    );

    // Backward through ffn1
    linearBackward(
        model.ffn1,
        model.ffn1_g,
        model.ffn1_b_g,
        cache.post_attn_res[last * dm .. (last + 1) * dm],
        grad_pre_relu[0..fd],
        grad_from_ffn1[0..dm],
        fd,
        dm,
    );

    // Combine FFN backward + skip
    for (0..dm) |d| {
        grad_post_attn_res[d] = grad_from_ffn1[d] + grad_skip_ffn[d];
    }

    // Attention residual: grad splits to Wo path and skip
    @memcpy(grad_post_wo_last[0..dm], grad_post_attn_res[0..dm]);

    // Backward through Wo
    linearBackward(
        model.wo,
        model.wo_g,
        model.wo_b_g,
        cache.attn_out[last * dm .. (last + 1) * dm],
        grad_post_wo_last[0..dm],
        grad_attn_out[0..dm],
        dm,
        dm,
    );

    // Backward through attention mix
    // Need full seq_len grad_attn_out but we only have last position
    // Zero-fill a full buffer
    var full_grad_attn: [4096]i32 = [_]i32{0} ** 4096;
    @memcpy(full_grad_attn[last * dm .. (last + 1) * dm], grad_attn_out[0..dm]);

    attentionMixBackward(
        cache,
        full_grad_attn[0 .. sl * dm],
        grad_weights_buf[0 .. sl * sl],
        grad_v_buf[0 .. sl * dm],
    );

    // Backward through softmax (all rows, since attention mix touches all)
    for (0..sl) |i| {
        softmaxBackward(
            grad_weights_buf[i * sl .. (i + 1) * sl],
            cache.weights[i * sl .. (i + 1) * sl],
            cache.shifted[i * sl .. (i + 1) * sl],
            grad_scores_buf[i * sl .. (i + 1) * sl],
            sl,
        );
    }

    // Backward through scores
    scoreBackward(
        cache,
        grad_scores_buf[0 .. sl * sl],
        grad_q_buf[0 .. sl * dm],
        grad_k_buf[0 .. sl * dm],
    );

    // Backward through Q, K, V projections
    for (0..sl) |pos| {
        linearBackward(
            model.wq,
            model.wq_g,
            model.wq_b_g,
            cache.embedded[pos * dm .. (pos + 1) * dm],
            grad_q_buf[pos * dm .. (pos + 1) * dm],
            discard[0..dm],
            dm,
            dm,
        );
        linearBackward(
            model.wk,
            model.wk_g,
            model.wk_b_g,
            cache.embedded[pos * dm .. (pos + 1) * dm],
            grad_k_buf[pos * dm .. (pos + 1) * dm],
            discard[0..dm],
            dm,
            dm,
        );
        linearBackward(
            model.wv,
            model.wv_g,
            model.wv_b_g,
            cache.embedded[pos * dm .. (pos + 1) * dm],
            grad_v_buf[pos * dm .. (pos + 1) * dm],
            discard[0..dm],
            dm,
            dm,
        );
    }
}

// ============================================================
// SGD Step
// ============================================================

pub fn sgdStep(model: *GemmModel, lr: i32) void {
    sgdUpdateQ16(model.wq, model.wq_g, lr);
    sgdUpdateQ16(model.wk, model.wk_g, lr);
    sgdUpdateQ16(model.wv, model.wv_g, lr);
    sgdUpdateQ16(model.wo, model.wo_g, lr);
    sgdUpdateQ16(model.ffn1, model.ffn1_g, lr);
    sgdUpdateQ16(model.ffn2, model.ffn2_g, lr);
    sgdUpdateQ16(model.out_w, model.out_g, lr);
    sgdUpdateQ16(model.wq_b, model.wq_b_g, lr);
    sgdUpdateQ16(model.wk_b, model.wk_b_g, lr);
    sgdUpdateQ16(model.wv_b, model.wv_b_g, lr);
    sgdUpdateQ16(model.wo_b, model.wo_b_g, lr);
    sgdUpdateQ16(model.ffn1_b, model.ffn1_b_g, lr);
    sgdUpdateQ16(model.ffn2_b, model.ffn2_b_g, lr);
    sgdUpdateQ16(model.out_b, model.out_b_g, lr);
}

fn sgdUpdateQ16(weights: []Q16, grads: []i32, lr: i32) void {
    for (weights, grads) |*w, g| {
        const update: i64 = @as(i64, lr) * @as(i64, g);
        const step: i32 = @intCast(@divTrunc(update, D));
        w.v -= step;
    }
}

// ============================================================
// Loss (MSE in Q16 scale)
// ============================================================

fn mseLoss(pred: []const i32, target: []const i32, count: usize) i64 {
    var total: i64 = 0;
    for (0..count) |i| {
        const diff: i64 = @as(i64, pred[i]) - @as(i64, target[i]);
        total += diff * diff;
    }
    return @divTrunc(total, @as(i64, @intCast(count)));
}

fn mseGrad(pred: []const i32, target: []const i32, grad: []i32, count: usize) void {
    for (0..count) |i| {
        const diff: i32 = pred[i] - target[i];
        grad[i] = @divTrunc(2 * diff, @as(i32, @intCast(count)));
    }
}

fn oneHot(target_idx: usize, output: []i32, count: usize) void {
    for (0..count) |i| {
        output[i] = if (i == target_idx) D else 0;
    }
}

// ============================================================
// Train Step
// ============================================================

pub fn trainStep(model: *GemmModel, context: []const i32, target_idx: i32) i64 {
    const vs = @as(usize, @intCast(model.vocab_size));
    const sl = @as(usize, @intCast(model.seq_len));

    forward(model, context);

    // Softmax on last position logits
    var probs: [4096]i32 = [_]i32{0} ** 4096;
    var shifted: [4096]i32 = [_]i32{0} ** 4096;
    const last_logits_start = (sl - 1) * vs;

    // Extract v fields from logits for softmax
    var logit_vals: [4096]i32 = [_]i32{0} ** 4096;
    for (0..vs) |i| {
        logit_vals[i] = model.cache.logits[last_logits_start + i].v;
    }

    softmaxExact(logit_vals[0..vs], probs[0..vs], shifted[0..vs], vs);

    // One-hot target
    var target: [4096]i32 = [_]i32{0} ** 4096;
    oneHot(@intCast(target_idx), target[0..vs], vs);

    // Loss
    const loss = mseLoss(probs[0..vs], target[0..vs], vs);

    // Grad of loss
    var grad_probs: [4096]i32 = [_]i32{0} ** 4096;
    mseGrad(probs[0..vs], target[0..vs], grad_probs[0..vs], vs);

    // Backward through softmax
    var grad_logits: [4096]i32 = [_]i32{0} ** 4096;
    softmaxBackward(grad_probs[0..vs], probs[0..vs], shifted[0..vs], grad_logits[0..vs], vs);

    // Backward through model
    zeroGrad(model);
    backward(model, grad_logits[0..vs]);

    // SGD
    sgdStep(model, DEFAULT_LR);

    return loss;
}

// ============================================================
// Greedy Inference
// ============================================================

pub fn inferGreedy(model: *GemmModel, prompt: []const i32, max_tokens: usize, output: []i32) usize {
    const sl = @as(usize, @intCast(model.seq_len));
    const vs = @as(usize, @intCast(model.vocab_size));

    // Build running sequence
    var seq: [64]i32 = [_]i32{0} ** 64;
    const prompt_len = @min(prompt.len, sl);
    @memcpy(seq[0..prompt_len], prompt[0..prompt_len]);
    var seq_len: usize = prompt_len;

    // Copy prompt to output
    @memcpy(output[0..prompt_len], prompt[0..prompt_len]);
    var out_len: usize = prompt_len;

    for (0..max_tokens) |_| {
        // Build context window from last seq_len tokens
        var context: [16]i32 = [_]i32{0} ** 16;
        if (seq_len >= sl) {
            @memcpy(context[0..sl], seq[seq_len - sl .. seq_len]);
        } else {
            @memcpy(context[0..seq_len], seq[0..seq_len]);
        }

        forward(model, context[0..sl]);

        // Softmax on last position
        var probs: [4096]i32 = [_]i32{0} ** 4096;
        var shifted: [4096]i32 = [_]i32{0} ** 4096;
        const last = (sl - 1) * vs;
        var logit_vals: [4096]i32 = [_]i32{0} ** 4096;
        for (0..vs) |i| {
            logit_vals[i] = model.cache.logits[last + i].v;
        }
        softmaxExact(logit_vals[0..vs], probs[0..vs], shifted[0..vs], vs);

        // Greedy select
        var best_idx: usize = 0;
        var best_val: i32 = probs[0];
        for (1..vs) |i| {
            if (probs[i] > best_val) {
                best_val = probs[i];
                best_idx = i;
            }
        }

        const next_token: i32 = @intCast(best_idx);
        if (seq_len < 64) {
            seq[seq_len] = next_token;
            seq_len += 1;
        }
        if (out_len < output.len) {
            output[out_len] = next_token;
            out_len += 1;
        }
    }

    return out_len;
}

// ============================================================
// Build Training Windows from Relations
// ============================================================

fn findTokenIndex(model: *const GemmModel, load_result: *const compact_loader.LoadResult, arena_base: [*]u8, entity_id: []const u8) ?i32 {
    _ = model;
    var running: i32 = 0;
    for (0..load_result.table_count) |ti| {
        const table = &load_result.tables[ti];
        for (0..table.row_count) |ri| {
            const eid = table.entityId(ri, arena_base);
            if (std.mem.eql(u8, eid, entity_id)) return running;
            running += 1;
        }
    }
    return null;
}

fn findEntityIdByTokenIndex(
    load_result: *const compact_loader.LoadResult,
    arena_base: [*]u8,
    token_idx: i32,
) ?[]const u8 {
    var running: i32 = 0;
    for (0..load_result.table_count) |ti| {
        const table = &load_result.tables[ti];
        for (0..table.row_count) |ri| {
            if (running == token_idx) {
                return table.entityId(ri, arena_base);
            }
            running += 1;
        }
    }
    return null;
}

pub fn buildTrainingWindows(
    arena: *Arena,
    load_result: *const compact_loader.LoadResult,
    arena_base: [*]u8,
    model: *const GemmModel,
    seq_len: i32,
) struct { windows: []TrainingWindow, count: usize } {
    _ = model;
    const max_windows: usize = 2048;
    const windows = arena.allocSlice(TrainingWindow, max_windows) orelse return .{ .windows = &.{}, .count = 0 };
    var count: usize = 0;
    const sl: usize = @intCast(seq_len);

    // Each relation (from, to) generates a training window:
    // context = [from, from, from, from] (padded), target = to
    // And reverse: context = [to, to, to, to], target = from
    for (0..load_result.relationship_count) |ri| {
        const rel = &load_result.relationships[ri];
        if (rel.canonical_type == .unknown) continue;

        const from_idx = findTokenIndex(undefined, load_result, arena_base, rel.fromSlice()) orelse continue;
        const to_idx = findTokenIndex(undefined, load_result, arena_base, rel.toSlice()) orelse continue;

        // Forward window
        if (count < max_windows) {
            var w = &windows[count];
            w.* = TrainingWindow{
                .context = [_]i32{0} ** 16,
                .target = to_idx,
            };
            for (0..sl) |s| {
                w.context[s] = from_idx;
            }
            count += 1;
        }

        // Reverse window
        if (count < max_windows) {
            var w = &windows[count];
            w.* = TrainingWindow{
                .context = [_]i32{0} ** 16,
                .target = from_idx,
            };
            for (0..sl) |s| {
                w.context[s] = to_idx;
            }
            count += 1;
        }
    }

    return .{ .windows = windows[0..count], .count = count };
}

// ============================================================
// Test Entry Point
// ============================================================

pub fn testGemm(
    global_arena: *Arena,
    config: *kb_config.KbConfig,
) void {
    std.debug.print("\n=== GEMM Transformer Test ===\n", .{});

    // Find root.engineering.mechanical
    var target_entry: ?*kb_config.KbConfigEntry = null;
    for (0..config.count) |i| {
        if (std.mem.eql(u8, config.entries[i].dottedSlice(), "root.engineering.mechanical")) {
            target_entry = &config.entries[i];
            break;
        }
    }

    if (target_entry == null) {
        std.debug.print("  SKIP: root.engineering.mechanical not found\n", .{});
        return;
    }

    const entry = target_entry.?;
    const kb = entry.kb orelse {
        std.debug.print("  SKIP: KB not created\n", .{});
        return;
    };
    const load_result = entry.load_result orelse {
        std.debug.print("  SKIP: no load result\n", .{});
        return;
    };

    const data_count = if (kb.data) |d| d.items.len else 0;
    std.debug.print("  KB: {s}\n", .{entry.dottedSlice()});
    std.debug.print("  vocab size: {}\n", .{data_count});
    std.debug.print("  relations: {}\n", .{load_result.relationship_count});

    // Create model
    const model = createModel(
        global_arena,
        kb,
        DEFAULT_D_MODEL,
        DEFAULT_SEQ_LEN,
        DEFAULT_FFN_DIM,
        42,
    ) orelse {
        std.debug.print("  FAIL: createModel returned null\n", .{});
        return;
    };

    std.debug.print("  model created: vocab={}, d_model={}, seq_len={}, ffn_dim={}\n", .{
        model.vocab_size,
        model.d_model,
        model.seq_len,
        model.ffn_dim,
    });

    // Build training windows
    const tw = buildTrainingWindows(
        global_arena,
        load_result,
        global_arena.base,
        model,
        model.seq_len,
    );

    std.debug.print("  training windows: {}\n", .{tw.count});

    if (tw.count == 0) {
        std.debug.print("  SKIP: no training windows\n", .{});
        return;
    }

    // Train
    std.debug.print("  training {} epochs...\n", .{DEFAULT_EPOCHS});

    var first_loss: i64 = 0;
    var last_loss: i64 = 0;

    for (0..@as(usize, @intCast(DEFAULT_EPOCHS))) |epoch| {
        var epoch_loss: i64 = 0;

        for (0..tw.count) |wi| {
            const w = &tw.windows[wi];
            const sl: usize = @intCast(model.seq_len);
            const loss = trainStep(model, w.context[0..sl], w.target);
            epoch_loss += loss;
        }

        const avg_loss = @divTrunc(epoch_loss, @as(i64, @intCast(tw.count)));

        if (epoch == 0) first_loss = avg_loss;
        last_loss = avg_loss;

        if (epoch == 0 or epoch == @as(usize, @intCast(DEFAULT_EPOCHS)) - 1 or (epoch + 1) % 50 == 0) {
            std.debug.print("    epoch {d:3}: avg_loss={d}\n", .{ epoch + 1, avg_loss });
        }
    }

    // Verify loss decreased
    if (last_loss < first_loss) {
        std.debug.print("  PASS: loss decreased {d} -> {d}\n", .{ first_loss, last_loss });
    } else {
        std.debug.print("  WEAK: loss did not decrease {d} -> {d}\n", .{ first_loss, last_loss });
    }

    // Verify softmax sums to D
    var softmax_ok = true;
    for (0..@min(tw.count, 10)) |wi| {
        const w = &tw.windows[wi];
        const sl: usize = @intCast(model.seq_len);
        forward(model, w.context[0..sl]);

        const vs: usize = @intCast(model.vocab_size);
        var probs: [4096]i32 = [_]i32{0} ** 4096;
        var shifted: [4096]i32 = [_]i32{0} ** 4096;
        var logit_vals: [4096]i32 = [_]i32{0} ** 4096;
        const last_start = (sl - 1) * vs;
        for (0..vs) |i| {
            logit_vals[i] = model.cache.logits[last_start + i].v;
        }
        softmaxExact(logit_vals[0..vs], probs[0..vs], shifted[0..vs], vs);

        var total: i64 = 0;
        for (0..vs) |i| {
            total += @as(i64, probs[i]);
        }
        if (total != D) {
            softmax_ok = false;
            std.debug.print("  FAIL: softmax sum={d} (expected {d})\n", .{ total, D });
            break;
        }
    }
    if (softmax_ok) {
        std.debug.print("  PASS: softmax sums to D={d} exactly\n", .{D});
    }

    // Inference test: query EC4, check if PM5-PM9 appear in predictions
    const ec4_idx = findTokenIndex(undefined, load_result, global_arena.base, "EC4") orelse {
        std.debug.print("  SKIP: EC4 not found\n", .{});
        return;
    };

    std.debug.print("\n  Inference: EC4 (electric motor) -> predict next\n", .{});

    var prompt: [4]i32 = [_]i32{ec4_idx} ** 4;
    var output: [8]i32 = [_]i32{0} ** 8;
    const out_len = inferGreedy(model, &prompt, 4, &output);

    std.debug.print("  predicted sequence:\n", .{});
    for (0..out_len) |i| {
        const eid = findEntityIdByTokenIndex(load_result, global_arena.base, output[i]);
        if (eid) |name| {
            std.debug.print("    [{d}] {s}\n", .{ i, name });
        } else {
            std.debug.print("    [{d}] token_idx={}\n", .{ i, output[i] });
        }
    }

    // Check expected targets
    const expected = [_][]const u8{ "PM5", "PM6", "PM7", "PM8", "PM9" };
    var hits: i32 = 0;
    for (expected) |exp| {
        const exp_idx = findTokenIndex(undefined, load_result, global_arena.base, exp) orelse continue;
        for (0..out_len) |oi| {
            if (output[oi] == exp_idx) {
                hits += 1;
                break;
            }
        }
    }

    std.debug.print("  Expected PM5-PM9 in output: {}/5 found\n", .{hits});

    std.debug.print("\n  arena used: {} bytes\n", .{global_arena.usedBytes()});
    std.debug.print("  arena free: {} bytes\n", .{global_arena.freeBytes()});
    std.debug.print("=== GEMM Transformer Test Complete ===\n", .{});
}
