// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Append-only run journal, one JSON line per step
// Flo: build line > append at end + sync > read all lines back (a torn last line is dropped: its write never ran) > derive run state
// I/O: Jent > <data>/jour/<id>.jsonl; file > Jent list + State
// ===================================================================
const std = @import("std");
const osys = @import("ut-osys-adap.zig");
const CF = .{ .maxz = 64 * 1024 * 1024 };
pub const Jent = struct { op: []const u8, a: []const u8 = "", b: []const u8 = "", h0: []const u8 = "", h1: []const u8 = "", note: []const u8 = "" };
pub const State = enum { open, done, rolled, none };
pub fn appd(allo: std.mem.Allocator, iozz: std.Io, dirz: []const u8, path: []const u8, jent: Jent) !void {
try std.Io.Dir.cwd().createDirPath(iozz, dirz);
const body = try std.json.Stringify.valueAlloc(allo, jent, .{});
defer allo.free(body);
const line = try std.fmt.allocPrint(allo, "{s}\n", .{body});
defer allo.free(line);
var file = try std.Io.Dir.cwd().createFile(iozz, path, .{ .truncate = false, .read = true, .permissions = osys.privz });
defer file.close(iozz);
const lenz = try file.length(iozz);
try file.writePositionalAll(iozz, line, lenz);
try file.sync(iozz);
}
pub fn readAll(allo: std.mem.Allocator, iozz: std.Io, path: []const u8) ![]Jent {
const data = try std.Io.Dir.cwd().readFileAlloc(iozz, path, allo, .limited(CF.maxz));
var list: std.ArrayList(Jent) = .empty;
var iter = std.mem.splitScalar(u8, data, '\n');
while (iter.next()) |line| {
const trim = std.mem.trim(u8, line, " \r\t");
if (trim.len == 0) continue;
const ent = std.json.parseFromSliceLeaky(Jent, allo, trim, .{ .ignore_unknown_fields = true, .allocate = .alloc_always }) catch |err| {
if (std.mem.trim(u8, iter.rest(), " \r\n\t").len == 0) break;
return err;
};
try list.append(allo, ent);
}
return list.toOwnedSlice(allo);
}
pub fn stateOf(ents: []const Jent) State {
if (ents.len == 0) return .none;
var stav: State = .open;
for (ents) |ent| {
if (std.mem.eql(u8, ent.op, "done")) stav = .done;
if (std.mem.eql(u8, ent.op, "rolled")) stav = .rolled;
}
return stav;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
