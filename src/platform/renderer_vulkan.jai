#scope_file

#import "Basic";
#import "Vulkhan";

VK :: struct {
	vkGetInstanceProcAddr: PFN_vkGetInstanceProcAddr; @Exported
	vkCreateInstance: PFN_vkCreateInstance; @Global
	vkDestroyInstance: PFN_vkDestroyInstance; @Instance
	#if DEBUG {
		vkCreateDebugUtilsMessengerEXT: PFN_vkCreateDebugUtilsMessengerEXT; @Instance
		vkDestroyDebugUtilsMessengerEXT: PFN_vkDestroyDebugUtilsMessengerEXT; @Instance
	}
	#if OS == .WINDOWS {
		vkCreateWin32SurfaceKHR: PFN_vkCreateWin32SurfaceKHR; @Instance
		vkDestroySurfaceKHR: PFN_vkDestroySurfaceKHR; @Instance
	}

	instance: VkInstance;
	surface: VkSurfaceKHR;
	#if DEBUG debug_messenger: VkDebugUtilsMessengerEXT;
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

	#if DEBUG {
		debug_messenger_create_info: VkDebugUtilsMessengerCreateInfoEXT;

		{
			using debug_messenger_create_info;
			sType = .VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT;
			messageSeverity = .VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT |
				.VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT |
				.VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT |
				.VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT;
			messageType = .VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT |
				.VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT |
				.VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT;
			pfnUserCallback = (severity: VkDebugUtilsMessageSeverityFlagsEXT, types: VkDebugUtilsMessageTypeFlagsEXT, callback_data: *VkDebugUtilsMessengerCallbackDataEXT, data: *void) -> VkBool32 #c_call {
				len := c_style_strlen(callback_data.pMessage);
				push_context { print("%\n", string.{len, callback_data.pMessage}); }
				return xx false;
			};
		}
	}

	{
		layers :: #ifx DEBUG then (*u8).["VK_layer_khronos_validation"] else (*u8).[];
		extensions: [#ifx DEBUG 3 else 2]*u8;
		extensions[0] = VK_KHR_SURFACE_EXTENSION_NAME;
		#if OS == .WINDOWS extensions[1] = VK_KHR_WIN32_SURFACE_EXTENSION_NAME;
		else #assert(false, "OS not supported");
		#if DEBUG extensions[2] = VK_EXT_DEBUG_UTILS_EXTENSION_NAME;

		using info: VkInstanceCreateInfo;
		sType = .VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
		#if DEBUG pNext = *debug_messenger_create_info;
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

	#if DEBUG {{
		result = vkCreateDebugUtilsMessengerEXT(instance, *debug_messenger_create_info, null, *debug_messenger);
		return_if_not_success_or();
	}}

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
		#if DEBUG if debug_messenger vkDestroyDebugUtilsMessengerEXT(instance, debug_messenger, null);
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
