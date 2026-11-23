// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for plan classes, skip flags and counts
// Flo: kind to class > class to skip by config > count a plan
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\rn-name-upda\build.zig
// ===================================================================
const std = @import("std");
const cfgz = @import("cf-conf-load.zig");
const plan = @import("pl-plan-buil.zig");
const vari = @import("ut-path-vari.zig");
test "kind maps to class" {
try std.testing.expectEqual(plan.Clas.safe, plan.clasOf(.nati));
try std.testing.expectEqual(plan.Clas.safe, plan.clasOf(.fwds));
try std.testing.expectEqual(plan.Clas.safe, plan.clasOf(.rela));
try std.testing.expectEqual(plan.Clas.enco, plan.clasOf(.dbls));
try std.testing.expectEqual(plan.Clas.enco, plan.clasOf(.urlz));
try std.testing.expectEqual(plan.Clas.comp, plan.clasOf(.bare));
}
test "safe is never skipped, even if every key is true" {
const conf: cfgz.Conf = .{};
try std.testing.expect(!plan.skipOf(conf, .safe));
try std.testing.expect(plan.skipOf(conf, .comp) and plan.skipOf(conf, .enco));
}
test "flipping a key to false applies that class only" {
var conf: cfgz.Conf = .{};
conf.skip_comp_part = false;
try std.testing.expect(!plan.skipOf(conf, .comp));
try std.testing.expect(plan.skipOf(conf, .enco));
conf.skip_enco_vari = false;
try std.testing.expect(!plan.skipOf(conf, .enco));
}
fn item(clas: plan.Clas, skip: bool) plan.Item { return .{ .path = "p", .line = 1, .offz = 0, .lenz = 1, .kind = .fwds, .clas = clas, .skip = skip, .newz = "n" }; }
test "summary counts apply and skip by class" {
const list = [_]plan.Item{ item(.safe, false), item(.safe, false), item(.comp, true), item(.enco, true), item(.enco, true), item(.comp, false) };
const summ = plan.summOf(&list);
try std.testing.expectEqual(@as(usize, 3), summ.appl);
try std.testing.expectEqual(@as(usize, 3), summ.skip);
try std.testing.expectEqual(@as(usize, 1), summ.comp);
try std.testing.expectEqual(@as(usize, 2), summ.enco);
}
test "empty plan counts zero" {
const summ = plan.summOf(&.{});
try std.testing.expectEqual(@as(usize, 0), summ.appl + summ.skip + summ.comp + summ.enco);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
