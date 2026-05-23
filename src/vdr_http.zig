const std = @import("std");
const net = std.net;
const posix = std.posix;
const resetable_memory = @import("resetable_memory.zig");
const handler = @import("vdr_http_handler.zig");
const accepter = @import("vdr_http_accepter.zig");
const Text = @import("text.zig").Text;

const READ_BUFFER_SIZE: usize = 8192;
const MAX_HEADER_BYTES: usize = 1024 * 64;

pub var shutdown: bool = false;

pub fn requestShutdown() void {
    shutdown = true;
    accepter.stop();
}

pub fn run(port: u16) void {
    const address = net.Address.parseIp4("127.0.0.1", port) catch |err| {
        std.debug.print("http: parseIp4 failed: {any}\n", .{err});
        return;
    };

    var server = address.listen(.{ .reuse_address = true }) catch |err| {
        std.debug.print("http: listen failed: {any}\n", .{err});
        return;
    };
    defer server.deinit();

    std.debug.print("http: listening on 127.0.0.1:{}\n", .{port});

    // Start handler threads via accepter
    accepter.init(4);

    while (!shutdown) {
        // Poll before accept so we don't block on shutdown
        var pollfds = [_]posix.pollfd{
            .{
                .fd = server.stream.handle,
                .events = posix.POLL.IN,
                .revents = 0,
            },
        };

        // 100ms timeout — check shutdown flag periodically
        const ready = posix.poll(&pollfds, 100) catch |err| {
            if (shutdown) break;
            std.debug.print("http: poll error: {any}\n", .{err});
            std.Thread.sleep(10 * std.time.ns_per_ms);
            continue;
        };

        if (ready == 0) continue; // timeout, loop back and check shutdown
        if (shutdown) break;

        const conn = server.accept() catch |err| {
            if (shutdown) break;
            std.debug.print("http: accept error: {any}\n", .{err});
            continue;
        };

        if (!accepter.dispatch(conn)) {
            write_503(conn);
        }
    }

    accepter.stop();
    std.debug.print("http: shutdown clean\n", .{});
}

pub fn handle_connection(conn: net.Server.Connection) !void {
    const scratch = resetable_memory.getAllocator() orelse return;

    var raw = std.array_list.Managed(u8).init(scratch);

    var read_buf: [READ_BUFFER_SIZE]u8 = undefined;

    var headers_end: ?usize = null;
    while (headers_end == null) {
        const n = posix.recv(conn.stream.handle, &read_buf, 0) catch |err| {
            std.debug.print("http: recv error: {any}\n", .{err});
            return;
        };
        if (n == 0) {
            std.debug.print("http: client closed before headers\n", .{});
            return;
        }
        try raw.appendSlice(read_buf[0..n]);

        if (std.mem.indexOf(u8, raw.items, "\r\n\r\n")) |pos| {
            headers_end = pos;
        }

        if (raw.items.len > MAX_HEADER_BYTES) {
            try write_400(conn, scratch, "Headers too large");
            return;
        }
    }

    const header_block = raw.items[0..headers_end.?];
    const after_headers = headers_end.? + 4;
    const initial_body_bytes = raw.items[after_headers..];

    const first_line_end = std.mem.indexOf(u8, header_block, "\r\n") orelse {
        try write_400(conn, scratch, "Malformed HTTP request line");
        return;
    };
    const request_line = header_block[0..first_line_end];

    const space1 = std.mem.indexOfScalar(u8, request_line, ' ') orelse {
        try write_400(conn, scratch, "Malformed HTTP request line");
        return;
    };
    const after_space1 = request_line[space1 + 1 ..];
    const space2_rel = std.mem.indexOfScalar(u8, after_space1, ' ') orelse {
        try write_400(conn, scratch, "Malformed HTTP request line");
        return;
    };

    const method = request_line[0..space1];
    const path = after_space1[0..space2_rel];
    const version = after_space1[space2_rel + 1 ..];

    std.debug.print("http: {s} {s} {s}\n", .{ method, path, version });

    if (!std.mem.eql(u8, method, "POST") and !std.mem.eql(u8, method, "GET")) {
        try write_405(conn, scratch);
        return;
    }

    // Read body — POST requires Content-Length, GET body is optional
    var body = Text.initEmpty();
    body.appendRaw(initial_body_bytes);

    const content_length = parse_content_length(header_block);
    if (content_length == -1) {
        if (std.mem.eql(u8, method, "POST")) {
            try write_411(conn, scratch);
            return;
        }
        // GET without Content-Length: use whatever body bytes arrived with headers
        const result = handler.handle(method, path, &body);
        try write_response(conn, scratch, result.status_code, result.status_text, result.content_type, result.body.toText());
        return;
    }

    while (body.len < @as(usize, @intCast(content_length))) {
        const remaining = @as(usize, @intCast(content_length)) - body.len;
        const to_read = @min(remaining, READ_BUFFER_SIZE);
        const n = posix.recv(conn.stream.handle, read_buf[0..to_read], 0) catch |err| {
            std.debug.print("http: body recv error: {any}\n", .{err});
            try write_400(conn, scratch, "Body read failed");
            return;
        };
        if (n == 0) {
            try write_400(conn, scratch, "Body shorter than Content-Length");
            return;
        }
        body.appendRaw(read_buf[0..n]);
    }

    // Dispatch to handler
    const result = handler.handle(method, path, &body);

    // Write response
    try write_response(conn, scratch, result.status_code, result.status_text, result.content_type, result.body.toText());
}

fn parse_content_length(header_block: []const u8) i32 {
    var i: usize = 0;
    while (i < header_block.len) {
        const rest = header_block[i..];
        const line_end_rel = std.mem.indexOf(u8, rest, "\r\n") orelse rest.len;
        const line = rest[0..line_end_rel];

        if (i > 0) {
            if (std.mem.indexOfScalar(u8, line, ':')) |colon_pos| {
                const name = line[0..colon_pos];
                if (std.ascii.eqlIgnoreCase(name, "Content-Length")) {
                    var value = line[colon_pos + 1 ..];
                    value = std.mem.trim(u8, value, " \t");
                    return std.fmt.parseInt(i32, value, 10) catch return -1;
                }
            }
        }

        i += line_end_rel + 2;
        if (line_end_rel == 0) break;
        if (i >= header_block.len) break;
    }

    return -1;
}

fn write_all(handle: posix.socket_t, bytes: []const u8) !void {
    var sent: usize = 0;
    while (sent < bytes.len) {
        const n = try posix.send(handle, bytes[sent..], 0);
        if (n == 0) return error.ConnectionClosed;
        sent += n;
    }
}

fn write_response(conn: net.Server.Connection, alloc: std.mem.Allocator, status_code: u16, status_text: []const u8, content_type: []const u8, body: []const u8) !void {
    const response = try std.fmt.allocPrint(
        alloc,
        "HTTP/1.1 {d} {s}\r\nContent-Type: {s}\r\nContent-Length: {d}\r\nConnection: close\r\n\r\n{s}",
        .{ status_code, status_text, content_type, body.len, body },
    );
    write_all(conn.stream.handle, response) catch |err| {
        std.debug.print("http: send error: {any}\n", .{err});
    };
}

fn write_400(conn: net.Server.Connection, alloc: std.mem.Allocator, reason: []const u8) !void {
    try write_response(conn, alloc, 400, "Bad Request", "text/plain", reason);
}

fn write_405(conn: net.Server.Connection, alloc: std.mem.Allocator) !void {
    try write_response(conn, alloc, 405, "Method Not Allowed", "text/plain", "Only POST is supported");
}

fn write_411(conn: net.Server.Connection, alloc: std.mem.Allocator) !void {
    try write_response(conn, alloc, 411, "Length Required", "text/plain", "Content-Length header required");
}

fn write_503(conn: net.Server.Connection) void {
    const response = "HTTP/1.1 503 Service Unavailable\r\nContent-Length: 0\r\nConnection: close\r\n\r\n";
    write_all(conn.stream.handle, response) catch {};
}
