const std = @import("std");
const c = @cImport({
    @cInclude("glad.h");
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
    @cInclude("linmath.h");
});
const print = std.debug.print;
const g = @import("engine/global.zig");
const io = @import("engine/io/io.zig");
const Global = g.Global;

const ESC_KEY = 41;

pub fn main() !void {

    _ = io.io_file_read();
    
    var global = Global.init();

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