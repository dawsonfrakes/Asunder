#include "../game/game.c"
#include "../basic/windows.h"

#define RENDER_API_NONE 0
#define RENDER_API_OPENGL 1

#if !defined(RENDER_API)
#define RENDER_API RENDER_API_OPENGL
#endif

#define X(RET, NAME, ...) RET WINAPI NAME(__VA_ARGS__);
KERNEL32_FUNCTIONS
#undef X
#define X(RET, NAME, ...) RET (WINAPI *NAME)(__VA_ARGS__);
USER32_FUNCTIONS
#if RENDER_API == RENDER_API_OPENGL
GDI32_FUNCTIONS
OPENGL32_FUNCTIONS
#endif
WS2_32_FUNCTIONS
DWMAPI_FUNCTIONS
WINMM_FUNCTIONS
#undef X

HANDLE platform_stdout;
HINSTANCE platform_hinstance;
HWND platform_hwnd;
HDC platform_hdc;
sint platform_width;
sint platform_height;
sint platform_mouse_x;
sint platform_mouse_y;

void print_console(string fmt, ...) {
	va_list ap;
	va_start(ap, fmt);
	for (sint i = 0; i < fmt.count; i += 1) {
		if (fmt.data[i] == '%') {
			if (i + 1 >= fmt.count || fmt.data[i + 1] != '%') {
				string arg = va_arg(ap, string);
				WriteFile(platform_stdout, arg.data, cast(u32) arg.count, null, null);
				continue;
			}
			i += 1;
		}
		WriteFile(platform_stdout, &fmt.data[i], 1, null, null);
	}
	va_end(ap);
}

#if RENDER_API == RENDER_API_NONE
void renderer_none(void) {}
#define renderer_init renderer_none
#define renderer_deinit renderer_none
#define renderer_resize renderer_none
#define renderer_present renderer_none
void renderer_clear(f32 color0[4], f32 depth) { (void) color0; (void) depth; }
#elif RENDER_API == RENDER_API_OPENGL
#include "renderer_opengl.c"
#define renderer_init opengl_init
#define renderer_deinit opengl_deinit
#define renderer_resize opengl_resize
#define renderer_present opengl_present
#define renderer_clear opengl_clear
#endif

void update_cursor_clip(void) {
	ClipCursor(null);
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
		SetWindowLongPtrW(platform_hwnd, GWL_STYLE, style & ~cast(u32) WS_OVERLAPPEDWINDOW);
		SetWindowPos(platform_hwnd, HWND_TOP, mi.rcMonitor.left, mi.rcMonitor.top,
			mi.rcMonitor.right - mi.rcMonitor.left, mi.rcMonitor.bottom - mi.rcMonitor.left,
			SWP_FRAMECHANGED);
	} else {
		SetWindowLongPtrW(platform_hwnd, GWL_STYLE, style | WS_OVERLAPPEDWINDOW);
		SetWindowPlacement(platform_hwnd, &save_placement);
		SetWindowPos(platform_hwnd, null, 0, 0, 0, 0, SWP_NOMOVE |
			SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED);
	}
}

sint WINAPI window_proc(HWND hwnd, u32 message, uint wParam, sint lParam) {
	switch (message) {
		case WM_PAINT:
			ValidateRect(hwnd, null);
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
		case WM_CREATE:
			platform_hwnd = hwnd;
			platform_hdc = GetDC(hwnd);

			if (DwmSetWindowAttribute) {
				b32 dark_mode = true;
				DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, 4);
				s32 round_mode = DWMWCP_DONOTROUND;
				DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, 4);
			}

			renderer_init();
			return 0;
		case WM_DESTROY:
			renderer_deinit();

			PostQuitMessage(0);
			return 0;
		case WM_SYSCOMMAND:
			if (wParam == SC_KEYMENU) return 0;
			fallthrough;
		default:
			return DefWindowProcW(hwnd, message, wParam, lParam);
	}
}

noreturn_def WINAPI WinMainCRTStartup(void) {
	#define X(RET, NAME, ...) NAME = cast(RET (WINAPI *)(__VA_ARGS__)) GetProcAddress(lib, #NAME);
	HMODULE lib = LoadLibraryW(L"USER32.DLL");
	USER32_FUNCTIONS
	#if RENDER_API == RENDER_API_OPENGL
	lib = LoadLibraryW(L"GDI32.DLL");
	GDI32_FUNCTIONS
	lib = LoadLibraryW(L"OPENGL32.DLL");
	OPENGL32_FUNCTIONS
	#endif
	lib = LoadLibraryW(L"WS2_32.DLL");
	WS2_32_FUNCTIONS
	lib = LoadLibraryW(L"DWMAPI.DLL");
	DWMAPI_FUNCTIONS
	lib = LoadLibraryW(L"WINMM.DLL");
	WINMM_FUNCTIONS
	#undef X

	if (DEBUG) {
		AllocConsole();
		platform_stdout = GetStdHandle(STD_OUTPUT_HANDLE);
	}

	platform_hinstance = GetModuleHandleW(null);

	WSADATA wsadata;
	bool networking_supported = WSAStartup && WSAStartup(0x202, &wsadata) == 0;

	bool sleep_is_granular = timeBeginPeriod && timeBeginPeriod(1) == TIMERR_NOERROR;

	s64 clock_frequency;
	QueryPerformanceFrequency(&clock_frequency);
	s64 clock_start;
	QueryPerformanceCounter(&clock_start);
	s64 clock_previous = clock_start;

	SetProcessDPIAware();
	WNDCLASSEXW wndclass;
	zero(&wndclass);
	wndclass.cbSize = size_of(WNDCLASSEXW);
	wndclass.style = CS_OWNDC;
	wndclass.lpfnWndProc = window_proc;
	wndclass.hInstance = platform_hinstance;
	wndclass.hIcon = LoadIconW(null, IDI_WARNING);
	wndclass.hCursor = LoadCursorW(null, IDC_CROSS);
	wndclass.lpszClassName = L"A";
	RegisterClassExW(&wndclass);
	CreateWindowExW(0, wndclass.lpszClassName, L"Asunder",
		WS_OVERLAPPEDWINDOW | WS_VISIBLE,
		CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
		null, null, platform_hinstance, null);

	for (;;) {
		s64 clock_frame_start;
		QueryPerformanceCounter(&clock_frame_start);

		MSG msg;
		while (PeekMessageW(&msg, null, 0, 0, PM_REMOVE)) {
			TranslateMessage(&msg);
			switch (msg.message) {
				case WM_KEYDOWN: fallthrough;
				case WM_KEYUP: fallthrough;
				case WM_SYSKEYDOWN: fallthrough;
				case WM_SYSKEYUP: {
					bool pressed = (msg.lParam & (1 << 31)) == 0;
					bool repeat = pressed && (msg.lParam & (1 << 30)) != 0;
					bool sys = msg.message == WM_SYSKEYDOWN || msg.message == WM_SYSKEYUP;
					bool alt = sys && (msg.lParam & (1 << 29)) != 0;

					if (!repeat && (!sys || alt || msg.wParam == VK_MENU || msg.wParam == VK_F10)) {
						if (pressed) {
							if (msg.wParam == VK_F4 && alt) DestroyWindow(platform_hwnd);
							if (DEBUG && msg.wParam == VK_ESCAPE) DestroyWindow(platform_hwnd);
							if (msg.wParam == VK_RETURN && alt) toggle_fullscreen();
							if (msg.wParam == VK_F11) toggle_fullscreen();
						}
					}
					break;
				}
				case WM_MOUSEMOVE: {
					s16 x = cast(s16) msg.lParam;
					s16 y = cast(s16) (msg.lParam >> 16);
					platform_mouse_x = x;
					platform_mouse_y = y;
					break;
				}
				case WM_QUIT:
					goto main_loop_end;
				default:
					DispatchMessageW(&msg);
			}
		}

		s64 clock_current;
		QueryPerformanceCounter(&clock_current);
		f32 delta = cast(f32) (clock_current - clock_previous) / clock_frequency;

		Game_Input game_input;
		zero(&game_input);
		game_input.delta = delta;
		game_input.width = platform_width;
		game_input.height = platform_height;
		game_input.mouse_x = platform_mouse_x;
		game_input.mouse_y = platform_height - 1 - platform_mouse_y;
		Game_Renderer game_renderer;
		zero(&game_renderer);
		game_renderer.clear = renderer_clear;
		game_update_and_render(&game_input, &game_renderer);

		renderer_present();

		s64 clock_frame_end;
		QueryPerformanceCounter(&clock_frame_end);

		if (sleep_is_granular) {
			s64 ideal_ms = 7;

			s64 frame_ms = (clock_frame_end - clock_frame_start) / (clock_frequency / 1000);
			if (ideal_ms > frame_ms) {
				Sleep(cast(u32) (ideal_ms - frame_ms));
			}
		}

		clock_previous = clock_current;
	}
main_loop_end:

	if (networking_supported) WSACleanup();

	ExitProcess(0);
}

sint _fltused = 0;
