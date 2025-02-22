package main

import "../game"

when ODIN_OS == .Windows {
	RENDER_API :: #config(RENDER_API, "OPENGL")
} else {
	RENDER_API :: #config(RENDER_API, "UNKNOWN")
}

Renderer :: struct {
	init: proc(),
	deinit: proc(),
	resize: proc(),
	present: proc(),
	procs: game.Renderer_Procs,
}

when RENDER_API == "OPENGL" {
	renderer :: Renderer{
		init = opengl_init,
		deinit = opengl_deinit,
		resize = opengl_resize,
		present = opengl_present,
		procs = {
			clear = opengl_clear,
		},
	}
} else {
	renderer :: Renderer{
		init = proc() {},
		deinit = proc() {},
		resize = proc() {},
		present = proc() {},
		procs = {
			clear = proc(color0: [4]f32, depth: f32) {}
		},
	}
	#assert(RENDER_API == "NONE", "RENDER_API is not valid");
}
