const std = @import("std");

const IO_READ_CHUNK_SIZE = 2097152;

/// Reads a file and loads it into a `File` struct
/// uses an allocator internally and manages the allocator.
pub fn io_file_read() !File {
    // Create a File struct
    var result = File{};

    //  Get an allocator
    var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gp.deinit();
    const allocator = gp.allocator();

    // Get the path
    var path_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const path: []u8 = std.fs.realpath("/home/andrea/Programming/zig/simple-rpg/README.md", &path_buffer) catch |e| {
        std.debug.print("IO-ERROR {s}", .{@errorName(e)});
    };

    const file = std.fs.openFileAbsolute(path, .{ .mode = .read_only }) catch |e| {
        std.debug.print("IO-ERROR {s}", .{@errorName(e)});
        return e;
    };

    defer file.close();
    const file_buffer: []u8 = try file.readToEndAlloc(allocator, std.math.maxInt(usize));

    defer allocator.free(file_buffer);

    result.data = file_buffer;
    result.is_valid = true;
    result.size = @sizeOf(@TypeOf(file_buffer));
    return result;
}

pub const File = struct {
    data: []const u8 = undefined,
    is_valid: bool = false,
    size: u32 = 0,
};