#+build linux, freebsd, openbsd, netbsd, haiku

package main

foreign import "system:X11"

CopyFromParent :: 0
InputOutput :: 1

Display :: struct {}
Visual :: struct {}
Window :: distinct u32
Atom :: distinct u32
XEvent :: struct #raw_union {
	type: i32,
	// xany: XAnyEvent,
	// xkey: XKeyEvent,
	// xbutton: XButtonEvent,
	// xmotion: XMotionEvent,
	// xcrossing: XCrossingEvent,
	// xfocus: XFocusChangeEvent,
	// xexpose: XExposeEvent,
	// xgraphicsexpose: XGraphicsExposeEvent,
	// xnoexpose: XNoExposeEvent,
	// xvisibility: XVisibilityEvent,
	// xcreatewindow: XCreateWindowEvent,
	// xdestroywindow: XDestroyWindowEvent,
	// xunmap: XUnmapEvent,
	// xmap: XMapEvent,
	// xmaprequest: XMapRequestEvent,
	// xreparent: XReparentEvent,
	// xconfigure: XConfigureEvent,
	// xgravity: XGravityEvent,
	// xresizerequest: XResizeRequestEvent,
	// xconfigurerequest: XConfigureRequestEvent,
	// xcirculate: XCirculateEvent,
	// xcirculaterequest: XCirculateRequestEvent,
	// xproperty: XPropertyEvent,
	// xselectionclear: XSelectionClearEvent,
	// xselectionrequest: XSelectionRequestEvent,
	// xselection: XSelectionEvent,
	// xcolormap: XColormapEvent,
	// xclient: XClientMessageEvent,
	// xmapping: XMappingEvent,
	// xerror: XErrorEvent,
	// xkeymap: XKeymapEvent,
	pad: [24]u32,
}
XSetWindowAttributes :: struct {}

foreign X11 {
  XOpenDisplay :: proc(name: [^]u8) -> ^Display ---
  XCloseDisplay :: proc(display: ^Display) -> i32 ---
  XRootWindow :: proc(display: ^Display) -> Window ---
  XCreateWindow :: proc(display: ^Display, parent: Window, x, y: i32, w, h, border: u32, depth: i32, class: u32, visual: ^Visual, mask: u32, attributes: ^XSetWindowAttributes) -> Window ---
  XMapWindow :: proc(display: ^Display, window: Window) -> i32 ---
  XPending :: proc(display: ^Display) -> i32 ---
  XNextEvent :: proc(display: ^Display, event: ^XEvent) -> i32 ---
}

main :: proc() {
  display := XOpenDisplay(nil)
  defer XCloseDisplay(display)
  root := XRootWindow(display);

  window := XCreateWindow(display, root, 0, 0, 600, 400, 0, CopyFromParent, InputOutput, cast(^Visual) cast(uintptr) CopyFromParent, 0, nil)
  XMapWindow(display, window)

  for {
    for XPending(display) > 0 {
      event: XEvent = ---
      XNextEvent(display, &event)
    }
  }
}
