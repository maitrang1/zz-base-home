// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Build script: exe, dist targets, auto-found tests
// Flo: CF consts > exe module > run step > dist-dev 2 targets > scan root for *-test.zig > one test run each
// I/O: sibling *.zig (project root) + -Doptimize (CLI) > zig-out/bin/scra(.exe), zig-out/dist/<os>-<arch>/, test run
// Run: zig build | zig build test | zig build dist-dev
// ===================================================================
const std = @import("std"); const Targ = std.Build.ResolvedTarget; const Opti = std.builtin.OptimizeMode;
const CF = .{ .exez = "scra", .root = "ru-main-root.zig", .tail = "-test.zig", .sqld = "../../../vd-vend-deps/sqlite-3540100/sqlite-amalgamation-3540100", .sqlf = @as([]const []const u8, &.{ "-DSQLITE_THREADSAFE=1", "-DSQLITE_OMIT_LOAD_EXTENSION", "-DSQLITE_DQS=0" }), .sqpf = [_][]const u8{ "st-", "ru-", "qu-", "sy-", "ct-", "ob-" }, .dist = [_]struct { dirz: []const u8, quer: std.Target.Query }{ .{ .dirz = "dist/windows-x86_64", .quer = .{ .cpu_arch = .x86_64, .os_tag = .windows } }, .{ .dirz = "dist/linux-x86_64", .quer = .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .musl } } } };
fn modMake(buil: *std.Build, targ: Targ, opti: Opti, path: []const u8) *std.Build.Module { const modu = buil.createModule(.{ .root_source_file = buil.path(path), .target = targ, .optimize = opti, .link_libc = true }); if (needSql(path)) { modu.addIncludePath(buil.path(CF.sqld)); modu.addCSourceFile(.{ .file = buil.path(CF.sqld ++ "/sqlite3.c"), .flags = CF.sqlf }); } return modu; }
fn needSql(path: []const u8) bool { if (std.mem.eql(u8, path, CF.root)) return true; for (CF.sqpf) |pref| if (std.mem.startsWith(u8, path, pref)) return true; return false; }
pub fn build(buil: *std.Build) void {
const targ = buil.standardTargetOptions(.{});
const opti = buil.standardOptimizeOption(.{});
const exez = buil.addExecutable(.{ .name = CF.exez, .root_module = modMake(buil, targ, opti, CF.root) }); buil.installArtifact(exez);
const runz = buil.addRunArtifact(exez); runz.step.dependOn(buil.getInstallStep()); if (buil.args) |args| runz.addArgs(args);
buil.step("run", "Build and run scra").dependOn(&runz.step);
const stepDevz = buil.step("dist-dev", "Build windows-x86_64 + linux-x86_64 into zig-out/dist/");
for (CF.dist) |dist| { const exed = buil.addExecutable(.{ .name = CF.exez, .root_module = modMake(buil, buil.resolveTargetQuery(dist.quer), .ReleaseSafe, CF.root) }); stepDevz.dependOn(&buil.addInstallArtifact(exed, .{ .dest_dir = .{ .override = .{ .custom = dist.dirz } }, .pdb_dir = .disabled }).step); }
const stepTest = buil.step("test", "Run every *-test.zig");
const iozz = buil.graph.io; var dirz = buil.build_root.handle.openDir(iozz, ".", .{ .iterate = true }) catch @panic("project root unreadable"); defer dirz.close(iozz);
var iter = dirz.iterate(); while (iter.next(iozz) catch @panic("scan project root")) |item| { if (item.kind != .file or !std.mem.endsWith(u8, item.name, CF.tail)) continue; const rela = buil.allocator.dupe(u8, item.name) catch @panic("OOM"); stepTest.dependOn(&buil.addRunArtifact(buil.addTest(.{ .root_module = modMake(buil, targ, .Debug, rela) })).step); }
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
