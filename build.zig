const std = @import("std");
const protobuf = @import("protobuf");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const protobuf_dep = b.dependency("protobuf", .{
        .target = target,
        .optimize = optimize,
    });

    const build_zig_zon = b.createModule(.{
        .root_source_file = b.path("build.zig.zon"),
        .target = target,
        .optimize = optimize,
    });

    const mod = b.addModule("mmc-api", .{
        .root_source_file = b.path("src/api.zig"),
        .imports = &.{
            .{ .name = "protobuf", .module = protobuf_dep.module("protobuf") },
            .{ .name = "build.zig.zon", .module = build_zig_zon },
        },
        .target = target,
        .optimize = optimize,
    });

    const unit_tests = b.addTest(.{ .root_module = mod });
    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

    // Check step is same as test, as there is no output artifact.
    const check = b.step("check", "Check if foo compiles");
    check.dependOn(&run_unit_tests.step);

    const gen_proto = b.step(
        "gen-proto",
        "generates zig files from protocol buffer definitions",
    );

    const protoc_step = protobuf.RunProtocStep.create(
        protobuf_dep.builder,
        target,
        .{
            .destination_directory = b.path("src/protobuf"),
            .source_files = &.{b.path("protobuf/mmc.proto")},
            .include_directories = &.{b.path("protobuf")},
        },
    );

    gen_proto.dependOn(&protoc_step.step);

    // ***** Building for legacy MCL interface *****
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

    const mdfunc = b.dependency("mdfunc", .{
        .target = target,
        .optimize = optimize,
        .mdfunc = mdfunc_lib_path,
        .mock = mdfunc_mock_build,
    });

    const mcl = b.addModule("mcl", .{
        .root_source_file = b.path("src/mcl/mcl.zig"),
        .imports = &.{
            .{ .name = "build.zig.zon", .module = build_zig_zon },
            .{ .name = "mdfunc", .module = mdfunc.module("mdfunc") },
        },
        .target = target,
        .optimize = optimize,
    });

    const mcl_test = b.addTest(.{ .root_module = mcl });
    const run_mcl_tests = b.addRunArtifact(mcl_test);
    test_step.dependOn(&run_mcl_tests.step);
}
