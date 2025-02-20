package main

import NS "../basic/objc"

platform_app: ^NS.Application
platform_window: ^NS.Window
platform_width: int
platform_height: int

main :: proc() {
  platform_app = NS.Application.sharedApplication()
  platform_app->setActivationPolicy(.REGULAR)

  platform_window = NS.Window.alloc()->initWithContentRect({{0, 0}, {600, 400}}, {.TITLED} | {.CLOSABLE} | {.RESIZABLE} | {.MINIATURIZABLE}, .BUFFERED, false)
  platform_window->setTitle(NS.String.alloc()->initWithUTF8String("Asunder"))
  platform_window->makeKeyAndOrderFront(nil)

  platform_app->run()
}
