// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for risk class by path and file name
// Flo: each class alone > own home vs other user > combos > case rules
// I/O: none > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\rn-name-upda\build.zig
// ===================================================================
const std = @import("std");
const risk = @import("ut-risk-clas.zig");
const plan = @import("pl-plan-buil.zig");
const osys = @import("ut-osys-adap.zig");
const cfgz = @import("cf-conf-load.zig");
const WIN: osys.Osys = .{ .wind = true, .caze = true };
const NIX: osys.Osys = .{ .wind = false, .caze = false };
fn has(mask: u16, clas: plan.Clas) bool { return mask & plan.bitOf(clas) != 0; }
test "plain user file has no risk" {
const conf: cfgz.Conf = .{};
try std.testing.expectEqual(@as(u16, 0), risk.pathMask(NIX, conf, "/home/me", "/home/me/proj/a.txt"));
try std.testing.expectEqual(@as(u16, 0), risk.pathMask(WIN, conf, "C:/Users/me", "C:/Users/me/proj/a.txt"));
try std.testing.expectEqual(@as(u16, 0), risk.pathMask(WIN, conf, "C:/Users/me", "E:/work/a.txt"));
}
test "another user's tree is flagged, own tree and the users dir itself are not" {
const conf: cfgz.Conf = .{};
try std.testing.expect(has(risk.pathMask(NIX, conf, "/home/me", "/home/bob/a.txt"), .othe));
try std.testing.expect(has(risk.pathMask(WIN, conf, "C:/Users/me", "C:/Users/Bob/Desktop/a.txt"), .othe));
try std.testing.expect(!has(risk.pathMask(NIX, conf, "/home/me", "/home/me/a.txt"), .othe));
try std.testing.expect(!has(risk.pathMask(NIX, conf, "/home/me", "/home"), .othe));
try std.testing.expect(has(risk.pathMask(NIX, conf, "/home/me", "/home/me2/a.txt"), .othe));
}
test "system and package locations" {
const conf: cfgz.Conf = .{};
try std.testing.expect(has(risk.pathMask(NIX, conf, "/home/me", "/etc/hosts"), .syst));
try std.testing.expect(has(risk.pathMask(NIX, conf, "/home/me", "/usr/local/bin/x"), .syst));
try std.testing.expect(has(risk.pathMask(NIX, conf, "/home/me", "/usr/local/bin/x"), .pack));
try std.testing.expect(has(risk.pathMask(WIN, conf, "C:/Users/me", "C:/Windows/System32/x.ini"), .syst));
try std.testing.expect(has(risk.pathMask(WIN, conf, "C:/Users/me", "c:/program files/App/x.ini"), .pack));
try std.testing.expect(!has(risk.pathMask(NIX, conf, "/home/me", "/etcetera/x"), .syst));
try std.testing.expect(!has(risk.pathMask(NIX, conf, "/home/me", "/home/me/etc/x"), .syst));
}
test "git and sync folders" {
const conf: cfgz.Conf = .{};
try std.testing.expect(has(risk.pathMask(NIX, conf, "/home/me", "/home/me/r/.git/config"), .gitz));
try std.testing.expect(!has(risk.pathMask(NIX, conf, "/home/me", "/home/me/r/.github/x.yml"), .gitz));
try std.testing.expect(has(risk.pathMask(WIN, conf, "C:/Users/me", "C:/Users/me/OneDrive - Corp/a.txt"), .sync));
try std.testing.expect(has(risk.pathMask(NIX, conf, "/home/me", "/home/me/Dropbox/a.txt"), .sync));
try std.testing.expect(has(risk.pathMask(WIN, conf, "C:/Users/me", "//srv/share/a.txt"), .sync));
}
test "signed or hashed files and archives by name" {
const conf: cfgz.Conf = .{};
try std.testing.expect(has(risk.pathMask(NIX, conf, "/h", "/h/p/package-lock.json"), .sign));
try std.testing.expect(has(risk.pathMask(NIX, conf, "/h", "/h/p/mise.lock"), .sign));
try std.testing.expect(has(risk.pathMask(NIX, conf, "/h", "/h/p/a.tar.gz.sig"), .sign));
try std.testing.expect(has(risk.pathMask(NIX, conf, "/h", "/h/p/go.sum"), .sign));
try std.testing.expect(!has(risk.pathMask(NIX, conf, "/h", "/h/p/lockfile.txt"), .sign));
try std.testing.expect(has(risk.pathMask(NIX, conf, "/h", "/h/p/a.docx"), .arch));
try std.testing.expect(has(risk.pathMask(WIN, conf, "C:/h", "C:/h/p/A.ZIP"), .arch));
try std.testing.expect(!has(risk.pathMask(NIX, conf, "/h", "/h/p/A.ZIP"), .arch));
}
test "several risks stack in one mask" {
const conf: cfgz.Conf = .{};
const mask = risk.pathMask(NIX, conf, "/home/me", "/home/bob/Dropbox/r/.git/config.lock");
try std.testing.expect(has(mask, .othe) and has(mask, .sync) and has(mask, .gitz) and has(mask, .sign));
}
test "custom lists replace the defaults" {
var conf: cfgz.Conf = .{};
conf.risk_syst_list = &.{"/srv"};
try std.testing.expect(has(risk.pathMask(NIX, conf, "/h", "/srv/x"), .syst));
try std.testing.expect(!has(risk.pathMask(NIX, conf, "/h", "/etc/x"), .syst));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
