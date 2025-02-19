package game

import "core:math/linalg"
import "../assets/fonts"

Rect_Texture :: enum {
	WHITE = 0,
	FONT = 1,
}

Mesh_Kind :: enum {
	CUBE = 0,
}

Renderer :: struct {
	clear: proc(color0: [4]f32, depth: f32),
	rect: proc(position: [3]f32, size: [2]f32, texcoords: [2][2]f32, texture: Rect_Texture, color: [4]f32, rotation: f32),
	mesh: proc(kind: Mesh_Kind, world_transform: matrix[4, 4]f32, local_transform: matrix[4, 4]f32),
}

Input :: struct {
	mouse: [2]f32,
	lmb: bool,
	wants_quit: bool,
	width: f32,
	height: f32,
}

rect :: proc(renderer: ^Renderer, position: [2]f32, size: [2]f32, color: [4]f32, rotation: f32 = 0.0, z_index: f32 = -1.0) {
	renderer.rect({position.x, position.y, z_index}, size, {{0.0, 0.0}, {1.0, 1.0}}, .WHITE, color, rotation)
}

trect :: proc(renderer: ^Renderer, texture: Rect_Texture, position: [2]f32, size: [2]f32, texcoords: [2][2]f32, color: [4]f32 = 1.0, rotation: f32 = 0.0, z_index: f32 = -1.0) {
	renderer.rect({position.x, position.y, z_index}, size, texcoords, texture, color, rotation)
}

text_bounds :: proc(s: string, position: [2]f32, scale: f32 = 1.0) -> (rmin: [2]f32, rmax: [2]f32) {
	rmin, rmax = position, position
	x: f32 = position.x - fonts.mikado.characters[s[0]].xoff * scale
	y: f32 = position.y + (fonts.mikado.base + abs(fonts.mikado.descent)) * scale
	for ch in s {
		c := fonts.mikado.characters[ch]
		x += cast(f32) c.w / 2.0 * scale

		x1 := x - cast(f32) c.w / 2.0 * scale + c.xoff * scale
		y1 := y - cast(f32) c.h / 2.0 * scale - (cast(f32) c.h / 2.0 * scale)  - c.yoff * scale
		x2 := x + cast(f32) c.w / 2.0 * scale + c.xoff * scale
		y2 := y + cast(f32) c.h / 2.0 * scale - (cast(f32) c.h / 2.0 * scale)  - c.yoff * scale
		rmin.x = min(rmin.x, x1, x2)
		rmin.y = min(rmin.y, y1, y2)
		rmax.x = max(rmax.x, x1, x2)
		rmax.y = max(rmax.y, y1, y2)

		x += (-cast(f32) c.w / 2.0 + c.xadvance) * scale
	}
	return
}

text :: proc(renderer: ^Renderer, s: string, position: [2]f32, scale: f32 = 1.0, color: [4]f32 = 1.0, z_index: f32 = -1.0) {
	x: f32 = position.x - fonts.mikado.characters[s[0]].xoff * scale
	y: f32 = position.y + (fonts.mikado.base + abs(fonts.mikado.descent)) * scale
	for ch in s {
		c := fonts.mikado.characters[ch]
		x += cast(f32) c.w / 2.0 * scale
		if ch != ' ' {
			x1 := cast(f32) c.x / cast(f32) (fonts.mikado.w - 1)
			y1 := 1.0 - cast(f32) c.y / cast(f32) (fonts.mikado.h - 1)
			x2 := cast(f32) (c.x + c.w) / cast(f32) (fonts.mikado.w - 1)
			y2 := 1.0 - cast(f32) (c.y + c.h) / cast(f32) (fonts.mikado.h - 1)
			trect(renderer, .FONT, {x + c.xoff * scale, y - (cast(f32) c.h / 2.0 * scale) - c.yoff * scale}, {cast(f32) c.w * scale, cast(f32) c.h * scale}, {{x1, y2}, {x2, y1}}, color = color, z_index = z_index)
		}
		x += (-cast(f32) c.w / 2.0 + c.xadvance) * scale
	}
}

UI :: struct {
	renderer: ^Renderer,
	input: ^Input,
	left_mouse_handled: bool,
	lmb_at: [2]f32,
	lmb_prev: bool,
	current_button_y: f32,
}

contains :: proc(p, rmin, rmax: [2]f32) -> bool {
	return p.x >= rmin.x && p.x <= rmax.x && p.y >= rmin.y && p.y <= rmax.y
}

button :: proc(ui: ^UI, s: string) -> (pressed: bool) {
	color := [4]f32{0.2, 0.2, 0.2, 1.0}

	scale: f32 = 1.0
	position := [2]f32{0, ui.current_button_y}
	rmin, rmax := text_bounds(s, position, scale = scale)

	if contains(ui.input.mouse, rmin, rmax) {
		color = {0.3, 0.3, 0.3, 1.0}
		if ui.input.lmb do color = {0.4, 0.4, 0.4, 1.0}
		if !ui.left_mouse_handled && !ui.input.lmb && ui.lmb_prev && contains(ui.lmb_at, rmin, rmax) {
			ui.left_mouse_handled = true
			pressed = true
		}
	}

	rect(ui.renderer, {rmin.x + (rmax.x - rmin.x) / 2.0, rmin.y + (rmax.y - rmin.y) / 2.0}, {rmax.x - rmin.x, rmax.y - rmin.y}, color)
	text(ui.renderer, s, position, scale = scale)

	ui.current_button_y += (fonts.mikado.line_height + abs(fonts.mikado.descent)) * scale

	return
}

remove_this_but_its_lmb_prev: bool
remove_this_but_its_lmb_at: [2]f32

update_and_render :: proc(renderer: ^Renderer, input: ^Input) {
	ui := UI{renderer = renderer, input = input, lmb_at = remove_this_but_its_lmb_at, lmb_prev = remove_this_but_its_lmb_prev}
	defer remove_this_but_its_lmb_prev = input.lmb
	defer remove_this_but_its_lmb_at = ui.lmb_at

	if input.lmb && !ui.lmb_prev do ui.lmb_at = input.mouse

	renderer.clear({0.6, 0.2, 0.2, 1.0}, 0.0)
	rect(renderer, {input.width / 2.0 - 2, input.height / 2.0 - 2}, {2 * 2, 2 * 2}, {1.0, 0.0, 0.0, 1.0})

	if button(&ui, "Quit") do input.wants_quit = true

	cube0_position := linalg.matrix4_translate_f32({2.5, 0.0, -5.0})
	cube1_position := linalg.matrix4_translate_f32({-2.5, 0.0, -5.0})
	projection := linalg.matrix4_infinite_perspective_f32(1.0, input.width / input.height, 0.1)

	renderer.mesh(.CUBE, projection * cube0_position, cube0_position)
	renderer.mesh(.CUBE, projection * cube1_position, cube1_position)

	text(renderer, "Asunder Alpha 0.0.1", {input.width / 2.0 - 150.0, input.height - 50.0}, color = {0.3, 0.3, 0.3, 0.6})
}
