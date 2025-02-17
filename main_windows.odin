package main

#assert(ODIN_NO_CRT, "Please provide -no-crt in your build line.");
#assert(ODIN_NO_ENTRY_POINT, "Please provide -no-entry-point in your build line.");

import "basic/windows"

platform_hinstance: windows.HINSTANCE
platform_hwnd: windows.HWND
platform_hdc: windows.HDC
platform_width: int
platform_height: int

when true {
	renderer_init :: opengl_init
	renderer_deinit :: opengl_deinit
	renderer_resize :: opengl_resize
	renderer_present :: opengl_present
}

entry :: proc() {
	using windows

	update_cursor_clip :: proc "contextless" () {
		ClipCursor(nil)
	}

	clear_held_keys :: proc "contextless" () {

	}

	toggle_fullscreen :: proc "contextless" () {
		@static save_placement := WINDOWPLACEMENT{length = size_of(WINDOWPLACEMENT)}

		style := cast(u32) GetWindowLongPtrW(platform_hwnd, GWL_STYLE)
		if style & WS_OVERLAPPEDWINDOW != 0 {
			mi := MONITORINFO{cbSize = size_of(MONITORINFO)}
			GetMonitorInfoW(MonitorFromWindow(platform_hwnd, MONITOR_DEFAULTTOPRIMARY), &mi)

			GetWindowPlacement(platform_hwnd, &save_placement)
			SetWindowLongPtrW(platform_hwnd, GWL_STYLE, int(style & ~cast(u32) WS_OVERLAPPEDWINDOW))
			SetWindowPos(platform_hwnd, HWND_TOP, mi.rcMonitor.left, mi.rcMonitor.top,
				mi.rcMonitor.right - mi.rcMonitor.left, mi.rcMonitor.bottom - mi.rcMonitor.top,
				SWP_FRAMECHANGED)
		} else {
			SetWindowLongPtrW(platform_hwnd, GWL_STYLE, int(style | WS_OVERLAPPEDWINDOW))
			SetWindowPlacement(platform_hwnd, &save_placement)
			SetWindowPos(platform_hwnd, nil, 0, 0, 0, 0, SWP_NOMOVE |
				SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED)
		}
	}

	platform_hinstance = GetModuleHandleW(nil)

	sleep_is_granular := timeBeginPeriod(1) == TIMERR_NOERROR

	SetProcessDPIAware()
	wndclass: WNDCLASSEXW
	wndclass.cbSize = size_of(WNDCLASSEXW)
	wndclass.style = CS_OWNDC
	wndclass.lpfnWndProc = proc "std" (hwnd: HWND, message: u32, wParam: uintptr, lParam: int) -> int {
		switch message {
			case WM_PAINT:
				ValidateRect(hwnd, nil)
			case WM_ERASEBKGND:
				return 1
			case WM_ACTIVATEAPP:
				tabbing_in := wParam != 0

				if tabbing_in { update_cursor_clip() }
				else { clear_held_keys() }
			case WM_SIZE:
				platform_width = cast(int) cast(u16) lParam
				platform_height = cast(int) cast(u16) (lParam >> 16)

				renderer_resize()
			case WM_CREATE:
				platform_hwnd = hwnd
				platform_hdc = GetDC(hwnd)

				dark_mode: i32 = 1
				DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, size_of(type_of(dark_mode)))
				round_mode: i32 = DWMWCP_DONOTROUND
				DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, size_of(type_of(round_mode)))

				renderer_init()
			case WM_DESTROY:
				renderer_deinit()

				PostQuitMessage(0)
			case WM_SYSCOMMAND:
				if wParam == SC_KEYMENU do return 0
				fallthrough
			case:
				return DefWindowProcW(hwnd, message, wParam, lParam)
		}
		return 0
	}
	wndclass.hInstance = platform_hinstance
	wndclass.hIcon = LoadIconW(nil, IDI_WARNING)
	wndclass.hCursor = LoadCursorW(nil, IDC_CROSS)
	wndclass.lpszClassName = raw_data([]u16{'A', 0})
	RegisterClassExW(&wndclass)
	CreateWindowExW(0, wndclass.lpszClassName, raw_data([]u16{'A', 's', 'u', 'n', 'd', 'e', 'r', 0}),
		WS_OVERLAPPEDWINDOW | WS_VISIBLE,
		CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
		nil, nil, platform_hinstance, nil)

	main_loop: for {
		msg: MSG = ---
		for PeekMessageW(&msg, nil, 0, 0, PM_REMOVE) != 0 {
			using msg
			TranslateMessage(&msg)
			switch message {
				case WM_KEYDOWN: fallthrough
				case WM_KEYUP: fallthrough
				case WM_SYSKEYDOWN: fallthrough
				case WM_SYSKEYUP:
					pressed := lParam & (1 << 31) == 0
					repeat := pressed && lParam & (1 << 30) != 0
					sys := message == WM_SYSKEYDOWN || message == WM_SYSKEYUP
					alt := sys && lParam & (1 << 29) != 0

					if !repeat && (!sys || alt || wParam == VK_MENU || wParam == VK_F10) {
						if pressed {
							if wParam == VK_F4 && alt do DestroyWindow(platform_hwnd)
							if wParam == VK_ESCAPE do DestroyWindow(platform_hwnd)
							if wParam == VK_RETURN && alt do toggle_fullscreen()
							if wParam == VK_F11 do toggle_fullscreen()
						}
					}
				case WM_QUIT:
					break main_loop
				case:
					DispatchMessageW(&msg)
			}
		}

		renderer_present()

		if sleep_is_granular {
			// :todo
			Sleep(1)
		}
	}
}

@(link_name="mainCRTStartup", linkage="strong", require)
mainCRTStartup :: proc "std" () {
	context = {}
	entry()
	windows.ExitProcess(0)
}
