#if TARGET_OS_WINDOWS
#define VK_USE_PLATFORM_WIN32_KHR
#endif
#define VK_NO_PROTOTYPES
#include <vulkan/vulkan.h>

#define VULKAN_EXPORTED_PROCS \
  X(vkGetInstanceProcAddr)

#define VULKAN_GLOBAL_PROCS \
  X(vkCreateInstance)

#define VULKAN_INSTANCE_PROCS \
  X(vkDestroyInstance)

#define X(NAME) PFN_##NAME NAME;
VULKAN_EXPORTED_PROCS
VULKAN_GLOBAL_PROCS
VULKAN_INSTANCE_PROCS
#undef X

struct {
  VkInstance instance;
} vk;

void vulkan_deinit(void);

void vulkan_init(void) {
  VkResult result;

  #if TARGET_OS_WINDOWS
  HMODULE vulkan_dll = LoadLibraryW(L"vulkan-1");
  if (!vulkan_dll) goto error;
  #define X(NAME) NAME = cast(PFN_##NAME) GetProcAddress(vulkan_dll, #NAME);
  VULKAN_EXPORTED_PROCS
  #undef X
  #endif

  #define X(NAME) NAME = cast(PFN_##NAME) vkGetInstanceProcAddr(null, #NAME);
  VULKAN_GLOBAL_PROCS
  #undef X

  #if TARGET_OS_WINDOWS
  char const* instance_extensions[] = {VK_KHR_SURFACE_EXTENSION_NAME, VK_KHR_WIN32_SURFACE_EXTENSION_NAME};
  #endif

  {
    VkInstanceCreateInfo instance_create_info = {};
    instance_create_info.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
    instance_create_info.enabledExtensionCount = len(instance_extensions);
    instance_create_info.ppEnabledExtensionNames = instance_extensions;
    result = vkCreateInstance(&instance_create_info, null, &vk.instance);
    if (result != VK_SUCCESS) goto error;
  }

  #define X(NAME) NAME = cast(PFN_##NAME) vkGetInstanceProcAddr(vk.instance, #NAME);
  VULKAN_INSTANCE_PROCS
  #undef X

  return;
error:
  vulkan_deinit();
}

void vulkan_deinit(void) {
  if (vk.instance) {
    vkDestroyInstance(vk.instance, null);
  }
  vk = {};
}

void vulkan_resize(void) {

}

void vulkan_present(void) {

}
