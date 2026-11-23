// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: The user's crontab (Linux, macOS) as one location
// Flo: crontab -l > scan the whole text > Lref with new text > write a temp file and crontab <file> to apply or restore
// I/O: Ctxz + Targ > Lref; temp file under the data dir; calls only through the runner
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const walk = @import("se-scan-walk.zig");
const stex = @import("se-scan-text.zig");
const plan = @import("pl-plan-buil.zig");
const runm = @import("ru-cmdz-runn.zig");
pub const CF = .{ .name = "crontab" };
pub const Erro = error{CronFail};
pub fn current(ctxz: *const cx.Ctxz) ![]const u8 {
const outp = try ctxz.runn.exec(ctxz.allo, &.{ "crontab", "-l" }, &.{});
if (outp.code != 0) return "";
return outp.outz;
}
pub fn collect(ctxz: *const cx.Ctxz, targ: walk.Targ, outc: *walk.Outc) !void {
const text = current(ctxz) catch |err| switch (err) { runm.Erro.ToolAbsent => return, else => return err };
if (text.len == 0) return;
const hits = try stex.scanText(ctxz.allo, ctxz.osy, text, targ.olds, targ.news);
if (hits.len == 0) return;
var skip = false;
var mask: u16 = 0;
var outz: std.ArrayList(u8) = .empty;
var curz: usize = 0;
for (hits) |hit| {
const decd = plan.decide(ctxz.conf, 0, hit.kind, false, true);
mask |= decd.mask;
if (decd.skip) skip = true;
try outz.appendSlice(ctxz.allo, text[curz..hit.offz]);
try outz.appendSlice(ctxz.allo, hit.newz);
curz = hit.offz + hit.lenz;
}
try outz.appendSlice(ctxz.allo, text[curz..]);
try outc.lrefs.append(ctxz.allo, .{ .kind = .cron, .name = CF.name, .oldv = text, .newv = try outz.toOwnedSlice(ctxz.allo), .clas = plan.firstOf(mask), .mask = mask, .skip = skip });
}
pub fn setz(ctxz: *const cx.Ctxz, text: []const u8, tag: []const u8) !void {
const dirz = try ctxz.dirzData();
const tmpd = try ctxz.nati(try std.fmt.allocPrint(ctxz.allo, "{s}/tmp", .{dirz}));
try std.Io.Dir.cwd().createDirPath(ctxz.iozz, tmpd);
const path = try std.fmt.allocPrint(ctxz.allo, "{s}{c}cron-{s}.txt", .{ tmpd, std.fs.path.sep, tag });
var file = try std.Io.Dir.cwd().createFile(ctxz.iozz, path, .{ .truncate = true });
{
defer file.close(ctxz.iozz);
try file.writePositionalAll(ctxz.iozz, text, 0);
}
const outp = try ctxz.runn.exec(ctxz.allo, &.{ "crontab", path }, &.{});
if (outp.code != 0) return Erro.CronFail;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
