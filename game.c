#include "game.h"
#include "renderer.h"
#include "vector_math.c"

struct GameState {
	v3    camera_pos;
	v3    camera_vel;
	float camera_force;
	float camera_drag;

	float phys_dt;
	float phys_accum;

	uint8_t initted;
};

static void
update(struct Memory *memory, struct Input *input, struct Graphics *gfx)
{
	struct Vertices vertices;
	v3 camera_acc;
	struct GameState *gs = (struct GameState *) memory->permanent;

	ASSERT(sizeof(*gs) <= memory->permanent_size);
	if (!gs->initted) {
		gs->initted = 1;

		gs->camera_force = 10.0f;
		gs->camera_drag  = 3.0f;

		gs->phys_dt = 1.0f / 144.0f;
	}

	renderer_clear(gfx, make_v4(0.2f, 0.2f, 0.2f, 1.0f));

	camera_acc = make_v3(0.0f, 0.0f, 0.0f);
	if (input->keys & GAME_KEY_FORWARD) camera_acc.z -= 1.0f;
	if (input->keys & GAME_KEY_BACKWARD) camera_acc.z += 1.0f;

	gs->phys_accum += input->dt;
	while (gs->phys_accum >= gs->phys_dt) {
		gs->phys_accum -= gs->phys_dt;

		gs->camera_vel.x += camera_acc.x * gs->phys_dt * gs->camera_force;
		gs->camera_vel.y += camera_acc.y * gs->phys_dt * gs->camera_force;
		gs->camera_vel.z += camera_acc.z * gs->phys_dt * gs->camera_force;

		gs->camera_pos.x += gs->camera_vel.x * gs->phys_dt;
		gs->camera_pos.y += gs->camera_vel.y * gs->phys_dt;
		gs->camera_pos.z += gs->camera_vel.z * gs->phys_dt;

		gs->camera_vel.x += gs->camera_vel.x * -gs->camera_drag * gs->phys_dt;
		gs->camera_vel.y += gs->camera_vel.y * -gs->camera_drag * gs->phys_dt;
		gs->camera_vel.z += gs->camera_vel.z * -gs->camera_drag * gs->phys_dt;
	}

	vertices.pos[0].x = -0.5f - gs->camera_pos.x;
	vertices.pos[0].y = -0.5f - gs->camera_pos.y;
	vertices.pos[0].z = -2.0f - gs->camera_pos.z;
	vertices.color[0] = make_v4(1.0f, 0.0f, 0.0f, 1.0f);

	vertices.pos[1].x = 0.5f - gs->camera_pos.x;
	vertices.pos[1].y = -0.5f - gs->camera_pos.y;
	vertices.pos[1].z = -2.0f - gs->camera_pos.z;
	vertices.color[1] = make_v4(0.0f, 1.0f, 0.0f, 1.0f);

	vertices.pos[2].x = 0.0f - gs->camera_pos.x;
	vertices.pos[2].y = 0.5f - gs->camera_pos.y;
	vertices.pos[2].z = -2.0f - gs->camera_pos.z;
	vertices.color[2] = make_v4(0.0f, 0.0f, 1.0f, 1.0f);

	renderer_tri(gfx, &vertices);
}
