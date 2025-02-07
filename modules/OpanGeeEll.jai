// 1.0
GL_COLOR_BUFFER_BIT :: 0x00004000;
GL_COLOR :: 0x1800;
GL_DEPTH :: 0x1801;
GL_NEAREST :: 0x2600;

PFN_glEnable :: #type (index: u32) #c_call;
PFN_glDisable :: #type (index: u32) #c_call;
PFN_glViewport :: #type (x: s32, y: s32, w: u32, h: u32) #c_call;
PFN_glGetIntegerv :: #type (index: u32, value: *s32) #c_call;

// 3.0
GL_RGBA16F :: 0x881A;
GL_DEPTH_COMPONENT32F :: 0x8CAC;
GL_COLOR_ATTACHMENT0 :: 0x8CE0;
GL_DEPTH_ATTACHMENT :: 0x8D00;
GL_FRAMEBUFFER :: 0x8D40;
GL_RENDERBUFFER :: 0x8D41;
GL_FRAMEBUFFER_SRGB :: 0x8DB9;

// 3.2
GL_MAX_COLOR_TEXTURE_SAMPLES :: 0x910E;
GL_MAX_DEPTH_TEXTURE_SAMPLES :: 0x910F;

// 4.3
GLDEBUGPROC :: #type (source: u32, type: u32, id: u32, severity: u32, length: u32, message: *u8, data: *void) #c_call;

GL_DEBUG_OUTPUT_SYNCHRONOUS :: 0x8242;
GL_DEBUG_OUTPUT :: 0x92E0;

PFN_glDebugMessageCallback :: #type (callback: GLDEBUGPROC, data: *void) #c_call;

// 4.5
PFN_glCreateFramebuffers :: #type (n: u32, framebuffers: *u32) #c_call;
PFN_glNamedFramebufferRenderbuffer :: #type (fbo: u32, attachment: u32, target: u32, rbo: u32) #c_call;
PFN_glClearNamedFramebufferfv :: #type (fbo: u32, type: u32, index: s32, value: *float) #c_call;
PFN_glBlitNamedFramebuffer :: #type (from: u32, to: u32, x1: s32, y1: s32, w1: s32, h1: s32, x2: s32, y2: s32, w2: s32, h2: s32, bits: u32, filter: u32) #c_call;
PFN_glCreateRenderbuffers :: #type (n: u32, renderbuffers: *u32) #c_call;
PFN_glNamedRenderbufferStorageMultisample :: #type (rbo: u32, samples: u32, iformat: u32, w: u32, h: u32) #c_call;
