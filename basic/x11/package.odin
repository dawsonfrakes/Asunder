package x11

foreign import "system:X11"

CopyFromParent :: 0
InputOutput :: 1
CWEventMask :: 1 << 11
CWBackPixel :: 1 << 1
StructureNotifyMask :: 1 << 17
DestroyNotify :: 17
ConfigureNotify :: 22
ClientMessage :: 33

Display :: struct {}
Visual :: struct {}
Atom :: distinct uintptr
Screen :: distinct uintptr
Window :: distinct uintptr
Pixmap :: distinct uintptr
Cursor :: distinct uintptr
Colormap :: distinct uintptr
SetWindowAttributes :: struct {
	background_pixmap: Pixmap,
	background_pixel: uintptr,
	border_pixmap: Pixmap,
	border_pixel: uintptr,
	bit_gravity: i32,
	win_gravity: i32,
	backing_store: i32,
	backing_planes: uintptr,
	backing_pixel: uintptr,
	save_under: b32,
	event_mask: int,
	do_not_propagate_mask: int,
	override_redirect: b32,
	colormap: Colormap,
	cursor: Cursor,
}
ConfigureEvent :: struct {
	type: i32,
	serial: uintptr,
	send_event: b32,
	display: ^Display,
	event: Window,
	window: Window,
	x: i32,
  y: i32,
  width: i32,
  height: i32,
	border_width: i32,
	above: Window,
	override_redirect: b32,
}
ClientMessageEvent :: struct {
	type: i32,
	serial: uintptr,
	send_event: b32,
	display: ^Display,
	window: Window,
	message_type: Atom,
	format: i32,
	data: struct #raw_union {
		b: [20]u8,
		s: [10]u16,
		l: [5]uintptr,
  },
}
Event :: struct #raw_union {
  type: i32,
  xconfigure: ConfigureEvent,
  xclient: ClientMessageEvent,
  pad: [24]uintptr,
}

@(link_prefix="X")
foreign X11 {
  OpenDisplay :: proc(name: cstring) -> ^Display ---
  CloseDisplay :: proc(display: ^Display) -> i32 ---
  RootWindow :: proc(display: ^Display) -> Window ---
  DefaultScreen :: proc(display: ^Display) -> Screen ---
  BlackPixel :: proc(display: ^Display, screen: Screen) -> uintptr ---
  CreateWindow :: proc(display: ^Display, parent: Window, x, y: i32, w, h, border: u32, depth: i32, class: u32, visual: ^Visual, mask: u32, attributes: ^SetWindowAttributes) -> Window ---
  StoreName :: proc(display: ^Display, window: Window, name: cstring) -> i32 ---
  MapWindow :: proc(display: ^Display, window: Window) -> i32 ---
  Pending :: proc(display: ^Display) -> i32 ---
  NextEvent :: proc(display: ^Display, event: ^Event) -> i32 ---
  InternAtom :: proc(display: ^Display, name: cstring, only_if_exists: b32) -> Atom ---
  SetWMProtocols :: proc(display: ^Display, window: Window, protocols: [^]Atom, count: i32) -> i32 ---
  DestroyWindow :: proc(display: ^Display, window: Window) -> i32 ---
}