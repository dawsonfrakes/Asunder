DEBUG :: true;

#import "Basic";
#import "Compiler";

build :: () {
	set_build_options_dc(.{do_output = false});

	options := get_build_options();
	options.output_type = .EXECUTABLE;
	options.output_executable_name = "Asunder";
	if options.os_target == .MACOS options.additional_linker_arguments = .["-framework", "AppKit"];

	w := compiler_create_workspace();
	set_build_options(options, w);
	add_build_string(tprint("DEBUG :: %;", DEBUG), w);
	if options.os_target == {
		case .WINDOWS; add_build_file("src/platform/main_windows.jai", w);
		case .MACOS; add_build_file("src/platform/main_macos.jai", w);
		case; print("OS % is not currently supported\n", options.os_target);
	}

	if options.os_target == .MACOS && !DEBUG {
		#import "MacOS_Bundler";
		create_app_bundle("Asunder", "./Asunder", "", "", false, false);
	}
}

#run build();
