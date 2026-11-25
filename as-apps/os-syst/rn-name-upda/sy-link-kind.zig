// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Re-point a symlink to a new target, no gap
// Flo: make a temp link with the new target > rename it over the old link > read a link back
// I/O: link path + target text + tag > link retargeted on disk
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const CF = .{ .linz = 4096 };
pub fn currentz(ctxz: *const cx.Ctxz, name: []const u8) ![]const u8 {
var buff: [CF.linz]u8 = undefined;
const lenz = try std.Io.Dir.cwd().readLink(ctxz.iozz, try ctxz.nati(name), &buff);
return ctxz.allo.dupe(u8, buff[0..lenz]);
}
pub fn setz(ctxz: *const cx.Ctxz, name: []const u8, target: []const u8, tag: []const u8) !void {
const nat = try ctxz.nati(name);
const tmpn = try std.fmt.allocPrint(ctxz.allo, "{s}.rn-{s}", .{ nat, tag });
const isdr = if (std.Io.Dir.cwd().statFile(ctxz.iozz, nat, .{})) |info| info.kind == .directory else |_| false;
try std.Io.Dir.cwd().symLink(ctxz.iozz, target, tmpn, .{ .is_directory = isdr });
std.Io.Dir.rename(std.Io.Dir.cwd(), tmpn, std.Io.Dir.cwd(), nat, ctxz.iozz) catch |err| {
std.Io.Dir.cwd().deleteFile(ctxz.iozz, tmpn) catch {};
return err;
};
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
