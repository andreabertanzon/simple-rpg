const std = @import("std");
const c = @cImport({
    @cInclude("glad.h");
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
    @cInclude("linmath.h");
});
const print = std.debug.print;
const g = @import("engine/global.zig");
const Global = g.Global;

const ESC_KEY = 41;

pub fn main() !void {
    var global = Global.init();
    
    if (c.gladLoadGLLoader(@as(c.GLADloadproc, c.SDL_GL_GetProcAddress)) < 1) {
        print("ERROR:", .{});
        return;
    }
    mainloop: while (true) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    print("closing", .{});
                    break :mainloop;
                },
                c.SDL_KEYDOWN => switch (event.key.keysym.scancode) {
                    ESC_KEY => break :mainloop,
                    else => print("{}", .{event.key.keysym.scancode}),
                },
                else => {},
            }
        }
        global.render.render_begin();

        global.render.render_quad(
            c.vec2{global.render.width * 0.5, global.render.height * 0.5},
            c.vec2{50,50},
            c.vec4{1,1,1,1}
        );

        global.render.render_end(global.render.window);
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
