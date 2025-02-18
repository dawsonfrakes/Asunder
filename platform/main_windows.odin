package main

import "../basic/windows"
import "../game"

RENDER_API :: #config(RENDER_API, "OPENGL")

platform_stdout: windows.HANDLE
platform_hinstance: windows.HINSTANCE
platform_hwnd: windows.HWND
platform_hdc: windows.HDC
platform_width: i32
platform_height: i32
platform_keys: bit_set[0..<128]
platform_mouse: [2]i16

when RENDER_API == "OPENGL" {
	renderer_init :: opengl_init
	renderer_deinit :: opengl_deinit
	renderer_resize :: opengl_resize
	renderer_present :: opengl_present
	renderer_clear :: opengl_clear
} else when RENDER_API == "NONE" {
	renderer_init :: proc "contextless" () {}
	renderer_deinit :: proc "contextless" () {}
	renderer_resize :: proc "contextless" () {}
	renderer_present :: proc "contextless" () {}
	renderer_clear :: proc(color0: [4]f32, depth: f32) {}
} else do #panic("Invalid RENDER_API")

main :: proc() {
	using windows

	if ODIN_DEBUG {
		AllocConsole()
		platform_stdout = GetStdHandle(STD_OUTPUT_HANDLE)
	}

	update_cursor_clip :: proc "contextless" () {
		ClipCursor(nil)
	}

	clear_held_keys :: proc "contextless" () {
		platform_keys = {}
	}

	toggle_fullscreen :: proc "contextless" () {
		@static save_placement := WINDOWPLACEMENT{length = size_of(WINDOWPLACEMENT)}

		style := cast(u32) GetWindowLongPtrW(platform_hwnd, GWL_STYLE)
		if style & WS_OVERLAPPEDWINDOW != 0 {
			mi := MONITORINFO{cbSize = size_of(MONITORINFO)}
			GetMonitorInfoW(MonitorFromWindow(platform_hwnd, MONITOR_DEFAULTTOPRIMARY), &mi)

			GetWindowPlacement(platform_hwnd, &save_placement)
			SetWindowLongPtrW(platform_hwnd, GWL_STYLE, cast(int) (style & ~cast(u32) WS_OVERLAPPEDWINDOW))
			SetWindowPos(platform_hwnd, HWND_TOP, mi.rcMonitor.left, mi.rcMonitor.top,
				mi.rcMonitor.right - mi.rcMonitor.left, mi.rcMonitor.bottom - mi.rcMonitor.top,
				SWP_FRAMECHANGED)
		} else {
			SetWindowLongPtrW(platform_hwnd, GWL_STYLE, cast(int) (style | WS_OVERLAPPEDWINDOW))
			SetWindowPlacement(platform_hwnd, &save_placement)
			SetWindowPos(platform_hwnd, nil, 0, 0, 0, 0, SWP_NOMOVE |
				SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED)
		}
	}

	platform_hinstance = GetModuleHandleW(nil)

	wsadata: WSADATA = ---
	networking_supported := WSAStartup(0x202, &wsadata) == 0
	defer if networking_supported do WSACleanup()

	sleep_is_granular := timeBeginPeriod(1) == TIMERR_NOERROR

	clock_frequency: i64 = ---
	QueryPerformanceFrequency(&clock_frequency)
	clock_start: i64 = ---
	QueryPerformanceCounter(&clock_start)
	clock_previous := clock_start

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

				if tabbing_in do update_cursor_clip()
				else do clear_held_keys()
			case WM_SIZE:
				platform_width = cast(i32) cast(u16) lParam
				platform_height = cast(i32) cast(u16) (lParam >> 16)

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
		platform_key_transitions: [128]u8
		platform_mouse_delta: [3]i16

		clock_frame_begin: i64 = ---
		QueryPerformanceCounter(&clock_frame_begin)

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
							if ODIN_DEBUG && wParam == VK_ESCAPE do DestroyWindow(platform_hwnd)
							if wParam == VK_RETURN && alt do toggle_fullscreen()
							if wParam == VK_F11 do toggle_fullscreen()
						}
						if pressed do platform_keys |= {cast(int) cast(u8) wParam}
						else do platform_keys &~= {cast(int) cast(u8) wParam}
						platform_key_transitions[cast(u8) wParam] += 1
					}
				case WM_MOUSEMOVE:
					x := cast(i16) lParam
					y := cast(i16) (lParam >> 16)
					platform_mouse_delta.xy += {x, y} - platform_mouse.x
					platform_mouse = {x, y}
				case WM_MOUSEWHEEL:
					z := cast(i16) (wParam >> 16)
					platform_mouse_delta.z += z if abs(z) < 120 else z / 120
				case WM_QUIT:
					break main_loop
				case:
					DispatchMessageW(&msg)
			}
		}

		clock_current: i64 = ---
		QueryPerformanceCounter(&clock_current)
		delta := cast(f32) (clock_current - clock_previous) / cast(f32) clock_frequency
		defer clock_previous = clock_current

		renderer: game.Renderer
		renderer.clear = renderer_clear
		game.update_and_render(&renderer)

		renderer_present()

		clock_frame_end: i64 = ---
		QueryPerformanceCounter(&clock_frame_end)
		if sleep_is_granular {
			ideal_frame_ms: u32 = 16

			frame_delta_ms := (clock_frame_end - clock_frame_begin) / (clock_frequency / 1000)
			if cast(i64) ideal_frame_ms > frame_delta_ms {
				Sleep(ideal_frame_ms - cast(u32) frame_delta_ms)
			}
		}
	}
}
