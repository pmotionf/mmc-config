const std = @import("std");
const Direction = @import("mmc-config.zig").Direction;
const mcl = @import("mcl");
const Line = mcl.Line;
const Axis = mcl.Axis;
const Station = mcl.Station;

// TODO: Length of carriers and hall_sensors should be specified correctly
num_of_carriers: u10,
num_of_active_axis: Axis.Id.Line,
carriers: [64 * 4 * 3]Carrier,
hall_sensors: [64 * 4 * 3]Hall,

pub const Carrier = packed struct {
    id: u10,
    line_id: Line.Id,
    axis_ids: packed struct {
        first: Axis.Id.Line,
        second: Axis.Id.Line,
    },
    location: f32,
    state: mcl.registers.Wr.Carrier.State,
    command_received: bool,
    command_response: mcl.registers.Wr.CommandResponseCode,
};

pub const Hall = packed struct {
    line_id: Line.Id,
    axis_id: Axis.Id.Line,
    hall_states: packed struct {
        front: bool,
        back: bool,
    },
};
