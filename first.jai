DEBUG :: true;

#import "Basic";
#import "Compiler";

#run {
	set_build_options_dc(.{do_output = false});

	options := get_build_options();
	options.output_type = .EXECUTABLE;
	options.output_path = ".build";
	options.output_executable_name = "Asunder";

	w := compiler_create_workspace();
	set_build_options(options, w);
	add_build_string(tprint("DEBUG :: %;", DEBUG), w);
	if options.os_target == {
		case .WINDOWS;
			add_build_file("platform/main_windows.jai", w);
	}
}
