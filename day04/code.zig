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

    // parse
    var line_number: u32 = 0;
    var points: u64 = 0;
    const line_stride = second_iter.first().len + 1; // this may be encoding dependent, LF vs CRLF
    const num_lines = (file_buffer.len + 1) / line_stride;
    print("size: {d}, {d}\n", .{ line_stride, num_lines });
    while (iter.next()) |line| : (line_number += 1) {
        if (line.len == 0) {
            continue;
        }
        if (line[0] != 'C') {
            continue;
        }
        var winning_cards = std.ArrayList(u8).init(allocator);
        var own_cards = std.ArrayList(u8).init(allocator);
        defer winning_cards.deinit();
        defer own_cards.deinit();
        var pos: usize = 5;
        while (line[pos] != ':') pos += 1;
        pos += 2;
        while (line[pos] != '|') {
            if (line[pos] == ' ') {
                try winning_cards.append(try std.fmt.parseInt(u8, line[pos + 1 .. pos + 2], 0));
            } else {
                try winning_cards.append(try std.fmt.parseInt(u8, line[pos .. pos + 2], 0));
            }
            pos += 3;
        }
        pos += 2;
        while (pos < line.len) {
            if (line[pos] == ' ') {
                try own_cards.append(try std.fmt.parseInt(u8, line[pos + 1 .. pos + 2], 0));
            } else {
                try own_cards.append(try std.fmt.parseInt(u8, line[pos .. pos + 2], 0));
            }
            pos += 3;
        }
        var card_matches: u6 = 0;
        for (own_cards.items) |own_card| {
            for (winning_cards.items) |winning_card| {
                if (own_card == winning_card) {
                    card_matches += 1;
                    continue;
                }
            }
        }
        if (card_matches > 0) {
            points += (@as(u64, 1) << (card_matches - 1));
        }
        // print("line {d} -- {d} points\n", .{ line_number, points });
    }

    print("sum: {d}\n", .{points});
    // part 1: 20855
}

fn part_2(allocator: std.mem.Allocator, file_buffer: []u8) !void {
    var iter = std.mem.splitScalar(u8, file_buffer, '\n');
    var second_iter = std.mem.splitScalar(u8, file_buffer, '\n');

    // parse
    var line_number: u32 = 0;
    const line_stride = second_iter.first().len + 1; // this may be encoding dependent, LF vs CRLF
    const num_lines = (file_buffer.len + 1) / line_stride;
    const num_cards = try allocator.alloc(u32, num_lines);
    defer allocator.free(num_cards);
    for (0..num_lines) |pos| {
        num_cards[pos] = 1;
    }
    print("size: {d}, {d}\n", .{ line_stride, num_lines });
    while (iter.next()) |line| : (line_number += 1) {
        if (line.len == 0) {
            continue;
        }
        if (line[0] != 'C') {
            continue;
        }
        var winning_cards = std.ArrayList(u8).init(allocator);
        var own_cards = std.ArrayList(u8).init(allocator);
        defer winning_cards.deinit();
        defer own_cards.deinit();
        var pos: usize = 5;
        while (line[pos] != ':') pos += 1;
        pos += 2;
        while (line[pos] != '|') {
            if (line[pos] == ' ') {
                try winning_cards.append(try std.fmt.parseInt(u8, line[pos + 1 .. pos + 2], 0));
            } else {
                try winning_cards.append(try std.fmt.parseInt(u8, line[pos .. pos + 2], 0));
            }
            pos += 3;
        }
        pos += 2;
        while (pos < line.len) {
            if (line[pos] == ' ') {
                try own_cards.append(try std.fmt.parseInt(u8, line[pos + 1 .. pos + 2], 0));
            } else {
                try own_cards.append(try std.fmt.parseInt(u8, line[pos .. pos + 2], 0));
            }
            pos += 3;
        }
        var card_matches: u6 = 0;
        for (own_cards.items) |own_card| {
            for (winning_cards.items) |winning_card| {
                if (own_card == winning_card) {
                    card_matches += 1;
                    continue;
                }
            }
        }
        for ((line_number + 1)..(line_number + card_matches + 1)) |card_position| {
            if (card_position > num_lines) {
                break;
            }
            num_cards[card_position] += num_cards[line_number];
        }
        // print("line {d}: {d} copies x {d} matches\n", .{ line_number, num_cards[line_number], card_matches });
    }

    var aggregate: u32 = 0;
    for (num_cards) |number_card_type| {
        aggregate += number_card_type;
    }
    print("sum: {d}\n", .{aggregate});
    // part 2: 5489600
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

    // const file = try std.fs.cwd().openFile("day04/sample_input.txt", .{});
    const file = try std.fs.cwd().openFile("day04/input.txt", .{});
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
