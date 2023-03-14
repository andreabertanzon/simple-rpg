const std = @import("std");
const zmath = @import("libs/zmath/build.zig");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const cflags = [_][]const u8{};
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    var glad = b.addSharedLibrary(.{
        .name = "glad",
        .target = target,
        .optimize = optimize,
    });

    glad.addCSourceFile("glad/src/glad.c", &cflags);
    const exe = b.addExecutable(.{
        .name = "simple-rpg",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    glad.linkLibC();

    const sdl_path = "/usr/";
    exe.addIncludePath(sdl_path ++ "include/SDL2");
    exe.addLibraryPath(sdl_path ++ "lib/");
    exe.addIncludePath(sdl_path ++ "");
    //b.installBinFile(sdl_path ++ "lib/x64/SDL2.lib", "SDL2.lib");
    exe.linkSystemLibrary("SDL2");
    exe.linkSystemLibrary("SDL2_image");
    exe.addIncludePath("glad/src/glad");
    exe.addIncludePath("linmath/");
    //b.installBinFile(sdl_path ++ "lib/x64/SDL2.lib", "SDL2.lib");
    exe.linkSystemLibrary("SDL2");
    exe.linkSystemLibrary("SDL2_image");
    exe.linkLibC();

    exe.linkLibrary(glad);

    const zmath_pkg = zmath.Package.build(b, .{});

    exe.addModule("zmath", zmath_pkg.zmath);

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing.
    const exe_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
