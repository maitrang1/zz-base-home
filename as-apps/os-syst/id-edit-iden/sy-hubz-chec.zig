// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Ask the live hub which ids it knows, before and after a run
// Flo: curl GET /tasks through the runner > parse job ids + chain steps + armErrorCount > poll until old ids are gone and new ids are in
// I/O: Ctxz + port + Pair list > Snap; Snap before + pairs > Result {state, note}
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const osys = @import("ut-osys-adap.zig");
const tk = @import("ut-iden-toke.zig");
const runm = @import("ru-cmdz-runn.zig");
pub const Snap = struct { up: bool = false, fileok: bool = false, errc: u64 = 0, idz: []const []const u8 = &.{} };
pub const State = enum { skip, okay, bad };
pub const Result = struct { state: State, note: []const u8 };
const Task = struct { id: []const u8 = "", ids: ?[]const []const u8 = null };
const Raww = struct { ok: bool = false, fileOk: bool = false, armErrorCount: u64 = 0, tasks: []const Task = &.{} };
pub fn parse(allo: std.mem.Allocator, text: []const u8) !Snap {
const raww = try std.json.parseFromSliceLeaky(Raww, allo, text, .{ .ignore_unknown_fields = true, .allocate = .alloc_always });
if (!raww.ok) return .{};
var list: std.ArrayList([]const u8) = .empty;
for (raww.tasks) |task| {
try list.append(allo, task.id);
if (task.ids) |idsz| for (idsz) |step| try list.append(allo, step);
}
return .{ .up = true, .fileok = raww.fileOk, .errc = raww.armErrorCount, .idz = try list.toOwnedSlice(allo) };
}
pub fn snap(ctxz: *const cx.Ctxz, port: u16) Snap {
const url = std.fmt.allocPrint(ctxz.allo, "http://{s}:{d}/tasks", .{ ctxz.conf.hubz_host, port }) catch return .{};
const curl = if (osys.wind) ctxz.conf.curl_name_wind else ctxz.conf.curl_name_unix;
const outp = ctxz.runn.exec(ctxz.allo, &.{ curl, "-s", "-m", "3", url }, &.{}) catch return .{};
if (outp.code != 0) return .{};
return parse(ctxz.allo, outp.outz) catch .{};
}
pub fn has(sna: Snap, iden: []const u8) bool { for (sna.idz) |item| if (std.mem.eql(u8, item, iden)) return true; return false; }
fn verdict(ctxz: *const cx.Ctxz, before: Snap, aftr: Snap, pairs: []const tk.Pair) ?[]const u8 {
if (!aftr.fileok) return "hub reports fileOk false";
if (aftr.errc > before.errc) return "hub armErrorCount went up";
for (pairs) |pair| {
if (!has(before, pair.old)) continue;
if (has(aftr, pair.old)) return std.fmt.allocPrint(ctxz.allo, "hub still lists {s}", .{pair.old}) catch "hub still lists an old id";
if (!has(aftr, pair.new)) return std.fmt.allocPrint(ctxz.allo, "hub does not list {s} yet", .{pair.new}) catch "hub misses a new id";
}
return null;
}
pub fn check(ctxz: *const cx.Ctxz, port: u16, before: Snap, pairs: []const tk.Pair) Result {
if (!ctxz.conf.hubz_chec_on) return .{ .state = .skip, .note = "hub check off" };
if (!before.up) return .{ .state = .skip, .note = "hub was not running" };
var tryz: u32 = 0;
var why: []const u8 = "";
while (tryz <= ctxz.conf.hubz_wait_seco) : (tryz += 1) {
const aftr = snap(ctxz, port);
if (!aftr.up) return .{ .state = .bad, .note = "hub stopped answering" };
why = verdict(ctxz, before, aftr, pairs) orelse return .{ .state = .okay, .note = "hub reloaded and lists the new ids" };
if (tryz < ctxz.conf.hubz_wait_seco) std.Io.sleep(ctxz.iozz, .fromMilliseconds(1000), .awake) catch {};
}
return .{ .state = .bad, .note = why };
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
