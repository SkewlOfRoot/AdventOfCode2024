const std = @import("std");
const utils = @import("../utils.zig");

pub fn run(allocator: std.mem.Allocator) !void {
    std.debug.print("Running day 3\n", .{});

    const content = try utils.readFileContent(allocator, "src/Day3/data_test2");
    defer allocator.free(content);

    std.debug.print("content: {s}\n", .{content});

    try partOne(allocator, content);
    try partTwo(allocator, content);
}

fn partOne(allocator: std.mem.Allocator, content: []const u8) !void {
    var list = std.ArrayList([]const u8).init(allocator);
    defer {
        for (list.items) |item| {
            allocator.free(item);
        }
        list.deinit();
    }

    const pattern = "mul(";
    var i: usize = 0;
    while (i < content.len) {
        const index = std.mem.indexOf(u8, content[i..], pattern);

        if (index) |found_index| {
            const digit_search_index = i + found_index + pattern.len;
            for (digit_search_index..content.len) |j| {
                const c = content[j];
                if (std.ascii.isDigit(c) or c == ',') {
                    continue;
                }
                if (c == ')') {
                    const copy = try allocator.dupe(u8, content[i + found_index .. j + 1]);
                    try list.append(copy);
                    i += found_index + copy.len;
                    break;
                }
                i += found_index + pattern.len;
                break;
            }
        } else {
            break;
        }
    }

    var sum: u32 = 0;
    for (list.items) |item| {
        const product = try multiply(allocator, item);
        sum += product;
    }

    std.debug.print("Sum part 1: {d}\n", .{sum});
}

fn partTwo(allocator: std.mem.Allocator, content: []const u8) !void {
    var list = std.ArrayList([]const u8).init(allocator);
    defer {
        for (list.items) |item| {
            allocator.free(item);
        }
        list.deinit();
    }

    const pattern = "mul(";
    var i: usize = 0;
    while (i < content.len) {
        //std.debug.print("i: {d}\n", .{i});
        const index = std.mem.indexOf(u8, content[i..], pattern);

        if (index) |found_index| {
            const digit_search_index = i + found_index + pattern.len;
            //std.debug.print("found index: {d}\n", .{found_index});
            for (digit_search_index..content.len) |j| {
                const c = content[j];
                //std.debug.print("c: {c}\n", .{c});
                if (std.ascii.isDigit(c) or c == ',') {
                    //std.debug.print("hey\n", .{});
                    continue;
                }
                if (c == ')') {
                    //std.debug.print("hey2\n", .{});
                    const copy = try allocator.dupe(u8, content[i + found_index .. j + 1]);
                    //std.debug.print("copy: {s}\n", .{copy});
                    try list.append(copy);
                    i += found_index + copy.len;
                    //std.debug.print("i calc: {d}\n", .{i});
                    break;
                }
                i += found_index + pattern.len;
                break;
            }
        } else {
            break;
        }
    }

    var sum: u32 = 0;
    std.debug.print("Found items:\n", .{});
    for (list.items) |item| {
        std.debug.print("{s}\n", .{item});
        const product = try multiply(allocator, item);
        sum += product;
    }

    std.debug.print("Sum: {d}\n", .{sum});
}

fn multiply(allocator: std.mem.Allocator, mul: []const u8) !u32 {
    //std.debug.print("mul: {s}\n", .{mul});
    const part1 = try utils.stringReplace(allocator, mul, "mul(", "");
    defer allocator.free(part1);
    const part2 = try utils.stringReplace(allocator, part1, ")", "");
    defer allocator.free(part2);

    var iterator = std.mem.split(u8, part2, ",");

    const num1: u32 = try std.fmt.parseInt(u32, iterator.next().?, 10);
    const num2: u32 = try std.fmt.parseInt(u32, iterator.next().?, 10);

    const product = num1 * num2;
    return product;
}
