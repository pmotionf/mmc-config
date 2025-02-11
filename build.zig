const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mcl = b.dependency("mcl", .{
        .target = target,
        .optimize = optimize,
    });

    _ = b.addModule("mmc", .{
        .root_source_file = b.path("src/mmc.zig"),
        .imports = &.{
            .{ .name = "mcl", .module = mcl.module("mcl") },
        },
    });

    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/mmc.zig"),
        .target = target,
        .optimize = optimize,
    });
    unit_tests.root_module.addImport("mcl", mcl.module("mcl"));

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

    // Check step is same as test, as there is no output artifact.
    const check = b.step("check", "Check if foo compiles");
    check.dependOn(&run_unit_tests.step);
}
