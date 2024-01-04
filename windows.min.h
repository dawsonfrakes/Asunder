/* kernel32 */
#define MEM_COMMIT 0x00001000
#define MEM_RESERVE 0x00002000
#define PAGE_READWRITE 0x04

typedef uint64_t LARGE_INTEGER;
typedef struct HANDLE__ *HANDLE;
typedef struct HMODULE__ *HMODULE;
typedef HMODULE HINSTANCE;

HMODULE GetModuleHandleA(const char *);
int QueryPerformanceFrequency(LARGE_INTEGER *);
int QueryPerformanceCounter(LARGE_INTEGER *);
void *VirtualAlloc(void *, uintptr_t, unsigned long, unsigned long);
__attribute__((noreturn)) void ExitProcess(unsigned int);

/* user32 */
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
#define WS_MAXIMIZEBOX 0x00010000
#define WS_MINIMIZEBOX 0x00020000
#define WS_THICKFRAME 0x00040000
#define WS_SYSMENU 0x00080000
#define WS_CAPTION 0x00C00000
#define WS_VISIBLE 0x10000000
#define WS_POPUP 0x80000000
#define CW_USEDEFAULT ((int) 0x80000000)
#define PM_REMOVE 0x0001

typedef struct HDC__ *HDC;
typedef struct HWND__ *HWND;
typedef struct HRGN__ *HRGN;
typedef struct HICON__ *HICON;
typedef struct HMENU__ *HMENU;
typedef struct HBRUSH__ *HBRUSH;
typedef struct HCURSOR__ *HCURSOR;
typedef intptr_t (*WNDPROC)(HWND, unsigned int, uintptr_t, intptr_t);
typedef struct tagWNDCLASSA {
	unsigned int style;
	WNDPROC lpfnWndProc;
	int cbClsExtra;
	int cbWndExtra;
	HINSTANCE hInstance;
	HICON hIcon;
	HCURSOR hCursor;
	HBRUSH hbrBackground;
	const char *lpszMenuName;
	const char *lpszClassName;
} WNDCLASSA;
typedef struct tagPOINT { long x, y; } POINT;
typedef struct tagMSG {
	HWND hwnd;
	unsigned int message;
	uintptr_t wParam;
	intptr_t lParam;
	unsigned long time;
	POINT pt;
	unsigned long lPrivate;
} MSG;

HCURSOR LoadCursorA(HINSTANCE, const char *);
int RegisterClassA(const WNDCLASSA *);
HWND CreateWindowExA(unsigned long, const char *, const char *, unsigned long, int, int, int, int, HWND, HMENU, HINSTANCE, void *);
int PeekMessageA(MSG *, HWND, unsigned int, unsigned int, unsigned int);
int TranslateMessage(const MSG *);
intptr_t DispatchMessageA(const MSG *);
intptr_t DefWindowProcA(HWND, unsigned int, uintptr_t, intptr_t);
void PostQuitMessage(int);
int ValidateRgn(HWND, HRGN);
HDC GetDC(HWND);

/* gdi32 */
#define SRCCOPY 0x00CC0020

typedef struct HGDIOBJ__ *HGDIOBJ;
typedef HGDIOBJ HBITMAP;
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
typedef struct tagRGBQUAD { unsigned char b, g, r, reserved; } RGBQUAD;
typedef struct tagBITMAPINFO {
	BITMAPINFOHEADER bmiHeader;
	RGBQUAD bmiColors[1];
} BITMAPINFO;
typedef struct tagPIXELFORMATDESCRIPTOR {
	unsigned short nSize, nVersion;
	unsigned long dwFlags;
	unsigned char iPixelType, cColorBits, cRedBits, cRedShift,
	              cGreenBits, cGreenShift, cBlueBits, cBlueShift, cAlphaBits, cAlphaShift,
	              cAccumBits, cAccumRedBits, cAccumGreenBits, cAccumBlueBits, cAccumAlphaBits,
	              cDepthBits, cStencilBits, cAuxBuffers, iLayerType, bReserved;
	unsigned long dwLayerMask, dwVisibleMask, dwDamageMask;
} PIXELFORMATDESCRIPTOR;

HDC CreateCompatibleDC(HDC);
int DeleteDC(HDC);
HBITMAP CreateDIBSection(HDC, const BITMAPINFO *, unsigned int, void **, HANDLE, unsigned long);
HGDIOBJ SelectObject(HDC, HGDIOBJ);
int DeleteObject(HGDIOBJ);
int BitBlt(HDC, int, int, int, int, HDC, int, int, unsigned long);
int SetPixelFormat(HDC, int, const PIXELFORMATDESCRIPTOR *);
int ChoosePixelFormat(HDC, const PIXELFORMATDESCRIPTOR *);
int SwapBuffers(HDC);

/* opengl32 */
#define PFD_DOUBLEBUFFER 0x00000001
#define PFD_DRAW_TO_WINDOW 0x00000004
#define PFD_SUPPORT_OPENGL 0x00000020

typedef struct HGLRC__ *HGLRC;

HGLRC wglCreateContext(HDC);
int wglDeleteContext(HGLRC);
int wglMakeCurrent(HDC, HGLRC);
void (*wglGetProcAddress(const char *))(void);

/* gl/gl.h */
typedef uint32_t GLenum;
typedef uint32_t GLuint;
typedef uint32_t GLsizei;
typedef uint32_t GLbitfield;
typedef int32_t GLint;
typedef uint8_t GLboolean;
typedef float GLfloat;

#define GL_FALSE 0
#define GL_UNSIGNED_SHORT 0x1403
#define GL_FLOAT 0x1406
#define GL_TRIANGLES 0x0004
#define GL_COLOR_BUFFER_BIT 0x00004000

void glViewport(GLint, GLint, GLsizei, GLsizei);
void glDrawElements(GLenum, GLsizei, GLenum, const void *);
void glClear(GLbitfield);
void glClearColor(GLfloat, GLfloat, GLfloat, GLfloat);
