DEBUG :: true;

#import "Basic";
#import "Compiler";

build :: () {
  set_build_options_dc(.{do_output = false});

  options := get_build_options();
  options.output_type = .EXECUTABLE;
  options.output_executable_name = "Asunder";
  options.output_path = ".build";

  w := compiler_create_workspace();
  set_build_options(options, w);
  add_build_string(tprint("DEBUG :: %;", DEBUG), w);
  if options.os_target == {
    case .WINDOWS;
      add_build_string("RENDER_API :: Render_API.OPENGL;", w);
      add_build_file("platform/main_windows.jai", w);
    case .LINUX;
      add_build_string("RENDER_API :: Render_API.OPENGL;", w);
      add_build_file("platform/main_unix.jai", w);
    case;
      print("error: Target % is not supported\n", options.os_target);
  }
}

#run build();
