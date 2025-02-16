DEBUG :: true;

#import "Basic";
#import "Compiler";

build :: () {
  set_build_options_dc(.{do_output = false});

  options := get_build_options();
  options.output_type = .EXECUTABLE;
  options.output_executable_name = "Asunder";
  options.runtime_support_definitions = .OMIT;

  import_path: [..]string;
  array_add(*import_path, "src/modules");
  array_add(*import_path, .. options.import_path);
  options.import_path = import_path;

  if options.os_target == {
    case .MACOS;
      options.additional_linker_arguments = .["-framework", "AppKit", "-e", "_entry"];
  }

  w := compiler_create_workspace();
  set_build_options(options, w);
  add_build_string(tprint("DEBUG :: %;\n", DEBUG), w);
  if options.os_target == {
    case .MACOS;
      add_build_file("src/platform/main_macos.jai", w);
  }
}

#run build();
