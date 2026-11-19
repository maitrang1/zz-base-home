// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Unit tests for id check, norm and type lists
// Flo: fixed ids and tasks > assert verdicts and folded keys
// I/O: ids + Task > reason or normalized Task
// ===================================================================
const std = @import("std"); const builtin = @import("builtin"); const stor = @import("tk-task-stor.zig");
const tszz = std.testing; const Task = stor.Task; const Reje = stor.Reje; const vali = stor.vali; const norm = stor.norm; const chaiFind = stor.chaiFind; const idenVali = stor.idenVali; const autoRunz = stor.autoRunz;
fn testJson(allo: std.mem.Allocator, text: []const u8) std.json.Value { return std.json.parseFromSliceLeaky(std.json.Value, allo, text, .{}) catch unreachable; }
test "idenVali guards the state/log file name on its own" { for ([_][]const u8{ "../../etc/passwd", "a/b", "a\\b", "C:evil", ".", "..", "" }) |iden| { try tszz.expect(idenVali(iden) != null); } for ([_][]const u8{ "nightly-test", "a.b.c", "task_1", "UPPER" }) |iden| { try tszz.expect(idenVali(iden) == null); } }
test "norm folds the old key names into dela / tmo / try, a new name wins" { const fold = norm(.{ .id = "a", .type = "boot", .run = "x", .dlyM = 5, .tmoS = 30, .retry = 2 }); try tszz.expectEqual(@as(?u32, 5), fold.dela); try tszz.expectEqual(@as(?u32, 30), fold.tmo); try tszz.expectEqual(@as(?u32, 2), fold.@"try"); try tszz.expect(fold.dlyM == null and fold.tmoS == null and fold.retry == null); const both = norm(.{ .id = "a", .type = "boot", .run = "x", .dela = 1, .dlyM = 5, .tmo = 9, .tmoS = 30 }); try tszz.expectEqual(@as(?u32, 1), both.dela); try tszz.expectEqual(@as(?u32, 9), both.tmo); }
test "all 20 types are present and unique" { try tszz.expectEqual(@as(usize, 20), stor.TYPE_LIST.len); for (stor.TYPE_LIST, 0..) |left, indx| { for (stor.TYPE_LIST[indx + 1 ..]) |righ| try tszz.expect(!std.mem.eql(u8, left, righ)); } }
test "type helper sets are subsets of TYPE_LIST" { for (stor.NONE_SCHE) |kind| try tszz.expect(stor.typeChec(kind)); for (stor.WINZ_ONLY) |kind| try tszz.expect(stor.typeChec(kind)); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
