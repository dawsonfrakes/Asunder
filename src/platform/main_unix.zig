const core = @import("../modules/core.zig");
const linux = if (core.os_tag == .linux) @import("std").os.linux else struct {};

pub const libc = struct {
    pub extern "c" fn _exit(status: i32) noreturn;
    pub extern "c" fn usleep(status: c_uint) c_int;
};

pub const u = struct {
    const exit = if (core.os_tag == .linux) linux.exit else libc._exit;
    const usleep = libc.usleep;
};

pub const x = struct {
    pub const CopyFromParent = 0;
    pub const InputOutput = 1;

    pub const Display = opaque {};
    pub const Visual = opaque {};
    pub const Window = c_ulong;
    pub const XAnyEvent = extern struct {
        type: c_int,
        serial: c_ulong,
        send_event: c_int,
        display: ?*Display,
        window: Window,
    };
    pub const XEvent = extern union {
        type: c_int,
        xany: XAnyEvent,
        // xkey: XKeyEvent,
        // xbutton: XButtonEvent,
        // xmotion: XMotionEvent,
        // xcrossing: XCrossingEvent,
        // xfocus: XFocusChangeEvent,
        // xexpose: XExposeEvent,
        // xgraphicsexpose: XGraphicsExposeEvent,
        // xnoexpose: XNoExposeEvent,
        // xvisibility: XVisibilityEvent,
        // xcreatewindow: XCreateWindowEvent,
        // xdestroywindow: XDestroyWindowEvent,
        // xunmap: XUnmapEvent,
        // xmap: XMapEvent,
        // xmaprequest: XMapRequestEvent,
        // xreparent: XReparentEvent,
        // xconfigure: XConfigureEvent,
        // xgravity: XGravityEvent,
        // xresizerequest: XResizeRequestEvent,
        // xconfigurerequest: XConfigureRequestEvent,
        // xcirculate: XCirculateEvent,
        // xcirculaterequest: XCirculateRequestEvent,
        // xproperty: XPropertyEvent,
        // xselectionclear: XSelectionClearEvent,
        // xselectionrequest: XSelectionRequestEvent,
        // xselection: XSelectionEvent,
        // xcolormap: XColormapEvent,
        // xclient: XClientMessageEvent,
        // xmapping: XMappingEvent,
        // xerror: XErrorEvent,
        // xkeymap: XKeymapEvent,
        pad: [24]c_long,
    };

    pub extern "X11" fn XOpenDisplay(?[*:0]const u8) ?*Display;
    pub extern "X11" fn XCloseDisplay(?*Display) c_int;
    pub extern "X11" fn XDefaultRootWindow(?*Display) Window;
    pub extern "X11" fn XCreateWindow(?*Display, Window, c_int, c_int, c_uint, c_uint, c_uint, c_int, c_uint, ?*Visual, c_ulong, ?*anyopaque) Window;
    pub extern "X11" fn XMapWindow(?*Display, Window) c_int;
    pub extern "X11" fn XPending(?*Display) c_int;
    pub extern "X11" fn XNextEvent(?*Display, ?*XEvent) c_int;
};

pub fn main() noreturn {
    const display = x.XOpenDisplay(null);
    const root = x.XDefaultRootWindow(display.?);

    const window = x.XCreateWindow(
        display,
        root,
        0,
        0,
        600,
        400,
        0,
        x.CopyFromParent,
        x.InputOutput,
        @ptrFromInt(x.CopyFromParent),
        0,
        null,
    );
    _ = x.XMapWindow(display, window);

    while (true) {
        while (x.XPending(display) > 0) {
            var event: x.XEvent = undefined;
            _ = x.XNextEvent(display, &event);
        }

        _ = u.usleep(1000);
    }

    _ = x.XCloseDisplay(display);
    u.exit(0);
}
