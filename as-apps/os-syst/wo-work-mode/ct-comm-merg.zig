// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Merge helpers for wo-work-mode docs and sync: one winner
// Flo: unmerged files > newer edit wins (author date) > loser restored under zz-dele-auto > checkout winner > commit
// I/O: Ctxz + git env > facts, true when every clash was resolved and committed
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const fcts = @import("ob-fact-rept.zig");
const runm = @import("ru-cmdz-runn.zig");
pub const CF = .{ .futz = 300, .tras = "zz-dele-auto" };
pub fn splitNul(allo: std.mem.Allocator, text: []const u8) ![]const []const u8 {
var outz: std.ArrayList([]const u8) = .empty;
var iter = std.mem.splitScalar(u8, text, 0);
while (iter.next()) |item| { if (item.len > 0) try outz.append(allo, item); }
return outz.items;
}
pub fn editTime(ctxz: *const cx.Ctxz, envp: []const runm.Envp, rev: []const u8, file: []const u8) i64 {
const outp = (ctxz.tool(&.{ "git", "log", "-1", "--format=%at", rev, "--", file }, envp) catch return 0) orelse return 0;
const valz = std.fmt.parseInt(i64, cx.trim(outp.outz), 10) catch return 0;
const nowz = ctxz.nowz();
return if (valz > nowz + CF.futz) nowz else valz;
}
pub fn hasFile(ctxz: *const cx.Ctxz, envp: []const runm.Envp, rev: []const u8, file: []const u8) bool {
const spec = std.fmt.allocPrint(ctxz.allo, "{s}:{s}", .{ rev, file }) catch return false;
const outp = (ctxz.tool(&.{ "git", "cat-file", "-e", spec }, envp) catch return false) orelse return false;
return outp.code == 0;
}
pub fn mergeFix(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact), envp: []const runm.Envp, gitd: []const u8, top: []const u8, refm: []const u8, tag: []const u8, stav: fcts.Stat) !bool {
const unm = (try ctxz.tool(&.{ "git", "diff", "--name-only", "--diff-filter=U", "-z" }, envp)) orelse return false;
const files = try splitNul(ctxz.allo, unm.outz);
if (files.len == 0) return false;
const stmp = try cx.stamTxt(ctxz.allo, ctxz.nowz());
const dest = try std.fs.path.join(ctxz.allo, &.{ top, CF.tras, try std.fmt.allocPrint(ctxz.allo, "_{s}-{s}", .{ tag, stmp }) });
try std.Io.Dir.cwd().createDirPath(ctxz.iozz, dest);
const envd = try ctxz.allo.alloc(runm.Envp, 2);
envd[0] = .{ "GIT_DIR", gitd };
envd[1] = .{ "GIT_WORK_TREE", dest };
for (files) |file| {
const lok = hasFile(ctxz, envp, "HEAD", file);
const rok = hasFile(ctxz, envp, refm, file);
const ours = if (!lok and rok) false else if (lok and !rok) true else editTime(ctxz, envp, "HEAD", file) > editTime(ctxz, envp, refm, file);
if (if (ours) rok else lok) {
const saved = try std.fs.path.join(ctxz.allo, &.{ dest, file });
const rest = (try ctxz.tool(&.{ "git", "restore", "--source", if (ours) refm else "HEAD", "--worktree", "--", saved }, envd)) orelse return false;
if (rest.code != 0) return false;
_ = std.Io.Dir.cwd().statFile(ctxz.iozz, saved, .{}) catch return false;
}
const path = try std.fs.path.join(ctxz.allo, &.{ top, file });
const chk = (try ctxz.tool(&.{ "git", "checkout", if (ours) "--ours" else "--theirs", "--", path }, envp)) orelse return false;
if (chk.code != 0) return false;
const add = (try ctxz.tool(&.{ "git", "add", "-f", "--", path }, envp)) orelse return false;
if (add.code != 0) return false;
}
const fin = (try ctxz.tool(&.{ "git", "-c", "commit.gpgsign=false", "commit", "--no-edit", "-q" }, envp)) orelse return false;
if (fin.code != 0) return false;
try facts.append(ctxz.allo, cx.mkfa("conf", stav, try std.fmt.allocPrint(ctxz.allo, "resolved {d} file(s): the newer edit wins, losers saved in {s}/_{s}-{s}: {s}", .{ files.len, CF.tras, tag, stmp, cx.clip(try std.mem.join(ctxz.allo, ", ", files)) })));
return true;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
