const std = @import("std");
const File = std.fs.File;

/// Reads the content from a file.
pub fn readFileContent(allocator: std.mem.Allocator, fileName: []const u8) ![]const u8 {
    // Open file.
    const file = try std.fs.cwd().openFile(fileName, File.OpenFlags{ .mode = File.OpenMode.read_only });
    defer file.close();

    const stat = try file.stat();
    const buffer = try file.readToEndAlloc(allocator, stat.size);
    return buffer;
}

/// Reads the content from a file and splts at line breaks to return a 'std.ArrayList([]const u8)' of lines.
pub fn readFileContentAsLines(allocator: std.mem.Allocator, fileName: []const u8) !std.ArrayList([]const u8) {
    // Open file.
    const buffer = try readFileContent(allocator, fileName);
    defer allocator.free(buffer);

    var lines: std.ArrayList([]const u8) = std.ArrayList([]const u8).init(allocator);

    var iterator = std.mem.splitAny(u8, buffer, "\n");

    while (iterator.next()) |line| {
        const copy = try allocator.dupe(u8, line);
        try lines.append(copy);
    }

    return lines;
}

/// Searches through an input slice for a target slice and replaces any target found with the replacement.
pub fn stringReplace(allocator: std.mem.Allocator, input: []const u8, target: []const u8, replacement: []const u8) ![]u8 {
    if (target.len == 0) {
        return error.InvalidArgument;
    }

    var builder = std.ArrayList(u8).init(allocator);

    var i: usize = 0;
    while (i < input.len) {
        const index = std.mem.indexOf(u8, input[i..], target);

        if (index == null) {
            try builder.appendSlice(input[i..]);
            break;
        }

        if (index) |found_index| {
            try builder.appendSlice(input[i .. i + found_index]);
            try builder.appendSlice(replacement);
            i += found_index + target.len;
        } else {
            try builder.appendSlice(input[i..]);
            break;
        }
    }

    return try builder.toOwnedSlice();
}

test "string replace" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const result = try stringReplace(allocator, "Hello world mello", "world", "bello");
    defer allocator.free(result);

    try std.testing.expectEqualStrings("Hello bello mello", result);
}
