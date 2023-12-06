const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;

const PartNumber = struct { value: u32, x_start: u32, x_end: u32, y: u32, is_part: bool };
const Symbol = struct { x: u32, y: u32, symbol: u8 };

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

pub fn is_digit(char: u8) bool {
    return char >= '0' and char <= '9';
}

pub fn is_symbol(char: u8) bool {
    return !is_digit(char) and char != '.';
}

fn transform_int(comptime T: type, value: T, map: []T) T {
    assert(@mod(map.len, 3) == 0);
    var index: u32 = 0;
    while (index < map.len) : (index += 3) {
        const dest_start = map[index];
        const start = map[index + 1];
        const length = map[index + 2];
        if (value >= start and value < start + length) {
            return value - start + dest_start;
        }
    }
    return value;
}

const Range = struct { start: u64, end: u64 };

fn range_overlap(range_1: Range, range_2: Range) Range {
    if (range_1.end <= range_2.start) {
        return .{ .start = 0, .end = 0 };
    } else if (range_2.end <= range_1.start) {
        return .{ .start = 0, .end = 0 };
    } else {
        const start = @max(range_1.start, range_2.start);
        const end = @min(range_1.end, range_2.end);
        return .{ .start = start, .end = end };
    }
}

fn transform_range(values_in: *std.ArrayList(Range), values_out: *std.ArrayList(Range), map: []u64) !void {
    assert(@mod(map.len, 3) == 0);
    var input_index: u32 = 0;
    while (input_index < values_in.items.len) : (input_index += 1) {
        const range_in = values_in.items[input_index];
        var mapped: bool = false;
        var index: u32 = 0;
        while (index < map.len) : (index += 3) {
            const dest_start = map[index];
            const map_range: Range = .{ .start = map[index + 1], .end = map[index + 1] + map[index + 2] };
            const overlap = range_overlap(range_in, map_range);
            if (overlap.end != 0) {
                mapped = true;
                try values_out.append(.{ .start = overlap.start - map_range.start + dest_start, .end = overlap.end - map_range.start + dest_start });
                if (overlap.start > range_in.start) {
                    try values_in.append(.{ .start = range_in.start, .end = overlap.start });
                }
                if (overlap.end < range_in.end) {
                    try values_in.append(.{ .start = overlap.end, .end = range_in.end });
                }
                break;
            }
        }
        if (!mapped) {
            try values_out.append(range_in);
        }
    }
}

fn part_1(allocator: std.mem.Allocator, file_buffer: []u8) !void {
    var iter = std.mem.splitScalar(u8, file_buffer, '\n');
    var second_iter = std.mem.splitScalar(u8, file_buffer, '\n');

    // parse
    var line_number: u32 = 0;
    const line_stride = second_iter.first().len + 1; // this may be encoding dependent, LF vs CRLF
    var seeds = std.ArrayList(u64).init(allocator);
    var maps = [_]std.ArrayList(u64){
        std.ArrayList(u64).init(allocator),
        std.ArrayList(u64).init(allocator),
        std.ArrayList(u64).init(allocator),
        std.ArrayList(u64).init(allocator),
        std.ArrayList(u64).init(allocator),
        std.ArrayList(u64).init(allocator),
        std.ArrayList(u64).init(allocator),
    };
    defer seeds.deinit();
    const num_lines = (file_buffer.len + 1) / line_stride;
    print("size: {d}, {d}\n", .{ line_stride, num_lines });
    var map_index: u8 = 0;
    while (iter.next()) |line| : (line_number += 1) {
        if (line.len == 0) {
            continue;
        }
        if (string_equals(line[0..6], "seeds:")) {
            var number_iter = std.mem.splitScalar(u8, line[7..line.len], ' ');
            while (number_iter.next()) |number_string| {
                const integer = try std.fmt.parseInt(u64, number_string, 0);
                try seeds.append(integer);
            }
        } else if (line.len > 11 and string_equals(line[0..12], "seed-to-soil")) {
            map_index = 0;
        } else if (line.len > 11 and string_equals(line[0..12], "soil-to-fert")) {
            map_index = 1;
        } else if (line.len > 11 and string_equals(line[0..12], "fertilizer-t")) {
            map_index = 2;
        } else if (line.len > 11 and string_equals(line[0..12], "water-to-lig")) {
            map_index = 3;
        } else if (line.len > 11 and string_equals(line[0..12], "light-to-tem")) {
            map_index = 4;
        } else if (line.len > 11 and string_equals(line[0..12], "temperature-")) {
            map_index = 5;
        } else if (line.len > 11 and string_equals(line[0..12], "humidity-to-")) {
            map_index = 6;
        } else {
            var number_iter = std.mem.splitScalar(u8, line, ' ');
            while (number_iter.next()) |number_string| {
                const integer = try std.fmt.parseInt(u64, number_string, 0);
                try maps[map_index].append(integer);
            }
        }
    }

    var min_location: u64 = 1 << 60;
    for (seeds.items) |seed| {
        // print("{d} ", .{seed});
        var value = seed;
        for (maps) |map| {
            value = transform_int(u64, value, map.items);
        }
        print("seed {d} -> {d}\n", .{ seed, value });
        if (value < min_location) {
            min_location = value;
        }
    }
    print("min = {d}\n", .{min_location});

    // part 1: 382895070
    inline for (maps) |map| {
        map.deinit();
    }
}

fn part_2(allocator: std.mem.Allocator, file_buffer: []u8) !void {
    var iter = std.mem.splitScalar(u8, file_buffer, '\n');
    var second_iter = std.mem.splitScalar(u8, file_buffer, '\n');

    // parse
    var line_number: u32 = 0;
    const line_stride = second_iter.first().len + 1; // this may be encoding dependent, LF vs CRLF
    var seeds = std.ArrayList(u64).init(allocator);
    var maps = [_]std.ArrayList(u64){
        std.ArrayList(u64).init(allocator),
        std.ArrayList(u64).init(allocator),
        std.ArrayList(u64).init(allocator),
        std.ArrayList(u64).init(allocator),
        std.ArrayList(u64).init(allocator),
        std.ArrayList(u64).init(allocator),
        std.ArrayList(u64).init(allocator),
    };
    defer seeds.deinit();
    const num_lines = (file_buffer.len + 1) / line_stride;
    print("size: {d}, {d}\n", .{ line_stride, num_lines });
    var map_index: u8 = 0;
    while (iter.next()) |line| : (line_number += 1) {
        if (line.len == 0) {
            continue;
        }
        if (string_equals(line[0..6], "seeds:")) {
            var number_iter = std.mem.splitScalar(u8, line[7..line.len], ' ');
            while (number_iter.next()) |number_string| {
                const integer = try std.fmt.parseInt(u64, number_string, 0);
                try seeds.append(integer);
            }
        } else if (line.len > 11 and string_equals(line[0..12], "seed-to-soil")) {
            map_index = 0;
        } else if (line.len > 11 and string_equals(line[0..12], "soil-to-fert")) {
            map_index = 1;
        } else if (line.len > 11 and string_equals(line[0..12], "fertilizer-t")) {
            map_index = 2;
        } else if (line.len > 11 and string_equals(line[0..12], "water-to-lig")) {
            map_index = 3;
        } else if (line.len > 11 and string_equals(line[0..12], "light-to-tem")) {
            map_index = 4;
        } else if (line.len > 11 and string_equals(line[0..12], "temperature-")) {
            map_index = 5;
        } else if (line.len > 11 and string_equals(line[0..12], "humidity-to-")) {
            map_index = 6;
        } else {
            var number_iter = std.mem.splitScalar(u8, line, ' ');
            while (number_iter.next()) |number_string| {
                const integer = try std.fmt.parseInt(u64, number_string, 0);
                try maps[map_index].append(integer);
            }
        }
    }

    var min_location: u64 = 1 << 60;
    var seed_index: u32 = 0;
    while (seed_index < seeds.items.len) : (seed_index += 2) {
        // print("{d} ", .{seed});
        const initial_range: Range = .{ .start = seeds.items[seed_index], .end = seeds.items[seed_index] + seeds.items[seed_index + 1] };
        var values = [8]std.ArrayList(Range){
            std.ArrayList(Range).init(allocator),
            std.ArrayList(Range).init(allocator),
            std.ArrayList(Range).init(allocator),
            std.ArrayList(Range).init(allocator),
            std.ArrayList(Range).init(allocator),
            std.ArrayList(Range).init(allocator),
            std.ArrayList(Range).init(allocator),
            std.ArrayList(Range).init(allocator),
        };
        try values[0].append(initial_range);
        for (0..maps.len) |stage| {
            const map = maps[stage];
            try transform_range(&values[stage], &values[stage + 1], map.items);
            // for (values[stage + 1].items) |input_range| {
            // print("{d}: {d}..{d}, ", .{ stage, input_range.start, input_range.end });
            // }
            // print("\n", .{});
        }
        for (values[7].items) |final_range| {
            if (final_range.start < min_location) {
                min_location = final_range.start;
            }
        }
        inline for (values) |value_array| {
            value_array.deinit();
        }
    }
    print("min = {d}\n", .{min_location});

    // part 2: 17729182
    // it's spaghetti, but it works! :D
    inline for (maps) |map| {
        map.deinit();
    }
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

    // const file = try std.fs.cwd().openFile("day05/sample_input.txt", .{});
    const file = try std.fs.cwd().openFile("day05/input.txt", .{});
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
