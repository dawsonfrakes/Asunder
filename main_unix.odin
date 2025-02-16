#+build linux, freebsd, openbsd, netbsd, haiku

package main

import "core:time"
import "X"

platform_display: ^X.Display
platform_window: X.Window

main :: proc() {
  platform_display = X.OpenDisplay(nil)
  defer X.CloseDisplay(platform_display)
  root := X.RootWindow(platform_display)

  platform_window = X.CreateWindow(platform_display, root, 0, 0, 600, 400, 0, X.CopyFromParent, X.InputOutput, cast(^X.Visual) cast(uintptr) X.CopyFromParent, 0, nil)
  X.MapWindow(platform_display, platform_window)

  for {
    for X.Pending(platform_display) > 0 {
      event: X.Event = ---
      X.NextEvent(platform_display, &event)
      switch event.type {
        case:
      }
    }

    time.sleep(1 * time.Millisecond)
  }
}
