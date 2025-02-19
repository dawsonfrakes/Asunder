Game_Renderer :: struct {
  Procs :: struct {
    clear: (color0: [4]float32, depth: float32);
  }

  using procs: Procs;
}

game_update_and_render :: (renderer: *Game_Renderer) {
  renderer.clear(.[0.6, 0.2, 0.2, 1.0], 0.0);
}
