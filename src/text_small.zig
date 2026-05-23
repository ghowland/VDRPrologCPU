const std = @import("std");

const resetable_memory = @import("resetable_memory.zig");

pub const TEXT_LEN_MAX = 64 * 1; // 1KB text
pub const TEXT_LEN_OVERSIZE = TEXT_LEN_MAX + 1;
pub const TEXT_LEN_UNDERSIZE = TEXT_LEN_MAX - 1;

pub const TextSmall = struct {
    text: [TEXT_LEN_MAX]u8 = [_]u8{0} ** TEXT_LEN_MAX,
    len: usize = 0,

    pub fn init(input: []const u8) TextSmall {
        var s = TextSmall{};
        s.appendRaw(input);
        return s;
    }

    pub fn initEmpty() TextSmall {
        return TextSmall.init("");
    }

    pub fn initFormat(allocator: std.mem.Allocator, comptime fmt: []const u8, args: anytype) !TextSmall {
        _ = allocator;

        const written = try std.fmt.allocPrint(resetable_memory.frameMem.allocator, fmt, args);

        return TextSmall.init(written);
    }

    pub fn formatFrame(comptime fmt: []const u8, args: anytype) !TextSmall {
        const written = try std.fmt.allocPrint(resetable_memory.frameMem.allocator, fmt, args);

        return TextSmall.init(written);
    }

    pub fn initFormatAlloc(allocator: std.mem.Allocator, comptime fmt: []const u8, args: anytype) !TextSmall {
        _ = allocator;
        const written = try std.fmt.allocPrint(resetable_memory.frameMem.allocator, fmt, args);

        return TextSmall.init(written);
    }

    pub fn initMaybe(text: ?TextSmall) TextSmall {
        if (text == null) {
            return TextSmall.init("");
        }

        return text.?;
    }

    pub fn initMaybeRaw(text: ?[]const u8) ?TextSmall {
        if (text == null) {
            return null;
        }

        return TextSmall.init(text.?);
    }

    // Write clean JSON without padded zeros
    pub fn jsonStringify(self: TextSmall, writer: anytype) !void {
        try writer.write(self.text[0..self.len]);
    }

    pub fn jsonParse(allocator: std.mem.Allocator, source: anytype, options: std.json.ParseOptions) !TextSmall {
        _ = allocator;
        _ = options;

        const token = try source.next();
        switch (token) {
            .string => |s| return TextSmall.init(s),
            .allocated_string => |s| return TextSmall.init(s),
            .null => return TextSmall.initEmpty(),

            // Handle partial strings by accumulating all fragments
            .partial_string, .partial_string_escaped_1, .partial_string_escaped_2, .partial_string_escaped_3, .partial_string_escaped_4 => {
                var result = TextSmall.initEmpty();
                var current_token = token;

                // Process all string fragments until we get the final piece
                while (true) {
                    const bytes: []const u8 = switch (current_token) {
                        .partial_string => |s| s,
                        .partial_string_escaped_1 => |b| &b,
                        .partial_string_escaped_2 => |b| &b,
                        .partial_string_escaped_3 => |b| &b,
                        .partial_string_escaped_4 => |b| &b,
                        .string => |s| {
                            // Final piece - append and return
                            const new_len = result.len + s.len;
                            if (new_len > result.text.len) {
                                std.debug.print("TextSmall overflow: total length {} exceeds buffer {}\n", .{ new_len, result.text.len });
                                return error.UnexpectedToken;
                            }
                            @memcpy(result.text[result.len..new_len], s);
                            result.len = new_len;
                            return result;
                        },
                        .allocated_string => |s| {
                            // Final piece (allocated) - append and return
                            const new_len = result.len + s.len;
                            if (new_len > result.text.len) {
                                std.debug.print("TextSmall overflow: total length {} exceeds buffer {}\n", .{ new_len, result.text.len });
                                return error.UnexpectedToken;
                            }
                            @memcpy(result.text[result.len..new_len], s);
                            result.len = new_len;
                            return result;
                        },
                        else => {
                            std.debug.print("Unexpected token in string sequence: {any}\n", .{current_token});
                            return error.UnexpectedToken;
                        },
                    };

                    // Append current fragment
                    const new_len = result.len + bytes.len;
                    if (new_len > result.text.len) {
                        std.debug.print("TextSmall overflow: total length {} exceeds buffer {}\n", .{ new_len, result.text.len });
                        return error.UnexpectedToken;
                    }
                    @memcpy(result.text[result.len..new_len], bytes);
                    result.len = new_len;

                    // Get next token
                    current_token = try source.next();
                }
            },

            else => {
                std.debug.print("TextSmall.jsonParse unexpected token: {any}\n", .{token});
                return error.UnexpectedToken;
            },
        }
    }

    pub fn format(
        self: TextSmall,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.print("{s}", .{self.toText()});
    }

    // Same as toSlice
    pub fn toText(self: *const TextSmall) []const u8 {
        return self.text[0..self.len];
    }

    // toText, but allocated new memory which must be freed by someone else
    pub fn toTextAlloc(self: *const TextSmall, allocatorRemote: std.mem.Allocator) []const u8 {
        const bytes = allocatorRemote.alloc(u8, self.len) catch |err| {
            std.debug.print("TextSmall Allocation Error: {any}\n", .{err});
            std.debug.print("   From: {s}\n", .{self.toText()});
            return "";
        };
        std.mem.copyForwards(u8, bytes, self.text[0..self.len]);

        return bytes;
    }

    // Same as toText
    pub fn toSlice(self: *const TextSmall) []const u8 {
        return self.text[0..self.len];
    }

    pub fn isEmpty(self: TextSmall) bool {
        return self.len == 0;
    }

    pub fn appendTextSmall(self: *TextSmall, input: TextSmall) void {
        const space = self.text.len - self.len;
        const to_copy = @min(input.len, space);

        // std.debug.print("Append TextSmall Start: {s}  Len: {d}   TextSmall: {s}  TLen: {d}  Space: {d}  ToCopy: {d}\n", .{ self.toText(), self.len, input.toText(), input.len, space, to_copy });

        // Copy only what fits
        @memcpy(self.text[self.len .. self.len + to_copy], input.text[0..to_copy]);
        self.len += to_copy;

        // Zero out remaining unused buffer
        @memset(self.text[self.len..], 0);
        // std.debug.print("Append TextSmall End: {s}  Len: {d}\n", .{ self.toText(), self.len });
    }

    // pub fn appendRaw(self: *TextSmall, input: []const u8) void {
    //     const space = self.text.len - self.len;
    //     const to_copy = @min(input.len, space);

    //     // std.debug.print("Append Raw Start: {s}  Len: {d}   TextSmall: {s}  TLen: {d}  Space: {d}  ToCopy: {d}\n", .{ self.toText(), self.len, input, input.len, space, to_copy });

    //     // Copy only what fits
    //     @memcpy(self.text[self.len .. self.len + to_copy], input[0..to_copy]);
    //     self.len += to_copy;

    //     // Zero out remaining unused buffer
    //     @memset(self.text[self.len..], 0);
    //     // std.debug.print("Append Raw End: {s}  Len: {d}\n", .{ self.toText(), self.len });
    // }

    pub fn appendRaw(self: *TextSmall, input: []const u8) void {
        // Simple byte-by-byte copy (correct for UTF-8)
        const available_space = self.text.len - self.len - 1; // -1 for null terminator
        const copy_len = @min(input.len, available_space);

        @memcpy(self.text[self.len .. self.len + copy_len], input[0..copy_len]);
        self.len += copy_len;
    }

    pub fn appendRawAlloc(self: *TextSmall, allocator: std.mem.Allocator, input: []const u8) void {
        _ = allocator;

        // Create a temporary copy to avoid aliasing
        const temp_copy = resetable_memory.frameMem.allocator.alloc(u8, input.len) catch {
            // If allocation fails, just return without appending
            return;
        };
        // defer allocator.free(temp_copy);

        // Copy input to temporary buffer
        @memcpy(temp_copy, input);

        // Now safely append from the temporary buffer
        const available_space = self.text.len - self.len - 1; // -1 for null terminator
        const copy_len = @min(temp_copy.len, available_space);

        @memcpy(self.text[self.len .. self.len + copy_len], temp_copy[0..copy_len]);
        self.len += copy_len;
    }

    pub fn concat(self: *TextSmall, other: []const u8) void {
        self.append(other);
    }

    pub fn trim(self: *TextSmall) void {
        self.trimStart();
        self.trimEnd();
    }

    pub fn trimStart(self: *TextSmall) void {
        const trimmed = std.mem.trimLeft(u8, self.toSlice(), " \t\n\r");
        const new_len = trimmed.len;
        std.mem.copyForwards(u8, &self.text, trimmed);
        self.len = new_len;
    }

    pub fn trimEnd(self: *TextSmall) void {
        const trimmed = std.mem.trimRight(u8, self.toSlice(), " \t\n\r");
        self.len = trimmed.len;
    }

    pub fn equals(a: TextSmall, b: TextSmall) bool {
        return std.mem.eql(u8, a.toSlice(), b.toSlice());
    }

    pub fn equalsRaw(a: TextSmall, b: []const u8) bool {
        return std.mem.eql(u8, a.toSlice(), b);
    }

    pub fn toInt(self: TextSmall) ?i32 {
        return std.fmt.parseInt(i32, self.toSlice(), 10) catch null;
    }

    pub fn toUsize(self: TextSmall) ?usize {
        return std.fmt.parseInt(usize, self.toSlice(), 10) catch null;
    }

    pub fn toU32(self: TextSmall) ?u32 {
        return std.fmt.parseInt(u32, self.toSlice(), 10) catch null;
    }

    pub fn toU16(self: TextSmall) ?u16 {
        return std.fmt.parseInt(u16, self.toSlice(), 10) catch null;
    }

    pub fn toU8(self: TextSmall) ?u8 {
        return std.fmt.parseInt(u8, self.toSlice(), 10) catch null;
    }

    pub fn toIndex(self: TextSmall) ?usize {
        return std.fmt.parseInt(usize, self.toSlice(), 10) catch null;
    }

    pub fn toFloat(self: TextSmall) ?f32 {
        return std.fmt.parseFloat(f32, self.toSlice()) catch null;
    }

    pub fn toBool(self: TextSmall) bool {
        if (self.equalsRaw("true")) return true;
        return false;
    }

    pub fn fromInt(allocator: std.mem.Allocator, value: i32) !TextSmall {
        _ = allocator;
        return try TextSmall.initFormat(resetable_memory.frameMem.allocator, "{}", .{value});
    }

    pub fn fromFloat(allocator: std.mem.Allocator, value: f32) !TextSmall {
        _ = allocator;
        return try TextSmall.initFormat(resetable_memory.frameMem.allocator, "{}", .{value});
    }

    pub fn fromBool(allocator: std.mem.Allocator, value: bool) !TextSmall {
        _ = allocator;
        return try TextSmall.initFormat(resetable_memory.frameMem.allocator, "{any}", .{value});
    }

    pub fn toZeroString(self: *TextSmall) [*c]u8 {
        self.text[self.len] = 0;
        return @ptrCast(&self.text);
    }

    pub fn startsWith(self: TextSmall, prefix: []const u8) bool {
        return std.mem.startsWith(u8, self.toSlice(), prefix);
    }

    pub fn endsWith(self: TextSmall, suffix: []const u8) bool {
        return std.mem.endsWith(u8, self.toSlice(), suffix);
    }

    pub fn contains(self: TextSmall, sub: []const u8) bool {
        return std.mem.indexOf(u8, self.toSlice(), sub) != null;
    }

    pub fn containsTextSmall(self: TextSmall, sub: TextSmall) bool {
        return self.contains(sub.toText());
    }

    pub fn indexOf(self: TextSmall, sub: []const u8) ?usize {
        return std.mem.indexOf(u8, self.toSlice(), sub);
    }

    pub fn clear(self: *TextSmall) void {
        self.len = 0;
    }

    pub fn toUppercase(self: *TextSmall) void {
        for (self.text[0..self.len]) |*c| {
            c.* = std.ascii.toUpper(c.*);
        }
    }

    pub fn toLowercase(self: *TextSmall) void {
        for (self.text[0..self.len]) |*c| {
            c.* = std.ascii.toLower(c.*);
        }
    }

    pub fn secureWipe(self: *TextSmall) void {
        @memset(&self.text, 0);
        self.len = 0;
    }

    pub fn shorten(self: TextSmall, maxLen: i32) TextSmall {
        if (self.len < maxLen) return self;

        const text = TextSmall.init(self.text[0..@intCast(maxLen)]);
        return text;
    }

    pub fn replace(self: *TextSmall, needle: []const u8, replacement: []const u8) void {
        var result: [TEXT_LEN_MAX]u8 = [_]u8{0} ** TEXT_LEN_MAX;
        var result_len: usize = 0;

        var i: usize = 0;
        while (i < self.len) {
            if (i + needle.len <= self.len and std.mem.eql(u8, self.text[i .. i + needle.len], needle)) {
                if (result_len + replacement.len > result.len) break;

                @memcpy(result[result_len .. result_len + replacement.len], replacement);
                result_len += replacement.len;
                i += needle.len;
            } else {
                if (result_len + 1 > result.len) break;

                result[result_len] = self.text[i];
                result_len += 1;
                i += 1;
            }
        }

        // Copy the new result back to self
        @memcpy(self.text[0..result_len], result[0..result_len]);
        self.len = result_len;

        // Zero the rest of the buffer
        @memset(self.text[self.len..], 0);
    }

    pub fn split(self: TextSmall, delimiter: u8) ![]TextSmall {
        var list = std.array_list.Managed(TextSmall).init(resetable_memory.frameMem.allocator); // Dont free this memory here, we hand off with toOwnedSlice

        var slice1 = self.toSlice();
        var start: usize = 0;

        for (slice1, 0..) |c, i| {
            if (c == delimiter) {
                try list.append(TextSmall.init(slice1[start..i]));
                start = i + 1;
            }
        }

        if (start <= slice1.len) {
            try list.append(TextSmall.init(slice1[start..]));
        }

        // Return the owned items, which are useable for this and next frame
        return list.items;
        // return list.toOwnedSlice();
    }

    pub fn slice(self: TextSmall, start: usize, end: usize) []const u8 {
        var endF = end;
        var startF = start;

        if (end > self.len) endF = self.len;
        if (start > end) startF = end;

        return self.text[startF..endF];
    }

    pub fn sliceTextSmall(self: TextSmall, start: usize, end: usize) TextSmall {
        var endF = end;
        var startF = start;

        if (end > self.len) endF = self.len;
        if (start > end) startF = end;

        const out = TextSmall.init(self.text[startF..endF]);
        return out;
    }

    pub fn joinRaw(parts: [][]const u8, delimiter: []const u8) TextSmall {
        var result = TextSmall.initEmpty();
        for (parts, 0..) |part, i| {
            const clean_part = if (part.len > 0 and part[part.len - 1] == 0)
                part[0 .. part.len - 1]
            else
                part;
            result.appendRaw(clean_part);
            if (i < parts.len - 1) {
                result.appendRaw(delimiter);
            }
        }
        return result;
    }

    pub fn join(parts: []TextSmall, delimiter: []const u8) !TextSmall {
        var items = std.array_list.Managed([]const u8).init(resetable_memory.frameMem.allocator);
        defer items.deinit();

        for (0..parts.len) |index| {
            try items.append(parts[index].toSlice());
        }

        const owned_slice = try items.toOwnedSlice();

        return joinRaw(owned_slice, delimiter);
    }

    pub fn toCStringOld(self: TextSmall) [*c]u8 {
        var text = self;

        // Only NUL-terminate if there’s space:
        if (text.len < text.text.len) {
            text.text[self.len] = 0;
        }
        return @ptrCast(text.text[0..].ptr);
    }

    pub fn deleteAt(self: *TextSmall, byte_index: usize, count: usize) void {
        if (byte_index >= self.len) return; // Nothing to delete

        const actual_count = @min(count, self.len - byte_index);
        if (actual_count == 0) return;

        // Move remaining text forward
        const src_start = byte_index + actual_count;
        const remaining_len = self.len - src_start;

        if (remaining_len > 0) {
            std.mem.copyForwards(u8, self.text[byte_index .. byte_index + remaining_len], self.text[src_start .. src_start + remaining_len]);
        }

        // Update length
        self.len -= actual_count;

        // Zero out the end of the buffer
        @memset(self.text[self.len..], 0);
    }

    pub fn insertAt(self: *TextSmall, byte_index: usize, input: TextSmall) void {
        const insert_pos = @min(byte_index, self.len);
        const available_space = self.text.len - self.len;
        const insert_len = @min(input.len, available_space);

        if (insert_len == 0) return; // No space or nothing to insert

        // Move existing text backward to make room
        const move_len = self.len - insert_pos;
        if (move_len > 0) {
            // Move from end to beginning to avoid overlap
            var i: usize = move_len;
            while (i > 0) {
                i -= 1;
                self.text[insert_pos + insert_len + i] = self.text[insert_pos + i];
            }
        }

        // Insert the new text
        @memcpy(self.text[insert_pos .. insert_pos + insert_len], input.text[0..insert_len]);

        // Update length
        self.len += insert_len;
    }

    pub fn insertAtRaw(self: *TextSmall, byte_index: usize, input: []const u8) void {
        const input_text = TextSmall.init(input);
        self.insertAt(byte_index, input_text);
    }

    pub fn lastIndexOf(self: TextSmall, sub: []const u8) ?usize {
        if (sub.len == 0 or sub.len > self.len) return null;

        // Start from the last possible position where substring could fit
        var i: usize = self.len - sub.len + 1;
        while (i > 0) {
            i -= 1;

            // Check if substring matches at this position
            var matches = true;
            for (sub, 0..) |c, j| {
                if (self.text[i + j] != c) {
                    matches = false;
                    break;
                }
            }

            if (matches) {
                return i;
            }
        }

        return null;
    }

    pub fn extractZigTypeName(input: TextSmall) TextSmall {
        // Find where the alphabetic characters start
        var alpha_start: usize = 0;
        for (input.text[0..input.len], 0..) |c, i| {
            if ((c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z')) {
                alpha_start = i;
                break;
            }
        }

        // If no alphabetic characters, return as-is
        if (alpha_start == input.len) {
            return input;
        }

        // Build result starting with non-alpha prefix
        var result = TextSmall.init(input.slice(0, alpha_start));

        // Find the last dot in the alphabetic portion
        const alpha_portion = TextSmall.init(input.slice(alpha_start, input.len));
        const last_dot = alpha_portion.lastIndexOf(".");

        if (last_dot) |dot_pos| {
            // Take everything after the last dot
            const type_name = alpha_portion.slice(dot_pos + 1, alpha_portion.len);
            result.appendRaw(type_name);
        } else {
            // No dots, use the whole alphabetic portion
            result.appendRaw(alpha_portion.toText());
        }

        return result;
    }

    pub fn checksum(self: TextSmall, force_negative: bool) i32 {
        var hasher = std.crypto.hash.Sha1.init(.{});
        hasher.update(self.text[0..self.len]);
        var hash: [20]u8 = undefined;
        hasher.final(&hash);

        // Use first 4 bytes as i32
        var result: i32 = @bitCast(std.mem.readInt(u32, hash[0..4], .little));

        if (force_negative) {
            result |= @as(i32, 1) << 31; // Set high bit to force negative
        }

        return result;
    }

    pub fn removeLastSplitItem(self: TextSmall, delimiter: []const u8) !TextSmall {
        const parts = try self.split(delimiter[0]);
        if (parts.len > 1) {
            return try join(parts[0 .. parts.len - 1], delimiter);
        } else {
            return TextSmall.initEmpty();
        }
    }

    pub fn getGetLastNSplitItem(self: TextSmall, delimiter: u8, indexFromLast: usize) !?TextSmall {
        const parts = try self.split(delimiter);

        // If index is trying to reach too deep, it cant
        if (indexFromLast >= parts.len) return null;

        // We have enough parts to get it
        if (parts.len > indexFromLast) {
            // Return the index requested, we always subtract 1 to get the last item, and index is 0 starting
            return parts[parts.len - (indexFromLast + 1)];
        } else {
            return null;
        }
    }

    pub fn trimChars(self: TextSmall, chars: []const u8) TextSmall {
        if (self.text.len == 0) return self;

        var start: usize = 0;
        var end: usize = self.text.len;

        // Trim from start
        while (start < end) {
            var found = false;
            for (chars) |char| {
                if (self.text[start] == char) {
                    found = true;
                    break;
                }
            }
            if (!found) break;
            start += 1;
        }

        // Trim from end
        while (end > start) {
            var found = false;
            for (chars) |char| {
                if (self.text[end - 1] == char) {
                    found = true;
                    break;
                }
            }
            if (!found) break;
            end -= 1;
        }

        return TextSmall.init(self.text[start..end]);
    }
};
