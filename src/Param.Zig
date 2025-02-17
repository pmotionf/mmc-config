const std = @import("std");
const Line = @import("mmc-config.zig").Line;
const Axis = @import("mmc-config.zig").Axis;
const Direction = @import("mmc-config.zig").Direction;

pub const Param = union(enum) {
    get_x: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.Line,
    },
    get_y: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.Line,
    },
    get_wr: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.Line,
    },
    get_ww: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.Line,
    },
    clear_errors: void,
    clear_carrier_info: void,
    reset_mcl: void,
    release_axis_servo: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.Line,
    },
    calibrate: packed struct {
        line_idx: Line.Index,
    },
    set_line_zero: packed struct {
        line_idx: Line.Index,
    },
    isolate: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.Line,
        direction: Direction,
        carrier_id: u16,
        link_axis: Direction,
    },
    recover_carrier: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.Line,
        new_carrier_id: u16,
        use_sensor: Direction,
    },
    move_carrier_axis: packed struct {
        line_idx: Line.Index,
        carrier_id: u16,
        axis_idx: Axis.Index.Line,
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
        axis_idx: Axis.Index.Line,
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
        axis_idx: Axis.Index.Line,
        carrier_id: u16,
    },
    pull_carrier_backward: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.Line,
        carrier_id: u16,
    },
    stop_pull_carrier: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.Line,
    },
};
