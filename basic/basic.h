#if !defined(DEBUG)
#error DEBUG is not defined
#endif

#if defined(_MSC_VER)
#define COMPILER_MSVC 1
#else
#define COMPILER_MSVC 0
#endif

#if defined(__TINYC__)
#define COMPILER_TCC 1
#else
#define COMPILER_TCC 0
#endif

#if defined(__clang__)
#define COMPILER_CLANG 1
#else
#define COMPILER_CLANG 0
#endif

#if !COMPILER_CLANG && defined(__GNUC__)
#define COMPILER_GCC 1
#else
#define COMPILER_GCC 0
#endif

#if defined(i386) || defined(__i386__) || defined(__i386) || defined(_M_IX86)
#define TARGET_CPU_ARCH_X86 1
#else
#define TARGET_CPU_ARCH_X86 0
#endif

#if defined(__x86_64__) || defined(_M_AMD64)
#define TARGET_CPU_ARCH_AMD64 1
#else
#define TARGET_CPU_ARCH_AMD64 0
#endif

#if defined(__aarch64__) || defined(_M_ARM64)
#define TARGET_CPU_ARCH_ARM64 1
#else
#define TARGET_CPU_ARCH_ARM64 0
#endif

#if defined(_WIN32) || defined(_WIN64) || defined(__WIN32__)
#define TARGET_OS_WINDOWS 1
#else
#define TARGET_OS_WINDOWS 0
#endif

#define cast(T) (T)
#define size_of(T) (sizeof(T))
#define zero(X) memset((X), 0, size_of(*(X)))
#define true (cast(bool) 1)
#define false (cast(bool) 0)
#define null (cast(void*) 0)
#define fallthrough (cast(void) 0)
#define unreachable do *((volatile u8*) 0) = 0; while (0)

#if COMPILER_TCC || COMPILER_GCC || COMPILER_CLANG
#define noreturn_t __attribute__((noreturn)) void
#elif COMPILER_MSVC
#define noreturn_t __declspec(noreturn) void
#else
#error Check implementation.
#endif

#if TARGET_CPU_ARCH_AMD64 || TARGET_CPU_ARCH_ARM64
typedef signed char s8;
typedef short s16;
typedef int s32;
typedef long long s64;

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;
#else
#error Check implementation.
#endif

typedef _Bool bool;
typedef u8 b8;
typedef u16 b16;
typedef u32 b32;

typedef float f32;
typedef double f64;

void* memset(void*, s32, u64);
void* memcpy(void*, void*, u64);
void* memmove(void*, void*, u64);
