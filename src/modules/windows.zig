const core = @import("core.zig");

pub const kernel32 = struct {
    pub const HINSTANCE = *opaque {};
    pub const HMODULE = HINSTANCE;
    pub const PROC = *const fn () callconv(.winapi) isize;

    pub extern "kernel32" fn GetModuleHandleW(name: ?[*:0]const u16) callconv(.winapi) ?HMODULE;
    pub extern "kernel32" fn LoadLibraryW(name: ?[*:0]const u16) callconv(.winapi) ?HMODULE;
    pub extern "kernel32" fn GetProcAddress(module: ?HMODULE, name: ?[*:0]const u8) callconv(.winapi) ?PROC;
    pub extern "kernel32" fn Sleep(duration: c_ulong) callconv(.winapi) void;
    pub extern "kernel32" fn ExitProcess(status: c_ulong) callconv(.winapi) noreturn;
};

pub const user32 = struct {
    pub const CS_OWNDC = 0x0020;
    pub const IDI_WARNING: [*:0]align(1) const u16 = @ptrFromInt(32515);
    pub const IDC_CROSS: [*:0]align(1) const u16 = @ptrFromInt(32515);
    pub const WS_MAXIMIZEBOX = 0x00010000;
    pub const WS_MINIMIZEBOX = 0x00020000;
    pub const WS_THICKFRAME = 0x00040000;
    pub const WS_SYSMENU = 0x00080000;
    pub const WS_CAPTION = 0x00C00000;
    pub const WS_VISIBLE = 0x10000000;
    pub const WS_OVERLAPPEDWINDOW = WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX;
    pub const CW_USEDEFAULT: c_int = @bitCast(@as(c_uint, 0x80000000));
    pub const PM_REMOVE = 0x0001;
    pub const WM_CREATE = 0x0001;
    pub const WM_DESTROY = 0x0002;
    pub const WM_SIZE = 0x0005;
    pub const WM_PAINT = 0x000F;
    pub const WM_QUIT = 0x0012;
    pub const WM_ERASEBKGND = 0x0014;
    pub const WM_ACTIVATEAPP = 0x001C;
    pub const WM_KEYDOWN = 0x0100;
    pub const WM_KEYUP = 0x0101;
    pub const WM_SYSKEYDOWN = 0x0104;
    pub const WM_SYSKEYUP = 0x0105;
    pub const WM_SYSCOMMAND = 0x0112;
    pub const SC_KEYMENU = 0xF100;
    pub const GWL_STYLE = -16;
    pub const HWND_TOP: ?HWND = @ptrFromInt(0);
    pub const SWP_NOSIZE = 0x0001;
    pub const SWP_NOMOVE = 0x0002;
    pub const SWP_NOZORDER = 0x0004;
    pub const SWP_FRAMECHANGED = 0x0020;
    pub const MONITOR_DEFAULTTOPRIMARY = 0x00000001;
    pub const VK_RETURN = 0x0D;
    pub const VK_MENU = 0x12;
    pub const VK_ESCAPE = 0x1B;
    pub const VK_F4 = 0x73;
    pub const VK_F10 = 0x79;
    pub const VK_F11 = 0x7A;

    pub const HDC = *opaque {};
    pub const HWND = *opaque {};
    pub const HMENU = *opaque {};
    pub const HICON = *opaque {};
    pub const HBRUSH = *opaque {};
    pub const HCURSOR = *opaque {};
    pub const HMONITOR = *opaque {};
    pub const WNDPROC = *const fn (hwnd: ?HWND, message: c_uint, wParam: usize, lParam: isize) callconv(.winapi) isize;
    pub const POINT = extern struct {
        x: c_int,
        y: c_int,
    };
    pub const RECT = extern struct {
        left: c_int,
        top: c_int,
        right: c_int,
        bottom: c_int,
    };
    pub const WNDCLASSEXW = extern struct {
        cbSize: c_uint,
        style: c_uint,
        lpfnWndProc: ?WNDPROC,
        cbClsExtra: c_int,
        cbWndExtra: c_int,
        hInstance: ?kernel32.HINSTANCE,
        hIcon: ?HICON,
        hCursor: ?HCURSOR,
        hbrBackground: ?HBRUSH,
        lpszMenuName: ?[*:0]const u16,
        lpszClassName: ?[*:0]const u16,
        hIconSm: ?HICON,
    };
    pub const MSG = extern struct {
        hwnd: ?HWND,
        message: c_uint,
        wParam: usize,
        lParam: isize,
        time: c_ulong,
        pt: POINT,
        lPrivate: c_ulong,
    };
    pub const WINDOWPLACEMENT = extern struct {
        length: c_uint,
        flags: c_uint,
        showCmd: c_uint,
        ptMinPosition: POINT,
        ptMaxPosition: POINT,
        rcNormalPosition: RECT,
        rcDevice: RECT,
    };
    pub const MONITORINFO = extern struct {
        cbSize: c_ulong,
        rcMonitor: RECT,
        rcWork: RECT,
        dwFlags: c_ulong,
    };

    pub extern "user32" fn SetProcessDPIAware() callconv(.winapi) c_int;
    pub extern "user32" fn LoadIconW(instance: ?kernel32.HINSTANCE, name: ?[*:0]align(1) const u16) callconv(.winapi) ?HICON;
    pub extern "user32" fn LoadCursorW(instance: ?kernel32.HINSTANCE, name: ?[*:0]align(1) const u16) callconv(.winapi) ?HCURSOR;
    pub extern "user32" fn RegisterClassExW(wndclass: ?*const WNDCLASSEXW) callconv(.winapi) c_ushort;
    pub extern "user32" fn CreateWindowExW(exstyle: c_ulong, classname: ?[*:0]const u16, name: ?[*:0]const u16, style: c_ulong, x: c_int, y: c_int, w: c_int, h: c_int, parent: ?HWND, menu: ?HMENU, instance: ?kernel32.HINSTANCE, param: ?*anyopaque) callconv(.winapi) ?HWND;
    pub extern "user32" fn PeekMessageW(msg: ?*MSG, hwnd: ?HWND, mmin: c_uint, mmax: c_uint, mremove: c_uint) callconv(.winapi) c_int;
    pub extern "user32" fn TranslateMessage(msg: ?*const MSG) callconv(.winapi) c_int;
    pub extern "user32" fn DispatchMessageW(msg: ?*const MSG) callconv(.winapi) isize;
    pub extern "user32" fn PostQuitMessage(status: c_int) callconv(.winapi) void;
    pub extern "user32" fn DefWindowProcW(hwnd: ?HWND, message: c_uint, wParam: usize, lParam: isize) callconv(.winapi) isize;
    pub extern "user32" fn GetDC(hwnd: ?HWND) callconv(.winapi) ?HDC;
    pub extern "user32" fn ValidateRect(hwnd: ?HWND, rect: ?*const RECT) callconv(.winapi) c_int;
    pub extern "user32" fn DestroyWindow(hwnd: ?HWND) callconv(.winapi) c_int;
    pub extern "user32" fn ClipCursor(rect: ?*const RECT) callconv(.winapi) c_int;
    pub extern "user32" fn GetWindowLongPtrW(hwnd: ?HWND, index: c_int) callconv(.winapi) isize;
    pub extern "user32" fn SetWindowLongPtrW(hwnd: ?HWND, index: c_int, value: isize) callconv(.winapi) isize;
    pub extern "user32" fn GetWindowPlacement(hwnd: ?HWND, placement: ?*WINDOWPLACEMENT) callconv(.winapi) c_int;
    pub extern "user32" fn SetWindowPlacement(hwnd: ?HWND, placement: ?*const WINDOWPLACEMENT) callconv(.winapi) c_int;
    pub extern "user32" fn SetWindowPos(hwnd: ?HWND, after: ?HWND, x: c_int, y: c_int, w: c_int, h: c_int, flags: c_uint) callconv(.winapi) c_int;
    pub extern "user32" fn MonitorFromWindow(hwnd: ?HWND, flags: c_ulong) callconv(.winapi) ?HMONITOR;
    pub extern "user32" fn GetMonitorInfoW(monitor: ?HMONITOR, mi: ?*MONITORINFO) callconv(.winapi) c_int;
};

pub const ws2_32 = struct {
    pub const WSADESCRIPTION_LEN = 256;
    pub const WSASYS_STATUS_LEN = 128;

    pub const WSADATA32 = extern struct {
        szDescription: [WSADESCRIPTION_LEN + 1]u8,
        szSystemStatus: [WSASYS_STATUS_LEN + 1]u8,
        iMaxSockets: c_ushort,
        iMaxUdpDg: c_ushort,
        lpVendorInfo: ?[*]u8,
    };
    pub const WSADATA64 = extern struct {
        iMaxSockets: c_ushort,
        iMaxUdpDg: c_ushort,
        lpVendorInfo: ?[*]u8,
        szDescription: [WSADESCRIPTION_LEN + 1]u8,
        szSystemStatus: [WSASYS_STATUS_LEN + 1]u8,
    };
    pub const WSADATA = switch (core.cpu_bits) {
        32 => WSADATA32,
        64 => WSADATA64,
        else => unreachable,
    };

    pub extern "ws2_32" fn WSAStartup(version: c_ushort, wsadata: ?*WSADATA) callconv(.winapi) c_int;
    pub extern "ws2_32" fn WSACleanup() callconv(.winapi) c_int;
};

pub const dwmapi = struct {
    pub const DWMWA_USE_IMMERSIVE_DARK_MODE = 20;
    pub const DWMWA_WINDOW_CORNER_PREFERENCE = 33;
    pub const DWMWCP_DONOTROUND = 1;

    pub extern "dwmapi" fn DwmSetWindowAttribute(hwnd: ?user32.HWND, attribute: c_ulong, value: ?*const anyopaque, size: c_ulong) callconv(.winapi) c_int;
};

pub const winmm = struct {
    pub const TIMERR_NOERROR = 0;

    pub extern "winmm" fn timeBeginPeriod(interval: c_ulong) callconv(.winapi) c_ulong;
};
