package main

import w "core:sys/windows"
import gl "vendor:OpenGL"

WGL_CONTEXT_MAJOR_VERSION_ARB :: 0x2091
WGL_CONTEXT_MINOR_VERSION_ARB :: 0x2092
WGL_CONTEXT_FLAGS_ARB :: 0x2094
WGL_CONTEXT_PROFILE_MASK_ARB :: 0x9126
WGL_CONTEXT_DEBUG_BIT_ARB :: 0x0001
WGL_CONTEXT_CORE_PROFILE_BIT_ARB :: 0x00000001

opengl32: w.HMODULE
opengl_ctx: w.HGLRC

opengl_platform_init :: proc() {
	pfd: w.PIXELFORMATDESCRIPTOR
	pfd.nSize = size_of(w.PIXELFORMATDESCRIPTOR)
	pfd.nVersion = 1
	pfd.dwFlags = w.PFD_DRAW_TO_WINDOW | w.PFD_SUPPORT_OPENGL | w.PFD_DOUBLEBUFFER | w.PFD_DEPTH_DONTCARE
	pfd.cColorBits = 24
	format := w.ChoosePixelFormat(platform_hdc, &pfd)
	w.SetPixelFormat(platform_hdc, format, &pfd)

	temp_ctx := w.wglCreateContext(platform_hdc)
	defer w.wglDeleteContext(temp_ctx)
	w.wglMakeCurrent(platform_hdc, temp_ctx)

	wglCreateContextAttribsARB :=
		cast(proc "std" (hdc: w.HDC, share: w.HGLRC, attribs: [^]i32) -> w.HGLRC) w.wglGetProcAddress("wglCreateContextAttribsARB")

	@static attribs := []i32{
		WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
		WGL_CONTEXT_MINOR_VERSION_ARB, 6,
		WGL_CONTEXT_FLAGS_ARB, WGL_CONTEXT_DEBUG_BIT_ARB when ODIN_DEBUG else 0,
		WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
		0,
	}
	opengl_ctx = wglCreateContextAttribsARB(platform_hdc, nil, raw_data(attribs))
	w.wglMakeCurrent(platform_hdc, opengl_ctx)

	opengl32 = w.GetModuleHandleW(w.utf8_to_wstring("OPENGL32.DLL"))

	get_legacy_proc :: proc(p: rawptr, name: cstring) {
		(^proc())(p)^ = auto_cast w.GetProcAddress(opengl32, name)
	}

	get_modern_proc :: proc(p: rawptr, name: cstring) {
		(^proc())(p)^ = auto_cast w.wglGetProcAddress(name)
	}

	gl.load_1_0(get_legacy_proc)
	gl.load_3_0(get_modern_proc)
	gl.load_4_5(get_modern_proc)
}

opengl_platform_deinit :: proc() {
	if opengl_ctx != nil do w.wglDeleteContext(opengl_ctx)
	opengl_ctx = nil
}

opengl_platform_present :: proc() {
	w.SwapBuffers(platform_hdc)
}
