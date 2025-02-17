package main

import "base:intrinsics"
import "core:time"
import NS "core:sys/darwin/Foundation"

Application_stop :: proc "c" (self: ^NS.Application, sender: ^NS.Object) {
  intrinsics.objc_send(nil, self, "stop:", sender)
}
Application_setWindowsMenu :: proc "c" (self: ^NS.Application, menu: ^NS.Menu) -> ^NS.Menu {
  return intrinsics.objc_send(^NS.Menu, self, "setWindowsMenu:", menu)
}
Window_center :: proc "c" (self: ^NS.Window) {
  intrinsics.objc_send(nil, self, "center")
}
View_frame :: proc "c" (self: ^NS.View) -> NS.Rect {
  return intrinsics.objc_send(NS.Rect, self, "frame")
}

platform_app: ^NS.Application
platform_window: ^NS.Window
platform_running := true
platform_width: int = 600
platform_height: int = 400

main :: proc() {
  NSString :: proc(s: string) -> ^NS.String {
    return NS.String.alloc()->initWithOdinString(s)
  }

  platform_app = NS.Application.sharedApplication()
  platform_app->setActivationPolicy(.Regular)

  applicationDidFinishLaunching :: proc(notification: ^NS.Notification) {
    Application_stop(platform_app, nil)
  }

  app_delegate := NS.application_delegate_register_and_alloc({applicationDidFinishLaunching=applicationDidFinishLaunching}, "AsunderApplicationDelegate", nil)
  platform_app->setDelegate(app_delegate)

  appbar := NS.Menu.alloc()
  platform_app->setMainMenu(appbar)

  appmenuitem := NS.MenuItem.alloc()->initWithTitle(NSString("Asunder"), nil, NSString(""))
  appbar->addItem(appmenuitem)

  appmenu := NS.Menu.alloc()->init()
  appmenuitem->setSubmenu(appmenu)

  quitbutton := NS.MenuItem.alloc()->initWithTitle(NSString("Quit Asunder"), intrinsics.objc_find_selector("terminate:"), NSString("q"))
  appmenu->addItem(quitbutton)

  windowsmenuitem := NS.MenuItem.alloc()->initWithTitle(NSString("Window"), nil, NSString(""))
  appbar->addItem(windowsmenuitem)

  windowsmenu := NS.Menu.alloc()->init()
  windowsmenuitem->setSubmenu(windowsmenu)

  Application_setWindowsMenu(platform_app, windowsmenu)

  platform_window = NS.Window.alloc()->initWithContentRect({{0, 0}, {cast(NS.Float) platform_width, cast(NS.Float) platform_height}}, {.Titled} | {.Closable} | {.Miniaturizable} | {.Resizable}, .Buffered, false)

  windowWillClose :: proc(notification: ^NS.Notification) {
    platform_running = false
  }

  windowDidResize :: proc(notification: ^NS.Notification) {
    size := View_frame(platform_window->contentView()).size
    platform_width = cast(int) size.width
    platform_height = cast(int) size.height
  }

  window_delegate := NS.window_delegate_register_and_alloc({windowWillClose=windowWillClose, windowDidResize=windowDidResize}, "AsunderWindowDelegate", nil)
  platform_window->setDelegate(window_delegate)

  platform_window->setTitle(NSString("Asunder"))
  Window_center(platform_window)
  platform_window->setFrameAutosaveName(NSString("AsunderWindow"))
  platform_window->makeKeyAndOrderFront(nil)

  platform_app->run()

  main_loop: for platform_running {
    for {
      event := platform_app->nextEventMatchingMask(NS.EventMaskAny, nil, NS.DefaultRunLoopMode, true)
      if event == nil do break
      platform_app->sendEvent(event)
      event->release()
    }

    time.sleep(1 * time.Millisecond)
  }
}
