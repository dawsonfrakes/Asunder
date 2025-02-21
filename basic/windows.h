#if COMPILER_MSVC
#define WINAPI __stdcall
#elif TARGET_CPU_ARCH_X64 || TARGET_CPU_ARCH_ARM64
#define WINAPI
#else
#error WINAPI needs definition
#endif

// kernel32
noreturn_t WINAPI ExitProcess(u32);
