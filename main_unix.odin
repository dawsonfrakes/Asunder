#+build linux, freebsd, openbsd, netbsd, haiku

package main

import "core:fmt"
import X "basic/x11"

platform_display: ^X.Display
platform_window: X.Window
platform_close_window_atom: X.Atom
platform_width: int
platform_height: int

main :: proc() {
  platform_display = X.OpenDisplay(nil)
  defer X.CloseDisplay(platform_display)
  screen := X.DefaultScreen(platform_display)
  root := X.RootWindow(platform_display)

  attributes: X.SetWindowAttributes = ---
  attributes.background_pixel = X.BlackPixel(platform_display, screen)
  attributes.event_mask = X.StructureNotifyMask
  platform_window = X.CreateWindow(platform_display, root, 0, 0, 1280, 720, 0, X.CopyFromParent, X.InputOutput, nil, X.CWEventMask | X.CWBackPixel, &attributes)
  X.StoreName(platform_display, platform_window, "Asunder")
  X.MapWindow(platform_display, platform_window)

  platform_close_window_atom = X.InternAtom(platform_display, "WM_DELETE_WINDOW", false)
  X.SetWMProtocols(platform_display, platform_window, &platform_close_window_atom, 1)

  main_loop: for {
    for X.Pending(platform_display) > 0 {
      event: X.Event = ---
      X.NextEvent(platform_display, &event)
      switch event.type {
        case X.ConfigureNotify:
          platform_width = cast(int) event.xconfigure.width
          platform_height = cast(int) event.xconfigure.height
        case X.ClientMessage:
          fmt.println(event.xclient, event.xclient.data.l)
          if cast(X.Atom) event.xclient.data.l[0] == platform_close_window_atom {
            X.DestroyWindow(platform_display, platform_window)
          }
        case X.DestroyNotify:
          break main_loop
        case:
      }
    }
  }
}
