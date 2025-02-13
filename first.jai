#import "Compiler";

build :: () {
	set_build_options_dc(.{do_output = false});

	options := get_build_options();
	options.output_type = .EXECUTABLE;
	options.output_executable_name = "Asunder";

	w := compiler_create_workspace();
	set_build_options(options, w);
	if options.os_target == .WINDOWS add_build_file("src/platform/main_windows.jai", w);
}

#run build();
