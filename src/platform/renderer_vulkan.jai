#scope_file

#import "Basic";
#import "Vulkhan";

VK :: struct {
	vkGetInstanceProcAddr: PFN_vkGetInstanceProcAddr; @Exported
	vkCreateInstance: PFN_vkCreateInstance; @Global
	vkDestroyInstance: PFN_vkDestroyInstance; @Instance
	#if OS == .WINDOWS {
		vkCreateWin32SurfaceKHR: PFN_vkCreateWin32SurfaceKHR; @Instance
		vkDestroySurfaceKHR: PFN_vkDestroySurfaceKHR; @Instance
	}

	instance: VkInstance;
	surface: VkSurfaceKHR;
}
using vk: VK;

vulkan_init :: () #no_context {
	#if OS == .WINDOWS {
		vulkan_dll := LoadLibraryA("vulkan-1");

		#insert -> string {
			b: String_Builder;
			for type_info(VK).members {
				if array_find(it.notes, "Exported") {
					print_to_builder(*b, "%1 = xx GetProcAddress(vulkan_dll, \"%1\");\n", it.name);
				}
			}
			return builder_to_string(*b);
		}
	} else #assert(false);

	#insert -> string {
		b: String_Builder;
		for type_info(VK).members {
			if array_find(it.notes, "Global") {
				print_to_builder(*b, "%1 = xx vkGetInstanceProcAddr(xx null, \"%1\");\n", it.name);
			}
		}
		return builder_to_string(*b);
	}

	result: VkResult = ---;

	return_if_not_success_or :: ($also_success:  .. VkResult) #expand {
		if `result == .VK_SUCCESS return;
		for also_success if `result == it return;
		vulkan_deinit();
		`return;
	}

	{
		extensions :: (*u8).["VK_KHR_surface", "VK_KHR_win32_surface"];
		using info: VkInstanceCreateInfo;
		sType = .VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
		enabledExtensionCount = extensions.count;
		ppEnabledExtensionNames = extensions.data;
		result = vkCreateInstance(*info, null, *instance);
		return_if_not_success_or();
	}

	#insert -> string {
		b: String_Builder;
		for type_info(VK).members {
			if array_find(it.notes, "Instance") {
				print_to_builder(*b, "%1 = xx vkGetInstanceProcAddr(instance, \"%1\");\n", it.name);
			}
		}
		return builder_to_string(*b);
	}

	#if OS == .WINDOWS {{
		using info: VkWin32SurfaceCreateInfoKHR;
		sType = .VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR;
		hinstance = platform_hinstance;
		hwnd = platform_hwnd;
		result = vkCreateWin32SurfaceKHR(instance, *info, null, *surface);
		return_if_not_success_or();
	}}
}

vulkan_deinit :: () #no_context {
	if instance {
		if surface vkDestroySurfaceKHR(instance, surface, null);
		vkDestroyInstance(instance, null);
	}
	vk = .{};
}

vulkan_resize :: () #no_context {

}

vulkan_present :: () #no_context {

}

#scope_export

vulkan_renderer :: struct {
	init :: vulkan_init;
	deinit :: vulkan_deinit;
	resize :: vulkan_resize;
	present :: vulkan_present;
}
