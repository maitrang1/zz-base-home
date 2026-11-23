// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for ct-comm-flws: the action map is complete and honest
// Flo: scan tables > assert job coverage both ways, reasons for non-built rows, counts add up
// I/O: tables > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const fl = @import("ct-comm-flws.zig"); const jobs = @import("ru-jobs-main.zig"); const T = std.testing;
test "every job in the job table appears in the action map" { for (jobs.SPECS) |sp| { try T.expect(fl.covered(sp.name)); } }
test "every plain job token names a real job; at-tokens are only guards and commands" { for (fl.ROWS) |row| { if (row.jobs.len == 0) continue; var itr = std.mem.splitScalar(u8, row.jobs, ' '); while (itr.next()) |tok| { if (tok[0] == '@') { try T.expect(std.mem.startsWith(u8, tok, "@cmd:") or std.mem.eql(u8, tok, "@halt") or std.mem.eql(u8, tok, "@popup")); } else try T.expect(jobs.known(tok)); } } }
test "built rows name a job; every other row gives a reason" { for (fl.ROWS) |row| { if (row.stat == .built) try T.expect(row.jobs.len > 0); if (row.stat != .built) try T.expect(row.why.len > 0); if (row.stat == .gap or row.stat == .out) try T.expect(row.jobs.len == 0); } }
test "counts add up and every category has a row" { try T.expectEqual(fl.ROWS.len, fl.count(.built) + fl.count(.gap) + fl.count(.hand) + fl.count(.out)); const cats = [_][]const u8{ "account", "core", "data", "money", "access", "settings", "help", "edge" }; for (cats) |cat| { var seen = false; for (fl.ROWS) |row| { if (std.mem.eql(u8, row.cat, cat)) seen = true; } try T.expect(seen); } try T.expect(fl.count(.built) > 40); try T.expect(fl.count(.out) >= 4); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
