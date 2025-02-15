// 1.0
#define GL_VENDOR 0x1F00
#define GL_RENDERER 0x1F01
#define GL_VERSION 0x1F02

#define GL10_FUNCTIONS \
  X(u8 const*, glGetString, u32) \
  X(void, glEnable, u32) \
  X(void, glDisable, u32)

// 4.3
#define GL_DEBUG_OUTPUT_SYNCHRONOUS 0x8242
#define GL_DEBUG_OUTPUT 0x92E0

typedef void (*GLDEBUGPROC)(u32, u32, u32, u32, u32, char const*, void const*);

#define GL43_FUNCTIONS \
  X(void, glDebugMessageCallback, GLDEBUGPROC, void*)

#if OS_WINDOWS
#define WGL_CONTEXT_MAJOR_VERSION_ARB 0x2091
#define WGL_CONTEXT_MINOR_VERSION_ARB 0x2092
#define WGL_CONTEXT_FLAGS_ARB 0x2094
#define WGL_CONTEXT_PROFILE_MASK_ARB 0x9126
#define WGL_CONTEXT_DEBUG_BIT_ARB 0x0001
#define WGL_CONTEXT_CORE_PROFILE_BIT_ARB 0x00000001

HGLRC opengl_ctx;
#define X(RET, NAME, ...) RET (*NAME)(__VA_ARGS__);
GL10_FUNCTIONS
GL43_FUNCTIONS
#undef X

void opengl_platform_init() {
  PIXELFORMATDESCRIPTOR pfd = {};
  pfd.nSize = size_of(PIXELFORMATDESCRIPTOR);
  pfd.nVersion = 1;
  pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER | PFD_DEPTH_DONTCARE;
  pfd.cColorBits = 24;
  s32 format = ChoosePixelFormat(platform_hdc, &pfd);
  SetPixelFormat(platform_hdc, format, &pfd);

  HGLRC temp_ctx = wglCreateContext(platform_hdc);
  wglMakeCurrent(platform_hdc, temp_ctx);

  HGLRC (WINAPI *wglCreateContextAttribsARB)(HDC, HGLRC, s32*) = cast(HGLRC (WINAPI *)(HDC, HGLRC, s32*)) wglGetProcAddress("wglCreateContextAttribsARB");

  static s32 attribs[] = {
    WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
    WGL_CONTEXT_MINOR_VERSION_ARB, 6,
    WGL_CONTEXT_FLAGS_ARB, WGL_CONTEXT_DEBUG_BIT_ARB,
    WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
    0,
  };
  opengl_ctx = wglCreateContextAttribsARB(platform_hdc, null, attribs);
  wglMakeCurrent(platform_hdc, opengl_ctx);

  HMODULE opengl32 = LoadLibraryW(L"opengl32");
  #define X(RET, NAME, ...) NAME = (RET (*)(__VA_ARGS__)) GetProcAddress(opengl32, #NAME);
  GL10_FUNCTIONS
  #undef X

  #define X(RET, NAME, ...) NAME = (RET (*)(__VA_ARGS__)) wglGetProcAddress(#NAME);
  GL43_FUNCTIONS
  #undef X

  wglDeleteContext(temp_ctx);
}

void opengl_platform_deinit() {
  wglDeleteContext(opengl_ctx);
}

void opengl_platform_present() {
  SwapBuffers(platform_hdc);
}
#endif

void opengl_debug_callback(u32 source, u32 type, u32 id, u32 severity, u32 length, char const* message, void const* param) {
  (void) source; (void) type; (void) id; (void) severity; (void) param;
  debugf("[OpenGL]: %", string(length, message));
}

void opengl_init() {
  opengl_platform_init();

  if (DEBUG) {
    glDebugMessageCallback(opengl_debug_callback, null);
    glEnable(GL_DEBUG_OUTPUT);
    glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS);

    debugf("[OpenGL]: %", glGetString(GL_VERSION));
    debugf("[OpenGL]: %", glGetString(GL_VENDOR));
    debugf("[OpenGL]: %", glGetString(GL_RENDERER));
  }
}

void opengl_deinit() {
  opengl_platform_deinit();
}

void opengl_resize() {

}

void opengl_present() {
  opengl_platform_present();
}
