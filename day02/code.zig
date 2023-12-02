const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;

const BallArrangement = struct { red: u64 = 0, green: u64 = 0, blue: u64 = 0 };

pub fn is_digit(char: u8) bool {
    return char >= '0' and char <= '9';
}

pub fn parse_max_ball_arrangement(string: []const u8) !BallArrangement {
    var max_result: BallArrangement = .{};
    var header_parsed = false;
    var num_start: ?usize = null;
    var current_number: ?u64 = null;
    for (0..string.len) |index| {
        const char = string[index];
        if (!header_parsed and char != ':') {
            continue;
        } else if (char == ':') {
            header_parsed = true;
        } else if (is_digit(char) and num_start == null) {
            num_start = index;
        } else if (!is_digit(char) and num_start != null) {
            if (num_start) |number_start| {
                current_number = try std.fmt.parseInt(u64, string[number_start..index], 0);
            }
            num_start = null;
        } else if (current_number) |_current_number| {
            if (char == 'r') {
                max_result.red = @max(max_result.red, _current_number);
            } else if (char == 'b') {
                max_result.blue = @max(max_result.blue, _current_number);
            } else if (char == 'g') {
                max_result.green = @max(max_result.green, _current_number);
            } else {
                assert(false);
            }
            current_number = null;
        }
    }
    return max_result;
}

fn part_1(allocator: std.mem.Allocator, file_buffer: []u8) !void {
    _ = allocator;
    var iter = std.mem.splitScalar(u8, file_buffer, '\n');
    const MAX_RED = 12;
    const MAX_GREEN = 13;
    const MAX_BLUE = 14;

    var aggregate: u32 = 0;
    var line_number: u32 = 1;
    while (iter.next()) |line| : (line_number += 1) {
        if (line.len == 0) {
            continue;
        }
        const max_result = try parse_max_ball_arrangement(line);
        print("{d} - r{d}, g{d}, b{d}\n", .{ line_number, max_result.red, max_result.green, max_result.blue });
        if (max_result.red > MAX_RED or max_result.blue > MAX_BLUE or max_result.green > MAX_GREEN) {
            print("{d} - impossible\n", .{line_number});
        } else {
            print("{d} - possible\n", .{line_number});
            aggregate += line_number;
        }
    }
    print("sum: {d}\n", .{aggregate});
    // 1931
}

fn set_power(set: BallArrangement) u64 {
    return set.red * set.blue * set.green;
}

fn part_2(allocator: std.mem.Allocator, file_buffer: []u8) !void {
    _ = allocator;
    var iter = std.mem.splitScalar(u8, file_buffer, '\n');

    var aggregate: u64 = 0;
    var line_number: u32 = 1;
    while (iter.next()) |line| : (line_number += 1) {
        if (line.len == 0) {
            continue;
        }
        const max_result = try parse_max_ball_arrangement(line);
        const power = set_power(max_result);
        print("{d} - r{d}, g{d}, b{d} - power = {d}\n", .{ line_number, max_result.red, max_result.green, max_result.blue, power });
        aggregate += power;
    }
    print("sum: {d}\n", .{aggregate});
}

pub fn main() !void {
    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();
    _ = stdout;

    //  Get an allocator
    var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gp.deinit();
    const allocator = gp.allocator();

    // const file = try std.fs.cwd().openFile("day02/sample_input.txt", .{});
    const file = try std.fs.cwd().openFile("day02/input.txt", .{});
    defer file.close();

    // Read the contents
    const buffer_size = 1_000_000;
    const file_buffer = try file.readToEndAlloc(allocator, buffer_size);
    defer allocator.free(file_buffer);

    // try part_1(allocator, file_buffer);
    try part_2(allocator, file_buffer);

    try bw.flush(); // don't forget to flush!
}
