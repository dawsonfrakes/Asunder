#include "cfix.c"
#include "vector_math.c"

struct GameMemory {
	void *ptr;
	u32 size;
};

#define GAME_KEY_FORWARD 0x1
struct GameInput {
	u32 keys;

	u16 screen_width;
	u16 screen_height;
	f32 dt;
};

struct GameGraphics {
	void (*clear)(v4 color);
	void (*immediate_quad)(v2 a, v2 b, v4 color);
};

struct GameState {
	u8 initted;

	f32 pos_y;
	f32 vel_y;

	f32 phys_dt;
	f32 phys_accum;
};
static void game_update(struct GameMemory *memory, struct GameInput *input, struct GameGraphics *gfx) {
	struct GameState *gs = memory->ptr;
	ASSERT(sizeof *gs <= memory->size);
	if (!gs->initted) {
		gs->initted = 1;

		gs->phys_dt = 1.0f / 144.0f;
	}

	f32 force = 5.0f;
	f32 friction = 3.0f;

	f32 acc_y = 0.0f;
	if (input->keys & GAME_KEY_FORWARD) acc_y += 1.0f;
	acc_y *= force;

	gs->phys_accum += input->dt;
	while (gs->phys_accum >= gs->phys_dt) {
		gs->phys_accum -= gs->phys_dt;
		gs->vel_y += acc_y * gs->phys_dt;
		gs->pos_y += gs->vel_y * gs->phys_dt;
		gs->vel_y += gs->vel_y * -friction * gs->phys_dt;
	}

	gfx->clear(V4(0.2f, 0.2f, 0.2f, 1.0f));
	gfx->immediate_quad(V2(-0.5f, -0.5f + gs->pos_y), V2(0.5f, 0.5f + gs->pos_y), V4(1.0f, 0.0f, 1.0f, 1.0f));
}

#define MEM_COMMIT 0x00001000
#define MEM_RESERVE 0x00002000
#define PAGE_READWRITE 0x04
void *GetModuleHandleA(const char *);
void *VirtualAlloc(void *, uintptr_t, unsigned long, unsigned long);
int QueryPerformanceCounter(u64 *);
int QueryPerformanceFrequency(u64 *);
void ExitProcess(unsigned int);

#define WM_CREATE 0x0001
#define WM_DESTROY 0x0002
#define WM_SIZE 0x0005
#define WM_KILLFOCUS 0x0008
#define WM_PAINT 0x000F
#define WM_QUIT 0x0012
#define WM_ERASEBKGND 0x0014
#define WM_KEYDOWN 0x0100
#define WM_KEYUP 0x0101
#define WM_SYSKEYDOWN 0x0104
#define WM_SYSKEYUP 0x0105
#define CS_OWNDC 0x0020
#define IDC_CROSS ((const char *) (unsigned short) 32515)
#define WS_THICKFRAME 0x00040000
#define WS_SYSMENU 0x00080000
#define WS_CAPTION 0x00C00000
#define WS_VISIBLE 0x10000000
#define CW_USEDEFAULT ((int) 0x80000000)
#define PM_REMOVE 0x0001
typedef struct tagWNDCLASSA {
	unsigned int style;
	intptr_t (*lpfnWndProc)(void *, unsigned int, uintptr_t, intptr_t);
	int cbClsExtra;
	int cbWndExtra;
	void *hInstance;
	void *hIcon;
	void *hCursor;
	void *hbrBackground;
	const char *lpszMenuName;
	const char *lpszClassName;
} WNDCLASSA;
typedef struct tagPOINT { long x, y; } POINT;
typedef struct tagMSG {
	void *hwnd;
	unsigned int message;
	uintptr_t wParam;
	intptr_t lParam;
	unsigned long time;
	POINT pt;
	unsigned long lPrivate;
} MSG;
int RegisterClassA(const WNDCLASSA *);
void *CreateWindowExA(unsigned long, const char *, const char *, unsigned long, int, int, int, int, void *, void *, void *, void *);
void *LoadCursorA(void *, const char *);
int PeekMessageA(const MSG *, void *, unsigned int, unsigned int, unsigned int);
int TranslateMessage(const MSG *);
intptr_t DispatchMessageA(const MSG *);
void *GetDC(void *);
intptr_t DefWindowProcA(void *, unsigned int, uintptr_t, intptr_t);
void PostQuitMessage(int);
int ValidateRgn(void *, void *);

#define SRCCOPY 0x00CC0020
typedef struct tagBITMAPINFOHEADER {
	unsigned long biSize;
	long biWidth;
	long biHeight;
	unsigned short biPlanes;
	unsigned short biBitCount;
	unsigned long biCompression;
	unsigned long biSizeImage;
	long biXPelsPerMeter;
	long biYPelsPerMeter;
	unsigned long biClrUsed;
	unsigned long biClrImportant;
} BITMAPINFOHEADER;
typedef struct tagBITMAPINFO {
	BITMAPINFOHEADER bmiHeader;
	void *bmiColors;
} BITMAPINFO;
int DeleteDC(void *);
int DeleteObject(void *);
void *CreateCompatibleDC(void *);
void *CreateDIBSection(void *, const BITMAPINFO *, unsigned int, void **, void *, unsigned long);
void *SelectObject(void *, void *);
int BitBlt(void *, int, int, int, int, void *, int, int, unsigned long);

static struct GameInput input;
static struct GameMemory memory;

#include "pixbuf_renderer.c"

static void *hdc, *mdc;
static intptr_t proc(void *hwnd, unsigned int msg, uintptr_t wp, intptr_t lp) {
	intptr_t result = 0;
	switch (msg) {
	case WM_CREATE: hdc = GetDC(hwnd); break;
	case WM_SIZE: {
		input.screen_width = (u16) (uintptr_t) lp;
		input.screen_height = (u16) ((uintptr_t) lp >> 16);

		pixbuf.width = (input.screen_width + 15) / 16 * 16;
		pixbuf.height = input.screen_height;

		static BITMAPINFO bmi;
		bmi.bmiHeader.biSize = sizeof bmi.bmiHeader;
		bmi.bmiHeader.biWidth = pixbuf.width;
		bmi.bmiHeader.biHeight = pixbuf.height;
		bmi.bmiHeader.biPlanes = 1;
		bmi.bmiHeader.biBitCount = 32;
		bmi.bmiHeader.biSizeImage = pixbuf.width * pixbuf.height * sizeof pixbuf.ptr[0];

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
		u8 repeat = pressed && ((uintptr_t) lp & (1 << 30)) != 0;
		if (!repeat) {
			switch (wp) {
			case 'W': input.keys = (input.keys & ~(u32) GAME_KEY_FORWARD) | ((u32) GAME_KEY_FORWARD * pressed); break;
			case '\x1b': PostQuitMessage(0); break; // @cleanup
			}
		}
		if (msg == WM_SYSKEYDOWN || msg == WM_SYSKEYUP)
			result = DefWindowProcA(hwnd, msg, wp, lp);
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
	QueryPerformanceFrequency(&clock_frequency);
	QueryPerformanceCounter(&clock_start);
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
		static u64 clock_current;
		QueryPerformanceCounter(&clock_current);
		input.dt = (f32) (clock_current - clock_previous) / (f32) clock_frequency;
		clock_previous = clock_current;

		game_update(&memory, &input, &gfx);

		BitBlt(hdc, 0, 0, input.screen_width, input.screen_height, mdc, pixbuf.height - input.screen_height, 0, SRCCOPY);
	}

end:
	ExitProcess(0);
}
