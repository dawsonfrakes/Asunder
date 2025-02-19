package opengl

// 1.0
Clear: proc "c" (mask: u32)
Viewport: proc "c" (x, y: i32, w, h: u32)

load_1_0 :: proc "contextless" (get_proc_addr: $T) {
  Clear = auto_cast get_proc_addr("glClear")
  Viewport = auto_cast get_proc_addr("glViewport")
}

// 4.5
ClipControl: proc "c" (origin, depth: u32)

load_4_5 :: proc "contextless" (get_proc_addr: $T) {
  ClipControl = auto_cast get_proc_addr("glClipControl")
}
