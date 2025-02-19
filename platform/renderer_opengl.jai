opengl_renderer :: struct {
  init :: opengl_init;
  deinit :: opengl_deinit;
  resize :: opengl_resize;
  present :: opengl_present;
  game_procs :: Game_Renderer.Procs.{
    clear = opengl_clear,
  };
}

#scope_file

#import "OpenGeeEll";

#if OS == {
  case .WINDOWS;
    WGL_CONTEXT_MAJOR_VERSION_ARB :: 0x2091;
    WGL_CONTEXT_MINOR_VERSION_ARB :: 0x2092;
    WGL_CONTEXT_FLAGS_ARB :: 0x2094;
    WGL_CONTEXT_PROFILE_MASK_ARB :: 0x9126;
    WGL_CONTEXT_DEBUG_BIT_ARB :: 0x0001;
    WGL_CONTEXT_CORE_PROFILE_BIT_ARB :: 0x00000001;

    opengl_ctx: HGLRC;
    opengl32_lib: HMODULE;

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
        cast(#type (hdc: HDC, share: HGLRC, attribs: *s32) -> HGLRC #c_call)
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

      opengl32_lib = GetModuleHandleW(u16.[#char "o", #char "p", #char "e", #char "n", #char "g", #char "l", #char "3", #char "2", 0].data);

      get_legacy_proc :: (name: *u8) -> PROC #no_context {
        return GetProcAddress(opengl32_lib, name);
      }

      gl_load_1_0(get_legacy_proc);
      gl_load_3_0(wglGetProcAddress);
      gl_load_4_5(wglGetProcAddress);
    }

    opengl_platform_deinit :: () #no_context {
      if opengl_ctx wglDeleteContext(opengl_ctx);
      opengl_ctx = xx null;
    }

    opengl_platform_present :: () #no_context {
      SwapBuffers(platform_hdc);
    }
  case .LINUX;
    GLX_CONTEXT_MAJOR_VERSION_ARB :: 0x2091;
    GLX_CONTEXT_MINOR_VERSION_ARB :: 0x2092;
    GLX_CONTEXT_FLAGS_ARB :: 0x2094;
    GLX_CONTEXT_PROFILE_MASK_ARB :: 0x9126;
    GLX_CONTEXT_DEBUG_BIT_ARB :: 0x0001;
    GLX_CONTEXT_CORE_PROFILE_BIT_ARB :: 0x00000001;

    opengl_ctx: GLXContext;

    opengl_platform_init :: () #no_context {
      glXCreateContextAttribsARB :=
        cast(#type (display: *Display, config: GLXFBConfig, share: GLXContext, direct: s32, attribs: *s32) -> GLXContext #c_call)
        glXGetProcAddress("glXCreateContextAttribsARB");

      attribs :: s32.[
        GLX_CONTEXT_MAJOR_VERSION_ARB, 4,
        GLX_CONTEXT_MINOR_VERSION_ARB, 6,
        GLX_CONTEXT_FLAGS_ARB, #ifx DEBUG GLX_CONTEXT_DEBUG_BIT_ARB else 0,
        GLX_CONTEXT_PROFILE_MASK_ARB, GLX_CONTEXT_CORE_PROFILE_BIT_ARB,
        0,
      ];
      opengl_ctx = glXCreateContextAttribsARB(platform_display, opengl_fbconfig, null, xx true, attribs.data);
      glXMakeCurrent(platform_display, platform_window, opengl_ctx);

      gl_load_1_0(glXGetProcAddress);
      gl_load_3_0(glXGetProcAddress);
      gl_load_4_5(glXGetProcAddress);
    }

    opengl_platform_deinit :: () #no_context {
      glXMakeCurrent(platform_display, 0, null);
      if opengl_ctx glXDestroyContext(platform_display, opengl_ctx);
      opengl_ctx = null;
    }

    opengl_platform_present :: () #no_context {
      glXSwapBuffers(platform_display, platform_window);
    }
  case;
    #assert(false, "Target % is not supported", OS);
}

opengl_main_fbo: u32;
opengl_main_fbo_color0: u32;
opengl_main_fbo_depth: u32;

opengl_init :: () #no_context {
  opengl_platform_init();

  glClipControl(GL_LOWER_LEFT, GL_ZERO_TO_ONE);

  glCreateFramebuffers(1, *opengl_main_fbo);
  glCreateRenderbuffers(1, *opengl_main_fbo_color0);
  glCreateRenderbuffers(1, *opengl_main_fbo_depth);
}

opengl_deinit :: () #no_context {
  opengl_platform_deinit();
}

opengl_resize :: () #no_context {
  if platform_width <= 0 || platform_height <= 0 return;

  fbo_color_samples_max: s32 = ---;
  glGetIntegerv(GL_MAX_COLOR_TEXTURE_SAMPLES, *fbo_color_samples_max);
  fbo_depth_samples_max: s32 = ---;
  glGetIntegerv(GL_MAX_DEPTH_TEXTURE_SAMPLES, *fbo_depth_samples_max);
  fbo_samples := cast(u32) min(fbo_color_samples_max, fbo_depth_samples_max);

  glNamedRenderbufferStorageMultisample(opengl_main_fbo_color0, fbo_samples, GL_RGBA16F, xx platform_width, xx platform_height);
  glNamedFramebufferRenderbuffer(opengl_main_fbo, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, opengl_main_fbo_color0);

  glNamedRenderbufferStorageMultisample(opengl_main_fbo_depth, fbo_samples, GL_DEPTH_COMPONENT32F, xx platform_width, xx platform_height);
  glNamedFramebufferRenderbuffer(opengl_main_fbo, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, opengl_main_fbo_depth);
}

opengl_present :: () #no_context {
  if platform_width <= 0 || platform_height <= 0 return;

  glBindFramebuffer(GL_FRAMEBUFFER, opengl_main_fbo);

  glBindFramebuffer(GL_FRAMEBUFFER, 0);

  glClear(0); // note: fixes intel driver bug

  glEnable(GL_FRAMEBUFFER_SRGB);
  glBlitNamedFramebuffer(opengl_main_fbo, 0,
    0, 0, xx platform_width, xx platform_height,
    0, 0, xx platform_width, xx platform_height,
    GL_COLOR_BUFFER_BIT, GL_NEAREST);
  glDisable(GL_FRAMEBUFFER_SRGB);

  opengl_platform_present();
}

opengl_clear :: (color0: [4]float32, depth: float32) {
  glClearNamedFramebufferfv(opengl_main_fbo, GL_COLOR, 0, color0.data);
  glClearNamedFramebufferfv(opengl_main_fbo, GL_DEPTH, 0, *depth);
}
