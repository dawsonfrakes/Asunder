const basic = @import("../basic/basic.zig");

pub const w = struct {
    const windows = @import("../basic/windows.zig");
    pub usingnamespace windows;
    pub usingnamespace windows.kernel32;
    pub usingnamespace windows.user32;
};

pub const platform = struct {
    pub var hinstance: w.HINSTANCE = undefined;
    pub var hwnd: w.HWND = undefined;
    pub var hdc: w.HDC = undefined;
    pub var size: [2]u16 = undefined;
    pub var mouse: [2]u16 = undefined;
};

pub export fn wWinMainCRTStartup() callconv(w.WINAPI) noreturn {
    _ = w.SetProcessDPIAware();

    w.ExitProcess(0);
}
