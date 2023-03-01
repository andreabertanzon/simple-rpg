const c = @cImport({
    @cInclude("glad.h");
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});
const render = @import("render/render.zig").Render();

/// Represents the global state in the application
pub fn Global() type {
    return struct {
        const Self = @This();
        
        render: render,

        /// initializes a `Global` type
        pub fn init() Self {
            return Self {
                .render = render.render_init(800,600)
            };
        }
    };
} 