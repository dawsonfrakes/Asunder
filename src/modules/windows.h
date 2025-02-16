#if TARGET_CPU_X86
#if COMPILER_MSVC
#define WINAPI __stdcall
#elif COMPILER_TCC
#define WINAPI __attribute__((stdcall))
#else
#error WINAPI not defined
#endif
#else
#define WINAPI
#endif

#define STD_OUTPUT_HANDLE (cast(u32) -11)

typedef void* HANDLE;
typedef struct HINSTANCE__* HINSTANCE;
typedef HINSTANCE HMODULE;
typedef s64 (WINAPI *PROC)(void);

// kernel32
HMODULE WINAPI GetModuleHandleW(u16*);
HMODULE WINAPI LoadLibraryW(u16*);
PROC WINAPI GetProcAddress(HMODULE, u8*);
void WINAPI Sleep(u32);
s32 WINAPI AllocConsole(void);
HANDLE WINAPI GetStdHandle(u32);
noreturn_t WINAPI ExitProcess(u32);

// user32
#define CS_OWNDC 0x0020
#define IDI_WARNING (cast(u16*) 32515)
#define IDC_CROSS (cast(u16*) 32515)
#define WS_MAXIMIZEBOX 0x00010000
#define WS_MINIMIZEBOX 0x00020000
#define WS_THICKFRAME 0x00040000
#define WS_SYSMENU 0x00080000
#define WS_CAPTION 0x00C00000
#define WS_VISIBLE 0x10000000
#define WS_OVERLAPPEDWINDOW (WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX)
#define CW_USEDEFAULT 0x80000000
#define PM_REMOVE 0x0001
#define WM_CREATE 0x0001
#define WM_DESTROY 0x0002
#define WM_SIZE 0x0005
#define WM_PAINT 0x000F
#define WM_QUIT 0x0012
#define WM_ERASEBKGND 0x0014
#define WM_ACTIVATEAPP 0x001C
#define WM_KEYDOWN 0x0100
#define WM_KEYUP 0x0101
#define WM_SYSKEYDOWN 0x0104
#define WM_SYSKEYUP 0x0105
#define WM_SYSCOMMAND 0x0112
#define SC_KEYMENU 0xF100
#define GWL_STYLE -16
#define HWND_TOP (cast(HWND) 0)
#define SWP_NOSIZE 0x0001
#define SWP_NOMOVE 0x0002
#define SWP_NOZORDER 0x0004
#define SWP_FRAMECHANGED 0x0020
#define MONITOR_DEFAULTTOPRIMARY 0x00000001
#define VK_RETURN 0x0D
#define VK_MENU 0x12
#define VK_ESCAPE 0x1B
#define VK_F4 0x73
#define VK_F10 0x79
#define VK_F11 0x7A

typedef struct HDC__* HDC;
typedef struct HWND__* HWND;
typedef struct HMENU__* HMENU;
typedef struct HICON__* HICON;
typedef struct HBRUSH__* HBRUSH;
typedef struct HCURSOR__* HCURSOR;
typedef struct HMONITOR__* HMONITOR;
typedef s64 (WINAPI *WNDPROC)(HWND, u32, u64, s64);
typedef struct {
	s32 x;
	s32 y;
} POINT;
typedef struct {
	s32 left;
	s32 top;
	s32 right;
	s32 bottom;
} RECT;
typedef struct {
	u32 cbSize;
  u32 style;
  WNDPROC lpfnWndProc;
  s32 cbClsExtra;
  s32 cbWndExtra;
  HINSTANCE hInstance;
  HICON hIcon;
  HCURSOR hCursor;
  HBRUSH hbrBackground;
  u16* lpszMenuName;
  u16* lpszClassName;
  HICON hIconSm;
} WNDCLASSEXW;
typedef struct {
  HWND hwnd;
  u32 message;
  u64 wParam;
  s64 lParam;
  u32 time;
  POINT pt;
  u32 lPrivate;
} MSG;
typedef struct {
  u32 length;
  u32 flags;
  u32 showCmd;
  POINT ptMinPosition;
  POINT ptMaxPosition;
  RECT rcNormalPosition;
  RECT rcDevice;
} WINDOWPLACEMENT;
typedef struct {
  u32 cbSize;
  RECT rcMonitor;
  RECT rcWork;
  u32 dwFlags;
} MONITORINFO;

s32 WINAPI SetProcessDPIAware(void);
HICON WINAPI LoadIconW(HINSTANCE, u16*);
HCURSOR WINAPI LoadCursorW(HINSTANCE, u16*);
u16 WINAPI RegisterClassExW(WNDCLASSEXW*);
HWND WINAPI CreateWindowExW(u32, u16*, u16*, u32, s32, s32, s32, s32, HWND, HMENU, HINSTANCE, void*);
s32 WINAPI PeekMessageW(MSG*, HWND, u32, u32, u32);
s32 WINAPI TranslateMessage(MSG*);
s64 WINAPI DispatchMessageW(MSG*);
HDC WINAPI GetDC(HWND);
s64 WINAPI DefWindowProcW(HWND, u32, u64, s64);
s32 WINAPI ValidateRect(HWND, RECT*);
s32 WINAPI ClipCursor(RECT*);
s32 WINAPI DestroyWindow(HWND);
void WINAPI PostQuitMessage(s32);
s64 WINAPI GetWindowLongPtrW(HWND, s32);
s64 WINAPI SetWindowLongPtrW(HWND, s32, s64);
s32 WINAPI GetWindowPlacement(HWND, WINDOWPLACEMENT*);
s32 WINAPI SetWindowPlacement(HWND, WINDOWPLACEMENT*);
s32 WINAPI SetWindowPos(HWND, HWND, s32, s32, s32, s32, u32);
HMONITOR WINAPI MonitorFromWindow(HWND, u32);
s32 WINAPI GetMonitorInfoW(HMONITOR, MONITORINFO*);

// gdi32
#define PFD_DOUBLEBUFFER 0x00000001
#define PFD_DRAW_TO_WINDOW 0x00000004
#define PFD_SUPPORT_OPENGL 0x00000020
#define PFD_DEPTH_DONTCARE 0x20000000

typedef struct {
  u16 nSize;
  u16 nVersion;
  u32 dwFlags;
  u8 iPixelType;
  u8 cColorBits;
  u8 cRedBits;
  u8 cRedShift;
  u8 cGreenBits;
  u8 cGreenShift;
  u8 cBlueBits;
  u8 cBlueShift;
  u8 cAlphaBits;
  u8 cAlphaShift;
  u8 cAccumBits;
  u8 cAccumRedBits;
  u8 cAccumGreenBits;
  u8 cAccumBlueBits;
  u8 cAccumAlphaBits;
  u8 cDepthBits;
  u8 cStencilBits;
  u8 cAuxBuffers;
  u8 iLayerType;
  u8 bReserved;
  u32 dwLayerMask;
  u32 dwVisibleMask;
  u32 dwDamageMask;
} PIXELFORMATDESCRIPTOR;

s32 WINAPI ChoosePixelFormat(HDC, PIXELFORMATDESCRIPTOR*);
s32 WINAPI SetPixelFormat(HDC, s32, PIXELFORMATDESCRIPTOR*);
s32 WINAPI SwapBuffers(HDC);

// opengl32
typedef struct HGLRC__* HGLRC;

HGLRC WINAPI wglCreateContext(HDC);
s32 WINAPI wglDeleteContext(HGLRC);
s32 WINAPI wglMakeCurrent(HDC, HGLRC);
PROC WINAPI wglGetProcAddress(u8*);

// ws2_32
#define WSADESCRIPTION_LEN 256
#define WSASYS_STATUS_LEN 128

typedef struct {
	u16 wVersion;
	u16 wHighVersion;
#ifdef TARGET_CPU_X86
	u8 szDescription[WSADESCRIPTION_LEN + 1];
	u8 szSystemStatus[WSASYS_STATUS_LEN + 1];
	u16 iMaxSockets;
	u16 iMaxUdpDg;
	u8* lpVendorInfo;
#else
	u16 iMaxSockets;
	u16 iMaxUdpDg;
	u8* lpVendorInfo;
	u8 szDescription[WSADESCRIPTION_LEN + 1];
	u8 szSystemStatus[WSASYS_STATUS_LEN + 1];
#endif
} WSADATA;

s32 WINAPI WSAStartup(u16, WSADATA*);
s32 WINAPI WSACleanup();

// dwmapi
#define DWMWA_USE_IMMERSIVE_DARK_MODE 20
#define DWMWA_WINDOW_CORNER_PREFERENCE 33
#define DWMWCP_DONOTROUND 1

s32 WINAPI DwmSetWindowAttribute(HWND, u32, void*, u32);

// winmm
#define TIMERR_NOERROR 0

u32 WINAPI timeBeginPeriod(u32);
