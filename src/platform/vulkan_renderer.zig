const core = @import("../modules/core.zig");
const platform = @import("root").platform;

var v: core.FnsToFnPtrs(struct {
    const vulkan = @import("../modules/vulkan.zig");
    pub usingnamespace vulkan;
    pub usingnamespace vulkan.exported;
    pub usingnamespace vulkan.global;
}) = undefined;

pub fn init() void {
    if (core.os_tag == .windows) {
        const w = @import("root").w;
        const vulkan_dll = w.LoadLibraryW(&core.asciiToUtf16LeStringLiteral("vulkan-1")).?;
        inline for (@typeInfo(v.exported).@"struct".decls) |decl| {
            if (@typeInfo(@TypeOf(@field(v.exported, decl.name))) == .@"fn") {
                @field(v, decl.name) = @ptrCast(w.GetProcAddress(vulkan_dll, decl.name));
            }
        }
    }
}

pub fn deinit() void {}

pub fn resize() void {}

pub fn present() void {}
