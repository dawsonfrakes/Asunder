const basic = @import("basic/basic.zig");

pub usingnamespace switch (basic.os_tag) {
	.windows => @import("platform/main_windows.zig"),
	else => |tag| @compileLog("OS {s} not supported", .{@tagName(tag)}),
};
