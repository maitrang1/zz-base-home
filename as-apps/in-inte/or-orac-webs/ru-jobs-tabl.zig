// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Job catalog as data: joins the row files, finds a job by name
// Flo: rows (account, resources) > one JOBS array > find by name > the runner turns rows into flow steps
// I/O: none (constants) > Job rows (find by name, list for `or-orac-webs jobs`)
// ===================================================================
const std = @import("std"); const typz = @import("ru-jobs-type.zig"); const acct = @import("ru-jobs-rows-acct.zig"); const reso = @import("ru-jobs-rows-reso.zig");
pub const Risk = typz.Risk; pub const Host = typz.Host; pub const Arg = typz.Arg; pub const T = typz.T; pub const Job = typz.Job;
pub const JOBS = acct.ROWS ++ reso.ROWS;
pub fn find(name: []const u8) ?*const Job { for (&JOBS) |*jb| { if (std.mem.eql(u8, jb.name, name)) return jb; } return null; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
