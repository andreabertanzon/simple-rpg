const std = @import("std");
const c = @cImport({
    @cInclude("glad.h");
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});

const ESC_KEY = 41;

pub fn main() !void {
    _ = c.SDL_GL_SetAttribute(c.SDL_GL_CONTEXT_PROFILE_MASK, c.SDL_GL_CONTEXT_PROFILE_CORE);
    _ = c.SDL_GL_SetAttribute(c.SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    _ = c.SDL_GL_SetAttribute(c.SDL_GL_CONTEXT_MINOR_VERSION, 3);

    if (c.SDL_Init(c.SDL_INIT_VIDEO) < 0) {
        std.debug.print("could not init sdl \n", .{});
        return;
    }

    var window = c.SDL_CreateWindow("Game", c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, 800, 600, c.SDL_WINDOW_OPENGL) orelse return;

    // if(!window){
    //     std.debug.print("error opening window\n", .{});
    //     return;
    // }
    _ = c.SDL_GL_CreateContext(window);
    if (c.gladLoadGLLoader(@as(c.GLADloadproc, c.SDL_GL_GetProcAddress)) < 1) {
        std.debug.print("ERROR:", .{});
        return;
    }
    mainloop: while (true) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    std.debug.print("closing", .{});
                    break :mainloop;
                },
                c.SDL_KEYDOWN => switch (event.key.keysym.scancode) {
                    ESC_KEY => break :mainloop,
                    else => std.debug.print("{}", .{event.key.keysym.scancode}),
                },
                else => {},
            }
        }
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
