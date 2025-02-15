bool platform_running = true;

#import <AppKit/AppKit.h>

@interface AsunderApplicationDelegate : NSObject <NSApplicationDelegate>
@end

@implementation AsunderApplicationDelegate
-(void)applicationDidFinishLaunching:(NSNotification*)notification {
  (void) notification;
  [NSApp stop:nil];
}
@end

@interface AsunderWindowDelegate : NSObject <NSWindowDelegate>
@end

@implementation AsunderWindowDelegate
-(void)windowWillClose:(NSNotification*)notification {
  (void) notification;
  platform_running = false;
}
@end

extern "C" [[noreturn]] void start() {
  [NSApplication sharedApplication];
  [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
  [NSApp setDelegate:[AsunderApplicationDelegate new]];

  NSMenu* appbar = [NSMenu new];
  [NSApp setMainMenu:appbar];

  NSMenuItem* appmenuitem = [NSMenuItem new];
  [appbar addItem:appmenuitem];

  NSMenu* appmenu = [NSMenu new];
  [appmenuitem setSubmenu:appmenu];

  NSMenuItem* quitbutton = [[NSMenuItem alloc] initWithTitle:@"Quit Asunder" action:@selector(terminate:) keyEquivalent:@"q"];
  [appmenu addItem:quitbutton];

  NSMenuItem *windowmenuitem = [[NSMenuItem alloc] initWithTitle:@"Window" action:nil keyEquivalent:@""];
  [appbar addItem:windowmenuitem];

  NSMenu *windowmenu = [[NSMenu alloc] initWithTitle:@"Window"];
  [windowmenuitem setSubmenu:windowmenu];

  [NSApp setWindowsMenu:windowmenu];

  NSRect windowRect = {{0, 0}, {600, 400}};
  NSWindow* window = [[NSWindow alloc]
    initWithContentRect:windowRect
    styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskResizable
    backing:NSBackingStoreBuffered
    defer:NO];
  [window setTitle:@"Asunder"];
  [window setDelegate:[AsunderWindowDelegate new]];
  [window center];
  [window setFrameAutosaveName:@"MainWindow"];
  [window makeKeyAndOrderFront:nil];

  [NSApp run];

  while (platform_running) {
    for (;;) {
      NSEvent* event = [NSApp nextEventMatchingMask:NSEventMaskAny untilDate:nil inMode:NSDefaultRunLoopMode dequeue:YES];
      if (!event) break;
      [NSApp sendEvent:event];
      [event release];
    }

    usleep(1000);
  }

  exit(0);
}
