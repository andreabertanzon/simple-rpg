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
    state: Render_State_Internal = Render_State_Internal{},

    pub fn render_init() Render {
        var state = Render_State_Internal{};
        var window = state.render_init_window(800, 600);
        var render = Render{ .width = 800, .height = 600, .window = window, .state = state };
        render.state.render_init_quad();
        return render;
    }

    pub fn render_begin(_: *Render) void {
        c.glClearColor(0.08, 0.1, 0.1, 1);
        c.glClear(c.GL_COLOR_BUFFER_BIT);
    }

    pub fn render_end(_: *Render, window: *c.SDL_Window) void {
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
    vao_quad: u32 = 0,
    vbo_quad: u32 = 0,
    ebo_quad: u32 = 0,

    pub fn render_init_window(_: *Render_State_Internal, width: i32, height: i32) *c.SDL_Window {
        _ = c.SDL_GL_SetAttribute(c.SDL_GL_CONTEXT_PROFILE_MASK, c.SDL_GL_CONTEXT_PROFILE_CORE);
        _ = c.SDL_GL_SetAttribute(c.SDL_GL_CONTEXT_MAJOR_VERSION, 3);
        _ = c.SDL_GL_SetAttribute(c.SDL_GL_CONTEXT_MINOR_VERSION, 3);

        if (c.SDL_Init(c.SDL_INIT_VIDEO) < 0) {
            print("could not init sdl \n", .{});
            // return;
        }
        var window = c.SDL_CreateWindow("Game", c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, width, height, c.SDL_WINDOW_OPENGL);

        var context = c.SDL_GL_CreateContext(window);
        if (c.gladLoadGLLoader(@as(c.GLADloadproc, c.SDL_GL_GetProcAddress)) < 1) {
            print("ERROR:", .{});
        }

        _ = c.SDL_GL_MakeCurrent(window, context);
        print("Vendor:    {s}\n", .{c.glGetString(c.GL_VENDOR)});
        print("Renderer:  {s}\n", .{c.glGetString(c.GL_RENDERER)});
        print("Version:   {s}\n", .{c.glGetString(c.GL_VERSION)});

        return window.?;
    }

    pub fn render_init_quad(self: *Render_State_Internal) void {
        var vertices = [_]f32{
            0.5,  0.5,  0, 0, 0,
            0.5,  -0.5, 0, 0, 1,
            -0.5, -0.5, 0, 1, 1,
            -0.5, 0.5,  0, 1, 0,
        };
        
        var indices = [_]u32{ 0, 1, 3, 1, 2, 3 };
        c.glGenVertexArrays(1, &self.vao_quad);
        c.glGenBuffers(1, &self.vbo_quad); // generates the buffer
        c.glGenBuffers(1, &self.ebo_quad); // generates the buffer

        c.glBindVertexArray(self.vao_quad);

        // bind vbo as a vertex buffer object, marking it as GL_ARRAY_BUFFER
        c.glBindBuffer(c.GL_ARRAY_BUFFER, self.vbo_quad);
        c.glBufferData(c.GL_ARRAY_BUFFER, @sizeOf(@TypeOf(vertices)), &vertices, c.GL_STATIC_DRAW);

        c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, self.ebo_quad);
        //  copies the previously defined vertex data into the buffer's memory

        // first argument is the type of the buffer we want to copy data into: 
            //the vertex buffer object currently bound to the GL_ARRAY_BUFFER target. 
        
        //The second argument specifies the size of the data (in bytes) we want to pass to the buffer; 
            // a simple sizeof of the vertex data suffices. 
        
        //The third parameter is the actual data we want to send.

        //The fourth parameter specifies how we want the graphics card to manage the given data. 
        //This can take 3 forms:

        //1. GL_STREAM_DRAW: the data is set only once and used by the GPU at most a few times.
        //2. GL_STATIC_DRAW: the data is set only once and used many times.
        //3. GL_DYNAMIC_DRAW: the data is changed a lot and used many times.
        c.glBufferData(c.GL_ELEMENT_ARRAY_BUFFER, @sizeOf(@TypeOf(indices)), &indices, c.GL_STATIC_DRAW);
        
        //xyz
        c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 5 * @sizeOf(f32), null);
        c.glEnableVertexAttribArray(0);

        //uv
        c.glVertexAttribPointer(1, 2, c.GL_FLOAT, c.GL_FALSE, 5 * @sizeOf(f32), @intToPtr(*anyopaque, 3 * @sizeOf(f32)));
        c.glEnableVertexAttribArray(1);

        c.glBindVertexArray(0);
    }
};
