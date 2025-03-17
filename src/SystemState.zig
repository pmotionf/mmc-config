const std = @import("std");
const Direction = @import("mmc-config.zig").Direction;
const mcl = @import("mcl");
const Line = mcl.Line;
const Axis = mcl.Axis;
const Station = mcl.Station;

num_of_carriers: u10,
num_of_active_axis: Axis.Id.Line,
num_of_running_commands: Station.Id,
carriers: []Carrier,
hall_sensors: []Hall,
/// `command_status` indexing will follow the system configuration. It starts
/// from the first line and the first
command_status: []CommandStatus,

pub const Carrier = packed struct {
    id: u10,
    line_id: Line.Id,
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

/// `CommandStatus` will be used to determine whether the CC-Link has successfully
/// received the command. When a client sends a command that triggers register
/// `x.command_received`, it should notify the server that it has read the status.
/// Upon receiving the notification, the server will remove the entry based on
/// the parameter given by the client.
///
/// If the command targets an axis, then `carrier_id` will be zero. If the
/// command targets a carrier, then both `line_id` and `axis_id` will be zero
pub const CommandStatus = packed struct {
    command_type: mcl.registers.Ww.Command,
    line_id: Line.Id,
    station_id: Station.Id,
    carrier_id: u10,
    status: Station.Wr.CommandResponseCode,
    received: bool,
};
