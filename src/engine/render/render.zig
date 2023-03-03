const c = @cImport({
    @cInclude("glad.h");
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
    @cInclude("linmath.h");
});

const std = @import("std");
const print = std.debug.print;

pub const Render = struct {
    window: *c.SDL_Window = undefined,
    width: f32 = 0,
    height: f32 = 0,
    state: Render_State_Internal = Render_State_Internal {},

    pub fn render_init() Render {
        var state = Render_State_Internal {};
        var window = state.render_init_window(800,600);
        var render = Render{
            .width = 800,
            .height = 600,
            .window = window,
            .state = state
        };
        render.state.render_init_quad(&state.vao_quad, &state.vbo_quad, &state.ebo_quad);
        return render;
    }

    pub fn render_begin(_: *Render) void {
        c.glClearColor(0.08, 0.1, 0.1, 1);
        c.glClear(c.GL_COLOR_BUFFER_BIT);
    }

    pub fn render_end(_:*Render, window: *c.SDL_Window) void {
        c.SDL_GL_SwapWindow(window);
    }
    pub fn render_quad(self: *Render, _: c.vec2, _: c.vec2, _: c.vec4) void {
        c.glBindVertexArray(self.state.vao_quad);

        c.glPolygonMode(c.GL_FRONT_AND_BACK, c.GL_LINE);
        c.glDrawElements(c.GL_TRIANGLES, 6, c.GL_UNSIGNED_INT, null);

        c.glBindVertexArray(0);
    }
};

pub const Render_State_Internal = struct {
    vao_quad: u32 = 1,
    vbo_quad: u32 = 1,
    ebo_quad: u32 = 1,

    pub fn render_init_window(_: *Render_State_Internal, width: i32, height: i32) *c.SDL_Window {
        _ = c.SDL_GL_SetAttribute(c.SDL_GL_CONTEXT_PROFILE_MASK, c.SDL_GL_CONTEXT_PROFILE_CORE);
        _ = c.SDL_GL_SetAttribute(c.SDL_GL_CONTEXT_MAJOR_VERSION, 3);
        _ = c.SDL_GL_SetAttribute(c.SDL_GL_CONTEXT_MINOR_VERSION, 3);

        // if (c.SDL_Init(c.SDL_INIT_VIDEO) < 0) {
        //     print("could not init sdl \n", .{});
        //     return;
        // }
        var window = c.SDL_CreateWindow("Game", c
        .SDL_WINDOWPOS_CENTERED, 
        c.SDL_WINDOWPOS_CENTERED, 
        width, 
        height, 
        c.SDL_WINDOW_OPENGL);

        _ = c.SDL_GL_CreateContext(window);
        return window.?;
    }

    pub fn render_init_quad(_:*Render_State_Internal, vao: *u32, vbo: *u32, ebo: *u32) void {
        var vertices = [_]f32{ 
            0.5, 0.5, 0, 0, 0,
            0.5, -0.5, 0, 0, 1,
            -0.5, -0.5, 0, 1, 1,
            -0.5, 0.5, 0, 1, 0,
        };
        var indices = [_]u32 {
            0,1,3,
            1,2,3
        };
        var casted = @intCast(c_uint, vao.*);
        
        c.glGenVertexArrays(1, vao);
        c.glGenBuffers(1,vbo);
        c.glGenBuffers(1,ebo);
        c.glBindVertexArray(casted);
        var vboCasted = @intCast(c_uint, vbo.*);
        c.glBindBuffer(c.GL_ARRAY_BUFFER, vboCasted);
        c.glBufferData(c.GL_ARRAY_BUFFER, @sizeOf(@TypeOf(vertices)), &vertices, c.GL_STATIC_DRAW);

        var eboCasted = @intCast(c_uint, ebo.*);
        c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, eboCasted);
        c.glBufferData(c.GL_ELEMENT_ARRAY_BUFFER, @sizeOf(@TypeOf(indices)), &indices,c.GL_STATIC_DRAW);

        //xyz
        c.glVertexAttribPointer(0,3,c.GL_FLOAT,c.GL_FALSE, 5 * @sizeOf(f32), null);
        c.glEnableVertexAttribArray(0);

        //uv
        c.glVertexAttribPointer(1,2,c.GL_FLOAT, c.GL_FALSE, 5 * @sizeOf(f32), @intToPtr(*anyopaque,3 * @sizeOf(f32)));
        c.glEnableVertexAttribArray(1);

        c.glBindVertexArray(0);
    }
};
