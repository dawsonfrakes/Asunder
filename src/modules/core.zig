const std = @import("std");
const builtin = @import("builtin");

pub const cpu_bits = builtin.target.ptrBitWidth();
pub const os_tag = builtin.target.os.tag;

pub const CallingConvention = @TypeOf(@typeInfo(fn () void).@"fn".calling_convention);
pub const Type = @TypeOf(@typeInfo(type));

pub const zeroInit = std.mem.zeroInit;

pub inline fn zeroes(comptime T: type) T {
    return @as(*align(1) const T, @ptrCast(&[_]u8{0} ** @sizeOf(T))).*;
}

pub fn asciiToUtf16LeStringLiteral(comptime ascii: []const u8) [ascii.len:0]u16 {
    var utf16le: [ascii.len:0]u16 = undefined;
    for (&utf16le, ascii) |*out, in| out.* = in;
    utf16le[ascii.len] = 0;
    return utf16le;
}

pub fn FnsToFnPtrs(comptime T: type) type {
    comptime {
        const decls = @typeInfo(T).@"struct".decls;
        var fields: [decls.len]Type.StructField = undefined;
        for (&fields, decls) |*field, decl| {
            const DeclT = @TypeOf(@field(T, decl.name));
            field.* = if (@typeInfo(DeclT) == .@"fn") .{
                .name = decl.name,
                .type = *const DeclT,
                .default_value_ptr = null,
                .is_comptime = false,
                .alignment = @alignOf(*const DeclT),
            } else .{
                .name = decl.name,
                .type = DeclT,
                .default_value_ptr = &@field(T, decl.name),
                .is_comptime = true,
                .alignment = @alignOf(DeclT),
            };
        }
        return @Type(.{ .@"struct" = .{
            .layout = .auto,
            .fields = &fields,
            .decls = &.{},
            .is_tuple = false,
        } });
    }
}
