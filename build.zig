const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "Asunder",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .single_threaded = true,
    });
    // exe.subsystem = .Windows;
    exe.entry = .{ .symbol_name = "WinMainCRTStartup" };
    b.installArtifact(exe);

    const run_step = b.addRunArtifact(exe);
    b.step("run", "play the game").dependOn(&run_step.step);
}
