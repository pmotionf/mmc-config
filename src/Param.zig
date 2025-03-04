const std = @import("std");
const Line = @import("mmc-config.zig").Line;
const Axis = @import("mmc-config.zig").Axis;
const Direction = @import("mmc-config.zig").Direction;

pub const CommandCode = enum(i16) {
    None = 0x0,
    SetLineZero = 0x1,
    // "By Position" commands calculate carrier movement by constant hall
    // sensor position feedback, and is much more precise in destination.
    PositionMoveCarrierAxis = 0x12,
    PositionMoveCarrierLocation = 0x13,
    PositionMoveCarrierDistance = 0x14,
    // "By Speed" commands calculate carrier movement by constant hall
    // sensor speed feedback. It should mostly not be used, as the
    // destination position becomes far too imprecise. However, it is
    // meant to maintain a certain speed while the carrier is traveling,
    // and to avoid the requirement of having a known system position.
    SpeedMoveCarrierAxis = 0x15,
    SpeedMoveCarrierLocation = 0x16,
    SpeedMoveCarrierDistance = 0x17,
    IsolateForward = 0x18,
    IsolateBackward = 0x19,
    Calibration = 0x1A,
    RecoverCarrierAtAxis = 0x1C,
    SetCarrierIdAtAxis = 0x1D,
    PushAxisCarrierForward = 0x1E,
    PushAxisCarrierBackward = 0x1F,
    PullAxisCarrierForward = 0x20,
    PullAxisCarrierBackward = 0x21,
};

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
        kind: enum(u1) { Hall, Carrier },
    },
    clear_errors: void,
    clear_carrier_info: void,
    reset_mcl: void,
    release_axis_servo: packed struct {
        line_idx: Line.Index,
        axis_idx: Axis.Index.Line,
    },
    /// send command to cc-link
    set_command: packed struct {
        command_code: CommandCode,
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
};
