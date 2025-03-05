const std = @import("std");
const Line = @import("mmc-config.zig").Line;
const Axis = @import("mmc-config.zig").Axis;
const Direction = @import("mmc-config.zig").Direction;

num_of_carriers: u10,
num_of_active_axis: Axis.Id.Line,
carriers: []Carrier,
hall_sensors: []Hall,

pub const Carrier = packed struct {
    line_id: Line.Id,
    carrier_id: u10,
    axis_ids: packed struct {
        first: Axis.Id.Line,
        second: Axis.Id.Line,
    },
    location: f32,
    state: State,

    pub const State = enum(u8) {
        None = 0x0,

        WarmupProgressing,
        WarmupCompleted,

        PosMoveProgressing = 0x4,
        PosMoveCompleted,
        SpdMoveProgressing,
        SpdMoveCompleted,
        Auxiliary,
        AuxiliaryCompleted,

        ForwardCalibrationProgressing = 0xA,
        ForwardCalibrationCompleted,
        BackwardCalibrationProgressing,
        BackwardCalibrationCompleted,

        ForwardIsolationProgressing = 0x10,
        ForwardIsolationCompleted,
        BackwardIsolationProgressing,
        BackwardIsolationCompleted,
        ForwardRestartProgressing,
        ForwardRestartCompleted,
        BackwardRestartProgressing,
        BackwardRestartCompleted,

        PullForward = 0x1A,
        PullForwardCompleted,
        PullBackward,
        PullBackwardCompleted,

        Overcurrent = 0x1F,
    };
};

pub const Hall = packed struct {
    line_id: Line.Id,
    axis_id: Axis.Id.Line,
    hall_states: packed struct {
        front: bool,
        back: bool,
    },
};
