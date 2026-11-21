// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Shared command context: config, data dir, output, db, keys
// Flo: find config beside exe > load > expand ~ in data dir > open db on demand > print lines to stdout
// I/O: process Init + Args (main) > Ctx; text out on stdout
// ===================================================================
const std = @import("std"); const cfgz = @import("cf-conf-load.zig"); const targ = @import("ct-ctrl-args.zig"); const pexp = @import("ut-path-expa.zig"); const inde = @import("st-page-inde.zig"); const sqli = @import("st-stor-sqli.zig"); const live = @import("nt-vend-live.zig"); const site = @import("cf-site-rule.zig");
const CF = .{ .file = "aa-conf-main.json", .cand = [_][]const u8{ "..", "../..", "." }, .dbfi = "scra-index.db" };
pub const Ctx = struct { init: std.process.Init, allo: std.mem.Allocator, iozz: std.Io, conf: cfgz.Conf, args: targ.Args, dirz: []const u8, home: []const u8 };
pub fn confFind(allo: std.mem.Allocator, iozz: std.Io, args: targ.Args) !cfgz.Conf { if (args.conf.len > 0) return cfgz.confLoad(allo, iozz, args.conf); const dirz = std.process.executableDirPathAlloc(iozz, allo) catch "."; for (CF.cand) |rela| { const path = std.fs.path.join(allo, &.{ dirz, rela, CF.file }) catch continue; _ = std.Io.Dir.cwd().statFile(iozz, path, .{}) catch continue; return cfgz.confLoad(allo, iozz, path); } return .{}; }
pub fn ctxMake(init: std.process.Init, args: targ.Args) !Ctx { const allo = init.arena.allocator(); const conf = try confFind(allo, init.io, args); var diag: site.Diag = .{}; site.siteChek(conf, &diag) catch { std.debug.print("config error: {s}\n", .{diag.text}); return error.BadConfig; }; const home = init.environ_map.get("USERPROFILE") orelse init.environ_map.get("HOME") orelse ""; const dirz = pexp.pathExpa(allo, home, conf.data_dirz_path) catch return error.BadConfig; return .{ .init = init, .allo = allo, .iozz = init.io, .conf = conf, .args = args, .dirz = dirz, .home = home }; }
pub fn outz(ctx: *const Ctx, text: []const u8) !void { const line = try std.fmt.allocPrint(ctx.allo, "{s}\n", .{text}); try std.Io.File.stdout().writeStreamingAll(ctx.iozz, line); }
pub fn dbHave(ctx: *const Ctx) bool { const path = std.fs.path.join(ctx.allo, &.{ ctx.dirz, CF.dbfi }) catch return false; _ = std.Io.Dir.cwd().statFile(ctx.iozz, path, .{}) catch return false; return true; }
pub fn dbOpen(ctx: *const Ctx) !sqli.Db { return inde.pageOpen(ctx.allo, ctx.iozz, ctx.dirz); }
pub fn realMake(ctx: *const Ctx) !live.Real { const keyd = pexp.pathExpa(ctx.allo, ctx.home, ctx.conf.vend_keyz_dirz) catch return error.BadConfig; return .{ .gpaz = ctx.init.gpa, .conf = ctx.conf, .keyd = keyd, .live = .{ .time_mill = ctx.conf.fetc_time_seco * 1000 } }; }
pub fn jsonOr(ctx: *const Ctx, valu: anytype, plain: []const u8) ![]const u8 { if (ctx.args.json) return std.json.Stringify.valueAlloc(ctx.allo, valu, .{}); return plain; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
