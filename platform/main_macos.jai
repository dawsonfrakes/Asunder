#import "MacOS";
#import "Objective_C";
#import "Objective_C/AppKit";

NSApplication_setWindowsMenu :: (self: *NSApplication, menu: *NSMenu) -> *NSMenu #no_context {
  func :: #type (*void, Selector, *NSMenu) -> *NSMenu #c_call;
  return (cast(func) objc_msgSend)(self, sel_getUid(cast(*u8) "setWindowsMenu:"), menu);
}

NSWindow_setFrameAutosaveName :: (self: *NSWindow, name: *NSString) -> BOOL #no_context {
  func :: #type (*void, Selector, *NSString) -> BOOL #c_call;
  return (cast(func) objc_msgSend)(self, sel_getUid(cast(*u8) "setFrameAutosaveName:"), name);
}

platform_app: *NSApplication;
platform_window: *NSWindow;
platform_width: int;
platform_height: int;

main :: () {
  init_objective_c();
  init_app_kit();

  platform_app = NSApplication.sharedApplication();
  NSApplication.setActivationPolicy(platform_app, .NSApplicationActivationPolicyRegular);

  appbar := objc_new(NSMenu);
  NSApplication.setMainMenu(platform_app, appbar);

  appmenuitem := objc_alloc(NSMenuItem);
  NSMenuItem.initWithTitle(appmenuitem, NSString.getTempString("Asunder"), null, NSString.getTempString(""));
  NSMenu.addItem(appbar, appmenuitem);

  appmenu := objc_new(NSMenu);
  NSMenuItem.setSubmenu(appmenuitem, appmenu);

  quitbutton := objc_alloc(NSMenuItem);
  NSMenuItem.initWithTitle(quitbutton, NSString.getTempString("Quit Asunder"), sel_getUid("terminate:"), NSString.getTempString("q"));
  NSMenu.addItem(appmenu, quitbutton);

  windowsmenuitem := objc_alloc(NSMenuItem);
  NSMenuItem.initWithTitle(windowsmenuitem, NSString.getTempString("Window"), null, NSString.getTempString(""));
  NSMenu.addItem(appbar, windowsmenuitem);

  windowsmenu := objc_new(NSMenu);
  NSMenuItem.setSubmenu(windowsmenuitem, windowsmenu);
  NSApplication_setWindowsMenu(platform_app, windowsmenu);

  platform_window = objc_alloc(NSWindow);
  NSWindow.initWithContentRect(platform_window, .{.{0, 0}, .{600, 400}}, .NSWindowStyleMaskTitled | .NSWindowStyleMaskClosable | .NSWindowStyleMaskMiniaturizable | .NSWindowStyleMaskResizable, .NSBackingStoreBuffered, xx false);
  NSWindow.setTitle(platform_window, NSString.getTempString("Asunder"));
  NSWindow.center(platform_window);
  NSWindow_setFrameAutosaveName(platform_window, NSString.getTempString("AsunderWindowSave"));
  NSWindow.makeKeyAndOrderFront(platform_window, null);

  NSApplication.run(platform_app);
}
