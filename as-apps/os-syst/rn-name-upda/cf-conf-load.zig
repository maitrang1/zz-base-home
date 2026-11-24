// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Load aa-conf-main.json into typed settings with built-in defaults
// Flo: pick path (flag > next to the exe > app root two levels above zig-out/bin > repo-relative) > read > parse JSON > fill missing keys with defaults
// I/O: optional path > Conf struct; an explicit bad path is an error, a missing default file is not
// ===================================================================
const std = @import("std");
const CF = .{ .maxz = 1024 * 1024, .name = "aa-conf-main.json", .nest = "as-apps/os-syst/rn-name-upda/aa-conf-main.json" };
pub const Conf = struct {
apps_data_loca: []const u8 = "as-apps/os-syst/rn-name-upda",
tena_loca_wind: []const u8 = "E:\\.zz-base-home-tena",
tena_loca_unix: []const u8 = ".zz-base-home-tena",
scan_root_list: []const []const u8 = &.{},
scan_alls_driv: bool = true,
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
skip_enco_vari: bool = false,
skip_gitz_hist: bool = true,
skip_path_list: []const []const u8 = &.{},
skip_glob_list: []const []const u8 = &.{},
scan_binz_maxz: u64 = 4,
scan_skip_ext: []const []const u8 = &.{ ".png", ".jpg", ".jpeg", ".gif", ".webp", ".bmp", ".mp3", ".mp4", ".mkv", ".avi", ".mov", ".flac", ".wav", ".pdf", ".exe", ".dll", ".so", ".dylib", ".o", ".obj", ".pdb", ".class", ".pyc", ".woff", ".woff2", ".ttf", ".otf", ".bin", ".dat", ".db", ".sqlite", ".iso", ".img", ".vhd", ".vmdk", ".zip", ".7z", ".rar", ".gz", ".tgz", ".bz2", ".xz", ".jar", ".apk", ".whl" },
risk_syst_list: []const []const u8 = &.{ "C:/Windows", "C:/ProgramData", "/etc", "/usr", "/var", "/Library", "/System", "/sbin", "/bin", "/lib", "/boot" },
risk_pack_list: []const []const u8 = &.{ "C:/Program Files", "C:/Program Files (x86)", "/opt", "/snap", "/usr/local", "/usr/lib", "/usr/share" },
risk_sync_list: []const []const u8 = &.{ "OneDrive", "Dropbox", "Google Drive", "iCloud", "Nextcloud", "MEGA", "pCloud" },
risk_user_list: []const []const u8 = &.{ "C:/Users", "/home", "/Users" },
risk_sign_list: []const []const u8 = &.{ ".lock", "-lock.json", ".sig", ".asc", ".gpg", ".sha256", ".sha512", ".md5", "go.sum" },
risk_arch_list: []const []const u8 = &.{ ".zip", ".7z", ".rar", ".tar", ".gz", ".tgz", ".bz2", ".xz", ".docx", ".xlsx", ".pptx", ".odt", ".ods", ".apk", ".jar", ".whl", ".epub", ".iso" },
loca_on: bool = true,
loca_regk_list: []const []const u8 = &.{ "HKCU\\Environment", "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run", "HKCU\\Software\\Microsoft\\Command Processor", "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment", "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run", "HKLM\\SYSTEM\\CurrentControlSet\\Services" },
lock_retr: u32 = 3,
plan_line_maxz: usize = 200,
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
