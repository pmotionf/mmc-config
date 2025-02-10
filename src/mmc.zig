const std = @import("std");
const mcl = @import("mcl");
pub const message = @import("message.zig");

const Direction = enum(u2) {
    backward,
    forward,
    no_direction,
    _,
};

pub const Param = union(enum) {
    set_speed: packed struct {
        line_idx: mcl.Line.Index,
        speed: u8,
    },
    set_acceleration: packed struct {
        line_idx: mcl.Line.Index,
        acceleration: u8,
    },
    get_speed: packed struct {
        line_idx: mcl.Line.Index,
    },
    get_acceleration: packed struct {
        line_idx: mcl.Line.Index,
    },
    axis_carrier: packed struct {
        line_idx: mcl.Line.Index,
        axis_idx: mcl.Axis.Index.Line,
    },
    carrier_location: packed struct {
        line_idx: mcl.Line.Index,
        carrier_id: u16,
    },
    carrier_axis: packed struct {
        line_idx: mcl.Line.Index,
        carrier_id: u16,
    },
    clear_errors: packed struct {
        line_idx: mcl.Line.Index,
        axis_idx: mcl.Axis.Index.Line,
    },
    clear_carrier_info: packed struct {
        line_idx: mcl.Line.Index,
        axis_idx: mcl.Axis.Index.Line,
    },
    release_axis_servo: packed struct {
        line_idx: mcl.Line.Index,
        axis_idx: mcl.Axis.Index.Line,
    },
    stop_traffic: packed struct {
        line_idx: mcl.Line.Index,
        axis_idx: mcl.Axis.Index.Line,
        direction: mcl.Direction,
    },
    allow_traffic: packed struct {
        line_idx: mcl.Line.Index,
        axis_idx: mcl.Axis.Index.Line,
        direction: mcl.Direction,
    },
    calibrate: packed struct {
        line_idx: mcl.Line.Index,
    },
    set_line_zero: packed struct {
        line_idx: mcl.Line.Index,
    },
    isolate: packed struct {
        line_idx: mcl.Line.Index,
        axis_idx: mcl.Axis.Index.Line,
        direction: mcl.Direction,
        carrier_id: u16,
        link_axis: Direction,
    },
    recover_carrier: packed struct {
        line_idx: mcl.Line.Index,
        axis_idx: mcl.Axis.Index.Line,
        new_carrier_id: u16,
        use_sensor: Direction,
    },
    move_carrier_axis: packed struct {
        line_idx: mcl.Line.Index,
        carrier_id: u16,
        axis_idx: mcl.Axis.Index.Line,
    },
    move_carrier_location: packed struct {
        line_idx: mcl.Line.Index,
        carrier_id: u16,
        location: f32,
    },
    move_carrier_distance: packed struct {
        line_idx: mcl.Line.Index,
        carrier_id: u16,
        distance: f32,
    },
    spd_move_carrier_axis: packed struct {
        line_idx: mcl.Line.Index,
        carrier_id: u16,
        axis_idx: mcl.Axis.Index.Line,
    },
    spd_move_carrier_location: packed struct {
        line_idx: mcl.Line.Index,
        carrier_id: u16,
        location: f32,
    },
    spd_move_carrier_distance: packed struct {
        line_idx: mcl.Line.Index,
        carrier_id: u16,
        distance: f32,
    },
    push_carrier_forward: packed struct {
        line_idx: mcl.Line.Index,
        carrier_id: u16,
    },
    push_carrier_backward: packed struct {
        line_idx: mcl.Line.Index,
        carrier_id: u16,
    },
    pull_carrier_forward: packed struct {
        line_idx: mcl.Line.Index,
        axis_idx: mcl.Axis.Index.Line,
        carrier_id: u16,
    },
    pull_carrier_backward: packed struct {
        line_idx: mcl.Line.Index,
        axis_idx: mcl.Axis.Index.Line,
        carrier_id: u16,
    },
    stop_pull_carrier: packed struct {
        line_idx: mcl.Line.Index,
        axis_idx: mcl.Axis.Index.Line,
    },

    pub fn ParamType(comptime kind: @typeInfo(Param).@"union".tag_type.?) type {
        const fields = @typeInfo(Param).@"union".fields;
        inline for (fields) |field| {
            if (std.mem.eql(u8, field.name, @tagName(kind))) {
                return field.type;
            }
        }
    }
};

test {
    std.testing.refAllDeclsRecursive(@This());
}
