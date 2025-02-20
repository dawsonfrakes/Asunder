package game

ASUNDER_VERSION :: "DEV-2025-02"

import ba "../basic/bounded_array"

Input :: struct {
  delta: f32,
  width: f32,
  height: f32,
}

Memory :: struct {
  permanent: []u8,
}

Local_Player :: struct {
  players_index: u8,
}

Player :: struct {
  using transform: Transform,
}

State :: struct {
  initted: bool,
  local_players: ba.Bounded_Array(4, Local_Player),
  players: ba.Bounded_Array(256, Player),
}

update_and_render :: proc(renderer: ^Renderer, input: ^Input, memory: ^Memory) {
  assert(len(memory.permanent) >= size_of(State))
  state := cast(^State) raw_data(memory.permanent[:size_of(State)])
  if !state.initted {
    state.initted = true

    player0 := ba.append(&state.players, Player{
      position = {500, 500, 0},
    })
    ba.append(&state.local_players, Local_Player{players_index = u8(player0)})
  }

  renderer.clear({0.6, 0.2, 0.2, 1.0}, 0.0)

  text(renderer, "ASUNDER ALPHA " + ASUNDER_VERSION, {input.width / 2 - 250, input.height - 50}, 1.0, {0.2, 0.2, 0.2, 1.0})
}
