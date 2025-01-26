const std = @import("std");
const day1z = @import("Day1/day1.zig");
const day2z = @import("Day2/day2.zig");
const day3z = @import("Day3/day3.zig");
const day4z = @import("Day4/day4.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        _ = gpa.detectLeaks();
        _ = gpa.deinit();
    }

    const Days = enum { day1, day2, day3, day4 };
    const CurrentDay = union(Days) { day1: type, day2: type, day3: type, day4: type };

    const currentDay = CurrentDay{ .day4 = day4z };

    switch (currentDay) {
        .day1 => |val| try val.run(allocator),
        .day2 => |val| try val.run(allocator),
        .day3 => |val| try val.run(allocator),
        .day4 => |val| try val.run(allocator),
    }

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Merry Christmas.\n", .{});
    try bw.flush();
}
