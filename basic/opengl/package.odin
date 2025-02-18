package opengl

// 1.0
DEPTH_BUFFER_BIT :: 0x00000100
COLOR_BUFFER_BIT :: 0x00004000
TRIANGLES :: 0x0004
SRC_ALPHA :: 0x0302
ONE_MINUS_SRC_ALPHA :: 0x0303

BLEND :: 0x0BE2
TEXTURE_2D :: 0x0DE1
UNSIGNED_BYTE :: 0x1401
UNSIGNED_INT :: 0x1405
FLOAT :: 0x1406
COLOR :: 0x1800
DEPTH :: 0x1801
RGB :: 0x1907
RGBA :: 0x1908
NEAREST :: 0x2600

Enable: proc "c" (cap: u32)
Disable: proc "c" (cap: u32)
Clear: proc "c" (mask: u32)
Viewport: proc "c" (x, y: i32, w, h: u32)
GetIntegerv: proc "c" (name: u32, data: [^]i32)
BlendFunc: proc "c" (sfactor, dfactor: u32)

load_1_0 :: proc "contextless" (get_proc_addr: $T) {
	Enable = cast(type_of(Enable)) get_proc_addr("glEnable")
	Disable = cast(type_of(Disable)) get_proc_addr("glDisable")
	Clear = cast(type_of(Clear)) get_proc_addr("glClear")
	Viewport = cast(type_of(Viewport)) get_proc_addr("glViewport")
	GetIntegerv = cast(type_of(GetIntegerv)) get_proc_addr("glGetIntegerv")
	BlendFunc = cast(type_of(BlendFunc)) get_proc_addr("glBlendFunc")
}

// 1.1
RGBA8 :: 0x8058

// 1.2
BGR :: 0x80E0
BGRA :: 0x80E1

// 1.5
STREAM_DRAW :: 0x88E0
STATIC_DRAW :: 0x88E4

// 2.0
FRAGMENT_SHADER :: 0x8B30
VERTEX_SHADER :: 0x8B31

CreateProgram: proc "c" () -> u32
AttachShader: proc "c" (program, shader: u32)
DetachShader: proc "c" (program, shader: u32)
LinkProgram: proc "c" (program: u32)
UseProgram: proc "c" (program: u32)
CreateShader: proc "c" (kind: u32) -> u32
DeleteShader: proc "c" (shader: u32)
ShaderSource: proc "c" (shader, count: u32, strings: [^]cstring, lengths: [^]i32)
CompileShader: proc "c" (shader: u32)

load_2_0 :: proc "contextless" (get_proc_addr: $T) {
	CreateProgram = cast(type_of(CreateProgram)) get_proc_addr("glCreateProgram")
	AttachShader = cast(type_of(AttachShader)) get_proc_addr("glAttachShader")
	DetachShader = cast(type_of(DetachShader)) get_proc_addr("glDetachShader")
	LinkProgram = cast(type_of(LinkProgram)) get_proc_addr("glLinkProgram")
	UseProgram = cast(type_of(UseProgram)) get_proc_addr("glUseProgram")
	CreateShader = cast(type_of(CreateShader)) get_proc_addr("glCreateShader")
	DeleteShader = cast(type_of(DeleteShader)) get_proc_addr("glDeleteShader")
	ShaderSource = cast(type_of(ShaderSource)) get_proc_addr("glShaderSource")
	CompileShader = cast(type_of(CompileShader)) get_proc_addr("glCompileShader")
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
BindVertexArray: proc "c" (vao: u32)

load_3_0 :: proc "contextless" (get_proc_addr: $T) {
	BindFramebuffer = cast(type_of(BindFramebuffer)) get_proc_addr("glBindFramebuffer")
	BindVertexArray = cast(type_of(BindVertexArray)) get_proc_addr("glBindVertexArray")
}

// 3.2
MAX_COLOR_TEXTURE_SAMPLES :: 0x910E
MAX_DEPTH_TEXTURE_SAMPLES :: 0x910F

// 4.2
DrawElementsInstancedBaseVertexBaseInstance: proc "c" (mode, count, type: u32, indices: rawptr, instancecount: u32, basevertex: i32, baseinstance: u32)

load_4_2 :: proc "contextless" (get_proc_addr: $T) {
	DrawElementsInstancedBaseVertexBaseInstance = cast(type_of(DrawElementsInstancedBaseVertexBaseInstance)) get_proc_addr("glDrawElementsInstancedBaseVertexBaseInstance")
}

// 4.5
CreateFramebuffers: proc "c" (n: u32, framebuffers: [^]u32)
NamedFramebufferRenderbuffer: proc "c" (framebuffer, attachment, target, renderbuffer: u32)
ClearNamedFramebufferfv: proc "c" (framebuffer, buffer: u32, index: i32, value: [^]f32)
BlitNamedFramebuffer: proc "c" (from, to: u32, x, y, w, h, x2, y2, w2, h2: i32, mask, filter: u32)
CreateRenderbuffers: proc "c" (n: u32, renderbuffers: [^]u32)
NamedRenderbufferStorageMultisample: proc "c" (renderbuffer, samples, internalformat, width, height: u32)
CreateVertexArrays: proc "c" (n: u32, arrays: [^]u32)
VertexArrayElementBuffer: proc "c" (vao, ebo: u32)
VertexArrayVertexBuffer: proc "c" (vao, binding, buffer: u32, offset: int, stride: u32)
VertexArrayBindingDivisor: proc "c" (vao, binding, divisor: u32)
EnableVertexArrayAttrib: proc "c" (vao, attrib: u32)
VertexArrayAttribBinding: proc "c" (vao, attrib, binding: u32)
VertexArrayAttribFormat: proc "c" (vao, attrib: u32, size: i32, type: u32, normalized: bool, offset: u32)
VertexArrayAttribIFormat: proc "c" (vao, attrib: u32, size: i32, type: u32, offset: u32)
CreateBuffers: proc "c" (n: u32, buffers: [^]u32)
NamedBufferData: proc "c" (buffer: u32, size: uintptr, data: rawptr, usage: u32)
CreateTextures: proc "c" (kind, count: u32, textures: [^]u32)
TextureStorage2D: proc "c" (texture, levels, internalformat, width, height: u32)
TextureSubImage2D: proc "c" (texture: u32, level, xoffset, yoffset: i32, width, height, format, type: u32, pixels: rawptr)
BindTextureUnit: proc "c" (unit, texture: u32)
ProgramUniform1i: proc "c" (program: u32, location, v0: i32)

load_4_5 :: proc "contextless" (get_proc_addr: $T) {
	CreateFramebuffers = cast(type_of(CreateFramebuffers)) get_proc_addr("glCreateFramebuffers")
	NamedFramebufferRenderbuffer = cast(type_of(NamedFramebufferRenderbuffer)) get_proc_addr("glNamedFramebufferRenderbuffer")
	ClearNamedFramebufferfv = cast(type_of(ClearNamedFramebufferfv)) get_proc_addr("glClearNamedFramebufferfv")
	BlitNamedFramebuffer = cast(type_of(BlitNamedFramebuffer)) get_proc_addr("glBlitNamedFramebuffer")
	CreateRenderbuffers = cast(type_of(CreateRenderbuffers)) get_proc_addr("glCreateRenderbuffers")
	NamedRenderbufferStorageMultisample = cast(type_of(NamedRenderbufferStorageMultisample)) get_proc_addr("glNamedRenderbufferStorageMultisample")
	CreateVertexArrays = cast(type_of(CreateVertexArrays)) get_proc_addr("glCreateVertexArrays")
	VertexArrayElementBuffer = cast(type_of(VertexArrayElementBuffer)) get_proc_addr("glVertexArrayElementBuffer")
	VertexArrayVertexBuffer = cast(type_of(VertexArrayVertexBuffer)) get_proc_addr("glVertexArrayVertexBuffer")
	VertexArrayBindingDivisor = cast(type_of(VertexArrayBindingDivisor)) get_proc_addr("glVertexArrayBindingDivisor")
	EnableVertexArrayAttrib = cast(type_of(EnableVertexArrayAttrib)) get_proc_addr("glEnableVertexArrayAttrib")
	VertexArrayAttribBinding = cast(type_of(VertexArrayAttribBinding)) get_proc_addr("glVertexArrayAttribBinding")
	VertexArrayAttribFormat = cast(type_of(VertexArrayAttribFormat)) get_proc_addr("glVertexArrayAttribFormat")
	VertexArrayAttribIFormat = cast(type_of(VertexArrayAttribIFormat)) get_proc_addr("glVertexArrayAttribIFormat")
	CreateBuffers = cast(type_of(CreateBuffers)) get_proc_addr("glCreateBuffers")
	NamedBufferData = cast(type_of(NamedBufferData)) get_proc_addr("glNamedBufferData")
	CreateTextures = cast(type_of(CreateTextures)) get_proc_addr("glCreateTextures")
	TextureStorage2D = cast(type_of(TextureStorage2D)) get_proc_addr("glTextureStorage2D")
	TextureSubImage2D = cast(type_of(TextureSubImage2D)) get_proc_addr("glTextureSubImage2D")
	BindTextureUnit = cast(type_of(BindTextureUnit)) get_proc_addr("glBindTextureUnit")
	ProgramUniform1i = cast(type_of(ProgramUniform1i)) get_proc_addr("glProgramUniform1i")
}
