const c = @cImport({
    @cInclude("glad.h");
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});

pub const Render = struct {
    window: *c.SDL_Window = undefined,
    width: f32 = 0,
    height: f32 = 0,

    pub fn render_init() Render {
        return Render{
            .width = 800,
            .height = 600,
        };
    }

    pub fn render_begin(self: *Render) void {
        self.width += 1;
    }

    pub fn render_end(window: *c.SDL_Window) void {
        c.SDL_GL_SwapWindow(window);
    }
    pub fn render_quad() void {}
};
