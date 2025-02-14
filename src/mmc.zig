const std = @import("std");
pub const message = @import("message.zig");

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
        station: LocalStation,
        line: LocalLine,

        /// Local axis index within station.
        pub const LocalStation: type = std.math.IntFittingRange(0, 2);
        /// Axis index within line.
        pub const LocalLine: type = std.math.IntFittingRange(
            0,
            64 * 4 * 3 - 1,
        );
    };

    pub const Id = struct {
        station: LocalStation,
        line: LocalLine,

        /// Local axis ID within station.
        pub const LocalStation: type = std.math.IntFittingRange(1, 3);
        /// Axis ID within line.
        pub const LocalLine: type = std.math.IntFittingRange(
            1,
            64 * 4 * 3,
        );
    };
};

pub const Param = union(enum) {
    set_config: packed struct {
        line_idx: Line.Index,
        speed: u8,
        acceleration: u8,
    },
    get_speed: packed struct {
        line_idx: Line.Index,
    },
    get_acceleration: packed struct {
        line_idx: Line.Index,
    },
    get_x: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.LocalLine,
    },
    get_y: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.LocalLine,
    },
    get_wr: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.LocalLine,
    },
    get_ww: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.LocalLine,
    },
    axis_carrier: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.LocalLine,
    },
    carrier_location: packed struct {
        line_idx: Line.Index,
        carrier_id: u16,
    },
    carrier_axis: packed struct {
        line_idx: Line.Index,
        carrier_id: u16,
    },
    clear_errors: void,
    clear_carrier_info: void,
    get_hall_status: packed struct {
        line_idx: Line.Index,
        axis_id: Axis.Id.LocalLine,
    },
    assert_hall: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.LocalLine,
        side: Direction,
    },
    reset_mcl: void,
    release_axis_servo: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.LocalLine,
    },
    stop_traffic: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.LocalLine,
        direction: Direction,
    },
    allow_traffic: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.LocalLine,
        direction: Direction,
    },
    calibrate: packed struct {
        line_idx: Line.Index,
    },
    set_line_zero: packed struct {
        line_idx: Line.Index,
    },
    isolate: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.LocalLine,
        direction: Direction,
        carrier_id: u16,
        link_axis: Direction,
    },
    recover_carrier: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.LocalLine,
        new_carrier_id: u16,
        use_sensor: Direction,
    },
    move_carrier_axis: packed struct {
        line_idx: Line.Index,
        carrier_id: u16,
        axis_idx: Axis.Index.LocalLine,
    },
    move_carrier_location: packed struct {
        line_idx: Line.Index,
        carrier_id: u16,
        location: f32,
    },
    move_carrier_distance: packed struct {
        line_idx: Line.Index,
        carrier_id: u16,
        distance: f32,
    },
    spd_move_carrier_axis: packed struct {
        line_idx: Line.Index,
        carrier_id: u16,
        axis_idx: Axis.Index.LocalLine,
    },
    spd_move_carrier_location: packed struct {
        line_idx: Line.Index,
        carrier_id: u16,
        location: f32,
    },
    spd_move_carrier_distance: packed struct {
        line_idx: Line.Index,
        carrier_id: u16,
        distance: f32,
    },
    push_carrier_forward: packed struct {
        line_idx: Line.Index,
        carrier_id: u16,
    },
    push_carrier_backward: packed struct {
        line_idx: Line.Index,
        carrier_id: u16,
    },
    pull_carrier_forward: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.LocalLine,
        carrier_id: u16,
    },
    pull_carrier_backward: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.LocalLine,
        carrier_id: u16,
    },
    stop_pull_carrier: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.LocalLine,
    },
};

pub fn ParamType(comptime kind: @typeInfo(Param).@"union".tag_type.?) type {
    const fields = @typeInfo(Param).@"union".fields;
    inline for (fields) |field| {
        if (std.mem.eql(u8, field.name, @tagName(kind))) {
            return field.type;
        }
    }
}

test {
    std.testing.refAllDeclsRecursive(@This());
}
