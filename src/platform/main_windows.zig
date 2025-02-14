const core = @import("../modules/core.zig");

pub const w = struct {
    const windows = @import("../modules/windows.zig");
    pub usingnamespace windows;
    pub usingnamespace windows.kernel32;
    pub usingnamespace windows.user32;
    pub usingnamespace windows.ws2_32;
    pub usingnamespace windows.dwmapi;
    pub usingnamespace windows.winmm;
};

pub const platform = struct {
    pub var hinstance: w.HINSTANCE = undefined;
    pub var hwnd: w.HWND = undefined;
    pub var hdc: w.HDC = undefined;
    pub var width: i32 = undefined;
    pub var height: i32 = undefined;
};

const RenderAPI = enum { none, vulkan };
const render_api = RenderAPI.vulkan;
const renderer = switch (render_api) {
    .none => @compileError("You want to show nothing? Done!"),
    .vulkan => @import("vulkan_renderer.zig"),
};

fn updateCursorClip() void {
    _ = w.ClipCursor(null);
}

fn clearHeldKeys() void {}

fn toggleFullscreen() void {
    const S = struct {
        var placement = core.zeroInit(w.WINDOWPLACEMENT, .{ .length = @sizeOf(w.WINDOWPLACEMENT) });
    };

    const style = w.GetWindowLongPtrW(platform.hwnd, w.GWL_STYLE);
    if (style & w.WS_OVERLAPPEDWINDOW != 0) {
        var mi = core.zeroInit(w.MONITORINFO, .{ .cbSize = @sizeOf(w.MONITORINFO) });
        _ = w.GetMonitorInfoW(w.MonitorFromWindow(platform.hwnd, w.MONITOR_DEFAULTTOPRIMARY).?, &mi);

        _ = w.GetWindowPlacement(platform.hwnd, &S.placement);
        _ = w.SetWindowLongPtrW(platform.hwnd, w.GWL_STYLE, style & ~@as(c_ulong, w.WS_OVERLAPPEDWINDOW));
        _ = w.SetWindowPos(
            platform.hwnd,
            w.HWND_TOP,
            mi.rcMonitor.left,
            mi.rcMonitor.top,
            mi.rcMonitor.right - mi.rcMonitor.left,
            mi.rcMonitor.bottom - mi.rcMonitor.top,
            w.SWP_FRAMECHANGED,
        );
    } else {
        _ = w.SetWindowLongPtrW(platform.hwnd, w.GWL_STYLE, style | w.WS_OVERLAPPEDWINDOW);
        _ = w.SetWindowPlacement(platform.hwnd, &S.placement);
        _ = w.SetWindowPos(
            platform.hwnd,
            null,
            0,
            0,
            0,
            0,
            w.SWP_NOMOVE | w.SWP_NOSIZE | w.SWP_NOZORDER | w.SWP_FRAMECHANGED,
        );
    }
}

fn windowProc(hwnd: ?w.HWND, message: c_uint, wParam: usize, lParam: isize) callconv(.winapi) isize {
    switch (message) {
        w.WM_PAINT => _ = w.ValidateRect(hwnd, null),
        w.WM_ERASEBKGND => return 1,
        w.WM_ACTIVATEAPP => if (wParam != 0) updateCursorClip() else clearHeldKeys(),
        w.WM_SIZE => {
            platform.width = @as(u16, @truncate(@as(usize, @bitCast(lParam))));
            platform.height = @as(u16, @truncate(@as(usize, @bitCast(lParam)) >> 16));

            renderer.resize();
        },
        w.WM_CREATE => {
            platform.hwnd = hwnd.?;
            platform.hdc = w.GetDC(hwnd).?;

            const dark_mode: c_int = @intFromBool(true);
            _ = w.DwmSetWindowAttribute(hwnd, w.DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, @sizeOf(@TypeOf(dark_mode)));
            const round_mode: c_int = w.DWMWCP_DONOTROUND;
            _ = w.DwmSetWindowAttribute(hwnd, w.DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, @sizeOf(@TypeOf(round_mode)));

            renderer.init();
        },
        w.WM_DESTROY => {
            renderer.deinit();

            w.PostQuitMessage(0);
        },
        w.WM_SYSCOMMAND => {
            if (wParam == w.SC_KEYMENU) return 0;
            return w.DefWindowProcW(hwnd, message, wParam, lParam);
        },
        else => return w.DefWindowProcW(hwnd, message, wParam, lParam),
    }
    return 0;
}

fn entry() void {
    platform.hinstance = w.GetModuleHandleW(null).?;

    var wsadata: w.WSADATA = undefined;
    const networking_supported = w.WSAStartup(0x202, &wsadata) == 0;
    defer {
        if (networking_supported) _ = w.WSACleanup();
    }

    const sleep_is_granular = w.timeBeginPeriod(1) == w.TIMERR_NOERROR;

    _ = w.SetProcessDPIAware();
    var wndclass = core.zeroes(w.WNDCLASSEXW);
    wndclass.cbSize = @sizeOf(w.WNDCLASSEXW);
    wndclass.style = w.CS_OWNDC;
    wndclass.lpfnWndProc = windowProc;
    wndclass.hInstance = platform.hinstance;
    wndclass.hIcon = w.LoadIconW(null, w.IDI_WARNING).?;
    wndclass.hCursor = w.LoadCursorW(null, w.IDC_CROSS).?;
    wndclass.lpszClassName = &core.asciiToUtf16LeStringLiteral("A");
    _ = w.RegisterClassExW(&wndclass);
    _ = w.CreateWindowExW(
        0,
        wndclass.lpszClassName,
        &core.asciiToUtf16LeStringLiteral("Asunder"),
        w.WS_OVERLAPPEDWINDOW | w.WS_VISIBLE,
        w.CW_USEDEFAULT,
        w.CW_USEDEFAULT,
        w.CW_USEDEFAULT,
        w.CW_USEDEFAULT,
        null,
        null,
        platform.hinstance,
        null,
    ).?;

    main_loop: while (true) {
        var msg: w.MSG = undefined;
        while (w.PeekMessageW(&msg, null, 0, 0, w.PM_REMOVE) != 0) {
            _ = w.TranslateMessage(&msg);
            switch (msg.message) {
                w.WM_KEYDOWN, w.WM_KEYUP, w.WM_SYSKEYDOWN, w.WM_SYSKEYUP => {
                    const pressed = msg.lParam & (1 << 31) == 0;
                    const repeat = pressed and msg.lParam & (1 << 30) != 0;
                    const sys = msg.message == w.WM_SYSKEYDOWN or msg.message == w.WM_SYSKEYUP;
                    const alt = sys and msg.lParam & (1 << 29) != 0;

                    if (!repeat and (!sys or alt or msg.wParam == w.VK_MENU or msg.wParam == w.VK_F10)) {
                        if (pressed) {
                            if (msg.wParam == w.VK_F4 and alt) _ = w.DestroyWindow(platform.hwnd);
                            if (msg.wParam == w.VK_ESCAPE) _ = w.DestroyWindow(platform.hwnd);
                            if (msg.wParam == w.VK_RETURN and alt) toggleFullscreen();
                            if (msg.wParam == w.VK_F11) toggleFullscreen();
                        }
                    }
                },
                w.WM_QUIT => break :main_loop,
                else => _ = w.DispatchMessageW(&msg),
            }
        }

        renderer.present();

        if (sleep_is_granular) {
            w.Sleep(1);
        }
    }
}

pub export fn WinMainCRTStartup() callconv(.winapi) noreturn {
    entry();
    w.ExitProcess(0);
}
