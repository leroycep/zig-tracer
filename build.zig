const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.option(std.builtin.Mode, "mode", "") orelse .Debug;

    const mod = b.addModule("tracer", .{ .root_source_file = b.path("src/mod.zig") });

    addTest(b, target, mode, mod, 0);
    addTest(b, target, mode, mod, 1);
    addTest(b, target, mode, mod, 2);
    addTest(b, target, mode, mod, 3);

    const test_step = b.step("test", "dummy test step to pass CI checks");
    _ = test_step;
}

fn addTest(b: *std.Build, target: std.Build.ResolvedTarget, mode: std.builtin.OptimizeMode, mod: *std.Build.Module, comptime backend: u8) void {
    const options = b.addOptions();
    const parent_dir = std.fs.path.dirname(std.fs.path.dirname(@src().file) orelse "") orelse "";
    options.addOption(usize, "src_file_trimlen", parent_dir.len);
    options.addOption(u8, "backend", backend);

    const exe = b.addExecutable(.{
        .name = "test" ++ std.fmt.comptimePrint("{d}", .{backend}),
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = mode,
    });
    exe.linkLibC();
    exe.root_module.addImport("tracer", mod);
    exe.root_module.addOptions("build_options", options);
    b.installArtifact(exe);
}
