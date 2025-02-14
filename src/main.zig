const core = @import("modules/core.zig");

pub usingnamespace switch (core.os_tag) {
    .windows => @import("platform/main_windows.zig"),
    .macos => @import("platform/main_macos.zig"),
    else => @compileError("OS not supported"),
};
