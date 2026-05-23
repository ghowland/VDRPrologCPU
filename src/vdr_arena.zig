const std = @import("std");
const types = @import("vdr_types.zig");

const Arena = types.Arena;

// Create an arena backed by page_allocator memory.
// Returns null if allocation fails.
// size_bytes is the usable capacity of the arena.
pub fn create(size_bytes: usize) ?*Arena {
    const allocator = std.heap.page_allocator;

    // Allocate the Arena struct itself
    const arena_ptr = allocator.create(Arena) catch return null;

    // Allocate the backing memory
    const backing = allocator.alloc(u8, size_bytes) catch {
        allocator.destroy(arena_ptr);
        return null;
    };

    arena_ptr.* = .{
        .base = backing.ptr,
        .size = size_bytes,
        .cursor = 0,
    };

    return arena_ptr;
}

// Destroy an arena, freeing its backing memory and the struct itself.
pub fn destroy(arena: *Arena) void {
    const allocator = std.heap.page_allocator;
    const backing = arena.base[0..arena.size];
    allocator.free(backing);
    allocator.destroy(arena);
}
