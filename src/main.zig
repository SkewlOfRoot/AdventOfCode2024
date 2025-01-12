const std = @import("std");
const day1z = @import("Days/day1.zig");

pub fn main() !void {
    const Days = enum { day1, day2, day3 };
    const CurrentDay = union(Days) { day1: type, day2, day3 };

    const currentDay = CurrentDay{ .day1 = day1z };

    switch (currentDay) {
        .day1 => |val| try val.run(),
        .day2 => {},
        .day3 => {},
    }

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Merry Christmas.\n", .{});
    try bw.flush();
}
