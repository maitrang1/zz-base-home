// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: wo wipz: snapshot dirty work to private WIP ref
// Flo: dirty? > temp index > add all > drop big files > tree > commit on last snapshot > gitleaks > (leak: restic bundle only) > head ref > push > daily bookmark > stamp
// I/O: Ctxz (dry-run default, --live acts) > facts, exit 0 ok / 1 failed / 4 blocked
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const fcts = @import("ob-fact-rept.zig");
const exit = @import("ct-exit-code.zig");
const runm = @import("ru-cmdz-runn.zig");
const CF = .{ .leak = 9, .shaz = 40, .daye = 8 };
pub fn headName(allo: std.mem.Allocator, devi: []const u8) ![]u8 { return std.fmt.allocPrint(allo, "refs/wipz/{s}/head", .{devi}); }
pub fn heldName(allo: std.mem.Allocator, devi: []const u8) ![]u8 { return std.fmt.allocPrint(allo, "refs/wipz/{s}/held", .{devi}); }
pub fn markName(allo: std.mem.Allocator, devi: []const u8, nowz: i64) ![]u8 { return std.fmt.allocPrint(allo, "refs/wipz/{s}/d{s}", .{ devi, (try cx.stamTxt(allo, nowz))[0..CF.daye] }); }
fn shaOkay(text: []const u8) bool {
if (text.len != CF.shaz) return false;
for (text) |chr| { if (!std.ascii.isHex(chr)) return false; }
return true;
}
fn bigsFind(ctxz: *const cx.Ctxz) !?[]const []const u8 {
const outp = (try ctxz.tool(&.{ "git", "ls-files", "-z", "--others", "--modified", "--exclude-standard" }, &.{})) orelse return null;
var bigs: std.ArrayList([]const u8) = .empty;
if (outp.code != 0) return bigs.items;
var iter = std.mem.splitScalar(u8, outp.outz, 0);
while (iter.next()) |path| {
if (path.len == 0) continue;
const info = std.Io.Dir.cwd().statFile(ctxz.iozz, path, .{}) catch continue;
if (info.size > ctxz.conf.wipz_file_maxz) try bigs.append(ctxz.allo, path);
}
return bigs.items;
}
fn heldSave(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact), comh: []const u8, base: []const u8) !void {
const held = try heldName(ctxz.allo, ctxz.devi);
_ = (try ctxz.step(facts, "held", &.{ "git", "update-ref", held, comh }, &.{})) orelse return;
const bund = try std.fs.path.join(ctxz.allo, &.{ try ctxz.dirzData(), try std.fmt.allocPrint(ctxz.allo, "held-{s}.bundle", .{try cx.stamTxt(ctxz.allo, ctxz.nowz())}) });
const bscl = try std.fmt.allocPrint(ctxz.allo, "^{s}", .{base});
_ = (try ctxz.step(facts, "bndl", &.{ "git", "bundle", "create", bund, held, bscl }, &.{})) orelse return;
_ = try ctxz.step(facts, "rest", &.{ "restic", "backup", "--tag", ctxz.conf.wipz_rest_tagz, bund }, &.{});
}
pub fn comm(ctxz: *const cx.Ctxz, args: []const []const u8) !exit.Code {
_ = args;
var facts: std.ArrayList(fcts.Fact) = .empty;
const dirt = (try ctxz.tool(&.{ "git", "status", "--porcelain" }, &.{})) orelse { try facts.append(ctxz.allo, cx.mkfa("snap", .bloc, "git absent")); return ctxz.emit(facts.items); };
if (dirt.code != 0) { try facts.append(ctxz.allo, cx.mkfa("snap", .fail, try std.fmt.allocPrint(ctxz.allo, "git status failed: {s}", .{cx.clip(cx.trim(dirt.errz))}))); return ctxz.emit(facts.items); }
if (cx.trim(dirt.outz).len == 0) { try facts.append(ctxz.allo, cx.mkfa("snap", .skip, "clean, nothing to snapshot")); return ctxz.emit(facts.items); }
if (ctxz.conf.wipz_remo_list.len == 0) { try facts.append(ctxz.allo, cx.mkfa("remo", .bloc, "wipz_remo_list is empty: name the private remotes")); return ctxz.emit(facts.items); }
const refz = try headName(ctxz.allo, ctxz.devi);
if (!ctxz.ladd.live) { try facts.append(ctxz.allo, cx.mkfa("snap", .okay, try std.fmt.allocPrint(ctxz.allo, "dry-run: would snapshot to {s}, scan, push to {d} remote(s)", .{ refz, ctxz.conf.wipz_remo_list.len }))); return ctxz.emit(facts.items); }
const bigs = (try bigsFind(ctxz)) orelse { try facts.append(ctxz.allo, cx.mkfa("snap", .bloc, "git absent")); return ctxz.emit(facts.items); };
const idxp = try std.fs.path.join(ctxz.allo, &.{ try ctxz.dirzData(), "wipz.idx" });
try std.Io.Dir.cwd().createDirPath(ctxz.iozz, try ctxz.dirzData());
const envp: []const runm.Envp = &.{.{ "GIT_INDEX_FILE", idxp }};
_ = (try ctxz.step(&facts, "seed", &.{ "git", "read-tree", "HEAD" }, envp)) orelse return ctxz.emit(facts.items);
_ = (try ctxz.step(&facts, "stag", &.{ "git", "add", "-A" }, envp)) orelse return ctxz.emit(facts.items);
if (bigs.len > 0) {
var argv: std.ArrayList([]const u8) = .empty;
try argv.appendSlice(ctxz.allo, &.{ "git", "rm", "--cached", "-q", "--ignore-unmatch", "--" });
try argv.appendSlice(ctxz.allo, bigs);
_ = (try ctxz.step(&facts, "bigx", argv.items, envp)) orelse return ctxz.emit(facts.items);
try facts.append(ctxz.allo, cx.mkfa("bigf", .drif, try std.fmt.allocPrint(ctxz.allo, "skipped {d} file(s) over {d} bytes: {s}", .{ bigs.len, ctxz.conf.wipz_file_maxz, cx.clip(try std.mem.join(ctxz.allo, ", ", bigs)) })));
}
const tree = (try ctxz.step(&facts, "tree", &.{ "git", "write-tree" }, envp)) orelse return ctxz.emit(facts.items);
const treh = cx.trim(tree.outz);
if (!shaOkay(treh)) { try facts.append(ctxz.allo, cx.mkfa("tree", .fail, "write-tree gave no sha")); return ctxz.emit(facts.items); }
var base: []const u8 = "HEAD";
const prev = (try ctxz.tool(&.{ "git", "rev-parse", "--verify", "-q", refz }, &.{})) orelse { try facts.append(ctxz.allo, cx.mkfa("prev", .bloc, "git absent")); return ctxz.emit(facts.items); };
if (prev.code == 0 and shaOkay(cx.trim(prev.outz))) {
base = cx.trim(prev.outz);
const ptre = (try ctxz.tool(&.{ "git", "rev-parse", try std.fmt.allocPrint(ctxz.allo, "{s}^{{tree}}", .{base}) }, &.{})) orelse { try facts.append(ctxz.allo, cx.mkfa("prev", .bloc, "git absent")); return ctxz.emit(facts.items); };
if (ptre.code == 0 and std.mem.eql(u8, cx.trim(ptre.outz), treh)) { try facts.append(ctxz.allo, cx.mkfa("snap", .skip, "same as the last snapshot")); return ctxz.emit(facts.items); }
}
const comi = (try ctxz.step(&facts, "comm", &.{ "git", "commit-tree", treh, "-p", base, "-m", "wipz" }, &.{})) orelse return ctxz.emit(facts.items);
const comh = cx.trim(comi.outz);
if (!shaOkay(comh)) { try facts.append(ctxz.allo, cx.mkfa("comm", .fail, "commit-tree gave no sha")); return ctxz.emit(facts.items); }
const logo = try std.fmt.allocPrint(ctxz.allo, "--log-opts={s}^!", .{comh});
const leakTxt = try std.fmt.allocPrint(ctxz.allo, "{d}", .{CF.leak});
const scan = (try ctxz.tool(&.{ "gitleaks", "git", "--redact", "--no-banner", "--exit-code", leakTxt, logo }, &.{})) orelse { try facts.append(ctxz.allo, cx.mkfa("scan", .bloc, "gitleaks absent: push aborted")); return ctxz.emit(facts.items); };
if (scan.code == CF.leak) {
try facts.append(ctxz.allo, cx.mkfa("scan", .fail, "LEAK found: git push skipped, copy goes to restic only"));
try heldSave(ctxz, &facts, comh, base);
return ctxz.emit(facts.items);
}
if (scan.code != 0) { try facts.append(ctxz.allo, cx.mkfa("scan", .fail, "gitleaks failed: push aborted")); return ctxz.emit(facts.items); }
try facts.append(ctxz.allo, cx.mkfa("scan", .okay, ""));
_ = (try ctxz.step(&facts, "refz", &.{ "git", "update-ref", refz, comh }, &.{})) orelse return ctxz.emit(facts.items);
var allp = true;
for (ctxz.conf.wipz_remo_list) |remo| {
const spec = try std.fmt.allocPrint(ctxz.allo, "{s}:{s}", .{ refz, refz });
if ((try ctxz.step(&facts, try std.fmt.allocPrint(ctxz.allo, "push {s}", .{remo}), &.{ "git", "push", remo, spec }, &.{})) == null) allp = false;
}
if (!allp) return ctxz.emit(facts.items);
const mark = try markName(ctxz.allo, ctxz.devi, ctxz.nowz());
const dayz = (try cx.stamTxt(ctxz.allo, ctxz.nowz()))[0..CF.daye];
const lamk = if (ctxz.stamGet("wipzd")) |stam| (try cx.stamTxt(ctxz.allo, stam.when))[0..CF.daye] else "";
if (!std.mem.eql(u8, dayz, lamk)) {
var markOk = (try ctxz.step(&facts, "mark", &.{ "git", "update-ref", mark, comh }, &.{})) != null;
if (markOk) for (ctxz.conf.wipz_remo_list) |remo| {
const spec = try std.fmt.allocPrint(ctxz.allo, "{s}:{s}", .{ mark, mark });
if ((try ctxz.step(&facts, try std.fmt.allocPrint(ctxz.allo, "mark {s}", .{remo}), &.{ "git", "push", remo, spec }, &.{})) == null) markOk = false;
};
if (markOk) try ctxz.stamPut("wipzd", .{ .when = ctxz.nowz(), .okay = true, .note = mark });
}
try ctxz.stamPut("wipz", .{ .when = ctxz.nowz(), .okay = true, .note = comh });
return ctxz.emit(facts.items);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
