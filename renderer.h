struct Graphics;
struct Vertices {
	v3 pos[3];
	v4 color[3];
};

static void renderer_clear(struct Graphics *gfx, v4 color);
static void renderer_tri(struct Graphics *gfx, struct Vertices *vertices);
