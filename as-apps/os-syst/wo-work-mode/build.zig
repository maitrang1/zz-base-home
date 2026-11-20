// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Build script: wo exe, dist targets, per-file tests
// Flo: CF consts > exe + run step > dist 4 targets (dist-dev = 2) > one test target per *-test.zig | keep CF.vers in step with build.zig.zon and ct-comm-stat.zig
// I/O: sibling *.zig + -Doptimize > zig-out/bin/wo(.exe), zig-out/dist/<os>-<arch>/, test run
// Run: zig build test --build-file E:\zz-base-home\as-apps\os-syst\wo-work-mode\build.zig
// ===================================================================
const std = @import("std");
const CF = .{ .exez = "wo", .root = "ct-ctrl-main.zig", .test_list = [_][]const u8{ "ct-exit-code-test.zig", "ob-fact-rept-test.zig", "ct-safe-ladd-test.zig", "cf-conf-load-test.zig", "st-stat-file-test.zig", "ru-cmdz-runn-test.zig", "ct-comm-doct-test.zig", "ct-comm-wipz-test.zig", "ct-comm-dril-test.zig", "ct-comm-kill-test.zig", "ct-comm-secr-test.zig", "ct-comm-stat-test.zig", "ct-comm-conf-test.zig", "ct-comm-bkup-test.zig", "ct-comm-docs-test.zig", "ct-comm-beat-test.zig", "ct-comm-rels-test.zig", "ct-comm-ci-test.zig", "ct-comm-push-test.zig","ut-vers-comp-test.zig", "ct-comm-doct-host-test.zig" }, .dist = [_]struct { dirz: []const u8, quer: std.Target.Query }{ .{ .dirz = "dist/windows-x86_64", .quer = .{ .cpu_arch = .x86_64, .os_tag = .windows, .cpu_model = .baseline } }, .{ .dirz = "dist/linux-x86_64", .quer = .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .musl, .cpu_model = .baseline } }, .{ .dirz = "dist/linux-aarch64", .quer = .{ .cpu_arch = .aarch64, .os_tag = .linux, .abi = .musl, .cpu_model = .baseline } }, .{ .dirz = "dist/macos-aarch64", .quer = .{ .cpu_arch = .aarch64, .os_tag = .macos, .cpu_model = .baseline } } }, .dev0 = 0, .dev1 = 1 };
fn modMake(buil: *std.Build, targ: std.Build.ResolvedTarget, opti: std.builtin.OptimizeMode, path: []const u8, strp: bool) *std.Build.Module { return buil.createModule(.{ .root_source_file = buil.path(path), .target = targ, .optimize = opti, .strip = strp }); }
pub fn build(buil: *std.Build) void {
const targ = buil.standardTargetOptions(.{ .default_target = .{ .cpu_model = .baseline } });
const opti = buil.standardOptimizeOption(.{});
const exez = buil.addExecutable(.{ .name = CF.exez, .root_module = modMake(buil, targ, opti, CF.root, false) });
buil.installArtifact(exez);
const runz = buil.addRunArtifact(exez);
runz.step.dependOn(buil.getInstallStep());
if (buil.args) |args| runz.addArgs(args);
buil.step("run", "Build and run wo").dependOn(&runz.step);
const stepDist = buil.step("dist", "Build every target (ReleaseFast) into zig-out/dist/<os>-<arch>/");
const stepDevz = buil.step("dist-dev", "Build only windows-x86_64 + linux-x86_64 into zig-out/dist/");
for (CF.dist, 0..) |dist, indx| {
const exed = buil.addExecutable(.{ .name = CF.exez, .root_module = modMake(buil, buil.resolveTargetQuery(dist.quer), .ReleaseFast, CF.root, true) });
const inst = buil.addInstallArtifact(exed, .{ .dest_dir = .{ .override = .{ .custom = dist.dirz } } });
stepDist.dependOn(&inst.step);
if (indx == CF.dev0 or indx == CF.dev1) stepDevz.dependOn(&inst.step);
}
const stepTest = buil.step("test", "Run all tests");
for (CF.test_list) |path| stepTest.dependOn(&buil.addRunArtifact(buil.addTest(.{ .root_module = modMake(buil, targ, opti, path, false) })).step);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
