const std = @import("std");
const File = std.fs.File;

pub fn readLinesStreamFromFile(allocator: std.mem.Allocator, fileName: []const u8) !std.ArrayList([]const u8) {
    // Open file.
    const file = try std.fs.cwd().openFile(fileName, File.OpenFlags{ .mode = File.OpenMode.read_only });
    defer file.close();

    const stat = try file.stat();
    const buffer = try file.readToEndAlloc(allocator, stat.size);
    defer allocator.free(buffer);

    var lines: std.ArrayList([]const u8) = std.ArrayList([]const u8).init(allocator);

    var bla = std.mem.splitAny(u8, buffer, "\n");

    while (bla.next()) |line| {
        const copy = try allocator.dupe(u8, line);
        try lines.append(copy);
    }

    return lines;
}
