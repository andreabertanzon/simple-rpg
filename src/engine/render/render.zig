const c = @cImport({
    @cInclude("glad.h");
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});

pub fn Render() type {
    return struct {
        const Self = @This();

        window: *c.SDL_Window = undefined,
        width: f32 = 0,
        height: f32 = 0,

        pub fn render_init(width: f32, height: f32) Self {
            return Self{
                .width = width,
                .height = height,
            };
            //self.window = render_init_window();

        }
        pub fn render_begin(self: *Self) void {
            self.width += 1;
        }

        pub fn render_end() void {}
        pub fn render_quad() void {}
    };
}