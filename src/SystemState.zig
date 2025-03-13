const std = @import("std");
const Direction = @import("mmc-config.zig").Direction;
const mcl = @import("mcl");
const Line = mcl.Line;
const Axis = mcl.Axis;
const Station = mcl.Station;

num_of_carriers: u10,
num_of_active_axis: Axis.Id.Line,
carriers: []Carrier,
hall_sensors: []Hall,
command_status: []CommandStatus,

pub const Carrier = packed struct {
    line_id: Line.Id,
    carrier_id: u10,
    axis_ids: packed struct {
        first: Axis.Id.Line,
        second: Axis.Id.Line,
    },
    location: f32,
    state: mcl.registers.Wr.Carrier.State,
};

pub const Hall = packed struct {
    line_id: Line.Id,
    axis_id: Axis.Id.Line,
    hall_states: packed struct {
        front: bool,
        back: bool,
    },
};

pub const CommandStatus = packed struct {
    line_id: Line.Id,
    station_id: Station.Id,
    status: Station.Wr.CommandResponseCode,
};
