package game

Renderer :: struct {
	clear: proc(color0: [4]f32, depth: f32),
}

update_and_render :: proc(renderer: ^Renderer) {
	renderer.clear({0.6, 0.2, 0.2, 1.0}, 0.0)
}
