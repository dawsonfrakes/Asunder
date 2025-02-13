#import "Asunder_Basic";
#import "Asunder_Windows";

ascii_to_utf16lez :: (s: string, allocator := context.allocator) -> []u16 {
	utf16le: [256]u16;
	for s utf16le[it_index] = it;
	utf16le[s.count] = 0;

	return slice(utf16le, 0, s.count + 1);
}

platform_hinstance: HINSTANCE;
platform_hwnd: HWND;
platform_hdc: HDC;
platform_width: s32;
platform_height: s32;

update_cursor_clip :: () #no_context {
	ClipCursor(null);
}

clear_held_keys :: () #no_context {

}

toggle_fullscreen_save_placement := WINDOWPLACEMENT.{length = size_of(WINDOWPLACEMENT)};
toggle_fullscreen :: () #no_context {
	style := GetWindowLongPtrW(platform_hwnd, GWL_STYLE);
	if style & WS_OVERLAPPEDWINDOW {
		mi := MONITORINFO.{cbSize = size_of(MONITORINFO)};
		GetMonitorInfoW(MonitorFromWindow(platform_hwnd, MONITOR_DEFAULTTOPRIMARY), *mi);

		GetWindowPlacement(platform_hwnd, *toggle_fullscreen_save_placement);
		SetWindowLongPtrW(platform_hwnd, GWL_STYLE, style & ~WS_OVERLAPPEDWINDOW);
		SetWindowPos(platform_hwnd, HWND_TOP, mi.rcMonitor.left, mi.rcMonitor.top,
			mi.rcMonitor.bottom - mi.rcMonitor.left, mi.rcMonitor.bottom - mi.rcMonitor.top,
			SWP_FRAMECHANGED);
	} else {
		SetWindowLongPtrW(platform_hwnd, GWL_STYLE, style | WS_OVERLAPPEDWINDOW);
		SetWindowPlacement(platform_hwnd, *toggle_fullscreen_save_placement);
		SetWindowPos(platform_hwnd, xx null, 0, 0, 0, 0, SWP_NOMOVE |
			SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED);
	}
}

main :: () {
	platform_hinstance = GetModuleHandleW(null);

	wsadata: WSADATA;
	networking_supported := WSAStartup(0x202, *wsadata) == 0;
	defer if networking_supported WSACleanup();

	sleep_is_granular := timeBeginPeriod(1) == TIMERR_NOERROR;

	SetProcessDPIAware();
	wndclass: WNDCLASSEXW;
	wndclass.cbSize = size_of(WNDCLASSEXW);
	wndclass.style = CS_OWNDC;
	wndclass.lpfnWndProc = (hwnd: HWND, message: u32, wParam: u64, lParam: s64) -> s64 #c_call {
		if message == {
			case WM_PAINT;
				ValidateRect(hwnd, null);
			case WM_ERASEBKGND;
				return 1;
			case WM_ACTIVATEAPP;
				tabbing_in := wParam != 0;

				if tabbing_in update_cursor_clip();
				else clear_held_keys();
			case WM_SIZE;
				platform_width = cast,no_check(u16) lParam;
				platform_height = cast,no_check(u16) (lParam >> 16);
			case WM_CREATE;
				platform_hwnd = hwnd;
				platform_hdc = GetDC(hwnd);

				dark_mode: s32 = xx true;
				DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, *dark_mode, size_of(type_of(dark_mode)));
				round_mode: s32 = DWMWCP_DONOTROUND;
				DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, *round_mode, size_of(type_of(round_mode)));
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
	wndclass.lpszClassName = (#run ascii_to_utf16lez("A")).data;
	RegisterClassExW(*wndclass);
	CreateWindowExW(0, wndclass.lpszClassName, (#run ascii_to_utf16lez("Asunder")).data,
		WS_OVERLAPPEDWINDOW | WS_VISIBLE,
		CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
		xx null, xx null, platform_hinstance, null);

	while main_loop := true {
		msg: MSG = ---;
		while PeekMessageW(*msg, xx null, 0, 0, PM_REMOVE) {
			using msg;
			TranslateMessage(*msg);
			if message == {
				case WM_QUIT;
					break main_loop;
				case;
					DispatchMessageW(*msg);
			}
		}

		if sleep_is_granular {
			// :todo
			Sleep(1);
		}
	}
}
