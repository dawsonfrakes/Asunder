package objc

import "base:intrinsics"

foreign import "system:Foundation.framework"
@require foreign import "system:AppKit.framework"

RunLoopMode :: ^String
Point :: struct {
	x: f64,
	y: f64,
}
Size :: struct {
	width:  f64,
	height: f64,
}
Rect :: struct {
  using origin: Point,
  using size: Size,
}

@(objc_class="NSObject")
Object :: struct {using _: intrinsics.objc_object}

@(objc_class="NSObject")
Copying :: struct($T: typeid) {using _: Object}

alloc :: proc "c" ($T: typeid) -> ^T where intrinsics.type_is_subtype_of(T, Object) {
  return intrinsics.objc_send(^T, T, "alloc")
}

@(objc_type=Object, objc_name="init")
init :: proc "c" (self: ^$T) -> ^T where intrinsics.type_is_subtype_of(T, Object) {
  return intrinsics.objc_send(^T, self, "init")
}

@(objc_type=Object, objc_name="copy")
copy :: proc "c" (self: ^Copying($T)) -> ^T where intrinsics.type_is_subtype_of(T, Object) {
  return intrinsics.objc_send(^T, self, "copy")
}

new :: proc "c" ($T: typeid) -> ^T where intrinsics.type_is_subtype_of(T, Object) {
  return init(alloc(T))
}

@(objc_type=Object, objc_name="release")
release :: proc "c" (self: ^Object) {
	intrinsics.objc_send(nil, self, "release")
}

@(objc_class="NSString")
String :: struct {using _: Copying(String)}

@(objc_type=String, objc_name="alloc", objc_is_class_method=true)
String_alloc :: proc "c" () -> ^String {
  return intrinsics.objc_send(^String, String, "alloc")
}

@(objc_type=String, objc_name="initWithUTF8String")
String_initWithUTF8String :: proc "c" (self: ^String, utf8_string: cstring) -> ^String {
  return intrinsics.objc_send(^String, self, "initWithUTF8String:", utf8_string)
}

@(objc_class="NSDate")
Date :: struct {using _: Copying(Date)}

@(objc_class="NSEvent")
Event :: struct {using _: Object}

EventType :: enum uint {
  LeftMouseDown = 1,
  LeftMouseUp = 2,
  RightMouseDown = 3,
  RightMouseUp = 4,
  MouseMoved = 5,
  LeftMouseDragged = 6,
  RightMouseDragged = 7,
  MouseEntered = 8,
  MouseExited = 9,
  KeyDown = 10,
  KeyUp = 11,
  FlagsChanged = 12,
  AppKitDefined = 13,
  SystemDefined = 14,
  ApplicationDefined = 15,
  Periodic = 16,
  CursorUpdate = 17,
  Rotate = 18,
  BeginGesture = 19,
  EndGesture = 20,
  ScrollWheel = 22,
  TabletPoint = 23,
  TabletProximity = 24,
  OtherMouseDown = 25,
  OtherMouseUp = 26,
  OtherMouseDragged = 27,
  Gesture = 29,
  Magnify = 30,
  Swipe = 31,
  SmartMagnify = 32,
  QuickLook = 33,
  Pressure = 34,
  DirectTouch = 37,
  ChangeMode = 38,
}

EventMask :: distinct bit_set[EventType; uint]
EventMaskAny :: transmute(EventMask) max(uint)

@(objc_class="NSMenuItem")
MenuItem :: struct {using _: Object}

@(objc_class="NSMenu")
Menu :: struct {using _: Object}

@(objc_class="NSApplication")
Application :: struct {using _: Object}

ActivationPolicy :: enum uint {
  REGULAR = 0,
  ACCESSORY = 1,
  PROHIBITED = 2,
}

@(objc_type=Application, objc_name="sharedApplication", objc_is_class_method=true)
Application_sharedApplication :: proc "c" () -> ^Application {
  return intrinsics.objc_send(^Application, Application, "sharedApplication")
}

@(objc_type=Application, objc_name="setActivationPolicy")
Application_setActivationPolicy :: proc "c" (self: ^Application, activationPolicy: ActivationPolicy) -> bool {
  return intrinsics.objc_send(bool, self, "setActivationPolicy:", activationPolicy)
}

@(objc_type=Application, objc_name="setMainMenu")
Application_setMainMenu :: proc "c" (self: ^Application, menu: ^Menu) {
  intrinsics.objc_send(nil, self, "setMainMenu:", menu)
}

@(objc_type=Application, objc_name="run")
Application_run :: proc "c" (self: ^Application) {
  intrinsics.objc_send(nil, self, "run")
}

@(objc_type=Application, objc_name="stop")
Application_stop :: proc "c" (self: ^Application, sender: rawptr) {
  intrinsics.objc_send(nil, self, "stop:", sender)
}

@(objc_type=Application, objc_name="nextEventMatchingMask")
Application_nextEventMatchingMask :: proc "c" (self: ^Application, mask: EventMask, expiration: ^Date, in_mode: RunLoopMode, dequeue: bool) -> ^Event {
  return intrinsics.objc_send(^Event, self, "nextEventMatchingMask:untilDate:inMode:dequeue:", mask, expiration, in_mode, dequeue)
}

@(objc_type=Application, objc_name="sendEvent")
Application_sendEvent :: proc "c" (self: ^Application, event: ^Event) {
  intrinsics.objc_send(nil, self, "sendEvent:", event)
}

@(objc_class="NSResponder")
Responder :: struct {using _: Object}

@(objc_class="NSWindow")
Window :: struct {using _: Responder}

WindowStyleFlag :: enum uint {
  TITLED = 0,
  CLOSABLE = 1,
  MINIATURIZABLE = 2,
  RESIZABLE = 3,
  TEXTUREDBACKGROUND = 8,
  UNIFIEDTITLEANDTOOLBAR = 12,
  FULLSCREEN = 14,
  FULLSIZECONTENTVIEW = 15,
  UTILITYWINDOW = 4,
  DOCMODALWINDOW = 6,
  NONACTIVATINGPANEL = 7,
  HUDWINDOW = 13,
}
WindowStyleMask :: distinct bit_set[WindowStyleFlag; uint]

BackingStoreType :: enum uint {
  RETAINED = 0,
  NONRETAINED = 1,
  BUFFERED = 2,
}

@(objc_type=Window, objc_name="alloc", objc_is_class_method=true)
Window_alloc :: proc "c" () -> ^Window {
  return intrinsics.objc_send(^Window, Window, "alloc")
}

@(objc_type=Window, objc_name="initWithContentRect")
Window_initWithContentRect :: proc (self: ^Window, contentRect: Rect, styleMask: WindowStyleMask, backing: BackingStoreType, deferred: bool) -> ^Window {
  return intrinsics.objc_send(^Window, self, "initWithContentRect:styleMask:backing:defer:", contentRect, styleMask, backing, deferred)
}

@(objc_type=Window, objc_name="setTitle")
Window_setTitle :: proc "c" (self: ^Window, title: ^String) {
  intrinsics.objc_send(nil, self, "setTitle:", title)
}

@(objc_type=Window, objc_name="makeKeyAndOrderFront")
Window_makeKeyAndOrderFront :: proc "c" (self: ^Window, key: ^Object) {
  intrinsics.objc_send(nil, self, "makeKeyAndOrderFront:", key)
}
