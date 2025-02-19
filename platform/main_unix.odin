#+build linux, freebsd, openbsd, netbsd, haiku

package main

import X "../basic/x11"

platform_display: ^X.Display
platform_screen: i32
platform_window: X.Window
platform_width: int
platform_height: int

main :: proc() {
	platform_display = X.OpenDisplay(nil)
	defer X.CloseDisplay(platform_display)
	platform_screen = X.DefaultScreen(platform_display)
	root := X.RootWindow(platform_display, platform_screen)

	attribs: X.SetWindowAttributes = ---
	attribs.event_mask = X.StructureNotifyMask
	platform_window = X.CreateWindow(platform_display, root, 0, 0, 1280, 720, 0, X.CopyFromParent, X.InputOutput, nil, X.CWEventMask, &attribs)
	X.MapWindow(platform_display, platform_window)

	wm_close_atom := X.InternAtom(platform_display, "WM_DELETE_WINDOW", false)
	X.SetWMProtocols(platform_display, platform_window, &wm_close_atom, 1)

	renderer.init()

	main_loop: for {
		for X.Pending(platform_display) > 0 {
			event: X.Event = ---
			X.NextEvent(platform_display, &event)
			switch event.type {
				case X.ConfigureNotify:
					if i32(platform_width) != event.xconfigure.width || i32(platform_height) != event.xconfigure.height {
						platform_width = int(event.xconfigure.width)
						platform_height = int(event.xconfigure.height)

						renderer.resize()
					}
				case X.ClientMessage:
					if cast(X.Atom) event.xclient.data.l[0] == wm_close_atom {
						renderer.deinit()
						break main_loop
					}
				case X.DestroyNotify:
					renderer.deinit()
					break main_loop
			}
		}

		renderer.present()
	}
}
