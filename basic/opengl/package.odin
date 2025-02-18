package opengl

// 1.0
DEPTH_BUFFER_BIT :: 0x00000100
COLOR_BUFFER_BIT :: 0x00004000

Clear: proc "c" (mask: u32)
ClearColor: proc "c" (r, g, b, a: f32)
ClearDepth: proc "c" (depth: f64)
Viewport: proc "c" (x, y: i32, w, h: u32)

load_1_0 :: proc "contextless" (get_proc_addr: $T) {
	Clear = cast(type_of(Clear)) get_proc_addr("glClear")
	ClearColor = cast(type_of(ClearColor)) get_proc_addr("glClearColor")
	ClearDepth = cast(type_of(ClearDepth)) get_proc_addr("glClearDepth")
	Viewport = cast(type_of(Viewport)) get_proc_addr("glViewport")
}

// 4.5
CreateFramebuffers: proc "c" (n: u32, framebuffers: [^]u32)

load_4_5 :: proc "contextless" (get_proc_addr: $T) {
	CreateFramebuffers = cast(type_of(CreateFramebuffers)) get_proc_addr("glCreateFramebuffers")
}
