package glx

import X "../x11"

foreign import "system:GL"

DOUBLEBUFFER :: 5
RED_SIZE :: 8
GREEN_SIZE :: 9
BLUE_SIZE :: 10

Context :: distinct rawptr
FBConfig :: distinct rawptr

@(link_prefix="glX")
foreign GL {
	GetProcAddress :: proc(name: cstring) -> rawptr ---
	ChooseFBConfig :: proc(display: ^X.Display, screen: i32, attributes: [^]i32, count: ^i32) -> [^]FBConfig ---
	DestroyContext :: proc(display: ^X.Display, ctx: Context) ---
	MakeCurrent :: proc(display: ^X.Display, window: X.Window, ctx: Context) -> b32 ---
	SwapBuffers :: proc(display: ^X.Display, window: X.Window) ---
}
