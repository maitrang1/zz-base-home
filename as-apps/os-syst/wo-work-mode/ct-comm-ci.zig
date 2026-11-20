// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: wo ci: local mirrors of the CI jobs plus cloud watchers (read-only)
// Flo: pick sub-command > run outside tools through the runner > facts (red = fail, tool absent = blocked)
// I/O: Ctxz + stat|test|leak|lock|rele|repr|deps > facts, exit 0 ok / 1 failed / 4 blocked
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const fcts = @import("ob-fact-rept.zig");
const exit = @import("ct-exit-code.zig");
const CF = .{ .mark = "Verified: GitHub and GitLab built identical bytes", .miss = "MISMATCH", .mirr = "cimi", .bina = [_][]const u8{ "windows-x86_64/wo.exe", "linux-x86_64/wo", "linux-aarch64/wo", "macos-aarch64/wo" }, .shaz = 32 };
fn shaOf(ctxz: *const cx.Ctxz, base: []const u8, sub: []const u8) ?[CF.shaz]u8 {
const path = std.fs.path.join(ctxz.allo, &.{ base, "dist", sub }) catch return null;
const data = std.Io.Dir.cwd().readFileAlloc(ctxz.iozz, path, ctxz.allo, .limited(256 * 1024 * 1024)) catch return null;
var out: [CF.shaz]u8 = undefined;
std.crypto.hash.sha2.Sha256.hash(data, &out, .{});
return out;
}
fn headOf(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact), name: []const u8, remo: []const u8) !?[]const u8 {
const outp = (try ctxz.step(facts, name, &.{ "git", "ls-remote", remo, try std.fmt.allocPrint(ctxz.allo, "refs/heads/{s}", .{ctxz.conf.ci_bran_main}) }, &.{})) orelse return null;
var tokn = std.mem.tokenizeAny(u8, outp.outz, " \t\r\n");
const sha1 = tokn.next() orelse { try facts.append(ctxz.allo, cx.mkfa(name, .fail, "no main branch answer")); return null; };
return sha1;
}
fn doStat(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact)) !void {
if (try ctxz.tool(&.{ "gh", "run", "list", "--branch", ctxz.conf.ci_bran_main, "--limit", "1", "--json", "conclusion,status", "--jq", ".[0] | (.status + \" \" + .conclusion)" }, &.{})) |outp| {
const line = cx.trim(outp.outz);
if (outp.code != 0) try facts.append(ctxz.allo, cx.mkfa("gith", .fail, cx.clip(cx.trim(outp.errz)))) else if (std.mem.eql(u8, line, "completed success") or std.mem.startsWith(u8, line, "in_progress") or std.mem.startsWith(u8, line, "queued")) try facts.append(ctxz.allo, cx.mkfa("gith", .okay, line)) else try facts.append(ctxz.allo, cx.mkfa("gith", .fail, try std.fmt.allocPrint(ctxz.allo, "last run on {s}: {s}", .{ ctxz.conf.ci_bran_main, line })));
} else try facts.append(ctxz.allo, cx.mkfa("gith", .bloc, "tool absent: gh"));
const urlz = try std.fmt.allocPrint(ctxz.allo, "https://gitlab.com/api/v4/projects/{s}/pipelines?ref={s}&per_page=1", .{ ctxz.conf.ci_gitl_proj, ctxz.conf.ci_bran_main });
if (try ctxz.tool(&.{ "curl", "-fsS", "-m", "15", "--retry", "2", urlz }, &.{})) |outp| {
if (outp.code != 0) try facts.append(ctxz.allo, cx.mkfa("gitl", .fail, cx.clip(cx.trim(outp.errz)))) else {
const key = "\"status\":\"";
const pos = std.mem.indexOf(u8, outp.outz, key);
const stav = if (pos) |at| outp.outz[at + key.len ..][0 .. std.mem.indexOfScalar(u8, outp.outz[at + key.len ..], '"') orelse 0] else "";
if (stav.len == 0) try facts.append(ctxz.allo, cx.mkfa("gitl", .fail, "no pipeline status in the answer")) else if (std.mem.eql(u8, stav, "success") or std.mem.eql(u8, stav, "running") or std.mem.eql(u8, stav, "pending")) try facts.append(ctxz.allo, cx.mkfa("gitl", .okay, stav)) else try facts.append(ctxz.allo, cx.mkfa("gitl", .fail, try std.fmt.allocPrint(ctxz.allo, "last pipeline on {s}: {s}", .{ ctxz.conf.ci_bran_main, stav })));
}
} else try facts.append(ctxz.allo, cx.mkfa("gitl", .bloc, "tool absent: curl"));
var mine: std.ArrayList(fcts.Fact) = .empty;
const hubz = (try headOf(ctxz, &mine, "mirh", "origin")) orelse { try facts.appendSlice(ctxz.allo, mine.items); return; };
const labz = (try headOf(ctxz, &mine, "mirl", "mirr")) orelse { try facts.appendSlice(ctxz.allo, mine.items); return; };
if (std.mem.eql(u8, hubz, labz)) { try ctxz.stamPut(CF.mirr, .{ .when = ctxz.nowz(), .okay = true, .note = "same" }); try facts.append(ctxz.allo, cx.mkfa("mirr", .okay, "GitHub and GitLab main match")); return; }
const prev = ctxz.stamGet(CF.mirr);
const since = if (prev) |item| (if (item.okay) ctxz.nowz() else item.when) else ctxz.nowz();
if (prev == null or prev.?.okay) try ctxz.stamPut(CF.mirr, .{ .when = since, .okay = false, .note = "differ" });
const ager = ctxz.nowz() - since;
if (ager > ctxz.conf.ci_mirr_grac) try facts.append(ctxz.allo, cx.mkfa("mirr", .fail, try std.fmt.allocPrint(ctxz.allo, "GitHub and GitLab main differ for {d}s, limit {d}s", .{ ager, ctxz.conf.ci_mirr_grac }))) else try facts.append(ctxz.allo, cx.mkfa("mirr", .okay, try std.fmt.allocPrint(ctxz.allo, "differ for {d}s, inside the {d}s grace", .{ ager, ctxz.conf.ci_mirr_grac })));
}
fn doTest(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact)) !void {
for (ctxz.conf.ci_test_list) |file| _ = try ctxz.step(facts, file, &.{ "zig", "build", "test", "--summary", "all", "--build-file", file }, &.{});
}
fn doLeak(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact)) !void { _ = try ctxz.step(facts, "leak", &.{ "gitleaks", "git", "--redact", "--no-banner" }, &.{}); }
fn doLock(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact)) !void { _ = try ctxz.step(facts, "lock", &.{ "gh", "actions-lock", "--no-fix" }, &.{}); }
fn doRele(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact)) !void {
const list = (try ctxz.step(facts, "list", &.{ "gh", "release", "list", "--limit", "5", "--json", "tagName,isPrerelease", "--jq", ".[] | select(.isPrerelease) | .tagName" }, &.{})) orelse return;
var lines = std.mem.splitScalar(u8, list.outz, '\n');
const tag = cx.trim(lines.next() orelse "");
if (tag.len == 0) { try facts.append(ctxz.allo, cx.mkfa("rele", .skip, "no pending prerelease")); return; }
const body = (try ctxz.step(facts, "view", &.{ "gh", "release", "view", tag, "--json", "body,assets", "-q", ".body, (.assets[].name)" }, &.{})) orelse return;
if (std.mem.indexOf(u8, body.outz, CF.miss) != null) try facts.append(ctxz.allo, cx.mkfa("rele", .fail, try std.fmt.allocPrint(ctxz.allo, "{s} MISMATCH: GitHub and GitLab bytes differ", .{tag}))) else if (std.mem.indexOf(u8, body.outz, CF.mark) != null and std.mem.indexOf(u8, body.outz, "sha256.txt.sig") != null) try facts.append(ctxz.allo, cx.mkfa("rele", .okay, try std.fmt.allocPrint(ctxz.allo, "{s} Verified and signed", .{tag}))) else if (std.mem.indexOf(u8, body.outz, CF.mark) != null) try facts.append(ctxz.allo, cx.mkfa("rele", .okay, try std.fmt.allocPrint(ctxz.allo, "{s} Verified: run wo rels sign {s} --live", .{ tag, tag }))) else try facts.append(ctxz.allo, cx.mkfa("rele", .okay, try std.fmt.allocPrint(ctxz.allo, "{s} still pending", .{tag})));
}
fn doRepr(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact)) !void {
const root = try std.fs.path.join(ctxz.allo, &.{ try ctxz.dirzData(), "repr" });
const file = "as-apps/os-syst/wo-work-mode/build.zig";
var bases: [2][]const u8 = undefined;
for (&bases, 0..) |*slot, indx| {
slot.* = try std.fmt.allocPrint(ctxz.allo, "{s}{c}run{d}", .{ root, std.fs.path.sep, indx });
_ = (try ctxz.step(facts, try std.fmt.allocPrint(ctxz.allo, "bui{d}", .{indx}), &.{ "zig", "build", "dist", "--build-file", file, "--prefix", slot.*, "--cache-dir", try std.fmt.allocPrint(ctxz.allo, "{s}{c}zc", .{ slot.*, std.fs.path.sep }) }, &.{})) orelse return;
}
for (CF.bina) |sub| {
const sha1 = shaOf(ctxz, bases[0], sub);
const sha2 = shaOf(ctxz, bases[1], sub);
if (sha1 == null or sha2 == null) { try facts.append(ctxz.allo, cx.mkfa(sub, .fail, "built file missing")); continue; }
if (std.mem.eql(u8, &sha1.?, &sha2.?)) try facts.append(ctxz.allo, cx.mkfa(sub, .okay, "same bytes")) else try facts.append(ctxz.allo, cx.mkfa(sub, .fail, "two builds differ"));
}
}
fn doDeps(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact)) !void {
const cut = ctxz.nowz() - ctxz.conf.ci_deps_ager;
const stam = try cx.stamTxt(ctxz.allo, cut);
const outp = (try ctxz.step(facts, "deps", &.{ "gh", "pr", "list", "--author", "app/dependabot", "--state", "open", "--search", try std.fmt.allocPrint(ctxz.allo, "created:<{s}-{s}-{s}", .{ stam[0..4], stam[4..6], stam[6..8] }), "--json", "number", "--jq", "length" }, &.{})) orelse return;
const coun = std.fmt.parseInt(u32, cx.trim(outp.outz), 10) catch { try facts.append(ctxz.allo, cx.mkfa("deps", .fail, "gh gave no count")); return; };
if (coun > 0) try facts.append(ctxz.allo, cx.mkfa("deps", .fail, try std.fmt.allocPrint(ctxz.allo, "{d} Dependabot PR open for over {d} days", .{ coun, @divTrunc(ctxz.conf.ci_deps_ager, 86400) })));
}
pub fn comm(ctxz: *const cx.Ctxz, args: []const []const u8) !exit.Code {
if (args.len != 1) return exit.Erro.Usag;
const subc = args[0];
var facts: std.ArrayList(fcts.Fact) = .empty;
if (std.mem.eql(u8, subc, "stat")) try doStat(ctxz, &facts) else if (std.mem.eql(u8, subc, "test")) try doTest(ctxz, &facts) else if (std.mem.eql(u8, subc, "leak")) try doLeak(ctxz, &facts) else if (std.mem.eql(u8, subc, "lock")) try doLock(ctxz, &facts) else if (std.mem.eql(u8, subc, "rele")) try doRele(ctxz, &facts) else if (std.mem.eql(u8, subc, "repr")) try doRepr(ctxz, &facts) else if (std.mem.eql(u8, subc, "deps")) try doDeps(ctxz, &facts) else return exit.Erro.Usag;
return ctxz.emit(facts.items);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
