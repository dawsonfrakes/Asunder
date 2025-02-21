#include "../basic/basic.h"
#include "../basic/macos.h"

Class cls_NSApplication;
SEL sel_sharedApplication;
SEL sel_setActivationPolicy_;

noreturn_t start(void) {
  cls_NSApplication = objc_getClass("NSApplication");
  sel_sharedApplication = sel_getUid("sharedApplication");
  sel_setActivationPolicy_ = sel_getUid("setActivationPolicy:");

  NSApplication_sharedApplication();
  NSApplication_setActivationPolicy(NSApp, 0);

  exit(0);
}
