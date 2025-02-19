Game_Renderer :: struct {
  clear: (color0: [4]float32, depth: float32);
}

game_update_and_render :: (renderer: *Game_Renderer) {
  renderer.clear(.[0.6, 0.2, 0.2, 1.0], 0.0);
}
