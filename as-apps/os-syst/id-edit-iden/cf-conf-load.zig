// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Load aa-conf-main.json into typed settings with built-in defaults
// Flo: pick path (flag > next to the exe > app root two levels above zig-out/bin > repo-relative) > read > parse JSON > fill missing keys with defaults
// I/O: optional path > Conf struct; an explicit bad path is an error, a missing default file is not
// ===================================================================
const std = @import("std");
const CF = .{ .maxz = 1024 * 1024, .name = "aa-conf-main.json", .nest = "as-apps/os-syst/id-edit-iden/aa-conf-main.json" };
pub const Conf = struct {
apps_data_loca: []const u8 = "as-apps/os-syst/id-edit-iden",
tena_loca_wind: []const u8 = "E:\\.zz-base-home-tena",
tena_loca_unix: []const u8 = ".zz-base-home-tena",
repo_root: []const u8 = "",
hubz_dirz: []const u8 = "ac-auto-task",
hubz_conf_name: []const u8 = "aa-conf-main.json",
hubz_jobs_pref: []const u8 = "aa-auto-task",
hubz_host: []const u8 = "127.0.0.1",
hubz_chec_on: bool = true,
hubz_wait_seco: u32 = 20,
disp_file_list: []const []const u8 = &.{ "ac-auto-task/ba-cmds-wind.bat", "ac-auto-task/sh-cmds-linu.sh" },
scan_skip_dirs: []const []const u8 = &.{ ".git", "zig-out", ".zig-cache", "zz-dele-auto", "node_modules", "aa-todo-note", "id-edit-iden" },
scan_skip_pref: []const []const u8 = &.{"zzzz-dele-"},
scan_skip_name: []const []const u8 = &.{ "UPDATE.md", "wo-buil-logz.txt" },
scan_live_ext: []const []const u8 = &.{ ".json", ".bat", ".cmd", ".sh", ".ps1", ".zig", ".zon", ".js", ".html", ".css" },
scan_docs_ext: []const []const u8 = &.{ ".txt", ".md" },
scan_docs_on: bool = true,
scan_maxz_mbyt: u64 = 4,
scan_deep: u32 = 24,
lock_stal_seco: u32 = 600,
curl_name_wind: []const u8 = "curl.exe",
curl_name_unix: []const u8 = "curl",
};
pub fn confParse(allo: std.mem.Allocator, data: []const u8) !Conf { return std.json.parseFromSliceLeaky(Conf, allo, data, .{ .ignore_unknown_fields = true, .allocate = .alloc_always }); }
pub fn confLoad(allo: std.mem.Allocator, iozz: std.Io, path: ?[]const u8) !Conf {
if (path) |explicit| {
const data = try std.Io.Dir.cwd().readFileAlloc(iozz, explicit, allo, .limited(CF.maxz));
return confParse(allo, data);
}
const exed: ?[]const u8 = std.process.executableDirPathAlloc(iozz, allo) catch null;
for (try candList(allo, exed)) |item| {
const data = std.Io.Dir.cwd().readFileAlloc(iozz, item, allo, .limited(CF.maxz)) catch continue;
return confParse(allo, data);
}
return .{};
}
pub fn candList(allo: std.mem.Allocator, exed: ?[]const u8) ![]const []const u8 {
var list: std.ArrayList([]const u8) = .empty;
if (exed) |dirz| {
try list.append(allo, try std.fs.path.join(allo, &.{ dirz, CF.name }));
try list.append(allo, try std.fs.path.join(allo, &.{ dirz, "..", "..", CF.name }));
}
try list.append(allo, CF.nest);
return list.toOwnedSlice(allo);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
