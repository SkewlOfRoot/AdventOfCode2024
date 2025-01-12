const std = @import("std");

pub fn readLinesStreamFromFile(fileName: []const u8) !std.ArrayList([]const u8) {
    const allocator = std.heap.page_allocator;

    // Open file.
    const file = try std.fs.cwd().openFile(fileName, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    var lines: std.ArrayList([]const u8) = std.ArrayList([]const u8).init(allocator);

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        // Appending line directly will just append a pointer to the buffer. So if the slice is not copied the ArrayList will contain the same item again and again.
        const line_copy = try allocator.dupe(u8, line);
        try lines.append(line_copy);
    }

    return lines;
}
