// 1.0
GL_COLOR_BUFFER_BIT :: 0x00004000;
GL_COLOR :: 0x1800;
GL_DEPTH :: 0x1801;
GL_NEAREST :: 0x2600;

glClear: (mask: u32) #c_call;
glEnable: (cap: u32) #c_call;
glDisable: (cap: u32) #c_call;
glViewport: (x: s32, y: u32, w: u32, h: u32) #c_call;
glGetIntegerv: (name: u32, data: *s32) #c_call;

gl_load_1_0 :: (get_proc_addr: $T) #no_context {
  glClear = xx get_proc_addr("glClear");
  glEnable = xx get_proc_addr("glEnable");
  glDisable = xx get_proc_addr("glDisable");
  glViewport = xx get_proc_addr("glViewport");
  glGetIntegerv = xx get_proc_addr("glGetIntegerv");
}

// 2.0
GL_LOWER_LEFT :: 0x8CA1;

// 3.0
GL_RGBA16F :: 0x881A;
GL_DEPTH_COMPONENT32F :: 0x8CAC;
GL_COLOR_ATTACHMENT0 :: 0x8CE0;
GL_DEPTH_ATTACHMENT :: 0x8D00;
GL_FRAMEBUFFER :: 0x8D40;
GL_RENDERBUFFER :: 0x8D41;
GL_FRAMEBUFFER_SRGB :: 0x8DB9;

glBindFramebuffer: (target: u32, framebuffer: u32) #c_call;

gl_load_3_0 :: (get_proc_addr: $T) #no_context {
  glBindFramebuffer = xx get_proc_addr("glBindFramebuffer");
}

// 3.2
GL_MAX_COLOR_TEXTURE_SAMPLES :: 0x910E;
GL_MAX_DEPTH_TEXTURE_SAMPLES :: 0x910F;

// 4.5
GL_ZERO_TO_ONE :: 0x935F;

glClipControl: (origin: u32, depth: u32) #c_call;
glCreateFramebuffers: (n: u32, framebuffers: *u32) #c_call;
glNamedFramebufferRenderbuffer: (framebuffer: u32, attachment: u32, target: u32, renderbuffer: u32) #c_call;
glClearNamedFramebufferfv: (framebuffer: u32, buffer: u32, drawbuffer: s32, value: *float32) #c_call;
glBlitNamedFramebuffer: (from: u32, to: u32, ax: s32, ay: s32, aw: s32, ah: s32, bx: s32, by: s32, bw: s32, bh: s32, mask: u32, filter: u32) #c_call;
glCreateRenderbuffers: (n: u32, renderbuffers: *u32) #c_call;
glNamedRenderbufferStorageMultisample: (renderbuffer: u32, samples: u32, internalformat: u32, width: u32, height: u32) #c_call;

gl_load_4_5 :: (get_proc_addr: $T) #no_context {
  glClipControl = xx get_proc_addr("glClipControl");
  glCreateFramebuffers = xx get_proc_addr("glCreateFramebuffers");
  glNamedFramebufferRenderbuffer = xx get_proc_addr("glNamedFramebufferRenderbuffer");
  glClearNamedFramebufferfv = xx get_proc_addr("glClearNamedFramebufferfv");
  glBlitNamedFramebuffer = xx get_proc_addr("glBlitNamedFramebuffer");
  glCreateRenderbuffers = xx get_proc_addr("glCreateRenderbuffers");
  glNamedRenderbufferStorageMultisample = xx get_proc_addr("glNamedRenderbufferStorageMultisample");
}
