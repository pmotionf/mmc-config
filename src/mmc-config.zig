const std = @import("std");
const mcl = @import("mcl");
pub const Message =
    @import("message.zig").Message;
pub const Param = @import("Param.zig").Param;
pub const SystemState = @import("SystemState.zig");

pub const Direction = enum(u2) {
    no_direction,
    backward,
    forward,
    _,
};

pub fn ParamType(comptime kind: @typeInfo(Param).@"union".tag_type.?) type {
    return @FieldType(Param, @tagName(kind));
}

/// This enum is used across both the client and server for cross-referencing
/// error types. It is used to avoid sending string message from server
/// to client when notifying the client if an error occurred in the server.
pub const MMCErrorEnum: type = generateErrorCodeEnum(MMCError);

const MMCError =
    generateErrorSet(mcl.registers.Wr.CommandResponseCode) ||
    error{CCLinkDisconnected};

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
    const tag_type = std.math.IntFittingRange(0, result_len - 1);
    comptime var result_field: [result_len]std.builtin.Type.EnumField = undefined;
    const fields = @typeInfo(Error).error_set.?;
    inline for (fields, 0..) |field, i| {
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

test {
    std.testing.refAllDeclsRecursive(@This());
    try std.testing.expectEqual(
        @bitSizeOf(Message(.set_command)),
        104,
    );
    std.testing.refAllDeclsRecursive(Message(.set_command));
}
