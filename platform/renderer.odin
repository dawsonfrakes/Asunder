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
    },
  }
  when RENDER_API != "NONE" do #panic("Unknown RENDER_API")
}
