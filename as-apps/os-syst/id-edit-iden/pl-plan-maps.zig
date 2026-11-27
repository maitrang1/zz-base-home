// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Parse and check the rename map
// Flo: args or file lines > Pair list > check ids, same, dup old, dup new, new is an old
// I/O: "old=new" args or map file text > Pair list + first Issue or null
// ===================================================================
const std = @import("std");
const tk = @import("ut-iden-toke.zig");
pub const Issue = struct { why: []const u8, iden: []const u8 };
pub const Erro = error{BadLine};
fn splitPair(line: []const u8) ?tk.Pair {
if (std.mem.indexOf(u8, line, "->")) |pos| return .{ .old = std.mem.trim(u8, line[0..pos], " \t"), .new = std.mem.trim(u8, line[pos + 2 ..], " \t") };
if (std.mem.indexOfScalar(u8, line, '=')) |pos| return .{ .old = std.mem.trim(u8, line[0..pos], " \t"), .new = std.mem.trim(u8, line[pos + 1 ..], " \t") };
var iter = std.mem.tokenizeAny(u8, line, " \t");
const left = iter.next() orelse return null;
const righ = iter.next() orelse return null;
if (iter.next() != null) return null;
return .{ .old = left, .new = righ };
}
pub fn fromText(allo: std.mem.Allocator, text: []const u8, list: *std.ArrayList(tk.Pair)) !void {
var iter = std.mem.splitScalar(u8, text, '\n');
while (iter.next()) |raww| {
const line = std.mem.trim(u8, raww, " \t\r");
if (line.len == 0 or line[0] == '#') continue;
try list.append(allo, splitPair(line) orelse return Erro.BadLine);
}
}
pub fn fromArgs(allo: std.mem.Allocator, args: []const []const u8, list: *std.ArrayList(tk.Pair)) !void {
for (args) |arg| try list.append(allo, splitPair(arg) orelse return Erro.BadLine);
}
pub fn check(pairs: []const tk.Pair) ?Issue {
if (pairs.len == 0) return .{ .why = "no pairs", .iden = "" };
for (pairs, 0..) |pair, indx| {
if (tk.idenBadz(pair.old)) |why| return .{ .why = why, .iden = pair.old };
if (tk.idenBadz(pair.new)) |why| return .{ .why = why, .iden = pair.new };
if (std.mem.eql(u8, pair.old, pair.new)) return .{ .why = "old equals new", .iden = pair.old };
for (pairs[0..indx]) |prev| {
if (std.mem.eql(u8, prev.old, pair.old)) return .{ .why = "old id listed twice", .iden = pair.old };
if (std.mem.eql(u8, prev.new, pair.new)) return .{ .why = "two ids renamed to the same new id", .iden = pair.new };
}
}
for (pairs) |pair| for (pairs) |othr| if (std.mem.eql(u8, pair.new, othr.old)) return .{ .why = "new id is also an old id (chain or swap): run two maps", .iden = pair.new };
return null;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
