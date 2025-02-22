package game

Rect_Texture :: enum u32 {
	WHITE = 0,
	FONT = 1,
}

Renderer_Procs :: struct {
	clear: proc(color0: [4]f32, depth: f32),
	rect: proc(position: [2]f32, size: [2]f32, texcoords: [2][2]f32, color: [4]f32, texture: Rect_Texture, rotation: f32, z_index: f32),
}

Renderer :: struct {
	using procs: Renderer_Procs,
}
