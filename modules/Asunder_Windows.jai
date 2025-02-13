kernel32 :: #library,system "kernel32";

HINSTANCE :: #type,distinct *void;
HMODULE :: HINSTANCE;
PROC :: #type () -> s64 #c_call;

GetModuleHandleW :: (name: *u16) -> HMODULE #foreign kernel32;
LoadLibraryW :: (name: *u16) -> HMODULE #foreign kernel32;
GetProcAddress :: (module: HMODULE, name: *u8) -> PROC #foreign kernel32;
Sleep :: (duration: u32) #foreign kernel32;
QueryPerformanceFrequency :: (freq: *s64) -> s32 #foreign kernel32;
QueryPerformanceCounter :: (count: *s64) -> s32 #foreign kernel32;

user32 :: #library,system "user32";

CS_OWNDC :: 0x0020;
IDI_WARNING :: cast(*u16) 32515;
IDC_CROSS :: cast(*u16) 32515;
PM_REMOVE :: 0x0001;
WM_CREATE :: 0x0001;
WM_DESTROY :: 0x0002;
WM_SIZE :: 0x0005;
WM_PAINT :: 0x000F;
WM_QUIT :: 0x0012;
WM_ERASEBKGND :: 0x0014;
WM_ACTIVATEAPP :: 0x001C;
WM_KEYDOWN :: 0x0100;
WM_KEYUP :: 0x0101;
WM_SYSKEYDOWN :: 0x0104;
WM_SYSKEYUP :: 0x0105;
WM_SYSCOMMAND :: 0x0112;
WS_MAXIMIZEBOX :: 0x00010000;
WS_MINIMIZEBOX :: 0x00020000;
WS_THICKFRAME :: 0x00040000;
WS_SYSMENU :: 0x00080000;
WS_CAPTION :: 0x00C00000;
WS_VISIBLE :: 0x10000000;
WS_OVERLAPPEDWINDOW :: WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX;
CW_USEDEFAULT :: 0x80000000;
SC_KEYMENU :: 0xF100;
SWP_NOSIZE :: 0x0001;
SWP_NOMOVE :: 0x0002;
SWP_NOZORDER :: 0x0004;
SWP_FRAMECHANGED :: 0x0020;
HWND_TOP :: cast(HWND) 0;
GWL_STYLE :: -16;
MONITOR_DEFAULTTOPRIMARY :: 0x00000001;
VK_RETURN :: 0x0D;
VK_MENU :: 0x12;
VK_ESCAPE :: 0x1B;
VK_F4 :: 0x73;
VK_F10 :: 0x79;
VK_F11 :: 0x7A;

HDC :: #type,distinct *void;
HWND :: #type,distinct *void;
HMENU :: #type,distinct *void;
HICON :: #type,distinct *void;
HBRUSH :: #type,distinct *void;
HCURSOR :: #type,distinct *void;
HMONITOR :: #type,distinct *void;
WNDPROC :: #type (hwnd: HWND, message: u32, wParam: u64, lParam: s64) -> s64 #c_call;
POINT :: struct {
	x: s32;
	y: s32;
}
RECT :: struct {
	left: s32;
	top: s32;
	right: s32;
	bottom: s32;
}
WNDCLASSEXW :: struct {
  cbSize: u32;
  style: u32;
  lpfnWndProc: WNDPROC;
  cbClsExtra: s32;
  cbWndExtra: s32;
  hInstance: HINSTANCE;
  hIcon: HICON;
  hCursor: HCURSOR;
  hbrBackground: HBRUSH;
  lpszMenuName: *u16;
  lpszClassName: *u16;
  hIconSm: HICON;
}
MSG :: struct {
  hwnd: HWND;
  message: u32;
  wParam: u64;
  lParam: s64;
  time: u32;
  pt: POINT;
  lPrivate: u32;
}
WINDOWPLACEMENT :: struct {
  length: u32;
  flags: u32;
  showCmd: u32;
  ptMinPosition: POINT;
  ptMaxPosition: POINT;
  rcNormalPosition: RECT;
  rcDevice: RECT;
}
MONITORINFO :: struct {
  cbSize: u32;
  rcMonitor: RECT;
  rcWork: RECT;
  dwFlags: u32;
}

SetProcessDPIAware :: () -> s32 #foreign user32;
LoadIconW :: (instance: HINSTANCE, name: *u16) -> HICON #foreign user32;
LoadCursorW :: (instance: HINSTANCE, name: *u16) -> HCURSOR #foreign user32;
RegisterClassExW :: (wndclass: *WNDCLASSEXW) -> u16 #foreign user32;
CreateWindowExW :: (exstyle: u32, classname: *u16, name: *u16, style: u32, x: s32, y: s32, w: s32, h: s32, parent: HWND, menu: HMENU, instance: HINSTANCE, param: *void) -> HWND #foreign user32;
PeekMessageW :: (msg: *MSG, hwnd: HWND, mmin: u32, mmax: u32, mremove: u32) -> s32 #foreign user32;
TranslateMessage :: (msg: *MSG) -> s32 #foreign user32;
DispatchMessageW :: (msg: *MSG) -> s64 #foreign user32;
GetDC :: (hwnd: HWND) -> HDC #foreign user32;
ValidateRect :: (hwnd: HWND, rect: *RECT) -> s32 #foreign user32;
ClipCursor :: (rect: *RECT) -> s32 #foreign user32;
DestroyWindow :: (hwnd: HWND) -> s32 #foreign user32;
DefWindowProcW :: (hwnd: HWND, message: u32, wParam: u64, lParam: s64) -> s64 #foreign user32;
PostQuitMessage :: (status: s32) #foreign user32;
GetWindowLongPtrW :: (hwnd: HWND, index: s32) -> s64 #foreign user32;
SetWindowLongPtrW :: (hwnd: HWND, index: s32, value: s64) -> s64 #foreign user32;
GetWindowPlacement :: (hwnd: HWND, placement: *WINDOWPLACEMENT) -> s32 #foreign user32;
SetWindowPlacement :: (hwnd: HWND, placement: *WINDOWPLACEMENT) -> s32 #foreign user32;
SetWindowPos :: (hwnd: HWND, after: HWND, x: s32, y: s32, w: s32, h: s32, flags: u32) -> s32 #foreign user32;
MonitorFromWindow :: (hwnd: HWND, flags: u32) -> HMONITOR #foreign user32;
GetMonitorInfoW :: (monitor: HMONITOR, mi: *MONITORINFO) -> s32 #foreign user32;

gdi32 :: #library,system "gdi32";

PIXELFORMATDESCRIPTOR :: struct {
  nSize: u16;
  nVersion: u16;
  dwFlags: u32;
  iPixelType: u8;
  cColorBits: u8;
  cRedBits: u8;
  cRedShift: u8;
  cGreenBits: u8;
  cGreenShift: u8;
  cBlueBits: u8;
  cBlueShift: u8;
  cAlphaBits: u8;
  cAlphaShift: u8;
  cAccumBits: u8;
  cAccumRedBits: u8;
  cAccumGreenBits: u8;
  cAccumBlueBits: u8;
  cAccumAlphaBits: u8;
  cDepthBits: u8;
  cStencilBits: u8;
  cAuxBuffers: u8;
  iLayerType: u8;
  bReserved: u8;
  dwLayerMask: u32;
  dwVisibleMask: u32;
  dwDamageMask: u32;
}

ChoosePixelFormat :: (hdc: HDC, pfd: *PIXELFORMATDESCRIPTOR) -> s32 #foreign gdi32;
SetPixelFormat :: (hdc: HDC, format: s32, pfd: *PIXELFORMATDESCRIPTOR) -> s32 #foreign gdi32;
SwapBuffers :: (hdc: HDC) -> s32 #foreign gdi32;

opengl32 :: #library,system "opengl32";

HGLRC :: #type,distinct *void;

PFD_DOUBLEBUFFER :: 0x00000001;
PFD_DRAW_TO_WINDOW :: 0x00000004;
PFD_SUPPORT_OPENGL :: 0x00000020;
PFD_DEPTH_DONTCARE :: 0x20000000;

wglCreateContext :: (hdc: HDC) -> HGLRC #foreign opengl32;
wglDeleteContext :: (ctx: HGLRC) -> s32 #foreign opengl32;
wglMakeCurrent :: (hdc: HDC, ctx: HGLRC) -> s32 #foreign opengl32;
wglGetProcAddress :: (name: *u8) -> PROC #foreign opengl32;

ws2_32 :: #library,system "ws2_32";

WSADATA :: struct {
	wVersion: u16;
	wHighVersion: u16;
	#if CPU == .X64 || CPU == .ARM64 {
		iMaxSockets: u16;
		iMaxUdpDg: u16;
		lpVendorInfo: *u8;
		szDescription: [257]u8;
		szSystemStatus: [129]u8;
	} else {
		szDescription: [257]u8;
		szSystemStatus: [129]u8;
		iMaxSockets: u16;
		iMaxUdpDg: u16;
		lpVendorInfo: *u8;
	}
}

WSAStartup :: (version: u16, wsadata: *WSADATA) -> s32 #foreign ws2_32;
WSACleanup :: () -> s32 #foreign ws2_32;

dwmapi :: #library,system "dwmapi";

DWMWA_USE_IMMERSIVE_DARK_MODE :: 20;
DWMWA_WINDOW_CORNER_PREFERENCE :: 33;
DWMWCP_DONOTROUND :: 1;

DwmSetWindowAttribute :: (hwnd: HWND, attribute: u32, value: *void, size: u32) -> s32 #foreign dwmapi;

winmm :: #library,system "winmm";

TIMERR_NOERROR :: 0;

timeBeginPeriod :: (interval: u32) -> u32 #foreign winmm;
