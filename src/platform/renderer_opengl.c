#if TARGET_OS_WINDOWS
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
}

void opengl_platform_deinit(void) {

}

void opengl_platform_present(void) {
	SwapBuffers(platform_hdc);
}
#endif

void opengl_init(void) {
	opengl_platform_init();
}

void opengl_deinit(void) {
	opengl_platform_deinit();
}

void opengl_resize(void) {

}

void opengl_present(void) {
	opengl_platform_present();
}
