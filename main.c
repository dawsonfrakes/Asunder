#define ASSERT(X) do if (!(X)) *(volatile char *) 0 = 0; while (0)
#define LENGTH(X) (sizeof (X) / sizeof (X)[0])
#define MIN(A, B) ((A) < (B) ? (A) : (B))
#define MAX(A, B) ((A) > (B) ? (A) : (B))
#define CLAMP(LO, V, HI) MAX((LO), MIN((V), (HI)))

#include <stdint.h>
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
typedef uintptr_t uptr;
typedef int8_t i8;
typedef int16_t i16;
typedef int32_t i32;
typedef int64_t i64;
typedef intptr_t iptr;
typedef size_t usize;
typedef float f32;
typedef double f64;
typedef struct v2 { f32 x, y; } v2;
typedef struct v3 { f32 x, y, z; } v3;
typedef struct v4 { f32 x, y, z, w; } v4;

struct GameMemory {
	void *ptr;
	usize size;
};

#define GAME_KEY_FORWARD 1
#define GAME_KEY_BACKWARD 2
#define GAME_KEY_RIGHT 4
#define GAME_KEY_LEFT 8
struct GameInput {
	u16 window_w, window_h;
	f32 dt;
	u32 keys;
};

struct GamePixelBuffer {
	u32 *ptr;
	u16 w, h; // @note: w, h must be 16 aligned
};

static v2 V2(f32 x, f32 y) {
	v2 result;
	result.x = x;
	result.y = y;
	return result;
}

static v3 V3(f32 x, f32 y, f32 z) {
	v3 result;
	result.x = x;
	result.y = y;
	result.z = z;
	return result;
}

static v3 V3zero(void) {
	v3 result;
	result.x = 0.0f;
	result.y = 0.0f;
	result.z = 0.0f;
	return result;
}

static v4 V4(f32 x, f32 y, f32 z, f32 w) {
	v4 result;
	result.x = x;
	result.y = y;
	result.z = z;
	result.w = w;
	return result;
}

static u32 argb_color(v4 color) {
	u32 result = ((u32) (u8) (color.w * 255.9f) << 24) |
		 ((u32) (u8) (color.x * 255.9f) << 16) |
		 ((u32) (u8) (color.y * 255.9f) << 8) |
		 ((u32) (u8) (color.z * 255.9f) << 0);
	return result;
}

static void pixbuf_rect(struct GamePixelBuffer *pixbuf, u16 x1, u16 y1, u16 x2, u16 y2, u32 color) {
	for (u16 y = y1; y < y2; ++y) {
		for (u16 x = x1; x < x2; ++x) {
			pixbuf->ptr[y * pixbuf->w + x] = color;
		}
	}
}

static void pixbuf_clear(struct GamePixelBuffer *pixbuf, v4 color) {
	pixbuf_rect(pixbuf, 0, 0, pixbuf->w, pixbuf->h, argb_color(color));
}

struct GameState {
	v3 cube_pos;
	v3 cube_vel;

	v3 camera_pos;
	v3 camera_vel;
	f32 camera_force;
	f32 camera_friction;

	f32 phys_dt;
	f32 phys_accum;

	u8 initted;
};

static void game_update(struct GameMemory *memory, struct GameInput *input, struct GamePixelBuffer *pixbuf) {
	struct GameState *gs = memory->ptr;
	ASSERT(sizeof *gs <= memory->size);
	if (!gs->initted) {
		gs->initted = 1;

		gs->phys_dt = 1.0f / 144.0f;

		gs->camera_pos = V3(0.0f, 0.0f, 1.0f);
		gs->camera_force = 1.0f;
		gs->camera_friction = 3.0f;
	}

	v3 acc = V3zero();
	if (input->keys & GAME_KEY_FORWARD) acc.y += 1.0f;
	if (input->keys & GAME_KEY_BACKWARD) acc.y -= 1.0f;
	if (input->keys & GAME_KEY_RIGHT) acc.x += 1.0f;
	if (input->keys & GAME_KEY_LEFT) acc.x -= 1.0f;

	// @todo properly normalize
	if (acc.x != 0.0f && acc.y != 0.0f) {
		acc.x *= 0.707f;
		acc.y *= 0.707f;
	}

	gs->phys_accum += input->dt;
	while (gs->phys_accum >= gs->phys_dt) {
		gs->phys_accum -= gs->phys_dt;

		gs->camera_vel.x += acc.x * gs->camera_force * gs->phys_dt;
		gs->camera_vel.y += acc.y * gs->camera_force * gs->phys_dt;

		gs->camera_pos.x += gs->camera_vel.x * gs->phys_dt;
		gs->camera_pos.y += gs->camera_vel.y * gs->phys_dt;

		gs->camera_vel.x += gs->camera_vel.x * -gs->camera_friction * gs->phys_dt;
		gs->camera_vel.y += gs->camera_vel.y * -gs->camera_friction * gs->phys_dt;
	}

	pixbuf_clear(pixbuf, V4(0.2f, 0.2f, 0.2f, 1.0f));

	v3 p = V3zero();
	p.x += gs->cube_pos.x; p.y += gs->cube_pos.y; p.z += gs->cube_pos.z; // translate
	p.x -= gs->camera_pos.x; p.y -= gs->camera_pos.y; p.z -= gs->camera_pos.z; // view
	p.x /= -p.z; p.y /= -p.z; // project

	f32 half_w = 0.1f;
	f32 half_h = 0.1f;
	v2 points[2] = {
		V2(p.x - half_w, p.y - half_h),
		V2(p.x + half_w, p.y + half_h),
	};

	// denormalize: [-1, 1] -> [0, window]
	for (v2 *point = points; point < points + LENGTH(points); ++point) {
		point->x *= (f32) input->window_h / (f32) input->window_w; // aspect correction
		point->x += 1.0f;
		point->x /= 2.0f;
		point->x = CLAMP(0.0f, point->x, 1.0f);
		point->x *= (f32) input->window_w;

		point->y += 1.0f;
		point->y /= 2.0f;
		point->y = CLAMP(0.0f, point->y, 1.0f);
		point->y *= (f32) input->window_h;
	}

	u16 xmin = (u16) points[0].x;
	u16 ymin = (u16) points[0].y;
	u16 xmax = (u16) points[1].x;
	u16 ymax = (u16) points[1].y;
	pixbuf_rect(pixbuf, xmin, ymin, xmax, ymax, 0xFFFFFFFF);
}

#define NOMINMAX
#define WIN32_LEAN_AND_MEAN
#include <windows.h>

static struct GameMemory memory;
static struct GameInput input;
static struct GamePixelBuffer pixbuf;

static void *hdc, *mdc;
static iptr proc(HWND hwnd, unsigned int msg, uptr wp, iptr lp) {
	iptr result = 0;
	switch (msg) {
	case WM_CREATE: hdc = GetDC(hwnd); break;
	case WM_SIZE: {
		input.window_w = (u16) (uptr) lp;
		input.window_h = (u16) ((uptr) lp >> 16);

		pixbuf.w = (input.window_w + 15) / 16 * 16;
		pixbuf.h = (input.window_h + 15) / 16 * 16;

		static BITMAPINFO bmi;
		bmi.bmiHeader.biSize = sizeof bmi;
		bmi.bmiHeader.biWidth = pixbuf.w;
		bmi.bmiHeader.biHeight = pixbuf.h;
		bmi.bmiHeader.biPlanes = 1;
		bmi.bmiHeader.biBitCount = 32;
		bmi.bmiHeader.biSizeImage = pixbuf.w * pixbuf.h * sizeof pixbuf.ptr[0];

		static void *hbm;
		if (mdc) DeleteDC(mdc);
		if (hbm) DeleteObject(hbm);
		mdc = CreateCompatibleDC(hdc);
		hbm = CreateDIBSection(hdc, &bmi, 0, (void **) &pixbuf.ptr, 0, 0);
		SelectObject(mdc, hbm);
	} break;
	case WM_KEYDOWN:
	case WM_KEYUP:
	case WM_SYSKEYDOWN:
	case WM_SYSKEYUP: {
		u8 pressed = msg == WM_KEYDOWN || msg == WM_SYSKEYDOWN;
		if (pressed) {
			u8 repeat = ((uptr) lp & (1 << 30)) != 0;
			if (repeat) break;
		}

#define INPUT_HANDLE_KEY_PRESS(K) input.keys = (input.keys & ~(u32) (K)) | ((u32) (K) * pressed)
		switch (wp) {
		case 'W': INPUT_HANDLE_KEY_PRESS(GAME_KEY_FORWARD); break;
		case 'S': INPUT_HANDLE_KEY_PRESS(GAME_KEY_BACKWARD); break;
		case 'D': INPUT_HANDLE_KEY_PRESS(GAME_KEY_RIGHT); break;
		case 'A': INPUT_HANDLE_KEY_PRESS(GAME_KEY_LEFT); break;
		case VK_ESCAPE: PostQuitMessage(0); break; // @cleanup
		}
#undef INPUT_HANDLE_KEY_PRESS
	} break;
	case WM_KILLFOCUS: input.keys = 0; break;
	case WM_PAINT: ValidateRgn(hwnd, 0); break;
	case WM_ERASEBKGND: result = 1; break;
	case WM_DESTROY: PostQuitMessage(0); break;
	default: result = DefWindowProcA(hwnd, msg, wp, lp); break;
	}
	return result;
}

void WinMainCRTStartup(void) {
	static u64 clock_frequency, clock_start, clock_previous;
	QueryPerformanceFrequency((LARGE_INTEGER *) &clock_frequency);
	QueryPerformanceCounter((LARGE_INTEGER *) &clock_start);
	clock_previous = clock_start;

	static WNDCLASSA wndclass;
	wndclass.style = CS_OWNDC;
	wndclass.lpfnWndProc = proc;
	wndclass.hInstance = GetModuleHandleA(0);
	wndclass.hCursor = LoadCursorA(0, IDC_CROSS);
	wndclass.lpszClassName = "A";
	RegisterClassA(&wndclass);
	CreateWindowExA(0, wndclass.lpszClassName, "Asunder",
		WS_SYSMENU | WS_CAPTION | WS_THICKFRAME | WS_VISIBLE,
		CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
		0, 0, wndclass.hInstance, 0);

	memory.size = 1 * 1024 * 1024;
	memory.ptr = VirtualAlloc((void *) 0x200000, memory.size,
		MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);

	for (;;) {
		static MSG msg;
		while (PeekMessageA(&msg, 0, 0, 0, PM_REMOVE) > 0) {
			if (msg.message == WM_QUIT) goto end;
			TranslateMessage(&msg);
			DispatchMessageA(&msg);
		}

		u64 clock_current;
		QueryPerformanceCounter((LARGE_INTEGER *) &clock_current);
		input.dt = (f32) (clock_current - clock_previous) / (f32) clock_frequency;
		clock_previous = clock_current;

		game_update(&memory, &input, &pixbuf);

		BitBlt(hdc, 0, 0, input.window_w, input.window_h, mdc, 0, pixbuf.h - input.window_h, SRCCOPY);
	}

end:
	ExitProcess(0);
}
