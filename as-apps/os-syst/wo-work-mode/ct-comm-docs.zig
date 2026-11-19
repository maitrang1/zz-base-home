// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: wo docs: sync the git-ignored docs through a private docs repo
// Flo: init: hidden git dir > exclude all > remotes from the main repo > restore | sync: find docs > gitleaks > add > commit > fetch > rebase > push > stamp
// I/O: Ctxz + init|sync (dry-run default, --live acts) > facts, exit 0 ok / 1 failed / 4 blocked
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const fcts = @import("ob-fact-rept.zig");
const exit = @import("ct-exit-code.zig");
const runm = @import("ru-cmdz-runn.zig");
const bkup = @import("ct-comm-bkup.zig");
const CF = .{ .leak = 9, .base = "zz-base-home", .suff = "-docs", .bran = "main", .keyz = [_][]const u8{ "user.name", "user.email", "core.sshCommand" } };
pub fn urlMake(allo: std.mem.Allocator, url: []const u8) !?[]const u8 {
const indx = std.mem.lastIndexOf(u8, url, CF.base) orelse return null;
const tail = url[indx + CF.base.len ..];
if (std.mem.startsWith(u8, tail, CF.suff)) return url;
return try std.mem.concat(allo, u8, &.{ url[0 .. indx + CF.base.len], CF.suff, tail });
}
fn gitdPath(ctxz: *const cx.Ctxz) ![]u8 { return std.fs.path.join(ctxz.allo, &.{ ctxz.home, ctxz.conf.docs_gitd_name }); }
fn topFind(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact)) !?[]const u8 {
const topp = (try ctxz.tool(&.{ "git", "rev-parse", "--show-toplevel" }, &.{})) orelse { try facts.append(ctxz.allo, cx.mkfa("top", .bloc, "git absent")); return null; };
if (topp.code != 0) { try facts.append(ctxz.allo, cx.mkfa("top", .bloc, "not inside a git repo")); return null; }
return cx.trim(topp.outz);
}
fn envpMake(ctxz: *const cx.Ctxz, gitd: []const u8, top: []const u8) ![]const runm.Envp {
const envp = try ctxz.allo.alloc(runm.Envp, 2);
envp[0] = .{ "GIT_DIR", gitd };
envp[1] = .{ "GIT_WORK_TREE", top };
return envp;
}
fn gitdExist(ctxz: *const cx.Ctxz, gitd: []const u8) bool {
const head = std.fs.path.join(ctxz.allo, &.{ gitd, "HEAD" }) catch return false;
_ = std.Io.Dir.cwd().statFile(ctxz.iozz, head, .{}) catch return false;
return true;
}
fn initRun(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact)) !void {
const top = (try topFind(ctxz, facts)) orelse return;
const gitd = try gitdPath(ctxz);
if (gitdExist(ctxz, gitd)) { try facts.append(ctxz.allo, cx.mkfa("init", .skip, "docs git dir already exists")); return; }
if (ctxz.conf.docs_remo_list.len == 0) { try facts.append(ctxz.allo, cx.mkfa("remo", .bloc, "docs_remo_list is empty")); return; }
if (!ctxz.ladd.live) { try facts.append(ctxz.allo, cx.mkfa("init", .okay, try std.fmt.allocPrint(ctxz.allo, "dry-run: would create {s} with {d} remote(s) derived from the main repo", .{ gitd, ctxz.conf.docs_remo_list.len }))); return; }
_ = (try ctxz.step(facts, "bare", &.{ "git", "init", "--bare", "-q", gitd }, &.{})) orelse return;
_ = (try ctxz.step(facts, "head", &.{ "git", "--git-dir", gitd, "symbolic-ref", "HEAD", "refs/heads/" ++ CF.bran }, &.{})) orelse return;
const infd = try std.fs.path.join(ctxz.allo, &.{ gitd, "info" });
try std.Io.Dir.cwd().createDirPath(ctxz.iozz, infd);
try std.Io.Dir.cwd().writeFile(ctxz.iozz, .{ .sub_path = try std.fs.path.join(ctxz.allo, &.{ infd, "exclude" }), .data = "*\n" });
_ = (try ctxz.step(facts, "conf", &.{ "git", "--git-dir", gitd, "config", "core.autocrlf", "false" }, &.{})) orelse return;
for (CF.keyz) |keyz| {
const got = (try ctxz.tool(&.{ "git", "config", "--get", keyz }, &.{})) orelse continue;
const val = cx.trim(got.outz);
if (got.code != 0 or val.len == 0) continue;
_ = (try ctxz.step(facts, keyz, &.{ "git", "--git-dir", gitd, "config", keyz, val }, &.{})) orelse return;
}
for (ctxz.conf.docs_remo_list) |remo| {
const urlp = (try ctxz.tool(&.{ "git", "remote", "get-url", remo }, &.{})) orelse return;
if (urlp.code != 0) { try facts.append(ctxz.allo, cx.mkfa(remo, .drif, "no such remote in the main repo: skipped")); continue; }
const urld = (try urlMake(ctxz.allo, cx.trim(urlp.outz))) orelse { try facts.append(ctxz.allo, cx.mkfa(remo, .drif, "remote url has no repo name to derive from: skipped")); continue; };
_ = (try ctxz.step(facts, try std.fmt.allocPrint(ctxz.allo, "remo {s}", .{remo}), &.{ "git", "--git-dir", gitd, "remote", "add", remo, urld }, &.{})) orelse return;
}
const frst = ctxz.conf.docs_remo_list[0];
const lsrm = (try ctxz.tool(&.{ "git", "--git-dir", gitd, "ls-remote", "--exit-code", "--heads", frst, CF.bran }, &.{})) orelse return;
if (lsrm.code != 0) { try facts.append(ctxz.allo, cx.mkfa("rest", .skip, "remote has no docs yet: the first sync pushes them")); return; }
var scra: std.ArrayList(fcts.Fact) = .empty;
const have = (try bkup.docsFind(ctxz, &scra)) orelse return;
if (have.len > 0) { try facts.append(ctxz.allo, cx.mkfa("rest", .drif, "docs already on disk and the remote has docs: not overwritten, review then run sync")); return; }
_ = (try ctxz.step(facts, "fetz", &.{ "git", "--git-dir", gitd, "fetch", "-q", frst }, &.{})) orelse return;
const envp = try envpMake(ctxz, gitd, top);
_ = (try ctxz.step(facts, "rest", &.{ "git", "checkout", "-q", "-f", "-B", CF.bran, try std.fmt.allocPrint(ctxz.allo, "{s}/{s}", .{ frst, CF.bran }) }, envp)) orelse return;
}
fn syncRun(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact)) !void {
const top = (try topFind(ctxz, facts)) orelse return;
const gitd = try gitdPath(ctxz);
if (!gitdExist(ctxz, gitd)) { try facts.append(ctxz.allo, cx.mkfa("init", .bloc, "docs git dir missing: run wo docs init --live")); return; }
const pick = (try bkup.docsFind(ctxz, facts)) orelse return;
if (pick.len == 0) { try facts.append(ctxz.allo, cx.mkfa("docs", .skip, "no ignored docs found")); return; }
if (!ctxz.ladd.live) { try facts.append(ctxz.allo, cx.mkfa("sync", .okay, try std.fmt.allocPrint(ctxz.allo, "dry-run: would scan and commit {d} doc path(s), rebase, push to {d} remote(s)", .{ pick.len, ctxz.conf.docs_remo_list.len }))); return; }
for (pick) |path| {
const scan = (try ctxz.tool(&.{ "gitleaks", "dir", "--redact", "--no-banner", "--exit-code", "9", path }, &.{})) orelse { try facts.append(ctxz.allo, cx.mkfa("scan", .bloc, "gitleaks absent: docs sync stopped")); return; };
if (scan.code == CF.leak) { try facts.append(ctxz.allo, cx.mkfa("scan", .fail, try std.fmt.allocPrint(ctxz.allo, "LEAK in {s}: docs sync stopped, nothing staged", .{std.fs.path.basename(path)}))); return; }
if (scan.code != 0) { try facts.append(ctxz.allo, cx.mkfa("scan", .fail, "gitleaks failed: docs sync stopped")); return; }
}
try facts.append(ctxz.allo, cx.mkfa("scan", .okay, ""));
const envp = try envpMake(ctxz, gitd, top);
var argv: std.ArrayList([]const u8) = .empty;
try argv.appendSlice(ctxz.allo, &.{ "git", "add", "-f", "-A", "--" });
try argv.appendSlice(ctxz.allo, pick);
_ = (try ctxz.step(facts, "stag", argv.items, envp)) orelse return;
const diff = (try ctxz.tool(&.{ "git", "diff", "--cached", "--quiet" }, envp)) orelse return;
if (diff.code == 1) {
_ = (try ctxz.step(facts, "comm", &.{ "git", "-c", "commit.gpgsign=false", "commit", "-q", "-m", try std.fmt.allocPrint(ctxz.allo, "docs {s}", .{ctxz.devi}) }, envp)) orelse return;
} else if (diff.code != 0) { try facts.append(ctxz.allo, cx.mkfa("diff", .fail, "git diff failed")); return; }
for (ctxz.conf.docs_remo_list) |remo| {
_ = (try ctxz.step(facts, try std.fmt.allocPrint(ctxz.allo, "fetz {s}", .{remo}), &.{ "git", "fetch", "-q", remo }, envp)) orelse return;
const refm = try std.fmt.allocPrint(ctxz.allo, "refs/remotes/{s}/{s}", .{ remo, CF.bran });
const have = (try ctxz.tool(&.{ "git", "rev-parse", "--verify", "-q", refm }, envp)) orelse return;
if (have.code != 0) continue;
if ((try ctxz.step(facts, try std.fmt.allocPrint(ctxz.allo, "base {s}", .{remo}), &.{ "git", "rebase", "-q", refm }, envp)) == null) {
_ = try ctxz.tool(&.{ "git", "rebase", "--abort" }, envp);
try facts.append(ctxz.allo, cx.mkfa("rbas", .fail, "rebase conflict: aborted, both copies kept, fix by hand"));
return;
}
}
var allp = true;
for (ctxz.conf.docs_remo_list) |remo| {
if ((try ctxz.step(facts, try std.fmt.allocPrint(ctxz.allo, "push {s}", .{remo}), &.{ "git", "push", "-q", remo, "HEAD:refs/heads/" ++ CF.bran }, envp)) == null) allp = false;
}
if (allp) try ctxz.stamPut("docs", .{ .when = ctxz.nowz(), .okay = true, .note = gitd });
}
pub fn comm(ctxz: *const cx.Ctxz, args: []const []const u8) !exit.Code {
var init = false;
if (args.len != 1) return exit.Erro.Usag;
if (std.mem.eql(u8, args[0], "init")) init = true else if (!std.mem.eql(u8, args[0], "sync")) return exit.Erro.Usag;
var facts: std.ArrayList(fcts.Fact) = .empty;
if (init) try initRun(ctxz, &facts) else try syncRun(ctxz, &facts);
return ctxz.emit(facts.items);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
