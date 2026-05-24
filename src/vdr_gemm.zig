// ============================================================
// vdr_gemm.zig
// GEMM cache building, training, and inference.
// Stripped-down test implementation.
// ============================================================

const std = @import("std");
const types = @import("vdr_types.zig");
const kb_config = @import("vdr_kb_config.zig");
const compact_loader = @import("vdr_compact_loader.zig");

const VdrId = types.VdrId;
const Q16 = types.Q16;
const KB = types.KB;
const Arena = types.Arena;
const GemmCache = types.GemmCache;
const InferenceResult = types.InferenceResult;

const D_MODEL: i32 = 32;
const LEARNING_RATE: i32 = 100; // Q16-scale step size
const TRAIN_EPOCHS: i32 = 50;
const TOP_N: i32 = 10;

// ============================================================
// Build GemmCache from KB data entries
// ============================================================

pub fn buildGemmCache(arena: *Arena, kb: *KB) ?*GemmCache {
    const data_list = kb.data orelse return null;
    const count: i32 = @intCast(data_list.items.len);
    if (count == 0) return null;

    const cache = arena.allocTyped(GemmCache) orelse return null;
    cache.* = GemmCache{};

    const total_values: usize = @intCast(count * D_MODEL);

    // Allocate v_packed: entry_count * d_model i32 values
    cache.v_packed = arena.allocSlice(i32, total_values) orelse return null;

    // Allocate ids: entry_count VdrIds
    const id_count: usize = @intCast(count);
    cache.ids = arena.allocSlice(VdrId, id_count) orelse return null;

    cache.entry_count = count;
    cache.d_model = D_MODEL;
    cache.kb_id = kb.id;
    cache.generation = 1;

    // Initialize embeddings from entity ID hash (deterministic, not random)
    for (0..id_count) |i| {
        const data_entry = &data_list.items[i];
        cache.ids[i] = data_entry.id;

        const base: usize = i * @as(usize, @intCast(D_MODEL));
        const seed: u64 = @bitCast(data_entry.id.v);

        for (0..@as(usize, @intCast(D_MODEL))) |d| {
            // Simple hash spread across dimensions
            var h: u64 = seed;
            h ^= @as(u64, d) *% 0x9E3779B97F4A7C15;
            h = (h ^ (h >> 30)) *% 0xBF58476D1CE4E5B9;
            h = (h ^ (h >> 27)) *% 0x94D049BB133111EB;
            h = h ^ (h >> 31);
            // Scale to small range centered on 0
            // Truncate to 16 bits first, then shift down for small range
            const h16: u16 = @truncate(h);
            const val: i32 = @as(i32, @as(i16, @bitCast(h16))) >> 4;
            cache.v_packed[base + d] = val;
        }
    }

    return cache;
}

// ============================================================
// Find entry index in cache by VdrId
// ============================================================

fn findEntryIndex(cache: *const GemmCache, id: VdrId) ?usize {
    for (cache.ids, 0..) |cache_id, i| {
        if (cache_id.eql(id)) return i;
    }
    return null;
}

// ============================================================
// Get embedding slice for entry i
// ============================================================

fn getEmbedding(cache: *const GemmCache, index: usize) []i32 {
    const d: usize = @intCast(cache.d_model);
    const base = index * d;
    return cache.v_packed[base .. base + d];
}

// ============================================================
// Dot product of two embedding slices
// ============================================================

fn dotProduct(a: []const i32, b: []const i32) i64 {
    var sum: i64 = 0;
    for (a, b) |av, bv| {
        sum += @as(i64, av) * @as(i64, bv);
    }
    return sum;
}

// ============================================================
// Train: nudge co-occurring tokens toward each other
// ============================================================

pub fn trainFromRelations(
    cache: *GemmCache,
    load_result: *const compact_loader.LoadResult,
) i32 {
    var pairs_trained: i32 = 0;
    const d: usize = @intCast(cache.d_model);

    // We need to resolve entity IDs from relationships to cache indices.
    // Relationships reference entity IDs like "EC4", "PM5" etc.
    // These map to KBData entries by row order within tables.
    // Build a mapping: entity_id text -> cache index

    // First pass: build entity_id -> cache index mapping
    // Entity IDs are stored in the tables of the load result.
    // KBData entries were created in table order, row order.
    // So cache index = running count across tables.

    // We need arena for temp storage but we don't have one here.
    // Use a simple O(n) scan approach instead.

    for (0..@as(usize, @intCast(TRAIN_EPOCHS))) |_| {
        for (0..load_result.relationship_count) |ri| {
            const rel = &load_result.relationships[ri];
            if (rel.canonical_type == .unknown) continue;

            const from_text = rel.fromSlice();
            const to_text = rel.toSlice();

            // Find from and to in cache by matching against KBData text
            const from_idx = findEntryByEntityId(cache, load_result, from_text);
            const to_idx = findEntryByEntityId(cache, load_result, to_text);

            if (from_idx == null or to_idx == null) continue;

            // Get embeddings
            const from_emb = getEmbedding(cache, from_idx.?);
            const to_emb = getEmbedding(cache, to_idx.?);

            // Nudge toward each other
            // from_emb[d] += LEARNING_RATE * sign(to_emb[d] - from_emb[d])
            // to_emb[d] += LEARNING_RATE * sign(from_emb[d] - to_emb[d])
            for (0..d) |dim| {
                const diff_fwd = to_emb[dim] - from_emb[dim];
                const diff_bwd = from_emb[dim] - to_emb[dim];

                if (diff_fwd > 0) {
                    from_emb[dim] += LEARNING_RATE;
                } else if (diff_fwd < 0) {
                    from_emb[dim] -= LEARNING_RATE;
                }

                if (diff_bwd > 0) {
                    to_emb[dim] += LEARNING_RATE;
                } else if (diff_bwd < 0) {
                    to_emb[dim] -= LEARNING_RATE;
                }
            }

            pairs_trained += 1;
        }
    }

    return pairs_trained;
}

// ============================================================
// Find cache index by entity ID string
// Walks load_result tables to find which row matches,
// then converts to cache index (running count across tables)
// ============================================================

fn findEntryByEntityId(
    cache: *const GemmCache,
    load_result: *const compact_loader.LoadResult,
    entity_id: []const u8,
) ?usize {
    _ = cache;
    var running_index: usize = 0;

    for (0..load_result.table_count) |ti| {
        const table = &load_result.tables[ti];
        for (0..table.row_count) |ri| {
            // Entity ID is stored in the load result
            // We need the arena base to resolve it, but we stored
            // offsets relative to arena base.
            // However, entity IDs are also the first column before the pipe.
            // We stored them separately in eid_offsets/eid_lens.
            // But we need the arena base pointer to read them.
            // This is a limitation — we need to pass arena base.
            // For now, use a workaround: the KBData text_column_0
            // often contains the entity name, not the ID.
            // Skip this approach and use a different strategy.
            _ = ri;
            running_index += 1;
        }
    }

    // Fallback: scan not possible without arena base.
    // We need to restructure. See findEntryByEntityIdWithArena.
    _ = entity_id;
    return null;
}

// ============================================================
// Find cache index by entity ID string (with arena base)
// ============================================================

fn findEntryByEntityIdWithArena(
    load_result: *const compact_loader.LoadResult,
    arena_base: [*]u8,
    entity_id: []const u8,
) ?usize {
    var running_index: usize = 0;

    for (0..load_result.table_count) |ti| {
        const table = &load_result.tables[ti];
        for (0..table.row_count) |ri| {
            const eid = table.entityId(ri, arena_base);
            if (std.mem.eql(u8, eid, entity_id)) {
                return running_index;
            }
            running_index += 1;
        }
    }

    return null;
}

// ============================================================
// Train with arena base access
// ============================================================

pub fn trainFromRelationsWithArena(
    cache: *GemmCache,
    load_result: *const compact_loader.LoadResult,
    arena_base: [*]u8,
) i32 {
    var pairs_trained: i32 = 0;
    const d: usize = @intCast(cache.d_model);
    const entry_count: usize = @intCast(cache.entry_count);

    if (entry_count < 2) return 0;

    // Simple PRNG for negative sampling
    var rng_state: u64 = 12345;

    for (0..@as(usize, @intCast(TRAIN_EPOCHS))) |_| {
        for (0..load_result.relationship_count) |ri| {
            const rel = &load_result.relationships[ri];
            if (rel.canonical_type == .unknown) continue;

            const from_text = rel.fromSlice();
            const to_text = rel.toSlice();

            const from_idx = findEntryByEntityIdWithArena(load_result, arena_base, from_text) orelse continue;
            const to_idx = findEntryByEntityIdWithArena(load_result, arena_base, to_text) orelse continue;

            if (from_idx >= entry_count or to_idx >= entry_count) continue;

            const from_emb = getEmbedding(cache, from_idx);
            const to_emb = getEmbedding(cache, to_idx);

            // Positive: pull from and to toward each other (proportional)
            for (0..d) |dim| {
                const diff: i32 = to_emb[dim] - from_emb[dim];
                const step: i32 = @intCast(@divTrunc(@as(i64, diff) * LEARNING_RATE, 1000));
                from_emb[dim] += step;
                to_emb[dim] -= step;
            }

            // Negative: push from AWAY from a random non-related entry
            rng_state = rng_state *% 6364136223846793005 +% 1442695040888963407;
            var neg_idx: usize = @intCast(@mod(rng_state >> 16, @as(u64, entry_count)));
            if (neg_idx == from_idx or neg_idx == to_idx) {
                neg_idx = (neg_idx + 1) % entry_count;
            }

            const neg_emb = getEmbedding(cache, neg_idx);

            for (0..d) |dim| {
                const diff: i32 = neg_emb[dim] - from_emb[dim];
                const step: i32 = @intCast(@divTrunc(@as(i64, diff) * LEARNING_RATE, 2000));
                // Push apart: subtract instead of add
                from_emb[dim] -= step;
                neg_emb[dim] += step;
            }

            pairs_trained += 1;
        }
    }

    cache.generation += 1;
    return pairs_trained;
}

// ============================================================
// Inference: given query VdrIds, find top-N scoring entries
// ============================================================

pub fn infer(
    cache: *const GemmCache,
    query_ids: []const VdrId,
    result_ids: []VdrId,
    result_scores: []i64,
    max_results: usize,
) i32 {
    const d: usize = @intCast(cache.d_model);
    const entry_count: usize = @intCast(cache.entry_count);

    if (entry_count == 0 or query_ids.len == 0) return 0;

    // Build query vector: average of query token embeddings
    var query_vec: [256]i64 = [_]i64{0} ** 256;
    var query_count: i32 = 0;

    for (query_ids) |qid| {
        const idx = findEntryIndex(cache, qid) orelse continue;
        const emb = getEmbedding(cache, idx);
        for (0..d) |dim| {
            query_vec[dim] += @as(i64, emb[dim]);
        }
        query_count += 1;
    }

    if (query_count == 0) return 0;

    // Average
    for (0..d) |dim| {
        query_vec[dim] = @divTrunc(query_vec[dim], @as(i64, query_count));
    }

    // Score every entry
    const n_results = @min(max_results, @min(entry_count, result_ids.len));

    // Initialize results with minimum scores
    for (0..n_results) |i| {
        result_ids[i] = VdrId.NONE;
        result_scores[i] = std.math.minInt(i64);
    }

    for (0..entry_count) |ei| {
        // Skip entries that are in the query (don't predict yourself)
        var is_query = false;
        for (query_ids) |qid| {
            if (cache.ids[ei].eql(qid)) {
                is_query = true;
                break;
            }
        }
        if (is_query) continue;

        // Dot product with query vector
        const emb = getEmbedding(cache, ei);
        var score: i64 = 0;
        for (0..d) |dim| {
            score += query_vec[dim] * @as(i64, emb[dim]);
        }

        // Insert into top-N if qualifies
        // Find minimum score in results
        var min_idx: usize = 0;
        var min_score: i64 = result_scores[0];
        for (1..n_results) |i| {
            if (result_scores[i] < min_score) {
                min_score = result_scores[i];
                min_idx = i;
            }
        }

        if (score > min_score) {
            result_scores[min_idx] = score;
            result_ids[min_idx] = cache.ids[ei];
        }
    }

    // Sort results by score descending
    for (0..n_results) |i| {
        var max_idx = i;
        for (i + 1..n_results) |j| {
            if (result_scores[j] > result_scores[max_idx]) {
                max_idx = j;
            }
        }
        if (max_idx != i) {
            const tmp_id = result_ids[i];
            const tmp_score = result_scores[i];
            result_ids[i] = result_ids[max_idx];
            result_scores[i] = result_scores[max_idx];
            result_ids[max_idx] = tmp_id;
            result_scores[max_idx] = tmp_score;
        }
    }

    return @intCast(n_results);
}

// ============================================================
// Test: build, train, infer on a real KB
// ============================================================

pub fn testGemm(
    global_arena: *Arena,
    config: *kb_config.KbConfig,
) void {
    std.debug.print("\n=== GEMM Test ===\n", .{});

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

    std.debug.print("  KB: {s}\n", .{entry.dottedSlice()});
    std.debug.print("  data entries: {}\n", .{if (kb.data) |d| d.items.len else 0});
    std.debug.print("  relations: {}\n", .{load_result.relationship_count});

    // Build cache
    const cache = buildGemmCache(global_arena, kb) orelse {
        std.debug.print("  FAIL: buildGemmCache returned null\n", .{});
        return;
    };

    std.debug.print("  cache built: {} entries, d_model={}\n", .{ cache.entry_count, cache.d_model });
    std.debug.print("  v_packed bytes: {}\n", .{cache.v_packed.len * 4});
    std.debug.print("  ids bytes: {}\n", .{cache.ids.len * 8});

    // Train
    const pairs = trainFromRelationsWithArena(cache, load_result, global_arena.base);
    std.debug.print("  trained: {} relation pairs over {} epochs\n", .{
        @divTrunc(pairs, TRAIN_EPOCHS),
        TRAIN_EPOCHS,
    });
    std.debug.print("  cache generation: {}\n", .{cache.generation});

    // Find EC4 (electric motor) by entity ID
    const ec4_idx = findEntryByEntityIdWithArena(load_result, global_arena.base, "EC4") orelse {
        std.debug.print("  SKIP: EC4 not found in load result\n", .{});
        return;
    };

    if (ec4_idx >= cache.ids.len) {
        std.debug.print("  SKIP: EC4 index {} out of range\n", .{ec4_idx});
        return;
    }

    const ec4_id = cache.ids[ec4_idx];
    std.debug.print("\n  Query: EC4 (electric motor)\n", .{});
    std.debug.print("  VdrId: {}\n", .{ec4_id.v});

    // Infer
    var result_ids: [10]VdrId = [_]VdrId{VdrId.NONE} ** 10;
    var result_scores: [10]i64 = [_]i64{0} ** 10;
    const query = [_]VdrId{ec4_id};

    const n = infer(cache, &query, &result_ids, &result_scores, 10);

    std.debug.print("  Top {} results:\n", .{n});

    // Print results with entity ID lookup
    for (0..@as(usize, @intCast(n))) |i| {
        // Find which entity ID this VdrId corresponds to
        const eid = findEntityIdByIndex(cache, load_result, global_arena.base, result_ids[i]);
        if (eid) |name| {
            std.debug.print("    [{d}] {s} (score: {})\n", .{ i, name, result_scores[i] });
        } else {
            std.debug.print("    [{d}] VdrId:{} (score: {})\n", .{ i, result_ids[i].v, result_scores[i] });
        }
    }

    // Check if expected results (PM5-PM9) appear in top 10
    const expected = [_][]const u8{ "PM5", "PM6", "PM7", "PM8", "PM9" };
    var hits: i32 = 0;

    for (expected) |exp| {
        const exp_idx = findEntryByEntityIdWithArena(load_result, global_arena.base, exp) orelse continue;
        if (exp_idx >= cache.ids.len) continue;
        const exp_id = cache.ids[exp_idx];

        for (0..@as(usize, @intCast(n))) |ri| {
            if (result_ids[ri].eql(exp_id)) {
                hits += 1;
                break;
            }
        }
    }

    std.debug.print("\n  Expected PM5-PM9 in top 10: {}/5 found\n", .{hits});

    if (hits >= 3) {
        std.debug.print("  PASS: GEMM training captured EC4 -> PM5-PM9 pattern\n", .{});
    } else {
        std.debug.print("  WEAK: only {}/5 expected results found — training may need tuning\n", .{hits});
    }

    // Also test HS5 -> VL18, SN13, CT6
    std.debug.print("\n  Query: HS5 (electrohydraulic servo system)\n", .{});
    const hs5_idx = findEntryByEntityIdWithArena(load_result, global_arena.base, "HS5") orelse {
        std.debug.print("  SKIP: HS5 not found\n", .{});
        return;
    };

    if (hs5_idx >= cache.ids.len) {
        std.debug.print("  SKIP: HS5 index out of range\n", .{});
        return;
    }

    const hs5_id = cache.ids[hs5_idx];
    var result_ids2: [10]VdrId = [_]VdrId{VdrId.NONE} ** 10;
    var result_scores2: [10]i64 = [_]i64{0} ** 10;
    const query2 = [_]VdrId{hs5_id};

    const n2 = infer(cache, &query2, &result_ids2, &result_scores2, 10);

    std.debug.print("  Top {} results:\n", .{n2});
    for (0..@as(usize, @intCast(n2))) |i| {
        const eid = findEntityIdByIndex(cache, load_result, global_arena.base, result_ids2[i]);
        if (eid) |name| {
            std.debug.print("    [{d}] {s} (score: {})\n", .{ i, name, result_scores2[i] });
        } else {
            std.debug.print("    [{d}] VdrId:{} (score: {})\n", .{ i, result_ids2[i].v, result_scores2[i] });
        }
    }

    const expected2 = [_][]const u8{ "VL18", "SN13", "CT6" };
    var hits2: i32 = 0;
    for (expected2) |exp| {
        const exp_idx = findEntryByEntityIdWithArena(load_result, global_arena.base, exp) orelse continue;
        if (exp_idx >= cache.ids.len) continue;
        const exp_id = cache.ids[exp_idx];
        for (0..@as(usize, @intCast(n2))) |ri| {
            if (result_ids2[ri].eql(exp_id)) {
                hits2 += 1;
                break;
            }
        }
    }

    std.debug.print("  Expected VL18,SN13,CT6 in top 10: {}/3 found\n", .{hits2});

    std.debug.print("\n  arena used after GEMM: {} bytes\n", .{global_arena.usedBytes()});
    std.debug.print("  arena free after GEMM: {} bytes\n", .{global_arena.freeBytes()});
    std.debug.print("=== GEMM Test Complete ===\n", .{});
}

// ============================================================
// Reverse lookup: VdrId -> entity ID string
// ============================================================

fn findEntityIdByIndex(
    cache: *const GemmCache,
    load_result: *const compact_loader.LoadResult,
    arena_base: [*]u8,
    target_id: VdrId,
) ?[]const u8 {
    // Find the cache index for this VdrId
    const cache_idx = findEntryIndex(cache, target_id) orelse return null;

    // Walk tables to find which entity ID is at this running index
    var running_index: usize = 0;
    for (0..load_result.table_count) |ti| {
        const table = &load_result.tables[ti];
        for (0..table.row_count) |ri| {
            if (running_index == cache_idx) {
                return table.entityId(ri, arena_base);
            }
            running_index += 1;
        }
    }

    return null;
}
