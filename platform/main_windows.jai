#import "Windows";
using,only(WSADATA,WSAStartup,WSACleanup) Socket :: #import "Socket";
user32 :: #library,system "user32";
IDI_WARNING :: cast(*void) 32515;
WINDOWPLACEMENT :: struct {
  length: u32;
  flags: u32;
  showCmd: u32;
  ptMinPosition: POINT;
  ptMaxPosition: POINT;
  rcNormalPosition: RECT;
  rcDevice: RECT;
}
GetWindowLongPtrW :: (hwnd: HWND, index: s32) -> s64 #foreign user32;
GetWindowPlacement :: (hwnd: HWND, placement: *WINDOWPLACEMENT) -> s32 #foreign user32;
SetWindowPlacement :: (hwnd: HWND, placement: *WINDOWPLACEMENT) -> s32 #foreign user32;
dwmapi :: #library,system "dwmapi";
DWMWA_USE_IMMERSIVE_DARK_MODE :: 20;
DWMWA_WINDOW_CORNER_PREFERENCE :: 33;
DWMWCP_DONOTROUND :: 1;
DwmSetWindowAttribute :: (hwnd: HWND, attribute: u32, data: *void, size: u32) -> s32 #foreign dwmapi;

platform_hinstance: HINSTANCE;
platform_hwnd: HWND;
platform_hdc: HDC;
platform_size: [2]u16;
platform_mouse: [2]u16;
platform_keys: [256]bool;
platform_save_placement := WINDOWPLACEMENT.{length = size_of(WINDOWPLACEMENT)};

main :: () {
	update_cursor_clip :: () #no_context {
		ClipCursor(null);
	}

	clear_held_keys :: () #no_context {
		memset(platform_keys.data, 0, size_of(type_of(platform_keys)));
	}

	toggle_fullscreen :: () #no_context {
		style := cast(u32) GetWindowLongPtrW(platform_hwnd, GWL_STYLE);
		if style & WS_OVERLAPPEDWINDOW {
			mi := MONITORINFO.{cbSize = size_of(MONITORINFO)};
			GetMonitorInfoW(MonitorFromWindow(platform_hwnd, MONITOR_DEFAULTTOPRIMARY), *mi);

			GetWindowPlacement(platform_hwnd, *platform_save_placement);
			SetWindowLongPtrW(platform_hwnd, GWL_STYLE, style & ~WS_OVERLAPPEDWINDOW);
			SetWindowPos(platform_hwnd, HWND_TOP, mi.rcMonitor.left, mi.rcMonitor.top,
				mi.rcMonitor.right - mi.rcMonitor.left, mi.rcMonitor.bottom - mi.rcMonitor.top,
				SWP_FRAMECHANGED);
		} else {
			SetWindowLongPtrW(platform_hwnd, GWL_STYLE, style | WS_OVERLAPPEDWINDOW);
			SetWindowPlacement(platform_hwnd, *platform_save_placement);
			SetWindowPos(platform_hwnd, null, 0, 0, 0, 0, SWP_NOMOVE |
				SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED);
		}
	}

	platform_hinstance = GetModuleHandleW(null);

	wsadata: WSADATA = ---;
	networking_supported := WSAStartup(0x202, *wsadata);
	defer if networking_supported WSACleanup();

	sleep_is_granular := timeBeginPeriod(1) == TIMERR_NOERROR;

	SetProcessDPIAware();
	wndclass: WNDCLASSEXW;
	wndclass.cbSize = size_of(WNDCLASSEXW);
	wndclass.style = CS_OWNDC;
	wndclass.lpfnWndProc = xx (hwnd: HWND, message: u32, wParam: u64, lParam: s64) -> s64 #c_call {
		if message == {
			case WM_PAINT;
				ValidateRect(platform_hwnd, null);
			case WM_ERASEBKGND;
				return 1;
			case WM_ACTIVATEAPP;
				tabbing_in := wParam != 0;
				if tabbing_in update_cursor_clip();
				else clear_held_keys();
			case WM_SIZE;
				x := cast,no_check(u16) lParam;
				y := cast,no_check(u16) (lParam >> 16);
				platform_size = .[x, y];
			case WM_CREATE;
				platform_hwnd = hwnd;
				platform_hdc = GetDC(hwnd);

				dark_mode: s32 = xx true;
				DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, *dark_mode, size_of(s32));
				round_mode: s32 = DWMWCP_DONOTROUND;
				DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, *round_mode, size_of(s32));
			case WM_DESTROY;
				PostQuitMessage(0);
			case WM_SYSCOMMAND;
				if wParam == SC_KEYMENU return 0;
				#through;
			case;
				return DefWindowProcW(hwnd, message, wParam, lParam);
		}
		return 0;
	};
	wndclass.hInstance = platform_hinstance;
	wndclass.hIcon = LoadIconW(xx null, IDI_WARNING);
	wndclass.hCursor = LoadCursorW(xx null, IDC_CROSS);
	wndclass.lpszClassName = u16.[#char "A", 0].data;
	RegisterClassExW(*wndclass);
	CreateWindowExW(0, wndclass.lpszClassName, u16.[#char "A", #char "s", #char "u", #char "n", #char "d", #char "e", #char "r", 0].data,
		WS_OVERLAPPEDWINDOW | WS_VISIBLE,
		CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
		xx null, xx null, platform_hinstance, null);

	while main_loop := true {
		msg: MSG = ---;
		while PeekMessageW(*msg, xx null, 0, 0, PM_REMOVE) {
			using msg;
			TranslateMessage(*msg);
			if message == {
				case WM_KEYDOWN; #through;
				case WM_KEYUP; #through;
				case WM_SYSKEYDOWN; #through;
				case WM_SYSKEYUP;
					pressed := lParam & (1 << 31) == 0;
					repeat := pressed && lParam & (1 << 30) != 0;
					sys := message == WM_SYSKEYDOWN || message == WM_SYSKEYUP;
					alt := sys && lParam & (1 << 29) != 0;

					if !repeat && (!sys || alt || wParam == VK_MENU || wParam == VK_F10) {
						if pressed {
							if wParam == VK_F4 && alt DestroyWindow(platform_hwnd);
							if DEBUG && wParam == VK_ESCAPE DestroyWindow(platform_hwnd);
							if wParam == VK_RETURN && alt toggle_fullscreen();
							if wParam == VK_F11 toggle_fullscreen();
						}
					}
				case WM_QUIT;
					break main_loop;
				case;
					DispatchMessageW(*msg);
			}
		}

		if sleep_is_granular {
			Sleep(1);
		}
	}
}
