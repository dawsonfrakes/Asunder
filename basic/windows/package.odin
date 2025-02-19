package windows

foreign import "system:kernel32.lib"

HINSTANCE :: distinct rawptr
HMODULE :: HINSTANCE
PROC :: proc "std" () -> int

@(default_calling_convention = "std")
foreign kernel32 {
  GetModuleHandleW :: proc(name: [^]u16) -> HMODULE ---
  LoadLibraryW :: proc(name: [^]u16) -> HMODULE ---
  GetProcAddress :: proc(module: HMODULE, name: cstring) -> PROC ---
  Sleep :: proc(duration: u32) ---
  QueryPerformanceFrequency :: proc(frequency: ^i64) -> i32 ---
  QueryPerformanceCounter :: proc(counter: ^i64) -> i32 ---
  ExitProcess :: proc(status: u32) ---
}

foreign import "system:user32.lib"

CS_OWNDC :: 0x0020
IDI_WARNING :: cast([^]u16) cast(uintptr) 32515
IDC_CROSS :: cast([^]u16) cast(uintptr) 32515
WS_MAXIMIZEBOX :: 0x00010000
WS_MINIMIZEBOX :: 0x00020000
WS_THICKFRAME :: 0x00040000
WS_SYSMENU :: 0x00080000
WS_CAPTION :: 0x00C00000
WS_VISIBLE :: 0x10000000
WS_OVERLAPPEDWINDOW :: WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX
CW_USEDEFAULT :: transmute(i32) cast(u32) 0x80000000
PM_REMOVE :: 0x0001
WM_CREATE :: 0x0001
WM_DESTROY :: 0x0002
WM_SIZE :: 0x0005
WM_PAINT :: 0x000F
WM_QUIT :: 0x0012
WM_ERASEBKGND :: 0x0014
WM_ACTIVATEAPP :: 0x001C
WM_KEYDOWN :: 0x0100
WM_KEYUP :: 0x0101
WM_SYSKEYDOWN :: 0x0104
WM_SYSKEYUP :: 0x0105
WM_SYSCOMMAND :: 0x0112
SC_KEYMENU :: 0xF100
VK_RETURN :: 0x0D
VK_MENU :: 0x12
VK_ESCAPE :: 0x1B
VK_F4 :: 0x73
VK_F10 :: 0x79
VK_F11 :: 0x7A
GWL_STYLE :: -16
HWND_TOP :: cast(HWND) cast(uintptr) 0
SWP_NOSIZE :: 0x0001
SWP_NOMOVE :: 0x0002
SWP_NOZORDER :: 0x0004
SWP_FRAMECHANGED :: 0x0020
MONITOR_DEFAULTTOPRIMARY :: 0x00000001

HDC :: distinct rawptr
HWND :: distinct rawptr
HMENU :: distinct rawptr
HICON :: distinct rawptr
HBRUSH :: distinct rawptr
HCURSOR :: distinct rawptr
HMONITOR :: distinct rawptr
WNDPROC :: proc "std" (hwnd: HWND, message: u32, wParam: uintptr, lParam: int) -> int
POINT :: struct {
  x: i32,
  y: i32,
}
RECT :: struct {
  left: i32,
  top: i32,
  right: i32,
  bottom: i32,
}
WNDCLASSEXW :: struct {
  cbSize: u32,
  style: u32,
  lpfnWndProc: WNDPROC,
  cbClsExtra: i32,
  cbWndExtra: i32,
  hInstance: HINSTANCE,
  hIcon: HICON,
  hCursor: HCURSOR,
  hbrBackground: HBRUSH,
  lpszMenuName: [^]u16,
  lpszClassName: [^]u16,
  hIconSm: HICON,
}
MSG :: struct {
  hwnd: HWND,
  message: u32,
  wParam: uintptr,
  lParam: int,
  time: u32,
  pt: POINT,
  lPrivate: u32,
}
WINDOWPLACEMENT :: struct {
  length: u32,
  flags: u32,
  showCmd: u32,
  ptMinPosition: POINT,
  ptMaxPosition: POINT,
  rcNormalPosition: RECT,
  rcDevice: RECT,
}
MONITORINFO :: struct {
  cbSize: u32,
  rcMonitor: RECT,
  rcWork: RECT,
  dwFlags: u32,
}

@(default_calling_convention = "std")
foreign user32 {
  SetProcessDPIAware :: proc() -> i32 ---
  LoadIconW :: proc(instance: HINSTANCE, name: [^]u16) -> HICON ---
  LoadCursorW :: proc(instance: HINSTANCE, name: [^]u16) -> HCURSOR ---
  RegisterClassExW :: proc(wndclass: ^WNDCLASSEXW) -> u16 ---
  CreateWindowExW :: proc(exstyle: u32, classname, name: [^]u16, style: u32, x, y, w, h: i32, parent: HWND, menu: HMENU, instance: HINSTANCE, param: rawptr) -> HWND ---
  PeekMessageW :: proc(msg: ^MSG, hwnd: HWND, mmin, mmax, mremove: u32) -> i32 ---
  TranslateMessage :: proc(msg: ^MSG) -> i32 ---
  DispatchMessageW :: proc(msg: ^MSG) -> int ---
  GetDC :: proc(hwnd: HWND) -> HDC ---
  ValidateRect :: proc(hwnd: HWND, rect: ^RECT) -> i32 ---
  DefWindowProcW :: proc(hwnd: HWND, message: u32, wParam: uintptr, lParam: int) -> int ---
  ClipCursor :: proc(rect: ^RECT) -> i32 ---
  DestroyWindow :: proc(hwnd: HWND) -> i32 ---
  PostQuitMessage :: proc(status: i32) ---
  GetWindowLongPtrW :: proc(hwnd: HWND, index: i32) -> int ---
  SetWindowLongPtrW :: proc(hwnd: HWND, index: i32, value: int) -> int ---
  GetWindowPlacement :: proc(hwnd: HWND, placement: ^WINDOWPLACEMENT) -> i32 ---
  SetWindowPlacement :: proc(hwnd: HWND, placement: ^WINDOWPLACEMENT) -> i32 ---
  SetWindowPos :: proc(hwnd, after: HWND, x, y, w, h: i32, flags: u32) -> i32 ---
  MonitorFromWindow :: proc(hwnd: HWND, flags: u32) -> HMONITOR ---
  GetMonitorInfoW :: proc(monitor: HMONITOR, mi: ^MONITORINFO) -> i32 ---
}

foreign import "system:gdi32.lib"

PFD_DOUBLEBUFFER :: 0x00000001
PFD_DRAW_TO_WINDOW :: 0x00000004
PFD_SUPPORT_OPENGL :: 0x00000020
PFD_DEPTH_DONTCARE :: 0x20000000

PIXELFORMATDESCRIPTOR :: struct {
  nSize: u16,
  nVersion: u16,
  dwFlags: u32,
  iPixelType: u8,
  cColorBits: u8,
  cRedBits: u8,
  cRedShift: u8,
  cGreenBits: u8,
  cGreenShift: u8,
  cBlueBits: u8,
  cBlueShift: u8,
  cAlphaBits: u8,
  cAlphaShift: u8,
  cAccumBits: u8,
  cAccumRedBits: u8,
  cAccumGreenBits: u8,
  cAccumBlueBits: u8,
  cAccumAlphaBits: u8,
  cDepthBits: u8,
  cStencilBits: u8,
  cAuxBuffers: u8,
  iLayerType: u8,
  bReserved: u8,
  dwLayerMask: u32,
  dwVisibleMask: u32,
  dwDamageMask: u32,
}

@(default_calling_convention = "std")
foreign gdi32 {
  ChoosePixelFormat :: proc(hdc: HDC, pfd: ^PIXELFORMATDESCRIPTOR) -> i32 ---
  SetPixelFormat :: proc(hdc: HDC, format: i32, pfd: ^PIXELFORMATDESCRIPTOR) -> i32 ---
  SwapBuffers :: proc(hdc: HDC) -> i32 ---
}

foreign import "system:opengl32.lib"

HGLRC :: distinct rawptr

@(default_calling_convention = "std")
foreign opengl32 {
  wglCreateContext :: proc(hdc: HDC) -> HGLRC ---
  wglDeleteContext :: proc(ctx: HGLRC) -> i32 ---
  wglMakeCurrent :: proc(hdc: HDC, ctx: HGLRC) -> i32 ---
  wglGetProcAddress :: proc(name: cstring) -> PROC ---
}

foreign import "system:ws2_32.lib"

WSADESCRIPTION_LEN :: 256
WSASYS_STATUS_LEN :: 128

WSADATA :: struct {
  wVersion: u16,
  wHighVersion: u16,
  iMaxSockets: u16,
  iMaxUdpDg: u16,
  lpVendorInfo: [^]u8,
  szDescription: [WSADESCRIPTION_LEN + 1]u8,
  szSystemStatus: [WSASYS_STATUS_LEN + 1]u8,
} when ODIN_ARCH == .amd64 || ODIN_ARCH == .arm64 else struct {
  wVersion: u16,
  wHighVersion: u16,
  szDescription: [WSADESCRIPTION_LEN + 1]u8,
  szSystemStatus: [WSASYS_STATUS_LEN + 1]u8,
  iMaxSockets: u16,
  iMaxUdpDg: u16,
  lpVendorInfo: [^]u8,
}

@(default_calling_convention = "std")
foreign ws2_32 {
  WSAStartup :: proc(version: u16, wsadata: ^WSADATA) -> i32 ---
  WSACleanup :: proc() -> i32 ---
}

foreign import "system:dwmapi.lib"

DWMWA_USE_IMMERSIVE_DARK_MODE :: 20
DWMWA_WINDOW_CORNER_PREFERENCE :: 33
DWMWCP_DONOTROUND :: 1

@(default_calling_convention = "std")
foreign dwmapi {
  DwmSetWindowAttribute :: proc(hwnd: HWND, attribute: u32, value: rawptr, size: u32) -> i32 ---
}

foreign import "system:winmm.lib"

TIMERR_NOERROR :: 0

@(default_calling_convention = "std")
foreign winmm {
  timeBeginPeriod :: proc(interval: u32) -> u32 ---
}
