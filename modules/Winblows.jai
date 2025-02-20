using Windows :: #import "Windows";

// user32
user32 :: #library,system "user32";

IDI_WARNING :: cast(*void) 32515;

WINDOWPLACEMENT :: struct {
  length: u32;
  flags: u32;
  showCmd: u32;
  ptMinPosition: POINT;
  ptMaxPosition: POINT;
  rcNormalPosition: RECT;
  rcDevice: RECT;
}

GetWindowLongPtrW :: (hwnd: HWND, index: s32) -> s64 #foreign user32;
GetWindowPlacement :: (hwnd: HWND, placement: *WINDOWPLACEMENT) -> s32 #foreign user32;
SetWindowPlacement :: (hwnd: HWND, placement: *WINDOWPLACEMENT) -> s32 #foreign user32;

// gdi32
PFD_DEPTH_DONTCARE :: 0x20000000;

// ws2_32
ws2_32 :: #library,system "ws2_32";

WSADATA :: struct {
  wVersion: u16;
  wHighVersion: u16;
  iMaxSockets: u16;
  iMaxUdpDg: u16;
  lpVendorInfo: *u8;
  szDescription: [257] u8;
  szSystemStatus: [129] u8;
}

WSAStartup :: (wVersionRequested: u16, lpWSAData: *WSADATA) -> s32 #foreign ws2_32;
WSACleanup :: () -> s32 #foreign ws2_32;

// dwmapi
dwmapi :: #library,system "dwmapi";

DWMWA_USE_IMMERSIVE_DARK_MODE :: 20;
DWMWA_WINDOW_CORNER_PREFERENCE :: 33;
DWMWCP_DONOTROUND :: 1;

DwmSetWindowAttribute :: (hwnd: HWND, attribute: u32, value: *void, size: u32) -> s32 #foreign dwmapi;
