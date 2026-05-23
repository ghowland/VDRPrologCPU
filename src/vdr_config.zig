const std = @import("std");
const types = @import("vdr_types.zig");

pub const ConfigError = enum(i32) {
    ok = 0,
    file_not_found = 1,
    read_error = 2,
    parse_error = 3,
};

pub const ConfigResult = struct {
    config: types.SystemConfig = .{},
    error_code: ConfigError = .ok,
};

pub fn loadConfig(path: []const u8) ConfigResult {
    const file = std.fs.cwd().openFile(path, .{}) catch |err| {
        std.debug.print("config: cannot open '{s}': {}\n", .{ path, err });
        return .{ .error_code = .file_not_found };
    };
    defer file.close();

    const stat = file.stat() catch |err| {
        std.debug.print("config: cannot stat '{s}': {}\n", .{ path, err });
        return .{ .error_code = .read_error };
    };

    if (stat.size == 0 or stat.size > 1024 * 1024) {
        std.debug.print("config: file size {} out of range\n", .{stat.size});
        return .{ .error_code = .read_error };
    }

    const allocator = std.heap.page_allocator;
    const buf = allocator.alloc(u8, stat.size) catch {
        std.debug.print("config: alloc failed for {} bytes\n", .{stat.size});
        return .{ .error_code = .read_error };
    };
    defer allocator.free(buf);

    const bytes_read = file.readAll(buf) catch |err| {
        std.debug.print("config: read error: {}\n", .{err});
        return .{ .error_code = .read_error };
    };

    if (bytes_read == 0) {
        std.debug.print("config: empty read\n", .{});
        return .{ .error_code = .read_error };
    }

    const json_slice = buf[0..bytes_read];

    var config = types.SystemConfig{};

    var parsed = std.json.parseFromSlice(std.json.Value, allocator, json_slice, .{}) catch |err| {
        std.debug.print("config: JSON parse error: {}\n", .{err});
        return .{ .error_code = .parse_error };
    };
    defer parsed.deinit();

    const root = parsed.value;

    if (root != .object) {
        std.debug.print("config: root is not object\n", .{});
        return .{ .error_code = .parse_error };
    }

    const map = root.object;

    // Top-level i32 fields
    if (map.get("n_cores")) |v| {
        config.n_cores = jsonToI32(v) orelse return parseErr("n_cores");
    }
    if (map.get("http_port")) |v| {
        config.http_port = jsonToI32(v) orelse return parseErr("http_port");
    }
    if (map.get("max_total_kbs")) |v| {
        config.max_total_kbs = jsonToI32(v) orelse return parseErr("max_total_kbs");
    }
    if (map.get("max_total_rules")) |v| {
        config.max_total_rules = jsonToI32(v) orelse return parseErr("max_total_rules");
    }
    if (map.get("max_sessions_per_core")) |v| {
        config.max_sessions_per_core = jsonToI32(v) orelse return parseErr("max_sessions_per_core");
    }
    if (map.get("max_ephemeral_kbs_per_session")) |v| {
        config.max_ephemeral_kbs_per_session = jsonToI32(v) orelse return parseErr("max_ephemeral_kbs_per_session");
    }
    if (map.get("max_facts_per_session_kb")) |v| {
        config.max_facts_per_session_kb = jsonToI32(v) orelse return parseErr("max_facts_per_session_kb");
    }
    if (map.get("default_max_turns")) |v| {
        config.default_max_turns = jsonToI32(v) orelse return parseErr("default_max_turns");
    }
    if (map.get("auto_snapshot_interval")) |v| {
        config.auto_snapshot_interval = jsonToI32(v) orelse return parseErr("auto_snapshot_interval");
    }
    if (map.get("max_runners")) |v| {
        config.max_runners = jsonToI32(v) orelse return parseErr("max_runners");
    }
    if (map.get("audit_ring_capacity")) |v| {
        config.audit_ring_capacity = jsonToI32(v) orelse return parseErr("audit_ring_capacity");
    }
    if (map.get("relation_index_rebuild_interval")) |v| {
        config.relation_index_rebuild_interval = jsonToI32(v) orelse return parseErr("relation_index_rebuild_interval");
    }

    // Top-level i64 fields
    if (map.get("global_arena_bytes")) |v| {
        config.global_arena_bytes = jsonToI64(v) orelse return parseErr("global_arena_bytes");
    }
    if (map.get("per_core_arena_bytes")) |v| {
        config.per_core_arena_bytes = jsonToI64(v) orelse return parseErr("per_core_arena_bytes");
    }
    if (map.get("max_total_facts")) |v| {
        config.max_total_facts = jsonToI64(v) orelse return parseErr("max_total_facts");
    }
    if (map.get("max_total_terms")) |v| {
        config.max_total_terms = jsonToI64(v) orelse return parseErr("max_total_terms");
    }

    // Top-level i8 fields
    if (map.get("default_visibility")) |v| {
        const i = jsonToI32(v) orelse return parseErr("default_visibility");
        if (i < -128 or i > 127) return parseErr("default_visibility");
        config.default_visibility = @intCast(i);
    }

    // Validate n_cores
    if (config.n_cores <= 0 or config.n_cores > types.MAX_CORES) {
        std.debug.print("config: n_cores {} out of range 1-{}\n", .{ config.n_cores, types.MAX_CORES });
        return .{ .error_code = .parse_error };
    }

    return .{ .config = config };
}

fn jsonToI32(v: std.json.Value) ?i32 {
    return switch (v) {
        .integer => |i| std.math.cast(i32, i),
        else => null,
    };
}

fn jsonToI64(v: std.json.Value) ?i64 {
    return switch (v) {
        .integer => |i| i,
        else => null,
    };
}

fn parseErr(field: []const u8) ConfigResult {
    std.debug.print("config: bad value for '{s}'\n", .{field});
    return .{ .error_code = .parse_error };
}
