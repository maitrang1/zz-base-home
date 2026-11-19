// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: wo docs: sync the git-ignored docs through a private docs repo
// Flo: init: hidden git dir > exclude all > remotes from the main repo > restore | sync: stage docs > scan changed files > commit (author date = edit time) > fetch + merge (newer edit wins a clash, loser saved aside) > push, retry > stamp
// I/O: Ctxz + init|sync (dry-run default, --live acts) > facts, exit 0 ok / 1 failed / 4 blocked
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const fcts = @import("ob-fact-rept.zig");
const exit = @import("ct-exit-code.zig");
const runm = @import("ru-cmdz-runn.zig");
const bkup = @import("ct-comm-bkup.zig");
const CF = .{ .leak = 9, .tryz = 3, .futz = 300, .tras = "zz-dele-auto", .base = "zz-base-home", .suff = "-docs", .bran = "main", .keyz = [_][]const u8{ "user.name", "user.email", "core.sshCommand" } };
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
if (lsrm.code == 2) { try facts.append(ctxz.allo, cx.mkfa("rest", .skip, "remote has no docs yet: the first sync pushes them")); return; }
if (lsrm.code != 0) { try facts.append(ctxz.allo, cx.mkfa("rest", .fail, try std.fmt.allocPrint(ctxz.allo, "cannot reach {s}: {s}", .{ frst, cx.clip(cx.trim(lsrm.errz)) }))); return; }
var scra: std.ArrayList(fcts.Fact) = .empty;
const have = (try bkup.docsFind(ctxz, &scra)) orelse return;
if (have.len > 0) { try facts.append(ctxz.allo, cx.mkfa("rest", .drif, "docs already on disk and the remote has docs: not overwritten, review then run sync")); return; }
_ = (try ctxz.step(facts, "fetz", &.{ "git", "--git-dir", gitd, "fetch", "-q", frst }, &.{})) orelse return;
const envp = try envpMake(ctxz, gitd, top);
_ = (try ctxz.step(facts, "rest", &.{ "git", "checkout", "-q", "-f", "-B", CF.bran, try std.fmt.allocPrint(ctxz.allo, "{s}/{s}", .{ frst, CF.bran }) }, envp)) orelse return;
}
fn splitNul(allo: std.mem.Allocator, text: []const u8) ![]const []const u8 {
var outz: std.ArrayList([]const u8) = .empty;
var iter = std.mem.splitScalar(u8, text, 0);
while (iter.next()) |item| { if (item.len > 0) try outz.append(allo, item); }
return outz.items;
}
fn editTime(ctxz: *const cx.Ctxz, envp: []const runm.Envp, rev: []const u8, file: []const u8) i64 {
const outp = (ctxz.tool(&.{ "git", "log", "-1", "--format=%at", rev, "--", file }, envp) catch return 0) orelse return 0;
const valz = std.fmt.parseInt(i64, cx.trim(outp.outz), 10) catch return 0;
const nowz = ctxz.nowz();
return if (valz > nowz + CF.futz) nowz else valz;
}
fn hasFile(ctxz: *const cx.Ctxz, envp: []const runm.Envp, rev: []const u8, file: []const u8) bool {
const spec = std.fmt.allocPrint(ctxz.allo, "{s}:{s}", .{ rev, file }) catch return false;
const outp = (ctxz.tool(&.{ "git", "cat-file", "-e", spec }, envp) catch return false) orelse return false;
return outp.code == 0;
}
fn mergeFix(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact), envp: []const runm.Envp, gitd: []const u8, top: []const u8, refm: []const u8) !bool {
const unm = (try ctxz.tool(&.{ "git", "diff", "--name-only", "--diff-filter=U", "-z" }, envp)) orelse return false;
const files = try splitNul(ctxz.allo, unm.outz);
if (files.len == 0) return false;
const stmp = try cx.stamTxt(ctxz.allo, ctxz.nowz());
const dest = try std.fs.path.join(ctxz.allo, &.{ top, CF.tras, try std.fmt.allocPrint(ctxz.allo, "_docs-{s}", .{stmp}) });
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
try facts.append(ctxz.allo, cx.mkfa("conf", .okay, try std.fmt.allocPrint(ctxz.allo, "resolved {d} file(s): the newer edit wins, losers saved in {s}/_docs-{s}", .{ files.len, CF.tras, stmp })));
return true;
}
fn mergeAll(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact), envp: []const runm.Envp, gitd: []const u8, top: []const u8) !bool {
for (ctxz.conf.docs_remo_list) |remo| {
const fetz = (try ctxz.tool(&.{ "git", "fetch", "-q", remo }, envp)) orelse { try facts.append(ctxz.allo, cx.mkfa("fetz", .bloc, "git absent")); return false; };
if (fetz.code != 0) { try facts.append(ctxz.allo, cx.mkfa(try std.fmt.allocPrint(ctxz.allo, "fetz {s}", .{remo}), .fail, try std.fmt.allocPrint(ctxz.allo, "exit {d}: {s}", .{ fetz.code, cx.clip(cx.trim(fetz.errz)) }))); return false; }
const refm = try std.fmt.allocPrint(ctxz.allo, "refs/remotes/{s}/{s}", .{ remo, CF.bran });
const have = (try ctxz.tool(&.{ "git", "rev-parse", "--verify", "-q", refm }, envp)) orelse return false;
if (have.code != 0) continue;
const mrge = (try ctxz.tool(&.{ "git", "-c", "commit.gpgsign=false", "merge", "--no-edit", "-q", refm }, envp)) orelse return false;
if (mrge.code == 0) continue;
if (!(try mergeFix(ctxz, facts, envp, gitd, top, refm))) {
_ = try ctxz.tool(&.{ "git", "merge", "--abort" }, envp);
try facts.append(ctxz.allo, cx.mkfa("merg", .fail, try std.fmt.allocPrint(ctxz.allo, "merge with {s} failed and was aborted, nothing lost: {s}", .{ remo, cx.clip(cx.trim(mrge.errz)) })));
return false;
}
}
return true;
}
fn syncRun(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact)) !void {
const top = (try topFind(ctxz, facts)) orelse return;
const gitd = try gitdPath(ctxz);
if (!gitdExist(ctxz, gitd)) { try facts.append(ctxz.allo, cx.mkfa("init", .bloc, "docs git dir missing: run wo docs init --live")); return; }
const pick = (try bkup.docsFind(ctxz, facts)) orelse return;
if (pick.len == 0) { try facts.append(ctxz.allo, cx.mkfa("docs", .skip, "no ignored docs found")); return; }
if (!ctxz.ladd.live) { try facts.append(ctxz.allo, cx.mkfa("sync", .okay, try std.fmt.allocPrint(ctxz.allo, "dry-run: would sync {d} doc path(s): stage, scan the changed files, commit, merge, push to {d} remote(s)", .{ pick.len, ctxz.conf.docs_remo_list.len }))); return; }
const envp = try envpMake(ctxz, gitd, top);
var argv: std.ArrayList([]const u8) = .empty;
try argv.appendSlice(ctxz.allo, &.{ "git", "add", "-f", "-A", "--" });
try argv.appendSlice(ctxz.allo, pick);
_ = (try ctxz.step(facts, "stag", argv.items, envp)) orelse return;
const chg = (try ctxz.tool(&.{ "git", "diff", "--cached", "--name-only", "-z" }, envp)) orelse return;
if (chg.code != 0) { try facts.append(ctxz.allo, cx.mkfa("diff", .fail, "git diff failed")); return; }
const files = try splitNul(ctxz.allo, chg.outz);
if (files.len > 0) {
var edit: i64 = 0;
for (files) |file| {
const path = try std.fs.path.join(ctxz.allo, &.{ top, file });
const info = std.Io.Dir.cwd().statFile(ctxz.iozz, path, .{}) catch continue;
const scan = (try ctxz.tool(&.{ "gitleaks", "dir", "--redact", "--no-banner", "--exit-code", "9", path }, &.{})) orelse { _ = try ctxz.tool(&.{ "git", "reset", "-q" }, envp); try facts.append(ctxz.allo, cx.mkfa("scan", .bloc, "gitleaks absent: docs sync stopped, nothing committed")); return; };
if (scan.code != 0) {
_ = try ctxz.tool(&.{ "git", "reset", "-q" }, envp);
try facts.append(ctxz.allo, cx.mkfa("scan", .fail, if (scan.code == CF.leak) try std.fmt.allocPrint(ctxz.allo, "LEAK in {s}: docs sync stopped, nothing committed", .{std.fs.path.basename(path)}) else "gitleaks failed: docs sync stopped, nothing committed"));
return;
}
edit = @max(edit, info.mtime.toSeconds());
}
try facts.append(ctxz.allo, cx.mkfa("scan", .okay, try std.fmt.allocPrint(ctxz.allo, "{d} changed file(s) clean", .{files.len})));
const nowz = ctxz.nowz();
const when = if (edit > 0 and edit <= nowz + CF.futz) edit else nowz;
const envc = try ctxz.allo.alloc(runm.Envp, 3);
envc[0] = envp[0];
envc[1] = envp[1];
envc[2] = .{ "GIT_AUTHOR_DATE", try std.fmt.allocPrint(ctxz.allo, "{d} +0000", .{when}) };
_ = (try ctxz.step(facts, "comm", &.{ "git", "-c", "commit.gpgsign=false", "commit", "-q", "-m", try std.fmt.allocPrint(ctxz.allo, "docs {s}", .{ctxz.devi}) }, envc)) orelse return;
} else try facts.append(ctxz.allo, cx.mkfa("scan", .skip, "nothing changed"));
var attempt: usize = 0;
while (attempt < CF.tryz) : (attempt += 1) {
if (!(try mergeAll(ctxz, facts, envp, gitd, top))) return;
var allp = true;
for (ctxz.conf.docs_remo_list) |remo| {
const push = (try ctxz.tool(&.{ "git", "push", "-q", remo, "HEAD:refs/heads/" ++ CF.bran }, envp)) orelse { try facts.append(ctxz.allo, cx.mkfa("push", .bloc, "git absent")); return; };
if (push.code != 0) { allp = false; if (attempt + 1 == CF.tryz) try facts.append(ctxz.allo, cx.mkfa(try std.fmt.allocPrint(ctxz.allo, "push {s}", .{remo}), .fail, try std.fmt.allocPrint(ctxz.allo, "rejected {d} times: {s}", .{ CF.tryz, cx.clip(cx.trim(push.errz)) }))); }
}
if (allp) { try facts.append(ctxz.allo, cx.mkfa("push", .okay, "")); try ctxz.stamPut("docs", .{ .when = ctxz.nowz(), .okay = true, .note = gitd }); return; }
}
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
