#include "basic/basic.h"
#include "basic/windows.h"

HINSTANCE platform_hinstance;
HWND platform_hwnd;
HDC platform_hdc;
s32 platform_width;
s32 platform_height;

#if 1
#include "renderer_opengl.c"
#define renderer_init opengl_init
#define renderer_deinit opengl_deinit
#define renderer_resize opengl_resize
#define renderer_present opengl_present
#endif

void update_cursor_clip(void) {
	ClipCursor(nil);
}

void clear_held_keys(void) {

}

void toggle_fullscreen(void) {
	static WINDOWPLACEMENT save_placement = {size_of(WINDOWPLACEMENT)};

	u32 style = cast(u32) GetWindowLongPtrW(platform_hwnd, GWL_STYLE);
	if (style & WS_OVERLAPPEDWINDOW) {
		MONITORINFO mi = {size_of(MONITORINFO)};
		GetMonitorInfoW(MonitorFromWindow(platform_hwnd, MONITOR_DEFAULTTOPRIMARY), &mi);

		GetWindowPlacement(platform_hwnd, &save_placement);
		SetWindowLongPtrW(platform_hwnd, GWL_STYLE, style & ~WS_OVERLAPPEDWINDOW);
		SetWindowPos(platform_hwnd, HWND_TOP, mi.rcMonitor.left, mi.rcMonitor.top,
			mi.rcMonitor.right - mi.rcMonitor.left, mi.rcMonitor.bottom - mi.rcMonitor.top,
			SWP_FRAMECHANGED);
	} else {
		SetWindowLongPtrW(platform_hwnd, GWL_STYLE, style | WS_OVERLAPPEDWINDOW);
		SetWindowPlacement(platform_hwnd, &save_placement);
		SetWindowPos(platform_hwnd, nil, 0, 0, 0, 0, SWP_NOMOVE |
			SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED);
	}
}

s64 WINAPI window_proc(HWND hwnd, u32 message, u64 wParam, s64 lParam) {
	switch (message) {
		case WM_PAINT:
			ValidateRect(hwnd, nil);
			return 0;
		case WM_ERASEBKGND:
			return 1;
		case WM_ACTIVATEAPP: {
			bool tabbing_in = wParam != 0;

			if (tabbing_in) update_cursor_clip();
			else clear_held_keys();
			return 0;
		}
		case WM_SIZE:
			platform_width = cast(u16) lParam;
			platform_height = cast(u16) (lParam >> 16);

			renderer_resize();
			return 0;
		case WM_CREATE: {
			platform_hwnd = hwnd;
			platform_hdc = GetDC(hwnd);

			s32 dark_mode = true;
			DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, size_of(s32));
			s32 round_mode = DWMWCP_DONOTROUND;
			DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, size_of(s32));

			renderer_init();
			return 0;
		}
		case WM_DESTROY:
			renderer_deinit();

			PostQuitMessage(0);
			return 0;
		case WM_SYSCOMMAND:
			if (wParam == SC_KEYMENU) return 0;
			fall_through;
		default:
			return DefWindowProcW(hwnd, message, wParam, lParam);
	}
}

noreturn_t WINAPI WinMainCRTStartup(void) {
	platform_hinstance = GetModuleHandleW(nil);

	WSADATA wsadata;
	bool networking_supported = WSAStartup(0x202, &wsadata);

	bool sleep_is_granular = timeBeginPeriod(1) == TIMERR_NOERROR;

	SetProcessDPIAware();
	WNDCLASSEXW wndclass;
	zero(&wndclass);
	wndclass.cbSize = size_of(WNDCLASSEXW);
	wndclass.style = CS_OWNDC;
	wndclass.lpfnWndProc = window_proc;
	wndclass.hInstance = platform_hinstance;
	wndclass.hIcon = LoadIconW(nil, IDI_WARNING);
	wndclass.hCursor = LoadCursorW(nil, IDC_CROSS);
	wndclass.lpszClassName = L"A";
	RegisterClassExW(&wndclass);
	CreateWindowExW(0, wndclass.lpszClassName, L"Asunder",
		WS_OVERLAPPEDWINDOW | WS_VISIBLE,
		CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
		nil, nil, platform_hinstance, nil);

	for (;;) {
		MSG msg;
		while (PeekMessageW(&msg, nil, 0, 0, PM_REMOVE)) {
			TranslateMessage(&msg);
			switch (msg.message) {
				case WM_KEYDOWN: fall_through;
				case WM_KEYUP: fall_through;
				case WM_SYSKEYDOWN: fall_through;
				case WM_SYSKEYUP: {
					bool pressed = (msg.lParam & (1 << 31)) == 0;
					bool repeat = pressed && (msg.lParam & (1 << 30)) != 0;
					bool sys = msg.message == WM_SYSKEYDOWN || msg.message == WM_SYSKEYUP;
					bool alt = sys && (msg.lParam & (1 << 29)) != 0;

					if (!repeat && (!sys || alt || msg.wParam == VK_MENU || msg.wParam == VK_F10)) {
						if (pressed) {
							if (msg.wParam == VK_F4 && alt) DestroyWindow(platform_hwnd);
							if (msg.wParam == VK_ESCAPE) DestroyWindow(platform_hwnd);
							if (msg.wParam == VK_RETURN && alt) toggle_fullscreen();
							if (msg.wParam == VK_F11) toggle_fullscreen();
						}
					}
					break;
				}
				case WM_QUIT:
					goto main_loop_end;
				default:
					DispatchMessageW(&msg);
			}
		}

		renderer_present();

		if (sleep_is_granular) {
			// :todo
			Sleep(1);
		}
	}
main_loop_end:

	if (networking_supported) WSACleanup();

	ExitProcess(0);
}
