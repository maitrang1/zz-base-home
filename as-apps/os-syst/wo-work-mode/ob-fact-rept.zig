// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Fact list per check, with text and JSON output
// Flo: collect facts > fold to one exit code > render text or JSON
// I/O: []Fact > exit Code, stdout text or JSON {code, facts}
// ===================================================================
const std = @import("std");
const exit = @import("ct-exit-code.zig");
pub const Stat = enum { okay, drif, bloc, fail, skip };
pub const Fact = struct { name: []const u8, stat: Stat, note: []const u8 };
const Rept = struct { code: u8, facts: []const Fact };
pub fn statName(stat: Stat) []const u8 { return switch (stat) { .okay => "okay", .drif => "drif", .bloc => "bloc", .fail => "fail", .skip => "skip" }; }
pub fn codeOf(facts: []const Fact) exit.Code {
var drif = false;
var bloc = false;
for (facts) |fact| { switch (fact.stat) { .fail => return .fail, .drif => drif = true, .bloc => bloc = true, else => {} } }
if (drif) return .drif;
if (bloc) return .bloc;
return .okay;
}
pub fn rendText(wrtr: *std.Io.Writer, facts: []const Fact) !void {
for (facts) |fact| {
try wrtr.print("{s}\t{s}\t", .{ statName(fact.stat), fact.name });
for (fact.note) |chr| try wrtr.writeByte(if (chr == '\n' or chr == '\r' or chr == '\t') ' ' else chr);
try wrtr.writeByte('\n');
}
}
pub fn rendJson(wrtr: *std.Io.Writer, facts: []const Fact) !void {
try std.json.Stringify.value(Rept{ .code = @intFromEnum(codeOf(facts)), .facts = facts }, .{}, wrtr);
try wrtr.writeAll("\n");
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
