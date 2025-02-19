#load "renderer.jai";
#load "../game/main.jai";

#import "Maths";
#import "X11";

glx :: #system_library "libGL";
glXGetVisualFromFBConfig :: (display: *Display, config: GLXFBConfig) -> *XVisualInfo #foreign glx;

platform_display: *Display;
platform_screen: s32;
platform_window: Window;
platform_width: int;
platform_height: int;
#if RENDER_API == .OPENGL opengl_fbconfig: GLXFBConfig;

main :: () {
	platform_display = XOpenDisplay(null);
	defer XCloseDisplay(platform_display);
	platform_screen = XDefaultScreen(platform_display);
	root := XRootWindow(platform_display, platform_screen);

	screen_width := XDisplayWidth(platform_display, platform_screen);
	screen_height := XDisplayHeight(platform_display, platform_screen);

	event_mask: u32 = StructureNotifyMask;

	#if RENDER_API == .OPENGL {
		fbattribs :: s32.[
			GLX_RENDER_TYPE, GLX_RGBA_BIT,
			GLX_DRAWABLE_TYPE, GLX_WINDOW_BIT,
			GLX_DOUBLEBUFFER, xx true,
			GLX_RED_SIZE, 8,
			GLX_GREEN_SIZE, 8,
			GLX_BLUE_SIZE, 8,
			0,
		];
		fbcount: s32 = ---;
		fbconfigs := glXChooseFBConfig(platform_display, platform_screen, fbattribs.data, *fbcount);
		opengl_fbconfig = fbconfigs[0];

		vi := glXGetVisualFromFBConfig(platform_display, opengl_fbconfig);

		attribs: XSetWindowAttributes = ---;
		attribs.event_mask = event_mask;
		attribs.colormap = XCreateColormap(platform_display, root, vi.visual, AllocNone);
		platform_window = XCreateWindow(platform_display, root, screen_width / 4, screen_height / 4, cast(u32) screen_width / 2, cast(u32) screen_height / 2, 0, vi.depth, InputOutput, vi.visual, CWEventMask | CWColormap, *attribs);
	} else {
		attribs: XSetWindowAttributes = ---;
		attribs.event_mask = event_mask;
		platform_window = XCreateWindow(platform_display, root, screen_width / 4, screen_height / 4, cast(u32) screen_width / 2, cast(u32) screen_height / 2, 0, CopyFromParent, InputOutput, cast(*Visual) CopyFromParent, CWEventMask, *attribs);
	}
	XMapWindow(platform_display, platform_window);

	wm_close_atom := XInternAtom(platform_display, "WM_DELETE_WINDOW", xx false);
	XSetWMProtocols(platform_display, platform_window, *wm_close_atom, 1);

	renderer.init();

	while main_loop := true {
		while XPending(platform_display) > 0 {
			event: XEvent = ---;
			XNextEvent(platform_display, *event);
			if event.type == {
				case ConfigureNotify;
					if event.xconfigure.width != platform_width || event.xconfigure.height != platform_height {
						platform_width = event.xconfigure.width;
						platform_height = event.xconfigure.height;

						renderer.resize();
					}
				case ClientMessage;
					if cast(Atom) event.xclient.data.l[0] == wm_close_atom {
						renderer.deinit();
						break main_loop;
					}
				case DestroyNotify;
					renderer.deinit();
					break main_loop;
			}
		}

		game_renderer: Game_Renderer;
		game_renderer.procs = renderer.game_procs;
		game_update_and_render(*game_renderer);

		renderer.present();
	}
}
