const std = @import("std");
const utils = @import("../utils.zig");

pub fn run(allocator: std.mem.Allocator) !void {
    std.debug.print("Running day 3\n", .{});

    const lines = try utils.readLinesStreamFromFile(allocator, "src/Day3/data_test");
    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit();
    }

    for (lines.items) |line| {
        std.debug.print("line: {s}\n", .{line});
    }
}
