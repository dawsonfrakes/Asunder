#import "Basic";
#import "Compiler";
#import "File";

build :: () {
  set_build_options_dc(.{do_output = false});

  options := get_build_options();
  options.output_type = .EXECUTABLE;
  options.output_executable_name = "Asunder";

  if options.os_target == {
    case .MACOS;
      w := compiler_create_workspace();
      options.output_path = ".build";
      set_build_options(options, w);

      compiler_begin_intercept(w);
      add_build_file("platform/main_macos.jai", w);
      while true {
        msg := compiler_wait_for_message();
        if msg.workspace != w continue;
        if msg.kind == .COMPLETE break;
      }
      compiler_end_intercept(w);

      MacOS_Bundler :: #import "MacOS_Bundler";
      MacOS_Bundler.create_app_bundle(options.output_executable_name, tprint(".build/%", options.output_executable_name), "", "", false, false);
      b: String_Builder;
      MacOS_Bundler.plist_start(*b);
        success := MacOS_Bundler.plist_write_key_value(*b, "NSRequiresAquaSystemAppearance", false);
        success &= MacOS_Bundler.plist_write_key_value(*b, "NSHighResolutionCapable", true);
        success &= MacOS_Bundler.plist_write_key_value(*b, "NSAppSleepDisabled", true);
        assert(success);
      MacOS_Bundler.plist_end(*b);
      write_entire_file(tprint("%.app/Contents/Info.plist", options.output_executable_name), builder_to_string(*b));
    case;
      assert(false, "error: target % not supported", options.os_target);
  }
}

#run build();
