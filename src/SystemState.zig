const std = @import("std");
const Line = @import("mmc-config.zig").Line;
const Axis = @import("mmc-config.zig").Axis;
const Direction = @import("mmc-config.zig").Direction;

num_of_carriers: u16,
num_of_active_axis: Axis.Id.Line,
carriers: []Carrier,
hall_sensors: []Hall,

pub const Carrier = struct {
    carrier_id: u16,
    axis_ids: struct {
        first: Axis.Id.Line,
        second: Axis.Id.Line,
    },
    location: f32,
};

pub const Hall = struct {
    line_id: Axis.Id.Line,
    axis_id: Axis.Id.Line,
    hall_states: struct {
        front: bool,
        back: bool,
    },
};
