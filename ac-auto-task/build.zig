// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Build script: exe, dist targets, per-module tests
// Flo: CF consts > named module graph per target (libc where needed) > exe + run step > dist 8 targets (dist-dev = 2) > per-file test targets with fresh dep instances | keep CF.vers in step with build.zig.zon
// I/O: sibling *.zig + UI files (project root) + -Doptimize/-Dembed (CLI) > zig-out/bin/auto-task(.exe), zig-out/dist/<os>-<arch>/, test run
// ===================================================================
const std = @import("std"); const Modu = std.Build.Module; const Targ = std.Build.ResolvedTarget; const Opti = std.builtin.OptimizeMode;
const CF = .{ .exez = "auto-task", .vers = "0.2.0", .dev0 = 0, .dev1 = 3, .dist = [_]struct { dirz: []const u8, quer: std.Target.Query }{ .{ .dirz = "dist/windows-x86_64", .quer = .{ .cpu_arch = .x86_64, .os_tag = .windows } }, .{ .dirz = "dist/windows-aarch64", .quer = .{ .cpu_arch = .aarch64, .os_tag = .windows } }, .{ .dirz = "dist/windows-x86", .quer = .{ .cpu_arch = .x86, .os_tag = .windows } }, .{ .dirz = "dist/linux-x86_64", .quer = .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .musl } }, .{ .dirz = "dist/linux-aarch64", .quer = .{ .cpu_arch = .aarch64, .os_tag = .linux, .abi = .musl } }, .{ .dirz = "dist/linux-arm", .quer = .{ .cpu_arch = .arm, .os_tag = .linux, .abi = .musleabihf } }, .{ .dirz = "dist/macos-aarch64", .quer = .{ .cpu_arch = .aarch64, .os_tag = .macos } }, .{ .dirz = "dist/macos-x86_64", .quer = .{ .cpu_arch = .x86_64, .os_tag = .macos } } } };
const Spec = struct { path: []const u8, libc: bool = false, deps: []const []const u8 = &.{} };
fn modMake(buil: *std.Build, targ: Targ, opti: Opti, path: []const u8, libc: ?bool) *Modu { return buil.createModule(.{ .root_source_file = buil.path(path), .target = targ, .optimize = opti, .link_libc = libc }); }
fn moduRoot(buil: *std.Build, targ: Targ, opti: Opti, embe: bool) *Modu {
const strp: ?bool = if (embe) true else null;
const modSpaw = modMake(buil, targ, opti, "ru-spaw-engi.zig", true); const modRegi = modMake(buil, targ, opti, "ru-jobz-regi.zig", true); const modStre = modMake(buil, targ, opti, "ru-outp-stre.zig", null); const modCwdz = modMake(buil, targ, opti, "ru-sess-cwdz.zig", null); const modStor = modMake(buil, targ, opti, "st-conf-stor.zig", true); const modHist = modMake(buil, targ, opti, "st-runz-hist.zig", true); const modWatc = modMake(buil, targ, opti, "ev-path-watc.zig", null); const modHttp = modMake(buil, targ, opti, "sv-main-http.zig", null); const modStat = modMake(buil, targ, opti, "sv-stat-cach.zig", null);
const opts = buil.addOptions(); opts.addOption([]const u8, "version", CF.vers); opts.addOption(bool, "embed", embe);
const modTaskStor = modMake(buil, targ, opti, "tk-task-stor.zig", null); const modTaskTime = modMake(buil, targ, opti, "tk-task-time.zig", true); const modTaskEven = modMake(buil, targ, opti, "ev-task-even.zig", null); const modTaskSupe = modMake(buil, targ, opti, "ru-task-supe.zig", true); const modTaskProb = modMake(buil, targ, opti, "ev-task-prob.zig", true); const modTaskArmz = modMake(buil, targ, opti, "tk-task-armz.zig", true); const modTaskTick = modMake(buil, targ, opti, "tk-task-tick.zig", true); const modServ = modMake(buil, targ, opti, "sv-main-serv.zig", true);
const modRoot = buil.createModule(.{ .root_source_file = buil.path("sv-main-root.zig"), .target = targ, .optimize = opti, .link_libc = true, .strip = strp });
modCwdz.addImport("store", modStor); modHist.addImport("store", modStor); modTaskStor.addImport("store", modStor); modTaskEven.addImport("watch", modWatc);
modStat.addImport("http", modHttp); modStat.addImport("assets", modAsse(buil, targ, opti, embe));
modTaskSupe.addImport("spawn", modSpaw); modTaskSupe.addImport("registry", modRegi); modTaskProb.addImport("spawn", modSpaw);
modTaskArmz.addImport("taskstore", modTaskStor); modTaskArmz.addImport("tasktime", modTaskTime); modTaskArmz.addImport("taskevent", modTaskEven); modTaskArmz.addImport("tasksuper", modTaskSupe); modTaskArmz.addImport("taskprobe", modTaskProb);
modTaskTick.addImport("taskstore", modTaskStor); modTaskTick.addImport("tasktime", modTaskTime); modTaskTick.addImport("taskarm", modTaskArmz); modTaskTick.addImport("taskevent", modTaskEven); modTaskTick.addImport("spawn", modSpaw); modTaskTick.addImport("registry", modRegi); modTaskTick.addImport("tasksuper", modTaskSupe); modTaskTick.addImport("taskprobe", modTaskProb); modTaskTick.addImport("store", modStor); modTaskTick.addImport("stream", modStre);
modSpaw.addImport("registry", modRegi); modSpaw.addImport("stream", modStre); modSpaw.addImport("cwd", modCwdz); modSpaw.addImport("store", modStor);
modServ.addImport("http", modHttp); modServ.addImport("spawn", modSpaw); modServ.addImport("registry", modRegi); modServ.addImport("stream", modStre); modServ.addImport("cwd", modCwdz); modServ.addImport("store", modStor); modServ.addImport("history", modHist); modServ.addImport("watch", modWatc); modServ.addImport("taskstore", modTaskStor); modServ.addImport("tasktime", modTaskTime); modServ.addImport("ticker", modTaskTick); modServ.addImport("static", modStat); modServ.addImport("build_options", opts.createModule());
modRoot.addImport("server", modServ); modRoot.addImport("store", modStor); modRoot.addImport("taskstore", modTaskStor); modRoot.addImport("ticker", modTaskTick); modRoot.addImport("spawn", modSpaw);
return modRoot;
}
fn testAddz(buil: *std.Build, targ: Targ, opti: Opti, step: *std.Build.Step, spec: Spec) void {
const tmod = modMake(buil, targ, opti, spec.path, spec.libc);
var made = std.StringHashMap(*Modu).init(buil.allocator); defer made.deinit();
var queu: std.ArrayList([]const u8) = .empty; defer queu.deinit(buil.allocator); for (spec.deps) |dep| queu.append(buil.allocator, dep) catch @panic("OOM");
var indx: usize = 0;
while (indx < queu.items.len) : (indx += 1) { const dep = queu.items[indx]; if (made.contains(dep)) continue; const modu = if (std.mem.eql(u8, dep, "assets")) modAsse(buil, targ, opti, false) else modMake(buil, targ, opti, depzPath(dep), depzLibc(dep)); made.put(dep, modu) catch @panic("OOM"); for (depzDepz(dep)) |sub| queu.append(buil.allocator, sub) catch @panic("OOM"); }
var iter = made.iterator(); while (iter.next()) |item| { for (depzDepz(item.key_ptr.*)) |sub| item.value_ptr.*.addImport(sub, made.get(sub).?); }
for (spec.deps) |dep| tmod.addImport(dep, made.get(dep).?);
step.dependOn(&buil.addRunArtifact(buil.addTest(.{ .root_module = tmod })).step);
}
pub fn build(buil: *std.Build) void {
const targ = buil.standardTargetOptions(.{});
const flag = buil.option(Opti, "optimize", "Debug | ReleaseSafe (default) | ReleaseFast | ReleaseSmall");
const opti: Opti = flag orelse switch (buil.graph.release_mode) { .fast => .ReleaseFast, .small => .ReleaseSmall, else => .ReleaseSafe };
const opte: Opti = flag orelse .Debug;
const embe = buil.option(bool, "embed", "Embed the UI files into the exe (default: false native, true dist)") orelse false;
const exez = buil.addExecutable(.{ .name = CF.exez, .root_module = moduRoot(buil, targ, opti, embe) }); buil.installArtifact(exez);
const runz = buil.addRunArtifact(exez); runz.step.dependOn(buil.getInstallStep()); runz.addPassthruArgs();
const stepRunz = buil.step("run", "Build and run auto-task"); stepRunz.dependOn(&runz.step);
const stepDist = buil.step("dist", "Build every target into zig-out/dist/<os>-<arch>/"); const stepDevz = buil.step("dist-dev", "Build only windows-x86_64 + linux-x86_64 into zig-out/dist/");
for (CF.dist, 0..) |dist, indx| { const exed = buil.addExecutable(.{ .name = CF.exez, .root_module = moduRoot(buil, buil.resolveTargetQuery(dist.quer), .ReleaseSafe, true) }); const inst = buil.addInstallArtifact(exed, .{ .dest_dir = .{ .override = .{ .custom = dist.dirz } }, .pdb_dir = .disabled }); stepDist.dependOn(&inst.step); if (indx == CF.dev0 or indx == CF.dev1) stepDevz.dependOn(&inst.step); }
const stepTest = buil.step("test", "Run module tests");
const TICK_DEPS: []const []const u8 = &.{ "taskstore", "tasktime", "taskarm", "taskevent", "spawn", "registry", "tasksuper", "taskprobe", "store", "stream" };
const list = [_]Spec{ .{ .path = "sv-main-http-test.zig" }, .{ .path = "sv-serv-base-test.zig" }, .{ .path = "sv-serv-task-test.zig", .deps = &.{"taskstore"} }, .{ .path = "ru-jobz-regi-test.zig", .libc = true }, .{ .path = "ru-paus-ctrl-test.zig", .libc = true }, .{ .path = "ru-sess-cwdz-test.zig", .deps = &.{"store"} }, .{ .path = "ru-outp-stre-test.zig" }, .{ .path = "tk-task-stor-test.zig", .deps = &.{"store"} }, .{ .path = "tk-stor-vali-test.zig", .deps = &.{"store"} }, .{ .path = "tk-stor-base-test.zig", .deps = &.{"store"} }, .{ .path = "tk-stor-chai-test.zig", .deps = &.{"store"} }, .{ .path = "tk-stor-stat-test.zig", .deps = &.{"store"} }, .{ .path = "ru-spaw-base-test.zig", .libc = true, .deps = &.{ "registry", "stream", "cwd", "store" } }, .{ .path = "ru-spaw-shel-test.zig", .libc = true, .deps = &.{ "registry", "stream", "cwd", "store" } }, .{ .path = "tk-task-time-test.zig", .libc = true }, .{ .path = "tk-time-base-test.zig", .libc = true }, .{ .path = "tk-time-cron-test.zig", .libc = true }, .{ .path = "tk-time-sola-test.zig", .libc = true }, .{ .path = "ev-task-even-test.zig", .deps = &.{"watch"} }, .{ .path = "ru-task-supe-test.zig", .libc = true, .deps = &.{ "spawn", "registry" } }, .{ .path = "ev-prob-base-test.zig", .libc = true, .deps = &.{"spawn"} }, .{ .path = "ev-prob-armz-test.zig", .libc = true, .deps = &.{"spawn"} }, .{ .path = "ev-prob-type-test.zig", .libc = true, .deps = &.{"spawn"} }, .{ .path = "ev-prob-netw-test.zig", .libc = true, .deps = &.{"spawn"} }, .{ .path = "ev-prob-plat-test.zig", .libc = true, .deps = &.{"spawn"} }, .{ .path = "tk-task-armz-test.zig", .libc = true, .deps = &.{ "taskstore", "tasktime", "taskevent", "tasksuper", "taskprobe" } }, .{ .path = "tk-task-tick-test.zig", .libc = true, .deps = TICK_DEPS }, .{ .path = "tk-tick-chai-test.zig", .libc = true, .deps = TICK_DEPS }, .{ .path = "tk-tick-chai-paus-test.zig", .libc = true, .deps = TICK_DEPS }, .{ .path = "tk-tick-work-test.zig", .libc = true, .deps = TICK_DEPS }, .{ .path = "tk-tick-manu-test.zig", .libc = true, .deps = TICK_DEPS }, .{ .path = "tk-tick-base-test.zig", .libc = true, .deps = TICK_DEPS }, .{ .path = "tk-tick-logz-test.zig", .libc = true, .deps = TICK_DEPS }, .{ .path = "sv-stat-cach-test.zig", .deps = &.{ "http", "assets" } }, .{ .path = "st-runz-hist-test.zig", .libc = true, .deps = &.{"store"} }, .{ .path = "st-conf-stor-test.zig", .libc = true }, .{ .path = "st-envi-fres-test.zig" } };
for (list) |spec| testAddz(buil, targ, opte, stepTest, spec);
}
fn modAsse(buil: *std.Build, targ: Targ, opti: Opti, embe: bool) *Modu {
const writ = buil.addWriteFiles();
var code: std.ArrayList(u8) = .empty; code.appendSlice(buil.allocator, "pub const File = struct { name: []const u8, data: []const u8 };\npub const files = [_]File{\n") catch @panic("OOM");
if (embe) { const iozz = buil.graph.io; var dirz = buil.root.openDir(iozz, ".", .{ .iterate = true }) catch @panic("project root unreadable"); defer dirz.close(iozz); var iter = dirz.iterate(); while (iter.next(iozz) catch @panic("scan project root")) |item| { if (item.kind != .file) continue; const extn = std.fs.path.extension(item.name); const okay = std.mem.eql(u8, extn, ".html") or std.mem.eql(u8, extn, ".css") or std.mem.eql(u8, extn, ".js") or std.mem.eql(u8, extn, ".ico"); if (!okay or std.mem.endsWith(u8, item.name, "-test.js")) continue; const rela = buil.allocator.dupe(u8, item.name) catch @panic("OOM"); _ = writ.addCopyFile(buil.path(rela), rela); code.appendSlice(buil.allocator, buil.fmt("    .{{ .name = \"{s}\", .data = @embedFile(\"{s}\") }},\n", .{ rela, rela })) catch @panic("OOM"); } }
code.appendSlice(buil.allocator, "};\n") catch @panic("OOM");
return buil.createModule(.{ .root_source_file = writ.add("assets.zig", code.items), .target = targ, .optimize = opti });
}
fn depzPath(name: []const u8) []const u8 {
if (std.mem.eql(u8, name, "taskstore")) return "tk-task-stor.zig"; if (std.mem.eql(u8, name, "tasktime")) return "tk-task-time.zig"; if (std.mem.eql(u8, name, "taskarm")) return "tk-task-armz.zig"; if (std.mem.eql(u8, name, "taskevent")) return "ev-task-even.zig"; if (std.mem.eql(u8, name, "tasksuper")) return "ru-task-supe.zig"; if (std.mem.eql(u8, name, "taskprobe")) return "ev-task-prob.zig"; if (std.mem.eql(u8, name, "watch")) return "ev-path-watc.zig";
if (std.mem.eql(u8, name, "spawn")) return "ru-spaw-engi.zig"; if (std.mem.eql(u8, name, "registry")) return "ru-jobz-regi.zig"; if (std.mem.eql(u8, name, "stream")) return "ru-outp-stre.zig"; if (std.mem.eql(u8, name, "cwd")) return "ru-sess-cwdz.zig"; if (std.mem.eql(u8, name, "store")) return "st-conf-stor.zig"; if (std.mem.eql(u8, name, "http")) return "sv-main-http.zig";
@panic("depzPath: unknown module name — add it here");
}
fn depzLibc(name: []const u8) bool { return std.mem.eql(u8, name, "tasktime") or std.mem.eql(u8, name, "taskarm") or std.mem.eql(u8, name, "store") or std.mem.eql(u8, name, "spawn") or std.mem.eql(u8, name, "registry") or std.mem.eql(u8, name, "tasksuper") or std.mem.eql(u8, name, "taskprobe"); }
fn depzDepz(name: []const u8) []const []const u8 {
if (std.mem.eql(u8, name, "taskarm")) return &.{ "taskstore", "tasktime", "taskevent", "tasksuper", "taskprobe" }; if (std.mem.eql(u8, name, "tasksuper")) return &.{ "spawn", "registry" }; if (std.mem.eql(u8, name, "taskevent")) return &.{"watch"}; if (std.mem.eql(u8, name, "taskstore")) return &.{"store"};
if (std.mem.eql(u8, name, "cwd")) return &.{"store"}; if (std.mem.eql(u8, name, "taskprobe")) return &.{"spawn"}; if (std.mem.eql(u8, name, "spawn")) return &.{ "registry", "stream", "cwd", "store" };
return &.{};
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
