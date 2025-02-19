package opengl

// 1.0
DEPTH_BUFFER_BIT :: 0x00000100
COLOR_BUFFER_BIT :: 0x00004000
TRIANGLES :: 0x0004
GEQUAL :: 0x0206
SRC_ALPHA :: 0x0302
ONE_MINUS_SRC_ALPHA :: 0x0303
CULL_FACE :: 0x0B44
DEPTH_TEST :: 0x0B71
BLEND :: 0x0BE2
TEXTURE_2D :: 0x0DE1
UNSIGNED_BYTE :: 0x1401
UNSIGNED_INT :: 0x1405
FLOAT :: 0x1406
COLOR :: 0x1800
DEPTH :: 0x1801
RGB :: 0x1907
RGBA :: 0x1908
POINT :: 0x1B00
LINE :: 0x1B01
FILL :: 0x1B02
KEEP :: 0x1E00
NEAREST :: 0x2600
LINEAR :: 0x2601

Clear: proc "c" (mask: u32)
Enable: proc "c" (cap: u32)
Disable: proc "c" (cap: u32)
Viewport: proc "c" (x, y: i32, w, h: u32)
GetIntegerv: proc "c" (name: u32, data: [^]i32)

load_1_0 :: proc "contextless" (get_proc_addr: $T) {
  Clear = auto_cast get_proc_addr("glClear")
  Enable = auto_cast get_proc_addr("glEnable")
  Disable = auto_cast get_proc_addr("glDisable")
  Viewport = auto_cast get_proc_addr("glViewport")
  GetIntegerv = auto_cast get_proc_addr("glGetIntegerv")
}

// 1.1
RGB8 :: 0x8051
RGBA8 :: 0x8058

// 1.2
BGR :: 0x80E0
BGRA :: 0x80E1

// 2.0
FRAGMENT_SHADER :: 0x8B30
VERTEX_SHADER :: 0x8B31
LOWER_LEFT :: 0x8CA1

// 3.0
RGBA16F :: 0x881A
DEPTH_COMPONENT32F :: 0x8CAC
COLOR_ATTACHMENT0 :: 0x8CE0
DEPTH_ATTACHMENT :: 0x8D00
FRAMEBUFFER :: 0x8D40
RENDERBUFFER :: 0x8D41
FRAMEBUFFER_SRGB :: 0x8DB9

BindFramebuffer: proc "c" (target, fbo: u32)
BindVertexArray: proc "c" (vao: u32)

load_3_0 :: proc "contextless" (get_proc_addr: $T) {
  BindFramebuffer = auto_cast get_proc_addr("glBindFramebuffer")
  BindVertexArray = auto_cast get_proc_addr("glBindVertexArray")
}

// 3.2
MAX_COLOR_TEXTURE_SAMPLES ::0x910E
MAX_DEPTH_TEXTURE_SAMPLES ::0x910F

// 4.5
ZERO_TO_ONE :: 0x935F

ClipControl: proc "c" (origin, depth: u32)
CreateFramebuffers: proc "c" (n: u32, framebuffers: [^]u32)
NamedFramebufferRenderbuffer: proc "c" (framebuffer, attachment, target, renderbuffer: u32)
ClearNamedFramebufferfv: proc "c" (framebuffer, buffer: u32, drawbuffer: i32, value: [^]f32)
BlitNamedFramebuffer: proc "c" (from, to: u32, x1, y1, w1, h1, x2, y2, w2, h2: i32, mask, filter: u32)
CreateRenderbuffers: proc "c" (n: u32, renderbuffers: [^]u32)
NamedRenderbufferStorageMultisample: proc "c" (renderbuffer, samples, internalformat, width, height: u32)

load_4_5 :: proc "contextless" (get_proc_addr: $T) {
  ClipControl = auto_cast get_proc_addr("glClipControl")
  CreateFramebuffers = auto_cast get_proc_addr("glCreateFramebuffers")
  NamedFramebufferRenderbuffer = auto_cast get_proc_addr("glNamedFramebufferRenderbuffer")
  ClearNamedFramebufferfv = auto_cast get_proc_addr("glClearNamedFramebufferfv")
  BlitNamedFramebuffer = auto_cast get_proc_addr("glBlitNamedFramebuffer")
  CreateRenderbuffers = auto_cast get_proc_addr("glCreateRenderbuffers")
  NamedRenderbufferStorageMultisample = auto_cast get_proc_addr("glNamedRenderbufferStorageMultisample")
}
