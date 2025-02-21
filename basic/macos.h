// libSystem
noreturn_t exit(s32);

// libobjc
typedef struct objc_class* Class;
typedef struct objc_selector* SEL;

void objc_msgSend(void);
Class objc_getClass(u8*);
SEL sel_getUid(u8*);

// Foundation
typedef struct NSObject {
  void* isa;
} NSObject;

// AppKit
#define NSApplication_sharedApplication() (cast(NSApplication* (*)(Class, SEL)) objc_msgSend)(cls_NSApplication, sel_sharedApplication)
#define NSApplication_setActivationPolicy(self, policy) (cast(bool (*)(NSApplication*, SEL, s32)) objc_msgSend)(self, sel_setActivationPolicy_, policy)

typedef struct NSApplication {
  NSObject object;
} NSApplication;

typedef struct NSResponder {
  NSObject object;
} NSResponder;

typedef struct NSWindow {
  NSResponder responder;
} NSWindow;

extern NSApplication* NSApp;
