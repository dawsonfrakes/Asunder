#include "../modules/basic.h"
#include "game.h"

typedef struct {
	bool lmb_prev;
	v2 lmb_mouse;
} GameUI;

typedef struct {
	f32 x;
	f32 y;
	f32 w;
	f32 h;
	f32 xoff;
	f32 yoff;
	f32 xadvance;
} GameFontCharacter;

typedef struct {
	f32 w;
	f32 h;
	f32 line_height;
	f32 base;
	f32 ascent;
	f32 descent;
	GameFontCharacter characters[256];
} GameFont;

GameFont monocraft = {
	.w = 512.0f,
	.h = 256.0f,
	.line_height = 34.875f,
	.base = 28.5f,
	.ascent = 24.9375f,
	.descent = -3.5625f,
	.characters = {
		[32] = {.x = 288, .y = 136, .w = 9, .h = 9, .xoff = 0.0f, .yoff = 28.5f, .xadvance = 21.3333f},
		[33] = {.x = 50, .y = 103, .w = 12, .h = 33, .xoff = 7.0625f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[34] = {.x = 213, .y = 136, .w = 19, .h = 16, .xoff = 3.5f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[35] = {.x = 182, .y = 70, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[36] = {.x = 156, .y = 70, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[37] = {.x = 0, .y = 70, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[38] = {.x = 312, .y = 37, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[39] = {.x = 264, .y = 136, .w = 12, .h = 16, .xoff = 7.0625f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[40] = {.x = 460, .y = 70, .w = 19, .h = 33, .xoff = 3.5f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[41] = {.x = 441, .y = 70, .w = 19, .h = 33, .xoff = 3.5f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[42] = {.x = 194, .y = 136, .w = 19, .h = 19, .xoff = 3.5f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[43] = {.x = 338, .y = 103, .w = 26, .h = 26, .xoff = 0.0f, .yoff = 7.125f, .xadvance = 21.3333f},
		[44] = {.x = 232, .y = 136, .w = 16, .h = 16, .xoff = 3.5f, .yoff = 21.375f, .xadvance = 21.3333f},
		[45] = {.x = 130, .y = 136, .w = 26, .h = 12, .xoff = 0.0f, .yoff = 14.25f, .xadvance = 21.3333f},
		[46] = {.x = 276, .y = 136, .w = 12, .h = 12, .xoff = 7.0625f, .yoff = 24.9375f, .xadvance = 21.3333f},
		[47] = {.x = 338, .y = 37, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[48] = {.x = 364, .y = 37, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[49] = {.x = 390, .y = 37, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[50] = {.x = 416, .y = 37, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[51] = {.x = 442, .y = 37, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[52] = {.x = 468, .y = 37, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[53] = {.x = 26, .y = 70, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[54] = {.x = 286, .y = 37, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[55] = {.x = 52, .y = 70, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[56] = {.x = 78, .y = 70, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[57] = {.x = 104, .y = 70, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[58] = {.x = 156, .y = 136, .w = 12, .h = 26, .xoff = 7.0625f, .yoff = 10.6875f, .xadvance = 21.3333f},
		[59] = {.x = 166, .y = 103, .w = 16, .h = 30, .xoff = 3.5f, .yoff = 10.6875f, .xadvance = 21.3333f},
		[60] = {.x = 418, .y = 70, .w = 23, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[61] = {.x = 52, .y = 136, .w = 26, .h = 23, .xoff = 0.0f, .yoff = 10.6875f, .xadvance = 21.3333f},
		[62] = {.x = 303, .y = 70, .w = 23, .h = 33, .xoff = 3.5f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[63] = {.x = 416, .y = 0, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[64] = {.x = 52, .y = 0, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 7.125f, .xadvance = 21.3333f},
		[65] = {.x = 78, .y = 0, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[66] = {.x = 104, .y = 0, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[67] = {.x = 130, .y = 0, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[68] = {.x = 156, .y = 0, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[69] = {.x = 182, .y = 0, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[70] = {.x = 208, .y = 0, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[71] = {.x = 234, .y = 0, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[72] = {.x = 260, .y = 0, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[73] = {.x = 479, .y = 70, .w = 19, .h = 33, .xoff = 3.5f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[74] = {.x = 286, .y = 0, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[75] = {.x = 312, .y = 0, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[76] = {.x = 338, .y = 0, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[77] = {.x = 364, .y = 0, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[78] = {.x = 390, .y = 0, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[79] = {.x = 26, .y = 0, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[80] = {.x = 442, .y = 0, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[81] = {.x = 468, .y = 0, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[82] = {.x = 0, .y = 37, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[83] = {.x = 26, .y = 37, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[84] = {.x = 52, .y = 37, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[85] = {.x = 78, .y = 37, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[86] = {.x = 104, .y = 37, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[87] = {.x = 130, .y = 37, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[88] = {.x = 156, .y = 37, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[89] = {.x = 182, .y = 37, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[90] = {.x = 208, .y = 37, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[91] = {.x = 0, .y = 103, .w = 19, .h = 33, .xoff = 3.5f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[92] = {.x = 234, .y = 37, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[93] = {.x = 19, .y = 103, .w = 19, .h = 33, .xoff = 3.5f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[94] = {.x = 104, .y = 136, .w = 26, .h = 19, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[95] = {.x = 168, .y = 136, .w = 26, .h = 12, .xoff = 0.0f, .yoff = 28.5f, .xadvance = 21.3333f},
		[96] = {.x = 248, .y = 136, .w = 16, .h = 16, .xoff = 3.5f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[97] = {.x = 0, .y = 136, .w = 26, .h = 26, .xoff = 0.0f, .yoff = 10.6875f, .xadvance = 21.3333f},
		[98] = {.x = 260, .y = 37, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[99] = {.x = 468, .y = 103, .w = 26, .h = 26, .xoff = 0.0f, .yoff = 10.6875f, .xadvance = 21.3333f},
		[100] = {.x = 208, .y = 70, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[101] = {.x = 442, .y = 103, .w = 26, .h = 26, .xoff = 0.0f, .yoff = 10.6875f, .xadvance = 21.3333f},
		[102] = {.x = 395, .y = 70, .w = 23, .h = 33, .xoff = 1.75f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[103] = {.x = 140, .y = 103, .w = 26, .h = 30, .xoff = 0.0f, .yoff = 10.6875f, .xadvance = 21.3333f},
		[104] = {.x = 130, .y = 70, .w = 26, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[105] = {.x = 372, .y = 70, .w = 23, .h = 33, .xoff = 1.75f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[106] = {.x = 0, .y = 0, .w = 26, .h = 37, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[107] = {.x = 349, .y = 70, .w = 23, .h = 33, .xoff = 1.75f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[108] = {.x = 326, .y = 70, .w = 23, .h = 33, .xoff = 1.75f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[109] = {.x = 312, .y = 103, .w = 26, .h = 26, .xoff = 0.0f, .yoff = 10.6875f, .xadvance = 21.3333f},
		[110] = {.x = 286, .y = 103, .w = 26, .h = 26, .xoff = 0.0f, .yoff = 10.6875f, .xadvance = 21.3333f},
		[111] = {.x = 260, .y = 103, .w = 26, .h = 26, .xoff = 0.0f, .yoff = 10.6875f, .xadvance = 21.3333f},
		[112] = {.x = 114, .y = 103, .w = 26, .h = 30, .xoff = 0.0f, .yoff = 10.6875f, .xadvance = 21.3333f},
		[113] = {.x = 88, .y = 103, .w = 26, .h = 30, .xoff = 0.0f, .yoff = 10.6875f, .xadvance = 21.3333f},
		[114] = {.x = 234, .y = 103, .w = 26, .h = 26, .xoff = 0.0f, .yoff = 10.6875f, .xadvance = 21.3333f},
		[115] = {.x = 208, .y = 103, .w = 26, .h = 26, .xoff = 0.0f, .yoff = 10.6875f, .xadvance = 21.3333f},
		[116] = {.x = 234, .y = 70, .w = 23, .h = 33, .xoff = 1.75f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[117] = {.x = 364, .y = 103, .w = 26, .h = 26, .xoff = 0.0f, .yoff = 10.6875f, .xadvance = 21.3333f},
		[118] = {.x = 390, .y = 103, .w = 26, .h = 26, .xoff = 0.0f, .yoff = 10.6875f, .xadvance = 21.3333f},
		[119] = {.x = 182, .y = 103, .w = 26, .h = 26, .xoff = 0.0f, .yoff = 10.6875f, .xadvance = 21.3333f},
		[120] = {.x = 416, .y = 103, .w = 26, .h = 26, .xoff = 0.0f, .yoff = 10.6875f, .xadvance = 21.3333f},
		[121] = {.x = 62, .y = 103, .w = 26, .h = 30, .xoff = 0.0f, .yoff = 10.6875f, .xadvance = 21.3333f},
		[122] = {.x = 26, .y = 136, .w = 26, .h = 26, .xoff = 0.0f, .yoff = 10.6875f, .xadvance = 21.3333f},
		[123] = {.x = 280, .y = 70, .w = 23, .h = 33, .xoff = 0.0f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[124] = {.x = 38, .y = 103, .w = 12, .h = 33, .xoff = 7.0625f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[125] = {.x = 257, .y = 70, .w = 23, .h = 33, .xoff = 3.5f, .yoff = 3.5625f, .xadvance = 21.3333f},
		[126] = {.x = 78, .y = 136, .w = 26, .h = 19, .xoff = 0.0f, .yoff = 10.6875f, .xadvance = 21.3333f},
	},
};

typedef struct {
	bool initted;
	GameUI ui_state;
	struct {
		v3 position;
	} player;
} GameState;

GameRenderer* renderer;
GameInput* input;
GameState* state;
GameUI* ui;

GameRenderCommand* alloc_render_command(GameRenderCommandKind kind) {
	GameRenderCommand* command = cast(GameRenderCommand*) arena_alloc(&renderer->commands_arena, size_of(GameRenderCommand));
	command->kind = kind;
	return command;
}

void rect(f32 x, f32 y, f32 w, f32 h, v4 color) {
	GameRenderCommand* command = alloc_render_command(RENDER_COMMAND_RECT);
	command->u.rect.offset_and_scale = (v4) {x, y, w, h};
	command->u.rect.color = color;
	command->u.rect.texcoords = (v4) {0.0f, 0.0f, 1.0f, 1.0f};
	command->u.rect.texture_index = 0; // assuming white texture
}

void textured_rect(f32 x, f32 y, f32 w, f32 h, f32 tx1, f32 ty1, f32 tx2, f32 ty2, v4 tint, u32 texture_index) {
	GameRenderCommand* command = alloc_render_command(RENDER_COMMAND_RECT);
	command->u.rect.offset_and_scale = (v4) {x, y, w, h};
	command->u.rect.color = tint;
	command->u.rect.texcoords = (v4) {tx1, ty1, tx2, ty2};
	command->u.rect.texture_index = texture_index;
}

void model(v3 position) {
	GameRenderCommand* command = alloc_render_command(RENDER_COMMAND_MODEL);
	f32 x = position.x - state->player.position.x;
	f32 y = position.y - state->player.position.y;
	f32 z = position.z - state->player.position.z;
	command->u.model.world_transform = (m4) {{
		1.0f / -z, 0.0f, 0.0f, 0.0f,
		0.0f, 1.0f / -z, 0.0f, 0.0f,
		0.0f, 0.0f, 1.0f, 0.0f,
		x, y, z, 1.0f,
	}};
}

v4 calculate_text_bounds(string s, f32 x, f32 scale, f32 pad) {
	f32 xstart = x;
	for (s64 i = 0; i < s.count; i += 1) {
		u8 ch = s.data[i];
		GameFontCharacter c = monocraft.characters[ch];
		if (ch != ' ') {
			f32 y = monocraft.base * scale * 2.0f; // :todo figure out why 2x makes sense here
			f32 tx1 = c.x / (monocraft.w - 1);
			f32 ty1 = 1.0f - c.y / (monocraft.h - 1);
			f32 tx2 = (c.x + c.w) / (monocraft.w - 1);
			f32 ty2 = 1.0f - (c.y + c.h) / (monocraft.h - 1);
			textured_rect(x + c.xoff * scale, y - (c.h - 1 + c.yoff) * scale, c.w * scale, c.h * scale, tx1, ty2, tx2, ty1, (v4) {0.0f, 0.0f, 0.0f, 1.0f}, 1);
		}
		x += c.xadvance * scale;
	}
	return (v4) {xstart - pad, (monocraft.base + monocraft.descent) * scale - pad, x - xstart + pad * 2.0f, (monocraft.ascent - monocraft.descent) * scale + pad * 2.0f};
}

void text(string s, f32 x, f32 scale, v4 color) {
	for (s64 i = 0; i < s.count; i += 1) {
		u8 ch = s.data[i];
		GameFontCharacter c = monocraft.characters[ch];
		if (ch != ' ') {
			f32 y = monocraft.base * scale * 2.0f; // :todo figure out why 2x makes sense here
			f32 tx1 = c.x / (monocraft.w - 1);
			f32 ty1 = 1.0f - c.y / (monocraft.h - 1);
			f32 tx2 = (c.x + c.w) / (monocraft.w - 1);
			f32 ty2 = 1.0f - (c.y + c.h) / (monocraft.h - 1);
			textured_rect(x + c.xoff * scale, y - (c.h - 1 + c.yoff) * scale, c.w * scale, c.h * scale, tx1, ty2, tx2, ty1, color, 1);
		}
		x += c.xadvance * scale;
	}
}

bool contains(f32 x, f32 y, f32 w, f32 h, v2 p) {
	return x <= p.x && x + w >= p.x && y <= p.y && y + h >= p.y;
}

bool button(string s, f32 x, f32 scale) {
	v4 bounds = calculate_text_bounds(s, x, scale, 20.0f);
	bool hovered = contains(bounds.x, bounds.y, bounds.z, bounds.w, input->mouse);
	bool selected = contains(bounds.x, bounds.y, bounds.z, bounds.w, ui->lmb_mouse);

	v4 color = {0.0f, 0.0f, 0.0f, 1.0f};
	if (hovered) color = (v4) {1.0f, 0.0f, 0.0f, 1.0f};
	if (input->lmb && selected) color = (v4) {1.0f, 0.0f, 1.0f, 1.0f};

	rect(bounds.x, bounds.y, bounds.z, bounds.w, color);
	text(s, x, scale, (v4) {1.0f, 1.0f, 1.0f, 1.0f});

	return !input->lmb && ui->lmb_prev && hovered && selected;
}

void game_update_and_render(GameInput* new_input, GameRenderer* new_renderer, GameMemory* memory) {
	input = new_input;
	renderer = new_renderer;

	state = cast(GameState*) memory->permanent_storage;
	assert(size_of(GameState) <= memory->permanent_storage_size);
	if (!state->initted) {
		state->initted = true;

		ui = &state->ui_state;

		state->player.position = (v3) {0.0f, 0.0f, 0.0f};
	}

	renderer->clear_color0 = (v4) {0.6f, 0.2f, 0.2f, 1.0f};
	renderer->clear_depth = 0.0f;

	if (input->lmb && !ui->lmb_prev) ui->lmb_mouse = input->mouse;

	if (input->keys['W']) state->player.position.z -= input->delta;
	if (input->keys['S']) state->player.position.z += input->delta;
	if (input->keys['D']) state->player.position.x += input->delta;
	if (input->keys['A']) state->player.position.x -= input->delta;

	rect(0, 0, 500, 500, (v4) {0.2f, 0.2f, 0.2f, 1.0f});
	rect(cast(f32) (input->width - 1), cast(f32) (input->height - 1), -500, -500, (v4) {1.0f, 0.2f, 0.2f, 1.0f});

	if (button(S("Quit"), 0.0f, 2.0f)) {
		input->wants_quit = true;
	}

	model((v3) {0.0f, 0.0f, -1.0f});

	ui->lmb_prev = input->lmb;
}
