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
carriers: []Carrier,
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
        line_states[line_idx].index = @intCast(line_idx);
        line_states[line_idx].hall_sensors = try a.alloc(
            LineState.Hall,
            line.axes,
        );
        // Maximum number of carriers in one line is number of axes in one line
        line_states[line_idx].carriers = try a.alloc(Carrier, line.axes);
        line_states[line_idx].num_of_carriers = 0;
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

pub fn reset() void {
    for (line_states) |*line_state| {
        @memset(
            line_state.*.carriers,
            std.mem.zeroInit(LineState.Carrier, .{}),
        );
        line_state.*.num_of_carriers = 0;
    }
}

test "LineState" {
    var ranges = [_]mcl.Config.Line.Range{
        .{
            .channel = .cc_link_1slot,
            .start = 1,
            .end = 1,
        },
    };
    var lines = [_]mcl.Config.Line{ .{
        .axes = 3,
        .ranges = &ranges,
    }, .{
        .axes = 6,
        .ranges = &ranges,
    } };
    const config: mcl.Config = .{
        .lines = &lines,
    };
    const a = std.heap.page_allocator;
    try init(a, config);
    try std.testing.expectEqual(line_states.len, 2);
    for (0..lines.len) |i| {
        const line_state = line_states[i];
        try std.testing.expectEqual(
            line_state.carriers.len,
            lines[i].axes,
        );
        try std.testing.expectEqual(
            line_state.num_of_carriers,
            0,
        );
        try std.testing.expectEqual(
            line_state.hall_sensors.len,
            lines[i].axes,
        );
        try std.testing.expectEqual(
            line_state.index,
            i,
        );
        // Modify carrier and hall states
        for (0..line_state.carriers.len) |carrier_idx| {
            // unused 0x3 bit on carrier state
            if (carrier_idx == 3) continue;

            const carrier = &line_state.carriers[carrier_idx];
            carrier.*.id = @intCast(carrier_idx + 1);
            carrier.*.location = @floatFromInt(10 * carrier_idx);
            carrier.*.state = @enumFromInt(carrier_idx);
        }
        for (0..line_state.hall_sensors.len) |hall_idx| {
            const hall = &line_state.hall_sensors[hall_idx];
            if (hall_idx % 2 == 0) {
                hall.*.back = true;
                hall.*.front = false;
            } else {
                hall.*.back = false;
                hall.*.front = true;
            }
        }
    }
    // Test carrier and hall sensor state
    for (0..lines.len) |i| {
        const line_state = line_states[i];
        for (0..line_state.carriers.len) |carrier_idx| {
            const carrier = line_state.carriers[carrier_idx];
            if (carrier.id == 0) continue;

            try std.testing.expect(carrier.id == carrier_idx + 1);
            try std.testing.expect(carrier.location == @as(
                f32,
                @floatFromInt(10 * carrier_idx),
            ));
            try std.testing.expectEqualStrings(
                @tagName(carrier.state),
                @tagName(@as(
                    mcl.registers.Wr.Carrier.State,
                    @enumFromInt(carrier_idx),
                )),
            );
        }
        for (0..line_state.hall_sensors.len) |hall_idx| {
            const hall = line_state.hall_sensors[hall_idx];
            if (hall_idx % 2 == 0) {
                try std.testing.expect(hall.back == true);
                try std.testing.expect(hall.front == false);
            } else {
                try std.testing.expect(hall.back == false);
                try std.testing.expect(hall.front == true);
            }
        }
    }
    // Test reset for carrier information
    reset();
    for (0..lines.len) |i| {
        const line_state = line_states[i];
        for (0..line_state.carriers.len) |carrier_idx| {
            const carrier = line_state.carriers[carrier_idx];
            try std.testing.expect(carrier.id == 0);
            try std.testing.expect(carrier.location == 0);
            try std.testing.expectEqualStrings(
                @tagName(carrier.state),
                @tagName(@as(
                    mcl.registers.Wr.Carrier.State,
                    @enumFromInt(0),
                )),
            );
        }
    }
    deinit();
}
