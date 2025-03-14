//! The message passed between client and server will have the following format:
//!
//! MessageType|MessageLength|ActualMessage (without character "|")
//!
//! MessageType is an enum described in this file. MessageLength is the byte
//! size of the whole message, help the client and server to know if the
//! message containing other message or not or if the receiver already receive
//! full message or not.
const std = @import("std");
const Param = @import("mmc-config.zig").Param;
const ParamType =
    @import("mmc-config.zig").ParamType;

/// Command message description from client to server
pub fn CommandMessage(comptime tag: @typeInfo(Param).@"union".tag_type.?) type {
    return packed struct(u104) {
        kind: KindFittedSize,
        _unused_kind: RestKindFittedSize,
        param: ParamType(tag),
        _rest_param: Unused,

        const kind_bit_size = @bitSizeOf(@typeInfo(Param).@"union".tag_type.?);

        /// Integer type that fit the number of commands used in the mmc-server
        const KindFittedSize: type = getKindSize();
        const rest_kind_bit_size = 8 - kind_bit_size;
        const RestKindFittedSize: type = getRestKindSize();
        const param_bit_size = @bitSizeOf(ParamType(tag));
        const unused_bit_size =
            104 - param_bit_size - kind_bit_size - rest_kind_bit_size;
        const Unused: type = getUnusedType(unused_bit_size);

        fn getUnusedType(size: comptime_int) type {
            comptime var max_unused_val = 1;
            for (0..size) |_| {
                max_unused_val *= 2;
            }
            return std.math.IntFittingRange(
                0,
                max_unused_val - 1,
            );
        }

        fn getKindSize() type {
            comptime var max_kind_value = 1;
            for (0..kind_bit_size) |_| {
                max_kind_value *= 2;
            }
            return std.math.IntFittingRange(
                0,
                max_kind_value - 1,
            );
        }

        fn getRestKindSize() type {
            comptime var max_rest_kind_val = 1;
            for (0..rest_kind_bit_size) |_| {
                max_rest_kind_val *= 2;
            }
            return std.math.IntFittingRange(
                0,
                max_rest_kind_val - 1,
            );
        }
    };
}

/// Type of message that is sent between client and server
pub const MessageType = enum {
    Command,
    RegisterX,
    RegisterY,
    RegisterWr,
    RegisterWw,
    StatusCarrier,
    StatusHall,
    StatusCommand,
    LineConfig,
};
