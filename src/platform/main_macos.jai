libobjc :: #library,system "libobjc";

objc_getClass :: (name: *u8) -> *void #foreign libobjc;
objc_msgSend :: () #foreign libobjc;
sel_getUid :: (name: *u8) -> *void #foreign libobjc;

// CoreGraphics
CGPoint :: struct {
  x: float64;
  y: float64;
}
CGSize :: struct {
  w: float64;
  h: float64;
}
CGRect :: struct {
  origin: CGPoint;
  size: CGSize;
}

// Foundation
NSRect :: CGRect;

// AppKit
NSApplicationActivationPolicy :: enum s32 {
  REGULAR :: 0;
  ACCESSORY :: 1;
  PROHIBITED :: 2;
}
NSWindowStyleMask :: enum_flags u32 {
  TITLED :: 1 << 0;
  CLOSABLE :: 1 << 1;
  MINIATURIZABLE :: 1 << 2;
  RESIZABLE :: 1 << 3;
}
NSBackingStoreType :: enum u32 {
  BUFFERED :: 2;
}

NSApplication_sharedApplication :: () -> *void #expand { return (cast(#type (cls: *void, sel: *void) -> *void #c_call) objc_msgSend)(`NSApplication, `sel_sharedApplication); }
NSApplication_setActivationPolicy :: (obj: *void, policy: NSApplicationActivationPolicy) -> bool #expand { return (cast(#type (obj: *void, sel: *void, policy: NSApplicationActivationPolicy) -> bool #c_call) objc_msgSend)(obj, `sel_setActivationPolicy, policy); }
NSApplication_run :: (obj: *void) #expand { (cast(#type (obj: *void, sel: *void) #c_call) objc_msgSend)(obj, `sel_run); }

NSWindow_alloc :: () -> *void #expand { return (cast(#type (cls: *void, sel: *void) -> *void #c_call) objc_msgSend)(`NSWindow, `sel_alloc); }
NSWindow_initWithContentRectstyleMaskbackingdefer :: (obj: *void, contentRect: NSRect, styleMask: NSWindowStyleMask, backing: NSBackingStoreType, deferred: bool) -> *void #expand { return (cast(#type (obj: *void, sel: *void, contentRect: NSRect, styleMask: NSWindowStyleMask, backing: NSBackingStoreType, deferred: bool) -> *void #c_call) objc_msgSend)(obj, `sel_initWithContentRectstyleMaskbackingdefer, contentRect, styleMask, backing, deferred); }
NSWindow_makeKeyAndOrderFront :: (obj: *void, sender: *void) #expand { (cast(#type (obj: *void, sel: *void, sender: *void) #c_call) objc_msgSend)(obj, `sel_makeKeyAndOrderFront, sender); }

main :: () {
  NSString := objc_getClass("NSString");
  NSApplication := objc_getClass("NSApplication");
  NSWindow := objc_getClass("NSWindow");

  sel_alloc := sel_getUid("alloc");
  sel_sharedApplication := sel_getUid("sharedApplication");
  sel_setActivationPolicy := sel_getUid("setActivationPolicy:");
  sel_initWithContentRectstyleMaskbackingdefer := sel_getUid("initWithContentRect:styleMask:backing:defer:");
  sel_makeKeyAndOrderFront := sel_getUid("makeKeyAndOrderFront:");
  sel_run := sel_getUid("run");

  app := NSApplication_sharedApplication();
  NSApplication_setActivationPolicy(app, .REGULAR);

  window := NSWindow_initWithContentRectstyleMaskbackingdefer(NSWindow_alloc(), NSRect.{.{0, 0}, .{600, 400}},
    .TITLED | .CLOSABLE | .MINIATURIZABLE | .RESIZABLE, .BUFFERED, false);
  NSWindow_makeKeyAndOrderFront(window, null);

  NSApplication_run(app);
}
