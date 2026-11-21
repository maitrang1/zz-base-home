// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for ct-ctrl-runz: worst-case cost estimate
// Flo: estimate for default and custom vendor order and prices
// I/O: Conf > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const runz = @import("ct-ctrl-runz.zig"); const cfgz = @import("cf-conf-load.zig");
test "worst case follows the first vendor and its price" { const dflt = runz.estzWors(.{}, ""); try std.testing.expectEqual(@as(u32, 6), dflt.cred); try std.testing.expectEqual(@as(u64, 6000), dflt.micr); var conf: cfgz.Conf = .{}; conf.vend_orde = &.{ "zenr", "deco" }; conf.vend_cred_micr.zenr = 280; const zenz = runz.estzWors(conf, ""); try std.testing.expectEqual(@as(u32, 31), zenz.cred); try std.testing.expectEqual(@as(u64, 8680), zenz.micr); conf.vend_orde = &.{"brig"}; try std.testing.expectEqual(@as(u32, 3), runz.estzWors(conf, "").cred); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
