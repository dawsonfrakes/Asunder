#include "basic/opengl.h"

#if TARGET_OS_WINDOWS
#define X(RET, NAME, ...) RET (WINAPI *NAME)(__VA_ARGS__);
GL10_FUNCTIONS
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

	HMODULE opengl32 = GetModuleHandleW(L"opengl32");
	#define X(RET, NAME, ...) NAME = cast(RET (WINAPI *)(__VA_ARGS__)) GetProcAddress(opengl32, #NAME);
	GL10_FUNCTIONS
	#undef X

	#define X(RET, NAME, ...) NAME = cast(RET (WINAPI *)(__VA_ARGS__)) wglGetProcAddress(#NAME);
	GL45_FUNCTIONS
	#undef X
}

void opengl_platform_deinit(void) {

}

void opengl_platform_present(void) {
	SwapBuffers(platform_hdc);
}
#else
#error Check implementation.
#endif

void opengl_init(void) {
	opengl_platform_init();
}

void opengl_deinit(void) {
	opengl_platform_deinit();
}

void opengl_resize(void) {
	if (platform_width <= 0 || platform_height <= 0) return;
}

void opengl_present(void) {
	if (platform_width <= 0 || platform_height <= 0) return;

	glViewport(0, 0, cast(u32) platform_width, cast(u32) platform_height);
	opengl_platform_present();
}
