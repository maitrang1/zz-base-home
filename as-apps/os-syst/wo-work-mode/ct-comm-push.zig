// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: wo push: commit the idle changed files and push main to every remote
// Flo: gates (branch, git busy, size, count, quiet window) > add + commit (hooks scan) > fetch > remotes diverged? > rebase only if behind > push each remote (retry) > stamp
// I/O: Ctxz (dry-run default, --live acts) > facts, exit 0 ok / 1 failed / 4 blocked
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const fcts = @import("ob-fact-rept.zig");
const exit = @import("ct-exit-code.zig");
const CF = .{ .head = "auto", .dirz = 3, .busy = [_][]const u8{ "MERGE_HEAD", "rebase-merge", "rebase-apply", "CHERRY_PICK_HEAD", "index.lock" } };
pub fn entrParse(allo: std.mem.Allocator, text: []const u8) ![]const []const u8 {
var out: std.ArrayList([]const u8) = .empty;
var iter = std.mem.splitScalar(u8, text, 0);
while (iter.next()) |tok| {
if (tok.len < 4) continue;
try out.append(allo, tok[3..]);
if (tok[0] == 'R' or tok[0] == 'C' or tok[1] == 'R' or tok[1] == 'C') _ = iter.next();
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
fn bestRef(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact), refs: []const []const u8) !?[]const u8 {
var best: usize = 0;
for (refs[1..], 1..) |ref, indx| {
if (isAnc(ctxz, refs[best], ref)) best = indx else if (!isAnc(ctxz, ref, refs[best])) { try facts.append(ctxz.allo, cx.mkfa("dive", .fail, try std.fmt.allocPrint(ctxz.allo, "{s} and {s} diverged: fix by hand", .{ refs[best], ref }))); return null; }
}
return refs[best];
}
fn overlap(ctxz: *const cx.Ctxz, best: []const u8, rest: []const []const u8) !?[]const u8 {
const outp = (try ctxz.tool(&.{ "git", "diff", "--name-only", "HEAD", best }, &.{})) orelse return null;
var lines = std.mem.splitScalar(u8, outp.outz, '\n');
while (lines.next()) |line| {
const name = cx.trim(line);
for (rest) |item| { if (name.len > 0 and std.mem.eql(u8, name, item)) return item; }
}
return null;
}
fn syncOne(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact), refs: []const []const u8, rest: []const []const u8) !bool {
const conf = ctxz.conf;
for (conf.push_remo_list) |remo| { if (!try okay(ctxz, facts, remo, &.{ "git", "fetch", remo, conf.push_bran_main })) return false; }
const best = (try bestRef(ctxz, facts, refs)) orelse return false;
const lead = count(ctxz, try std.fmt.allocPrint(ctxz.allo, "{s}..HEAD", .{best})) orelse 0;
const lagz = count(ctxz, try std.fmt.allocPrint(ctxz.allo, "HEAD..{s}", .{best})) orelse 0;
if (lagz > 0 and lead == 0) { try facts.append(ctxz.allo, cx.mkfa("sync", .skip, try std.fmt.allocPrint(ctxz.allo, "behind {s} by {d}: pull by hand", .{ best, lagz }))); return true; }
if (lagz > 0) {
if (try overlap(ctxz, best, rest)) |item| { try facts.append(ctxz.allo, cx.mkfa("sync", .fail, try std.fmt.allocPrint(ctxz.allo, "incoming change touches {s}, which is being edited: sync by hand", .{item}))); return false; }
if (!try okay(ctxz, facts, "rbas", &.{ "git", "rebase", "--autostash", best })) { _ = try ctxz.tool(&.{ "git", "rebase", "--abort" }, &.{}); return false; }
}
var good = true;
for (conf.push_remo_list, 0..) |remo, indx| {
const need = count(ctxz, try std.fmt.allocPrint(ctxz.allo, "{s}..HEAD", .{refs[indx]})) orelse 1;
if (need == 0) continue;
if (!try okay(ctxz, facts, remo, &.{ "git", "push", remo, conf.push_bran_main })) good = false;
}
return good;
}
pub fn comm(ctxz: *const cx.Ctxz, args: []const []const u8) !exit.Code {
if (args.len != 0) return exit.Erro.Usag;
const conf = ctxz.conf;
var facts: std.ArrayList(fcts.Fact) = .empty;
const topp = (try ctxz.tool(&.{ "git", "rev-parse", "--show-toplevel" }, &.{})) orelse { try facts.append(ctxz.allo, cx.mkfa("top", .bloc, "git absent")); return ctxz.emit(facts.items); };
if (topp.code != 0) { try facts.append(ctxz.allo, cx.mkfa("top", .bloc, "not inside a git repo")); return ctxz.emit(facts.items); }
const root = cx.trim(topp.outz);
const bran = (try ctxz.step(&facts, "bran", &.{ "git", "rev-parse", "--abbrev-ref", "HEAD" }, &.{})) orelse return ctxz.emit(facts.items);
if (!std.mem.eql(u8, cx.trim(bran.outz), conf.push_bran_main)) { try facts.append(ctxz.allo, cx.mkfa("bran", .bloc, try std.fmt.allocPrint(ctxz.allo, "on {s}, not {s}", .{ cx.trim(bran.outz), conf.push_bran_main }))); return ctxz.emit(facts.items); }
const gitd = (try ctxz.step(&facts, "gitd", &.{ "git", "rev-parse", "--absolute-git-dir" }, &.{})) orelse return ctxz.emit(facts.items);
for (CF.busy) |name| {
const path = try std.fs.path.join(ctxz.allo, &.{ cx.trim(gitd.outz), name });
if (std.Io.Dir.cwd().statFile(ctxz.iozz, path, .{})) |_| { try facts.append(ctxz.allo, cx.mkfa("busy", .bloc, try std.fmt.allocPrint(ctxz.allo, "git is busy: {s}", .{name}))); return ctxz.emit(facts.items); } else |_| {}
}
const stat = (try ctxz.step(&facts, "stat", &.{ "git", "status", "--porcelain=v1", "-z", "--untracked-files=all" }, &.{})) orelse return ctxz.emit(facts.items);
const entr = try entrParse(ctxz.allo, stat.outz);
var picks: std.ArrayList([]const u8) = .empty;
var rest: std.ArrayList([]const u8) = .empty;
var bigs: std.ArrayList([]const u8) = .empty;
var held: u32 = 0;
for (entr) |path| {
if (denied(conf.push_deny_list, path)) { try rest.append(ctxz.allo, path); continue; }
const full = try std.fs.path.join(ctxz.allo, &.{ root, path });
const info = std.Io.Dir.cwd().statFile(ctxz.iozz, full, .{}) catch { try picks.append(ctxz.allo, path); continue; };
if (info.size > conf.push_file_maxz) { try bigs.append(ctxz.allo, path); continue; }
if (ctxz.nowz() - info.mtime.toSeconds() < conf.push_quie_secz) { held += 1; try rest.append(ctxz.allo, path); continue; }
try picks.append(ctxz.allo, path);
}
if (bigs.items.len > 0) { try facts.append(ctxz.allo, cx.mkfa("bigf", .bloc, try std.fmt.allocPrint(ctxz.allo, "{d} file(s) over {d} bytes: {s}", .{ bigs.items.len, conf.push_file_maxz, cx.clip(try std.mem.join(ctxz.allo, ", ", bigs.items)) }))); return ctxz.emit(facts.items); }
if (picks.items.len > conf.push_file_cntz) { try facts.append(ctxz.allo, cx.mkfa("many", .bloc, try std.fmt.allocPrint(ctxz.allo, "{d} files to commit, limit {d}: commit by hand", .{ picks.items.len, conf.push_file_cntz }))); return ctxz.emit(facts.items); }
const note = try std.fmt.allocPrint(ctxz.allo, "{d} to commit, {d} held (edited in the last {d}s), {d} kept out", .{ picks.items.len, held, conf.push_quie_secz, rest.items.len - held });
if (!ctxz.ladd.live) { try facts.append(ctxz.allo, cx.mkfa("push", .okay, try std.fmt.allocPrint(ctxz.allo, "dry-run: {s}", .{note}))); return ctxz.emit(facts.items); }
if (picks.items.len > 0) {
const msg = try mesg(ctxz.allo, ctxz.devi, picks.items);
const addv = try cat(ctxz.allo, &.{ "git", "add", "-A", "--" }, picks.items);
if (!try okay(ctxz, &facts, "add", addv)) return ctxz.emit(facts.items);
const comv = try cat(ctxz.allo, &.{ "git", "-c", "commit.gpgsign=false", "commit", "-q", "-m", msg, "--" }, picks.items);
if (!try okay(ctxz, &facts, "comm", comv)) { _ = try ctxz.tool(try cat(ctxz.allo, &.{ "git", "reset", "-q", "--" }, picks.items), &.{}); return ctxz.emit(facts.items); }
}
var refs: std.ArrayList([]const u8) = .empty;
for (conf.push_remo_list) |remo| try refs.append(ctxz.allo, try std.fmt.allocPrint(ctxz.allo, "{s}/{s}", .{ remo, conf.push_bran_main }));
if (refs.items.len == 0) { try facts.append(ctxz.allo, cx.mkfa("remo", .bloc, "push_remo_list is empty")); return ctxz.emit(facts.items); }
var attempt: u32 = 0;
var done = false;
while (attempt < conf.push_tryz_maxz and !done) : (attempt += 1) {
var tries: std.ArrayList(fcts.Fact) = .empty;
done = try syncOne(ctxz, &tries, refs.items, rest.items);
if (done or attempt + 1 >= conf.push_tryz_maxz) try facts.appendSlice(ctxz.allo, tries.items);
}
if (done) { try ctxz.stamPut("push", .{ .when = ctxz.nowz(), .okay = true, .note = note }); try facts.append(ctxz.allo, cx.mkfa("push", .okay, note)); }
return ctxz.emit(facts.items);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
