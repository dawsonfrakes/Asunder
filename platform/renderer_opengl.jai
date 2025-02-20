opengl_renderer :: struct {
  init :: opengl_init;
  deinit :: opengl_deinit;
  resize :: opengl_resize;
  present :: opengl_present;
  procs :: Game_Renderer.Procs.{
    clear = opengl_clear,
  };
}

#scope_file

#import "GL";

#if OS == .WINDOWS {
  WGL_CONTEXT_MAJOR_VERSION_ARB :: 0x2091;
  WGL_CONTEXT_MINOR_VERSION_ARB :: 0x2092;
  WGL_CONTEXT_FLAGS_ARB :: 0x2094;
  WGL_CONTEXT_PROFILE_MASK_ARB :: 0x9126;
  WGL_CONTEXT_DEBUG_BIT_ARB :: 0x0001;
  WGL_CONTEXT_CORE_PROFILE_BIT_ARB :: 0x00000001;

  opengl_ctx: HGLRC;

  opengl_platform_init :: () #no_context {
    pfd: PIXELFORMATDESCRIPTOR;
    pfd.nSize = size_of(PIXELFORMATDESCRIPTOR);
    pfd.nVersion = 1;
    pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER | PFD_DEPTH_DONTCARE;
    pfd.cColorBits = 24;
    format := ChoosePixelFormat(platform_hdc, *pfd);
    SetPixelFormat(platform_hdc, format, *pfd);

    temp_ctx := wglCreateContext(platform_hdc);
    defer wglDeleteContext(temp_ctx);
    wglMakeCurrent(platform_hdc, temp_ctx);

    wglCreateContextAttribsARB :=
      cast(#type (HDC, HGLRC, *s32) -> HGLRC #c_call)
      wglGetProcAddress("wglCreateContextAttribsARB");

    attribs :: s32.[
      WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
      WGL_CONTEXT_MINOR_VERSION_ARB, 6,
      WGL_CONTEXT_FLAGS_ARB, #ifx DEBUG WGL_CONTEXT_DEBUG_BIT_ARB else 0,
      WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
      0,
    ];
    opengl_ctx = wglCreateContextAttribsARB(platform_hdc, xx null, attribs.data);
    wglMakeCurrent(platform_hdc, opengl_ctx);
  }

  opengl_platform_deinit :: () #no_context {
    if opengl_ctx wglDeleteContext(opengl_ctx);
    opengl_ctx = xx null;
  }

  opengl_platform_present :: () #no_context {
    SwapBuffers(platform_hdc);
  }
}

using gl;

opengl_main_fbo: u32;
opengl_main_fbo_color0: u32;
opengl_main_fbo_depth: u32;

opengl_init :: () #no_context {
  opengl_platform_init();
  push_context .{} { gl_load(*gl); }

  glCreateFramebuffers(1, *opengl_main_fbo);
  glCreateRenderbuffers(1, *opengl_main_fbo_color0);
  glCreateRenderbuffers(1, *opengl_main_fbo_depth);
}

opengl_deinit :: () #no_context {
  opengl_platform_deinit();
}

opengl_resize :: () #no_context {
  if platform_width <= 0 || platform_height <= 0 return;

  fbo_max_color_samples: s32 = ---;
  glGetIntegerv(GL_MAX_COLOR_TEXTURE_SAMPLES, *fbo_max_color_samples);
  fbo_max_depth_samples: s32 = ---;
  glGetIntegerv(GL_MAX_DEPTH_TEXTURE_SAMPLES, *fbo_max_depth_samples);
  fbo_samples := cast(u32) min(fbo_max_color_samples, fbo_max_depth_samples);

  glNamedRenderbufferStorageMultisample(opengl_main_fbo_color0, fbo_samples, GL_RGBA16F, cast(u32) platform_width, cast(u32) platform_height);
  glNamedFramebufferRenderbuffer(opengl_main_fbo, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, opengl_main_fbo_color0);

  glNamedRenderbufferStorageMultisample(opengl_main_fbo_depth, fbo_samples, GL_DEPTH_COMPONENT32F, cast(u32) platform_width, cast(u32) platform_height);
  glNamedFramebufferRenderbuffer(opengl_main_fbo, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, opengl_main_fbo_depth);
}

opengl_present :: () #no_context {
  if platform_width <= 0 || platform_height <= 0 return;

  color0 :: float32.[0.6, 0.2, 0.2, 1.0];
  glClearNamedFramebufferfv(opengl_main_fbo, GL_COLOR, 0, color0.data);
  depth :: float32.[0.0];
  glClearNamedFramebufferfv(opengl_main_fbo, GL_DEPTH, 0, depth.data);

  glClear(0);

  glEnable(GL_FRAMEBUFFER_SRGB);
  glBlitNamedFramebuffer(opengl_main_fbo, 0,
    0, 0, cast(s32) platform_width, cast(s32) platform_height,
    0, 0, cast(s32) platform_width, cast(s32) platform_height,
    GL_COLOR_BUFFER_BIT, GL_NEAREST);
  glDisable(GL_FRAMEBUFFER_SRGB);
  opengl_platform_present();
}

opengl_clear :: (color0: [4]float32, depth: float32) {

}
