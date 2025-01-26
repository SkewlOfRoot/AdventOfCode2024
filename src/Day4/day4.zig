const std = @import("std");
const utils = @import("../utils.zig");

const pattern_f = "XMAS";

pub fn run(allocator: std.mem.Allocator) !void {
    std.debug.print("Running day 4\n", .{});

    const lines = try utils.readFileContentAsLines(allocator, "src/Day4/data");
    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit();
    }

    var sum: u32 = 0;

    for (lines.items, 0..) |line, i| {
        var j: usize = 0;
        while (j < line.len) : (j += 1) {
            const c = line[j];

            if (c == 'X') {
                sum += try countXmas(allocator, j, i, lines.items);
            }
        }
    }

    std.debug.print("Sum part 1: {d}\n", .{sum});
}

fn countXmas(allocator: std.mem.Allocator, x: usize, y: usize, rows: [][]const u8) !u32 {
    var sum: u32 = 0;

    sum += try scanHorizontally(x, rows[y]);
    sum += try scanVertically(allocator, x, y, rows);
    sum += scanDiagonally(x, y, rows);

    return sum;
}

fn scanHorizontally(x: usize, row: []const u8) !u32 {
    // XXXXXXX
    // 0123456
    var sum: u32 = 0;

    // Should scan left?
    if (x >= 3) {
        var is_match = true;
        for (0..4) |i| {
            if (row[x - i] == pattern_f[i]) {
                continue;
            }
            is_match = false;
            break;
        }
        sum += if (is_match) 1 else 0;
    }

    // Should scan right?
    if (x <= row.len - 4) {
        var is_match = true;
        for (0..4) |i| {
            if (row[x + i] == pattern_f[i]) {
                continue;
            }
            is_match = false;
            break;
        }
        sum += if (is_match) 1 else 0;
    }
    return sum;
}

fn scanVertically(allocator: std.mem.Allocator, x: usize, y: usize, rows: [][]const u8) !u32 {
    var sum: u32 = 0;

    if (y >= 3) {
        const rows_up = rows[y - 3 .. y + 1];
        var ts = try allocator.alloc(u8, 4);
        defer allocator.free(ts);
        ts[0] = rows_up[3][x];
        ts[1] = rows_up[2][x];
        ts[2] = rows_up[1][x];
        ts[3] = rows_up[0][x];
        sum += if (std.mem.eql(u8, ts, pattern_f)) 1 else 0;
    }

    if (y <= rows.len - 4) {
        const rows_down = rows[y .. y + 4];
        var ts = try allocator.alloc(u8, 4);
        defer allocator.free(ts);
        ts[0] = rows_down[0][x];
        ts[1] = rows_down[1][x];
        ts[2] = rows_down[2][x];
        ts[3] = rows_down[3][x];
        sum += if (std.mem.eql(u8, ts, pattern_f)) 1 else 0;
    }
    return sum;
}

fn scanDiagonally(x: usize, y: usize, rows: [][]const u8) u32 {
    var sum: u32 = 0;
    // Scan diagonally up to the left?
    if (x >= 3 and y >= 3) {
        var is_match = true;
        for (0..4) |i| {
            if (rows[y - i][x - i] == pattern_f[i]) {
                continue;
            }
            is_match = false;
            break;
        }
        sum += if (is_match) 1 else 0;
    }

    // Scan diagonally up to the right?
    if (x <= rows[y].len - 4 and y >= 3) {
        var is_match = true;
        for (0..4) |i| {
            if (rows[y - i][x + i] == pattern_f[i]) {
                continue;
            }
            is_match = false;
            break;
        }
        sum += if (is_match) 1 else 0;
    }

    // Scan diagonally down to the left?
    if (x >= 3 and y <= rows.len - 4) {
        var is_match = true;
        for (0..4) |i| {
            if (rows[y + i][x - i] == pattern_f[i]) {
                continue;
            }
            is_match = false;
            break;
        }
        sum += if (is_match) 1 else 0;
    }

    // Scan diagonally down to the right?
    if (x <= rows[y].len - 4 and y <= rows.len - 4) {
        var is_match = true;
        for (0..4) |i| {
            if (rows[y + i][x + i] == pattern_f[i]) {
                continue;
            }
            is_match = false;
            break;
        }
        sum += if (is_match) 1 else 0;
    }
    return sum;
}

inline fn cast(T: type, v: anytype) T {
    return @intCast(v);
}

test "scanHorizontally" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    try std.testing.expectEqual(2, try scanHorizontally(allocator, 3, "SAMXMASMAS"));
    try std.testing.expectEqual(1, try scanHorizontally(allocator, 6, "AMXSAMXMA"));
    try std.testing.expectEqual(2, try scanHorizontally(allocator, 6, "AMXSAMXMAS"));
    try std.testing.expectEqual(1, try scanHorizontally(allocator, 3, "AMXMASXMAS"));
}

test "scanVertically" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var d = try allocator.alloc([]const u8, 7);
    defer allocator.free(d);
    d[0] = "XLSAXMLS";
    d[1] = "MLAAMSLA";
    d[2] = "ALMAAALM";
    d[3] = "SLXASMLX";
    d[4] = "SLMASXLM";
    d[5] = "SLAASMLA";
    d[6] = "SLSASALS";

    try std.testing.expectEqual(1, try scanVertically(allocator, 0, 0, d));
    try std.testing.expectEqual(2, try scanVertically(allocator, 2, 3, d));
    try std.testing.expectEqual(2, try scanVertically(allocator, 7, 3, d));
    try std.testing.expectEqual(1, try scanVertically(allocator, 5, 4, d));
    try std.testing.expectEqual(0, try scanVertically(allocator, 1, 3, d));
}

test "scanDiagonally" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var d = try allocator.alloc([]const u8, 7);
    defer allocator.free(d);
    d[0] = "SLSAXMSS";
    d[1] = "MASAMALA";
    d[2] = "ALMAMALA";
    d[3] = "SLXXMMMX";
    d[4] = "SLMAMXLM";
    d[5] = "SAAAMAMA";
    d[6] = "SLSASASA";

    try std.testing.expectEqual(4, scanDiagonally(3, 3, d));
    try std.testing.expectEqual(1, scanDiagonally(5, 4, d));
}
