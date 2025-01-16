const std = @import("std");
const utils = @import("../utils.zig");

pub fn run() !void {
    std.debug.print("Running day 2\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        _ = gpa.detectLeaks();
        _ = gpa.deinit();
    }

    const lines = try utils.readLinesStreamFromFile(allocator, "src/Day2/data_test");
    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit();
    }
}
