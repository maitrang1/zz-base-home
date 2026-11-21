// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for v5 doct host checks: tools, CPU, patches
// Flo: mock runner + overridden OS tag and CPU model > one check each > status and note
// I/O: none live > pass or fail
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\wo-work-mode\build.zig
// ===================================================================
const std = @import("std");
const doct = @import("ct-comm-doct.zig");
const make = @import("te-ctxz-make.zig");
const mock = @import("te-mock-runn.zig");
const cfgz = @import("cf-conf-load.zig");
const host = @import("ob-host-fact.zig");
const exit = @import("ct-exit-code.zig");
const NOWZ = make.NOWZ;
const Pick = struct { name: []const u8, ostg: std.Target.Os.Tag = .linux, cpum: []const u8 = "x86_64", prof: []const u8 = "t0" };
fn runOne(allo: std.mem.Allocator, rule: []const mock.Rule, pick: Pick) !struct { code: exit.Code, text: []const u8 } {
var mck: mock.Mock = .{ .rule = rule };
var buff: std.Io.Writer.Allocating = .init(allo);
const list = try allo.dupe([]const u8, &.{pick.name});
var cfgv: cfgz.Conf = .{};
cfgv.chek_t0_list = list;
cfgv.chek_box_list = list;
var ctxz = make.make(allo, &buff.writer, &mck, cfgv, "h", false, false);
ctxz.ostg = pick.ostg;
ctxz.cpum = pick.cpum;
ctxz.prof = pick.prof;
const code = try doct.comm(&ctxz, &.{});
return .{ .code = code, .text = buff.written() };
}
fn has(text: []const u8, part: []const u8) bool { return std.mem.indexOf(u8, text, part) != null; }
test "accepted risk turns drift and blocked into okay, keeps the reason, ignores other checks" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
var mck: mock.Mock = .{ .rule = &.{} };
var buff: std.Io.Writer.Allocating = .init(allo);
var cfgv: cfgz.Conf = .{};
cfgv.chek_t0_list = &.{ "esus", "tsfl" };
cfgv.doct_acpt_list = &.{"esus"};
var ctxz = make.make(allo, &buff.writer, &mck, cfgv, "h", false, false);
ctxz.ostg = .windows;
const code = try doct.comm(&ctxz, &.{});
try std.testing.expectEqual(exit.Code.bloc, code);
try std.testing.expect(has(buff.written(), "accepted risk: ConsumerESU key absent"));
try std.testing.expect(has(buff.written(), "bloc\ttsfl"));
}
test "tailscale floor: above, equal, below, absent, junk" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
const up = try runOne(allo, &.{.{ .pref = &.{ "tailscale", "version" }, .outz = "1.104.5\n  tailscale commit: x\n" }}, .{ .name = "tsfl" });
try std.testing.expectEqual(exit.Code.okay, up.code);
const eq = try runOne(allo, &.{.{ .pref = &.{ "tailscale", "version" }, .outz = "1.102.1\n" }}, .{ .name = "tsfl" });
try std.testing.expectEqual(exit.Code.okay, eq.code);
const lo = try runOne(allo, &.{.{ .pref = &.{ "tailscale", "version" }, .outz = "1.98.8\n" }}, .{ .name = "tsfl" });
try std.testing.expectEqual(exit.Code.drif, lo.code);
try std.testing.expect(has(lo.text, "below floor 1.102.1"));
const ab = try runOne(allo, &.{}, .{ .name = "tsfl" });
try std.testing.expectEqual(exit.Code.bloc, ab.code);
const jk = try runOne(allo, &.{.{ .pref = &.{ "tailscale", "version" }, .outz = "dev-build\n" }}, .{ .name = "tsfl" });
try std.testing.expectEqual(exit.Code.bloc, jk.code);
}
test "claude floor runs on the box profile and reads the first token" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
const lo = try runOne(allo, &.{.{ .pref = &.{ "claude", "--version" }, .outz = "2.1.285 (Claude Code)\n" }}, .{ .name = "clfl", .prof = "box" });
try std.testing.expectEqual(exit.Code.drif, lo.code);
try std.testing.expect(has(lo.text, "claude 2.1.285 below floor 2.1.302"));
const ok = try runOne(allo, &.{.{ .pref = &.{ "claude", "--version" }, .outz = "2.1.302 (Claude Code)\n" }}, .{ .name = "clfl", .prof = "box" });
try std.testing.expectEqual(exit.Code.okay, ok.code);
}
test "tailnet lock: on, off, missing key, not json, not running" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
const pref: []const []const u8 = &.{ "tailscale", "lock", "status", "--json" };
const on = try runOne(allo, &.{.{ .pref = pref, .outz = "{\"Enabled\": true}" }}, .{ .name = "lock" });
try std.testing.expectEqual(exit.Code.okay, on.code);
const off = try runOne(allo, &.{.{ .pref = pref, .outz = "{\"Enabled\": false}" }}, .{ .name = "lock" });
try std.testing.expectEqual(exit.Code.drif, off.code);
const nok = try runOne(allo, &.{.{ .pref = pref, .outz = "{}" }}, .{ .name = "lock" });
try std.testing.expectEqual(exit.Code.bloc, nok.code);
const njs = try runOne(allo, &.{.{ .pref = pref, .outz = "oops" }}, .{ .name = "lock" });
try std.testing.expectEqual(exit.Code.bloc, njs.code);
const nrun = try runOne(allo, &.{.{ .pref = pref, .code = 1 }}, .{ .name = "lock" });
try std.testing.expectEqual(exit.Code.bloc, nrun.code);
}
test "cpu level: baseline models pass, a native model drifts" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
const base = try runOne(allo, &.{}, .{ .name = "cpuz", .cpum = "x86_64" });
try std.testing.expectEqual(exit.Code.okay, base.code);
const gene = try runOne(allo, &.{}, .{ .name = "cpuz", .cpum = "generic" });
try std.testing.expectEqual(exit.Code.okay, gene.code);
const nati = try runOne(allo, &.{}, .{ .name = "cpuz", .cpum = "skylake" });
try std.testing.expectEqual(exit.Code.drif, nati.code);
try std.testing.expect(has(nati.text, "built for skylake"));
try std.testing.expect(host.cpuOkay("x86_64_v2", &.{ "x86_64", "x86_64_v2" }));
try std.testing.expect(!host.cpuOkay("x86_64_v3", &.{ "x86_64", "x86_64_v2" }));
}
test "patch age on windows: fresh ok, old drifts, failure blocks" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
const fresh = try runOne(allo, &.{.{ .pref = &.{"powershell"}, .outz = "2023-11-10\n" }}, .{ .name = "patc", .ostg = .windows });
try std.testing.expectEqual(exit.Code.okay, fresh.code);
const old = try runOne(allo, &.{.{ .pref = &.{"powershell"}, .outz = "2023-06-01\n" }}, .{ .name = "patc", .ostg = .windows });
try std.testing.expectEqual(exit.Code.drif, old.code);
try std.testing.expect(has(old.text, "> 45"));
const bad = try runOne(allo, &.{.{ .pref = &.{"powershell"}, .code = 1 }}, .{ .name = "patc", .ostg = .windows });
try std.testing.expectEqual(exit.Code.bloc, bad.code);
const junk = try runOne(allo, &.{.{ .pref = &.{"powershell"}, .outz = "soon\n" }}, .{ .name = "patc", .ostg = .windows });
try std.testing.expectEqual(exit.Code.bloc, junk.code);
}
test "patch age on linux reads stat seconds; macos is unknown" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
const fresh = try runOne(allo, &.{.{ .pref = &.{ "stat", "-c", "%Y" }, .outz = "1699900000\n" }}, .{ .name = "patc", .ostg = .linux });
try std.testing.expectEqual(exit.Code.okay, fresh.code);
const old = try runOne(allo, &.{.{ .pref = &.{ "stat", "-c", "%Y" }, .outz = "1600000000\n" }}, .{ .name = "patc", .ostg = .linux });
try std.testing.expectEqual(exit.Code.drif, old.code);
const mac = try runOne(allo, &.{}, .{ .name = "patc", .ostg = .macos });
try std.testing.expectEqual(exit.Code.bloc, mac.code);
}
test "esus: enrolled, not enrolled, key absent, not windows" {
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
const allo = arna.allocator();
const pref: []const []const u8 = &.{ "reg.exe", "query" };
const head = "HKEY_CURRENT_USER\\SOFTWARE\\X\\ConsumerESU\r\n    ESUEligibilityResult    REG_DWORD    0x1\r\n    ESUEligibility    REG_DWORD    ";
const ok3 = try runOne(allo, &.{.{ .pref = pref, .outz = head ++ "0x3\r\n" }}, .{ .name = "esus", .ostg = .windows });
try std.testing.expectEqual(exit.Code.okay, ok3.code);
const ok5 = try runOne(allo, &.{.{ .pref = pref, .outz = head ++ "0x5\r\n" }}, .{ .name = "esus", .ostg = .windows });
try std.testing.expectEqual(exit.Code.okay, ok5.code);
const el2 = try runOne(allo, &.{.{ .pref = pref, .outz = head ++ "0x2\r\n" }}, .{ .name = "esus", .ostg = .windows });
try std.testing.expectEqual(exit.Code.drif, el2.code);
const gone = try runOne(allo, &.{.{ .pref = pref, .code = 1 }}, .{ .name = "esus", .ostg = .windows });
try std.testing.expectEqual(exit.Code.bloc, gone.code);
const lin = try runOne(allo, &.{}, .{ .name = "esus", .ostg = .linux });
try std.testing.expectEqual(exit.Code.okay, lin.code);
try std.testing.expect(has(lin.text, "not Windows"));
}
test "esus and date parsers" {
try std.testing.expectEqual(@as(?i64, 3), host.esusParse("  ESUEligibility    REG_DWORD    0x3\r\n"));
try std.testing.expectEqual(@as(?i64, null), host.esusParse("  ESUEligibilityResult    REG_DWORD    0x1\r\n"));
try std.testing.expectEqual(@as(?i64, null), host.esusParse(""));
var arna = std.heap.ArenaAllocator.init(std.testing.allocator);
defer arna.deinit();
try std.testing.expectEqual(@as(?i64, 1699574400), host.dateEpoc(arna.allocator(), "2023-11-10\r\n"));
try std.testing.expectEqual(@as(?i64, null), host.dateEpoc(arna.allocator(), "10/11/2023"));
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
