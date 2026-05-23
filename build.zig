const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Module: vdr_types
    const vdr_types_mod = b.createModule(.{
        .root_source_file = b.path("src/vdr_types.zig"),
    });

    // Module: vdr_config (depends on vdr_types)
    const vdr_config_mod = b.createModule(.{
        .root_source_file = b.path("src/vdr_config.zig"),
        .imports = &.{
            .{ .name = "vdr_types", .module = vdr_types_mod },
        },
    });

    // Executable: root
    const exe = b.addExecutable(.{
        .name = "vdr",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "vdr_types", .module = vdr_types_mod },
                .{ .name = "vdr_config", .module = vdr_config_mod },
            },
        }),
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run VDR-Prolog kernel");
    run_step.dependOn(&run_cmd.step);
}
