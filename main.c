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
typedef struct v4 { f32 x, y, z, w; } v4;

struct PixelBuffer {
	u32 *ptr;
	u16 w, h; // @note: w must be 16 aligned
};

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

static void pixbuf_rect(struct PixelBuffer *pixbuf, u16 x1, u16 y1, u16 x2, u16 y2, u32 color) {
	for (u16 y = y1; y < y2; ++y) {
		for (u16 x = x1; x < x2; ++x) {
			pixbuf->ptr[y * pixbuf->w + x] = color;
		}
	}
}

static void pixbuf_clear(struct PixelBuffer *pixbuf, v4 color) {
	pixbuf_rect(pixbuf, 0, 0, pixbuf->w, pixbuf->h, argb_color(color));
}

static void game_update(struct PixelBuffer *pixbuf) {
	pixbuf_clear(pixbuf, V4(1.0f, 0.0f, 1.0f, 1.0f));
}

#define NOMINMAX
#define WIN32_LEAN_AND_MEAN
#include <windows.h>

static struct PixelBuffer pixbuf;

static void *hdc, *mdc;
static u16 window_w, window_h;
static iptr proc(HWND hwnd, unsigned int msg, uptr wp, iptr lp) {
	iptr result = 0;
	switch (msg) {
	case WM_CREATE: hdc = GetDC(hwnd); break;
	case WM_SIZE: {
		window_w = (u16) (u64) lp;
		window_h = (u16) ((u64) lp >> 16);

		pixbuf.w = (window_w + 15) / 16 * 16;
		pixbuf.h = window_h;

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
	case WM_PAINT: ValidateRgn(hwnd, 0); break;
	case WM_ERASEBKGND: result = 1; break;
	case WM_DESTROY: PostQuitMessage(0); break;
	default: result = DefWindowProcA(hwnd, msg, wp, lp); break;
	}
	return result;
}

void WinMainCRTStartup(void) {
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

	for (;;) {
		static MSG msg;
		while (PeekMessageA(&msg, 0, 0, 0, PM_REMOVE) > 0) {
			if (msg.message == WM_QUIT) goto end;
			TranslateMessage(&msg);
			DispatchMessageA(&msg);
		}

		game_update(&pixbuf);

		BitBlt(hdc, 0, 0, window_w, window_h, mdc, 0, 0, SRCCOPY);
	}

end:
	ExitProcess(0);
}
