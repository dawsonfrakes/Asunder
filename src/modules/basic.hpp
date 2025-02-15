#if defined(__x86_64__) || defined(_M_AMD64) || defined(_M_X64)
#define CPU_AMD64 1
#else
#define CPU_AMD64 0
#endif

#if defined(_WIN32) || defined(_WIN64) || defined(__WIN32__)
#define OS_WINDOWS 1
#else
#define OS_WINDOWS 0
#endif

#define null nullptr
#define fallthrough do {} while (0)
#define unreachable do *(cast(volatile u8*) 0) = 0; while (0)
#define cast(T) (T)
#define size_of(T) (sizeof(T))
#define len(ARRAY) (size_of(ARRAY) / size_of((ARRAY)[0]))
#define assertf(CHECK, ...) do if (!(CHECK)) debugf(__VA_ARGS__); while (0)

#if CPU_AMD64
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

inline s64 string_length(u8 const* data) { s64 count = 0; while (data[count]) count += 1; return count; }

struct string {
  s64 count;
  u8* data;

  string(u8 const* data) : count(string_length(data)), data(cast(u8*) data) {}
  string(s64 count, u8 const* data) : count(count), data(cast(u8*) data) {}
  string(s64 count, char const* data) : count(count), data(cast(u8*) data) {}
  template<s64 N> string(char const (&x)[N]) : count(N), data(cast(u8*) x) {}
};
