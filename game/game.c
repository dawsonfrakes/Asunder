#include "game.h"

void game_update_and_render(Game_Input* input, Game_Renderer* renderer) {
	(void) input;
	renderer->clear((f32[4]) {0.6f, 0.2f, 0.2f, 1.0f}, 0.0f);
}
