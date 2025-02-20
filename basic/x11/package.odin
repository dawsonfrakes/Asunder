package x11

foreign import "system:X11"

CopyFromParent :: 0
InputOutput :: 1
CWEventMask :: 1 << 11
StructureNotifyMask :: 1 << 17
DestroyNotify :: 17
ConfigureNotify :: 22
ClientMessage :: 33

Display :: struct {}
Visual :: struct {}
Atom :: distinct int
Window :: distinct int
Pixmap :: distinct int
Colormap :: distinct int
Cursor :: distinct int
SetWindowAttributes :: struct {
	background_pixmap: Pixmap,
	background_pixel: uint,
	border_pixmap: Pixmap,
	border_pixel: uint,
	bit_gravity: i32,
	win_gravity: i32,
	backing_store: i32,
	backing_planes: uint,
	backing_pixel: uint,
	save_under: b32,
	event_mask: int,
	do_not_propagate_mask: int,
	override_redirect: b32,
	colormap: Colormap,
	cursor: Cursor,
}
ConfigureEvent :: struct {
	type: i32,
	serial: uint,
	send_event: b32,
	display: ^Display,
	event: Window,
	window: Window,
	x, y: i32,
	width, height: i32,
	border_width: i32,
	above: Window,
	override_redirect: b32,
}
ClientMessageEvent :: struct {
	type: i32,
	serial: uint,
	send_event: b32,
	display: ^Display,
	window: Window,
	message_type: Atom,
	format: i32,
	data: struct #raw_union {
		b: [20]u8,
		s: [10]u16,
		l: [5]uint,
	},
}
Event :: struct #raw_union {
	type: i32,
	xconfigure: ConfigureEvent,
	xclient: ClientMessageEvent,
	pad: [24]int,
}

@(link_prefix="X")
foreign X11 {
	OpenDisplay :: proc(name: cstring) -> ^Display ---
	CloseDisplay :: proc(display: ^Display) -> i32 ---
	DefaultScreen :: proc(display: ^Display) -> i32 ---
	RootWindow :: proc(display: ^Display, screen: i32) -> Window ---
	CreateWindow :: proc(display: ^Display, parent: Window, x, y: i32, w, h, border: u32, depth: i32, class: u32, visual: ^Visual, valuemask: uint, attibutes: ^SetWindowAttributes) -> Window ---
	MapWindow :: proc(display: ^Display, window: Window) -> i32 ---
	InternAtom :: proc(display: ^Display, name: cstring, only_if_exists: b32) -> Atom ---
	SetWMProtocols :: proc(display: ^Display, window: Window, protocols: [^]Atom, count: i32) -> i32 ---
	Pending :: proc(display: ^Display) -> i32 ---
	NextEvent :: proc(display: ^Display, event: ^Event) -> i32 ---
}
