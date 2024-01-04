#include "game.c"

#if 0
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <gl/gl.h>
#else
#include "windows.min.h"
#endif

#if defined(RENDERER_OPENGL) && RENDERER_OPENGL
#include "renderer_opengl.c"
#else
#include "renderer_cpu.c"
#endif

/* shared variables (windows_callback and WinMainCRTStartup) */
static struct Input    input;
static struct Graphics gfx;
static struct Memory   memory;

static intptr_t
windows_callback(HWND hwnd, unsigned int msg, uintptr_t wp, intptr_t lp)
{
	intptr_t result = 0;

	switch (msg) {
	case WM_CREATE:
		renderer_init(&gfx, GetDC(hwnd));
		break;
	case WM_SIZE:
		renderer_resize(&gfx, (uint16_t) (uintptr_t) lp,
		                (uint16_t) ((uintptr_t) lp >> 16));
		break;
	case WM_KEYDOWN:
	case WM_KEYUP:
	case WM_SYSKEYDOWN:
	case WM_SYSKEYUP: {
		uint8_t pressed = ((uintptr_t) lp & ((unsigned int) 1 << 31)) == 0;
		uint8_t repeat  = pressed && ((uintptr_t) lp & (1 << 30)) != 0;

		if (!repeat) switch (wp) {
		case 'W': input.keys = (input.keys & ~GAME_KEY_FORWARD) | (GAME_KEY_FORWARD * pressed); break;
		case 'S': input.keys = (input.keys & ~GAME_KEY_BACKWARD) | (GAME_KEY_BACKWARD * pressed); break;
		}

		if (wp == '\x1b' && pressed && !repeat) /* @debug */
			PostQuitMessage(0);

		if (msg == WM_SYSKEYDOWN || msg == WM_SYSKEYUP)
			DefWindowProcA(hwnd, msg, wp, lp);
	} break;
	case WM_KILLFOCUS: input.keys = 0; break;
	case WM_PAINT: ValidateRgn(hwnd, 0); break;
	case WM_ERASEBKGND: result = 1; break;
	case WM_DESTROY: PostQuitMessage(0); break;
	default: result = DefWindowProcA(hwnd, msg, wp, lp); break;
	}
	return result;
}

void
WinMainCRTStartup(void)
{
	static uint64_t  clock_frequency, clock_start, clock_previous, clock_current;
	static WNDCLASSA wndclass;
	static MSG       msg;

	QueryPerformanceFrequency((LARGE_INTEGER *) &clock_frequency);
	QueryPerformanceCounter((LARGE_INTEGER *) &clock_start);
	clock_previous = clock_start;

	wndclass.style         = CS_OWNDC;
	wndclass.lpfnWndProc   = windows_callback;
	wndclass.hInstance     = GetModuleHandleA(0);
	wndclass.hCursor       = LoadCursorA(0, IDC_CROSS);
	wndclass.lpszClassName = "A";
	RegisterClassA(&wndclass);

	CreateWindowExA(0, wndclass.lpszClassName, "Asunder",
	                WS_SYSMENU | WS_CAPTION | WS_THICKFRAME | WS_VISIBLE,
	                CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
	                0, 0, wndclass.hInstance, 0);

	memory.permanent_size = 1 * 1024 * 1024;
	memory.permanent      = VirtualAlloc((void *) 0x200000, /* @debug */
	                                     memory.permanent_size,
	                                     MEM_RESERVE | MEM_COMMIT,
	                                     PAGE_READWRITE);

	for (;;) {
		while (PeekMessageA(&msg, 0, 0, 0, PM_REMOVE)) {
			if (msg.message == WM_QUIT) goto end;
			TranslateMessage(&msg);
			DispatchMessageA(&msg);
		}

		QueryPerformanceCounter((LARGE_INTEGER *) &clock_current);
		input.dt = (float) (clock_current - clock_previous) /
		           (float) clock_frequency;
		clock_previous = clock_current;

		update(&memory, &input, &gfx);

		renderer_swap(&gfx);
	}

end:
	ExitProcess(0);
}
