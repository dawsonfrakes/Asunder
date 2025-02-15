const core = @import("../modules/core.zig");

pub const m = struct {
    const macos = @import("../modules/macos.zig");
    pub usingnamespace macos;
    pub usingnamespace macos.libSystem;
    pub usingnamespace macos.libobjc;
    pub usingnamespace macos.fwFoundation;
    pub usingnamespace macos.fwAppKit;
};

pub const platform = struct {
    var app: *m.NSApplication = undefined;
    var running = true;
};

fn AsunderApplicationDelegate_applicationDidFinishLaunching(self: ?*anyopaque, sel: ?*anyopaque, notification: ?*anyopaque) callconv(.c) void {
    _ = .{ self, sel, notification };
    platform.app.@"stop:"(null);
}

fn AsunderWindowDelegate_windowWillClose(self: ?*anyopaque, sel: ?*anyopaque, notification: ?*anyopaque) callconv(.c) void {
    _ = .{ self, sel, notification };
    platform.running = false;
}

fn entry() void {
    inline for (@typeInfo(m.libobjc.classes).@"struct".decls) |decl| {
        @field(m.libobjc.classes, decl.name) = m.objc_getClass(decl.name).?;
    }
    inline for (@typeInfo(m.libobjc.selectors).@"struct".decls) |decl| {
        @field(m.libobjc.selectors, decl.name) = m.sel_getUid(decl.name).?;
    }

    const AsunderApplicationDelegate = m.objc_allocateClassPair(m.classes.NSObject, "AsunderApplicationDelegate", 0).?;
    _ = m.class_addMethod(AsunderApplicationDelegate, m.selectors.@"applicationDidFinishLaunching:", @ptrCast(&AsunderApplicationDelegate_applicationDidFinishLaunching), "v@:@");
    m.objc_registerClassPair(AsunderApplicationDelegate);

    const AsunderWindowDelegate = m.objc_allocateClassPair(m.classes.NSObject, "AsunderWindowDelegate", 0).?;
    _ = m.class_addProtocol(AsunderWindowDelegate, m.objc_getProtocol("NSWindowDelegate").?);
    _ = m.class_addMethod(AsunderWindowDelegate, m.selectors.@"windowWillClose:", @ptrCast(&AsunderWindowDelegate_windowWillClose), "v@:@");
    m.objc_registerClassPair(AsunderWindowDelegate);

    platform.app = m.NSApplication.sharedApplication().?;
    _ = platform.app.@"setActivationPolicy:"(.regular);

    const application_delegate = m.class_createInstance(AsunderApplicationDelegate, 0).?;
    platform.app.@"setDelegate:"(application_delegate);

    const window = m.NSWindow.alloc().?.@"initWithContentRect:styleMask:backing:defer:"(
        .{ .origin = .{ .x = 0, .y = 0 }, .size = .{ .w = 600, .h = 400 } },
        core.enumFlags(m.NSWindow.StyleMask, .{ .titled, .closable, .miniaturizable, .resizable }),
        .buffered,
        false,
    ).?;
    window.@"setTitle:"(m.NSString.alloc().?.@"initWithUTF8String:"("Asunder").?);

    const window_delegate = m.class_createInstance(AsunderWindowDelegate, 0).?;
    window.@"setDelegate:"(window_delegate);

    window.@"makeKeyAndOrderFront:"(null);

    platform.app.run();

    while (platform.running) {
        while (true) {
            const event = platform.app.@"nextEventMatchingMask:untilDate:inMode:dequeue:"(.any, null, m.NSDefaultRunLoopMode, @intFromBool(true));
            if (event == null) break;
            platform.app.@"sendEvent:"(event.?);
            event.?.release();
        }
    }
}

pub export fn _start() noreturn {
    entry();
    m.exit(0);
}
