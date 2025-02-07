#import "Basic";
#import "OpanGeeEll";

GLFuncs :: struct {
	glViewport: PFN_glViewport; @v1_0
	glCreateFramebuffers: PFN_glCreateFramebuffers; @v4_5
}

#if OS == .WINDOWS {
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

opengl_init :: () #no_context {
	opengl_platform_init();
}

opengl_deinit :: () #no_context {
	opengl_platform_deinit();
}

opengl_resize :: () #no_context {

}

opengl_present :: () #no_context {
	glViewport(0, 0, xx platform_width, xx platform_height);

	opengl_platform_present();
}

opengl_renderer :: struct {
	init :: opengl_init;
	deinit :: opengl_deinit;
	resize :: opengl_resize;
	present :: opengl_present;
}
