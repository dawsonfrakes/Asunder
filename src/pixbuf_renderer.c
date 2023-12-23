
struct PixelBuffer {
	u32 *ptr;
	u16 width;
	u16 height;
};
static struct PixelBuffer pixbuf;

static u32 argb_color(v4 color) {
	u32 result = ((u32) (u8) (color.a * 255.9f) << 24) |
		((u32) (u8) (color.r * 255.9f) << 16) |
		((u32) (u8) (color.g * 255.9f) << 8) |
		((u32) (u8) (color.b * 255.9f) << 0);
	return result;
}

static void pixbuf_clear(v4 color) {
	for (u16 y = 0; y < pixbuf.height; ++y) {
		for (u16 x = 0; x < pixbuf.width; ++x) {
			u32 color_u = argb_color(color);
			pixbuf.ptr[y * pixbuf.width + x] = color_u;
		}
	}
}

static void pixbuf_quad(v2 a, v2 b, v4 color) {
	if (a.x > b.x) { f32 tmp = a.x; a.x = b.x; b.x = tmp; }
	if (a.y > b.y) { f32 tmp = a.y; a.y = b.y; b.y = tmp; }

	a.x += 1.0f;
	a.y += 1.0f;
	a.x *= 0.5f;
	a.y *= 0.5f;
	a.x = CLAMP(0.0f, a.x, 1.0f);
	a.y = CLAMP(0.0f, a.y, 1.0f);
	a.x *= (f32) input.screen_width;
	a.y *= (f32) input.screen_height;

	b.x += 1.0f;
	b.y += 1.0f;
	b.x *= 0.5f;
	b.y *= 0.5f;
	b.x = CLAMP(0.0f, b.x, 1.0f);
	b.y = CLAMP(0.0f, b.y, 1.0f);
	b.x *= (f32) input.screen_width;
	b.y *= (f32) input.screen_height;

	u16 xmin = (u16) a.x;
	u16 ymin = (u16) a.y;
	u16 xmax = (u16) b.x;
	u16 ymax = (u16) b.y;

	u32 color_u = argb_color(color);
	for (u16 y = ymin; y < ymax; ++y) {
		for (u16 x = xmin; x < xmax; ++x) {
			pixbuf.ptr[y * pixbuf.width + x] = color_u;
		}
	}
}

static struct GameGraphics gfx = {
	.clear = pixbuf_clear,
	.immediate_quad = pixbuf_quad,
};
