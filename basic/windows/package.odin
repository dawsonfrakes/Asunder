package windows

foreign import kernel32 "system:kernel32.lib"

HINSTANCE :: distinct rawptr
HMODULE :: HINSTANCE
PROC :: proc "stdcall" () -> int

@(default_calling_convention="stdcall")
foreign kernel32 {
  GetModuleHandleW :: proc(name: [^]u16le) -> HMODULE ---
  LoadLibraryW :: proc(name: [^]u16le) -> HMODULE ---
  GetProcAddress :: proc(module: HMODULE, name: [^]u8) -> PROC ---
  Sleep :: proc(duration: u32) ---
  ExitProcess :: proc(status: u32) ---
}

foreign import user32 "system:user32.lib"

CS_OWNDC :: 0x0020
IDI_WARNING :: cast([^]u16le) cast(uintptr) 32515
IDC_CROSS :: cast([^]u16le) cast(uintptr) 32515
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

HDC :: distinct rawptr
HWND :: distinct rawptr
HMENU :: distinct rawptr
HICON :: distinct rawptr
HBRUSH :: distinct rawptr
HCURSOR :: distinct rawptr
HMONITOR :: distinct rawptr
WNDPROC :: proc "stdcall" (hwnd: HWND, message: u32, wParam: uint, lParam: int) -> int
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
  lpszMenuName: [^]u16le,
  lpszClassName: [^]u16le,
  hIconSm: HICON,
}
MSG :: struct {
  hwnd: HWND,
  message: u32,
  wParam: uint,
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

@(default_calling_convention="stdcall")
foreign user32 {
  SetProcessDPIAware :: proc() -> i32 ---
  LoadIconW :: proc(instance: HINSTANCE, name: [^]u16le) -> HICON ---
  LoadCursorW :: proc(instance: HINSTANCE, name: [^]u16le) -> HCURSOR ---
  RegisterClassExW :: proc(wndclass: ^WNDCLASSEXW) -> u16 ---
  CreateWindowExW :: proc(exstyle: u32, classname, name: [^]u16le, style: u32, x, y, w, h: i32, parent: HWND, menu: HMENU, instance: HINSTANCE, param: rawptr) -> HWND ---
  PeekMessageW :: proc(msg: ^MSG, hwnd: HWND, mmin, mmax, mremove: u32) -> i32 ---
  TranslateMessage :: proc(msg: ^MSG) -> i32 ---
  DispatchMessageW :: proc(msg: ^MSG) -> int ---
  GetDC :: proc(hwnd: HWND) -> HDC ---
  DefWindowProcW :: proc(hwnd: HWND, message: u32, wParam: uint, lParam: int) -> int ---
  PostQuitMessage :: proc(status: i32) ---
  ValidateRect :: proc(hwnd: HWND, rect: ^RECT) -> i32 ---
  ClipCursor :: proc(rect: ^RECT) -> i32 ---
  DestroyWindow :: proc(hwnd: HWND) -> i32 ---
}

foreign import ws2_32 "system:ws2_32.lib"

WSADATA :: struct {
  wVersion: u16,
  wHighVersion: u16,
  szDescription: [256 + 1]u8,
  szSystemStatus: [128 + 1]u8,
  iMaxSockets: u16,
  iMaxUdpDg: u16,
  lpVendorInfo: [^]u8,
} when ODIN_ARCH == .i386 else struct {
  wVersion: u16,
  wHighVersion: u16,
  iMaxSockets: u16,
  iMaxUdpDg: u16,
  lpVendorInfo: [^]u8,
  szDescription: [256 + 1]u8,
  szSystemStatus: [128 + 1]u8,
}

@(default_calling_convention="stdcall")
foreign ws2_32 {
  WSAStartup :: proc(version: u16, wsadata: ^WSADATA) -> i32 ---
  WSACleanup :: proc() -> i32 ---
}

foreign import dwmapi "system:dwmapi.lib"

DWMWA_USE_IMMERSIVE_DARK_MODE :: 20
DWMWA_WINDOW_CORNER_PREFERENCE :: 33
DWMWCP_DONOTROUND :: 1

@(default_calling_convention="stdcall")
foreign dwmapi {
  DwmSetWindowAttribute :: proc(hwnd: HWND, attribute: u32, value: rawptr, size: u32) -> i32 ---
}

foreign import winmm "system:winmm.lib"

TIMERR_NOERROR :: 0

@(default_calling_convention="stdcall")
foreign winmm {
  timeBeginPeriod :: proc(interval: u32) -> u32 ---
}
