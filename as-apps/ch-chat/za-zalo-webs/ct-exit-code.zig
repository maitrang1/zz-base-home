// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Map results to exit codes: ok, fail, finding, blocked
// Flo: job counts + halt flag > one exit code
// I/O: done, fail, skip, blocked counts (caller) > u8 exit code
// ===================================================================
const CF = .{ .okay = 0, .fail = 1, .find = 3, .bloc = 4 };
pub fn jobCode(done: u32, fail: u32, skip: u32, blok: u32, halt: bool) u8 { if (halt or blok > 0) return CF.bloc; if (fail > 0 and done == 0) return CF.fail; if (skip > 0 or fail > 0) return CF.find; return CF.okay; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
