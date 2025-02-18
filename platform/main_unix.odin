#+build linux, freebsd, openbsd, netbsd, haiku

package main

import X "../basic/x11"

platform_display: ^X.Display
platform_window: X.Window

main :: proc() {
	platform_display = X.OpenDisplay(nil)
	defer X.CloseDisplay(platform_display)
	screen := X.DefaultScreen(platform_display)
	root := X.RootWindow(platform_display)

	attribs: X.SetWindowAttributes = ---
	attribs.background_pixel = X.BlackPixel(platform_display, screen)
	attribs.event_mask = X.StructureNotifyMask
	platform_window = X.CreateWindow(platform_display, root, 0, 0, 1280, 720, 0, X.CopyFromParent, X.InputOutput, nil, X.CWEventMask | X.CWBackPixel, &attribs)
	X.MapWindow(platform_display, platform_window)

	wm_close_atom := X.InternAtom(platform_display, "WM_DELETE_WINDOW", false)
	X.SetWMProtocols(platform_display, platform_window, &wm_close_atom, 1)

	main_loop: for {
		for X.Pending(platform_display) > 0 {
			event: X.Event = ---
			X.NextEvent(platform_display, &event)
			switch event.type {
				case X.ClientMessage:
					if transmute(X.Atom) event.xclient.data.l[0] == wm_close_atom {
						X.DestroyWindow(platform_display, platform_window)
					}
				case X.DestroyNotify:
					break main_loop
				case:
			}
		}
	}
}
