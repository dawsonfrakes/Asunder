const core = @import("modules/core.zig");

pub usingnamespace switch (core.os_tag) {
    .windows => @import("platform/main_windows.zig"),
    .macos => @import("platform/main_macos.zig"),
    .linux,
    .freebsd,
    .openbsd,
    .netbsd,
    .dragonfly,
    => @import("platform/main_unix.zig"),
    else => @compileError("OS not supported"),
};
