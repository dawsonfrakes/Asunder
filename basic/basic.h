#if defined(i386) || defined(__i386__) || defined(__i386) || defined(_M_IX86)
#define TARGET_CPU_ARCH_X86 1
#else
#define TARGET_CPU_ARCH_X86 0
#endif

#if defined(__x86_64__) || defined(_M_AMD64)
#define TARGET_CPU_ARCH_X64 1
#else
#define TARGET_CPU_ARCH_X64 0
#endif

#if defined(__aarch64__) || defined(_M_ARM64)
#define TARGET_CPU_ARCH_ARM64 1
#else
#define TARGET_CPU_ARCH_ARM64 0
#endif

#if defined(_MSC_VER)
#define COMPILER_MSVC 1
#else
#define COMPILER_MSVC 0
#endif

#define cast(T) (T)
#define size_of(T) (cast(int) sizeof(T))
#define offset_of(T, F) (cast(int) &(cast(T*) 0)->F)
#define S(LIT) ((string) {size_of(LIT) - 1, cast(u8*) (LIT)})

#define noreturn_t __attribute__((noreturn)) void

#if TARGET_CPU_ARCH_X64 || TARGET_CPU_ARCH_ARM64
typedef signed char s8;
typedef short s16;
typedef int s32;
typedef long long s64;

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;
typedef unsigned long long uintptr;

#define int s64
#define uint u64
#else
#error types not defined
#endif

typedef float f32;
typedef double f64;

typedef s8 bool;

typedef struct string {
  int count;
  u8* data;
} string;

#define SliceOf(T) \
  struct { \
    int count; \
    T* data; \
  }

#define ArenaOf(T) \
  struct { \
    int count; \
    T* data; \
    int max_count; \
  }
