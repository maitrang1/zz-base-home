// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Seed a fake repo + hub data folder in a tmp dir for tests
// Flo: write job files, dispatchers, docs, hub config, state and log files > hand back the paths
// I/O: tmp dir path > Fake {repo, tena, hubd}
// ===================================================================
const std = @import("std");
pub const JOBS_WI = "[\n{\"type\":\"puls\",\"sche\":\"15m\",\"id\":\"puls-15mi\",\"on\":true,\"kind\":\"shell\",\"ids\":[\"fb-watc\",\"cicd-stat\",\"home-docs\"]},\n{\"type\":\"cron\",\"sche\":\"[00..59] * * * *\",\"id\":\"once-aday\",\"on\":true,\"kind\":\"shell\",\"ids\":[\"scra-raws\",\"scra-sync\"]},\n{\"type\":\"boot\",\"id\":\"home-beat\",\"on\":true,\"kind\":\"shell\"}\n]\n";
pub const JOBS_LI = "[\n{\"type\":\"puls\",\"sche\":\"15m\",\"id\":\"puls-15mi\",\"on\":true,\"kind\":\"shell\",\"ids\":[\"fb-watc\",\"cicd-stat\"]}\n]\n";
pub const BATZ = "@echo off\nif \"%~1\"==\"fb-watc\" call x\nif \"%~1\"==\"cicd-stat\" call y\nif \"%~1\"==\"home-docs\" call z\nif \"%~1\"==\"scra-raws\" call w\nif \"%~1\"==\"home-beat\" call v\nexit /b 2\n";
pub const SHZZ = "case \"$1\" in\nfb-watc) a ;;\ncicd-stat) b ;;\nhome-docs) c ;;\nscra-raws) d ;;\nhome-beat) e ;;\nesac\n";
pub const DOCZ = "jobs: cicd-stat runs every 15m; cicd-stat2 is another; see cicd-stat.\n";
pub const HUBC = "{\"port\":4999,\"lock_list\":{\"scra\":[\"scra-\"],\"cicd\":[\"cicd-\",\"home-doct\"]},\"apps_data_loca_wind\":\"HUBD\",\"apps_data_loca_unix\":\"HUBD\"}\n";
pub fn tmpPath(allo: std.mem.Allocator, sub: []const u8) ![]u8 { return std.fs.path.join(allo, &.{ try std.process.currentPathAlloc(std.testing.io, allo), ".zig-cache", "tmp", sub }); }
pub const Fake = struct { repo: []const u8, tena: []const u8, hubd: []const u8 };
pub fn put(allo: std.mem.Allocator, iozz: std.Io, root: []const u8, rela: []const u8, body: []const u8) !void {
const path = try std.fs.path.join(allo, &.{ root, rela });
if (std.fs.path.dirname(path)) |pare| try std.Io.Dir.cwd().createDirPath(iozz, pare);
try std.Io.Dir.cwd().writeFile(iozz, .{ .sub_path = path, .data = body });
}
pub fn get(allo: std.mem.Allocator, iozz: std.Io, root: []const u8, rela: []const u8) ![]u8 { return std.Io.Dir.cwd().readFileAlloc(iozz, try std.fs.path.join(allo, &.{ root, rela }), allo, .limited(1 << 22)); }
pub fn has(allo: std.mem.Allocator, iozz: std.Io, root: []const u8, rela: []const u8) bool { return if (std.Io.Dir.cwd().statFile(iozz, std.fs.path.join(allo, &.{ root, rela }) catch return false, .{})) |_| true else |_| false; }
fn dumpDir(allo: std.mem.Allocator, iozz: std.Io, base: []const u8, rela: []const u8, outz: *std.ArrayList(u8)) !void {
const path = if (rela.len == 0) try allo.dupe(u8, base) else try std.fs.path.join(allo, &.{ base, rela });
var dir = std.Io.Dir.cwd().openDir(iozz, path, .{ .iterate = true }) catch return;
defer dir.close(iozz);
var names: std.ArrayList([]const u8) = .empty;
var kinds: std.ArrayList(bool) = .empty;
var iter = dir.iterate();
while (try iter.next(iozz)) |entr| { try names.append(allo, try allo.dupe(u8, entr.name)); try kinds.append(allo, entr.kind == .directory); }
const idxs = try allo.alloc(usize, names.items.len);
for (idxs, 0..) |*slot, indx| slot.* = indx;
const Ctx = struct { nam: []const []const u8 };
std.mem.sort(usize, idxs, Ctx{ .nam = names.items }, struct { fn lt(ctx: Ctx, left: usize, righ: usize) bool { return std.mem.order(u8, ctx.nam[left], ctx.nam[righ]) == .lt; } }.lt);
for (idxs) |indx| {
const sub = if (rela.len == 0) names.items[indx] else try std.fs.path.join(allo, &.{ rela, names.items[indx] });
if (kinds.items[indx]) { try dumpDir(allo, iozz, base, sub, outz); continue; }
const body = try std.Io.Dir.cwd().readFileAlloc(iozz, try std.fs.path.join(allo, &.{ base, sub }), allo, .limited(1 << 22));
try outz.print(allo, "{s}|{d}|", .{ sub, body.len });
try outz.appendSlice(allo, body);
try outz.append(allo, '\n');
}
}
pub fn dump(allo: std.mem.Allocator, iozz: std.Io, base: []const u8) ![]u8 {
var outz: std.ArrayList(u8) = .empty;
try dumpDir(allo, iozz, base, "", &outz);
return outz.toOwnedSlice(allo);
}
pub fn seed(allo: std.mem.Allocator, iozz: std.Io, base: []const u8) !Fake {
const repo = try std.fs.path.join(allo, &.{ base, "repo" });
const tena = try std.fs.path.join(allo, &.{ base, "tena" });
const hubd = try std.fs.path.join(allo, &.{ tena, "ac-auto-task" });
const hubc = try std.mem.replaceOwned(u8, allo, HUBC, "HUBD", try std.mem.replaceOwned(u8, allo, hubd, "\\", "\\\\"));
try put(allo, iozz, repo, "ac-auto-task/aa-auto-task-wi01.json", JOBS_WI);
try put(allo, iozz, repo, "ac-auto-task/aa-auto-task-li01.json", JOBS_LI);
try put(allo, iozz, repo, "ac-auto-task/ba-cmds-wind.bat", BATZ);
try put(allo, iozz, repo, "ac-auto-task/sh-cmds-linu.sh", SHZZ);
try put(allo, iozz, repo, "ac-auto-task/aa-conf-main.json", hubc);
try put(allo, iozz, repo, "do-note/no-note-docs.txt", DOCZ);
try put(allo, iozz, repo, "do-note/UPDATE.md", DOCZ);
try put(allo, iozz, repo, "zz-dele-auto/old.txt", DOCZ);
try put(allo, iozz, hubd, "task-state/cicd-stat.last", "2992720829");
try put(allo, iozz, hubd, "task-state/puls-15mi.chain", "1 1 0 5 5\n");
try put(allo, iozz, hubd, "task-log/cicd-stat.log", "log line\n");
try put(allo, iozz, hubd, "task-log/fb-watc.log", "log line\n");
try put(allo, iozz, hubd, "history.txt", "cicd-stat history stays\n");
return .{ .repo = repo, .tena = tena, .hubd = hubd };
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
