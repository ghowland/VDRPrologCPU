const std = @import("std");
const TextBig = @import("text_big.zig").TextBig;

const RING_SIZE: usize = 64;
const MAX_RUNNERS: usize = 16;

pub const WorkRequest = struct {
    request_id: i32 = 0,
    body: TextBig = TextBig.initEmpty(),
};

pub const WorkResponse = struct {
    request_id: i32 = 0,
    body: TextBig = TextBig.initEmpty(),
};

const CoreState = struct {
    in_ring: [RING_SIZE]?WorkRequest = [_]?WorkRequest{null} ** RING_SIZE,
    in_head: std.atomic.Value(usize) = std.atomic.Value(usize).init(0),
    in_tail: std.atomic.Value(usize) = std.atomic.Value(usize).init(0),

    out_ring: [RING_SIZE]?WorkResponse = [_]?WorkResponse{null} ** RING_SIZE,
    out_head: std.atomic.Value(usize) = std.atomic.Value(usize).init(0),
    out_tail: std.atomic.Value(usize) = std.atomic.Value(usize).init(0),

    thread: ?std.Thread = null,
    core_id: usize = 0,
};

var cores: [MAX_RUNNERS]CoreState = undefined;
var core_count: usize = 0;
var runner_shutdown: bool = false;
var next_core: std.atomic.Value(usize) = std.atomic.Value(usize).init(0);
var next_request_id: std.atomic.Value(i32) = std.atomic.Value(i32).init(1);

pub fn init(n_cores: usize) void {
    runner_shutdown = false;
    const count = @min(n_cores, MAX_RUNNERS);
    core_count = count;

    for (0..count) |i| {
        cores[i] = CoreState{};
        cores[i].core_id = i;

        cores[i].thread = std.Thread.spawn(.{}, runnerLoop, .{i}) catch {
            std.debug.print("runner_pool: failed to spawn runner {}\n", .{i});
            continue;
        };
    }

    std.debug.print("runner_pool: spawned {} runners\n", .{count});
}

pub fn stop() void {
    runner_shutdown = true;

    for (0..core_count) |i| {
        if (cores[i].thread) |thread| {
            thread.join();
            cores[i].thread = null;
        }
    }

    std.debug.print("runner_pool: all runners stopped\n", .{});
}

pub fn nextCoreId() usize {
    const current = next_core.fetchAdd(1, .monotonic);
    return current % core_count;
}

pub fn nextRequestId() i32 {
    return next_request_id.fetchAdd(1, .monotonic);
}

pub fn submit(core_id: usize, request: WorkRequest) bool {
    if (core_id >= core_count) return false;

    var core = &cores[core_id];
    const current_head = core.in_head.load(.acquire);
    const next_head = (current_head + 1) % RING_SIZE;
    const current_tail = core.in_tail.load(.acquire);

    if (next_head == current_tail) {
        std.debug.print("runner_pool: core {} incoming ring full\n", .{core_id});
        return false;
    }

    core.in_ring[current_head] = request;
    core.in_head.store(next_head, .release);
    return true;
}

pub fn poll(core_id: usize, request_id: i32) ?WorkResponse {
    if (core_id >= core_count) return null;

    var core = &cores[core_id];
    const current_tail = core.out_tail.load(.acquire);
    const current_head = core.out_head.load(.acquire);

    if (current_tail == current_head) return null;

    const response = core.out_ring[current_tail] orelse return null;

    if (response.request_id != request_id) return null;

    core.out_ring[current_tail] = null;
    core.out_tail.store((current_tail + 1) % RING_SIZE, .release);

    return response;
}

fn runnerLoop(core_id: usize) void {
    std.debug.print("runner[{}]: started\n", .{core_id});

    var core = &cores[core_id];

    while (!runner_shutdown) {
        const current_tail = core.in_tail.load(.acquire);
        const current_head = core.in_head.load(.acquire);

        if (current_tail == current_head) {
            std.Thread.yield() catch {};
            continue;
        }

        const request = core.in_ring[current_tail] orelse {
            core.in_tail.store((current_tail + 1) % RING_SIZE, .release);
            continue;
        };
        core.in_ring[current_tail] = null;
        core.in_tail.store((current_tail + 1) % RING_SIZE, .release);

        // Do the work — echo with JSON escaping
        var output = TextBig.initEmpty();
        output.appendRaw("{\"echo\":\"");

        const input = request.body.toText();
        for (input) |c| {
            switch (c) {
                '"' => output.appendRaw("\\\""),
                '\\' => output.appendRaw("\\\\"),
                '\n' => output.appendRaw("\\n"),
                '\r' => output.appendRaw("\\r"),
                '\t' => output.appendRaw("\\t"),
                else => {
                    if (c >= 0x20) {
                        output.appendRaw(&[_]u8{c});
                    }
                },
            }
        }

        output.appendRaw("\"}");

        // Push response
        const out_head = core.out_head.load(.acquire);
        const next_out = (out_head + 1) % RING_SIZE;

        if (next_out == core.out_tail.load(.acquire)) {
            std.debug.print("runner[{}]: outgoing ring full, dropping response\n", .{core_id});
            continue;
        }

        core.out_ring[out_head] = WorkResponse{
            .request_id = request.request_id,
            .body = output,
        };
        core.out_head.store(next_out, .release);
    }

    std.debug.print("runner[{}]: stopped\n", .{core_id});
}
