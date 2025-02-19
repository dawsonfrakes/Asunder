package main

import gl "../basic/opengl"

opengl_init :: proc "contextless" () {
  opengl_platform_init()
}

opengl_deinit :: proc "contextless" () {
  opengl_platform_deinit()
}

opengl_resize :: proc "contextless" () {

}

opengl_present :: proc "contextless" () {
  if platform_width <= 0 || platform_height <= 0 do return

  w := cast(u32) platform_width
  h := cast(u32) platform_height

  gl.Viewport(0, 0, w, h)

  gl.Clear(0) // note: fixes intel driver bug

  opengl_platform_present()
}

opengl_clear :: proc(color0: [4]f32, depth: f32) {

}
