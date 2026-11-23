// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for the doctor (does each job's first control exist on its page)
// Flo: run the doctor in the rig > check OK and MISSING lines, errors
// I/O: none (mock site on loopback, scratch profile) > pass or fail (skips without Chrome)
// Run: cd E:\zz-base-home\as-apps\in-inte\zr-zrow-webs && zig build test -Dfile=ru-doct-main-test.zig
// ===================================================================
const std = @import("std"); const rigz = @import("te-rigz-brow.zig"); const doct = @import("ru-doct-main.zig"); const cfgz = @import("cf-conf-load.zig");
fn has(rig: *rigz.Rig, needle: []const u8) bool { return std.mem.find(u8, rig.sink.items, needle) != null; }
test "every job page on the fake site passes the doctor" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); rig.conf.brow_vers_minz = 1; var cx = rig.ctx(.read); const okay = doct.doctor(&cx, "", "") catch |err| { std.debug.print("{s}\n", .{rig.sink.items}); return err; }; try std.testing.expect(okay >= 36); try std.testing.expect(has(&rig, "doctor: ")); try std.testing.expect(has(&rig, " 0 missing")); try std.testing.expect(has(&rig, "OK      browser: Chrome")); }
test "a renamed label is reported MISSING and the doctor fails with Drift" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); rig.conf.brow_vers_minz = 1; rig.conf.retr_coun_maxz = 1; var aren = std.heap.ArenaAllocator.init(std.testing.allocator); defer aren.deinit(); const conf = try cfgz.confParse(aren.allocator(), "{\"labl_over\":{\"keyz_newz\":[\"Zzz Nothing Here\"]}}"); rig.conf.labl_over = conf.labl_over; var cx = rig.ctx(.read); try std.testing.expectError(error.Drift, doct.doctor(&cx, "", "")); try std.testing.expect(has(&rig, "MISSING key-create: keyz_newz")); try std.testing.expect(has(&rig, "OK      signup")); }
test "one job by name" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); rig.conf.brow_vers_minz = 1; var cx = rig.ctx(.read); try std.testing.expectEqual(@as(u32, 1), try doct.doctor(&cx, "key-create", "")); try std.testing.expect(has(&rig, "OK      key-create: keyz_newz")); }
test "a browser older than the minimum is flagged" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); rig.conf.brow_vers_minz = 9999; var cx = rig.ctx(.read); try std.testing.expectError(error.Drift, doct.doctor(&cx, "key-create", "")); try std.testing.expect(has(&rig, "older than brow_vers_minz")); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
