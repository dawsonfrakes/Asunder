#include "../basic/opengl.h"

#if OS == OS_WINDOWS
#define WGL_CONTEXT_MAJOR_VERSION_ARB 0x2091
#define WGL_CONTEXT_MINOR_VERSION_ARB 0x2092
#define WGL_CONTEXT_FLAGS_ARB 0x2094
#define WGL_CONTEXT_PROFILE_MASK_ARB 0x9126
#define WGL_CONTEXT_DEBUG_BIT_ARB 0x0001
#define WGL_CONTEXT_CORE_PROFILE_BIT_ARB 0x00000001

HGLRC opengl_ctx;
#define X(RET, NAME, ...) RET (*NAME)(__VA_ARGS__);
GL10_FUNCTIONS
GL30_FUNCTIONS
GL45_FUNCTIONS
#undef X

void opengl_platform_init(void) {
	PIXELFORMATDESCRIPTOR pfd;
	zero(&pfd);
	pfd.nSize = size_of(PIXELFORMATDESCRIPTOR);
	pfd.nVersion = 1;
	pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER | PFD_DEPTH_DONTCARE;
	pfd.cColorBits = 24;
	s32 format = ChoosePixelFormat(platform_hdc, &pfd);
	SetPixelFormat(platform_hdc, format, &pfd);

	HGLRC temp_ctx = wglCreateContext(platform_hdc);
	wglMakeCurrent(platform_hdc, temp_ctx);

	HGLRC (WINAPI *wglCreateContextAttribsARB)(HDC, HGLRC, s32*) =
		cast(HGLRC (WINAPI *)(HDC, HGLRC, s32*))
		wglGetProcAddress("wglCreateContextAttribsARB");

	static s32 attribs[] = {
		WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
		WGL_CONTEXT_MINOR_VERSION_ARB, 6,
		WGL_CONTEXT_FLAGS_ARB, DEBUG ? WGL_CONTEXT_DEBUG_BIT_ARB : 0,
		WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
		0,
	};
	opengl_ctx = wglCreateContextAttribsARB(platform_hdc, null, attribs);
	wglMakeCurrent(platform_hdc, opengl_ctx);

	wglDeleteContext(temp_ctx);

	HMODULE opengl32 = GetModuleHandleW(L"OPENGL32.DLL");
	#define X(RET, NAME, ...) NAME = cast(RET (*)(__VA_ARGS__)) GetProcAddress(opengl32, #NAME);
	GL10_FUNCTIONS
	#undef X
	#define X(RET, NAME, ...) NAME = cast(RET (*)(__VA_ARGS__)) wglGetProcAddress(#NAME);
	GL30_FUNCTIONS
	GL45_FUNCTIONS
	#undef X
}

void opengl_platform_deinit(void) {
	if (opengl_ctx) wglDeleteContext(opengl_ctx);
	opengl_ctx = null;
}

void opengl_platform_present(void) {
	SwapBuffers(platform_hdc);
}
#endif

u32 opengl_main_fbo;
u32 opengl_main_fbo_color0;
u32 opengl_main_fbo_depth;

void opengl_init(void) {
	opengl_platform_init();

	glClipControl(GL_LOWER_LEFT, GL_ZERO_TO_ONE);

	glCreateFramebuffers(1, &opengl_main_fbo);
	glCreateRenderbuffers(1, &opengl_main_fbo_color0);
	glCreateRenderbuffers(1, &opengl_main_fbo_depth);
}

void opengl_deinit(void) {
	opengl_platform_deinit();
}

void opengl_resize(void) {
	if (platform_width <= 0 || platform_height <= 0) return;

	s32 fbo_color_samples_max;
	glGetIntegerv(GL_MAX_COLOR_TEXTURE_SAMPLES, &fbo_color_samples_max);
	s32 fbo_depth_samples_max;
	glGetIntegerv(GL_MAX_DEPTH_TEXTURE_SAMPLES, &fbo_depth_samples_max);
	u32 fbo_samples = cast(u32) min(fbo_color_samples_max, fbo_depth_samples_max);

	glNamedRenderbufferStorageMultisample(opengl_main_fbo_color0, fbo_samples, GL_RGBA16F, cast(u32) platform_width, cast(u32) platform_height);
	glNamedFramebufferRenderbuffer(opengl_main_fbo, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, opengl_main_fbo_color0);

	glNamedRenderbufferStorageMultisample(opengl_main_fbo_depth, fbo_samples, GL_DEPTH_COMPONENT32F, cast(u32) platform_width, cast(u32) platform_height);
	glNamedFramebufferRenderbuffer(opengl_main_fbo, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, opengl_main_fbo_depth);
}

void opengl_present(void) {
	if (platform_width <= 0 || platform_height <= 0) return;

	glBindFramebuffer(GL_FRAMEBUFFER, opengl_main_fbo);

	glBindFramebuffer(GL_FRAMEBUFFER, 0);

	glClear(0); // NOTE(dfra): fixes intel driver bug

	glEnable(GL_FRAMEBUFFER_SRGB);
	glBlitNamedFramebuffer(opengl_main_fbo, 0,
		0, 0, cast(s32) platform_width, cast(s32) platform_height,
		0, 0, cast(s32) platform_width, cast(s32) platform_height,
		GL_COLOR_BUFFER_BIT, GL_NEAREST);
	glDisable(GL_FRAMEBUFFER_SRGB);
	opengl_platform_present();
}

void opengl_clear(f32 color0[4], f32 depth) {
	glClearNamedFramebufferfv(opengl_main_fbo, GL_COLOR, 0, color0);
	glClearNamedFramebufferfv(opengl_main_fbo, GL_DEPTH, 0, &depth);
}
