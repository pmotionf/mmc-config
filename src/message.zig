const std = @import("std");
const config = @import("mmc.zig");

const kind_bit_size = @bitSizeOf(@typeInfo(config.Param).@"union".tag_type.?);
pub const kind_size: type = defineKindSize();
const rest_kind_bit_size = 8 - kind_bit_size;
pub const rest_kind_size: type = defineRestKindSize();

/// Unwrap the message of mmc communication. The message structure:
/// - active tag integer value of Command tagged union
/// - parameters of the active parameter
/// - unused bit from the given 8 byte buffer
pub fn messageType(comptime tag: @typeInfo(config.Param).@"union".tag_type.?) type {
    const Param: type = config.Param.ParamType(tag);
    const param_bit_size: comptime_int = @bitSizeOf(Param);
    comptime var max_param_size = 1;
    for (0..param_bit_size) |_| {
        max_param_size *= 2;
    }
    const unused_bit_size = 64 -
        param_bit_size - kind_bit_size - rest_kind_bit_size;
    comptime var max_unused_val = 1;
    for (0..unused_bit_size) |_| {
        max_unused_val *= 2;
    }
    const unused_size: type = std.math.IntFittingRange(
        0,
        max_unused_val - 1,
    );
    return packed struct {
        kind: kind_size,
        _unused_kind: rest_kind_size,
        param: Param,
        _rest_param: unused_size,
    };
}

fn defineKindSize() type {
    comptime var max_kind_value = 1;
    for (0..kind_bit_size) |_| {
        max_kind_value *= 2;
    }
    return std.math.IntFittingRange(
        0,
        max_kind_value - 1,
    );
}

fn defineRestKindSize() type {
    comptime var max_rest_kind_val = 1;
    for (0..rest_kind_bit_size) |_| {
        max_rest_kind_val *= 2;
    }
    return std.math.IntFittingRange(
        0,
        max_rest_kind_val - 1,
    );
}
