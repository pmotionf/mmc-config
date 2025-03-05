const std = @import("std");
const Line = @import("mmc-config.zig").Line;
const Axis = @import("mmc-config.zig").Axis;
const Direction = @import("mmc-config.zig").Direction;
const mcl = @import("mcl");

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
