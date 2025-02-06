opengl_init :: () #no_context {

}

opengl_deinit :: () #no_context {

}

opengl_resize :: () #no_context {

}

opengl_present :: () #no_context {

}

opengl_renderer :: struct {
	init :: opengl_init;
	deinit :: opengl_deinit;
	resize :: opengl_resize;
	present :: opengl_present;
}
