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
        None = 0,
        WarmupProgressing = 1,
        WarmupCompleted = 2,
        CurrentBiasProgressing = 4,
        CurrentBiasCompleted = 5,
        PosMoveProgressing = 29,
        PosMoveCompleted = 30,
        ForwardCalibrationProgressing = 32,
        ForwardCalibrationCompleted = 33,
        BackwardIsolationProgressing = 34,
        BackwardIsolationCompleted = 35,
        ForwardRestartProgressing = 36,
        ForwardRestartCompleted = 37,
        BackwardRestartProgressing = 38,
        BackwardRestartCompleted = 39,
        SpdMoveProgressing = 40,
        SpdMoveCompleted = 41,
        NextAxisAuxiliary = 43,
        // Note: Next Axis Completed will show even when the next axis is
        // progressing, if the carrier is paused for collision avoidance
        // on the next axis.
        NextAxisCompleted = 44,
        PrevAxisAuxiliary = 45,
        // Note: Prev Axis Completed will show even when the prev axis is
        // progressing, if the carrier is paused for collision avoidance
        // on the prev axis.
        PrevAxisCompleted = 46,
        ForwardIsolationProgressing = 47,
        ForwardIsolationCompleted = 48,
        Overcurrent = 50,

        PullForward = 52,
        PullForwardCompleted = 53,
        PullBackward = 55,
        PullBackwardCompleted = 56,
        BackwardCalibrationProgressing = 58,
        BackwardCalibrationCompleted = 59,
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
