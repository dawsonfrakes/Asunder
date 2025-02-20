DEBUG :: true;

#import "Basic";
#import "Compiler";
#import "File";

build :: () {
  set_build_options_dc(.{do_output = false});

  options := get_build_options();
  options.output_type = .EXECUTABLE;
  options.output_executable_name = "Asunder";

  if options.os_target == {
    case .WINDOWS;
      w := compiler_create_workspace();
      set_build_options(options, w);
      add_build_string(tprint("DEBUG :: %;", DEBUG), w);
      add_build_string("RENDER_API :: Render_API.OPENGL;", w);
      add_build_file("platform/main_windows.jai", w);
    case .MACOS;
      w := compiler_create_workspace();
      options.output_path = ".build";
      set_build_options(options, w);

      compiler_begin_intercept(w);
      add_build_string(tprint("DEBUG :: %;", DEBUG), w);
      add_build_file("platform/main_macos.jai", w);
      while true {
        msg := compiler_wait_for_message();
        if msg.workspace != w continue;
        if msg.kind == .COMPLETE break;
      }
      compiler_end_intercept(w);

      #if OS_IS_UNIX { // NOTE(dfra): MacOS_Bundler doesn't currently work on windows (despite just being a folder creator).
        #import "MacOS_Bundler";
        create_app_bundle(options.output_executable_name, tprint(".build/%", options.output_executable_name), "", "", false, false);
        b: String_Builder;
        plist_start(*b);
          success := plist_write_key_value(*b, "NSRequiresAquaSystemAppearance", false);
          success &= plist_write_key_value(*b, "NSHighResolutionCapable", true);
          success &= plist_write_key_value(*b, "NSAppSleepDisabled", true);
          assert(success);
        plist_end(*b);
        write_entire_file(tprint("%.app/Contents/Info.plist", options.output_executable_name), builder_to_string(*b));
      }
    case;
      print("error: target % not supported", options.os_target);
  }
}

#run build();
