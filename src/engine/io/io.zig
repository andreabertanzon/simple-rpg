const std = @import("std");

const IO_READ_CHUNK_SIZE = 2097152;

/// Reads a file and loads it into a `File` struct
/// uses an allocator internally and manages the allocator.
pub fn io_file_read(input_path:[]const u8, allocator:std.mem.Allocator) !File {
    // Create a File struct
    var result = File{};

    // Get the path
    var path_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const path: []u8 = std.fs.realpath(input_path, &path_buffer) catch |e| {
        std.debug.print("IO-ERROR {s}", .{@errorName(e)});
        return e;
    };

    const file = std.fs.openFileAbsolute(path, .{ .mode = .read_only }) catch |e| {
        std.debug.print("IO-ERROR {s}", .{@errorName(e)});
        return e;
    };

    defer file.close();
    result.data = try file.readToEndAlloc(allocator, std.math.maxInt(usize));

    // defer allocator.free(file_buffer);

    result.is_valid = true;
    result.size = @sizeOf(@TypeOf(result.data));
    return result;
}

pub const File = struct {
    data: []u8 = undefined,
    is_valid: bool = false,
    size: u32 = 0,
};

pub fn io_file_write() void {
    
}