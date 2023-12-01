const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;

pub fn string_equals(left: []const u8, right: []const u8) bool {
    if (left.len != right.len) {
        return false;
    }
    for (0..left.len) |index| {
        if (left[index] != right[index]) {
            return false;
        }
    }
    return true;
}

pub fn string_replace_all(string: *[]u8, string_len: usize, from: []const u8, to: u8) void {
    var string_position: usize = 0;
    const replace_len = from.len;
    while (string_position < (string_len - replace_len)) {
        // print("'{s}'' vs '{s}'\n", .{ string[string_position .. string_position + replace_len], from });
        if (string_equals(string.*[string_position .. string_position + replace_len], from)) {
            string.*[string_position] = to;
            for (1..(replace_len - 1)) |offset| {
                string.*[string_position + offset] = '_';
            }
            string_position += replace_len;
        } else {
            string_position += 1;
        }
    }
    // print("{s}\n", .{string.*[0..string_len]});
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

fn part_2(allocator: std.mem.Allocator, file_buffer: []u8) !void {
    var iter = std.mem.splitScalar(u8, file_buffer, '\n');

    var modified_line: []u8 = try allocator.alloc(u8, 1024);
    defer allocator.free(modified_line);
    var aggregate: u32 = 0;
    var line_number: usize = 0;
    while (iter.next()) |line| : (line_number += 1) {
        if (line.len == 0) {
            continue;
        }
        assert(line.len < 1024);
        @memset(modified_line, 0);
        std.mem.copyForwards(u8, modified_line, line);
        string_replace_all(&modified_line, line.len, "zero", '0');
        string_replace_all(&modified_line, line.len, "one", '1');
        string_replace_all(&modified_line, line.len, "two", '2');
        string_replace_all(&modified_line, line.len, "three", '3');
        string_replace_all(&modified_line, line.len, "four", '4');
        string_replace_all(&modified_line, line.len, "five", '5');
        string_replace_all(&modified_line, line.len, "six", '6');
        string_replace_all(&modified_line, line.len, "seven", '7');
        string_replace_all(&modified_line, line.len, "eight", '8');
        string_replace_all(&modified_line, line.len, "nine", '9');

        var first_digit: u8 = 10;
        var last_digit: u8 = 10;
        for (modified_line) |char| {
            if (char >= '0' and char <= '9') {
                last_digit = char - '0';
                if (first_digit == 10) {
                    first_digit = char - '0';
                }
            }
        }
        const number = 10 * first_digit + last_digit;
        aggregate += number;
        print("{d} - found {d} - {s}\n", .{ line_number, number, modified_line });
    }
    print("sum: {d}\n", .{aggregate});
}

pub fn main() !void {
    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    // const stdout_file = std.io.getStdOut().writer();
    // var bw = std.io.bufferedWriter(stdout_file);
    // const stdout = bw.writer();

    //  Get an allocator
    var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gp.deinit();
    const allocator = gp.allocator();

    // const file = try std.fs.cwd().openFile("day1/input.txt", .{});
    const file = try std.fs.cwd().openFile("day1/sample_input2.txt", .{});
    defer file.close();

    // Read the contents
    const buffer_size = 1_000_000;
    const file_buffer = try file.readToEndAlloc(allocator, buffer_size);
    defer allocator.free(file_buffer);

    // try part_1(file_buffer);
    try part_2(allocator, file_buffer);

    // try bw.flush(); // don't forget to flush!
}
