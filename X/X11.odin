package X

foreign import "system:X11"

CopyFromParent :: 0
InputOutput :: 1

Display :: struct {}
Visual :: struct {}
Window :: distinct u32
SetWindowAttributes :: struct {

}
Event :: struct #raw_union {
  type: i32,
  pad: [24]u32,
}

@(link_prefix="X")
foreign X11 {
  OpenDisplay :: proc(name: cstring) -> ^Display ---
  CloseDisplay :: proc(display: ^Display) -> i32 ---
  RootWindow :: proc(display: ^Display) -> Window ---
  CreateWindow :: proc(display: ^Display, root: Window, x, y: i32, width, height, border: u32, depth: i32, class: u32, visual: ^Visual, valuemask: u32, attributes: ^SetWindowAttributes) -> Window ---
  MapWindow :: proc(display: ^Display, window: Window) -> i32 ---
  Pending :: proc(display: ^Display) -> i32 ---
  NextEvent :: proc(display: ^Display, event: ^Event) -> i32 ---
}
