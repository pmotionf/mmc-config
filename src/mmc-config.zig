const std = @import("std");
const mcl = @import("mcl");
pub const SystemState = @import("SystemState.zig");

pub const protobuf_msg = @import("proto/mmc.pb.zig");
pub const protobuf = @import("protobuf");

pub const Version = packed struct {
    major: u8,
    minor: u8,
    patch: u8,
};

/// Cross-reference error types between client and server. It is used to avoid
/// sending string message from server to client when notifying the client if
/// an error occurred in the server. `NoError` value is used to notify the
/// client that the error is already resolved and server is working normally.
pub const MMCErrorEnum: type = generateErrorCodeEnum(MMCError);

/// `Unexpected` error is the way to tell the client that the error is not
/// coming from CC-Link. The actual error is printed in the server side.
/// Developer must fix the error immediately if `Unexpected` error is thrown.
pub const MMCError =
    generateErrorSet(mcl.registers.Wr.CommandResponseCode) ||
    error{ CCLinkDisconnected, Unexpected };

/// Convert an enum into an error set. The field of enum with value 0 will be
/// ignored. This behavior is consistent with zig Error set definition.
/// Convert an enum into an error set. The field of enum with value 0 will be
/// ignored. This behavior is consistent with zig Error set definition.
fn generateErrorSet(comptime Enum: type) type {
    if (@typeInfo(Enum) != .@"enum") return error.NotEnumType;
    const fields = @typeInfo(Enum).@"enum".fields;
    const error_len = fields.len - 1;
    comptime var error_set: [error_len]std.builtin.Type.Error = undefined;
    inline for (fields) |enum_field| {
        if (enum_field.value == 0) continue;
        error_set[enum_field.value - 1].name = enum_field.name;
    }
    return @Type(.{ .error_set = &error_set });
}

/// Convert error set to enum. The field of this enum is used in both client
/// and server for cross reference.
fn generateErrorCodeEnum(comptime Error: type) type {
    const result_len = @typeInfo(Error).error_set.?.len;
    const tag_type = std.math.IntFittingRange(0, result_len);
    comptime var result_field: [result_len + 1]std.builtin.Type.EnumField = undefined;
    result_field[0] = .{
        .name = "NoError",
        .value = 0,
    };
    const fields = @typeInfo(Error).error_set.?;
    inline for (fields, 1..) |field, i| {
        result_field[i] = .{
            .name = field.name,
            .value = i,
        };
    }
    return @Type(.{
        .@"enum" = .{
            .decls = &.{},
            .fields = &result_field,
            .is_exhaustive = true,
            .tag_type = tag_type,
        },
    });
}
