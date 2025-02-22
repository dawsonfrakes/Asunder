package game

Renderer_Procs :: struct {
	clear: proc(color0: [4]f32, depth: f32),
	// rect: proc(),
}

Renderer :: struct {
	using procs: Renderer_Procs,
}
