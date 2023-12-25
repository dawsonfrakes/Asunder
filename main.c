/* https://suckless.org/coding_style */
#include <stdint.h>

#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>

#define MIN(A, B) ((A) < (B) ? (A) : (B))
#define MAX(A, B) ((A) > (B) ? (A) : (B))
#define CLAMP(LO, V, HI) MAX((LO), MIN((V), (HI)))

typedef struct V4 { float x, y, z, w; } V4;

enum GameKeys {
	GAME_KEY_FORWARD  = 0x1,
	GAME_KEY_BACKWARD = 0x2,
	GAME_KEY_RIGHT    = 0x4,
	GAME_KEY_LEFT     = 0x8,
};

static void *hdc, *mdc;
static uint16_t window_width, window_height;

static uint32_t *pixbuf_ptr;
static uint16_t pixbuf_width, pixbuf_height;

static uint32_t keys;

static float player_x, player_y;
static float player_dx, player_dy;

static float phys_dt = 1.0f / 144.0f;

static V4
make_vector4(float x, float y, float z, float w)
{
	V4 result;

	result.x = x;
	result.y = y;
	result.z = z;
	result.w = w;
	return result;
}

static uint32_t
argb_color(V4 color) {
	uint32_t result = ((uint32_t) (uint8_t) (color.w * 255.9f) << 24) |
	                  ((uint32_t) (uint8_t) (color.x * 255.9f) << 16) |
	                  ((uint32_t) (uint8_t) (color.y * 255.9f) <<  8) |
	                  ((uint32_t) (uint8_t) (color.z * 255.9f) <<  0);

	return result;
}

/* @todo rename */
static float
canonicalize_coordinate(float x)
{
	float result = x;

	result += 1.0f;
	result *= 0.5f;
	result = CLAMP(0.0f, result, 1.0f);
	return result;
}

static void
draw_player(void) {
	float player_half_w = 0.1f, player_half_h = 0.2f;
	uint32_t player_color_u = argb_color(make_vector4(1.0f, 0.0f, 0.0f, 1.0f));
	uint16_t x, y;
	uint16_t xmin = (uint16_t) (canonicalize_coordinate(player_x - player_half_w) * (float) window_width);
	uint16_t ymin = (uint16_t) (canonicalize_coordinate(player_y - player_half_h) * (float) window_height);
	uint16_t xmax = (uint16_t) (canonicalize_coordinate(player_x + player_half_w) * (float) window_width);
	uint16_t ymax = (uint16_t) (canonicalize_coordinate(player_y + player_half_h) * (float) window_height);

	for (y = ymin; y < ymax; ++y) {
		for (x = xmin; x < xmax; ++x) {
			pixbuf_ptr[y * pixbuf_width + x] = player_color_u;
		}
	}
}

static void
clear(void)
{
	uint16_t x, y;
	uint32_t color_u = argb_color(make_vector4(0.2f, 0.2f, 0.2f, 1.0f));

	for (y = 0; y < pixbuf_height; ++y) {
		for (x = 0; x < pixbuf_width; ++x) {
			pixbuf_ptr[y * pixbuf_width + x] = color_u;
		}
	}
}

static void
move_player(void)
{
	float player_force = 5.0f;
	float player_friction = 3.0f;
	float player_ddx = 0.0f, player_ddy = 0.0f;

	if (keys & GAME_KEY_FORWARD)  player_ddy += 1.0f;
	if (keys & GAME_KEY_BACKWARD) player_ddy -= 1.0f;
	if (keys & GAME_KEY_RIGHT)    player_ddx += 1.0f;
	if (keys & GAME_KEY_LEFT)     player_ddx -= 1.0f;

	/* @todo proper normalization */
	if (player_ddx != 0.0f && player_ddy != 0.0f) {
		player_ddx *= 0.707f;
		player_ddy *= 0.707f;
	}

	player_dx += player_ddx * phys_dt * player_force;
	player_dy += player_ddy * phys_dt * player_force;
	player_x  += player_dx * phys_dt;
	player_y  += player_dy * phys_dt;
	player_dx += player_dx * phys_dt * -player_friction;
	player_dy += player_dy * phys_dt * -player_friction;
}

static void
update_and_draw(float frame_dt)
{
	static float phys_accum;

	clear();
	phys_accum += frame_dt;
	while (phys_accum >= phys_dt) {
		phys_accum -= phys_dt;
		move_player();
	}
	draw_player();
}

static void
handle_game_key(uint32_t key, uint8_t pressed, uint8_t repeat)
{
	if (!repeat) {
		keys = (keys & ~key) | (key * pressed);
	}
}

static void
handle_keypress(unsigned int msg, uintptr_t wp, intptr_t lp)
{
	uint8_t pressed = msg == WM_KEYDOWN || msg == WM_SYSKEYDOWN;
	uint8_t repeat = pressed && ((uintptr_t) lp & ((uintptr_t) 1 << 30)) != 0;

	switch (wp) {
	case 'W': handle_game_key(GAME_KEY_FORWARD, pressed, repeat); break;
	case 'S': handle_game_key(GAME_KEY_BACKWARD, pressed, repeat); break;
	case 'D': handle_game_key(GAME_KEY_RIGHT, pressed, repeat); break;
	case 'A': handle_game_key(GAME_KEY_LEFT, pressed, repeat); break;
	case '\x1b': PostQuitMessage(0); break; /* @cleanup */
	}
}

static intptr_t
proc(HWND hwnd, unsigned int msg, uintptr_t wp, intptr_t lp)
{
	static BITMAPINFO bmi;
	static void *hbm;
	intptr_t result = 0;

	switch (msg) {
	case WM_CREATE: hdc = GetDC(hwnd); break;
	case WM_KEYDOWN:
	case WM_KEYUP:
		handle_keypress(msg, wp, lp);
		break;
	case WM_SYSKEYDOWN:
	case WM_SYSKEYUP:
		handle_keypress(msg, wp, lp);
		result = DefWindowProcA(hwnd, msg, wp, lp);
		break;
	case WM_SIZE:
		window_width  = (uint16_t) (uintptr_t) lp;
		window_height = (uint16_t) ((uintptr_t) lp >> 16);

		pixbuf_width  = (window_width + 15) / 16 * 16;
		pixbuf_height = window_height;

		bmi.bmiHeader.biSize      = sizeof(bmi.bmiHeader);
		bmi.bmiHeader.biWidth     = pixbuf_width;
		bmi.bmiHeader.biHeight    = pixbuf_height;
		bmi.bmiHeader.biPlanes    = 1;
		bmi.bmiHeader.biBitCount  = 32;
		bmi.bmiHeader.biSizeImage = pixbuf_width * pixbuf_height * sizeof(pixbuf_ptr[0]);

		if (mdc) DeleteDC(mdc);
		if (hbm) DeleteObject(hbm);
		mdc = CreateCompatibleDC(hdc);
		hbm = CreateDIBSection(hdc, &bmi, 0, (void **) &pixbuf_ptr, 0, 0);
		SelectObject(mdc, hbm);
		break;
	case WM_PAINT: ValidateRgn(hwnd, 0); break;
	case WM_ERASEBKGND: result = 1; break;
	case WM_DESTROY: PostQuitMessage(0); break;
	default: result = DefWindowProcA(hwnd, msg, wp, lp); break;
	}
	return result;
}

void
_start(void) {
	static WNDCLASSA wndclass;
	static MSG msg;
	uint64_t freq, start, previous, current;

	QueryPerformanceFrequency((LARGE_INTEGER *) &freq);
	QueryPerformanceCounter((LARGE_INTEGER *) &start);
	previous = start;

	wndclass.style         = CS_OWNDC;
	wndclass.lpfnWndProc   = proc;
	wndclass.hInstance     = GetModuleHandleA(0);
	wndclass.hCursor       = LoadCursorA(0, IDC_CROSS);
	wndclass.lpszClassName = "A";
	RegisterClassA(&wndclass);

	CreateWindowExA(0, wndclass.lpszClassName, "Title",
		WS_SYSMENU | WS_CAPTION | WS_THICKFRAME | WS_VISIBLE,
		CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
		0, 0, wndclass.hInstance, 0);

	for (;;) {
		while (PeekMessageA(&msg, 0, 0, 0, PM_REMOVE)) {
			if (msg.message == WM_QUIT) goto end;
			TranslateMessage(&msg);
			DispatchMessageA(&msg);
		}

		QueryPerformanceCounter((LARGE_INTEGER *) &current);
		update_and_draw((float) (current - previous) / (float) freq);
		previous = current;

		BitBlt(hdc, 0, 0, window_width, window_height, mdc, 0, 0, SRCCOPY);
	}

end:
	ExitProcess(0);
}
