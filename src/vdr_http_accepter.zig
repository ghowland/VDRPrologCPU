const std = @import("std");
const net = std.net;
const vdr_http = @import("vdr_http.zig");
const runner_pool = @import("vdr_runner_pool.zig");

const RING_SIZE: usize = 64;
const MAX_HANDLERS: usize = 16;

var ring: [RING_SIZE]?net.Server.Connection = [_]?net.Server.Connection{null} ** RING_SIZE;
var head: std.atomic.Value(usize) = std.atomic.Value(usize).init(0);
var tail: std.atomic.Value(usize) = std.atomic.Value(usize).init(0);
var handler_shutdown: bool = false;

var handler_threads: [MAX_HANDLERS]?std.Thread = [_]?std.Thread{null} ** MAX_HANDLERS;
var handler_count: usize = 0;

pub fn init(n_handlers: usize, n_runners: usize) void {
    handler_shutdown = false;
    head.store(0, .release);
    tail.store(0, .release);

    runner_pool.init(n_runners);

    const count = @min(n_handlers, MAX_HANDLERS);
    handler_count = count;

    for (0..count) |i| {
        handler_threads[i] = std.Thread.spawn(.{}, handlerLoop, .{i}) catch {
            std.debug.print("accepter: failed to spawn handler thread {}\n", .{i});
            continue;
        };
    }

    std.debug.print("accepter: spawned {} handler threads\n", .{count});
}

pub fn dispatch(conn: net.Server.Connection) bool {
    const current_head = head.load(.acquire);
    const next_head = (current_head + 1) % RING_SIZE;
    const current_tail = tail.load(.acquire);

    if (next_head == current_tail) {
        std.debug.print("accepter: ring full, dropping connection\n", .{});
        return false;
    }

    ring[current_head] = conn;
    head.store(next_head, .release);
    return true;
}

pub fn stop() void {
    handler_shutdown = true;

    for (0..handler_count) |i| {
        if (handler_threads[i]) |thread| {
            thread.join();
            handler_threads[i] = null;
        }
    }

    runner_pool.stop();

    std.debug.print("accepter: all handler threads joined\n", .{});
}

fn handlerLoop(id: usize) void {
    std.debug.print("handler[{}]: started\n", .{id});

    while (!handler_shutdown) {
        const current_tail = tail.load(.acquire);
        const current_head = head.load(.acquire);

        if (current_tail == current_head) {
            std.Thread.yield() catch {};
            continue;
        }

        const next_tail = (current_tail + 1) % RING_SIZE;
        const result = tail.cmpxchgWeak(current_tail, next_tail, .acq_rel, .acquire);

        if (result != null) {
            continue;
        }

        const conn = ring[current_tail] orelse continue;
        ring[current_tail] = null;

        vdr_http.handle_connection(conn) catch |err| {
            std.debug.print("handler[{}]: error: {any}\n", .{ id, err });
        };

        conn.stream.close();
    }

    std.debug.print("handler[{}]: stopped\n", .{id});
}
