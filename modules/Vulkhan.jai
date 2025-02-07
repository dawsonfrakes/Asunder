#if OS == .WINDOWS #import "Winblows";

VkFlags :: u32;
VkBool32 :: u32;
VkInstance :: #type,distinct *void;
PFN_vkVoidFunction :: #type () #c_call;
PFN_vkAllocationFunction :: #type (data: *void, size: u64, alignmenmt: u64, scope: VkSystemAllocationScope) -> *void #c_call;
PFN_vkReallocationFunction :: #type (data: *void, original: *void, size: u64, alignment: u64, scope: VkSystemAllocationScope) -> *void #c_call;
PFN_vkFreeFunction :: #type (data: *void, memory: *void) #c_call;
PFN_vkInternalAllocationNotification :: #type (data: *void, size: u64, type: VkInternalAllocationType, scope: VkSystemAllocationScope) #c_call;
PFN_vkInternalFreeNotification :: #type (data: *void, size: u64, type: VkInternalAllocationType, scope: VkSystemAllocationScope) #c_call;

VkStructureType :: enum s32 {
  VK_STRUCTURE_TYPE_APPLICATION_INFO :: 0;
  VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO :: 1;
  VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO :: 2;
  VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO :: 3;
  VK_STRUCTURE_TYPE_SUBMIT_INFO :: 4;
  VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO :: 5;
  VK_STRUCTURE_TYPE_MAPPED_MEMORY_RANGE :: 6;
  VK_STRUCTURE_TYPE_BIND_SPARSE_INFO :: 7;
  VK_STRUCTURE_TYPE_FENCE_CREATE_INFO :: 8;
  VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO :: 9;
  VK_STRUCTURE_TYPE_EVENT_CREATE_INFO :: 10;
  VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO :: 11;
  VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO :: 12;
  VK_STRUCTURE_TYPE_BUFFER_VIEW_CREATE_INFO :: 13;
  VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO :: 14;
  VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO :: 15;
  VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO :: 16;
  VK_STRUCTURE_TYPE_PIPELINE_CACHE_CREATE_INFO :: 17;
  VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO :: 18;
  VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO :: 19;
  VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO :: 20;
  VK_STRUCTURE_TYPE_PIPELINE_TESSELLATION_STATE_CREATE_INFO :: 21;
  VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO :: 22;
  VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO :: 23;
  VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO :: 24;
  VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO :: 25;
  VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO :: 26;
  VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO :: 27;
  VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO :: 28;
  VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO :: 29;
  VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO :: 30;
  VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO :: 31;
  VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO :: 32;
  VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO :: 33;
  VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO :: 34;
  VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET :: 35;
  VK_STRUCTURE_TYPE_COPY_DESCRIPTOR_SET :: 36;
  VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO :: 37;
  VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO :: 38;
  VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO :: 39;
  VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO :: 40;
  VK_STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_INFO :: 41;
  VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO :: 42;
  VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO :: 43;
  VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER :: 44;
  VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER :: 45;
  VK_STRUCTURE_TYPE_MEMORY_BARRIER :: 46;
  VK_STRUCTURE_TYPE_LOADER_INSTANCE_CREATE_INFO :: 47;
  // Provided by VK_KHR_win32_surface
  VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR :: 1000009000;
  // Provided by VK_EXT_debug_utils
  VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT :: 1000128004;
}
VkResult :: enum s32 {
  VK_SUCCESS :: 0;
  VK_NOT_READY :: 1;
  VK_TIMEOUT :: 2;
  VK_EVENT_SET :: 3;
  VK_EVENT_RESET :: 4;
  VK_INCOMPLETE :: 5;
  VK_ERROR_OUT_OF_HOST_MEMORY :: -1;
  VK_ERROR_OUT_OF_DEVICE_MEMORY :: -2;
  VK_ERROR_INITIALIZATION_FAILED :: -3;
  VK_ERROR_DEVICE_LOST :: -4;
  VK_ERROR_MEMORY_MAP_FAILED :: -5;
  VK_ERROR_LAYER_NOT_PRESENT :: -6;
  VK_ERROR_EXTENSION_NOT_PRESENT :: -7;
  VK_ERROR_FEATURE_NOT_PRESENT :: -8;
  VK_ERROR_INCOMPATIBLE_DRIVER :: -9;
  VK_ERROR_TOO_MANY_OBJECTS :: -10;
  VK_ERROR_FORMAT_NOT_SUPPORTED :: -11;
  VK_ERROR_FRAGMENTED_POOL :: -12;
  VK_ERROR_UNKNOWN :: -13;
}
VkObjectType :: enum s32 {
  VK_OBJECT_TYPE_UNKNOWN :: 0;
  VK_OBJECT_TYPE_INSTANCE :: 1;
  VK_OBJECT_TYPE_PHYSICAL_DEVICE :: 2;
  VK_OBJECT_TYPE_DEVICE :: 3;
  VK_OBJECT_TYPE_QUEUE :: 4;
  VK_OBJECT_TYPE_SEMAPHORE :: 5;
  VK_OBJECT_TYPE_COMMAND_BUFFER :: 6;
  VK_OBJECT_TYPE_FENCE :: 7;
  VK_OBJECT_TYPE_DEVICE_MEMORY :: 8;
  VK_OBJECT_TYPE_BUFFER :: 9;
  VK_OBJECT_TYPE_IMAGE :: 10;
  VK_OBJECT_TYPE_EVENT :: 11;
  VK_OBJECT_TYPE_QUERY_POOL :: 12;
  VK_OBJECT_TYPE_BUFFER_VIEW :: 13;
  VK_OBJECT_TYPE_IMAGE_VIEW :: 14;
  VK_OBJECT_TYPE_SHADER_MODULE :: 15;
  VK_OBJECT_TYPE_PIPELINE_CACHE :: 16;
  VK_OBJECT_TYPE_PIPELINE_LAYOUT :: 17;
  VK_OBJECT_TYPE_RENDER_PASS :: 18;
  VK_OBJECT_TYPE_PIPELINE :: 19;
  VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT :: 20;
  VK_OBJECT_TYPE_SAMPLER :: 21;
  VK_OBJECT_TYPE_DESCRIPTOR_POOL :: 22;
  VK_OBJECT_TYPE_DESCRIPTOR_SET :: 23;
  VK_OBJECT_TYPE_FRAMEBUFFER :: 24;
  VK_OBJECT_TYPE_COMMAND_POOL :: 25;
}
VkInternalAllocationType :: enum s32 {
	VK_INTERNAL_ALLOCATION_TYPE_EXECUTABLE :: 0;
}
VkSystemAllocationScope :: enum s32 {
  VK_SYSTEM_ALLOCATION_SCOPE_COMMAND :: 0;
  VK_SYSTEM_ALLOCATION_SCOPE_OBJECT :: 1;
  VK_SYSTEM_ALLOCATION_SCOPE_CACHE :: 2;
  VK_SYSTEM_ALLOCATION_SCOPE_DEVICE :: 3;
  VK_SYSTEM_ALLOCATION_SCOPE_INSTANCE :: 4;
}
VkAllocationCallbacks :: struct {
  pUserData: *void;
  pfnAllocation: PFN_vkAllocationFunction;
  pfnReallocation: PFN_vkReallocationFunction;
  pfnFree: PFN_vkFreeFunction;
  pfnInternalAllocation: PFN_vkInternalAllocationNotification;
  pfnInternalFree: PFN_vkInternalFreeNotification;
}
VkApplicationInfo :: struct {
  sType: VkStructureType;
  pNext: *void;
  pApplicationName: *u8;
  applicationVersion: u32;
  pEngineName: *u8;
  engineVersion: u32;
  apiVersion: u32;
}
VkInstanceCreateFlags :: VkFlags;
VkInstanceCreateInfo :: struct {
  sType: VkStructureType;
  pNext: *void;
  flags: VkInstanceCreateFlags;
  pApplicationInfo: *VkApplicationInfo;
  enabledLayerCount: u32;
  ppEnabledLayerNames: **u8;
  enabledExtensionCount: u32;
  ppEnabledExtensionNames: **u8;
}

PFN_vkGetInstanceProcAddr :: #type (instance: VkInstance, name: *u8) -> PFN_vkVoidFunction #c_call;
PFN_vkCreateInstance :: #type (info: *VkInstanceCreateInfo, allocator: *VkAllocationCallbacks, instance: *VkInstance) -> VkResult #c_call;
PFN_vkDestroyInstance :: #type (instance: VkInstance, allocator: *VkAllocationCallbacks) #c_call;

// VK_EXT_debug_utils
VK_EXT_DEBUG_UTILS_EXTENSION_NAME :: "VK_EXT_debug_utils";

VkDebugUtilsMessengerEXT :: #type,distinct *void;
PFN_vkDebugUtilsMessengerCallbackEXT :: #type (severity: VkDebugUtilsMessageSeverityFlagsEXT, types: VkDebugUtilsMessageTypeFlagsEXT, callback_data: *VkDebugUtilsMessengerCallbackDataEXT, data: *void) -> VkBool32 #c_call;
VkDebugUtilsLabelEXT :: struct {
  sType: VkStructureType;
  pNext: *void;
  pLabelName: *u8;
  color: [4]float;
}
VkDebugUtilsObjectNameInfoEXT :: struct {
  sType: VkStructureType;
  pNext: *void;
  objectType: VkObjectType;
  objectHandle: u64;
  pObjectName: *u8;
}
VkDebugUtilsMessengerCallbackDataFlagsEXT :: VkFlags;
VkDebugUtilsMessengerCallbackDataEXT :: struct {
  sType: VkStructureType;
  pNext: *void;
  flags: VkDebugUtilsMessengerCallbackDataFlagsEXT;
  pMessageIdName: *u8;
  messageIdNumber: s32;
  pMessage: *u8;
  queueLabelCount: u32;
  pQueueLabels: *VkDebugUtilsLabelEXT;
  cmdBufLabelCount: u32;
  pCmdBufLabels: *VkDebugUtilsLabelEXT;
  objectCount: u32;
  pObjects: *VkDebugUtilsObjectNameInfoEXT;
}
VkDebugUtilsMessageSeverityFlagsEXT :: enum_flags s32 {
  VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT :: 0x00000001;
  VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT :: 0x00000010;
  VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT :: 0x00000100;
  VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT :: 0x00001000;
}
VkDebugUtilsMessageTypeFlagsEXT :: enum_flags s32 {
  VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT :: 0x00000001;
  VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT :: 0x00000002;
  VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT :: 0x00000004;
}
VkDebugUtilsMessengerCreateFlagsEXT :: enum_flags s32 {
  VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT :: 0x00000001;
  VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT :: 0x00000010;
  VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT :: 0x00000100;
  VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT :: 0x00001000;
}
VkDebugUtilsMessengerCreateInfoEXT :: struct {
  sType: VkStructureType;
  pNext: *void;
  flags: VkDebugUtilsMessengerCreateFlagsEXT;
  messageSeverity: VkDebugUtilsMessageSeverityFlagsEXT;
  messageType: VkDebugUtilsMessageTypeFlagsEXT;
  pfnUserCallback: PFN_vkDebugUtilsMessengerCallbackEXT;
  pUserData: *void;
}

PFN_vkCreateDebugUtilsMessengerEXT :: #type (instance: VkInstance, info: *VkDebugUtilsMessengerCreateInfoEXT, allocator: *VkAllocationCallbacks, messenger: *VkDebugUtilsMessengerEXT) -> VkResult #c_call;
PFN_vkDestroyDebugUtilsMessengerEXT :: #type (instance: VkInstance, messenger: VkDebugUtilsMessengerEXT, allocator: *VkAllocationCallbacks) #c_call;

// VK_KHR_surface
VK_KHR_SURFACE_EXTENSION_NAME :: "VK_KHR_surface";

VkSurfaceKHR :: #type,distinct *void;

// VK_KHR_win32_surface
#if OS == .WINDOWS {
	VK_KHR_WIN32_SURFACE_EXTENSION_NAME :: "VK_KHR_win32_surface";

	VkWin32SurfaceCreateFlagsKHR :: VkFlags;
	VkWin32SurfaceCreateInfoKHR :: struct {
    sType: VkStructureType;
    pNext: *void;
    flags: VkWin32SurfaceCreateFlagsKHR;
    hinstance: HINSTANCE;
    hwnd: HWND;
	}

	PFN_vkCreateWin32SurfaceKHR :: #type (instance: VkInstance, info: *VkWin32SurfaceCreateInfoKHR, allocator: *VkAllocationCallbacks, surface: *VkSurfaceKHR) -> VkResult #c_call;
	PFN_vkDestroySurfaceKHR :: #type (instance: VkInstance, surface: VkSurfaceKHR, allocator: *VkAllocationCallbacks) #c_call;
}
