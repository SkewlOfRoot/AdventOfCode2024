const std = @import("std");
const day1z = @import("Day1/day1.zig");
const day2z = @import("Day2/day2.zig");

pub fn main() !void {
    const Days = enum { day1, day2, day3 };
    const CurrentDay = union(Days) { day1: type, day2: type, day3 };

    const currentDay = CurrentDay{ .day2 = day2z };

    switch (currentDay) {
        .day1 => |val| try val.run(),
        .day2 => |val| try val.run(),
        .day3 => {},
    }

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Merry Christmas.\n", .{});
    try bw.flush();
}
