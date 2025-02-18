#+build linux, freebsd, openbsd, netbsd, haiku

package main

import X "../basic/x11"
import gl "../basic/opengl"

GLX_WINDOW_BIT :: 0x00000001
GLX_DRAWABLE_TYPE :: 0x8010
GLX_RENDER_TYPE :: 0x8011
GLX_RGBA_BIT :: 0x00000001
GLX_DOUBLEBUFFER :: 5
GLX_RED_SIZE :: 8
GLX_GREEN_SIZE :: 9
GLX_BLUE_SIZE :: 10

GLX_CONTEXT_MAJOR_VERSION_ARB :: 0x2091
GLX_CONTEXT_MINOR_VERSION_ARB :: 0x2092
GLX_CONTEXT_FLAGS_ARB :: 0x2094
GLX_CONTEXT_PROFILE_MASK_ARB :: 0x9126
GLX_CONTEXT_DEBUG_BIT_ARB :: 0x0001
GLX_CONTEXT_CORE_PROFILE_BIT_ARB :: 0x00000001

opengl_ctx: X.GLXContext

opengl_platform_init :: proc "contextless" () {
	@static attribs := [?]i32{
		GLX_DRAWABLE_TYPE, GLX_WINDOW_BIT,
		GLX_RENDER_TYPE,   GLX_RGBA_BIT,
		GLX_DOUBLEBUFFER,  1,
		GLX_RED_SIZE,      8,
		GLX_GREEN_SIZE,    8,
		GLX_BLUE_SIZE,     8,
		0,
	}
	vi := X.ChooseVisual(platform_display, X.DefaultScreen(platform_display), raw_data(attribs[:]))
	opengl_ctx = X.CreateContext(platform_display, vi, nil, true)
	X.MakeCurrent(platform_display, platform_window, opengl_ctx)

	gl.load_1_0(X.GetProcAddress)
	gl.load_2_0(X.GetProcAddress)
	gl.load_3_0(X.GetProcAddress)
	gl.load_4_2(X.GetProcAddress)
	gl.load_4_5(X.GetProcAddress)
}

opengl_platform_deinit :: proc "contextless" () {
	if opengl_ctx != nil do X.DestroyContext(platform_display, opengl_ctx)
	opengl_ctx = nil
}

opengl_platform_present :: proc "contextless" () {
	// X.SwapBuffers(platform_display, platform_window)
}
