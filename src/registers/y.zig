const std = @import("std");
const registers = @import("../registers.zig");

const Direction = registers.Direction;

/// Registers written through CC-Link's "DevY" device. Used as a "write"
/// register bank.
pub const Y = packed struct(u64) {
    cc_link_enable: bool = false, //Y00
    service_enable: bool = false, //Y01
    start_command: bool = false, //Y02
    reset_command_received: bool = false, //Y03
    _04: u2 = 0,
    release_control: bool = false, //Y06, Release all motor control
    emergency_stop: bool = false, //Y07
    temporary_pause: bool = false, //Y08
    stop_driver_transmission: packed struct(u2) { //Y09,Y0A
        from_prev: bool = false,
        from_next: bool = false,

        pub fn set(
            self: *align(8:9:8) @This(),
            dir: Direction,
        ) void {
            switch (dir) {
                .backward => self.from_prev = true,
                .forward => self.from_next = true,
            }
        }

        pub fn reset(self: *align(8:9:8) @This(), dir: Direction) void {
            switch (dir) {
                .backward => self.from_prev = false,
                .forward => self.from_next = false,
            }
        }
    } = .{},
    clear_errors: bool = false, //Y0B
    clear_axis_slider_info: bool = false, //Y0C
    prev_axis_isolate_link: bool = false, //Y0D
    next_axis_isolate_link: bool = false, //Y0E
    _0F: u1 = 0, //Y0F
    reset_pull_slider: packed struct(u3) { //Y10,Y11,Y12
        axis1: bool = false,
        axis2: bool = false,
        axis3: bool = false,

        pub fn axis(self: @This(), local_axis: u2) bool {
            std.debug.assert(local_axis <= 2);
            return switch (local_axis) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                else => unreachable,
            };
        }

        pub fn setAxis(
            self: *align(8:16:8) @This(),
            local_axis: u2,
        ) void {
            std.debug.assert(local_axis <= 2);
            switch (local_axis) {
                0 => self.axis1 = true,
                1 => self.axis2 = true,
                2 => self.axis3 = true,
                else => unreachable,
            }
        }

        pub fn resetAxis(
            self: *align(8:16:8) @This(),
            local_axis: u2,
        ) void {
            std.debug.assert(local_axis <= 2);
            switch (local_axis) {
                0 => self.axis1 = false,
                1 => self.axis2 = false,
                2 => self.axis3 = false,
                else => unreachable,
            }
        }
    } = .{},
    recovery_use_hall_sensor: packed struct(u2) { //Y13,Y14
        back: bool = false,
        front: bool = false,

        pub fn side(self: @This(), dir: Direction) bool {
            return switch (dir) {
                .backward => self.back,
                .forward => self.front,
            };
        }

        pub fn setSide(
            self: *align(8:19:8) @This(),
            dir: Direction,
        ) void {
            switch (dir) {
                .backward => self.back = true,
                .forward => self.front = true,
            }
        }
        pub fn resetSide(
            self: *align(8:19:8) @This(),
            dir: Direction,
        ) void {
            switch (dir) {
                .backward => self.back = false,
                .forward => self.front = false,
            }
        }
    } = .{},
    _15: u12 = 0,
    get_speed_info: bool, //Y21,
    get_current_info: bool, //Y22
    lockup: packed struct(u3) { //Y23,Y24,Y25
        axis1: bool = false,
        axis2: bool = false,
        axis3: bool = false,

        pub fn axis(self: @This(), local_axis: u2) bool {
            std.debug.assert(local_axis <= 2);
            return switch (local_axis) {
                0 => self.axis1,
                1 => self.axis2,
                2 => self.axis3,
                else => unreachable,
            };
        }

        pub fn setAxis(
            self: *align(8:35:8) @This(),
            local_axis: u2,
        ) void {
            switch (local_axis) {
                0 => self.axis1 = true,
                1 => self.axis2 = true,
                2 => self.axis3 = true,
                else => unreachable,
            }
        }

        pub fn resetAxis(
            self: *align(8:35:8) @This(),
            local_axis: u2,
        ) void {
            std.debug.assert(local_axis <= 2);
            switch (local_axis) {
                0 => self.axis1 = false,
                1 => self.axis2 = false,
                2 => self.axis3 = false,
                else => unreachable,
            }
        }
    } = .{},
    _38: u26 = 0,

    pub fn format(y: Y, writer: anytype) !void {
        _ = try registers.nestedWrite("Y", y, 0, writer);
    }
};

test "Y" {
    try std.testing.expectEqual(8, @sizeOf(Y));
}

test {
    std.testing.refAllDecls(@This());
}
