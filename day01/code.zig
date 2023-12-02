const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;

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

pub fn string_replace_first(string: *[]u8, string_len: usize, from_array: []const []const u8, to_array: []const u8) void {
    var string_position: usize = 0;
    assert(from_array.len == to_array.len);
    while (string_position < (string_len)) {
        for (0..(from_array.len)) |index| {
            const from = from_array[index];
            const to = to_array[index];
            const replace_len = from.len;
            if (string_position + replace_len > string_len) {
                continue;
            }
            if (string_equals(string.*[string_position .. string_position + replace_len], from)) {
                string.*[string_position] = to;
                for (1..(replace_len)) |offset| {
                    string.*[string_position + offset] = '_';
                }
                return;
            }
        }
        string_position += 1;
    }
}

pub fn string_replace_last(string: *[]u8, string_len: usize, from_array: []const []const u8, to_array: []const u8) void {
    var string_position: usize = string_len - 1;
    assert(from_array.len == to_array.len);
    while (string_position > 0) {
        for (0..(from_array.len)) |index| {
            const from = from_array[index];
            const to = to_array[index];
            const replace_len = from.len;
            if (string_position + replace_len > string_len) {
                continue;
            }
            if (string_equals(string.*[string_position .. string_position + replace_len], from)) {
                string.*[string_position] = to;
                for (1..(replace_len)) |offset| {
                    string.*[string_position + offset] = '_';
                }
                return;
            }
        }
        string_position -= 1;
    }
}

fn part_1(file_buffer: []u8) !void {
    var iter = std.mem.splitScalar(u8, file_buffer, '\n');

    var aggregate: u32 = 0;
    var line_number: usize = 0;
    while (iter.next()) |line| : (line_number += 1) {
        if (line.len == 0) {
            continue;
        }
        var first_digit: u8 = 10;
        var last_digit: u8 = 10;
        for (line) |char| {
            if (char >= '0' and char <= '9') {
                last_digit = char - '0';
                if (first_digit == 10) {
                    first_digit = char - '0';
                }
            }
        }
        const number = 10 * first_digit + last_digit;
        aggregate += number;
        print("{d} - found {d} - {s}\n", .{ line_number, number, line });
    }
    print("sum: {d}\n", .{aggregate});
}

fn part_2(bw: anytype, stdout: anytype, allocator: std.mem.Allocator, file_buffer: []u8) !void {
    var iter = std.mem.splitScalar(u8, file_buffer, '\n');

    var modified_line_forward: []u8 = try allocator.alloc(u8, 1024);
    var modified_line_back: []u8 = try allocator.alloc(u8, 1024);
    defer allocator.free(modified_line_forward);
    defer allocator.free(modified_line_back);
    var aggregate: u32 = 0;
    var line_number: usize = 0;
    while (iter.next()) |line| : (line_number += 1) {
        if (line.len == 0) {
            continue;
        }
        assert(line.len < 1024);
        @memset(modified_line_forward, 0);
        @memset(modified_line_back, 0);
        std.mem.copyForwards(u8, modified_line_forward, line);
        std.mem.copyForwards(u8, modified_line_back, line);
        const words = [_][]const u8{
            "zero",
            "one",
            "two",
            "three",
            "four",
            "five",
            "six",
            "seven",
            "eight",
            "nine",
        };
        const chars: []const u8 = "0123456789";
        string_replace_first(&modified_line_forward, line.len, &words, chars);
        string_replace_last(&modified_line_back, line.len, &words, chars);

        var first_digit: u8 = 10;
        for (modified_line_forward) |char| {
            if (char >= '0' and char <= '9') {
                first_digit = char - '0';
                break;
            }
        }
        var last_digit: u8 = 10;
        var index: usize = line.len + 1;
        while (index >= 0) {
            const char = modified_line_back[index];
            if (char >= '0' and char <= '9') {
                last_digit = char - '0';
                break;
            }
            index -= 1;
        }
        const number = 10 * first_digit + last_digit;
        aggregate += number;
        try stdout.print("{d} - found {d}{d} = {d} - {s}\n", .{ line_number, first_digit, last_digit, number, line });
        try bw.*.flush();
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

    //  Get an allocator
    var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gp.deinit();
    const allocator = gp.allocator();

    const file = try std.fs.cwd().openFile("day01/input.txt", .{});
    // const file = try std.fs.cwd().openFile("day01/sample_input2.txt", .{});
    defer file.close();

    // Read the contents
    const buffer_size = 1_000_000;
    const file_buffer = try file.readToEndAlloc(allocator, buffer_size);
    defer allocator.free(file_buffer);

    // try part_1(file_buffer);
    try part_2(&bw, stdout, allocator, file_buffer);

    try bw.flush(); // don't forget to flush!
    // 54690 is too high
    // 54681 is too high
}
