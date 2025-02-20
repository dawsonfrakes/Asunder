package main

import "../game"

when ODIN_OS == .Windows || ODIN_OS == .Linux ||
  ODIN_OS == .FreeBSD || ODIN_OS == .OpenBSD ||
  ODIN_OS == .NetBSD || ODIN_OS == .Haiku
{
  RENDER_API :: #config(RENDER_API, "OPENGL")
} else {
  RENDER_API :: #config(RENDER_API, "NONE")
}

Renderer :: struct {
  init: proc "contextless" (),
  deinit: proc "contextless" (),
  resize: proc "contextless" (),
  present: proc "contextless" (),
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
      rect = opengl_rect,
    },
  }
} else {
  renderer :: Renderer{
    init = proc "contextless" () {},
    deinit = proc "contextless" () {},
    resize = proc "contextless" () {},
    present = proc "contextless" () {},
    procs = {
      clear = proc(color0: [4]f32, depth: f32) {},
      rect = proc(position: [2]f32, size: [2]f32, color: [4]f32, texcoords: [2][2]f32, rotation: f32, texture: game.Rect_Texture) {},
    },
  }
  when RENDER_API != "NONE" do #panic("Unknown RENDER_API")
}
