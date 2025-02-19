package opengl

// 1.0
Viewport: proc "c" (x, y: i32, w, h: u32)

load_1_0 :: proc "contextless" (get_proc_addr: $T) {
  Viewport = auto_cast get_proc_addr("glViewport")
}
