// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Read the hub job files and the dispatcher scripts, read-only
// Flo: list aa-auto-task*.json > parse rows > collect job ids, chain step ids, callable ids > find callables no dispatcher knows
// I/O: repo + Conf > Jobz list; Jobz list > id lookups; callables > unresolved ids
// ===================================================================
const std = @import("std");
const cfgz = @import("cf-conf-load.zig");
const osys = @import("ut-osys-adap.zig");
const tk = @import("ut-iden-toke.zig");
pub const Row = struct { id: []const u8 = "", ids: ?[]const []const u8 = null, run: ?[]const u8 = null };
pub const Jobz = struct { file: []const u8, rows: []const Row };
pub fn parse(allo: std.mem.Allocator, text: []const u8) ![]const Row { return std.json.parseFromSliceLeaky([]const Row, allo, text, .{ .ignore_unknown_fields = true, .allocate = .alloc_always }); }
pub fn listFiles(allo: std.mem.Allocator, iozz: std.Io, repo: []const u8, conf: cfgz.Conf) ![][]const u8 {
const dirz = try std.fs.path.join(allo, &.{ repo, conf.hubz_dirz });
var dir = try std.Io.Dir.cwd().openDir(iozz, dirz, .{ .iterate = true });
defer dir.close(iozz);
var list: std.ArrayList([]const u8) = .empty;
var iter = dir.iterate();
while (try iter.next(iozz)) |entr| {
if (entr.kind != .file or !std.mem.startsWith(u8, entr.name, conf.hubz_jobs_pref) or !std.mem.endsWith(u8, entr.name, ".json")) continue;
try list.append(allo, try std.fs.path.join(allo, &.{ dirz, entr.name }));
}
std.mem.sort([]const u8, list.items, {}, lessStr);
return list.toOwnedSlice(allo);
}
fn lessStr(_: void, left: []const u8, righ: []const u8) bool { return std.mem.order(u8, left, righ) == .lt; }
pub fn loadAll(allo: std.mem.Allocator, iozz: std.Io, repo: []const u8, conf: cfgz.Conf) ![]Jobz {
var list: std.ArrayList(Jobz) = .empty;
for (try listFiles(allo, iozz, repo, conf)) |path| {
const text = try std.Io.Dir.cwd().readFileAlloc(iozz, path, allo, .limited(8 << 20));
try list.append(allo, .{ .file = path, .rows = try parse(allo, text) });
}
return list.toOwnedSlice(allo);
}
pub fn hasIden(jobs: []const Jobz, iden: []const u8) bool {
for (jobs) |job| for (job.rows) |row| {
if (std.mem.eql(u8, row.id, iden)) return true;
if (row.ids) |idsz| for (idsz) |step| if (std.mem.eql(u8, step, iden)) return true;
};
return false;
}
pub fn isJobId(jobs: []const Jobz, iden: []const u8) bool { for (jobs) |job| for (job.rows) |row| if (std.mem.eql(u8, row.id, iden)) return true; return false; }
pub fn calls(allo: std.mem.Allocator, jobs: []const Jobz) ![][]const u8 {
var list: std.ArrayList([]const u8) = .empty;
for (jobs) |job| for (job.rows) |row| {
if (row.ids) |idsz| { for (idsz) |step| try addUniq(allo, &list, step); continue; }
if (row.run == null or row.run.?.len == 0) try addUniq(allo, &list, row.id);
};
return list.toOwnedSlice(allo);
}
fn addUniq(allo: std.mem.Allocator, list: *std.ArrayList([]const u8), iden: []const u8) !void {
for (list.items) |item| if (std.mem.eql(u8, item, iden)) return;
try list.append(allo, iden);
}
pub fn unresolved(allo: std.mem.Allocator, iozz: std.Io, repo: []const u8, conf: cfgz.Conf, callz: []const []const u8) ![][]const u8 {
var texts: std.ArrayList([]const u8) = .empty;
for (conf.disp_file_list) |rela| {
const path = try std.fs.path.join(allo, &.{ repo, try osys.nati(allo, rela) });
const text = std.Io.Dir.cwd().readFileAlloc(iozz, path, allo, .limited(4 << 20)) catch continue;
try texts.append(allo, text);
}
var list: std.ArrayList([]const u8) = .empty;
for (callz) |iden| {
var found = false;
for (texts.items) |text| if (tk.hasTok(text, iden)) { found = true; break; };
if (!found) try list.append(allo, iden);
}
return list.toOwnedSlice(allo);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
