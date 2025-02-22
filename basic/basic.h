#if !defined(DEBUG)
#error DEBUG must be defined as an integer
#endif

#define COMPILER_UNKNOWN 0
#define COMPILER_CLANG 1
#define COMPILER_GCC 2
#define COMPILER_MSVC 3
#define COMPILER_TCC 4
#define COMPILER_ICC 5
#define COMPILER_DMC 6
#define COMPILER_CUIK 7

#if defined(__clang__)
#define COMPILER COMPILER_CLANG
#elif defined(__GNUC__)
#define COMPILER COMPILER_GCC
#elif defined(_MSC_VER)
#define COMPILER COMPILER_MSVC
#elif defined(__TINYC__)
#define COMPILER COMPILER_TCC
#elif defined(__INTEL_COMPILER)
#define COMPILER COMPILER_ICC
#elif defined(__DMC__)
#define COMPILER COMPILER_DMC
#elif defined(__CUIK__)
#define COMPILER COMPILER_CUIK
#else
#define COMPILER COMPILER_UNKNOWN
#endif

#define CPU_UNKNOWN 0
#define CPU_X86 1
#define CPU_X64 2
#define CPU_ARM64 3
#define CPU_RISCV 4

#if defined(__i386__) || defined(_M_IX86)
#define CPU CPU_X86
#elif defined(__x86_64__) || defined(_M_X64)
#define CPU CPU_X64
#elif defined(__aarch64__) || defined(_M_ARM64)
#define CPU CPU_ARM64
#elif defined(__riscv)
#define CPU CPU_RISCV
#else
#define CPU CPU_UNKNOWN
#endif

#if CPU == CPU_X86 || (CPU == CPU_RISCV && __riscv_xlen == 32)
#define CPU_BITS 32
#elif CPU == CPU_X64 || CPU == CPU_ARM64 || (CPU == CPU_RISCV && __riscv_xlen == 64)
#define CPU_BITS 64
#endif

#define ENDIANNESS_UNKNOWN 0
#define ENDIANNESS_BIG 1
#define ENDIANNESS_LITTLE 2

#if CPU == CPU_X86 || CPU == CPU_X64 || CPU == CPU_ARM64 || CPU == CPU_RISCV
#define ENDIANNESS ENDIANNESS_LITTLE
#else
#define ENDIANNESS ENDIANNESS_UNKNOWN
#endif

#define OS_UNKNOWN 0
#define OS_WINDOWS 1
#define OS_MACOS 2
#define OS_LINUX 3
#define OS_FREEBSD 4
#define OS_OPENBSD 5
#define OS_NETBSD 6
#define OS_HAIKU 7
#define OS_ANDROID 8
#define OS_WASI 9

#if defined(_WIN32) || defined(_WIN64) || defined(__WIN32__) || defined(__CYGWIN__)
#define OS OS_WINDOWS
#elif defined(__APPLE__) && defined(__MACH__)
#define OS OS_MACOS
#elif defined(__FreeBSD__)
#define OS OS_FREEBSD
#elif defined(__OpenBSD__)
#define OS OS_OPENBSD
#elif defined(__NetBSD__)
#define OS OS_NETBSD
#elif defined(__HAIKU__)
#define OS OS_HAIKU
#elif defined(__ANDROID__)
#define OS OS_ANDROID
#elif defined(__wasm__)
#define OS OS_WASI
#else
#define OS OS_UNKNOWN
#endif

#include <stdarg.h>

#define cast(T) (T)
#define size_of(T) (cast(sint) sizeof(T))
#define offset_of(T, FIELD) (cast(sint) &(cast(T*) 0)->FIELD)
#define zero(MEM) memset((MEM), 0, size_of(*(MEM)))
#define len(ARRAY) (size_of(ARRAY) / size_of((ARRAY)[0]))
#define min(A, B) ((A) < (B) ? (A) : (B))
#define max(A, B) ((B) < (A) ? (A) : (B))
#define true (cast(bool) 1)
#define false (cast(bool) 0)
#define null (cast(void*) 0)
#define fallthrough (cast(void) 0)

#if COMPILER == COMPILER_CLANG || COMPILER == COMPILER_GCC || COMPILER == COMPILER_TCC
#define noreturn_decl __attribute__((noreturn)) void
#define noreturn_def __attribute__((noreturn)) void
#elif COMPILER == COMPILER_MSVC
#define noreturn_decl void
#define noreturn_def __declspec(noreturn) void
#else
#define noreturn_decl void
#define noreturn_def void
#endif

#if CPU == CPU_X64 || CPU == CPU_ARM64
typedef signed char s8;
typedef short s16;
typedef int s32;
typedef long long s64;

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;

typedef s64 sint;
typedef u64 uint;

typedef s64 intptr;
typedef u64 uintptr;
#endif

typedef s8 bool;
typedef s32 b32;

typedef float f32;
typedef double f64;

#define auto UNDEFINED
#define const UNDEFINED
#define unsigned UNDEFINED
#define signed UNDEFINED
#define char UNDEFINED
#define short UNDEFINED
#define int UNDEFINED
#define long UNDEFINED
#define float UNDEFINED
#define double UNDEFINED

#define SliceOf(T) \
	struct { \
		sint count; \
		T* data; \
	}

typedef SliceOf(u8) slice_u8;

#define S(LIT) ((string) {size_of(LIT) - 1, cast(u8*) (LIT)})
typedef slice_u8 string;

void* memset(void*, s32, uint);
void* memcpy(void*, void*, uint);
void* memmove(void*, void*, uint);
