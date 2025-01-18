const std = @import("std");
const utils = @import("../utils.zig");

pub fn run(allocator: std.mem.Allocator) !void {
    std.debug.print("Running day 2\n", .{});

    const lines = try utils.readLinesStreamFromFile(allocator, "src/Day2/data");
    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit();
    }

    var reports = std.ArrayList(std.ArrayList(i16)).init(allocator);
    defer {
        for (reports.items) |value| {
            value.deinit();
        }
        reports.deinit();
    }

    // Extract numbers from line.
    for (lines.items) |line| {
        const numbers = try extractNumbersFromLine(allocator, line);
        try reports.append(numbers);
    }

    try partOne(reports);
    try partTwo(allocator, reports);
}

fn partOne(reports: std.ArrayList(std.ArrayList(i16))) !void {
    var safe_reports: u32 = 0;
    for (reports.items) |report| {
        if (isReportSafe(report.items)) {
            safe_reports += 1;
        }
    }

    std.debug.print("Safe reports: {d}\n", .{safe_reports});
}

fn partTwo(allocator: std.mem.Allocator, reports: std.ArrayList(std.ArrayList(i16))) !void {
    var safe_reports: u32 = 0;
    for (reports.items) |report| {
        if (try isReportSafeWithTolerance(allocator, report)) {
            safe_reports += 1;
        }
    }

    std.debug.print("Safe reports w. tolerance: {d}\n", .{safe_reports});
}

fn extractNumbersFromLine(allocator: std.mem.Allocator, line: []const u8) !std.ArrayList(i16) {
    var numbers = std.ArrayList(i16).init(allocator);

    var digit_start_index: usize = 0;
    for (0..line.len) |i| {
        const value = line[i];

        if (value == ' ' or value == 13 or i == line.len - 1) {
            const end_index: usize = if (std.ascii.isDigit(value) and i == line.len - 1) i + 1 else i;
            try numbers.append(try std.fmt.parseInt(i16, line[digit_start_index..end_index], 10));
            digit_start_index = i + 1;
        }
    }

    return numbers;
}

fn isReportSafe(numbers: []const i16) bool {
    var declination: i8 = 0;
    for (0..numbers.len) |i| {
        if (i == 0) {
            continue;
        }

        const number = numbers[i];
        const prev_number = numbers[i - 1];

        // Unsafe if numbers are equal.
        if (number == prev_number) {
            return false;
        }

        // Unsafe if declination changes.
        if (declination == 0) {
            declination = if (number > prev_number) 1 else -1;
        } else if (declination == 1 and number < prev_number) {
            return false;
        } else if (declination == -1 and number > prev_number) {
            return false;
        }

        // Unsafe if levels increase/decrease with more than 3.
        const diff: u16 = @abs(prev_number - number);
        if (diff > 3) {
            return false;
        }
    }

    return true;
}

fn isReportSafeWithTolerance(allocator: std.mem.Allocator, numbers: std.ArrayList(i16)) !bool {
    for (0..numbers.items.len) |i| {
        var number_selection = std.ArrayList(i16).init(allocator);
        defer number_selection.deinit();

        for (0..numbers.items.len) |j| {
            if (i == j) {
                continue;
            }
            try number_selection.append(numbers.items[j]);
        }

        if (isReportSafe(number_selection.items)) {
            return true;
        }
    }

    return false;
}
