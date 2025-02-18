package opengl

// 1.0
Viewport: proc "c" (x, y: i32, w, h: u32)

load_1_0 :: proc "contextless" (get_proc_addr: $T) {
	Viewport = cast(type_of(Viewport)) get_proc_addr("glViewport")
}

// 4.5
CreateFramebuffers: proc "c" (n: u32, framebuffers: [^]u32)

load_4_5 :: proc "contextless" (get_proc_addr: $T) {
	CreateFramebuffers = cast(type_of(CreateFramebuffers)) get_proc_addr("glCreateFramebuffers")
}
