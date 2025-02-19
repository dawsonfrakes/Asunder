package main

import "../basic/windows"
import gl "../basic/opengl"

opengl_ctx: windows.HGLRC
opengl32_lib: windows.HMODULE

opengl_platform_init :: proc "contextless" () {
  using windows

  pfd: PIXELFORMATDESCRIPTOR
  pfd.nSize = size_of(PIXELFORMATDESCRIPTOR)
  pfd.nVersion = 1
  pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER | PFD_DEPTH_DONTCARE
  pfd.cColorBits = 24
  format := ChoosePixelFormat(platform_hdc, &pfd)
  SetPixelFormat(platform_hdc, format, &pfd)

  temp_ctx := wglCreateContext(platform_hdc)
  defer wglDeleteContext(temp_ctx)
  wglMakeCurrent(platform_hdc, temp_ctx)

  wglCreateContextAttribsARB :=
    cast(proc "std" (hdc: HDC, share: HGLRC, attribs: [^]i32) -> HGLRC) wglGetProcAddress("wglCreateContextAttribsARB")

  @static attribs := [?]i32{
    0,
  }
  opengl_ctx = wglCreateContextAttribsARB(platform_hdc, nil, raw_data(attribs[:]))
  wglMakeCurrent(platform_hdc, opengl_ctx)

  opengl32_lib = GetModuleHandleW(raw_data([]u16{'o', 'p', 'e', 'n', 'g', 'l', '3', '2', 0}))

  get_legacy_proc :: proc "contextless" (name: cstring) -> windows.PROC {
    return GetProcAddress(opengl32_lib, name)
  }

  gl.load_1_0(get_legacy_proc)
  gl.load_4_5(wglGetProcAddress)
}

opengl_platform_deinit :: proc "contextless" () {
  if opengl_ctx != nil do windows.wglDeleteContext(opengl_ctx)
  opengl_ctx = nil
}

opengl_platform_present :: proc "contextless" () {
  windows.SwapBuffers(platform_hdc)
}
