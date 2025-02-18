#+build !darwin

package main

import gl "../basic/opengl"

opengl_main_fbo: u32

opengl_init :: proc "contextless" () {
	opengl_platform_init()

	gl.CreateFramebuffers(1, &opengl_main_fbo)
}

opengl_deinit :: proc "contextless" () {
	opengl_platform_deinit()
}

opengl_resize :: proc "contextless" () {

}

opengl_present :: proc "contextless" () {
	gl.Viewport(0, 0, cast(u32) platform_width, cast(u32) platform_height)

	opengl_platform_present()
}

opengl_clear :: proc(color0: [4]f32, depth: f32) {
	gl.ClearColor(color0.r, color0.g, color0.b, color0.a)
	gl.ClearDepth(cast(f64) depth)
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
}
