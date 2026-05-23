// ============================================================
// vdr_kb_config.zig
// Loads and saves kb.json — maps dotted paths to compact files.
// ============================================================

const std = @import("std");
const types = @import("vdr_types.zig");

const Arena = types.Arena;

const MAX_ENTRIES: usize = 256;
const MAX_PATH: usize = 256;
const CONFIG_PATH = "kb.json";

pub const KbConfigEntry = struct {
    dotted_path: [MAX_PATH]u8 = [_]u8{0} ** MAX_PATH,
    dotted_path_len: usize = 0,
    file_path: [MAX_PATH]u8 = [_]u8{0} ** MAX_PATH,
    file_path_len: usize = 0,

    pub fn dottedSlice(self: *const KbConfigEntry) []const u8 {
        return self.dotted_path[0..self.dotted_path_len];
    }

    pub fn fileSlice(self: *const KbConfigEntry) []const u8 {
        return self.file_path[0..self.file_path_len];
    }
};

pub const KbConfig = struct {
    entries: []KbConfigEntry = &.{},
    count: usize = 0,
    next_unmapped: usize = 0, // counter for root.0, root.1, etc.

    // Find entry by file path. Returns index or null.
    pub fn findByFile(self: *const KbConfig, file_path: []const u8) ?usize {
        for (0..self.count) |i| {
            if (std.mem.eql(u8, self.entries[i].fileSlice(), file_path)) return i;
        }
        return null;
    }

    // Get dotted path for a file. Returns slice or null.
    pub fn dottedPathFor(self: *const KbConfig, file_path: []const u8) ?[]const u8 {
        const idx = self.findByFile(file_path) orelse return null;
        return self.entries[idx].dottedSlice();
    }

    // Add a new entry. Returns false if full.
    pub fn addEntry(self: *KbConfig, dotted: []const u8, file: []const u8) bool {
        if (self.count >= MAX_ENTRIES) return false;

        var e = &self.entries[self.count];
        e.* = KbConfigEntry{};

        const dl = @min(dotted.len, MAX_PATH);
        @memcpy(e.dotted_path[0..dl], dotted[0..dl]);
        e.dotted_path_len = dl;

        const fl = @min(file.len, MAX_PATH);
        @memcpy(e.file_path[0..fl], file[0..fl]);
        e.file_path_len = fl;

        self.count += 1;
        return true;
    }

    // Add an unmapped file with path root.0, root.1, etc.
    pub fn addUnmapped(self: *KbConfig, file_path: []const u8) bool {
        var dotted_buf: [MAX_PATH]u8 = undefined;
        const prefix = "root.";
        @memcpy(dotted_buf[0..prefix.len], prefix);

        // Format the number manually
        var num = self.next_unmapped;
        var num_buf: [10]u8 = undefined;
        var num_len: usize = 0;

        if (num == 0) {
            num_buf[0] = '0';
            num_len = 1;
        } else {
            var tmp: usize = 0;
            while (num > 0) {
                num_buf[tmp] = @intCast((num % 10) + '0');
                num /= 10;
                tmp += 1;
            }
            num_len = tmp;
            // reverse
            var lo: usize = 0;
            var hi: usize = num_len - 1;
            while (lo < hi) {
                const t = num_buf[lo];
                num_buf[lo] = num_buf[hi];
                num_buf[hi] = t;
                lo += 1;
                hi -= 1;
            }
        }

        if (prefix.len + num_len > MAX_PATH) return false;
        @memcpy(dotted_buf[prefix.len .. prefix.len + num_len], num_buf[0..num_len]);

        self.next_unmapped += 1;
        return self.addEntry(dotted_buf[0 .. prefix.len + num_len], file_path);
    }
};

// Load kb.json from disk. Allocates KbConfig and entries in arena.
pub fn loadKbConfig(arena: *Arena) ?*KbConfig {
    const config = arena.allocTyped(KbConfig) orelse return null;
    config.* = KbConfig{};

    config.entries = arena.allocSlice(KbConfigEntry, MAX_ENTRIES) orelse return null;
    for (0..MAX_ENTRIES) |i| {
        config.entries[i] = KbConfigEntry{};
    }

    // Try to read kb.json
    const file = std.fs.cwd().openFile(CONFIG_PATH, .{}) catch {
        // No file — return empty config
        std.debug.print("kb_config: no kb.json found, starting fresh\n", .{});
        return config;
    };
    defer file.close();

    const stat = file.stat() catch return config;
    if (stat.size == 0 or stat.size > 64 * 1024) return config;

    var buf: [64 * 1024]u8 = undefined;
    const n = file.readAll(&buf) catch return config;
    if (n == 0) return config;

    const json_slice = buf[0..n];

    // Parse JSON manually — it's a flat { "key": "value" } object
    // Walk through looking for "key" : "value" pairs
    var pos: usize = 0;

    // Skip to opening brace
    while (pos < json_slice.len and json_slice[pos] != '{') : (pos += 1) {}
    if (pos >= json_slice.len) return config;
    pos += 1;

    while (pos < json_slice.len) {
        // Skip whitespace and commas
        while (pos < json_slice.len and (json_slice[pos] == ' ' or json_slice[pos] == '\n' or
            json_slice[pos] == '\r' or json_slice[pos] == '\t' or json_slice[pos] == ','))
        {
            pos += 1;
        }
        if (pos >= json_slice.len or json_slice[pos] == '}') break;

        // Parse key string
        const key = parseJsonString(json_slice, &pos) orelse break;

        // Skip colon
        while (pos < json_slice.len and json_slice[pos] != ':') : (pos += 1) {}
        if (pos >= json_slice.len) break;
        pos += 1;

        // Skip whitespace
        while (pos < json_slice.len and (json_slice[pos] == ' ' or json_slice[pos] == '\t')) : (pos += 1) {}

        // Parse value string
        const val = parseJsonString(json_slice, &pos) orelse break;

        _ = config.addEntry(key, val);
    }

    std.debug.print("kb_config: loaded {} entries from kb.json\n", .{config.count});
    return config;
}

fn parseJsonString(json: []const u8, pos: *usize) ?[]const u8 {
    // Skip to opening quote
    while (pos.* < json.len and json[pos.*] != '"') : (pos.* += 1) {}
    if (pos.* >= json.len) return null;
    pos.* += 1; // skip opening quote

    const start = pos.*;
    while (pos.* < json.len and json[pos.*] != '"') : (pos.* += 1) {}
    if (pos.* >= json.len) return null;

    const result = json[start..pos.*];
    pos.* += 1; // skip closing quote
    return result;
}

// Save kb.json to disk.
pub fn saveKbConfig(config: *const KbConfig) void {
    const file = std.fs.cwd().createFile(CONFIG_PATH, .{}) catch |err| {
        std.debug.print("kb_config: cannot create kb.json: {}\n", .{err});
        return;
    };
    defer file.close();

    file.writeAll("{\n") catch return;

    for (0..config.count) |i| {
        file.writeAll("  \"") catch return;
        file.writeAll(config.entries[i].dottedSlice()) catch return;
        file.writeAll("\": \"") catch return;
        file.writeAll(config.entries[i].fileSlice()) catch return;

        if (i + 1 < config.count) {
            file.writeAll("\",\n") catch return;
        } else {
            file.writeAll("\"\n") catch return;
        }
    }

    file.writeAll("}\n") catch return;
    std.debug.print("kb_config: saved {} entries to kb.json\n", .{config.count});
}
