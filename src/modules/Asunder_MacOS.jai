libSystem :: #library,system "libSystem";

exit :: (status: u32) #foreign libSystem;

libobjc :: #library,system "libobjc";

objc_Class :: #type,distinct *void;
objc_SEL :: #type,distinct *void;

objc_msgSend :: () #foreign libobjc;
objc_getClass :: (name: *u8) -> objc_Class #foreign libobjc;
sel_getUid :: (name: *u8) -> objc_SEL #foreign libobjc;

Foundation :: #library,system "Foundation";

AppKit :: #library,system "AppKit";

NSApplication :: struct {
  ActivationPolicy :: enum s32 {
    REGULAR :: 0;
    ACCESSORY :: 1;
    PROHIBITED :: 2;
  }
  sharedApplication :: inline () -> *NSApplication {
    msg := cast(#type (cls: objc_Class, sel: objc_SEL) -> *NSApplication #c_call) objc_msgSend;
    return msg(_cls.NSApplication, _sel.sharedApplication);
  }

  setActivationPolicy_ :: inline (obj: *NSApplication, policy: ActivationPolicy) -> s8 {
    msg := cast(#type (obj: *NSApplication, sel: objc_SEL, policy: ActivationPolicy) -> s8 #c_call) objc_msgSend;
    return msg(obj, _sel.setActivationPolicy_, policy);
  }
}

_cls: struct {
  NSApplication: objc_Class;
}

_sel: struct {
  sharedApplication: objc_SEL;
  setActivationPolicy_: objc_SEL;
}

objc_load_classes_and_selectors :: () {
  #insert -> string {
    Basic :: #import "Basic";
    b: Basic.String_Builder;
    for type_info(type_of(_cls)).members {
      Basic.print_to_builder(*b, "_cls.%1 = objc_getClass(\"%1\");\n", it.name);
    }
    for type_info(type_of(_sel)).members {
      s := Basic.copy_temporary_string(it.name);
      for * s if it.* == #char "_" it.* = #char ":";
      Basic.print_to_builder(*b, "_sel.% = sel_getUid(\"%\");\n", it.name, s);
    }
    return Basic.builder_to_string(*b);
  }
}
