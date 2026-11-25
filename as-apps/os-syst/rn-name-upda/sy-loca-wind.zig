// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Windows registry values that hold the old path
// Flo: reg query each key tree > parse values > scan string values > Lref with new value > reg add to apply or restore
// I/O: Ctxz + Targ + key list > Lref list; reg add calls (only through the runner)
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const walk = @import("se-scan-walk.zig");
const stex = @import("se-scan-text.zig");
const plan = @import("pl-plan-buil.zig");
const runm = @import("ru-cmdz-runn.zig");
const CF = .{ .sepz = "\x1f", .hkey = "HKEY_", .typz = "    REG_", .gap = "    " };
pub const Erro = error{RegFail};
pub const Regv = struct { key: []const u8, name: []const u8, typz: []const u8, data: []const u8 };
pub fn nameOf(allo: std.mem.Allocator, regv: Regv) ![]u8 { return std.fmt.allocPrint(allo, "{s}{s}{s}{s}{s}", .{ regv.key, CF.sepz, regv.name, CF.sepz, regv.typz }); }
pub fn splitName(name: []const u8) ?Regv {
var iter = std.mem.splitSequence(u8, name, CF.sepz);
const key = iter.next() orelse return null;
const valn = iter.next() orelse return null;
const typz = iter.next() orelse return null;
return .{ .key = key, .name = valn, .typz = typz, .data = "" };
}
pub fn parseQuery(allo: std.mem.Allocator, text: []const u8) ![]Regv {
var list: std.ArrayList(Regv) = .empty;
var key: []const u8 = "";
var iter = std.mem.splitScalar(u8, text, '\n');
while (iter.next()) |raww| {
const line = std.mem.trimEnd(u8, raww, "\r");
if (std.mem.startsWith(u8, line, CF.hkey)) { key = try allo.dupe(u8, line); continue; }
if (!std.mem.startsWith(u8, line, CF.gap) or key.len == 0) continue;
const pos = std.mem.indexOf(u8, line, CF.typz) orelse continue;
const valn = line[CF.gap.len..pos];
const rest = line[pos + CF.gap.len ..];
const tend = std.mem.indexOf(u8, rest, CF.gap) orelse rest.len;
const typz = rest[0..tend];
const data = if (tend + CF.gap.len <= rest.len) rest[tend + CF.gap.len ..] else "";
try list.append(allo, .{ .key = key, .name = try allo.dupe(u8, valn), .typz = try allo.dupe(u8, typz), .data = try allo.dupe(u8, data) });
}
return list.toOwnedSlice(allo);
}
fn queryKey(ctxz: *const cx.Ctxz, key: []const u8) !?[]Regv {
const outp = ctxz.runn.exec(ctxz.allo, &.{ "reg", "query", key, "/s" }, &.{}) catch |err| switch (err) { runm.Erro.ToolAbsent => return null, else => return err };
if (outp.code != 0) return null;
return try parseQuery(ctxz.allo, outp.outz);
}
pub fn collect(ctxz: *const cx.Ctxz, targ: walk.Targ, outc: *walk.Outc) !void {
for (ctxz.conf.loca_regk_list) |key| {
const vals = (try queryKey(ctxz, key)) orelse continue;
const pmask: u16 = if (std.mem.startsWith(u8, key, "HKLM")) plan.bitOf(.syst) else 0;
for (vals) |regv| {
const wide = std.mem.eql(u8, regv.typz, "REG_MULTI_SZ");
if (!wide and !std.mem.eql(u8, regv.typz, "REG_SZ") and !std.mem.eql(u8, regv.typz, "REG_EXPAND_SZ")) continue;
const hits = try stex.scanText(ctxz.allo, ctxz.osy, regv.data, targ.olds, targ.news);
if (hits.len == 0) continue;
var mask: u16 = pmask;
var skip = false;
var outz: std.ArrayList(u8) = .empty;
var curz: usize = 0;
for (hits) |hit| {
const decd = plan.decide(ctxz.conf, pmask, hit.kind, wide, !wide);
mask |= decd.mask;
if (decd.skip) skip = true;
try outz.appendSlice(ctxz.allo, regv.data[curz..hit.offz]);
try outz.appendSlice(ctxz.allo, hit.newz);
curz = hit.offz + hit.lenz;
}
try outz.appendSlice(ctxz.allo, regv.data[curz..]);
try outc.lrefs.append(ctxz.allo, .{ .kind = .regv, .name = try nameOf(ctxz.allo, regv), .oldv = regv.data, .newv = try outz.toOwnedSlice(ctxz.allo), .clas = plan.firstOf(mask), .mask = mask, .skip = skip });
}
}
}
pub fn current(ctxz: *const cx.Ctxz, name: []const u8) ![]const u8 {
const spl = splitName(name) orelse return Erro.RegFail;
const outp = try ctxz.runn.exec(ctxz.allo, if (std.mem.eql(u8, spl.name, "(Default)")) &.{ "reg", "query", spl.key, "/ve" } else &.{ "reg", "query", spl.key, "/v", spl.name }, &.{});
if (outp.code != 0) return Erro.RegFail;
for (try parseQuery(ctxz.allo, outp.outz)) |regv| { if (std.mem.eql(u8, regv.name, spl.name)) return regv.data; }
return Erro.RegFail;
}
pub fn setz(ctxz: *const cx.Ctxz, name: []const u8, value: []const u8) !void {
const spl = splitName(name) orelse return Erro.RegFail;
const outp = try ctxz.runn.exec(ctxz.allo, if (std.mem.eql(u8, spl.name, "(Default)")) &.{ "reg", "add", spl.key, "/ve", "/t", spl.typz, "/d", value, "/f" } else &.{ "reg", "add", spl.key, "/v", spl.name, "/t", spl.typz, "/d", value, "/f" }, &.{});
if (outp.code != 0) return Erro.RegFail;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
