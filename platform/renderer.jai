Render_API :: enum {
  NONE :: 0;
  OPENGL :: 1;
}

#if RENDER_API == {
  case .NONE;
    renderer :: struct {
      init :: () #no_context {}
      deinit :: () #no_context {}
      resize :: () #no_context {}
      present :: () #no_context {}
      game_procs :: Game_Renderer.Procs.{
        clear = (color0: [4]float32, depth: float32) {}
      };
    }
  case .OPENGL;
    #assert(OS == .WINDOWS || OS == .LINUX);
    #load "renderer_opengl.jai";
    renderer :: opengl_renderer;
}
