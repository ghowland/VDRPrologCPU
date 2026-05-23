const std = @import("std");
const TextBig = @import("text_big.zig").TextBig;

const vdr_http = @import("vdr_http.zig");
const runner_pool = @import("vdr_runner_pool.zig");

pub const HandlerResult = struct {
    status_code: u16 = 200,
    status_text: []const u8 = "OK",
    content_type: []const u8 = "application/json",
    body: TextBig = TextBig.initEmpty(),
};

pub fn handle(method: []const u8, path: []const u8, body: *const TextBig) HandlerResult {
    _ = method;

    if (std.mem.eql(u8, path, "/shutdown")) {
        vdr_http.shutdown = true;
        return HandlerResult{
            .body = TextBig.init("{\"status\":\"shutdown\"}"),
        };
    }

    if (!std.mem.eql(u8, path, "/run")) {
        var result = HandlerResult{
            .status_code = 404,
            .status_text = "Not Found",
            .content_type = "text/plain",
        };
        result.body = TextBig.init("unknown route");
        return result;
    }

    // /run — submit to runner
    const core_id = runner_pool.nextCoreId();
    const request_id = runner_pool.nextRequestId();

    const req = runner_pool.WorkRequest{
        .request_id = request_id,
        .body = body.*,
    };

    if (!runner_pool.submit(core_id, req)) {
        var result = HandlerResult{
            .status_code = 503,
            .status_text = "Service Unavailable",
            .content_type = "text/plain",
        };
        result.body = TextBig.init("runner queue full");
        return result;
    }

    // Spin-wait for response
    while (true) {
        if (runner_pool.poll(core_id, request_id)) |response| {
            return HandlerResult{
                .body = response.body,
            };
        }
        std.Thread.yield() catch {};
    }
}
