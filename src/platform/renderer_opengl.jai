#if OS == .WINDOWS {
	WGL_CONTEXT_MAJOR_VERSION_ARB :: 0x2091;
	WGL_CONTEXT_MINOR_VERSION_ARB :: 0x2092;
	WGL_CONTEXT_FLAGS_ARB :: 0x2094;
	WGL_CONTEXT_PROFILE_MASK_ARB :: 0x9126;
	WGL_CONTEXT_DEBUG_BIT_ARB :: 0x0001;
	WGL_CONTEXT_CORE_PROFILE_BIT_ARB :: 0x00000001;
	WGL_CONTEXT_COMPATIBILITY_PROFILE_BIT_ARB :: 0x00000002;

	opengl_ctx: HGLRC;

	// 1.0
	GL_COLOR_BUFFER_BIT :: 0x00004000;
	GL_TRIANGLES :: 0x0004;

	glViewport: (x: s32, y: s32, w: u32, h: u32) #c_call;
	glClearColor: (r: float32, g: float32, b: float32, a: float32) #c_call;
	glClearDepth: (depth: float64) #c_call;
	glBegin: (mode: u32) #c_call;
	glEnd: () #c_call;
	glColor4f: (r: float32, g: float32, b: float32, a: float32) #c_call;
	glVertex3f: (x: float32, y: float32, z: float32) #c_call;
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
			WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_COMPATIBILITY_PROFILE_BIT_ARB,
			0,
		];
		opengl_ctx = wglCreateContextAttribsARB(platform_hdc, xx null, attribs.data);
		wglMakeCurrent(platform_hdc, opengl_ctx);

		opengl32 := LoadLibraryW((#run ascii_to_utf16lez_string_literal("opengl32")).data);
		glViewport = xx GetProcAddress(opengl32, "glViewport");
		glClearColor = xx GetProcAddress(opengl32, "glClearColor");
		glClearDepth = xx GetProcAddress(opengl32, "glClearDepth");
		glBegin = xx GetProcAddress(opengl32, "glBegin");
		glEnd = xx GetProcAddress(opengl32, "glEnd");
		glColor4f = xx GetProcAddress(opengl32, "glColor4f");
		glVertex3f = xx GetProcAddress(opengl32, "glVertex3f");
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

	opengl_platform_present();
}

opengl_clear :: inline (color: v4, depth: float32) {
	glClearColor(color.r, color.g, color.b, color.a);
	glClearDepth(depth);
	glClear(GL_COLOR_BUFFER_BIT);
}

RectTexture :: enum { WHITE :: 0; FONT :: 1; }

opengl_trect :: (x: float32, y: float32, w: float32, h: float32, tx1: float32, ty1: float32, tx2: float32, ty2: float32, texture: RectTexture, tint := v4.{1.0, 1.0, 1.0, 1.0}) {
	platform_width_divisor := cast(float32) max(1, platform_width - 1);
	platform_height_divisor := cast(float32) max(1, platform_height - 1);
	xmin := x / platform_width_divisor * 2.0 - 1.0;
	ymin := y / platform_height_divisor * 2.0 - 1.0;
	xmax := (x + w) / platform_width_divisor * 2.0 - 1.0;
	ymax := (y + h) / platform_height_divisor * 2.0 - 1.0;
	glBegin(GL_TRIANGLES);
		glColor4f(tint.r, tint.g, tint.b, tint.a);
		glVertex3f(xmin, ymin, 0.0);
		glVertex3f(xmax, ymin, 0.0);
		glVertex3f(xmax, ymax, 0.0);
		glVertex3f(xmax, ymax, 0.0);
		glVertex3f(xmin, ymax, 0.0);
		glVertex3f(xmin, ymin, 0.0);
	glEnd();
}

opengl_rect :: inline (x: float32, y: float32, w: float32, h: float32, color: v4) {
	opengl_trect(x, y, w, h, 0, 0, 1, 1, .WHITE, tint = color);
}

opengl_renderer :: struct {
	init :: opengl_init;
	deinit :: opengl_deinit;
	resize :: opengl_resize;
	present :: opengl_present;

	clear :: opengl_clear;
	rect :: opengl_rect;
	trect :: opengl_trect;
}
