const std = @import("std");
const utils = @import("../utils.zig");

pub fn run(allocator: std.mem.Allocator) !void {
    std.debug.print("Running day 3\n", .{});

    const content = try utils.readFileContent(allocator, "src/Day3/data");
    defer allocator.free(content);

    try partOne(allocator, content);
    try partTwo(allocator, content);
}

fn partOne(allocator: std.mem.Allocator, content: []const u8) !void {
    const list = try findMuls(allocator, content);
    defer {
        for (list.items) |item| {
            allocator.free(item.mul);
        }
        list.deinit();
    }

    var sum: u32 = 0;
    for (list.items) |item| {
        const product = try multiply(allocator, item.mul);
        sum += product;
    }

    std.debug.print("Sum part 1: {d}\n", .{sum});
}

fn partTwo(allocator: std.mem.Allocator, content: []const u8) !void {
    const list = try findMuls(allocator, content);
    defer {
        for (list.items) |item| {
            allocator.free(item.mul);
        }
        list.deinit();
    }

    var sum: u32 = 0;
    for (list.items) |item| {
        if (item.improve) {
            const product = try multiply(allocator, item.mul);
            sum += product;
        }
    }

    std.debug.print("Sum part 2: {d}\n", .{sum});
}

/// Scans through the input content and extracts any valid 'mul(n,n)'. Also detects any conditional 'do' and 'don't' statements which will make output more precise.
fn findMuls(allocator: std.mem.Allocator, content: []const u8) !std.ArrayList(Mul) {
    var list = std.ArrayList(Mul).init(allocator);

    const pattern = "mul(";
    const do_pattern = "do()";
    const dont_pattern = "don't()";
    var state: UncorruptedState = UncorruptedState.do;
    var i: usize = 0;

    while (i < content.len) {
        const index = std.mem.indexOf(u8, content[i..], pattern);
        const index_do = std.mem.indexOf(u8, content[i..], do_pattern);
        const index_dont = std.mem.indexOf(u8, content[i..], dont_pattern);

        if (index) |found_index| {
            // Set state = 'do' if the next do() is before 'mul' and the next don't() is either non-existant or after 'mul'.
            if (index_do != null and index_do.? < found_index) {
                if (index_dont == null or index_dont.? > found_index or index_dont.? < index_do.?) {
                    state = UncorruptedState.do;
                }
            }

            // Set state = 'dont' if the next don't() is before 'mul' and the next do() is either non-existant or after 'mul'.
            if (index_dont != null and index_dont.? < found_index) {
                if (index_do == null or index_do.? > found_index or index_do.? < index_dont.?) {
                    state = UncorruptedState.dont;
                }
            }

            // Find the index where the digits in the 'mul' should begin.
            const digit_search_index = i + found_index + pattern.len;
            for (digit_search_index..content.len) |j| {
                const c = content[j];
                if (std.ascii.isDigit(c) or c == ',') {
                    continue;
                }
                // If we find a ')' at this point we have a complete 'mul(n,n)'. Copy the slice and add it to the list.
                if (c == ')') {
                    const copy = try allocator.dupe(u8, content[i + found_index .. j + 1]);
                    try list.append(Mul{ .mul = copy, .improve = (state == UncorruptedState.do) });
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

    return list;
}

// Extracts the numbers from the 'mul(n,n)' and multiplies them.
fn multiply(allocator: std.mem.Allocator, mul: []const u8) !u32 {
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

const UncorruptedState = enum { none, do, dont };

const Mul = struct { mul: []const u8, improve: bool };
