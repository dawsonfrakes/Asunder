// :todo replace objc messages with c calls.

#include "basic/basic.h"
#import <AppKit/AppKit.h> // :todo replace this with basic/macos.h

NSApplication* platform_app;
NSWindow* platform_window;
bool platform_running = true;

@interface AsunderApplicationDelegate : NSObject <NSApplicationDelegate>
@end

@implementation AsunderApplicationDelegate
-(void)applicationDidFinishLaunching:(NSNotification*)notification {
  [platform_app stop:nil];
}
@end

@interface AsunderWindowDelegate : NSObject <NSWindowDelegate>
@end

@implementation AsunderWindowDelegate
-(void)windowWillClose:(NSNotification*)notification {
  platform_running = false;
}
@end

noreturn_t start(void) {
  platform_app = [NSApplication sharedApplication];
  [platform_app setDelegate:[AsunderApplicationDelegate new]];
  [platform_app setActivationPolicy:NSApplicationActivationPolicyRegular];

  NSMenu* appbar = [NSMenu new];
  [platform_app setMainMenu:appbar];

  NSMenuItem* appmenuitem = [[NSMenuItem alloc] initWithTitle:@"Asunder" action:nil keyEquivalent:@""];
  [appbar addItem:appmenuitem];

  NSMenu* appmenu = [NSMenu new];
  [appmenuitem setSubmenu: appmenu];

  NSMenuItem* quitbutton = [[NSMenuItem alloc] initWithTitle:@"Quit Asunder" action:@selector(terminate:) keyEquivalent:@"q"];
  [appmenu addItem:quitbutton];

  platform_window = [[NSWindow alloc] initWithContentRect:(NSRect){(CGPoint){0.0, 0.0}, (CGSize){600.0, 400.0}} styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskResizable|NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskClosable backing:NSBackingStoreBuffered defer:NO];
  [platform_window setDelegate:[AsunderWindowDelegate new]];
  [platform_window center];
  [platform_window setFrameAutosaveName:@"AsunderWindow"];
  [platform_window setTitle:@"Asunder"];
  [platform_window makeKeyAndOrderFront:nil];

  [platform_app run];

  for (;;) {
    for (;;) {
      NSEvent* event = [platform_app nextEventMatchingMask:NSEventMaskAny untilDate:nil inMode:NSDefaultRunLoopMode dequeue:YES];
      if (!event) break;
      [platform_app sendEvent:event];
      [event release];
    }
    if (!platform_running) break;
  }

  exit(0);
}
