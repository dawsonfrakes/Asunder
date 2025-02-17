#+build windows, linux, freebsd, openbsd, netbsd, haiku

package main

import gl "basic/opengl"
import "basic/windows"
import X "basic/x11"

when ODIN_OS == .Windows {
	WGL_CONTEXT_MAJOR_VERSION_ARB :: 0x2091
	WGL_CONTEXT_MINOR_VERSION_ARB :: 0x2092
	WGL_CONTEXT_FLAGS_ARB :: 0x2094
	WGL_CONTEXT_PROFILE_MASK_ARB :: 0x9126
	WGL_CONTEXT_DEBUG_BIT_ARB :: 0x0001
	WGL_CONTEXT_CORE_PROFILE_BIT_ARB :: 0x00000001

	opengl32: windows.HMODULE
	opengl_ctx: windows.HGLRC

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
			WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
			WGL_CONTEXT_MINOR_VERSION_ARB, 6,
			WGL_CONTEXT_FLAGS_ARB, WGL_CONTEXT_DEBUG_BIT_ARB,
			WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
			0,
		}
		opengl_ctx = wglCreateContextAttribsARB(platform_hdc, nil, raw_data(attribs[:]))
		wglMakeCurrent(platform_hdc, opengl_ctx)

		opengl32 = LoadLibraryW(raw_data([]u16{'o', 'p', 'e', 'n', 'g', 'l', '3', '2', 0}))

		get_legacy_proc :: proc "contextless" (name: cstring) -> rawptr {
			return cast(rawptr) GetProcAddress(opengl32, name)
		}
		get_modern_proc := wglGetProcAddress

		gl.load_1_0(get_legacy_proc)
		gl.load_4_5(get_modern_proc)
	}

	opengl_platform_deinit :: proc "contextless" () {
		if opengl_ctx != nil do windows.wglDeleteContext(opengl_ctx)
		opengl_ctx = nil
	}

	opengl_platform_present :: proc "contextless" () {
		windows.SwapBuffers(platform_hdc)
	}
} else {
  //opengl_ctx: X.GLXContext

	opengl_platform_init :: proc "contextless" () {
    using X
		/*opengl_ctx = glXCreateContext(platform_display)
		glXMakeCurrent(platform_display, platform_window, temp_ctx)

		gl.load_1_0(glXGetProcAddress)
		gl.load_4_5(glXGetProcAddress)*/
	}

	opengl_platform_deinit :: proc "contextless" () {
		//if opengl_ctx != nil do X.glXDeleteContext(platform_display, opengl_ctx)
		//opengl_ctx = nil
	}

	opengl_platform_present :: proc "contextless" () {
    //X.glXSwapBuffers(platform_display, platform_window)
	}
}

opengl_main_fbo: u32

opengl_init :: proc "contextless" () {
	opengl_platform_init()

	gl.CreateFramebuffers(1, &opengl_main_fbo)
}

opengl_deinit :: proc "contextless" () {
	opengl_platform_deinit()
}

opengl_resize :: proc "contextless" () {
	if platform_width <= 0 || platform_height <= 0 do return
}

opengl_present :: proc "contextless" () {
	if platform_width <= 0 || platform_height <= 0 do return

	w := cast(u32) platform_width
	h := cast(u32) platform_height

	gl.Viewport(0, 0, w, h)
	opengl_platform_present()
}
