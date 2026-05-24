// ============================================================
// vdr_prolog.zig
// Typed relation query engine over loaded KB data.
// L3 operations: direct scan, inverse, symmetric, transitive closure.
// No unification, no backtracking, no rule firing.
// Zero arena allocation — all results stack-allocated.
// ============================================================

const std = @import("std");
const types = @import("vdr_types.zig");
const kb_config = @import("vdr_kb_config.zig");
const compact_loader = @import("vdr_compact_loader.zig");

const RelationType = types.RelationType;

// ============================================================
// Query Result — stack allocated, fixed capacity
// ============================================================

const MAX_RESULTS: usize = 64;

pub const QueryResult = struct {
    from_ids: [MAX_RESULTS][64]u8 = undefined,
    from_lens: [MAX_RESULTS]usize = [_]usize{0} ** MAX_RESULTS,
    to_ids: [MAX_RESULTS][64]u8 = undefined,
    to_lens: [MAX_RESULTS]usize = [_]usize{0} ** MAX_RESULTS,
    rel_types: [MAX_RESULTS]RelationType = [_]RelationType{.unknown} ** MAX_RESULTS,
    count: usize = 0,

    pub fn addResult(self: *QueryResult, from: []const u8, to: []const u8, rel: RelationType) void {
        if (self.count >= MAX_RESULTS) return;
        const i = self.count;
        const fl = @min(from.len, 64);
        const tl = @min(to.len, 64);
        @memcpy(self.from_ids[i][0..fl], from[0..fl]);
        self.from_lens[i] = fl;
        @memcpy(self.to_ids[i][0..tl], to[0..tl]);
        self.to_lens[i] = tl;
        self.rel_types[i] = rel;
        self.count += 1;
    }

    pub fn fromSlice(self: *const QueryResult, i: usize) []const u8 {
        return self.from_ids[i][0..self.from_lens[i]];
    }

    pub fn toSlice(self: *const QueryResult, i: usize) []const u8 {
        return self.to_ids[i][0..self.to_lens[i]];
    }

    pub fn containsTo(self: *const QueryResult, entity_id: []const u8) bool {
        for (0..self.count) |i| {
            if (std.mem.eql(u8, self.toSlice(i), entity_id)) return true;
        }
        return false;
    }

    pub fn containsFrom(self: *const QueryResult, entity_id: []const u8) bool {
        for (0..self.count) |i| {
            if (std.mem.eql(u8, self.fromSlice(i), entity_id)) return true;
        }
        return false;
    }

    pub fn containsEither(self: *const QueryResult, entity_id: []const u8) bool {
        return self.containsTo(entity_id) or self.containsFrom(entity_id);
    }
};

// ============================================================
// Direct Relation Query
// "What does {from_id} {rel_type}?"
// ============================================================

pub fn queryRelation(
    load_result: *const compact_loader.LoadResult,
    arena_base: [*]u8,
    from_id: []const u8,
    rel_type: RelationType,
) QueryResult {
    _ = arena_base;
    var result = QueryResult{};

    for (0..load_result.relationship_count) |i| {
        const rel = &load_result.relationships[i];
        if (rel.canonical_type != rel_type) continue;
        if (!std.mem.eql(u8, rel.fromSlice(), from_id)) continue;
        result.addResult(rel.fromSlice(), rel.toSlice(), rel.canonical_type);
    }

    return result;
}

// ============================================================
// Reverse Relation Query
// "What {rel_type} {to_id}?"
// ============================================================

pub fn queryRelationReverse(
    load_result: *const compact_loader.LoadResult,
    arena_base: [*]u8,
    to_id: []const u8,
    rel_type: RelationType,
) QueryResult {
    _ = arena_base;
    var result = QueryResult{};

    for (0..load_result.relationship_count) |i| {
        const rel = &load_result.relationships[i];
        if (rel.canonical_type != rel_type) continue;
        if (!std.mem.eql(u8, rel.toSlice(), to_id)) continue;
        result.addResult(rel.fromSlice(), rel.toSlice(), rel.canonical_type);
    }

    return result;
}

// ============================================================
// Inverse Query
// "What depends_on X?" rewrites to "What does X enable?"
// Uses RelationType.inverse() to flip the query direction
// ============================================================

pub fn queryRelationInverse(
    load_result: *const compact_loader.LoadResult,
    arena_base: [*]u8,
    entity_id: []const u8,
    rel_type: RelationType,
) QueryResult {
    const inv = rel_type.inverse();
    if (inv == .unknown) {
        // No known inverse — fall back to reverse scan with original type
        return queryRelationReverse(load_result, arena_base, entity_id, rel_type);
    }
    // Inverse exists: "depends_on(X, Y)" inverts to "enables(Y, X)"
    // So query "what depends_on entity" becomes "what does entity enable"
    return queryRelation(load_result, arena_base, entity_id, inv);
}

// ============================================================
// Symmetric Query
// "Does A {rel_type} B?" checks both (A,B) and (B,A)
// ============================================================

pub fn querySymmetric(
    load_result: *const compact_loader.LoadResult,
    arena_base: [*]u8,
    entity_a: []const u8,
    entity_b: []const u8,
    rel_type: RelationType,
) bool {
    _ = arena_base;

    for (0..load_result.relationship_count) |i| {
        const rel = &load_result.relationships[i];
        if (rel.canonical_type != rel_type) continue;

        // Check A → B
        if (std.mem.eql(u8, rel.fromSlice(), entity_a) and
            std.mem.eql(u8, rel.toSlice(), entity_b))
        {
            return true;
        }

        // Check B → A if symmetric
        if (rel_type.isSymmetric()) {
            if (std.mem.eql(u8, rel.fromSlice(), entity_b) and
                std.mem.eql(u8, rel.toSlice(), entity_a))
            {
                return true;
            }
        }
    }

    return false;
}

// ============================================================
// Transitive Closure
// BFS: follow rel_type chains from start_id
// Returns all reachable entities
// ============================================================

const MAX_BFS: usize = 256;

pub fn queryTransitiveClosure(
    load_result: *const compact_loader.LoadResult,
    arena_base: [*]u8,
    start_id: []const u8,
    rel_type: RelationType,
) QueryResult {
    // _ = arena_base;
    var result = QueryResult{};

    if (!rel_type.isTransitive()) {
        // Non-transitive: just do a direct query
        return queryRelation(load_result, arena_base, start_id, rel_type);
    }

    // BFS queue — entity ID strings
    var queue: [MAX_BFS][64]u8 = undefined;
    var queue_lens: [MAX_BFS]usize = [_]usize{0} ** MAX_BFS;
    var queue_head: usize = 0;
    var queue_tail: usize = 0;

    // Visited set — entity ID strings
    var visited: [MAX_BFS][64]u8 = undefined;
    var visited_lens: [MAX_BFS]usize = [_]usize{0} ** MAX_BFS;
    var visited_count: usize = 0;

    // Seed the queue with start_id
    const sl = @min(start_id.len, 64);
    @memcpy(queue[queue_tail][0..sl], start_id[0..sl]);
    queue_lens[queue_tail] = sl;
    queue_tail += 1;

    // Mark start as visited
    @memcpy(visited[0][0..sl], start_id[0..sl]);
    visited_lens[0] = sl;
    visited_count = 1;

    while (queue_head < queue_tail) {
        const current = queue[queue_head][0..queue_lens[queue_head]];
        queue_head += 1;

        // Find all direct targets from current via rel_type
        for (0..load_result.relationship_count) |i| {
            const rel = &load_result.relationships[i];
            if (rel.canonical_type != rel_type) continue;
            if (!std.mem.eql(u8, rel.fromSlice(), current)) continue;

            const target = rel.toSlice();

            // Check if already visited
            var already_visited = false;
            for (0..visited_count) |vi| {
                if (std.mem.eql(u8, visited[vi][0..visited_lens[vi]], target)) {
                    already_visited = true;
                    break;
                }
            }
            if (already_visited) continue;

            // Add to result
            result.addResult(current, target, rel_type);

            // Mark visited
            if (visited_count < MAX_BFS) {
                const tl = @min(target.len, 64);
                @memcpy(visited[visited_count][0..tl], target[0..tl]);
                visited_lens[visited_count] = tl;
                visited_count += 1;
            }

            // Add to queue
            if (queue_tail < MAX_BFS) {
                const tl = @min(target.len, 64);
                @memcpy(queue[queue_tail][0..tl], target[0..tl]);
                queue_lens[queue_tail] = tl;
                queue_tail += 1;
            }
        }
    }

    return result;
}

// ============================================================
// All Relations For Entity
// Returns all relations where entity appears as from or to
// ============================================================

pub fn queryAllRelations(
    load_result: *const compact_loader.LoadResult,
    arena_base: [*]u8,
    entity_id: []const u8,
) QueryResult {
    _ = arena_base;
    var result = QueryResult{};

    for (0..load_result.relationship_count) |i| {
        const rel = &load_result.relationships[i];
        if (rel.canonical_type == .unknown) continue;

        if (std.mem.eql(u8, rel.fromSlice(), entity_id) or
            std.mem.eql(u8, rel.toSlice(), entity_id))
        {
            result.addResult(rel.fromSlice(), rel.toSlice(), rel.canonical_type);
        }
    }

    return result;
}

// ============================================================
// Print helpers
// ============================================================

fn printQueryResult(result: *const QueryResult, label: []const u8) void {
    std.debug.print("  {s}: {} results\n", .{ label, result.count });
    for (0..result.count) |i| {
        std.debug.print("    {s} --{s}--> {s}\n", .{
            result.fromSlice(i),
            @tagName(result.rel_types[i]),
            result.toSlice(i),
        });
    }
}

// ============================================================
// Test Entry Point
// ============================================================

pub fn testProlog(
    global_arena: *types.Arena,
    config: *kb_config.KbConfig,
) void {
    _ = global_arena;
    std.debug.print("\n=== Prolog Query Test ===\n", .{});

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
    const load_result = entry.load_result orelse {
        std.debug.print("  SKIP: no load result\n", .{});
        return;
    };

    std.debug.print("  KB: {s}\n", .{entry.dottedSlice()});
    std.debug.print("  relations: {}\n\n", .{load_result.relationship_count});

    var tests_passed: i32 = 0;
    var tests_total: i32 = 0;

    // ── Test 1: Direct query ──────────────────────────────────
    // "What does EC4 enable?"
    // EC4 (electric motor) enables PM5, PM6, PM7, PM8, PM9
    {
        std.debug.print("  Test 1: What does EC4 enable?\n", .{});
        const result = queryRelation(load_result, undefined, "EC4", .enables);
        printQueryResult(&result, "EC4 enables");

        const expected = [_][]const u8{ "PM5", "PM6", "PM7", "PM8", "PM9" };
        var hits: i32 = 0;
        for (expected) |exp| {
            if (result.containsTo(exp)) hits += 1;
        }
        tests_total += 1;
        if (hits == 5) {
            std.debug.print("    PASS: {}/5 expected targets found\n\n", .{hits});
            tests_passed += 1;
        } else {
            std.debug.print("    FAIL: {}/5 expected targets found\n\n", .{hits});
        }
    }

    // ── Test 2: Reverse query ─────────────────────────────────
    // "What requires PU6?"
    // HS2, HS3 require PU6
    {
        std.debug.print("  Test 2: What requires PU6?\n", .{});
        const result = queryRelationReverse(load_result, undefined, "PU6", .requires);
        printQueryResult(&result, "requires PU6");

        const expected = [_][]const u8{ "HS2", "HS3" };
        var hits: i32 = 0;
        for (expected) |exp| {
            if (result.containsFrom(exp)) hits += 1;
        }
        tests_total += 1;
        if (hits == 2) {
            std.debug.print("    PASS: {}/2 expected sources found\n\n", .{hits});
            tests_passed += 1;
        } else {
            std.debug.print("    FAIL: {}/2 expected sources found\n\n", .{hits});
        }
    }

    // ── Test 3: Inverse query ─────────────────────────────────
    // "What depends_on PM5?" inverts to "What does PM5 enable?"
    // depends_on.inverse() = enables
    {
        std.debug.print("  Test 3: What depends_on PM5? (inverse query)\n", .{});
        const result = queryRelationInverse(load_result, undefined, "PM5", .depends_on);
        printQueryResult(&result, "depends_on PM5 (via enables inverse)");

        // PM5 enables PU1 and CP2
        const expected = [_][]const u8{ "PU1", "CP2" };
        var hits: i32 = 0;
        for (expected) |exp| {
            if (result.containsTo(exp)) hits += 1;
        }
        tests_total += 1;
        if (hits == 2) {
            std.debug.print("    PASS: {}/2 expected results found\n\n", .{hits});
            tests_passed += 1;
        } else {
            std.debug.print("    FAIL: {}/2 expected results found\n\n", .{hits});
        }
    }

    // ── Test 4: Transitive closure ────────────────────────────
    // "What does EC4 transitively enable?"
    // EC4 → PM5 → PU1, CP2
    // EC4 → PM8 → (via AC6, GR9)
    // EC4 → PM9 → AC6
    // Should find at least PM5, PM6, PM7, PM8, PM9 + their targets
    {
        std.debug.print("  Test 4: What does EC4 transitively enable?\n", .{});
        const result = queryTransitiveClosure(load_result, undefined, "EC4", .enables);
        printQueryResult(&result, "EC4 enables (transitive)");

        // Must contain direct targets plus at least some chained targets
        var direct_hits: i32 = 0;
        const direct = [_][]const u8{ "PM5", "PM6", "PM7", "PM8", "PM9" };
        for (direct) |exp| {
            if (result.containsTo(exp)) direct_hits += 1;
        }

        var chain_hits: i32 = 0;
        const chained = [_][]const u8{ "PU1", "CP2" };
        for (chained) |exp| {
            if (result.containsTo(exp)) chain_hits += 1;
        }

        tests_total += 1;
        if (direct_hits >= 5 and chain_hits >= 1) {
            std.debug.print("    PASS: {}/5 direct + {}/2 chained targets found\n\n", .{ direct_hits, chain_hits });
            tests_passed += 1;
        } else {
            std.debug.print("    WEAK: {}/5 direct + {}/2 chained targets found\n\n", .{ direct_hits, chain_hits });
        }
    }

    // ── Test 5: Symmetric query ───────────────────────────────
    // contradicts is symmetric — if A contradicts B, then B contradicts A
    // prevents is symmetric per the RelationType definition
    {
        std.debug.print("  Test 5: Symmetric relation check\n", .{});

        // prevents is symmetric: FM7 prevents PU1
        // So PU1 prevents FM7 should also be true
        const fwd = querySymmetric(load_result, undefined, "FM7", "PU1", .prevents);
        const rev = querySymmetric(load_result, undefined, "PU1", "FM7", .prevents);

        std.debug.print("    FM7 prevents PU1: {}\n", .{fwd});
        std.debug.print("    PU1 prevents FM7 (symmetric): {}\n", .{rev});

        tests_total += 1;
        if (fwd and rev) {
            std.debug.print("    PASS: symmetric relation works both directions\n\n", .{});
            tests_passed += 1;
        } else {
            std.debug.print("    FAIL: fwd={} rev={}\n\n", .{ fwd, rev });
        }
    }

    // ── Test 6: All relations for entity ──────────────────────
    // Get everything related to HS5
    {
        std.debug.print("  Test 6: All relations for HS5\n", .{});
        const result = queryAllRelations(load_result, undefined, "HS5");
        printQueryResult(&result, "HS5 all relations");

        // HS5 requires VL18, SN13, CT6, CC14, PU6
        tests_total += 1;
        if (result.count >= 3) {
            std.debug.print("    PASS: {} relations found for HS5\n\n", .{result.count});
            tests_passed += 1;
        } else {
            std.debug.print("    FAIL: only {} relations found\n\n", .{result.count});
        }
    }

    // ── Test 7: Specialization chain ──────────────────────────
    // VL18 specializes VL17, VL17 specializes VL16
    // Transitive closure of specializes from VL18 should reach VL17 and VL16
    {
        std.debug.print("  Test 7: Specialization chain VL18 → VL17 → VL16\n", .{});
        const result = queryTransitiveClosure(load_result, undefined, "VL18", .specializes);
        printQueryResult(&result, "VL18 specializes (transitive)");

        const found_vl17 = result.containsTo("VL17");
        const found_vl16 = result.containsTo("VL16");

        tests_total += 1;
        if (found_vl17 and found_vl16) {
            std.debug.print("    PASS: VL17={} VL16={}\n\n", .{ found_vl17, found_vl16 });
            tests_passed += 1;
        } else {
            std.debug.print("    FAIL: VL17={} VL16={}\n\n", .{ found_vl17, found_vl16 });
        }
    }

    // ── Test 8: part_of query ─────────────────────────────────
    // GR1, GR2, GR7 are part_of DM2 (power transmission)
    {
        std.debug.print("  Test 8: What is part_of DM2?\n", .{});
        const result = queryRelationReverse(load_result, undefined, "DM2", .part_of);
        printQueryResult(&result, "part_of DM2");

        const expected = [_][]const u8{ "GR1", "GR2", "GR7" };
        var hits: i32 = 0;
        for (expected) |exp| {
            if (result.containsFrom(exp)) hits += 1;
        }
        tests_total += 1;
        if (hits == 3) {
            std.debug.print("    PASS: {}/3 expected parts found\n\n", .{hits});
            tests_passed += 1;
        } else {
            std.debug.print("    FAIL: {}/3 expected parts found\n\n", .{hits});
        }
    }

    // ── Summary ───────────────────────────────────────────────
    std.debug.print("  Results: {}/{} tests passed\n", .{ tests_passed, tests_total });
    if (tests_passed == tests_total) {
        std.debug.print("  ALL PASS\n", .{});
    }
    std.debug.print("=== Prolog Query Test Complete ===\n", .{});
}
