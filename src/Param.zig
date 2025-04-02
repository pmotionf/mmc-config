const std = @import("std");
const mcl = @import("mcl");
const Line = mcl.Line;
const Axis = mcl.Axis;
const Station = mcl.Station;
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
    get_status: packed struct {
        kind: enum(u2) { Hall, Carrier, Command },
        line_idx: Line.Index,
        axis_idx: Axis.Index.Line,
        carrier_id: u10,
    },
    get_version: void,
    clear_command_status: packed struct {
        line_idx: Line.Index,
        station_idx: Station.Index,
        status: enum(u1) { CommandReceived, CommandResponse },
    },
    clear_errors: packed struct {
        line_id: Line.Id,
        axis_id: Axis.Id.Line,
    },
    clear_carrier_info: packed struct {
        line_id: Line.Id,
        axis_id: Axis.Id.Line,
    },
    reset_mcl: void,
    release_axis_servo: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.Line,
    },
    /// send command to cc-link
    set_command: packed struct {
        command_code: mcl.registers.Ww.Command,
        line_idx: Line.Index,
        axis_idx: Axis.Index.Line,
        carrier_id: u10,
        location_distance: f32,
        speed: u5,
        acceleration: u8,
        link_axis: Direction,
        use_sensor: Direction,
    },
    stop_pull_carrier: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.Line,
    },
    auto_initialize: packed struct {
        line_id: Line.Id,
    },
};
