const std = @import("std");
const Direction = @import("mmc-config.zig").Direction;
const mcl = @import("mcl");
const Line = mcl.Line;
const Axis = mcl.Axis;

// Length of `carriers` and `hall_sensors` is defined by the maximum number of
// axis in one line.
/// `num_of_carriers` is required for updating the `system_state` in the server.
/// We do not want to update the carriers information when there is suddenly
/// the detected slider is less than the previous information (ghosting).
num_of_carriers: u10,
carriers: [64 * 4 * 3]Carrier,
hall_sensors: [64 * 4 * 3]Hall,
command: [64 * 4]Command,

pub const Carrier = packed struct {
    id: u10,
    axis_idx: packed struct {
        main_axis: Axis.Id.Line,
        aux_axis: Axis.Id.Line,
    },
    location: f32,
    state: mcl.registers.Wr.Carrier.State,
};

pub const Hall = packed struct {
    /// The `configured` flag is used to check whether the axis at that index
    /// has been configured by the system. This approach is taken because
    /// the `hall_sensors` field of `SystemState` is an array, not a slice.
    configured: bool,
    front: bool,
    back: bool,
};

pub const Command = packed struct {
    command_received: bool,
    command_response: mcl.registers.Wr.CommandResponseCode,
};
