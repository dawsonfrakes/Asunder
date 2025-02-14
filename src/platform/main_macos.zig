const core = @import("../modules/core.zig");

pub const m = struct {
    const macos = @import("../modules/macos.zig");
    pub usingnamespace macos;
    pub usingnamespace macos.libSystem;
    pub usingnamespace macos.libobjc;
    pub usingnamespace macos.fwFoundation;
    pub usingnamespace macos.fwAppKit;
};

pub const platform = struct {};

fn entry() void {
    inline for (@typeInfo(m.libobjc.classes).@"struct".decls) |decl| {
        @field(m.libobjc.classes, decl.name) = m.objc_getClass(decl.name).?;
    }
    inline for (@typeInfo(m.libobjc.selectors).@"struct".decls) |decl| {
        @field(m.libobjc.selectors, decl.name) = m.sel_getUid(decl.name).?;
    }

    const app = m.NSApplication.sharedApplication().?;
    _ = app.@"setActivationPolicy:"(.regular);

    const window = m.NSWindow.alloc().?.@"initWithContentRect:styleMask:backing:defer:"(
        .{ .origin = .{ .x = 0, .y = 0 }, .size = .{ .w = 600, .h = 400 } },
        core.enumFlags(m.NSWindow.StyleMask, .{ .titled, .closable, .miniaturizable, .resizable }),
        .buffered,
        false,
    ).?;
    window.@"setTitle:"(m.NSString.alloc().?.@"initWithUTF8String:"("Asunder").?);
    window.@"makeKeyAndOrderFront:"(null);

    app.run();
}

pub export fn _start() callconv(.c) noreturn {
    entry();
    m.exit(0);
}
