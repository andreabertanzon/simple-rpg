const c = @cImport({
    @cInclude("glad.h");
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});
const Render = @import("render/render.zig").Render;

pub const Global = struct {
  render: Render = undefined,

  pub fn init() Global {
    var renderer = Render.render_init();
    return Global {
        .render = renderer
    };
  }  
};
