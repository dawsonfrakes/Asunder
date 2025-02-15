package main

#assert(ODIN_NO_CRT)
#assert(ODIN_NO_ENTRY_POINT)

import w "basic/windows"

platform_hinstance: w.HINSTANCE
platform_hwnd: w.HWND
platform_hdc: w.HDC
platform_width: i32
platform_height: i32

update_cursor_clip :: proc "contextless" () {
  w.ClipCursor(nil);
}

clear_held_keys :: proc "contextless" () {

}

toggle_fullscreen :: proc "contextless" () {
  // :todo
  @static save_placement := w.WINDOWPLACEMENT{length=size_of(w.WINDOWPLACEMENT)}
}

entry :: proc "contextless" () {
  platform_hinstance = w.GetModuleHandleW(nil)

  wsadata: w.WSADATA = ---
  networking_supported := w.WSAStartup(0x202, &wsadata) == 0
  defer if networking_supported { w.WSACleanup() }

  sleep_is_granular := w.timeBeginPeriod(1) == w.TIMERR_NOERROR

  w.SetProcessDPIAware()
  wndclass: w.WNDCLASSEXW
  wndclass.cbSize = size_of(w.WNDCLASSEXW)
  wndclass.style = w.CS_OWNDC
  wndclass.lpfnWndProc = proc "stdcall" (hwnd: w.HWND, message: u32, wParam: uint, lParam: int) -> int {
    switch message {
      case w.WM_PAINT:
        w.ValidateRect(hwnd, nil)
      case w.WM_ERASEBKGND:
        return 1
      case w.WM_ACTIVATEAPP:
        tabbing_in := wParam != 0;

        if tabbing_in { update_cursor_clip() }
        else { clear_held_keys() }
      case w.WM_SIZE:
        platform_width = cast(i32) transmute(u16) cast(i16) lParam
        platform_height = cast(i32) transmute(u16) cast(i16) (lParam >> 16)
      case w.WM_CREATE:
        platform_hwnd = hwnd
        platform_hdc = w.GetDC(hwnd)

        dark_mode: i32 = 1
        w.DwmSetWindowAttribute(hwnd, w.DWMWA_USE_IMMERSIVE_DARK_MODE, &dark_mode, size_of(dark_mode))
        round_mode: i32 = w.DWMWCP_DONOTROUND
        w.DwmSetWindowAttribute(hwnd, w.DWMWA_WINDOW_CORNER_PREFERENCE, &round_mode, size_of(round_mode))
      case w.WM_DESTROY:
        w.PostQuitMessage(0)
      case w.WM_SYSCOMMAND:
        if wParam == w.SC_KEYMENU { return 0 }
        fallthrough
      case:
        return w.DefWindowProcW(hwnd, message, wParam, lParam)
    }
    return 0
  }
  wndclass.hInstance = platform_hinstance
  wndclass.hIcon = w.LoadIconW(nil, w.IDI_WARNING)
  wndclass.hCursor = w.LoadCursorW(nil, w.IDC_CROSS)
  wndclass.lpszClassName = raw_data([]u16le{'A', 0})
  w.RegisterClassExW(&wndclass)
  w.CreateWindowExW(0, wndclass.lpszClassName, raw_data([]u16le{'A', 's', 'u', 'n', 'd', 'e', 'r', 0}),
    w.WS_OVERLAPPEDWINDOW | w.WS_VISIBLE,
    w.CW_USEDEFAULT, w.CW_USEDEFAULT, w.CW_USEDEFAULT, w.CW_USEDEFAULT,
    nil, nil, platform_hinstance, nil)

  main_loop: for {
    msg: w.MSG = ---
    for w.PeekMessageW(&msg, nil, 0, 0, w.PM_REMOVE) != 0 {
      w.TranslateMessage(&msg)
      using msg
      switch message {
        case w.WM_KEYDOWN, w.WM_KEYUP, w.WM_SYSKEYDOWN, w.WM_SYSKEYUP:
          pressed := lParam & (1 << 31) == 0
          repeat := pressed && lParam & (1 << 30) != 0
          sys := message == w.WM_SYSKEYDOWN || message == w.WM_SYSKEYUP
          alt := sys && lParam & (1 << 29) != 0

          if !repeat && (!sys || alt || wParam == w.VK_MENU || wParam == w.VK_F10) {
            if pressed {
              if wParam == w.VK_F4 && alt { w.DestroyWindow(platform_hwnd) }
              if wParam == w.VK_ESCAPE { w.DestroyWindow(platform_hwnd) }
              if wParam == w.VK_RETURN && alt { toggle_fullscreen() }
              if wParam == w.VK_F11 { toggle_fullscreen() }
            }
          }
        case w.WM_QUIT:
          break main_loop
        case:
          w.DispatchMessageW(&msg)
      }
    }

    if sleep_is_granular {
      // :todo
      w.Sleep(1)
    }
  }
}

@(require, linkage="strong", link_name="mainCRTStartup")
__entry :: proc "std" () {
  entry()
  w.ExitProcess(0)
}
