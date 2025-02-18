package game

Rect_Texture :: enum {
	WHITE = 0,
	FONT = 1,
}

Renderer :: struct {
	clear: proc(color0: [4]f32, depth: f32),
	rect: proc(position: [3]f32, size: [2]f32, texcoords: [2][2]f32, texture: Rect_Texture, color: [4]f32, rotation: f32),
}

rect :: proc(renderer: ^Renderer, position: [2]f32, size: [2]f32, color: [4]f32, rotation: f32 = 0.0, z_index: f32 = -1.0) {
	renderer.rect({position.x, position.y, z_index}, size, {{0.0, 0.0}, {1.0, 1.0}}, .WHITE, color, rotation)
}

trect :: proc(renderer: ^Renderer, texture: Rect_Texture, position: [2]f32, size: [2]f32, texcoords: [2][2]f32, color: [4]f32 = 1.0, rotation: f32 = 0.0, z_index: f32 = -1.0) {
	renderer.rect({position.x, position.y, z_index}, size, texcoords, texture, color, rotation)
}

update_and_render :: proc(renderer: ^Renderer) {
	renderer.clear({0.6, 0.2, 0.2, 1.0}, 0.0)
	rect(renderer, {100, 100}, {100, 100}, {1.0, 0.0, 0.0, 1.0})
	trect(renderer, .FONT, {500, 500}, {100, 100}, {{0.0, 0.0}, {1.0, 1.0}})
}
