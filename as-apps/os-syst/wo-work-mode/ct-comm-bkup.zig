// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: wo bkup: restic state job and nightly SQLite copies
// Flo: stat: read list > resolve under home > restic backup --files-from, no *.db > stamp | nigh: VACUUM INTO per db > integrity > restic backup > stamp
// I/O: Ctxz + optional stat|nigh (dry-run default, --live acts) > facts, exit 0 ok / 1 failed / 4 blocked
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const fcts = @import("ob-fact-rept.zig");
const exit = @import("ct-exit-code.zig");
const CF = .{ .maxz = 64 * 1024, .resl = "bkup-files.txt", .nigh = "nigh" };
pub fn listParse(allo: std.mem.Allocator, home: []const u8, text: []const u8) !?[]const []const u8 {
var outz: std.ArrayList([]const u8) = .empty;
var lines = std.mem.splitScalar(u8, text, '\n');
while (lines.next()) |raww| {
const line = cx.trim(raww);
if (line.len == 0 or line[0] == '#') continue;
if (std.fs.path.isAbsolute(line) or std.mem.indexOf(u8, line, "..") != null) return null;
try outz.append(allo, try std.fs.path.join(allo, &.{ home, line }));
}
return outz.items;
}
pub fn docsPick(allo: std.mem.Allocator, top: []const u8, text: []const u8, names: []const []const u8) ![]const []const u8 {
var outz: std.ArrayList([]const u8) = .empty;
var iter = std.mem.splitScalar(u8, text, 0);
while (iter.next()) |raww| {
if (raww.len < 2) continue;
const dirz = if (raww[raww.len - 1] == '/') raww[0 .. raww.len - 1] else raww;
const base = std.fs.path.basename(dirz);
for (names) |name| { if (std.mem.startsWith(u8, base, name)) { try outz.append(allo, try std.fs.path.join(allo, &.{ top, dirz })); break; } }
}
return outz.items;
}
pub fn docsFind(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact)) !?[]const []const u8 {
if (ctxz.conf.bkup_docs_list.len == 0) return &.{};
const topp = (try ctxz.tool(&.{ "git", "rev-parse", "--show-toplevel" }, &.{})) orelse { try facts.append(ctxz.allo, cx.mkfa("docs", .bloc, "git absent: ignored docs not listed")); return null; };
if (topp.code != 0) { try facts.append(ctxz.allo, cx.mkfa("docs", .bloc, "not inside a git repo: ignored docs not listed")); return null; }
const top = cx.trim(topp.outz);
const lsfl = (try ctxz.tool(&.{ "git", "-C", top, "ls-files", "-z", "--others", "--ignored", "--exclude-standard", "--directory" }, &.{})) orelse { try facts.append(ctxz.allo, cx.mkfa("docs", .bloc, "git absent: ignored docs not listed")); return null; };
if (lsfl.code != 0) { try facts.append(ctxz.allo, cx.mkfa("docs", .fail, "git ls-files failed")); return null; }
const pick = try docsPick(ctxz.allo, top, lsfl.outz, ctxz.conf.bkup_docs_list);
try facts.append(ctxz.allo, cx.mkfa("docs", .okay, try std.fmt.allocPrint(ctxz.allo, "{d} ignored doc path(s) found", .{pick.len})));
return pick;
}
fn statRun(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact)) !void {
const data = std.Io.Dir.cwd().readFileAlloc(ctxz.iozz, ctxz.conf.bkup_list_file, ctxz.allo, .limited(CF.maxz)) catch { try facts.append(ctxz.allo, cx.mkfa("list", .fail, try std.fmt.allocPrint(ctxz.allo, "cannot read {s}", .{ctxz.conf.bkup_list_file}))); return; };
const path = (try listParse(ctxz.allo, ctxz.home, data)) orelse { try facts.append(ctxz.allo, cx.mkfa("list", .fail, "list holds an absolute or .. path")); return; };
const docs = (try docsFind(ctxz, facts)) orelse return;
const allp = try std.mem.concat(ctxz.allo, []const u8, &.{ path, docs });
if (allp.len == 0) { try facts.append(ctxz.allo, cx.mkfa("list", .fail, "list is empty")); return; }
if (!ctxz.ladd.live) { try facts.append(ctxz.allo, cx.mkfa("stat", .okay, try std.fmt.allocPrint(ctxz.allo, "dry-run: would back up {d} path(s) with restic, tag {s}", .{ allp.len, ctxz.conf.bkup_tagz_stat }))); return; }
const resl = try std.fs.path.join(ctxz.allo, &.{ try ctxz.dirzData(), CF.resl });
try std.Io.Dir.cwd().createDirPath(ctxz.iozz, try ctxz.dirzData());
try std.Io.Dir.cwd().writeFile(ctxz.iozz, .{ .sub_path = resl, .data = try std.mem.join(ctxz.allo, "\n", allp) });
var argv: std.ArrayList([]const u8) = .empty;
try argv.appendSlice(ctxz.allo, &.{ "restic", "backup", "--files-from", resl, "--skip-if-unchanged", "--exclude", "*.db", "--exclude", "*.db-wal", "--exclude", "*.db-shm", "--tag", ctxz.conf.bkup_tagz_stat });
if (ctxz.ostg == .windows) try argv.append(ctxz.allo, "--use-fs-snapshot");
if ((try ctxz.step(facts, "rest", argv.items, &.{})) != null) try ctxz.stamPut("bkup", .{ .when = ctxz.nowz(), .okay = true, .note = resl });
}
fn nighRun(ctxz: *const cx.Ctxz, facts: *std.ArrayList(fcts.Fact)) !void {
if (ctxz.conf.bkup_dbzz_list.len == 0) { try facts.append(ctxz.allo, cx.mkfa("dbzz", .bloc, "bkup_dbzz_list is empty: name the SQLite files")); return; }
const dest = try std.fs.path.join(ctxz.allo, &.{ try ctxz.dirzData(), CF.nigh, try cx.stamTxt(ctxz.allo, ctxz.nowz()) });
if (std.mem.indexOfScalar(u8, dest, '\'') != null) { try facts.append(ctxz.allo, cx.mkfa("dest", .fail, "copy path holds a quote")); return; }
if (!ctxz.ladd.live) { try facts.append(ctxz.allo, cx.mkfa("nigh", .okay, try std.fmt.allocPrint(ctxz.allo, "dry-run: would VACUUM INTO {d} db(s) under {s}, check, then restic backup, tag {s}", .{ ctxz.conf.bkup_dbzz_list.len, dest, ctxz.conf.bkup_tagz_nigh }))); return; }
try std.Io.Dir.cwd().createDirPath(ctxz.iozz, dest);
var allk = true;
for (ctxz.conf.bkup_dbzz_list) |item| {
const srcz = if (std.fs.path.isAbsolute(item)) item else try std.fs.path.join(ctxz.allo, &.{ ctxz.home, item });
const copy = try std.fs.path.join(ctxz.allo, &.{ dest, std.fs.path.basename(item) });
const base = std.fs.path.basename(item);
const sqlv = try std.fmt.allocPrint(ctxz.allo, "VACUUM INTO '{s}'", .{copy});
if ((try ctxz.step(facts, try std.fmt.allocPrint(ctxz.allo, "vacu {s}", .{base}), &.{ "sqlite3", srcz, sqlv }, &.{})) == null) { allk = false; continue; }
const chek = (try ctxz.tool(&.{ "sqlite3", copy, "PRAGMA integrity_check;" }, &.{})) orelse { try facts.append(ctxz.allo, cx.mkfa("chek", .bloc, "sqlite3 absent")); allk = false; continue; };
if (chek.code == 0 and std.mem.eql(u8, cx.trim(chek.outz), "ok")) try facts.append(ctxz.allo, cx.mkfa("chek", .okay, base)) else { try facts.append(ctxz.allo, cx.mkfa("chek", .fail, try std.fmt.allocPrint(ctxz.allo, "{s}: {s}", .{ base, cx.clip(cx.trim(chek.outz)) }))); allk = false; }
}
if (!allk) return;
if ((try ctxz.step(facts, "rest", &.{ "restic", "backup", "--tag", ctxz.conf.bkup_tagz_nigh, dest }, &.{})) != null) try ctxz.stamPut("bknt", .{ .when = ctxz.nowz(), .okay = true, .note = dest });
}
pub fn comm(ctxz: *const cx.Ctxz, args: []const []const u8) !exit.Code {
var nigh = false;
if (args.len > 1) return exit.Erro.Usag;
if (args.len == 1) { if (std.mem.eql(u8, args[0], "nigh")) nigh = true else if (!std.mem.eql(u8, args[0], "stat")) return exit.Erro.Usag; }
var facts: std.ArrayList(fcts.Fact) = .empty;
if (nigh) try nighRun(ctxz, &facts) else try statRun(ctxz, &facts);
return ctxz.emit(facts.items);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
