struct Graphics {
	uint32_t *data;
	uint16_t  width;
	uint16_t  height;

	uint16_t  screen_width, screen_height;
	v2        screen;

	#if 1 /* windows */
	HDC        hdc, mdc;
	BITMAPINFO bmi;
	HBITMAP    hbm;
	#endif
};

static void
renderer_init(struct Graphics *gfx, HDC hdc)
{
	gfx->hdc = hdc;
}

static void
renderer_resize(struct Graphics *gfx, uint16_t screen_width, uint16_t screen_height)
{
	gfx->screen_width = screen_width;
	gfx->screen_height = screen_height;
	gfx->screen = make_v2((float) gfx->screen_width,
	                      (float) gfx->screen_height);

	gfx->width  = (gfx->screen_width + 15) / 16 * 16;
	gfx->height = gfx->screen_height;

	gfx->bmi.bmiHeader.biSize      = sizeof(gfx->bmi.bmiHeader);
	gfx->bmi.bmiHeader.biWidth     = gfx->width;
	gfx->bmi.bmiHeader.biHeight    = gfx->height;
	gfx->bmi.bmiHeader.biPlanes    = 1;
	gfx->bmi.bmiHeader.biBitCount  = 32;
	gfx->bmi.bmiHeader.biSizeImage = gfx->width * gfx->height *
	                                 sizeof(gfx->data[0]);

	if (gfx->mdc) DeleteDC(gfx->mdc);
	if (gfx->hbm) DeleteObject(gfx->hbm);

	gfx->mdc = CreateCompatibleDC(gfx->hdc);
	gfx->hbm = CreateDIBSection(gfx->hdc, &gfx->bmi, 0, (void **) &gfx->data, 0, 0);
	SelectObject(gfx->mdc, gfx->hbm);
}

static void
renderer_swap(struct Graphics *gfx)
{
	BitBlt(gfx->hdc, 0, 0, gfx->screen_width, gfx->screen_height,
	       gfx->mdc, 0, 0, SRCCOPY);
}

static uint32_t
argb_color(v4 color)
{
	uint32_t result = ((uint32_t) (uint8_t) (color.w * 255.9f) << 24) |
	                  ((uint32_t) (uint8_t) (color.x * 255.9f) << 16) |
	                  ((uint32_t) (uint8_t) (color.y * 255.9f) <<  8) |
	                  ((uint32_t) (uint8_t) (color.z * 255.9f) <<  0);

	return result;
}

static void
renderer_clear(struct Graphics *gfx, v4 color)
{
	uint16_t x, y;
	uint32_t color32 = argb_color(color);

	for (y = 0; y < gfx->height; ++y) {
		for (x = 0; x < gfx->width; ++x) {
			gfx->data[y * gfx->width + x] = color32;
		}
	}
}

static void
renderer_tri(struct Graphics *gfx, struct Vertices *vertices)
{
	const v3 *it;
	ptrdiff_t it_index;
	v4        interp_color;
	v2        screen_pos[3], min, max, p, ab, ac, pa, pb, pc;
	float     area_abc_x2, area_pbc_x2, area_pca_x2, alpha, beta, gamma;
	uint16_t  x, y;

	min = gfx->screen;
	max = make_v2(0.0f, 0.0f);
	for (it = vertices->pos; it < vertices->pos + 3; ++it) {
		if (it->z > 0.0f) return; /* @cleanup @robustness solidify valid ranges */
		it_index = it - vertices->pos;
		screen_pos[it_index].x = (it->x / -it->z + 1.0f) * 0.5f * gfx->screen.x;
		screen_pos[it_index].y = (it->y / -it->z + 1.0f) * 0.5f * gfx->screen.y;

		min.x = MIN(min.x, screen_pos[it_index].x);
		min.y = MIN(min.y, screen_pos[it_index].y);

		max.x = MAX(max.x, screen_pos[it_index].x);
		max.y = MAX(max.y, screen_pos[it_index].y);
	}

	min.x = MAX(min.x, 0);
	min.y = MAX(min.y, 0);
	max.x = MIN(max.x, gfx->width);
	max.y = MIN(max.y, gfx->height);

	ab = make_v2(screen_pos[1].x - screen_pos[0].x, screen_pos[1].y - screen_pos[0].y);
	ac = make_v2(screen_pos[2].x - screen_pos[0].x, screen_pos[2].y - screen_pos[0].y);

	area_abc_x2 = ab.x * ac.y - ab.y * ac.x;

	for (y = (uint16_t) min.y; y < (uint16_t) max.y; ++y) {
		for (x = (uint16_t) min.x; x < (uint16_t) max.x; ++x) {
			p = make_v2((float) x + 0.5f, (float) y + 0.5f);
			pa = make_v2(screen_pos[0].x - p.x,
			             screen_pos[0].y - p.y);
			pb = make_v2(screen_pos[1].x - p.x,
			             screen_pos[1].y - p.y);
			pc = make_v2(screen_pos[2].x - p.x,
			             screen_pos[2].y - p.y);

			area_pbc_x2 = pb.x * pc.y - pb.y * pc.x;
			area_pca_x2 = pc.x * pa.y - pc.y * pa.x;

			alpha = area_pbc_x2 / area_abc_x2;
			beta = area_pca_x2 / area_abc_x2;
			gamma = 1.0f - alpha - beta;

			if (alpha >= 0.0f && beta >= 0.0f && gamma >= 0.0f) {
				interp_color.x = vertices->color[0].x * alpha +
				                 vertices->color[1].x * beta +
				                 vertices->color[2].x * gamma;
				interp_color.y = vertices->color[0].y * alpha +
				                 vertices->color[1].y * beta +
				                 vertices->color[2].y * gamma;
				interp_color.z = vertices->color[0].z * alpha +
				                 vertices->color[1].z * beta +
				                 vertices->color[2].z * gamma;
				interp_color.w = vertices->color[0].w * alpha +
				                 vertices->color[1].w * beta +
				                 vertices->color[2].w * gamma;
				gfx->data[y * gfx->width + x] = argb_color(interp_color);
			}
		}
	}
}
