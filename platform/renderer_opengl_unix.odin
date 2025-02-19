#+build linux, freebsd, openbsd, netbsd, haiku

package main

import X "../basic/x11"
import gl "../basic/opengl"
import glX "../basic/glx"

GLX_CONTEXT_MAJOR_VERSION_ARB :: 0x2091
GLX_CONTEXT_MINOR_VERSION_ARB :: 0x2092
GLX_CONTEXT_FLAGS_ARB :: 0x2094
GLX_CONTEXT_PROFILE_MASK_ARB :: 0x9126
GLX_CONTEXT_DEBUG_BIT_ARB :: 0x0001
GLX_CONTEXT_CORE_PROFILE_BIT_ARB :: 0x00000001

opengl_ctx: glX.Context

opengl_platform_init :: proc "contextless" () {
	@static fbattribs := [?]i32{
		glX.DOUBLEBUFFER, 1,
		glX.RED_SIZE, 8,
		glX.GREEN_SIZE, 8,
		glX.BLUE_SIZE, 8,
		0,
	}
	fbcount: i32 = ---
	fbconfigs := glX.ChooseFBConfig(platform_display, platform_screen, raw_data(fbattribs[:]), &fbcount)
	fbconfig := fbconfigs[0]

	glXCreateContextAttribsARB :=
		cast(proc "c" (display: ^X.Display, config: glX.FBConfig, share: glX.Context, direct: b32, attributes: [^]i32) -> glX.Context) glX.GetProcAddress("glXCreateContextAttribsARB")

	@static attribs := [?]i32{
		GLX_CONTEXT_MAJOR_VERSION_ARB, 4,
		GLX_CONTEXT_MINOR_VERSION_ARB, 6,
		GLX_CONTEXT_FLAGS_ARB, GLX_CONTEXT_DEBUG_BIT_ARB when ODIN_DEBUG else 0,
		GLX_CONTEXT_PROFILE_MASK_ARB, GLX_CONTEXT_CORE_PROFILE_BIT_ARB,
		0,
	}
	opengl_ctx = glXCreateContextAttribsARB(platform_display, fbconfig, nil, true, raw_data(attribs[:]))
	glX.MakeCurrent(platform_display, platform_window, opengl_ctx)

	gl.load_1_0(glX.GetProcAddress)
	gl.load_4_5(glX.GetProcAddress)
}

opengl_platform_deinit :: proc "contextless" () {
	if opengl_ctx != nil do glX.DestroyContext(platform_display, opengl_ctx)
	opengl_ctx = nil
}

opengl_platform_present :: proc "contextless" () {
	glX.SwapBuffers(platform_display, platform_window)
}
