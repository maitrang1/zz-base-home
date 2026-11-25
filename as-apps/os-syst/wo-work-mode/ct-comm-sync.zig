// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: wo sync: keep devices and remotes on one version
// Flo: gates > commit idle files (hooks scan) > fetch > merge each remote tip (ff, else merge, clash: newer edit wins, loser saved) > push > verify HEAD == every remote
// I/O: Ctxz (dry-run default, --live acts) > facts, exit 0 ok / 1 failed / 3 clash resolved / 4 blocked
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const fcts = @import("ob-fact-rept.zig");
const exit = @import("ct-exit-code.zig");
const merg = @import("ct-comm-merg.zig");
const runm = @import("ru-cmdz-runn.zig");
const CF = .{ .head = "auto", .dirz = 3, .undo = "refs/wo-sync/pre-", .busy = [_][]const u8{ "MERGE_HEAD", "rebase-merge", "rebase-apply", "CHERRY_PICK_HEAD", "index.lock" } };
const Mrg = enum { done, held, fail };
pub fn entrParse(allo: std.mem.Allocator, text: []const u8) ![]const []const u8 {
var out: std.ArrayList([]const u8) = .empty;
var iter = std.mem.splitScalar(u8, text, 0);
while (iter.next()) |tok| {
if (tok.len < 4) continue;
try out.append(allo, tok[3..]);
if (tok[0] == 'R' or tok[0] == 'C' or tok[1] == 'R' or tok[1] == 'C') { const from = iter.next() orelse continue; if (tok[0] == 'R' or tok[1] == 'R') try out.append(allo, from); }
}
return out.items;
}
pub fn mesg(allo: std.mem.Allocator, devi: []const u8, picks: []const []const u8) ![]u8 {
var tops: std.ArrayList([]const u8) = .empty;
for (picks) |item| {
const top = if (std.mem.indexOfScalar(u8, item, '/')) |at| item[0..at] else item;
var seen = false;
for (tops.items) |old| { if (std.mem.eql(u8, old, top)) seen = true; }
if (!seen and tops.items.len < CF.dirz) try tops.append(allo, top);
}
return std.fmt.allocPrint(allo, "{s}({s}): {d} file(s) · {s}", .{ CF.head, devi, picks.len, try std.mem.join(allo, ", ", tops.items) });
}
fn cat(allo: std.mem.Allocator, head: []const []const u8, tail: []const []const u8) ![]const []const u8 {
var out: std.ArrayList([]const u8) = .empty;
try out.appendSlice(allo, head);
try out.appendSlice(allo, tail);
return out.items;
}
fn denied(list: []const []const u8, path: []const u8) bool {
for (list) |pref| { if (std.mem.startsWith(u8, path, pref)) return true; }
return false;
}
fn okay(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact), name: []const u8, argv: []const []const u8) !bool { return (try ctxz.step(facts, name, argv, &.{})) != null; }
fn isAnc(ctxz: *const cx.Ctxz, one: []const u8, two: []const u8) bool {
const outp = (ctxz.tool(&.{ "git", "merge-base", "--is-ancestor", one, two }, &.{}) catch return false) orelse return false;
return outp.code == 0;
}
fn count(ctxz: *const cx.Ctxz, range: []const u8) ?u32 {
const outp = (ctxz.tool(&.{ "git", "rev-list", "--count", range }, &.{}) catch return null) orelse return null;
if (outp.code != 0) return null;
return std.fmt.parseInt(u32, cx.trim(outp.outz), 10) catch null;
}
fn revOf(ctxz: *const cx.Ctxz, rev: []const u8) []const u8 {
const outp = (ctxz.tool(&.{ "git", "rev-parse", rev }, &.{}) catch return "") orelse return "";
return cx.trim(outp.outz);
}
fn names(ctxz: *const cx.Ctxz, argv: []const []const u8) ![]const []const u8 {
const outp = (try ctxz.tool(argv, &.{})) orelse return &.{};
var out: std.ArrayList([]const u8) = .empty;
var lines = std.mem.splitScalar(u8, outp.outz, '\n');
while (lines.next()) |line| { const one = cx.trim(line); if (one.len > 0) try out.append(ctxz.allo, one); }
return out.items;
}
fn aside(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact), top: []const u8, ref: []const u8) !void {
const added = try names(ctxz, &.{ "git", "diff", "--name-only", "--diff-filter=A", try std.fmt.allocPrint(ctxz.allo, "HEAD...{s}", .{ref}) });
var dest: ?[]const u8 = null;
for (added) |path| {
const full = try std.fs.path.join(ctxz.allo, &.{ top, path });
const data = std.Io.Dir.cwd().readFileAlloc(ctxz.iozz, full, ctxz.allo, .limited(256 * 1024 * 1024)) catch continue;
const tracked = (try ctxz.tool(&.{ "git", "ls-files", "--", path }, &.{})) orelse continue;
if (cx.trim(tracked.outz).len > 0) continue;
if (dest == null) dest = try std.fs.path.join(ctxz.allo, &.{ top, merg.CF.tras, try std.fmt.allocPrint(ctxz.allo, "_code-{s}", .{try cx.stamTxt(ctxz.allo, ctxz.nowz())}) });
const saved = try std.fs.path.join(ctxz.allo, &.{ dest.?, path });
if (std.fs.path.dirname(saved)) |dirz| try std.Io.Dir.cwd().createDirPath(ctxz.iozz, dirz);
try std.Io.Dir.cwd().writeFile(ctxz.iozz, .{ .sub_path = saved, .data = data });
try facts.append(ctxz.allo, cx.mkfa("keep", .drif, try std.fmt.allocPrint(ctxz.allo, "local {s} would be overwritten: copy saved in {s}", .{ path, dest.? })));
}
}
fn mergeIn(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact), top: []const u8, gitd: []const u8, ref: []const u8, rest: []const []const u8) !Mrg {
if (isAnc(ctxz, ref, "HEAD")) return .done;
const inco = try names(ctxz, &.{ "git", "diff", "--name-only", try std.fmt.allocPrint(ctxz.allo, "HEAD...{s}", .{ref}) });
for (inco) |name| { for (rest) |item| { if (std.mem.eql(u8, name, item)) { try facts.append(ctxz.allo, cx.mkfa("held", .skip, try std.fmt.allocPrint(ctxz.allo, "{s} is being edited and {s} changes it: retry next cycle", .{ item, ref }))); return .held; } } }
try aside(ctxz, facts, top, ref);
_ = try ctxz.tool(&.{ "git", "update-ref", try std.fmt.allocPrint(ctxz.allo, "{s}{s}", .{ CF.undo, ctxz.devi }), "HEAD" }, &.{});
if (isAnc(ctxz, "HEAD", ref)) return if (try okay(ctxz, facts, "ffwd", &.{ "git", "merge", "--ff-only", "-q", ref })) .done else .fail;
const mrg = (try ctxz.tool(&.{ "git", "-c", "commit.gpgsign=false", "merge", "--no-edit", "-q", ref }, &.{})) orelse { try facts.append(ctxz.allo, cx.mkfa("merg", .bloc, "git absent")); return .fail; };
if (mrg.code == 0) return .done;
if (try merg.mergeFix(ctxz, facts, &.{}, gitd, top, ref, "code", .drif)) return .done;
_ = try ctxz.tool(&.{ "git", "merge", "--abort" }, &.{});
try facts.append(ctxz.allo, cx.mkfa("merg", .fail, try std.fmt.allocPrint(ctxz.allo, "merge with {s} failed and was aborted, nothing lost: {s}", .{ ref, cx.clip(cx.trim(mrg.errz)) })));
return .fail;
}
fn cycle(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact), top: []const u8, gitd: []const u8, refs: []const []const u8, rest: []const []const u8) !Mrg {
const conf = ctxz.conf;
for (conf.sync_remo_list) |remo| { if (!try okay(ctxz, facts, remo, &.{ "git", "fetch", remo, conf.sync_bran_main })) return .fail; }
for (refs) |ref| {
const got = try mergeIn(ctxz, facts, top, gitd, ref, rest);
if (got != .done) return got;
}
var good = true;
for (conf.sync_remo_list, 0..) |remo, indx| {
const need = count(ctxz, try std.fmt.allocPrint(ctxz.allo, "{s}..HEAD", .{refs[indx]})) orelse 1;
if (need == 0) continue;
if (!try okay(ctxz, facts, remo, &.{ "git", "push", remo, conf.sync_bran_main })) good = false;
}
if (!good) return .fail;
const head = revOf(ctxz, "HEAD");
for (refs) |ref| {
if (!std.mem.eql(u8, revOf(ctxz, ref), head)) { try facts.append(ctxz.allo, cx.mkfa("equa", .fail, try std.fmt.allocPrint(ctxz.allo, "{s} is not at HEAD after the push", .{ref}))); return .fail; }
}
return .done;
}
pub fn comm(ctxz: *const cx.Ctxz, args: []const []const u8) !exit.Code {
if (args.len != 0) return exit.Erro.Usag;
const conf = ctxz.conf;
var facts: std.ArrayList(fcts.Fact) = .empty;
const topp = (try ctxz.tool(&.{ "git", "rev-parse", "--show-toplevel" }, &.{})) orelse { try facts.append(ctxz.allo, cx.mkfa("top", .bloc, "git absent")); return ctxz.emit(facts.items); };
if (topp.code != 0) { try facts.append(ctxz.allo, cx.mkfa("top", .bloc, "not inside a git repo")); return ctxz.emit(facts.items); }
const root = cx.trim(topp.outz);
const bran = (try ctxz.step(&facts, "bran", &.{ "git", "rev-parse", "--abbrev-ref", "HEAD" }, &.{})) orelse return ctxz.emit(facts.items);
if (!std.mem.eql(u8, cx.trim(bran.outz), conf.sync_bran_main)) { try facts.append(ctxz.allo, cx.mkfa("bran", .bloc, try std.fmt.allocPrint(ctxz.allo, "on {s}, not {s}", .{ cx.trim(bran.outz), conf.sync_bran_main }))); return ctxz.emit(facts.items); }
const gitp = (try ctxz.step(&facts, "gitd", &.{ "git", "rev-parse", "--absolute-git-dir" }, &.{})) orelse return ctxz.emit(facts.items);
const gitd = cx.trim(gitp.outz);
for (CF.busy) |name| {
const path = try std.fs.path.join(ctxz.allo, &.{ gitd, name });
if (std.Io.Dir.cwd().statFile(ctxz.iozz, path, .{})) |_| { try facts.append(ctxz.allo, cx.mkfa("busy", .bloc, try std.fmt.allocPrint(ctxz.allo, "git is busy: {s}", .{name}))); return ctxz.emit(facts.items); } else |_| {}
}
const stat = (try ctxz.step(&facts, "stat", &.{ "git", "status", "--porcelain=v1", "-z", "--untracked-files=all" }, &.{})) orelse return ctxz.emit(facts.items);
const entr = try entrParse(ctxz.allo, stat.outz);
var picks: std.ArrayList([]const u8) = .empty;
var rest: std.ArrayList([]const u8) = .empty;
var bigs: std.ArrayList([]const u8) = .empty;
var held: u32 = 0;
var gone: std.ArrayList([]const u8) = .empty;
var edit: i64 = 0;
for (entr) |path| {
if (denied(conf.sync_deny_list, path)) { try rest.append(ctxz.allo, path); continue; }
const full = try std.fs.path.join(ctxz.allo, &.{ root, path });
const info = std.Io.Dir.cwd().statFile(ctxz.iozz, full, .{}) catch { try picks.append(ctxz.allo, path); try gone.append(ctxz.allo, path); continue; };
if (info.size > conf.sync_file_maxz) { try bigs.append(ctxz.allo, path); try rest.append(ctxz.allo, path); continue; }
if (ctxz.nowz() - info.mtime.toSeconds() < conf.sync_quie_secz) { held += 1; try rest.append(ctxz.allo, path); continue; }
edit = @max(edit, info.mtime.toSeconds());
try picks.append(ctxz.allo, path);
}
if (bigs.items.len > 0) try facts.append(ctxz.allo, cx.mkfa("bigf", .drif, try std.fmt.allocPrint(ctxz.allo, "{d} file(s) over {d} bytes kept out, never published: {s}", .{ bigs.items.len, conf.sync_file_maxz, cx.clip(try std.mem.join(ctxz.allo, ", ", bigs.items)) })));
if (picks.items.len > conf.sync_file_cntz) { try facts.append(ctxz.allo, cx.mkfa("many", .bloc, try std.fmt.allocPrint(ctxz.allo, "{d} files to commit, limit {d}: commit by hand", .{ picks.items.len, conf.sync_file_cntz }))); return ctxz.emit(facts.items); }
const note = try std.fmt.allocPrint(ctxz.allo, "{d} to commit, {d} held (edited in the last {d}s), {d} kept out", .{ picks.items.len, held, conf.sync_quie_secz, rest.items.len - held });
if (!ctxz.ladd.live) { try facts.append(ctxz.allo, cx.mkfa("sync", .okay, try std.fmt.allocPrint(ctxz.allo, "dry-run: {s}", .{note}))); return ctxz.emit(facts.items); }
if (conf.sync_remo_list.len == 0) { try facts.append(ctxz.allo, cx.mkfa("remo", .bloc, "sync_remo_list is empty")); return ctxz.emit(facts.items); }
if (picks.items.len > 0) {
const msg = try mesg(ctxz.allo, ctxz.devi, picks.items);
var live: std.ArrayList([]const u8) = .empty;
for (picks.items) |item| {
var isgone = false;
for (gone.items) |old| { if (std.mem.eql(u8, old, item)) isgone = true; }
if (!isgone) try live.append(ctxz.allo, item);
}
if (live.items.len > 0 and !try okay(ctxz, &facts, "add", try cat(ctxz.allo, &.{ "git", "add", "-A", "--" }, live.items))) return ctxz.emit(facts.items);
if (gone.items.len > 0 and !try okay(ctxz, &facts, "drop", try cat(ctxz.allo, &.{ "git", "rm", "--cached", "--ignore-unmatch", "-q", "--" }, gone.items))) return ctxz.emit(facts.items);
const when = if (edit > 0 and edit <= ctxz.nowz() + merg.CF.futz) edit else ctxz.nowz();
const envc = try ctxz.allo.alloc(runm.Envp, 1);
envc[0] = .{ "GIT_AUTHOR_DATE", try std.fmt.allocPrint(ctxz.allo, "{d} +0000", .{when}) };
if ((try ctxz.step(&facts, "comm", try cat(ctxz.allo, &.{ "git", "-c", "commit.gpgsign=false", "commit", "-q", "-m", msg, "--" }, picks.items), envc)) == null) { _ = try ctxz.tool(try cat(ctxz.allo, &.{ "git", "reset", "-q", "--" }, picks.items), &.{}); return ctxz.emit(facts.items); }
}
var refs: std.ArrayList([]const u8) = .empty;
for (conf.sync_remo_list) |remo| try refs.append(ctxz.allo, try std.fmt.allocPrint(ctxz.allo, "{s}/{s}", .{ remo, conf.sync_bran_main }));
var attempt: u32 = 0;
var got: Mrg = .fail;
while (attempt < conf.sync_tryz_maxz and got == .fail) : (attempt += 1) {
var tries: std.ArrayList(fcts.Fact) = .empty;
got = try cycle(ctxz, &tries, root, gitd, refs.items, rest.items);
if (got != .fail or attempt + 1 >= conf.sync_tryz_maxz) try facts.appendSlice(ctxz.allo, tries.items);
}
if (got == .done) { try ctxz.stamPut("sync", .{ .when = ctxz.nowz(), .okay = true, .note = note }); try facts.append(ctxz.allo, cx.mkfa("sync", .okay, try std.fmt.allocPrint(ctxz.allo, "all devices on one version: {s}", .{note}))); }
return ctxz.emit(facts.items);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
