const std = @import("std");
const utils = @import("../utils.zig");

pub fn run() !void {
    std.debug.print("Running day 1\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        _ = gpa.detectLeaks();
        _ = gpa.deinit();
    }

    const lines: std.ArrayList([]const u8) = try utils.readLinesStreamFromFile(allocator, "src/Day1/data");
    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit();
    }

    var listA = std.ArrayList(i32).init(allocator);
    defer listA.deinit();

    var listB = std.ArrayList(i32).init(allocator);
    defer listB.deinit();

    for (lines.items) |line| {
        std.debug.print("line: {s}\n", .{line});

        // Get first number
        const firstNumber = try getFirstNumberFromPos(line, 0);
        try listA.append(firstNumber);

        // Get second number
        var buff: [10]u8 = undefined;
        const numberStr = try std.fmt.bufPrint(&buff, "{}", .{firstNumber});
        const secondNumber = try getFirstNumberFromPos(line, numberStr.len + 3);
        try listB.append(secondNumber);
    }

    try partOne(&listA, &listB);
    try partTwo(&listA, &listB);
}

fn partOne(listA: *const std.ArrayList(i32), listB: *const std.ArrayList(i32)) !void {
    // Sort lists acending
    try sortList(listA.*);
    try sortList(listB.*);

    // Find number distances and calculate the sum
    var sum: u32 = 0;
    for (0..listA.items.len) |i| {
        const distance: u32 = @abs(listA.items[i] - listB.items[i]);
        sum += distance;
    }

    std.debug.print("Sum part1: {d}\n", .{sum});
}

fn partTwo(listA: *const std.ArrayList(i32), listB: *const std.ArrayList(i32)) !void {
    var sum: i32 = 0;
    for (listA.items) |itemA| {
        var mul: i32 = 0;

        for (listB.items) |itemB| {
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
