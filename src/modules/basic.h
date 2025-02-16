#if !defined(DEBUG)
#error DEBUG is not defined
#endif

#if defined(__x86_64__) || defined(_M_X64)
#define TARGET_CPU_AMD64 1
#else
#define TARGET_CPU_AMD64 0
#endif

#if defined(i386) || defined(__i386__) || defined(__i386) || defined(_M_IX86)
#define TARGET_CPU_X86 1
#else
#define TARGET_CPU_X86 0
#endif

#if defined(_WIN32) || defined(_WIN64) || defined(__WIN32__)
#define TARGET_OS_WINDOWS 1
#else
#define TAREGT_OS_WINDOWS 0
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

#define cast(T) (T)
#define size_of(T) (sizeof(T))
#define zero(V) memset((V), 0, size_of(*(V)))
#define true (cast(bool) 1)
#define false (cast(bool) 0)
#define null (cast(void*) 0)
#define fallthrough (cast(void) 0)
#define unreachable do *(cast(u8 volatile*) 0) = 0; while (0)

#if COMPILER_MSVC
#define noreturn_t __declspec(noreturn) void
#elif COMPILER_TCC
#define noreturn_t __attribute__((noreturn)) void
#else
#error noreturn_t not defined
#endif

#if TARGET_CPU_AMD64
typedef signed char s8;
typedef short s16;
typedef int s32;
typedef long long s64;

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;
#else
#error sized types not defined
#endif

typedef s8 bool;

typedef float f32;
typedef double f64;

void* memset(void*, s32, u64);
void* memcpy(void*, void*, u64);
void* memmove(void*, void*, u64);
