#if OS == .WINDOWS {
	WGL_CONTEXT_MAJOR_VERSION_ARB :: 0x2091;
	WGL_CONTEXT_MINOR_VERSION_ARB :: 0x2092;
	WGL_CONTEXT_FLAGS_ARB :: 0x2094;
	WGL_CONTEXT_PROFILE_MASK_ARB :: 0x9126;
	WGL_CONTEXT_DEBUG_BIT_ARB :: 0x0001;
	WGL_CONTEXT_CORE_PROFILE_BIT_ARB :: 0x00000001;

	opengl_ctx: HGLRC;

	// 1.0
	GL_COLOR_BUFFER_BIT :: 0x00004000;

	glViewport: (x: s32, y: s32, w: u32, h: u32) #c_call;
	glClearColor: (r: float32, g: float32, b: float32, a: float32) #c_call;
	glClear: (mask: u32) #c_call;

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
			WGL_CONTEXT_FLAGS_ARB, WGL_CONTEXT_DEBUG_BIT_ARB,
			WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
			0,
		];
		opengl_ctx = wglCreateContextAttribsARB(platform_hdc, xx null, attribs.data);
		wglMakeCurrent(platform_hdc, opengl_ctx);

		opengl32 := LoadLibraryW((#run ascii_to_utf16lez_string_literal("opengl32")).data);
		glViewport = xx GetProcAddress(opengl32, "glViewport");
		glClearColor = xx GetProcAddress(opengl32, "glClearColor");
		glClear = xx GetProcAddress(opengl32, "glClear");
	}

	opengl_platform_deinit :: () #no_context {
		if opengl_ctx wglDeleteContext(opengl_ctx);
		opengl_ctx = xx null;
	}

	opengl_platform_present :: () #no_context {
		SwapBuffers(platform_hdc);
	}
} else #assert(false, "OpenGL is not supported on OS %.", OS);

opengl_init :: () #no_context {
	opengl_platform_init();
}

opengl_deinit :: () #no_context {
	opengl_platform_deinit();
}

opengl_resize :: () #no_context {
	if platform_width <= 0 || platform_height <= 0 return;
}

opengl_present :: () #no_context {
	if platform_width <= 1 || platform_height <= 1 return;

	glViewport(0, 0, xx platform_width, xx platform_height);
	glClearColor(1.0, 0.0, 1.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT);

	opengl_platform_present();
}

opengl_renderer :: struct {
	init :: opengl_init;
	deinit :: opengl_deinit;
	resize :: opengl_resize;
	present :: opengl_present;
}
