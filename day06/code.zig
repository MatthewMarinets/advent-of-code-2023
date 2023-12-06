const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;

const PartNumber = struct { value: u32, x_start: u32, x_end: u32, y: u32, is_part: bool };
const Symbol = struct { x: u32, y: u32, symbol: u8 };

pub fn string_equals(left: []const u8, right: []const u8) bool {
    if (left.len != right.len) {
        return false;
    }
    for (0..(left.len)) |index| {
        if (left[index] != right[index]) {
            return false;
        }
    }
    return true;
}

pub fn is_digit(char: u8) bool {
    return char >= '0' and char <= '9';
}

pub fn is_symbol(char: u8) bool {
    return !is_digit(char) and char != '.';
}

fn part_1(allocator: std.mem.Allocator, file_buffer: []u8) !void {
    var iter = std.mem.splitScalar(u8, file_buffer, '\n');
    var second_iter = std.mem.splitScalar(u8, file_buffer, '\n');

    // parse
    var line_number: u32 = 0;
    const line_stride = second_iter.first().len + 1; // this may be encoding dependent, LF vs CRLF
    var race_times = std.ArrayList(u32).init(allocator);
    var race_distances = std.ArrayList(u32).init(allocator);
    defer race_times.deinit();
    defer race_distances.deinit();
    const num_lines = (file_buffer.len + 1) / line_stride;
    print("size: {d}, {d}\n", .{ line_stride, num_lines });
    while (iter.next()) |line| : (line_number += 1) {
        if (line.len == 0) {
            continue;
        }
        if (string_equals(line[0..5], "Time:")) {
            var number_iter = std.mem.splitScalar(u8, line[11..line.len], ' ');
            while (number_iter.next()) |number_string| {
                if (number_string.len == 0) continue;
                const integer = try std.fmt.parseInt(u32, number_string, 0);
                try race_times.append(integer);
            }
        }
        if (string_equals(line[0..9], "Distance:")) {
            var number_iter = std.mem.splitScalar(u8, line[11..line.len], ' ');
            while (number_iter.next()) |number_string| {
                if (number_string.len == 0) continue;
                const integer = try std.fmt.parseInt(u32, number_string, 0);
                try race_distances.append(integer);
            }
        }
    }
    assert(race_times.items.len == race_distances.items.len);
    var aggregate: u64 = 1;
    for (0..race_times.items.len) |index| {
        const time = race_times.items[index];
        const best_distance = race_distances.items[index];
        print("t={d}, d={d}\n", .{ race_times.items[index], race_distances.items[index] });
        var ways_to_win: u32 = 0;
        for (0..time) |time_to_check| {
            if (time_to_check * (time - time_to_check) > best_distance) {
                ways_to_win += 1;
            }
        }
        print("{d} ways to win\n", .{ways_to_win});
        aggregate *= ways_to_win;
    }

    print("sum: {d}\n", .{aggregate});
    // part 1: 1624896
}

fn part_2(allocator: std.mem.Allocator, file_buffer: []u8) !void {
    _ = allocator;
    _ = file_buffer;

    var aggregate: u128 = 1;
    // const time = 71530;
    // const best_distance = 940200;
    const time = 56977875;
    const best_distance = 546192711311139;
    print("t={d}, d={d}\n", .{ time, best_distance });
    var ways_to_win: u64 = 0;
    for (0..time) |time_to_check| {
        if (time_to_check * (time - time_to_check) > best_distance) {
            ways_to_win += 1;
        }
    }
    print("{d} ways to win\n", .{ways_to_win});
    aggregate *= ways_to_win;
    print("sum: {d}\n", .{aggregate});
    // part 2: 32583852
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

    // const file = try std.fs.cwd().openFile("day06/sample_input.txt", .{});
    const file = try std.fs.cwd().openFile("day06/input.txt", .{});
    defer file.close();

    // Read the contents
    const buffer_size = 1_000_000;
    const file_buffer = try file.readToEndAlloc(allocator, buffer_size);
    defer allocator.free(file_buffer);

    print("\n===start===\n\n", .{});
    print("# Part 1\n\n", .{});
    try part_1(allocator, file_buffer);

    print("# Part 2\n\n", .{});
    try part_2(allocator, file_buffer);

    try bw.flush(); // don't forget to flush!
}
