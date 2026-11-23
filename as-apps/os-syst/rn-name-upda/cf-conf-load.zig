// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Load aa-conf-main.json into typed settings with built-in defaults
// Flo: pick path (flag > ./ > ./as-apps/os-syst/rn-name-upda/) > read > parse JSON > fill missing keys with defaults
// I/O: optional path > Conf struct; an explicit bad path is an error, a missing default file is not
// ===================================================================
const std = @import("std");
const CF = .{ .maxz = 1024 * 1024, .name = "aa-conf-main.json", .nest = "as-apps/os-syst/rn-name-upda/aa-conf-main.json" };
pub const Conf = struct {
apps_data_loca: []const u8 = "as-apps/os-syst/rn-name-upda",
tena_loca_wind: []const u8 = "E:\\.zz-base-home-tena",
tena_loca_unix: []const u8 = ".zz-base-home-tena",
scan_root_list: []const []const u8 = &.{},
scan_maxz: u64 = 64,
scan_deep: u32 = 96,
scan_skip_list: []const []const u8 = &.{ "/proc", "/sys", "/dev", "C:/Windows", "System Volume Information", "$Recycle.Bin", "zz-dele-auto", ".zig-cache", ".git/objects", "node_modules" },
skip_bina: bool = true,
skip_arch: bool = true,
skip_sign_hash: bool = true,
skip_othe_user: bool = true,
skip_syst_owne: bool = true,
skip_runn_proc: bool = true,
skip_sync_remo: bool = true,
skip_pack_mana: bool = true,
skip_comp_part: bool = true,
skip_urls_exte: bool = true,
skip_enco_vari: bool = true,
skip_gitz_hist: bool = true,
skip_path_list: []const []const u8 = &.{},
skip_glob_list: []const []const u8 = &.{},
lock_retr: u32 = 3,
plan_line_maxz: usize = 200,
};
pub fn confParse(allo: std.mem.Allocator, data: []const u8) !Conf { return std.json.parseFromSliceLeaky(Conf, allo, data, .{ .ignore_unknown_fields = true, .allocate = .alloc_always }); }
pub fn confLoad(allo: std.mem.Allocator, iozz: std.Io, path: ?[]const u8) !Conf {
if (path) |explicit| {
const data = try std.Io.Dir.cwd().readFileAlloc(iozz, explicit, allo, .limited(CF.maxz));
return confParse(allo, data);
}
const cand = [_][]const u8{ CF.name, CF.nest };
for (cand) |item| {
const data = std.Io.Dir.cwd().readFileAlloc(iozz, item, allo, .limited(CF.maxz)) catch continue;
return confParse(allo, data);
}
return .{};
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
