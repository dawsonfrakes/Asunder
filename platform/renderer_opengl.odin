#+build windows, linux, freebsd, openbsd, netbsd, haiku

package main

import gl "../basic/opengl"

opengl_main_fbo: u32
opengl_main_fbo_color0: u32
opengl_main_fbo_depth: u32

opengl_init :: proc "contextless" () {
  opengl_platform_init()

  gl.ClipControl(gl.LOWER_LEFT, gl.ZERO_TO_ONE)

  gl.CreateFramebuffers(1, &opengl_main_fbo)
  gl.CreateRenderbuffers(1, &opengl_main_fbo_color0)
  gl.CreateRenderbuffers(1, &opengl_main_fbo_depth)
}

opengl_deinit :: proc "contextless" () {
  opengl_platform_deinit()
}

opengl_resize :: proc "contextless" () {
  if platform_width <= 0 || platform_height <= 0 do return

  w := u32(platform_width)
  h := u32(platform_height)

  fbo_color_samples_max: i32 = ---
  gl.GetIntegerv(gl.MAX_COLOR_TEXTURE_SAMPLES, &fbo_color_samples_max)
  fbo_depth_samples_max: i32 = ---
  gl.GetIntegerv(gl.MAX_DEPTH_TEXTURE_SAMPLES, &fbo_depth_samples_max)
  fbo_samples := u32(min(fbo_color_samples_max, fbo_depth_samples_max))

  gl.NamedRenderbufferStorageMultisample(opengl_main_fbo_color0, fbo_samples, gl.RGBA16F, w, h)
  gl.NamedFramebufferRenderbuffer(opengl_main_fbo, gl.COLOR_ATTACHMENT0, gl.RENDERBUFFER, opengl_main_fbo_color0)

  gl.NamedRenderbufferStorageMultisample(opengl_main_fbo_depth, fbo_samples, gl.DEPTH_COMPONENT32F, w, h)
  gl.NamedFramebufferRenderbuffer(opengl_main_fbo, gl.DEPTH_ATTACHMENT, gl.RENDERBUFFER, opengl_main_fbo_depth)
}

opengl_present :: proc "contextless" () {
  if platform_width <= 0 || platform_height <= 0 do return

  w := u32(platform_width)
  h := u32(platform_height)

  gl.Viewport(0, 0, w, h)

  gl.BindFramebuffer(gl.FRAMEBUFFER, opengl_main_fbo)

  gl.BindFramebuffer(gl.FRAMEBUFFER, 0)

  gl.Clear(0) // note: fixes intel driver bug

  gl.Enable(gl.FRAMEBUFFER_SRGB)
  gl.BlitNamedFramebuffer(opengl_main_fbo, 0,
    0, 0, i32(w), i32(h),
    0, 0, i32(w), i32(h),
    gl.COLOR_BUFFER_BIT, gl.NEAREST)
  gl.Disable(gl.FRAMEBUFFER_SRGB)

  opengl_platform_present()
}

opengl_clear :: proc(color0: [4]f32, depth: f32) {
  color0, depth := color0, depth
  gl.ClearNamedFramebufferfv(opengl_main_fbo, gl.COLOR, 0, raw_data(color0[:]))
  gl.ClearNamedFramebufferfv(opengl_main_fbo, gl.DEPTH, 0, &depth)
}
