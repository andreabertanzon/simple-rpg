const std = @import("std");

const IO_READ_CHUNK_SIZE = 2097152;

/// Reads a file and loads it into a `File` struct
/// uses an allocator internally and manages the allocator.
pub fn io_file_read() File {
    // Create a File struct
    var result = File{};

    //  Get an allocator
    var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gp.deinit();
    const allocator = gp.allocator();

    // Get the path
    var path_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    //TODO: Check why this seems to give an error.
    const path: std.os.RealPathError![]u8 = std.fs.realpath("/home/andrea/Programming/zig/simple-rpg/Readme.md", &path_buffer);

    //TODO: Read about switch cases on errors
    switch (path) {}
    // Open the file
    const file = try std.fs.openFileAbsolute(path, .{ .mode = .read_only });

    defer file.close();

    // Read the contents
    // const buffer_size = 4096;
    const file_buffer: []u8 = try file.readToEndAlloc(allocator, std.math.maxInt(usize));

    defer allocator.free(file_buffer);

    // Split by "\n" and iterate through the resulting slices of "const []u8"

    // var count: usize = 0;
    // while (count <= file_buffer.len) |line| : (count += 1) {
    //     std.log.info("{d:>2}: {s}", .{ count, line });
    // }
    // var testati = [_]u8{'a'} ** 4096;
    // for (file_buffer, 0..) |line, i| {
    //     testati[i] = line;
    // }
    // std.debug.print("\n{c}\n", .{testati[0]});
    // std.debug.print("{c}\n", .{testati[1]});
    // std.debug.print("{c}\n", .{testati[2]});
    // std.debug.print("{c}\n", .{testati[3]});

    result.data = file_buffer;
    result.is_valid = true;
    result.size = @sizeOf(file_buffer);
    return result;
}

pub const File = struct {
    data: []const u8 = undefined,
    is_valid: bool = false,
    size: u32 = 0,
};
