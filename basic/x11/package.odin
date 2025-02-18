package x11

foreign import lib "system:X11"

CopyFromParent :: 0
InputOutput :: 1
CWBackPixel :: 1 << 1
CWEventMask :: 1 << 11
StructureNotifyMask :: 1 << 17
DestroyNotify :: 17
ClientMessage :: 33

Display :: struct {}
Visual :: struct {}
Atom :: distinct uintptr
Screen :: distinct uintptr
Window :: distinct uintptr
Pixmap :: distinct uintptr
Colormap :: distinct uintptr
Cursor :: distinct uintptr
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
ClientMessageEvent :: struct {
	type: i32,
	serial: uintptr,
	send_event: b32,
	display: ^Display,
	window: Window,
	message_type: Atom,
	format: u32,
	data: struct #raw_union {
		b: [20]u8,
		s: [10]u16,
		l: [5]uintptr,
	},
}
Event :: struct #raw_union {
	type: i32,
	xclient: ClientMessageEvent,
	pad: [24]int,
}

@(link_prefix="X")
foreign lib {
	OpenDisplay :: proc(name: cstring) -> ^Display ---
	CloseDisplay :: proc(display: ^Display) -> i32 ---
	RootWindow :: proc(display: ^Display) -> Window ---
	DefaultScreen :: proc(display: ^Display) -> Screen ---
	DefaultVisual :: proc(display: ^Display, screen: Screen) -> ^Visual ---
	BlackPixel :: proc(display: ^Display, screen: Screen) -> uintptr ---
	CreateWindow :: proc(display: ^Display, parent: Window, x, y: i32, w, h, border: u32, depth: i32, class: u32, visual: ^Visual, mask: uintptr, attributes: ^SetWindowAttributes) -> Window ---
	MapWindow :: proc(display: ^Display, window: Window) -> i32 ---
	Pending :: proc(display: ^Display) -> i32 ---
	NextEvent :: proc(display: ^Display, event: ^Event) -> i32 ---
	InternAtom :: proc(display: ^Display, name: cstring, only_if_exists: b32) -> Atom ---
	SetWMProtocols :: proc(display: ^Display, window: Window, atoms: [^]Atom, count: i32) -> i32 ---
	DestroyWindow :: proc(display: ^Display, window: Window) -> i32 ---
}
