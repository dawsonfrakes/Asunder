package game

Renderer_Procs :: struct {
  clear: proc(color0: [4]f32, depth: f32),
}

Renderer :: struct {
  using procs: Renderer_Procs,
}

update_and_render :: proc(renderer: ^Renderer) {

}
