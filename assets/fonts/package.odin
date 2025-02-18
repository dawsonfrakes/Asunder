package fonts

Font :: struct {
	size: u16,
	line_height: f32,
	base: f32,
	ascent: f32,
	descent: f32,
	w: u16,
	h: u16,
	characters: [256]struct {
		x: u16,
		y: u16,
		w: u16,
		h: u16,
		xoff: f32,
		yoff: f32,
		xadvance: f32,
	},
}
