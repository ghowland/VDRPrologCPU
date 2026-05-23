const std = @import("std");
const net = std.net;
const resetable_memory = @import("resetable_memory.zig");
const handler = @import("vdr_http_handler.zig");
const Text = @import("text.zig").Text;

const READ_BUFFER_SIZE: usize = 8192;
const MAX_HEADER_BYTES: usize = 64 * 1024;

var shutdown: bool = false;

pub fn requestShutdown() void {
    shutdown = true;
}

pub fn run(port: u16) void {
    const address = net.Address.parseIp4("127.0.0.1", port) catch |err| {
        std.debug.print("http: parseIp4 failed: {}\n", .{err});
        return;
    };

    var server = address.listen(.{ .reuse_address = true }) catch |err| {
        std.debug.print("http: listen failed: {}\n", .{err});
        return;
    };
    defer server.deinit();

    std.debug.print("http: listening on 127.0.0.1:{}\n", .{port});

    while (!shutdown) {
        const conn = server.accept() catch |err| {
            if (shutdown) break;
            std.debug.print("http: accept error: {}\n", .{err});
            continue;
        };

        handleConnection(conn);

        conn.stream.close();
        resetable_memory.reset();
    }

    std.debug.print("http: shutdown clean\n", .{});
}

fn handleConnection(conn: net.Server.Connection) void {
    var raw = Text.initEmpty();
    var read_buf: [READ_BUFFER_SIZE]u8 = undefined;

    var headers_end: ?usize = null;
    while (headers_end == null) {
        const n = conn.stream.read(&read_buf) catch |err| {
            std.debug.print("http: read error: {}\n", .{err});
            return;
        };
        if (n == 0) return;

        raw.appendRaw(read_buf[0..n]);

        if (std.mem.indexOf(u8, raw.toText(), "\r\n\r\n")) |pos| {
            headers_end = pos;
        }

        if (raw.len > MAX_HEADER_BYTES) {
            writeResponse(conn, 400, "Bad Request", "text/plain", "Headers too large");
            return;
        }
    }

    const raw_slice = raw.toText();
    const hdr_end = headers_end.?;
    const after_headers = hdr_end + 4;

    const first_line_end = std.mem.indexOf(u8, raw_slice[0..hdr_end], "\r\n") orelse {
        writeResponse(conn, 400, "Bad Request", "text/plain", "Malformed request line");
        return;
    };
    const request_line = raw_slice[0..first_line_end];

    const space1 = std.mem.indexOfScalar(u8, request_line, ' ') orelse {
        writeResponse(conn, 400, "Bad Request", "text/plain", "Malformed request line");
        return;
    };
    const after_space1 = request_line[space1 + 1 ..];
    const space2 = std.mem.indexOfScalar(u8, after_space1, ' ') orelse {
        writeResponse(conn, 400, "Bad Request", "text/plain", "Malformed request line");
        return;
    };

    const method = request_line[0..space1];
    const path = after_space1[0..space2];

    std.debug.print("http: {s} {s}\n", .{ method, path });

    if (!std.mem.eql(u8, method, "POST")) {
        writeResponse(conn, 405, "Method Not Allowed", "text/plain", "Only POST supported");
        return;
    }

    const content_length = parseContentLength(raw_slice[0..hdr_end]) orelse {
        writeResponse(conn, 411, "Length Required", "text/plain", "Content-Length required");
        return;
    };

    var body = Text.initEmpty();

    if (after_headers < raw.len) {
        body.appendRaw(raw_slice[after_headers..]);
    }

    while (body.len < content_length) {
        const remaining = content_length - body.len;
        const to_read = @min(remaining, READ_BUFFER_SIZE);
        const n = conn.stream.read(read_buf[0..to_read]) catch |err| {
            std.debug.print("http: body read error: {}\n", .{err});
            return;
        };
        if (n == 0) {
            writeResponse(conn, 400, "Bad Request", "text/plain", "Body shorter than Content-Length");
            return;
        }
        body.appendRaw(read_buf[0..n]);
    }

    const result = handler.handle(method, path, &body);

    writeResponse(conn, result.status_code, result.status_text, result.content_type, result.body.toText());
}

fn parseContentLength(header_block: []const u8) ?usize {
    var i: usize = 0;
    while (i < header_block.len) {
        const rest = header_block[i..];
        const line_end = std.mem.indexOf(u8, rest, "\r\n") orelse rest.len;
        const line = rest[0..line_end];

        if (i > 0) {
            if (std.mem.indexOfScalar(u8, line, ':')) |colon| {
                const name = line[0..colon];
                if (std.ascii.eqlIgnoreCase(name, "Content-Length")) {
                    const value = std.mem.trim(u8, line[colon + 1 ..], " \t");
                    return std.fmt.parseInt(usize, value, 10) catch null;
                }
            }
        }

        i += line_end + 2;
        if (line_end == 0) break;
    }
    return null;
}

fn writeResponse(conn: net.Server.Connection, status_code: u16, status_text: []const u8, content_type: []const u8, body: []const u8) void {
    const scratch = resetable_memory.getAllocator() orelse return;

    const header = std.fmt.allocPrint(
        scratch,
        "HTTP/1.1 {} {s}\r\nContent-Type: {s}\r\nContent-Length: {}\r\nConnection: close\r\n\r\n",
        .{ status_code, status_text, content_type, body.len },
    ) catch return;

    writeAll(conn, header);
    writeAll(conn, body);
}

fn writeAll(conn: net.Server.Connection, bytes: []const u8) void {
    var sent: usize = 0;
    while (sent < bytes.len) {
        const n = conn.stream.write(bytes[sent..]) catch return;
        if (n == 0) return;
        sent += n;
    }
}
