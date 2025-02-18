package opengl

// 1.0
DEPTH_BUFFER_BIT :: 0x00000100
COLOR_BUFFER_BIT :: 0x00004000
COLOR :: 0x1800
DEPTH :: 0x1801

NEAREST :: 0x2600

Enable: proc "c" (cap: u32)
Disable: proc "c" (cap: u32)
Clear: proc "c" (mask: u32)
Viewport: proc "c" (x, y: i32, w, h: u32)
GetIntegerv: proc "c" (name: u32, data: [^]i32)

load_1_0 :: proc "contextless" (get_proc_addr: $T) {
	Enable = cast(type_of(Enable)) get_proc_addr("glEnable")
	Disable = cast(type_of(Disable)) get_proc_addr("glDisable")
	Clear = cast(type_of(Clear)) get_proc_addr("glClear")
	Viewport = cast(type_of(Viewport)) get_proc_addr("glViewport")
	GetIntegerv = cast(type_of(GetIntegerv)) get_proc_addr("glGetIntegerv")
}

// 3.0
RGBA16F :: 0x881A
DEPTH_COMPONENT32F :: 0x8CAC
COLOR_ATTACHMENT0 :: 0x8CE0
DEPTH_ATTACHMENT :: 0x8D00
FRAMEBUFFER :: 0x8D40
RENDERBUFFER :: 0x8D41
FRAMEBUFFER_SRGB :: 0x8DB9

BindFramebuffer: proc "c" (index, framebuffer: u32)

load_3_0 :: proc "contextless" (get_proc_addr: $T) {
	BindFramebuffer = cast(type_of(BindFramebuffer)) get_proc_addr("glBindFramebuffer")
}

// 3.2
MAX_COLOR_TEXTURE_SAMPLES :: 0x910E
MAX_DEPTH_TEXTURE_SAMPLES :: 0x910F

// 4.5
CreateFramebuffers: proc "c" (n: u32, framebuffers: [^]u32)
NamedFramebufferRenderbuffer: proc "c" (framebuffer, attachment, target, renderbuffer: u32)
ClearNamedFramebufferfv: proc "c" (framebuffer, buffer: u32, index: i32, value: [^]f32)
BlitNamedFramebuffer: proc "c" (from, to: u32, x, y, w, h, x2, y2, w2, h2: i32, mask, filter: u32)
CreateRenderbuffers: proc "c" (n: u32, renderbuffers: [^]u32)
NamedRenderbufferStorageMultisample: proc "c" (renderbuffer, samples, internalformat, width, height: u32)

load_4_5 :: proc "contextless" (get_proc_addr: $T) {
	CreateFramebuffers = cast(type_of(CreateFramebuffers)) get_proc_addr("glCreateFramebuffers")
	NamedFramebufferRenderbuffer = cast(type_of(NamedFramebufferRenderbuffer)) get_proc_addr("glNamedFramebufferRenderbuffer")
	ClearNamedFramebufferfv = cast(type_of(ClearNamedFramebufferfv)) get_proc_addr("glClearNamedFramebufferfv")
	BlitNamedFramebuffer = cast(type_of(BlitNamedFramebuffer)) get_proc_addr("glBlitNamedFramebuffer")
	CreateRenderbuffers = cast(type_of(CreateRenderbuffers)) get_proc_addr("glCreateRenderbuffers")
	NamedRenderbufferStorageMultisample = cast(type_of(NamedRenderbufferStorageMultisample)) get_proc_addr("glNamedRenderbufferStorageMultisample")
}
