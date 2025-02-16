#import "Asunder_MacOS";

my_main :: () {
  objc_load_classes_and_selectors();

  app := NSApplication.sharedApplication();
  NSApplication.setActivationPolicy_(app, .REGULAR);
}

entry :: () #foreign {
  push_context .{} { my_main(); }
  exit(0);
}
