#import "Maths";
#import "Winblows";

#load "../game/main.jai";
#load "renderer.jai";

platform_hinstance: HINSTANCE;
platform_hwnd: HWND;
platform_hdc: HDC;
platform_width: int;
platform_height: int;
platform_save_placement := WINDOWPLACEMENT.{length = size_of(WINDOWPLACEMENT)};

main :: () {
  update_cursor_clip :: () #no_context {
    ClipCursor(null);
  }

  clear_held_keys :: () #no_context {

  }

  toggle_fullscreen :: () #no_context {
    style := GetWindowLongPtrW(platform_hwnd, GWL_STYLE);
    if style & WS_OVERLAPPEDWINDOW {
      mi := MONITORINFO.{cbSize = size_of(MONITORINFO)};
      GetMonitorInfoW(MonitorFromWindow(platform_hwnd, MONITOR_DEFAULTTOPRIMARY), *mi);

      GetWindowPlacement(platform_hwnd, *platform_save_placement);
      SetWindowLongPtrW(platform_hwnd, GWL_STYLE, style & ~WS_OVERLAPPEDWINDOW);
      SetWindowPos(platform_hwnd, HWND_TOP, mi.rcMonitor.left, mi.rcMonitor.top,
        mi.rcMonitor.right - mi.rcMonitor.left, mi.rcMonitor.bottom - mi.rcMonitor.top,
        SWP_FRAMECHANGED);
    } else {
      SetWindowLongPtrW(platform_hwnd, GWL_STYLE, style | WS_OVERLAPPEDWINDOW);
      SetWindowPlacement(platform_hwnd, *platform_save_placement);
      SetWindowPos(platform_hwnd, xx null, 0, 0, 0, 0, SWP_NOMOVE |
        SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED);
    }
  }

  platform_hinstance = GetModuleHandleW(null);

  wsadata: WSADATA = ---;
  networking_supported := WSAStartup(0x202, *wsadata);
  defer if networking_supported WSACleanup();

  sleep_is_granular := timeBeginPeriod(1) == TIMERR_NOERROR;

  clock_frequency: s64 = ---;
  QueryPerformanceFrequency(*clock_frequency);
  clock_start: s64 = ---;
  QueryPerformanceCounter(*clock_start);
  clock_previous := clock_start;

  SetProcessDPIAware();
  wndclass: WNDCLASSEXW;
  wndclass.cbSize = size_of(WNDCLASSEXW);
  wndclass.style = CS_OWNDC;
  wndclass.lpfnWndProc = (hwnd: HWND, message: u32, wParam: u64, lParam: s64) -> s64 #c_call {
    if message == {
      case WM_PAINT;
        ValidateRect(hwnd, null);
      case WM_ERASEBKGND;
        return 1;
      case WM_ACTIVATEAPP;
        tabbing_in := wParam != 0;

        if tabbing_in update_cursor_clip();
        else clear_held_keys();
      case WM_SIZE;
        platform_width = cast,no_check(u16) lParam;
        platform_height = cast,no_check(u16) (lParam >> 16);

        renderer.resize();
      case WM_CREATE;
        platform_hwnd = hwnd;
        platform_hdc = GetDC(hwnd);

        dark_mode: s32 = xx true;
        DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, *dark_mode, size_of(type_of(dark_mode)));
        round_mode: s32 = DWMWCP_DONOTROUND;
        DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, *round_mode, size_of(type_of(round_mode)));

        renderer.init();
      case WM_DESTROY;
        renderer.deinit();

        PostQuitMessage(0);
      case WM_SYSCOMMAND;
        if wParam == SC_KEYMENU return 0;
        #through;
      case;
        return DefWindowProcW(hwnd, message, wParam, lParam);
    }
    return 0;
  };
  wndclass.hInstance = platform_hinstance;
  wndclass.hIcon = LoadIconW(xx null, IDI_WARNING);
  wndclass.hCursor = LoadCursorW(xx null, IDC_CROSS);
  wndclass.lpszClassName = u16.[#char "A", 0].data;
  RegisterClassExW(*wndclass);
  CreateWindowExW(0, wndclass.lpszClassName, u16.[#char "A", #char "s", #char "u", #char "n", #char "d", #char "e", #char "r", 0].data,
    WS_OVERLAPPEDWINDOW | WS_VISIBLE,
    CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
    xx null, xx null, platform_hinstance, xx null);

  while main_loop := true {
    clock_frame_begin: s64 = ---;
    QueryPerformanceCounter(*clock_frame_begin);

    msg: MSG = ---;
    while PeekMessageW(*msg, xx null, 0, 0, PM_REMOVE) {
      using msg;
      TranslateMessage(*msg);
      if message == {
        case WM_KEYDOWN; #through;
        case WM_KEYUP; #through;
        case WM_SYSKEYDOWN; #through;
        case WM_SYSKEYUP;
          pressed := lParam & (1 << 31) == 0;
          repeat := pressed && lParam & (1 << 30) != 0;
          sys := message == WM_SYSKEYDOWN || message == WM_SYSKEYUP;
          alt := sys && lParam & (1 << 29) != 0;

          if !repeat && (!sys || alt || wParam == VK_MENU || wParam == VK_F10) {
            if pressed {
              if wParam == VK_F4 && alt DestroyWindow(platform_hwnd);
              if DEBUG && wParam == VK_ESCAPE DestroyWindow(platform_hwnd);
              if wParam == VK_RETURN && alt toggle_fullscreen();
              if wParam == VK_F11 toggle_fullscreen();
            }
          }
        case WM_QUIT;
          break main_loop;
        case;
          DispatchMessageW(*msg);
      }
    }

    clock_current: s64 = ---;
    QueryPerformanceCounter(*clock_current);
    delta := cast(float32) (clock_current - clock_previous) / clock_frequency;
    defer clock_previous = clock_current;

    game_renderer: Game_Renderer;
    game_renderer.procs = renderer.game_procs;
    game_update_and_render(*game_renderer);

    renderer.present();

    clock_frame_end: s64 = ---;
    QueryPerformanceCounter(*clock_frame_end);

    if sleep_is_granular {
      ideal_frame_length_ms :: 7;

      frame_length_ms := (clock_frame_end - clock_frame_begin) / (clock_frequency / 1000);
      if ideal_frame_length_ms > frame_length_ms {
        Sleep(xx (ideal_frame_length_ms - frame_length_ms));
      }
    }
  }
}
