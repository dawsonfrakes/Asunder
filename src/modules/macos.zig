pub const libSystem = struct {
    pub extern "System" fn exit(status: c_int) noreturn;
};

pub const libobjc = struct {
    pub const classes = struct {
        pub var NSObject: objc_Class = undefined;
        pub var NSString: objc_Class = undefined;
        pub var NSApplication: objc_Class = undefined;
        pub var NSWindow: objc_Class = undefined;
    };
    pub const selectors = struct {
        pub var alloc: objc_SEL = undefined;
        pub var release: objc_SEL = undefined;
        pub var run: objc_SEL = undefined;
        pub var @"stop:": objc_SEL = undefined;
        pub var sharedApplication: objc_SEL = undefined;
        pub var @"setTitle:": objc_SEL = undefined;
        pub var @"setActivationPolicy:": objc_SEL = undefined;
        pub var @"initWithContentRect:styleMask:backing:defer:": objc_SEL = undefined;
        pub var @"makeKeyAndOrderFront:": objc_SEL = undefined;
        pub var @"initWithUTF8String:": objc_SEL = undefined;
        pub var @"windowWillClose:": objc_SEL = undefined;
        pub var @"setDelegate:": objc_SEL = undefined;
        pub var @"applicationDidFinishLaunching:": objc_SEL = undefined;
        pub var @"nextEventMatchingMask:untilDate:inMode:dequeue:": objc_SEL = undefined;
        pub var @"sendEvent:": objc_SEL = undefined;
    };

    pub const objc_Class = *opaque {};
    pub const objc_SEL = *opaque {};
    pub const objc_Protocol = opaque {};

    pub extern "objc" fn objc_msgSend() void;
    pub extern "objc" fn objc_getClass(name: ?[*:0]const u8) ?objc_Class;
    pub extern "objc" fn sel_getUid(name: ?[*:0]const u8) ?objc_SEL;
    pub extern "objc" fn objc_allocateClassPair(superclass: ?objc_Class, name: ?[*:0]const u8, extraBytes: usize) ?objc_Class;
    pub extern "objc" fn objc_registerClassPair(cls: ?objc_Class) void;
    pub extern "objc" fn class_addProtocol(cls: ?objc_Class, protocol: ?*objc_Protocol) c_int;
    pub extern "objc" fn objc_getProtocol(name: ?[*:0]const u8) ?*objc_Protocol;
    pub extern "objc" fn class_addMethod(cls: ?objc_Class, name: ?objc_SEL, imp: ?*const fn () callconv(.c) void, types: ?[*:0]const u8) c_int;
    pub extern "objc" fn class_createInstance(cls: ?objc_Class, extraBytes: usize) ?*anyopaque;
};

pub const fwCoreFoundation = struct {
    pub const CGPoint = extern struct {
        x: f64,
        y: f64,
    };
    pub const CGSize = extern struct {
        w: f64,
        h: f64,
    };
    pub const CGRect = extern struct {
        origin: CGPoint,
        size: CGSize,
    };
};

pub const fwFoundation = struct {
    pub const NSString = opaque {
        pub fn alloc() ?*NSString {
            return @as(*const fn (cls: ?libobjc.objc_Class, sel: ?libobjc.objc_SEL) callconv(.c) ?*NSString, @ptrCast(&libobjc.objc_msgSend))(libobjc.classes.NSString, libobjc.selectors.alloc);
        }

        pub fn @"initWithUTF8String:"(self: *NSString, utf8: [:0]const u8) ?*NSString {
            return @as(*const fn (obj: ?*NSString, sel: ?libobjc.objc_SEL, utf8: ?[*:0]const u8) callconv(.c) ?*NSString, @ptrCast(&libobjc.objc_msgSend))(self, libobjc.selectors.@"initWithUTF8String:", utf8);
        }
    };
    pub const NSRect = fwCoreFoundation.CGRect;
};

pub const fwAppKit = struct {
    pub extern const NSDefaultRunLoopMode: ?*anyopaque;

    pub const NSEvent = opaque {
        pub const EventMask = enum(c_ulonglong) {
            any = 0xFFFFFFFF,
        };

        pub fn release(self: *NSEvent) void {
            return @as(*const fn (cls: ?*NSEvent, sel: ?libobjc.objc_SEL) callconv(.c) void, @ptrCast(&libobjc.objc_msgSend))(self, libobjc.selectors.release);
        }
    };

    pub const NSApplication = opaque {
        pub const ActivationPolicy = enum(c_int) {
            regular = 0,
            accessory = 1,
            prohibited = 2,
        };

        pub fn sharedApplication() ?*NSApplication {
            return @as(*const fn (cls: ?libobjc.objc_Class, sel: ?libobjc.objc_SEL) callconv(.c) ?*NSApplication, @ptrCast(&libobjc.objc_msgSend))(libobjc.classes.NSApplication, libobjc.selectors.sharedApplication);
        }

        pub fn @"setActivationPolicy:"(self: *NSApplication, policy: ActivationPolicy) bool {
            return @as(*const fn (obj: ?*NSApplication, sel: ?libobjc.objc_SEL, policy: ActivationPolicy) callconv(.c) bool, @ptrCast(&libobjc.objc_msgSend))(self, libobjc.selectors.@"setActivationPolicy:", policy);
        }

        pub fn run(self: *NSApplication) void {
            return @as(*const fn (obj: ?*NSApplication, sel: ?libobjc.objc_SEL) callconv(.c) void, @ptrCast(&libobjc.objc_msgSend))(self, libobjc.selectors.run);
        }

        pub fn @"stop:"(self: *NSApplication, sender: ?*anyopaque) void {
            return @as(*const fn (obj: ?*NSApplication, sel: ?libobjc.objc_SEL, sender: ?*anyopaque) callconv(.c) void, @ptrCast(&libobjc.objc_msgSend))(self, libobjc.selectors.@"stop:", sender);
        }

        pub fn @"setDelegate:"(self: *NSApplication, delegate: *anyopaque) void {
            return @as(*const fn (obj: ?*NSApplication, sel: ?libobjc.objc_SEL, delegate: ?*anyopaque) callconv(.c) void, @ptrCast(&libobjc.objc_msgSend))(self, libobjc.selectors.@"setDelegate:", delegate);
        }

        pub fn @"nextEventMatchingMask:untilDate:inMode:dequeue:"(self: *NSApplication, mask: NSEvent.EventMask, untilDate: ?*anyopaque, inMode: ?*anyopaque, dequeue: c_int) ?*NSEvent {
            return @as(*const fn (obj: ?*NSApplication, sel: ?libobjc.objc_SEL, mask: NSEvent.EventMask, untilDate: ?*anyopaque, inMode: ?*anyopaque, dequeue: c_int) callconv(.c) ?*NSEvent, @ptrCast(&libobjc.objc_msgSend))(self, libobjc.selectors.@"nextEventMatchingMask:untilDate:inMode:dequeue:", mask, untilDate, inMode, dequeue);
        }

        pub fn @"sendEvent:"(self: *NSApplication, event: *NSEvent) void {
            return @as(*const fn (obj: ?*NSApplication, sel: ?libobjc.objc_SEL, event: ?*NSEvent) callconv(.c) void, @ptrCast(&libobjc.objc_msgSend))(self, libobjc.selectors.@"sendEvent:", event);
        }
    };

    pub const NSWindow = opaque {
        pub const StyleMask = enum(c_uint) {
            titled = 1 << 0,
            closable = 1 << 1,
            miniaturizable = 1 << 2,
            resizable = 1 << 3,
            _,
        };
        pub const BackingStore = enum(c_int) {
            retained = 0,
            nonretained = 1,
            buffered = 2,
        };

        pub fn alloc() ?*NSWindow {
            return @as(*const fn (cls: ?libobjc.objc_Class, sel: ?libobjc.objc_SEL) callconv(.c) ?*NSWindow, @ptrCast(&libobjc.objc_msgSend))(libobjc.classes.NSWindow, libobjc.selectors.alloc);
        }

        pub fn @"initWithContentRect:styleMask:backing:defer:"(self: *NSWindow, rect: fwFoundation.NSRect, style: StyleMask, backing: BackingStore, @"defer": bool) ?*NSWindow {
            return @as(*const fn (obj: ?*NSWindow, sel: ?libobjc.objc_SEL, rect: fwFoundation.NSRect, style: StyleMask, backing: BackingStore, @"defer": bool) callconv(.c) ?*NSWindow, @ptrCast(&libobjc.objc_msgSend))(self, libobjc.selectors.@"initWithContentRect:styleMask:backing:defer:", rect, style, backing, @"defer");
        }

        pub fn @"setTitle:"(self: *NSWindow, title: *fwFoundation.NSString) void {
            return @as(*const fn (obj: ?*NSWindow, sel: ?libobjc.objc_SEL, title: ?*fwFoundation.NSString) callconv(.c) void, @ptrCast(&libobjc.objc_msgSend))(self, libobjc.selectors.@"setTitle:", title);
        }

        pub fn @"makeKeyAndOrderFront:"(self: *NSWindow, sender: ?*anyopaque) void {
            return @as(*const fn (obj: ?*NSWindow, sel: ?libobjc.objc_SEL, sender: ?*anyopaque) callconv(.c) void, @ptrCast(&libobjc.objc_msgSend))(self, libobjc.selectors.@"makeKeyAndOrderFront:", sender);
        }

        pub fn @"setDelegate:"(self: *NSWindow, delegate: *anyopaque) void {
            return @as(*const fn (obj: ?*NSWindow, sel: ?libobjc.objc_SEL, delegate: ?*anyopaque) callconv(.c) void, @ptrCast(&libobjc.objc_msgSend))(self, libobjc.selectors.@"setDelegate:", delegate);
        }
    };
};
