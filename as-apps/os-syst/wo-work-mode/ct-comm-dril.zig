// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: wo dril: timed restore drill, digest-only report
// Flo: restic restore > integrity check every .db > git fsck on the mirror > time vs RTO > stamp
// I/O: Ctxz (dry-run default, --live acts) > facts + dril.json stamp, exit 0 ok / 1 failed / 4 blocked
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const fcts = @import("ob-fact-rept.zig");
const exit = @import("ct-exit-code.zig");
fn dbsFind(ctxz: *const cx.Ctxz, scra: []const u8) ![]const []const u8 {
var outz: std.ArrayList([]const u8) = .empty;
var dirz = std.Io.Dir.cwd().openDir(ctxz.iozz, scra, .{ .iterate = true }) catch return outz.items;
defer dirz.close(ctxz.iozz);
var walk = try dirz.walk(ctxz.allo);
defer walk.deinit();
while (try walk.next(ctxz.iozz)) |ent| { if (ent.kind == .file and std.mem.endsWith(u8, ent.path, ".db")) try outz.append(ctxz.allo, try std.fs.path.join(ctxz.allo, &.{ scra, ent.path })); }
return outz.items;
}
pub fn comm(ctxz: *const cx.Ctxz, args: []const []const u8) !exit.Code {
_ = args;
var facts: std.ArrayList(fcts.Fact) = .empty;
const stmp = try cx.stamTxt(ctxz.allo, ctxz.nowz());
const scra = try std.fs.path.join(ctxz.allo, &.{ try ctxz.dirzData(), try std.fmt.allocPrint(ctxz.allo, "dril-{s}", .{stmp}) });
if (!ctxz.ladd.live) {
try facts.append(ctxz.allo, cx.mkfa("rest", .okay, try std.fmt.allocPrint(ctxz.allo, "dry-run: would run restic restore latest into {s}", .{scra})));
try facts.append(ctxz.allo, cx.mkfa("sqlt", .okay, "dry-run: would check every .db with PRAGMA integrity_check"));
try facts.append(ctxz.allo, cx.mkfa("fsck", .okay, if (ctxz.conf.dril_mirr_dirz.len > 0) "dry-run: would run git fsck on the mirror" else "dry-run: dril_mirr_dirz empty, fsck skipped"));
return ctxz.emit(facts.items);
}
const star = ctxz.nowz();
try std.Io.Dir.cwd().createDirPath(ctxz.iozz, scra);
if ((try ctxz.step(&facts, "rest", &.{ "restic", "restore", "latest", "--target", scra }, &.{})) != null) {
const dbzz = try dbsFind(ctxz, scra);
for (dbzz) |dbfl| {
const outp = (try ctxz.tool(&.{ "sqlite3", dbfl, "PRAGMA integrity_check;" }, &.{})) orelse { try facts.append(ctxz.allo, cx.mkfa("sqlt", .bloc, "sqlite3 absent")); break; };
if (outp.code == 0 and std.mem.eql(u8, cx.trim(outp.outz), "ok")) try facts.append(ctxz.allo, cx.mkfa("sqlt", .okay, std.fs.path.basename(dbfl))) else try facts.append(ctxz.allo, cx.mkfa("sqlt", .fail, try std.fmt.allocPrint(ctxz.allo, "{s}: {s}", .{ std.fs.path.basename(dbfl), cx.clip(cx.trim(outp.outz)) })));
}
if (dbzz.len == 0) try facts.append(ctxz.allo, cx.mkfa("sqlt", .skip, "no .db in the restore"));
if (ctxz.conf.dril_mirr_dirz.len > 0) _ = try ctxz.step(&facts, "fsck", &.{ "git", "-C", ctxz.conf.dril_mirr_dirz, "fsck", "--no-progress" }, &.{}) else try facts.append(ctxz.allo, cx.mkfa("fsck", .skip, "dril_mirr_dirz empty"));
try facts.append(ctxz.allo, cx.mkfa("mani", .skip, "no manifest format yet"));
}
const secs = ctxz.nowz() - star;
if (secs > ctxz.conf.dril_rtoz_maxz) try facts.append(ctxz.allo, cx.mkfa("rtoz", .fail, try std.fmt.allocPrint(ctxz.allo, "{d}s > limit {d}s", .{ secs, ctxz.conf.dril_rtoz_maxz }))) else try facts.append(ctxz.allo, cx.mkfa("rtoz", .okay, try std.fmt.allocPrint(ctxz.allo, "{d}s", .{secs})));
const code = fcts.codeOf(facts.items);
try ctxz.stamPut("dril", .{ .when = ctxz.nowz(), .secs = secs, .okay = code == .okay, .note = scra });
return ctxz.emit(facts.items);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
