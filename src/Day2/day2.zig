const std = @import("std");
const utils = @import("../utils.zig");

pub fn run(allocator: std.mem.Allocator) !void {
    std.debug.print("Running day 2\n", .{});

    const lines = try utils.readLinesStreamFromFile(allocator, "src/Day2/data_test");
    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit();
    }
}
