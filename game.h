#include <stdint.h>

#define ASSERT(X) do if (!(X)) *(volatile char *) 0 = 0; while (0)
#define MIN(X, Y) ((X) < (Y) ? (X) : (Y))
#define MAX(X, Y) ((X) > (Y) ? (X) : (Y))
#define CLAMP(LO, X, HI) MAX((LO), MIN((X), (HI)))
#define OFFSETOF(TYPE, FIELD) ((size_t) &((TYPE *) 0)->FIELD)

typedef struct v2 { float x, y; } v2;
typedef struct v3 { float x, y, z; } v3;
typedef struct v4 { float x, y, z, w; } v4;

struct Memory {
	void    *permanent;
	uint32_t permanent_size;
};

#define GAME_KEY_FORWARD  ((uint32_t) 0x1)
#define GAME_KEY_BACKWARD ((uint32_t) 0x2)

struct Input {
	uint32_t keys;
	float    dt;
};
