// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Commit guard: big files, CRLF, Windows path traps, case clashes
// Flo: read NUL path list > check name + length > stat size > scan text for CR > report > exit 4 on any hit
// I/O: stdin NUL-separated repo paths (git ls-files -z) > stderr lines "kind<TAB>path", exit 0 ok / 4 blocked
// Run: git ls-files -z | zig run E:\zz-base-home\ci-flow-sync\ci-comm-guar.zig
// ===================================================================
const std = @import("std");
const CF = .{ .maxz = 100 * 1024 * 1024, .path = 259, .lfsz = 5 * 1024 * 1024, .listz = 64 * 1024 * 1024, .bufz = 65536, .nulz = 8000 };
pub const Kind = enum { size, crlf, long, resv, coll };
const RESV = [_][]const u8{ "con", "prn", "aux", "nul", "com1", "com2", "com3", "com4", "com5", "com6", "com7", "com8", "com9", "lpt1", "lpt2", "lpt3", "lpt4", "lpt5", "lpt6", "lpt7", "lpt8", "lpt9" };
pub fn kindName(kind: Kind) []const u8 { return switch (kind) { .size => "size", .crlf => "crlf", .long => "long", .resv => "resv", .coll => "coll" }; }
pub fn namePart(part: []const u8) bool {
const stem = part[0 .. std.mem.indexOfScalar(u8, part, '.') orelse part.len];
for (RESV) |name| { if (std.ascii.eqlIgnoreCase(stem, name)) return true; }
return false;
}
pub fn pathChec(path: []const u8, rootlen: usize) ?Kind {
if (rootlen + 1 + path.len > CF.path) return .long;
var iter = std.mem.splitScalar(u8, path, '/');
while (iter.next()) |part| { if (namePart(part)) return .resv; }
return null;
}
pub fn crlfOkay(path: []const u8) bool { return std.mem.endsWith(u8, path, ".ps1") or std.mem.endsWith(u8, path, ".bat"); }
pub fn textHasCr(data: []const u8) bool {
if (std.mem.indexOfScalar(u8, data[0..@min(data.len, CF.nulz)], 0) != null) return false;
return std.mem.indexOfScalar(u8, data, '\r') != null;
}
pub fn collChec(aren: std.mem.Allocator, seen: *std.StringHashMap([]const u8), path: []const u8) !bool {
var hitz = false;
var indx: usize = 0;
while (indx < path.len) {
const stop = std.mem.indexOfScalarPos(u8, path, indx, '/') orelse path.len;
const prev = path[0..stop];
const lowr = try std.ascii.allocLowerString(aren, prev);
const entr = try seen.getOrPut(lowr);
if (entr.found_existing) { if (!std.mem.eql(u8, entr.value_ptr.*, prev)) hitz = true; } else entr.value_ptr.* = prev;
indx = stop + 1;
}
return hitz;
}
fn rept(kind: Kind, path: []const u8) void { std.debug.print("{s}\t{s}\n", .{ kindName(kind), path }); }
fn chekOne(iozz: std.Io, gpaz: std.mem.Allocator, aren: std.mem.Allocator, rootlen: usize, path: []const u8, seen: *std.StringHashMap([]const u8)) !u32 {
var coun: u32 = 0;
if (pathChec(path, rootlen)) |kind| { rept(kind, path); coun += 1; }
if (try collChec(aren, seen, path)) { rept(.coll, path); coun += 1; }
const stat = std.Io.Dir.cwd().statFile(iozz, path, .{}) catch return coun;
if (stat.kind != .file) return coun;
if (stat.size > CF.maxz) { rept(.size, path); coun += 1; }
if (stat.size > CF.lfsz or crlfOkay(path)) return coun;
const data = std.Io.Dir.cwd().readFileAlloc(iozz, path, gpaz, .limited(CF.lfsz)) catch return coun;
defer gpaz.free(data);
if (textHasCr(data)) { rept(.crlf, path); coun += 1; }
return coun;
}
pub fn main(init: std.process.Init) !void {
const iozz = init.io;
const gpaz = init.gpa;
var arna = std.heap.ArenaAllocator.init(gpaz);
defer arna.deinit();
const aren = arna.allocator();
var buff: [CF.bufz]u8 = undefined;
var rdzz = std.Io.File.stdin().readerStreaming(iozz, &buff);
const list = try rdzz.interface.allocRemaining(aren, .limited(CF.listz));
const root = try std.process.currentPathAlloc(iozz, aren);
var seen = std.StringHashMap([]const u8).init(aren);
var coun: u32 = 0;
var iter = std.mem.splitScalar(u8, list, 0);
while (iter.next()) |path| { if (path.len > 0) coun += try chekOne(iozz, gpaz, aren, root.len, path, &seen); }
if (coun > 0) std.process.exit(4);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
