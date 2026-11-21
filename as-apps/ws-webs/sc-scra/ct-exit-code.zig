// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Map run results to exit codes 0 ok, 1 fail, 3 drift, 4 blocked
// Flo: outcome word + HTTP code > code; run summary > code; canary results > code
// I/O: Outc / Summ counts (commands) > u8 exit code
// ===================================================================
const std = @import("std");
const CF = .{ .okay = 0, .fail = 1, .drif = 3, .bloc = 4 };
pub fn outcCode(stat: []const u8, code: u16) u8 { if (std.mem.eql(u8, stat, "new") or std.mem.eql(u8, stat, "same") or std.mem.eql(u8, stat, "notm")) return CF.okay; if (std.mem.eql(u8, stat, "bloc")) return CF.bloc; if (std.mem.eql(u8, stat, "http")) { if (code == 404 or code == 410) return CF.okay; if (code == 401 or code == 403 or code == 429) return CF.bloc; } return CF.fail; }
pub fn sumzCode(done: u32, fail: u32, blok: u32, dead: i64, halt: bool, incm: bool) u8 { if (halt) return if (blok > 0 and done == 0) CF.bloc else CF.fail; if (done == 0 and blok > 0) return CF.bloc; if (done == 0 and (fail > 0 or dead > 0)) return CF.fail; if (incm) return CF.drif; if (dead > 0 or fail > 0) return CF.okay; return CF.okay; }
pub fn canaCode(dri2: u32, fai2: u32) u8 { if (dri2 > 0) return CF.drif; if (fai2 > 0) return CF.fail; return CF.okay; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
