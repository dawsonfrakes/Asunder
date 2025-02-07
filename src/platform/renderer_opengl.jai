#import "Basic";
#import "OpanGeeEll";

GLFuncs :: struct {
	glEnable: PFN_glEnable; @v1_0
	glDisable: PFN_glDisable; @v1_0
	glViewport: PFN_glViewport; @v1_0
	glGetIntegerv: PFN_glGetIntegerv; @v1_0

	#if DEBUG glDebugMessageCallback: PFN_glDebugMessageCallback; @v4_3

	glCreateFramebuffers: PFN_glCreateFramebuffers; @v4_5
	glNamedFramebufferRenderbuffer: PFN_glNamedFramebufferRenderbuffer; @v4_5
	glClearNamedFramebufferfv: PFN_glClearNamedFramebufferfv; @v4_5
	glBlitNamedFramebuffer: PFN_glBlitNamedFramebuffer; @v4_5
	glCreateRenderbuffers: PFN_glCreateRenderbuffers; @v4_5
	glNamedRenderbufferStorageMultisample: PFN_glNamedRenderbufferStorageMultisample; @v4_5
}

#if OS == .WINDOWS {
	WGL_CONTEXT_MAJOR_VERSION_ARB :: 0x2091;
	WGL_CONTEXT_MINOR_VERSION_ARB :: 0x2092;
	WGL_CONTEXT_FLAGS_ARB :: 0x2094;
	WGL_CONTEXT_PROFILE_MASK_ARB :: 0x9126;
	WGL_CONTEXT_DEBUG_BIT_ARB :: 0x0001;
	WGL_CONTEXT_CORE_PROFILE_BIT_ARB :: 0x00000001;

	GL :: struct {
		opengl_ctx: HGLRC;
		using funcs: GLFuncs;
	}
	using gl: GL;

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

		opengl32 := LoadLibraryA("opengl32");
		#insert -> string {
			b: String_Builder;
			for type_info(GLFuncs).members {
				if array_find(it.notes, "v1_0") || array_find(it.notes, "v1_1") {
					print_to_builder(*b, "%1 = xx GetProcAddress(opengl32, \"%1\");\n", it.name);
				} else {
					print_to_builder(*b, "%1 = xx wglGetProcAddress(\"%1\");\n", it.name);
				}
			}
			return builder_to_string(*b);
		}
	}

	opengl_platform_deinit :: () #no_context {
		if opengl_ctx wglDeleteContext(opengl_ctx);
		gl = .{};
	}

	opengl_platform_present :: () #no_context {
		SwapBuffers(platform_hdc);
	}
}

opengl_main_fbo: u32;
opengl_main_fbo_color0: u32;
opengl_main_fbo_depth: u32;

opengl_init :: () #no_context {
	opengl_platform_init();

	#if DEBUG {
		debug_callback :: (source: u32, type: u32, id: u32, severity: u32, length: u32, message: *u8, data: *void) #c_call {
			push_context { print("%\n", string.{length, message}); }
		}
		glDebugMessageCallback(debug_callback, null);
		glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS);
		glEnable(GL_DEBUG_OUTPUT);
	}

	glEnable(GL_FRAMEBUFFER_SRGB);
	glCreateFramebuffers(1, *opengl_main_fbo);
	glCreateRenderbuffers(1, *opengl_main_fbo_color0);
	glCreateRenderbuffers(1, *opengl_main_fbo_depth);
}

opengl_deinit :: () #no_context {
	opengl_platform_deinit();
}

opengl_resize :: () #no_context {
	if platform_width <= 0 || platform_height <= 0 return;

	min :: (a: $T, b: T) -> T #no_context { return ifx a < b a else b; }

	fbo_color_samples_max: s32;
	glGetIntegerv(GL_MAX_COLOR_TEXTURE_SAMPLES, *fbo_color_samples_max);
	fbo_depth_samples_max: s32;
	glGetIntegerv(GL_MAX_DEPTH_TEXTURE_SAMPLES, *fbo_depth_samples_max);
	fbo_samples: u32 = xx min(fbo_color_samples_max, fbo_depth_samples_max);

	glNamedRenderbufferStorageMultisample(opengl_main_fbo_color0, fbo_samples, GL_RGBA16F, xx platform_width, xx platform_height);
	glNamedFramebufferRenderbuffer(opengl_main_fbo, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, opengl_main_fbo_color0);

	glNamedRenderbufferStorageMultisample(opengl_main_fbo_depth, fbo_samples, GL_DEPTH_COMPONENT32F, xx platform_width, xx platform_height);
	glNamedFramebufferRenderbuffer(opengl_main_fbo, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, opengl_main_fbo_depth);
}

opengl_present :: () #no_context {
	glClearNamedFramebufferfv(opengl_main_fbo, GL_COLOR, 0, float.[0.6, 0.2, 0.2, 1.0].data);
	glClearNamedFramebufferfv(opengl_main_fbo, GL_DEPTH, 0, float.[0.0].data);

	glViewport(0, 0, xx platform_width, xx platform_height);

	glBlitNamedFramebuffer(opengl_main_fbo, 0,
		0, 0, platform_width, platform_height,
		0, 0, platform_width, platform_height,
		GL_COLOR_BUFFER_BIT, GL_NEAREST);
	opengl_platform_present();
}

opengl_renderer :: struct {
	init :: opengl_init;
	deinit :: opengl_deinit;
	resize :: opengl_resize;
	present :: opengl_present;
}
