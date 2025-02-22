#+build windows, linux, freebsd, openbsd, netbsd, haiku
package main

import gl "vendor:OpenGL"

opengl_main_fbo: u32
opengl_main_fbo_color0: u32
opengl_main_fbo_depth: u32

opengl_init :: proc() {
	opengl_platform_init()

	gl.ClipControl(gl.LOWER_LEFT, gl.ZERO_TO_ONE)

	gl.CreateFramebuffers(1, &opengl_main_fbo)
	gl.CreateRenderbuffers(1, &opengl_main_fbo_color0)
	gl.CreateRenderbuffers(1, &opengl_main_fbo_depth)
}

opengl_deinit :: proc() {
	opengl_platform_deinit()
}

opengl_resize :: proc() {
	if platform_size.x <= 0 || platform_size.y <= 0 do return

	fbo_color_samples_max: i32 = ---
	gl.GetIntegerv(gl.MAX_COLOR_TEXTURE_SAMPLES, &fbo_color_samples_max)
	fbo_depth_samples_max: i32 = ---
	gl.GetIntegerv(gl.MAX_DEPTH_TEXTURE_SAMPLES, &fbo_depth_samples_max)
	fbo_samples := min(fbo_color_samples_max, fbo_depth_samples_max)

	gl.NamedRenderbufferStorageMultisample(opengl_main_fbo_color0, fbo_samples, gl.RGBA16F, i32(platform_size.x), i32(platform_size.y))
	gl.NamedFramebufferRenderbuffer(opengl_main_fbo, gl.COLOR_ATTACHMENT0, gl.RENDERBUFFER, opengl_main_fbo_color0)

	gl.NamedRenderbufferStorageMultisample(opengl_main_fbo_depth, fbo_samples, gl.RGBA16F, i32(platform_size.x), i32(platform_size.y))
	gl.NamedFramebufferRenderbuffer(opengl_main_fbo, gl.COLOR_ATTACHMENT0, gl.RENDERBUFFER, opengl_main_fbo_depth)
}

opengl_present :: proc() {
	if platform_size.x <= 0 || platform_size.y <= 0 do return

	gl.BindFramebuffer(gl.FRAMEBUFFER, opengl_main_fbo)

	gl.BindFramebuffer(gl.FRAMEBUFFER, 0)

	gl.Clear(0) // NOTE(dfra): fixes intel driver bug

	gl.Enable(gl.FRAMEBUFFER_SRGB)
	gl.BlitNamedFramebuffer(opengl_main_fbo, 0,
		0, 0, i32(platform_size.x), i32(platform_size.y),
		0, 0, i32(platform_size.x), i32(platform_size.y),
		gl.COLOR_BUFFER_BIT, gl.NEAREST)
	gl.Disable(gl.FRAMEBUFFER_SRGB)

	opengl_platform_present()
}

opengl_clear :: proc(color: [4]f32, depth: f32) {
	color, depth := color, depth
	gl.ClearNamedFramebufferfv(opengl_main_fbo, gl.COLOR, 0, raw_data(color[:]))
	gl.ClearNamedFramebufferfv(opengl_main_fbo, gl.DEPTH, 0, &depth)
}
