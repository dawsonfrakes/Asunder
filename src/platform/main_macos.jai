libobjc :: #library,system "libobjc";

objc_getClass :: (name: *u8) -> *void #foreign libobjc;
objc_msgSend :: () #foreign libobjc;
sel_getUid :: (name: *u8) -> *void #foreign libobjc;

// AppKit
NSApplicationActivationPolicy :: enum s32 {
  REGULAR :: 0;
  ACCESSORY :: 1;
  PROHIBITED :: 2;
}

NSApplication_sharedApplication :: () -> *void #expand { return (cast(#type (cls: *void, sel: *void) -> *void #c_call) objc_msgSend)(`NSApplication, `sel_sharedApplication); }
NSApplication_setActivationPolicy :: (obj: *void, policy: NSApplicationActivationPolicy) -> bool #expand { return (cast(#type (obj: *void, sel: *void, policy: NSApplicationActivationPolicy) -> bool #c_call) objc_msgSend)(obj, `sel_setActivationPolicy, policy); }

main :: () {
  NSString := objc_getClass("NSString");
  NSApplication := objc_getClass("NSApplication");
  NSWindow := objc_getClass("NSWindow");

  sel_sharedApplication := sel_getUid("sharedApplication");
  sel_setActivationPolicy := sel_getUid("setActivationPolicy:");

  app := NSApplication_sharedApplication();
  NSApplication_setActivationPolicy(app, .REGULAR);
}
