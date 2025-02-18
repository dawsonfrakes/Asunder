#+build linux, freebsd, openbsd, netbsd, haiku

package main

RENDER_API :: #config(RENDER_API, "OPENGL")

import X "../basic/x11"

platform_display: ^X.Display
platform_window: X.Window
platform_width: i32
platform_height: i32

when RENDER_API == "OPENGL" {
	renderer_init :: opengl_init
	renderer_deinit :: opengl_deinit
	renderer_resize :: opengl_resize
	renderer_present :: opengl_present
	renderer_clear :: opengl_clear
	renderer_rect :: opengl_rect
} else when RENDER_API == "NONE" {
	renderer_init :: proc "contextless" () {}
	renderer_deinit :: proc "contextless" () {}
	renderer_resize :: proc "contextless" () {}
	renderer_present :: proc "contextless" () {}
	renderer_clear :: proc(color0: [4]f32, depth: f32) {}
	renderer_rect :: proc(position: [3]f32, size: [2]f32, texcoords: [2][2]f32, texture: game.Rect_Texture, color: [4]f32, rotation: f32) {}
} else do #panic("Invalid RENDER_API")

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

	renderer_init()

	main_loop: for {
		for X.Pending(platform_display) > 0 {
			event: X.Event = ---
			X.NextEvent(platform_display, &event)
			switch event.type {
				case X.ConfigureNotify:
					w := event.xconfigure.width
					h := event.xconfigure.height

					if w != platform_width || h != platform_height {
						platform_width, platform_height = w, h
						renderer_resize()
					}
				case X.ClientMessage:
					if transmute(X.Atom) event.xclient.data.l[0] == wm_close_atom {
						X.DestroyWindow(platform_display, platform_window)
					}
				case X.DestroyNotify:
					renderer_deinit()
					break main_loop
				case:
			}
		}

		renderer_present()
	}
}
