vulkan_init :: () #no_context {

}

vulkan_deinit :: () #no_context {

}

vulkan_resize :: () #no_context {

}

vulkan_present :: () #no_context {

}

vulkan_renderer :: struct {
	init :: vulkan_init;
	deinit :: vulkan_deinit;
	resize :: vulkan_resize;
	present :: vulkan_present;
}
