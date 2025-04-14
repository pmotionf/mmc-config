//! This modules provide system state for each line. The information this
//! modules provide are the carrier and hall sensor information of each line.
const LineState = @This();

const std = @import("std");
const Direction = @import("mmc-config.zig").Direction;
const mcl = @import("mcl");
const Line = mcl.Line;
const Axis = mcl.Axis;

pub var line_states: []LineState = &.{};
var allocator: ?std.mem.Allocator = null;
// Line index
index: mcl.Line.Index,
/// Num of carriers is required because the number of carriers in one line
/// is not constant.
num_of_carriers: u10,
/// Contain carrier information within one line. The index of `carriers`
/// represent the actual `carrier.id - 1` of the line for instant access.
carriers: [64 * 4 * 3]Carrier,
/// Contain hall sensors front and back information of each axis within one line.
/// The index of hall_sensors represents the actual axis index of the line for
/// instant access.
hall_sensors: []Hall,

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
    front: bool,
    back: bool,
};

pub fn init(a: std.mem.Allocator, config: mcl.Config) !void {
    line_states = try a.alloc(LineState, config.lines.len);
    for (config.lines, 0..) |line, line_idx| {
        line_states[line_idx].index = line_idx;
        line_states[line_idx].hall_sensors = try a.alloc(
            LineState.Hall,
            line.axes,
        );
        @memset(
            line_states[line_idx].hall_sensors,
            std.mem.zeroInit(LineState.Hall, .{}),
        );
        @memset(
            line_states[line_idx].carriers,
            std.mem.zeroInit(LineState.Carrier, .{}),
        );
    }
    allocator = a;
    errdefer {
        for (0..line_states.len) |line_idx| {
            a.free(line_states[line_idx].hall_sensors);
        }
    }
}

pub fn deinit() void {
    if (allocator) |a| {
        for (0..line_states.len) |line_idx| {
            a.free(line_states[line_idx].hall_sensors);
        }
        a.free(line_states);
    }
    allocator = null;
}
