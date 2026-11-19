// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Load aa-conf-main.json into typed settings with built-in defaults
// Flo: pick path (flag > ./ > ./as-apps/os-syst/wo-work-mode/) > read > parse JSON > fill missing keys with defaults
// I/O: optional path > Conf struct; an explicit bad path is an error, a missing default file is not
// ===================================================================
const std = @import("std");
const CF = .{ .maxz = 1024 * 1024, .name = "aa-conf-main.json", .nest = "as-apps/os-syst/wo-work-mode/aa-conf-main.json" };
pub const Conf = struct {
apps_data_loca: []const u8 = ".wo-work-mode",
secr_home_loca: []const u8 = ".zz-base-home-secr",
hook_path_main: []const u8 = "ci-flow-sync",
zigz_vers_pinz: []const u8 = "0.16.0",
wipz_ager_maxz: i64 = 1800,
bkup_ager_maxz: i64 = 1800,
dril_ager_maxz: i64 = 3024000,
dril_rtoz_maxz: i64 = 900,
tail_days_minz: i64 = 14,
tail_vers_minz: []const u8 = "1.102.1",
clau_vers_minz: []const u8 = "2.1.302",
patc_days_maxz: i64 = 45,
cpuz_okay_list: []const []const u8 = &.{ "x86_64", "x86_64_v2", "generic" },
devi_name_main: []const u8 = "",
prof_main: []const u8 = "t0",
chek_t0_list: []const []const u8 = &.{ "hook", "head", "tool", "cpuz", "wipz", "bkup", "bknt", "dril", "tail", "tsfl", "lock", "patc", "esus" },
chek_box_list: []const []const u8 = &.{ "hook", "head", "tool", "cpuz", "wipz", "bkup", "bknt", "dril", "tail", "tsfl", "lock", "patc", "clfl" },
chek_ci_list: []const []const u8 = &.{ "hook", "tool", "cpuz" },
wipz_remo_list: []const []const u8 = &.{},
wipz_file_maxz: u64 = 10485760,
wipz_rest_tagz: []const u8 = "wipz-held",
dril_mirr_dirz: []const u8 = "",
bkup_list_file: []const u8 = "mo-modu/mo-core/bk-back-modu/bk-stat-list.txt",
bkup_dbzz_list: []const []const u8 = &.{},
bkup_docs_list: []const []const u8 = &.{ "do-", "aa-todo-", "ag-agen", "CLAUDE.md", "AGENTS.md" },
bkup_tagz_stat: []const u8 = "stat",
bkup_tagz_nigh: []const u8 = "nigh",
docs_gitd_name: []const u8 = ".zz-base-home-docs.git",
docs_remo_list: []const []const u8 = &.{ "origin", "mirr" },
bknt_ager_maxz: i64 = 100800,
kill_step_list: []const []const []const u8 = &.{ &.{ "gh", "variable", "set", "AGEN_ENAB", "--body", "false" }, &.{ "sudo", "-n", "-u", "agen", "claude", "auth", "logout" } },
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
