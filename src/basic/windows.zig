const basic = @import("basic.zig");

pub const WINAPI = basic.CallingConvention.winapi;

pub const kernel32 = struct {
    pub const HINSTANCE = *opaque {};
    pub const HMODULE = HINSTANCE;

    pub extern "kernel32" fn ExitProcess(c_uint) callconv(WINAPI) noreturn;
};

pub const user32 = struct {
    pub const HDC = *opaque {};
    pub const HWND = *opaque {};
    pub const HMENU = *opaque {};
    pub const HICON = *opaque {};
    pub const HBRUSH = *opaque {};
    pub const HCURSOR = *opaque {};
    pub const HMONITOR = *opaque {};

    pub extern "user32" fn SetProcessDPIAware() callconv(WINAPI) c_int;
};
