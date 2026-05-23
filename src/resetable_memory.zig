const std = @import("std");
const types = @import("vdr_types.zig");

const Arena = types.Arena;

var backing: ?[]u8 = null;
var arena: Arena = .{};
var lock: bool = false;

// Create the resetable memory with the given size from page_allocator.
// Call once during init.
pub fn create(size_bytes: usize) bool {
    const alloc = std.heap.page_allocator;
    const mem = alloc.alloc(u8, size_bytes) catch return false;
    backing = mem;
    arena = .{
        .base = mem.ptr,
        .size = size_bytes,
        .cursor = 0,
    };
    lock = false;
    return true;
}

// Destroy the resetable memory, freeing backing pages.
pub fn destroy() void {
    if (backing) |mem| {
        const alloc = std.heap.page_allocator;
        alloc.free(mem);
        backing = null;
        arena = .{};
        lock = false;
    }
}

// Reset the arena cursor to 0. Sets lock during reset.
// All prior allocations from this arena are invalidated.
pub fn reset() void {
    lock = true;
    arena.cursor = 0;
    lock = false;
}

// Check if the arena is currently resetting.
// Threads should spin or skip if this returns true.
pub fn isLocked() bool {
    return lock;
}

// Get the arena for allocation. Returns null if locked or not created.
pub fn getArena() ?*Arena {
    if (lock) return null;
    if (backing == null) return null;
    return &arena;
}

// Convenience: get an allocator-compatible interface for std.fmt.allocPrint etc.
// Returns null if locked or not created.
pub fn getAllocator() ?std.mem.Allocator {
    const a = getArena() orelse return null;
    return std.mem.Allocator{
        .ptr = @ptrCast(a),
        .vtable = &vtable,
    };
}

const vtable = std.mem.Allocator.VTable{
    .alloc = vtableAlloc,
    .resize = vtableResize,
    .free = vtableFree,
};

fn vtableAlloc(ctx: *anyopaque, len: usize, alignment: std.mem.Alignment, _: usize) ?[*]u8 {
    const a: *Arena = @ptrCast(@alignCast(ctx));
    return a.alloc(len, @intFromEnum(alignment));
}

fn vtableResize(_: *anyopaque, _: []u8, _: std.mem.Alignment, _: usize, _: usize) bool {
    // Bump allocator cannot resize
    return false;
}

fn vtableFree(_: *anyopaque, _: []u8, _: std.mem.Alignment, _: usize) void {
    // Bump allocator does not free individual allocations
}
