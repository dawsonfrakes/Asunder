package game

Rect_Texture :: enum u32 {
	WHITE = 0,
}

Renderer :: struct {
	clear: proc(color: [4]f32, depth: f32),
	rect: proc(position: [2]f32, size: [2]f32, texcoords: [2][2]f32, color: [4]f32, rotation: f32, texture_index: u32),
}

rect :: proc(renderer: ^Renderer, position: [2]f32, size: [2]f32, color: [4]f32, rotation: f32 = 0.0) {
	renderer.rect(position, size, {{0.0, 0.0}, {1.0, 1.0}}, color, rotation, 0)
}

trect :: proc(renderer: ^Renderer, texture: Rect_Texture, position: [2]f32, size: [2]f32, texcoords: [2][2]f32 = {{0.0, 0.0}, {1.0, 1.0}}, tint: [4]f32 = {1.0, 1.0, 1.0, 1.0}, rotation: f32 = 0.0) {
	renderer.rect(position, size, texcoords, tint, rotation, transmute(u32) texture)
}

update_and_render :: proc(renderer: ^Renderer) {
	renderer.clear({0.6, 0.2, 0.2, 1.0}, 0.0)
	rect(renderer, {500, 500}, {250, 250}, {1.0, 0.0, 0.0, 1.0})
	trect(renderer, .WHITE, {600, 600}, {250, 250})
	trect(renderer, .WHITE, {800, 800}, {250, 250})
}
