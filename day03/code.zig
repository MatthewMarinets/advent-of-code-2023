const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;

const PartNumber = struct { value: u32, x_start: u32, x_end: u32, y: u32, is_part: bool };
const Symbol = struct { x: u32, y: u32, symbol: u8 };

pub fn is_digit(char: u8) bool {
    return char >= '0' and char <= '9';
}

pub fn is_symbol(char: u8) bool {
    return !is_digit(char) and char != '.';
}

fn part_1(allocator: std.mem.Allocator, file_buffer: []u8) !void {
    var iter = std.mem.splitScalar(u8, file_buffer, '\n');
    var second_iter = std.mem.splitScalar(u8, file_buffer, '\n');

    var part_list = std.ArrayList(PartNumber).init(allocator);
    var symbols = std.ArrayList(Symbol).init(allocator);
    defer part_list.deinit();
    defer symbols.deinit();

    // parse
    var line_number: u32 = 0;
    var current_start: ?u32 = null;
    var is_part = false;
    const line_stride = second_iter.first().len + 1; // this may be encoding dependent, LF vs CRLF
    const num_lines = file_buffer.len / line_stride;
    print("size: {d}, {d}\n", .{ line_stride, num_lines });
    while (iter.next()) |line| : (line_number += 1) {
        if (line.len == 0) {
            continue;
        }
        var x_coord: u32 = 0;
        // print("{s}\n", .{line});
        for (line) |char| {
            if (is_digit(char) and current_start == null) {
                current_start = x_coord;
                is_part = (x_coord > 0) and is_symbol(line[x_coord - 1]);
                if (line_number > 0) {
                    is_part = is_part or (is_symbol(file_buffer[line_stride * (line_number - 1) + x_coord]));
                    // diagonal
                    is_part = is_part or (x_coord > 0 and is_symbol(file_buffer[line_stride * (line_number - 1) + x_coord - 1]));
                }
                if (line_number < (num_lines - 1)) {
                    is_part = is_part or (is_symbol(file_buffer[line_stride * (line_number + 1) + x_coord]));
                    // diagonal
                    is_part = is_part or (x_coord > 0 and is_symbol(file_buffer[line_stride * (line_number + 1) + x_coord - 1]));
                }
            } else if (is_digit(char)) {
                is_part = is_part or (line_number > 0 and is_symbol(file_buffer[line_stride * (line_number - 1) + x_coord]));
                is_part = is_part or (line_number < (num_lines - 1) and is_symbol(file_buffer[line_stride * (line_number + 1) + x_coord]));
            } else if (current_start) |_current_start| {
                is_part = is_part or is_symbol(char);
                is_part = is_part or (line_number > 0 and is_symbol(file_buffer[line_stride * (line_number - 1) + x_coord]));
                is_part = is_part or (line_number < (num_lines - 1) and is_symbol(file_buffer[line_stride * (line_number + 1) + x_coord]));
                try part_list.append(.{ .value = try std.fmt.parseInt(u32, line[_current_start..x_coord], 0), .x_start = _current_start, .x_end = x_coord, .y = line_number, .is_part = is_part });
                current_start = null;
                is_part = false;
            }
            if (is_symbol(char)) {
                try symbols.append(.{ .x = x_coord, .y = line_number, .symbol = char });
            }
            x_coord += 1;
        }
        if (current_start) |_current_start| {
            try part_list.append(.{ .value = try std.fmt.parseInt(u32, line[_current_start..x_coord], 0), .x_start = _current_start, .x_end = x_coord, .y = line_number, .is_part = is_part });
            current_start = null;
            is_part = false;
        }
    }

    // analyze
    var aggregate: u32 = 0;
    for (part_list.items) |part| {
        // print("({}) {d}, {d} = {d}\n", .{ part.is_part, part.x_start, part.y, part.value });
        if (part.is_part) {
            aggregate += part.value;
        }
    }

    print("sum: {d}\n", .{aggregate});
    // part 1: 535351
}

fn part_2(allocator: std.mem.Allocator, file_buffer: []u8) !void {
    var iter = std.mem.splitScalar(u8, file_buffer, '\n');
    var second_iter = std.mem.splitScalar(u8, file_buffer, '\n');

    var part_list = std.ArrayList(PartNumber).init(allocator);
    var symbols = std.ArrayList(Symbol).init(allocator);
    defer part_list.deinit();
    defer symbols.deinit();

    // parse
    var line_number: u32 = 0;
    var current_start: ?u32 = null;
    var is_part = false;
    const line_stride = second_iter.first().len + 1; // this may be encoding dependent, LF vs CRLF
    const num_lines = file_buffer.len / line_stride;
    print("size: {d}, {d}\n", .{ line_stride, num_lines });
    while (iter.next()) |line| : (line_number += 1) {
        if (line.len == 0) {
            continue;
        }
        var x_coord: u32 = 0;
        // print("{s}\n", .{line});
        for (line) |char| {
            if (is_digit(char) and current_start == null) {
                current_start = x_coord;
                is_part = (x_coord > 0) and is_symbol(line[x_coord - 1]);
                if (line_number > 0) {
                    is_part = is_part or (is_symbol(file_buffer[line_stride * (line_number - 1) + x_coord]));
                    // diagonal
                    is_part = is_part or (x_coord > 0 and is_symbol(file_buffer[line_stride * (line_number - 1) + x_coord - 1]));
                }
                if (line_number < (num_lines - 1)) {
                    is_part = is_part or (is_symbol(file_buffer[line_stride * (line_number + 1) + x_coord]));
                    // diagonal
                    is_part = is_part or (x_coord > 0 and is_symbol(file_buffer[line_stride * (line_number + 1) + x_coord - 1]));
                }
            } else if (is_digit(char)) {
                is_part = is_part or (line_number > 0 and is_symbol(file_buffer[line_stride * (line_number - 1) + x_coord]));
                is_part = is_part or (line_number < (num_lines - 1) and is_symbol(file_buffer[line_stride * (line_number + 1) + x_coord]));
            } else if (current_start) |_current_start| {
                is_part = is_part or is_symbol(char);
                is_part = is_part or (line_number > 0 and is_symbol(file_buffer[line_stride * (line_number - 1) + x_coord]));
                is_part = is_part or (line_number < (num_lines - 1) and is_symbol(file_buffer[line_stride * (line_number + 1) + x_coord]));
                try part_list.append(.{ .value = try std.fmt.parseInt(u32, line[_current_start..x_coord], 0), .x_start = _current_start, .x_end = x_coord, .y = line_number, .is_part = is_part });
                current_start = null;
                is_part = false;
            }
            if (is_symbol(char)) {
                try symbols.append(.{ .x = x_coord, .y = line_number, .symbol = char });
            }
            x_coord += 1;
        }
        if (current_start) |_current_start| {
            try part_list.append(.{ .value = try std.fmt.parseInt(u32, line[_current_start..x_coord], 0), .x_start = _current_start, .x_end = x_coord, .y = line_number, .is_part = is_part });
            current_start = null;
            is_part = false;
        }
    }

    // analyze
    var aggregate: u32 = 0;
    for (symbols.items) |symbol| {
        var num_adjacents: u8 = 0;
        var gear_ratio: u32 = 1;
        if (symbol.symbol != '*') {
            continue;
        }
        for (part_list.items) |part| {
            if (!part.is_part) {
                continue;
            }
            if (part.y < (symbol.y - 1) or part.y > (symbol.y + 1)) {
                continue;
            }
            if (part.x_end < (symbol.x) or part.x_start > (symbol.x + 1)) {
                continue;
            }

            // print("{d},{d} -- has {d}\n", .{ symbol.x, symbol.y, part.value });
            num_adjacents += 1;
            gear_ratio *= part.value;
        }
        if (num_adjacents == 2) {
            aggregate += gear_ratio;
        }
    }

    print("sum: {d}\n", .{aggregate});
    // part 2: 87287096
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

    // const file = try std.fs.cwd().openFile("day03/sample_input.txt", .{});
    const file = try std.fs.cwd().openFile("day03/input.txt", .{});
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
