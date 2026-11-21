// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Task types, limits, type lists, id check, defaults
// Flo: consts > types > list checks > normalize > id check
// I/O: Task fields > normalized Task, id verdict
// ===================================================================
const std = @import("std"); const builtin = @import("builtin"); const stor = @import("store");
pub const CF = .{ .maxz_file = 4 * 1024 * 1024, .file = "aa-auto-task.json", .maxz_tmoz_seco = 24 * 60 * 60, .maxz_retr = 10, .maxz_runz = 2048, .maxz_cwdz = 512, .maxz_lock = 32, .defa_tmoz_seco = 60 * 60, .maxz_idsz = 32, .maxz_pool = 64, .maxz_idenlen = 120, .stat_dirz = "task-state" };
pub const MAXZ_FILE = CF.maxz_file; pub const MAXZ_TMOZ_SECO = CF.maxz_tmoz_seco; pub const MAXZ_RETR = CF.maxz_retr; pub const MAXZ_RUNZ = CF.maxz_runz; pub const MAXZ_CWDZ = CF.maxz_cwdz; pub const MAXZ_LOCK = CF.maxz_lock; pub const DEFA_TMOZ_SECO: u32 = CF.defa_tmoz_seco; pub const MAXZ_IDSZ = CF.maxz_idsz; pub const MAXZ_PLUS_POOL = CF.maxz_pool; pub const STAT_DIRZ = CF.stat_dirz;
pub const TYPE_LIST = [_][]const u8{ "live", "boot", "cron", "disk", "mail", "even", "flag", "hand", "idle", "link", "loop", "once", "powe", "proc", "puls", "queu", "sola", "tcpr", "webs", "chai" };
pub const NONE_SCHE = [_][]const u8{ "boot", "mail", "hand", "loop", "chai" }; pub const WINZ_ONLY = [_][]const u8{}; pub const PLUS_MAXZ = [6]u32{ 10, 11, 30, 23, 59, 59 };
pub const CMDS_SCRI = if (builtin.os.tag == .windows) "ba-cmds-wind.bat" else "sh-cmds-linu.sh"; pub const PLUS_BIGZ = "plus: a value is too big (years 10, months 11, days 30, hours 23, mins 59, secs 59)";
pub fn typeChec(name: []const u8) bool { for (TYPE_LIST) |item| if (std.mem.eql(u8, item, name)) return true; return false; }
pub fn scheNeed(name: []const u8) bool { for (NONE_SCHE) |item| if (std.mem.eql(u8, item, name)) return false; return true; }
pub fn winzOnlyChec(name: []const u8) bool { for (WINZ_ONLY) |item| if (std.mem.eql(u8, item, name)) return true; return false; }
pub const Task = struct { id: []const u8 = "", type: []const u8 = "", on: bool = true, sche: ?[]const u8 = null, kind: []const u8 = "shell", run: []const u8 = "", cwd: ?[]const u8 = null, shell: ?[]const u8 = null, guard: ?[]const u8 = null, npd: ?u32 = null, dela: ?u32 = null, admin: ?bool = null, noLog: ?bool = null, tmo: ?u32 = null, @"try": ?u32 = null, dlyM: ?u32 = null, tmoS: ?u32 = null, retry: ?u32 = null, _cmt: ?[]const u8 = null, plat: ?[]const u8 = null, acc: ?[]const u8 = null, lock: ?[]const u8 = null, catchup: ?[]const u8 = null, catc: ?u8 = null, ids: ?[]const []const u8 = null, plus: ?std.json.Value = null };
pub const Reje = struct { inde: usize, iden: []const u8, whyz: []const u8 };
pub const Load = struct { aren: std.heap.ArenaAllocator, task: []Task, reje: []Reje, rawz_okay: bool, pub fn dein(self: *Load) void { self.aren.deinit(); } };
pub const ChaiStat = struct { inde: u32, ranz: u32, fail: u32, next_msec: i64, star_msec: i64 };
pub var jobzFile: []const u8 = CF.file;
pub fn jobzFileSet(name: []const u8) bool { if (name.len == 0 or name.len > 64 or !std.mem.endsWith(u8, name, ".json")) return false; if (std.mem.indexOfAny(u8, name, "/\\") != null or std.mem.indexOf(u8, name, "..") != null) return false; jobzFile = name; return true; }
pub fn taskPath(allo: std.mem.Allocator, root: []const u8) ![]const u8 { return std.fs.path.join(allo, &.{ root, jobzFile }); }
pub fn norm(tas0: Task) Task { var task = tas0; if (task.dela == null) task.dela = task.dlyM; if (task.tmo == null) task.tmo = task.tmoS; if (task.@"try" == null) task.@"try" = task.retry; if (task.catchup) |old| { const once = std.mem.eql(u8, old, "once"); if (once or std.mem.eql(u8, old, "none")) { if (task.catc == null) task.catc = if (once) 1 else 0; task.catchup = null; } } task.dlyM = null; task.tmoS = null; task.retry = null; return task; }
pub fn chaiChec(task: Task) bool { return std.mem.eql(u8, task.type, "chai"); }
pub fn autoIdenChec(iden: []const u8) bool { if (iden.len == 0) return false; for (iden) |char| { const okay = (char >= 'a' and char <= 'z') or (char >= 'A' and char <= 'Z') or (char >= '0' and char <= '9') or char == '-' or char == '_' or char == '.'; if (!okay) return false; } return true; }
pub fn idenVali(iden: []const u8) ?[]const u8 { if (iden.len == 0) return "missing id"; if (iden.len > CF.maxz_idenlen) return "id too long (max 120)"; for (iden) |char| { const badz = char == '/' or char == '\\' or char == ':' or char == '*' or char == '?' or char == '"' or char == '<' or char == '>' or char == '|' or char < 0x20; if (badz) return "id has an illegal character (/ \\ : * ? \" < > | or control)"; } if (std.mem.eql(u8, iden, ".") or std.mem.eql(u8, iden, "..")) return "id cannot be . or .."; return null; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
