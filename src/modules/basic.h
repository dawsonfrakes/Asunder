#if defined(_MSC_VER)
#define COMPILER_MSVC 1
#else
#define COMPILER_MSVC 0
#endif

#if defined(_WIN32) || defined(_WIN64) || defined(__WIN32__)
#define TARGET_OS_WINDOWS 1
#else
#define TARGET_OS_WINDOWS 0
#endif

#if defined(__x86_64__) || defined(_M_AMD64) || defined(_M_X64)
#define TARGET_CPU_ARCH_X64 1
#else
#define TARGET_CPU_ARCH_X64 0
#endif

#if COMPILER_MSVC
#define assert(X) do if (!(X)) __debugbreak(); while (0)
#define noreturn_def __declspec(noreturn) void
#endif

#define size_of(T) sizeof(T)
#define offset_of(T, F) (cast(s64) &(cast(T*) 0)->F)
#define cast(T) (T)
#define len(A) (size_of(A) / size_of((A)[0]))
#define min(A, B) ((A) < (B) ? (A) : (B))
#define max(A, B) ((A) > (B) ? (A) : (B))
#define null (cast(void*) 0)
#define true (cast(bool) 1)
#define false (cast(bool) 0)
#define fallthrough (cast(void) 0)

#if TARGET_CPU_ARCH_X64
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

typedef s8 bool;

typedef struct v2 { f32 x, y; } v2;
typedef struct v3 { f32 x, y, z; } v3;
typedef struct v4 { f32 x, y, z, w; } v4;
typedef struct v2s { s32 x, y; } v2s;
typedef struct m4 { f32 e[16]; } m4;

#define S(LIT) ((string) {len(LIT) - 1, (LIT)})
typedef struct {
	s64 count;
	u8* data;
} string;

typedef struct {
	void* base;
	s64 max_size;
	s64 size;
} Arena;

static inline Arena arena_init(void* base, s64 max_size) {
	Arena result;
	result.base = base;
	result.max_size = max_size;
	result.size = 0;
	return result;
}

static inline void* arena_alloc(Arena* arena, s64 size) {
	assert(arena->size + size <= arena->max_size);
	void* result = cast(u8*) arena->base + arena->size;
	arena->size += size;
	return result;
}

static inline void arena_reset(Arena* arena) {
	arena->size = 0;
}
