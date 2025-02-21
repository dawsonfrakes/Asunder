#include "../basic/basic.h"

typedef struct {
	f32 delta;
	sint width;
	sint height;
	sint mouse_x;
	sint mouse_y;
} Game_Input;

void game_update_and_render(Game_Input*);
