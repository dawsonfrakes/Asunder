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
  if options.os_target == {
    case .WINDOWS;
      add_build_file("platform/main_windows.jai", w);
    case;
      print("error: Target % is not supported\n", options.os_target);
  }
}

#run build();
