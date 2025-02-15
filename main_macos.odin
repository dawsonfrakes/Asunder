package main

import "base:intrinsics"
import NS "core:sys/darwin/Foundation"

foreign import System "system:system"

foreign System {
  usleep :: proc(duration: u32) -> i32 ---
}

platform_app: ^NS.Application
platform_running := true

main :: proc() {
  platform_app = NS.Application.sharedApplication()
  platform_app->setActivationPolicy(.Regular)

  applicationDidFinishLaunching :: proc(notification: ^NS.Notification) {
    intrinsics.objc_send(nil, platform_app, "stop:", cast(rawptr) nil)
  }

  platform_app->setDelegate(NS.application_delegate_register_and_alloc({applicationDidFinishLaunching = applicationDidFinishLaunching}, "AsunderApplicationDelegate", nil))

  appbar := NS.Menu.alloc()->init()
  platform_app->setMainMenu(appbar)

  appmenuitem := NS.MenuItem.alloc()->init()
  appbar->addItem(appmenuitem)

  appmenu := NS.Menu.alloc()->init()
  appmenuitem->setSubmenu(appmenu)

  quitbutton := NS.MenuItem.alloc()->initWithTitle(NS.String.alloc()->initWithOdinString("Quit Asunder"), intrinsics.objc_find_selector("terminate:"), NS.String.alloc()->initWithOdinString("q"))
  appmenu->addItem(quitbutton)

  windowsmenuitem := NS.MenuItem.alloc()->initWithTitle(NS.String.alloc()->initWithOdinString("Window"), nil, NS.String.alloc()->initWithOdinString(""))
  appbar->addItem(windowsmenuitem)

  windowsmenu := NS.Menu.alloc()->init()
  windowsmenuitem->setSubmenu(windowsmenu)

  intrinsics.objc_send(^NS.Menu, platform_app, "setWindowsMenu:", windowsmenu)

  window := NS.Window.alloc()->initWithContentRect({{0, 0}, {600, 400}}, NS.WindowStyleMaskTitled | NS.WindowStyleMaskClosable | NS.WindowStyleMaskMiniaturizable | NS.WindowStyleMaskResizable, .Buffered, false)
  window->setTitle(NS.String.alloc()->initWithOdinString("Asunder"))

  windowWillClose :: proc(notification: ^NS.Notification) {
    platform_running = false
  }

  window->setDelegate(NS.window_delegate_register_and_alloc({windowWillClose = windowWillClose}, "AsunderWindowDelegate", nil))

  intrinsics.objc_send(nil, window, "center")
  window->setFrameAutosaveName(NS.String.alloc()->initWithOdinString("AsunderWindow"))
  window->makeKeyAndOrderFront(nil)

  platform_app->run()

  for platform_running {
    for {
      event := platform_app->nextEventMatchingMask(NS.EventMaskAny, nil, NS.DefaultRunLoopMode, true)
      if event == nil { break }
      platform_app->sendEvent(event)
      event->release()
    }

    usleep(1000)
  }
}
