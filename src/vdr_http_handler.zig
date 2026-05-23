const std = @import("std");
const Text = @import("text.zig").Text;

pub const HandlerResult = struct {
    status_code: u16 = 200,
    status_text: []const u8 = "OK",
    content_type: []const u8 = "application/json",
    body: Text = Text.initEmpty(),
};

/// Echo handler: wraps input body in {"echo":"..."} JSON response.
pub fn handle(method: []const u8, path: []const u8, body: *const Text) HandlerResult {
    _ = method;

    if (!std.mem.eql(u8, path, "/run")) {
        var result = HandlerResult{
            .status_code = 404,
            .status_text = "Not Found",
            .content_type = "text/plain",
        };
        result.body = Text.init("unknown route");
        return result;
    }

    var output = Text.initEmpty();
    output.appendRaw("{\"echo\":\"");

    // Escape the body into the output
    const input = body.toText();
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

    return HandlerResult{
        .body = output,
    };
}
