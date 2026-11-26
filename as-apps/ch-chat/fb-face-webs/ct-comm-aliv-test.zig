// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests login watch: saved state, alert gap, live check on a mock page
// Flo: no flag reads the saved state and never opens a page > a dead state exits 3 and tells the owner once > --live on a signed-in page saves ok
// I/O: mock site (rig) > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const rigz = @import("te-rigz-brow.zig"); const aliv = @import("ct-comm-aliv.zig");
fn has(rig: *rigz.Rig, needle: []const u8) bool { return std.mem.find(u8, rig.sink.items, needle) != null; }
test "alert gap: quiet inside six hours, open after, never alerted is open" { const hour: i64 = 3600 * 1000; try std.testing.expect(aliv.coolOk(10 * hour, 8 * hour)); try std.testing.expect(!aliv.coolOk(15 * hour, 8 * hour)); try std.testing.expect(!aliv.coolOk(10 * hour, 0)); }
test "look is due after the gap, never while dead, at once when never checked" { const hour: i64 = 3600 * 1000; try std.testing.expect(aliv.dueLook(0, 0, 5 * hour, 8)); try std.testing.expect(!aliv.dueLook(aliv.OK, 2 * hour, 9 * hour, 8)); try std.testing.expect(aliv.dueLook(aliv.OK, 1 * hour, 9 * hour, 8)); try std.testing.expect(!aliv.dueLook(aliv.DEAD, 1 * hour, 99 * hour, 8)); }
test "saved state: unknown at first, needs login exits 3 and tells once, ok after a good login" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); rig.conf.noti_chai_orde = &.{}; var cx = rig.ctx(.read); try std.testing.expectEqual(@as(u8, 0), try aliv.aliveRun(&cx)); try std.testing.expect(has(&rig, "unknown (not checked yet)")); aliv.markPut(&cx, aliv.DEAD); try std.testing.expectEqual(@as(u8, 3), try aliv.aliveRun(&cx)); try std.testing.expect(has(&rig, "login --acct main")); try std.testing.expect((try cx.store.metaGet("alive_note")) > 0); try std.testing.expectEqual(@as(u8, 3), try aliv.aliveRun(&cx)); aliv.markPut(&cx, aliv.OK); try std.testing.expectEqual(@as(u8, 0), try aliv.aliveRun(&cx)); try std.testing.expect(has(&rig, "account main: ok")); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
