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

struct PixelBuffer {
	u32 *ptr;
	u16 w, h; // @note: w must be 16 aligned
};

static void game_update(struct PixelBuffer *pixbuf) {
	for (u16 y = 0; y < pixbuf->h; ++y) {
		for (u16 x = 0; x < pixbuf->w; ++x) {
			pixbuf->ptr[y * pixbuf->w + x] = 0xFFFF0000;
		}
	}
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
