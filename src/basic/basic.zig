const builtin = @import("builtin");

pub const build_mode = builtin.mode;
pub const cpu_arch = builtin.target.cpu.arch;
pub const cpu_bits = builtin.target.ptrBitWidth();
pub const cpu_endianness = builtin.target.cpu.arch.endian();
pub const os_tag = builtin.target.os.tag;

pub const Type = @TypeOf(@typeInfo(type));
pub const CallingConvention = @TypeOf(@typeInfo(fn () void).@"fn".calling_convention);
