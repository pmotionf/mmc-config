const std = @import("std");
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

test {
    std.testing.refAllDeclsRecursive(@This());
    try std.testing.expectEqual(
        @bitSizeOf(Message(.set_command)),
        104,
    );
    std.testing.refAllDeclsRecursive(Message(.set_command));
}
