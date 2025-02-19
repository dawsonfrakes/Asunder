package game

Bounded_Array :: struct (N: int, T: typeid) {
  buffer: [N]T,
  len: int,
}

ba_append :: proc(barray: ^Bounded_Array($N, $T), items: ..T, loc := #caller_location) -> (n: int) #no_bounds_check {
  assert(barray.len + len(items) <= N, loc = loc)
  n = barray.len
  for item in items {
    barray.buffer[barray.len] = item
    barray.len += 1
  }
  return
}

ba_slice_range :: proc(barray: Bounded_Array($N, $T), start: int, end: int) -> []T {
  assert(start <= barray.len);
  assert(end <= barray.len);
  return barray.buffer[start:end]
}

ba_slice_begin :: proc(barray: Bounded_Array($N, $T), start := 0) -> []T {
  return ba_slice_range(barray, start, barray.len)
}

slice :: proc{ba_slice_begin, ba_slice_range}

Renderer_Procs :: struct {
  clear: proc(color0: [4]f32, depth: f32),
}

Renderer :: struct {
  using procs: Renderer_Procs,
}

Input :: struct {
  delta: f32,
}

Memory :: struct {
  permanent: []u8,
}

Transform :: struct {
  translation: [3]f32,
  rotation: [3]f32,
  scale: [3]f32,
}

Local_Player :: struct {
  players_index: u8,
}

Player :: struct {
  transform: Transform,
}

State :: struct {
  initted: bool,
  local_players: Bounded_Array(4, Local_Player),
  players: Bounded_Array(256, Player),
}

update_and_render :: proc(renderer: ^Renderer, input: ^Input, memory: ^Memory) {
  assert(len(memory.permanent) >= size_of(State))
  state := cast(^State) raw_data(memory.permanent[:size_of(State)])
  if !state.initted {
    state.initted = true

    player0 := ba_append(&state.players, Player{})
    ba_append(&state.local_players, Local_Player{players_index = u8(player0)})
  }

  renderer.clear({0.6, 0.2, 0.2, 1.0}, 0.0)
}
