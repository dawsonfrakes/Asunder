module basic.macos;

// libSystem
extern(C) int usleep(uint);
extern(C) noreturn exit(int);

// libobjc
import core.attribute : optional, selector;

struct objc_selector;
alias SEL = objc_selector*;

// fwCoreGraphics
struct CGPoint {
  double x;
  double y;
}
struct CGSize {
  double width;
  double height;
}
struct CGRect {
  CGPoint origin;
  CGSize size;
}

// fwFoundation
alias NSRect = CGRect;

extern(Objective-C) extern class NSObject {
  static NSObject new_() @selector("new");
  static NSObject alloc() @selector("alloc");
  NSObject init() @selector("init");
  void release() @selector("release");
}

extern(Objective-C) extern class NSString : NSObject {
  override static NSString alloc() @selector("alloc");
  NSString initWithUTF8String(const(char)*) @selector("initWithUTF8String:");
  override void release() @selector("release");
}

// fwAppKit
alias NSRunLoopMode = NSString;
extern(Objective-C) extern class NSNotification : NSObject {}
extern(Objective-C) extern class NSDate : NSObject {
  static NSDate distantPast() @selector("distantPast");
}
extern(Objective-C) extern class NSResponder : NSObject {}
extern(Objective-C) extern class NSEvent : NSObject {
  enum Mask : ulong {
    ANY = 0xFFFFFFFF,
  }

  override void release() @selector("release");
}
extern(Objective-C) interface NSApplicationDelegate {
  @optional void applicationDidFinishLaunching(NSNotification notification) @selector("applicationDidFinishLaunching:");
}
extern(Objective-C) extern class NSApplication : NSResponder {
  enum ActivationPolicy : int {
    REGULAR = 0,
    ACCESSORY = 1,
    PROHIBITED = 2,
  }

  static NSApplication sharedApplication() @selector("sharedApplication");
  ubyte setActivationPolicy(ActivationPolicy) @selector("setActivationPolicy:");
  NSObject setDelegate(NSObject) @selector("setDelegate:");
  void run() @selector("run");
  void stop(void* sender) @selector("stop:");
  NSEvent nextEventMatchingMaskUntilDateInModeDequeue(NSEvent.Mask, NSDate, NSRunLoopMode, ubyte) @selector("nextEventMatchingMask:untilDate:inMode:dequeue:");
  void sendEvent(NSEvent) @selector("sendEvent:");
}
extern(Objective-C) interface NSWindowDelegate {
  @optional void windowWillClose(NSNotification notification) @selector("windowWillClose:");
}
extern(Objective-C) extern class NSWindow : NSResponder {
  enum StyleMask : uint {
    TITLED = 1 << 0,
    CLOSABLE = 1 << 1,
    MINIATURIZABLE = 1 << 2,
    RESIZABLE = 1 << 3,
  }
  enum BackingStore : uint {
    BUFFERED = 2,
  }

  override static NSWindow alloc() @selector("alloc");
  NSWindow initWithContentRectStyleMaskBackingDefer(NSRect, StyleMask, BackingStore, ubyte) @selector("initWithContentRect:styleMask:backing:defer:");
  NSString title() @selector("title");
  NSString setTitle(NSString) @selector("setTitle:");
  NSObject setDelegate(NSObject) @selector("setDelegate:");
  void makeKeyAndOrderFront(void* sender) @selector("makeKeyAndOrderFront:");
  void center() @selector("center");
  void setFrameAutosaveName(NSString) @selector("setFrameAutosaveName:");
}
