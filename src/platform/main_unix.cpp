#include "../modules/basic.hpp"

#define RENDER_API_NONE 0
#define RENDER_API_OPENGL 1
#define RENDER_API_VULKAN 2

#if !defined(RENDER_API)
#define RENDER_API RENDER_API_VULKAN
#endif

#include <stdio.h>
#include <unistd.h>
#include <X11/Xlib.h>

Atom wm_delete_window;

#if DEBUG
template<typename... Args> void debugf(string format, Args const&... args_) {
  string args[] = {args_...};

  s64 check_count = 0;
  for (s64 i = 0; i < format.count; i += 1) {
    if (format.data[i] == '%') {
      if (i + 1 < format.count && format.data[i + 1] != '%') {
        check_count += 1;
        continue;
      }
      i += 1;
    }
  }
  assertf(check_count == len(args), "Incorrect argument count for format string \"%\"", format);

  s64 arg_index = 0;
  for (s64 i = 0; i < format.count; i += 1) {
    if (format.data[i] == '%') {
      if (i + 1 < format.count && format.data[i + 1] != '%') {
        write(STDOUT_FILENO, args[arg_index].data, cast(u32) args[arg_index].count);
        arg_index += 1;
        continue;
      }
      i += 1;
    }
    write(STDOUT_FILENO, format.data + i, 1);
  }
  write(STDOUT_FILENO, "\n", 1);
}
#else
template<typename... Args> void debugf(string format, Args const&... args_) {
  (void) format;
  string args[] = {args_...};
  (void) args;
}
#endif

#if RENDER_API == RENDER_API_OPENGL
#include "renderer_opengl.cpp"
#define renderer_init opengl_init
#define renderer_deinit opengl_deinit
#define renderer_resize opengl_resize
#define renderer_present opengl_present
#elif RENDER_API == RENDER_API_VULKAN
#include "renderer_vulkan.cpp"
#define renderer_init vulkan_init
#define renderer_deinit vulkan_deinit
#define renderer_resize vulkan_resize
#define renderer_present vulkan_present
#endif

int main() {
  Display* display = XOpenDisplay(null);
  Window root = DefaultRootWindow(display);
  int screen = DefaultScreen(display);

  XSetWindowAttributes attributes;
  attributes.background_pixel = BlackPixel(display, screen);
  attributes.event_mask = KeyPressMask | KeyReleaseMask | PointerMotionMask | StructureNotifyMask | ButtonPressMask | ButtonReleaseMask | FocusChangeMask;
  Window window = XCreateWindow(display, root, 0, 0, 600, 400, 0, CopyFromParent, InputOutput, CopyFromParent, CWEventMask | CWBackPixel, &attributes);
  XStoreName(display, window, "Asunder");
  XMapWindow(display, window);
  wm_delete_window = XInternAtom(display, "WM_DELETE_WINDOW", false);
  XSetWMProtocols(display, window, &wm_delete_window, 1);

  for (;;) {
    while (XPending(display) > 0) {
      XEvent event;
      XNextEvent(display, &event);
      switch (event.type) {
        case DestroyNotify:
          goto main_loop_end;
        case ClientMessage: 
          if (cast(Atom) event.xclient.data.l[0] == wm_delete_window) {
            XDestroyWindow(display, window);
          }
          break;
      }
    }

    usleep(1000);
  }
main_loop_end:

  XCloseDisplay(display);
  return 0;
}
