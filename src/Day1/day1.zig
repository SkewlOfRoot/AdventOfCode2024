const std = @import("std");
const utils = @import("../utils.zig");

pub fn run() !void {
    std.debug.print("Running day 1\n", .{});

    const lines = try utils.readLinesStreamFromFile("src/Day1/data_test");
    defer lines.deinit();

    for (lines.items) |line| {
        std.debug.print("{s}\n", .{line});
    }
}
