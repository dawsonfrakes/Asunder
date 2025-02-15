import basic.macos;

__gshared NSApplication platform_app;
__gshared bool platform_running = true;

import core.attribute : selector;

extern(Objective-C) class AsunderApplicationDelegate : NSObject, NSApplicationDelegate {
  override static NSObject new_() @selector("new");

  override void applicationDidFinishLaunching(NSNotification notification) @selector("applicationDidFinishLaunching:") {
    platform_app.stop(null);
  }
}

extern(Objective-C) class AsunderWindowDelegate : NSObject, NSWindowDelegate {
  override static NSObject new_() @selector("new");

  override void windowWillClose(NSNotification notification) @selector("windowWillClose:") {
    platform_running = false;
  }
}

extern(C) noreturn main() {
  platform_app = NSApplication.sharedApplication();
  platform_app.setActivationPolicy(NSApplication.ActivationPolicy.REGULAR);
  platform_app.setDelegate(AsunderApplicationDelegate.new_());

  NSWindow window = NSWindow.alloc().initWithContentRectStyleMaskBackingDefer(NSRect(CGPoint(0, 0), CGSize(600, 400)), NSWindow.StyleMask.TITLED | NSWindow.StyleMask.CLOSABLE | NSWindow.StyleMask.MINIATURIZABLE | NSWindow.StyleMask.RESIZABLE, NSWindow.BackingStore.BUFFERED, false);
  window.setTitle(NSString.alloc().initWithUTF8String("Asunder"));
  window.setDelegate(AsunderWindowDelegate.new_());
  window.center();
  window.setFrameAutosaveName(NSString.alloc().initWithUTF8String("window"));
  window.makeKeyAndOrderFront(null);

  platform_app.run();

  while (platform_running) {
    while (true) {
      NSEvent event = platform_app.nextEventMatchingMaskUntilDateInModeDequeue(NSEvent.Mask.ANY, NSDate.distantPast, NSString.alloc().initWithUTF8String("kCFRunLoopDefaultMode"), true);
      if (!event) break;
      platform_app.sendEvent(event);
      event.release();
    }

    usleep(1000);
  }

  exit(0);
}

pragma(linkerDirective, "-framework", "AppKit");
