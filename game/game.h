#include "../basic/basic.h"

typedef struct {
	f32 delta;
	sint width;
	sint height;
	sint mouse_x;
	sint mouse_y;
} Game_Input;

typedef struct {
	void (*clear)(f32 color0[4], f32 depth);
} Game_Renderer;

void game_update_and_render(Game_Input*, Game_Renderer*);
