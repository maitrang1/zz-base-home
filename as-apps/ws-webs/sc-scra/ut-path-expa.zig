// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Expand a leading ~ in paths via home dir
// Flo: check prefix ~ > join home + rest > else copy as is
// I/O: path text + home dir text (caller) > owned path text
// ===================================================================
const std = @import("std");
pub fn pathExpa(allo: std.mem.Allocator, home: []const u8, path: []const u8) ![]u8 { if (path.len == 0) return error.BadPath; if (path[0] != '~') return allo.dupe(u8, path); if (path.len > 1 and path[1] != '/' and path[1] != '\\') return error.BadPath; if (home.len == 0) return error.NoHome; return std.fs.path.join(allo, &.{ home, std.mem.trimStart(u8, path[1..], "/\\") }); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
