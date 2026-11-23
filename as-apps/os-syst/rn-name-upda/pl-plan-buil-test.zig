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
var conf: cfgz.Conf = .{};
conf.skip_enco_vari = true;
try std.testing.expect(!plan.skipOf(conf, .safe));
try std.testing.expect(plan.skipOf(conf, .comp) and plan.skipOf(conf, .enco));
}
test "defaults: bare name skipped, encoded forms applied (D12)" {
const conf: cfgz.Conf = .{};
try std.testing.expect(plan.skipOf(conf, .comp));
try std.testing.expect(!plan.skipOf(conf, .enco));
}
test "flipping a key applies that class only" {
var conf: cfgz.Conf = .{};
conf.skip_enco_vari = true;
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
test "every class has its own key; only safe and enco apply by default" {
const conf: cfgz.Conf = .{};
inline for (@typeInfo(plan.Clas).@"enum".field_names, 0..) |name, indx| {
const clas: plan.Clas = @enumFromInt(indx);
const want = !(std.mem.eql(u8, name, "safe") or std.mem.eql(u8, name, "enco"));
try std.testing.expectEqual(want, plan.skipOf(conf, clas));
}
}
test "class bits are unique" {
var seen: u16 = 0;
inline for (0..13) |indx| {
const bit = plan.bitOf(@enumFromInt(indx));
try std.testing.expectEqual(@as(u16, 0), seen & bit);
seen |= bit;
}
try std.testing.expectEqual(@as(u16, 0x1FFF), seen);
}
test "firstOf follows the severity order" {
try std.testing.expectEqual(plan.Clas.safe, plan.firstOf(0));
try std.testing.expectEqual(plan.Clas.sign, plan.firstOf(plan.bitOf(.sign) | plan.bitOf(.gitz)));
try std.testing.expectEqual(plan.Clas.syst, plan.firstOf(plan.bitOf(.pack) | plan.bitOf(.syst)));
try std.testing.expectEqual(plan.Clas.bina, plan.firstOf(plan.bitOf(.comp) | plan.bitOf(.bina)));
try std.testing.expectEqual(plan.Clas.comp, plan.firstOf(plan.bitOf(.comp)));
}
test "decide: a clean kind in a clean place applies" {
const dec = plan.decide(.{}, 0, .fwds, false, true);
try std.testing.expect(!dec.skip);
try std.testing.expectEqual(plan.Clas.safe, dec.clas);
}
test "decide: a risky place skips, and any one skip key is enough" {
const dec = plan.decide(.{}, plan.bitOf(.syst), .fwds, false, true);
try std.testing.expect(dec.skip);
try std.testing.expectEqual(plan.Clas.syst, dec.clas);
var conf: cfgz.Conf = .{};
conf.skip_syst_owne = false;
try std.testing.expect(!plan.decide(conf, plan.bitOf(.syst), .fwds, false, true).skip);
try std.testing.expect(plan.decide(conf, plan.bitOf(.syst) | plan.bitOf(.gitz), .fwds, false, true).skip);
}
test "decide: bare name is comp, url kinds are enco and apply by default" {
try std.testing.expect(plan.decide(.{}, 0, .bare, false, true).skip);
try std.testing.expect(!plan.decide(.{}, 0, .urlz, false, true).skip);
try std.testing.expectEqual(plan.Clas.enco, plan.decide(.{}, 0, .dbls, false, true).clas);
}
test "decide: binary needs its key off and the same length" {
try std.testing.expect(plan.decide(.{}, 0, .fwds, true, true).skip);
var conf: cfgz.Conf = .{};
conf.skip_bina = false;
const same = plan.decide(conf, 0, .fwds, true, true);
try std.testing.expect(!same.skip);
try std.testing.expectEqual(plan.Clas.bina, same.clas);
try std.testing.expect(plan.decide(conf, 0, .fwds, true, false).skip);
try std.testing.expectEqual(plan.Clas.bina, plan.decide(conf, 0, .u16l, false, true).clas);
}
test "location refs count like items and combine" {
const lrefs = [_]plan.Lref{ .{ .kind = .regv, .name = "a", .oldv = "", .newv = "" }, .{ .kind = .link, .name = "b", .oldv = "", .newv = "", .clas = .syst, .skip = true }, .{ .kind = .cron, .name = "c", .oldv = "", .newv = "", .clas = .comp, .skip = true } };
const sl = plan.summL(&lrefs);
try std.testing.expectEqual(@as(usize, 1), sl.appl);
try std.testing.expectEqual(@as(usize, 2), sl.skip);
try std.testing.expectEqual(@as(usize, 1), sl.risk);
try std.testing.expectEqual(@as(usize, 1), sl.comp);
const all = plan.summAdd(sl, plan.summOf(&[_]plan.Item{ item(.safe, false), item(.gitz, true) }));
try std.testing.expectEqual(@as(usize, 2), all.appl);
try std.testing.expectEqual(@as(usize, 3), all.skip);
try std.testing.expectEqual(@as(usize, 2), all.risk);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
