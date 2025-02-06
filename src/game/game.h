typedef struct {
	f32 delta;
	s32 width;
	s32 height;
	v2 mouse;
	bool lmb;
	bool* keys;

	// inout
	bool wants_quit;
} GameInput;

typedef enum {
	RENDER_COMMAND_NOOP = 0,
	RENDER_COMMAND_RECT = 1,
	RENDER_COMMAND_MODEL = 2,
} GameRenderCommandKind;

typedef struct {
	GameRenderCommandKind kind;
	union {
		struct {
			v4 offset_and_scale;
			v4 color;
			v4 texcoords;
			u32 texture_index;
		} rect;
		struct {
			m4 world_transform;
		} model;
	} u;
} GameRenderCommand;

typedef struct {
	v4 clear_color0;
	f32 clear_depth;

	Arena commands_arena;
} GameRenderer;

typedef struct {
	void* permanent_storage;
	s64 permanent_storage_size;
} GameMemory;

void game_update_and_render(GameInput*, GameRenderer*, GameMemory*);
