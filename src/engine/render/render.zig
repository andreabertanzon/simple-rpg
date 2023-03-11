const c = @cImport({
    @cInclude("glad.h");
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
    @cInclude("linmath.h");
});

const std = @import("std");
const io = @import("../io/io.zig");

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

    pub fn render_quad(self: *Render, pos: c.vec2, size: c.vec2, color: c.vec4) void {
        // c.glBindVertexArray(self.state.vao_quad);

        // c.glPolygonMode(c.GL_FRONT_AND_BACK, c.GL_LINE);
        // c.glDrawElements(c.GL_TRIANGLES, 6, c.GL_UNSIGNED_INT, null);

        // c.glBindVertexArray(0);
        c.glUseProgram(self.state.shader_default);

        var model: c.mat4x4 = undefined;
        c.mat4x4_identity(model);

        c.mat4x4_translate(model, pos[0], pos[1], 0);
        c.mat4x4_scale_aniso(model, model, size[0], size[1], 1);

        c.glUniformMatrix4fv(c.glGetUniformLocation(self.state.shader_default, "model"), 1, c.GL_FALSE, &model[0][0]);
        c.glUniform4fv(c.glGetUniformLocation(self.state.shader_default, "color"), 1, color);

        c.glBindVertexArray(self.state.vao_quad);

        c.glBindTexture(c.GL_TEXTURE_2D, self.state.texture_color);
        c.glDrawElements(c.GL_TRIANGLES, 6, c.GL_UNSIGNED_INT, null);

        c.glBindVertexArray(0);
    }

    pub fn render_init_shaders(self: *Render) void {
        self.shader_default = self.render_shader_create("./shaders/default.vert", "./shaders/default.frag");
        c.mat4x4_ortho(self.state.projection, 0, self.width, 0, self.height, -2, -2);

        c.glUseProgram(self.state.shader_default);
        c.glUniformMatrix4fv(c.glGenUniformLocation(self.state.shader_default, "projection"), 1, c.GL_FALSE, &self.state.projection[0][0]);
    }

    pub fn render_init_color_texture(texture: *u32) void {
        c.glGenTextures(1, texture);
        c.glBindTexture(c.GL_TEXTURE_2D, *texture);
        var solid_white = [4]u8{ 255, 255, 255, 255 };
        c.glTexImage2D(c.GL_TEXTURE_2D, 0, c.GL_RGBA, 1, 1, 0, c.GL_RGBA, c.GL_UNSIGNED_BYTE, solid_white);

        c.glBindTexture(c.GL_TEXTURE_2D, 0);
    }
};

pub const Render_State_Internal = struct {
    vao_quad: u32 = 0,
    vbo_quad: u32 = 0,
    ebo_quad: u32 = 0,
    shader_default: u32 = 0,
    texture_color: u32 = 0,
    projection: c.mat4x4 = undefined,

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

    pub fn render_shader_create(_: *Render_State_Internal, path_vert: []const u8, path_frag: []const u8) u32 {
        var success = false;
        var log: [512]u8 = undefined;

        var file_vertex: io.File = io.io_file_read(path_vert);
        if (!file_vertex.is_valid) {
            print("path: {c}\n", .{path_vert});
            @panic("Error rendering shader\n");
        }

        // defines a shader object
        var shader_vertex = c.glCreateShader(c.GL_VERTEX_SHADER);
        // attaches the GLSL shader file to the shader object
        c.glShaderSource(shader_vertex, 1, &file_vertex, null);
        c.glCompileShader(shader_vertex);
        // checks if the shader compilation was successful.
        c.glGetShaderiv(shader_vertex, c.GL_COMPILE_STATUS, &success);
        if (!success) {
            c.glGetShaderInfoLog(shader_vertex, 512, null, log);
            print("shader log: {c}\n", .{log});
            @panic("Error compiling vertex shader");
        }

        const file_fragment: io.File = io.io_file_read(path_frag);
        if (!file_fragment.is_valid) {
            print("Error reading shader:{c}", .{path_frag});
            @panic("Error in reading shader fragment");
        }

        var shader_fragment = c.glCreateShader(c.GL_FRAGMENT_SHADER);
        c.glShaderSource(shader_fragment);
        c.glCompileShader(shader_fragment);
        c.glGetShaderiv(shader_fragment, c.GL_COMPILE_STATUS, &success);
        if (!success) {
            c.glShaderInfoLog(shader_fragment, 512, null, log);
            print("Error compiling fragment shader:{c}", .{log});
            @panic("Error compiling fragment shader");
        }

        // multiple shaders combined create a shader program that is a final linked
        // version of those multiple shaders.
        var shader: u32 = c.glCreateProgram();
        // attach the previously defined shaders to the program and link them.
        c.glAttachShader(shader, shader_vertex);
        c.glAttachShader(shader, shader_fragment);
        c.glLinkProgram(shader);
        c.glGetProgramiv(shader, c.GL_LINK_STATUS, &success);
        if (!success) {
            c.glShaderInfoLog(shader, 512, null, log);
            print("Linking shader:{c}", .{log});
            @panic("error linking shader");
        }

        return shader;
    }
};
