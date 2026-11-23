// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Safety ladder and global flags (dry-run default)
// Flo: scan args > pick global flags > reject --force without --live > return the rest
// I/O: argv slice > Pars {ladd, conf path, positional args}
// ===================================================================
const std = @import("std");
pub const Ladd = struct { live: bool = false, forc: bool = false, json: bool = false };
pub const Pars = struct { ladd: Ladd, conf: ?[]const u8, rest: []const []const u8 };
pub const Erro = error{ ForcNeedLive, FlagNeedValu };
pub fn parse(allo: std.mem.Allocator, args: []const []const u8) !Pars {
var outz: Pars = .{ .ladd = .{}, .conf = null, .rest = &.{} };
var rest: std.ArrayList([]const u8) = .empty;
var indx: usize = 0;
while (indx < args.len) : (indx += 1) {
const arg = args[indx];
if (std.mem.eql(u8, arg, "--live")) { outz.ladd.live = true; continue; }
if (std.mem.eql(u8, arg, "--force")) { outz.ladd.forc = true; continue; }
if (std.mem.eql(u8, arg, "--json")) { outz.ladd.json = true; continue; }
if (std.mem.eql(u8, arg, "--conf")) {
if (indx + 1 >= args.len) return Erro.FlagNeedValu;
indx += 1;
outz.conf = args[indx];
continue;
}
try rest.append(allo, arg);
}
if (outz.ladd.forc and !outz.ladd.live) return Erro.ForcNeedLive;
outz.rest = try rest.toOwnedSlice(allo);
return outz;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
