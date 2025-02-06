#include "../modules/basic.h"
#include "../game/game.h"

#define RENDER_API_NONE 0
#define RENDER_API_OPENGL 1

#if !defined(RENDER_API)
#define RENDER_API RENDER_API_OPENGL
#endif

#define WIN32_LEAN_AND_MEAN
#define UNICODE
#define NOMINMAX
#define _CRT_SECURE_NO_WARNINGS
#include <Windows.h>
#include <Winsock2.h>
#include <Dwmapi.h>
#include <mmsystem.h>

HINSTANCE platform_hinstance;
HWND platform_hwnd;
HDC platform_hdc;
s32 platform_width;
s32 platform_height;
v2s platform_mouse;
bool platform_lmb;
bool platform_keys[256];
GameRenderCommand platform_commands_arena_backing[1024];

string platform_read_entire_file(string filename, Arena* arena) {
	string result = {0};
	HANDLE file = CreateFileA(filename.data, GENERIC_READ, 0, null, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, null);
	if (file != INVALID_HANDLE_VALUE) {
		LARGE_INTEGER size;
		GetFileSizeEx(file, &size);
		u8* buffer = cast(u8*) arena_alloc(arena, size.QuadPart + 1);
		unsigned long nwritten;
		ReadFile(file, buffer, cast(u32) size.QuadPart, &nwritten, null);
		buffer[nwritten] = 0;
		result = (string) {nwritten, buffer};
		CloseHandle(file);
	}
	return result;
}

#if RENDER_API == RENDER_API_OPENGL
#include "renderer_opengl.c"
#define renderer_init opengl_init
#define renderer_deinit opengl_deinit
#define renderer_resize opengl_resize
#define renderer_present opengl_present
#endif

void platform_update_cursor_clip(void) {
	ClipCursor(null); // :todo
}

void platform_clear_held_keys(void) {

}

void platform_toggle_fullscreen(void) {
	static WINDOWPLACEMENT save_placement = {size_of(WINDOWPLACEMENT)};

	s64 style = GetWindowLongPtrW(platform_hwnd, GWL_STYLE);
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
		SetWindowPos(platform_hwnd, null, 0, 0, 0, 0, SWP_NOMOVE |
			SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED);
	}
}

s64 WINAPI platform_window_proc(HWND hwnd, u32 message, u64 wParam, s64 lParam) {
	switch (message) {
		case WM_PAINT:
			ValidateRect(hwnd, null);
			return 0;
		case WM_ERASEBKGND:
			return 1;
		case WM_ACTIVATEAPP:
			bool tabbing_in = wParam != 0;

			if (tabbing_in) platform_update_cursor_clip();
			else platform_clear_held_keys();
			return 0;
		case WM_SIZE:
			platform_width = cast(u16) lParam;
			platform_height = cast(u16) (lParam >> 16);

			renderer_resize();
			return 0;
		case WM_CREATE:
			platform_hwnd = hwnd;
			platform_hdc = GetDC(hwnd);

			s32 dark_mode = true;
			DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, size_of(s32));
			s32 round_mode = DWMWCP_DONOTROUND;
			DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, size_of(s32));

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
	s64 game_memory_backing_size = 1024 * 1024 * 1024;
	void* game_memory_backing = VirtualAlloc(0, game_memory_backing_size, MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);
	if (game_memory_backing == null) ExitProcess(1);

	platform_hinstance = GetModuleHandleW(null);

	bool sleep_is_granular = timeBeginPeriod(1) == TIMERR_NOERROR;
	LARGE_INTEGER clock_frequency;
	QueryPerformanceFrequency(&clock_frequency);
	LARGE_INTEGER clock_start;
	QueryPerformanceCounter(&clock_start);
	LARGE_INTEGER clock_previous = clock_start;

	SetProcessDPIAware();
	WNDCLASSEXW wndclass = {0};
	wndclass.cbSize = size_of(WNDCLASSEXW);
	wndclass.style = CS_OWNDC;
	wndclass.lpfnWndProc = platform_window_proc;
	wndclass.hInstance = platform_hinstance;
	wndclass.hIcon = LoadIconW(null, IDI_WARNING);
	wndclass.hCursor = LoadCursorW(null, IDC_CROSS);
	wndclass.lpszClassName = L"A";
	RegisterClassExW(&wndclass);
	CreateWindowExW(0, wndclass.lpszClassName, L"Z1X1",
		WS_OVERLAPPEDWINDOW | WS_VISIBLE,
		CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
		null, null, platform_hinstance, null);

	for (;;) {
		LARGE_INTEGER clock_frame_begin;
		QueryPerformanceCounter(&clock_frame_begin);

		MSG msg;
		while (PeekMessageW(&msg, null, 0, 0, PM_REMOVE)) {
			TranslateMessage(&msg);
			switch (msg.message) {
				case WM_MOUSEMOVE:
					s32 x = cast(s16) msg.lParam;
					s32 y = cast(s16) (msg.lParam >> 16);
					platform_mouse = (v2s) {x, y};
					break;
				case WM_LBUTTONDOWN: fallthrough;
				case WM_LBUTTONUP:
					platform_lmb = msg.message == WM_LBUTTONDOWN;
					break;
				case WM_KEYDOWN: fallthrough;
				case WM_KEYUP: fallthrough;
				case WM_SYSKEYDOWN: fallthrough;
				case WM_SYSKEYUP:
					bool pressed = (msg.lParam & (1 << 31)) == 0;
					bool repeat = pressed && (msg.lParam & (1 << 30)) != 0;
					bool sys = msg.message == WM_SYSKEYDOWN || msg.message == WM_SYSKEYUP;
					bool alt = sys && (msg.lParam & (1 << 29)) != 0;

					if (!repeat && (!sys || alt || msg.wParam == VK_MENU || msg.wParam == VK_F10)) {
						if (pressed) {
							if (msg.wParam == VK_F4 && alt) DestroyWindow(platform_hwnd);
							if (msg.wParam == VK_ESCAPE) DestroyWindow(platform_hwnd);
							if (msg.wParam == VK_F11) platform_toggle_fullscreen();
							if (msg.wParam == VK_RETURN && alt) platform_toggle_fullscreen();
						}
						platform_keys[msg.wParam] = pressed;
					}
					break;
				case WM_QUIT:
					goto main_loop_end;
				default:
					DispatchMessageW(&msg);
			}
		}

		LARGE_INTEGER clock_current;
		QueryPerformanceCounter(&clock_current);

		f32 delta = cast(f32) (clock_current.QuadPart - clock_previous.QuadPart) / cast(f32) clock_frequency.QuadPart;
		clock_previous = clock_current;

		GameInput game_input = {0};
		game_input.delta = delta;
		game_input.width = platform_width;
		game_input.height = platform_height;
		game_input.mouse = (v2) {cast(f32) platform_mouse.x, cast(f32) (platform_height - 1 - platform_mouse.y)};
		game_input.lmb = platform_lmb;
		game_input.keys = platform_keys;
		GameRenderer game_renderer = {0};
		game_renderer.commands_arena = arena_init(platform_commands_arena_backing, size_of(platform_commands_arena_backing));
		GameMemory game_memory = {0};
		game_memory.permanent_storage = game_memory_backing;
		game_memory.permanent_storage_size = game_memory_backing_size;
		game_update_and_render(&game_input, &game_renderer, &game_memory);

		renderer_present(&game_renderer);

		if (sleep_is_granular) {
			LARGE_INTEGER clock_frame_end;
			QueryPerformanceCounter(&clock_frame_end);

			s64 ideal_frame_ms = 5;
			s64 delta_ms = (clock_frame_end.QuadPart - clock_frame_begin.QuadPart) / (clock_frequency.QuadPart / 1000);
			if (ideal_frame_ms > delta_ms) {
				Sleep(cast(u32) (ideal_frame_ms - delta_ms));
			}
		}

		if (game_input.wants_quit) DestroyWindow(platform_hwnd);
	}
main_loop_end:

	ExitProcess(0);
}

int _fltused = 0;
