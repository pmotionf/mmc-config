const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mdfunc_lib_path = b.option(
        []const u8,
        "mdfunc",
        "Specify the path to the MELSEC static library artifact.",
    ) orelse if (target.result.cpu.arch == .x86_64)
        "vendor/mdfunc/lib/x64/MdFunc32.lib"
    else
        "vendor/mdfunc/lib/mdfunc32.lib";
    const mdfunc_mock_build = b.option(
        bool,
        "mdfunc_mock",
        "Enable building a mock version of the MELSEC data link library.",
    ) orelse (target.result.os.tag != .windows);

    const mcl = b.dependency("mcl", .{
        .target = target,
        .optimize = optimize,
        .mdfunc = mdfunc_lib_path,
        .mdfunc_mock = mdfunc_mock_build,
    });

    const mmc_config = b.addModule("mmc-config", .{
        .root_source_file = b.path("src/mmc-config.zig"),
    });

    mmc_config.addImport("mcl", mcl.module("mcl"));

    const mcl_mock = b.dependency("mcl", .{
        .target = target,
        .optimize = optimize,
        .mdfunc = mdfunc_lib_path,
        .mdfunc_mock = true,
    });

    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/mmc-config.zig"),
        .target = target,
        .optimize = optimize,
    });

    unit_tests.root_module.addImport("mcl", mcl_mock.module("mcl"));

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

    // Check step is same as test, as there is no output artifact.
    const check = b.step("check", "Check if foo compiles");
    check.dependOn(&run_unit_tests.step);
}
