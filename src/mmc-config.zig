const std = @import("std");
pub const Message =
    @import("message.zig").Message;
pub const Param = @import("Param.zig").Param;
pub const SystemState = @import("SystemState.zig");

pub const Direction = enum(u2) {
    backward,
    forward,
    no_direction,
    _,
};

/// Index within configured line, spanning across connection ranges.
pub const Station = struct {
    pub const Index: type = std.math.IntFittingRange(0, 64 * 4 - 1);
    pub const Id: type = std.math.IntFittingRange(1, 64 * 4);
};

/// The maximum number of stations is also the maximum number of lines, as
/// there can be a minimum of one station per line.
pub const Line = Station;

/// Axis Index and Id for the configured line and station.
pub const Axis = struct {
    pub const Index = struct {
        station: Axis.Index.Station,
        line: Axis.Index.Line,

        /// Local axis index within station.
        pub const Station: type = std.math.IntFittingRange(0, 2);
        /// Axis index within line.
        pub const Line: type = std.math.IntFittingRange(
            0,
            64 * 4 * 3 - 1,
        );
    };

    pub const Id = struct {
        station: Axis.Id.Station,
        line: Axis.Id.Line,

        /// Local axis ID within station.
        pub const Station: type = std.math.IntFittingRange(1, 3);
        /// Axis ID within line.
        pub const Line: type = std.math.IntFittingRange(
            1,
            64 * 4 * 3,
        );
    };
};

pub fn ParamType(comptime kind: @typeInfo(Param).@"union".tag_type.?) type {
    return @FieldType(Param, @tagName(kind));
}

test {
    std.testing.refAllDeclsRecursive(@This());
    try std.testing.expectEqual(
        @bitSizeOf(Message(.isolate)),
        64,
    );
    std.testing.refAllDeclsRecursive(Message(.isolate));
}
