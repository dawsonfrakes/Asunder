#ifndef NDEBUG
#define ASSERT(X) do if (!(X)) *(volatile char *) 0 = 0; while (0)
#else
#define ASSERT(X) (void) (X)
#endif

#define MIN(A, B) ((A) < (B) ? (A) : (B))
#define MAX(A, B) ((A) > (B) ? (A) : (B))
#define CLAMP(LO, V, HI) MAX((LO), MIN((V), (HI)))

#include <stdint.h>
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
typedef int8_t s8;
typedef int16_t s16;
typedef int32_t s32;
typedef int64_t s64;
typedef float f32;
typedef double f64;
