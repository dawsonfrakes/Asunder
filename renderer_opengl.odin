package main

import "core:sys/windows"
import gl "vendor:OpenGL"

when ODIN_OS == .Windows {
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

		wglCreateContextAttribsARB = auto_cast wglGetProcAddress("wglCreateContextAttribsARB")

		@static attribs := [?]i32{
			WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
			WGL_CONTEXT_MINOR_VERSION_ARB, 6,
			WGL_CONTEXT_FLAGS_ARB, WGL_CONTEXT_DEBUG_BIT_ARB,
			WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
			0,
		}

		opengl_ctx = wglCreateContextAttribsARB(platform_hdc, nil, raw_data(attribs[:]))
		wglMakeCurrent(platform_hdc, opengl_ctx)

		opengl32_name :: []u16{'o', 'p', 'e', 'n', 'g', 'l', '3', '2', 0}
		opengl32 = LoadLibraryW(raw_data(opengl32_name))

		load_legacy :: proc(p: rawptr, name: cstring) {
			(cast(^proc()) p)^ = auto_cast GetProcAddress(opengl32, name)
		}

		load_modern :: proc(p: rawptr, name: cstring) {
			(cast(^proc()) p)^ = auto_cast wglGetProcAddress(name)
		}

		context = {}
		gl.load_1_0(load_legacy)
		gl.load_1_1(load_legacy)
		gl.load_4_5(load_modern)
	}

	opengl_platform_deinit :: proc "contextless" () {
		using windows

		wglDeleteContext(opengl_ctx)
	}

	opengl_platform_present :: proc "contextless" () {
		using windows

		SwapBuffers(platform_hdc)
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

}

opengl_present :: proc "contextless" () {
	opengl_platform_present()
}
