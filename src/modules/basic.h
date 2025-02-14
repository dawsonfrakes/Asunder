#if defined(__x86_64__) || defined(_M_AMD64) || defined(_M_X64)
#define TARGET_CPU_ARCH_AMD64 1
#else
#define TARGET_CPU_ARCH_AMD64 0
#endif

#if defined(_WIN32) || defined(_WIN64) || defined(__WIN32__)
#define TARGET_OS_WINDOWS 1
#else
#define TARGET_OS_WINDOWS 0
#endif

#if defined(__cplusplus)
#define LANGUAGE_CPP 1
#else
#define LANGUAGE_CPP 0
#endif

#define cast(T) (T)
#define size_of(T) (sizeof(T))
#define len(ARRAY) (size_of(ARRAY) / size_of((ARRAY)[0]))
#define fallthrough (cast(void) 0)

#if LANGUAGE_CPP
#define EXTERNC extern "C"
#define noreturn_t [[noreturn]] void
#define null nullptr
#else
#define EXTERNC
#define noreturn_t void
#define null (cast(void*) 0)
#endif

#if TARGET_CPU_ARCH_AMD64
typedef signed char s8;
typedef short s16;
typedef int s32;
typedef long long s64;

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;
#endif

typedef float f32;
typedef double f64;
