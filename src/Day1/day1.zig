const std = @import("std");
const utils = @import("../utils.zig");

pub fn run(allocator: std.mem.Allocator) !void {
    std.debug.print("Running day 1\n", .{});

    const lines: std.ArrayList([]const u8) = try utils.readLinesStreamFromFile(allocator, "src/Day1/data");
    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit();
    }

    var list_a = std.ArrayList(i32).init(allocator);
    defer list_a.deinit();

    var list_b = std.ArrayList(i32).init(allocator);
    defer list_b.deinit();

    for (lines.items) |line| {
        std.debug.print("line: {s}\n", .{line});

        // Get first number
        const firstNumber = try getFirstNumberFromPos(line, 0);
        try list_a.append(firstNumber);

        // Get second number
        var buff: [10]u8 = undefined;
        const numberStr = try std.fmt.bufPrint(&buff, "{}", .{firstNumber});
        const secondNumber = try getFirstNumberFromPos(line, numberStr.len + 3);
        try list_b.append(secondNumber);
    }

    try partOne(&list_a, &list_b);
    try partTwo(&list_a, &list_b);
}

fn partOne(list_a: *const std.ArrayList(i32), list_b: *const std.ArrayList(i32)) !void {
    // Sort lists acending
    try sortList(list_a.*);
    try sortList(list_b.*);

    // Find number distances and calculate the sum
    var sum: u32 = 0;
    for (0..list_a.items.len) |i| {
        const distance: u32 = @abs(list_a.items[i] - list_b.items[i]);
        sum += distance;
    }

    std.debug.print("Sum part1: {d}\n", .{sum});
}

fn partTwo(list_a: *const std.ArrayList(i32), list_b: *const std.ArrayList(i32)) !void {
    var sum: i32 = 0;
    for (list_a.items) |itemA| {
        var mul: i32 = 0;

        for (list_b.items) |itemB| {
            if (itemA == itemB) {
                mul += itemB;
            }
        }

        sum += mul;
    }

    std.debug.print("Sum part2: {d}\n", .{sum});
}

fn getFirstNumberFromPos(line: []const u8, pos: usize) !i32 {
    var index: usize = pos;
    while (index < line.len) : (index += 1) {
        if (std.ascii.isDigit(line[index])) {
            continue;
        }
        break;
    }

    const numbers = line[pos..index];
    return try std.fmt.parseInt(i32, numbers, 10);
}

fn sortList(list: std.ArrayList(i32)) !void {
    std.mem.sort(i32, list.items, {}, std.sort.asc(i32));
}
