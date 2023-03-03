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

pub const Pippo = struct {
    age: i32 = undefined,
    duck: Paperino = undefined,

    pub fn init(self: *Pippo) void {
        self.age = 0;
        self.duck = Paperino.init();
    }
};

pub const Paperino = struct {
    height: f32 = 0.2,
    testa: i32 = 1,
    body: i32 = undefined,

    pub fn init() Paperino {
        return Paperino{
            .height = 1,
            .testa = 10,
            .body = 10,
        };
    }
};
