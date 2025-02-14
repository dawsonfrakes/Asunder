const core = @import("core.zig");

pub const VKAPI = core.CallingConvention.c;

pub const VkFlags = u32;
pub const VkInstance = *opaque {};
pub const PFN_vkVoidFunction = *const fn () callconv(VKAPI) void;
pub const VkResult = enum(c_int) {
    VK_SUCCESS = 0,
    VK_NOT_READY = 1,
    VK_TIMEOUT = 2,
    VK_EVENT_SET = 3,
    VK_EVENT_RESET = 4,
    VK_INCOMPLETE = 5,
    VK_ERROR_OUT_OF_HOST_MEMORY = -1,
    VK_ERROR_OUT_OF_DEVICE_MEMORY = -2,
    VK_ERROR_INITIALIZATION_FAILED = -3,
    VK_ERROR_DEVICE_LOST = -4,
    VK_ERROR_MEMORY_MAP_FAILED = -5,
    VK_ERROR_LAYER_NOT_PRESENT = -6,
    VK_ERROR_EXTENSION_NOT_PRESENT = -7,
    VK_ERROR_FEATURE_NOT_PRESENT = -8,
    VK_ERROR_INCOMPATIBLE_DRIVER = -9,
    VK_ERROR_TOO_MANY_OBJECTS = -10,
    VK_ERROR_FORMAT_NOT_SUPPORTED = -11,
    VK_ERROR_FRAGMENTED_POOL = -12,
    VK_ERROR_UNKNOWN = -13,
};
pub const VkStructureType = enum(c_int) {
    VK_STRUCTURE_TYPE_APPLICATION_INFO = 0,
    VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO = 1,
    VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO = 2,
    VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO = 3,
    VK_STRUCTURE_TYPE_SUBMIT_INFO = 4,
    VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO = 5,
    VK_STRUCTURE_TYPE_MAPPED_MEMORY_RANGE = 6,
    VK_STRUCTURE_TYPE_BIND_SPARSE_INFO = 7,
    VK_STRUCTURE_TYPE_FENCE_CREATE_INFO = 8,
    VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO = 9,
    VK_STRUCTURE_TYPE_EVENT_CREATE_INFO = 10,
    VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO = 11,
    VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO = 12,
    VK_STRUCTURE_TYPE_BUFFER_VIEW_CREATE_INFO = 13,
    VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO = 14,
    VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO = 15,
    VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO = 16,
    VK_STRUCTURE_TYPE_PIPELINE_CACHE_CREATE_INFO = 17,
    VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO = 18,
    VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO = 19,
    VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO = 20,
    VK_STRUCTURE_TYPE_PIPELINE_TESSELLATION_STATE_CREATE_INFO = 21,
    VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO = 22,
    VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO = 23,
    VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO = 24,
    VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO = 25,
    VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO = 26,
    VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO = 27,
    VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO = 28,
    VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO = 29,
    VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO = 30,
    VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO = 31,
    VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO = 32,
    VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO = 33,
    VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO = 34,
    VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET = 35,
    VK_STRUCTURE_TYPE_COPY_DESCRIPTOR_SET = 36,
    VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO = 37,
    VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO = 38,
    VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO = 39,
    VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO = 40,
    VK_STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_INFO = 41,
    VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO = 42,
    VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO = 43,
    VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER = 44,
    VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER = 45,
    VK_STRUCTURE_TYPE_MEMORY_BARRIER = 46,
    VK_STRUCTURE_TYPE_LOADER_INSTANCE_CREATE_INFO = 47,
    VK_STRUCTURE_TYPE_LOADER_DEVICE_CREATE_INFO = 48,
};
pub const VkSystemAllocationScope = enum(c_int) {
    VK_SYSTEM_ALLOCATION_SCOPE_COMMAND = 0,
    VK_SYSTEM_ALLOCATION_SCOPE_OBJECT = 1,
    VK_SYSTEM_ALLOCATION_SCOPE_CACHE = 2,
    VK_SYSTEM_ALLOCATION_SCOPE_DEVICE = 3,
    VK_SYSTEM_ALLOCATION_SCOPE_INSTANCE = 4,
};
pub const PFN_vkAllocationFunction = *const fn (data: ?*anyopaque, size: usize, alignment: usize, scope: VkSystemAllocationScope) callconv(VKAPI) ?*anyopaque;
pub const PFN_vkReallocationFunction = *const fn (data: ?*anyopaque, original: ?*anyopaque, size: usize, alignment: usize, scope: VkSystemAllocationScope) callconv(VKAPI) ?*anyopaque;
pub const PFN_vkFreeFunction = *const fn (data: ?*anyopaque, memory: ?*anyopaque) callconv(VKAPI) void;
pub const VkInternalAllocationType = enum(c_int) {
    VK_INTERNAL_ALLOCATION_TYPE_EXECUTABLE = 0,
};
pub const PFN_vkInternalAllocationNotification = *const fn (data: ?*anyopaque, size: usize, @"type": VkInternalAllocationType, scope: VkSystemAllocationScope) callconv(VKAPI) void;
pub const PFN_vkInternalFreeNotification = *const fn (data: ?*anyopaque, size: usize, @"type": VkInternalAllocationType, scope: VkSystemAllocationScope) callconv(VKAPI) void;
pub const VkAllocationCallbacks = extern struct {
    pUserData: ?*void,
    pfnAllocation: ?PFN_vkAllocationFunction,
    pfnReallocation: ?PFN_vkReallocationFunction,
    pfnFree: ?PFN_vkFreeFunction,
    pfnInternalAllocation: ?PFN_vkInternalAllocationNotification,
    pfnInternalFree: ?PFN_vkInternalFreeNotification,
};
pub const VkApplicationInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    pApplicationName: ?[*:0]const u8,
    applicationVersion: u32,
    pEngineName: ?[*:0]const u8,
    engineVersion: u32,
    apiVersion: u32,
};
pub const VkInstanceCreateFlags = VkFlags;
pub const VkInstanceCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkInstanceCreateFlags,
    pApplicationInfo: ?*const VkApplicationInfo,
    enabledLayerCount: u32,
    ppEnabledLayerNames: ?[*]const ?[*:0]const u8,
    enabledExtensionCount: u32,
    ppEnabledExtensionNames: ?[*]const ?[*:0]const u8,
};

pub const exported = struct {
    pub extern fn vkGetInstanceProcAddr(instance: ?VkInstance, name: ?[*:0]const u8) callconv(VKAPI) ?PFN_vkVoidFunction;
};

pub const global = struct {
    pub extern fn vkCreateInstance(info: ?*const VkInstanceCreateInfo, allocator: ?*const VkAllocationCallbacks, instance: ?*VkInstance) callconv(VKAPI) VkResult;
};
