// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Standard fake machine for flow tests, 4 files
// Flo: root > write files with abs + relative refs > give back paths and the file list
// I/O: TmpDir > Fxt {root, old, new, rels}
// ===================================================================
const std = @import("std");
const fake = @import("te-mach-fake.zig");
pub const Fxt = struct { root: []u8, old: []u8, new: []u8 };
pub const rels = [_][]const u8{ "p/old/x.txt", "p/doc/a.md", "p/c.txt", "p/untouched.txt" };
pub fn seed(allo: std.mem.Allocator, tmp: *std.testing.TmpDir) !Fxt {
const root = try fake.rootOf(allo, tmp);
try fake.putz(tmp, rels[0], try std.fmt.allocPrint(allo, "self {s}/p/old/x.txt\nline2\r\nunicode tệp ✓\n", .{root}));
try fake.putz(tmp, rels[1], try std.fmt.allocPrint(allo, "abs {s}/p/old and rel ../old/x.txt\n", .{root}));
try fake.putz(tmp, rels[2], try std.fmt.allocPrint(allo, "see {s}/p/old/x.txt ok\nnothing else\n", .{root}));
try fake.putz(tmp, rels[3], "no refs here\n");
return .{ .root = root, .old = try std.fmt.allocPrint(allo, "{s}/p/old", .{root}), .new = try std.fmt.allocPrint(allo, "{s}/p/new", .{root}) };
}
pub fn dumpOld(allo: std.mem.Allocator, tmp: *std.testing.TmpDir) ![]u8 { return fake.dumpz(allo, tmp, &rels); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
