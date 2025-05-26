const std = @import("std");

const protobuf = @import("protobuf");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // first create a build for the dependency
    const protobuf_dep = b.dependency("protobuf", .{
        .target = target,
        .optimize = optimize,
    });

    _ = b.addModule("mmc-config", .{
        .root_source_file = b.path("src/mmc-config.zig"),
        .imports = &.{
            .{ .name = "protobuf", .module = protobuf_dep.module("protobuf") },
        },
        .target = target,
        .optimize = optimize,
    });

    // mmc_config.addImport("mcl", mcl.module("mcl"));
    // mmc_config.addImport("protobuf", protobuf_dep.module("protobuf"));

    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/mmc-config.zig"),
        .target = target,
        .optimize = optimize,
    });
    unit_tests.root_module.addImport("protobuf", protobuf_dep.module("protobuf"));

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

    // Check step is same as test, as there is no output artifact.
    const check = b.step("check", "Check if foo compiles");
    check.dependOn(&run_unit_tests.step);

    const gen_proto = b.step("gen-proto", "generates zig files from protocol buffer definitions");

    const protoc_step = protobuf.RunProtocStep.create(
        b,
        protobuf_dep.builder,
        target,
        .{
            // out directory for the generated zig files
            .destination_directory = b.path("src/proto"),
            .source_files = &.{
                "protocol/all.proto",
            },
            .include_directories = &.{},
        },
    );

    gen_proto.dependOn(&protoc_step.step);
}
