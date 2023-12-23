typedef struct v2 {
	union {
		struct { f32 x, y; };
		f32 e[2];
	};
} v2;
typedef struct v3 {
	union {
		struct { f32 x, y, z; };
		struct { v2 xy; f32 z1; };
		struct { f32 x1; v2 yz; };
		f32 e[3];
	};
} v3;
typedef struct v4 {
	union {
		struct { f32 x, y, z, w; };
		struct { f32 r, g, b, a; };
		struct { v2 xy, zw; };
		struct { v3 xyz; f32 w1; };
		f32 e[4];
	};
} v4;

static v2 V2(f32 x, f32 y) {
	v2 result;
	result.x = x;
	result.y = y;
	return result;
}

static v4 V4(f32 x, f32 y, f32 z, f32 w) {
	v4 result;
	result.x = x;
	result.y = y;
	result.z = z;
	result.w = w;
	return result;
}
