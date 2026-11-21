// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for ct-comm-matx: every job is in the matrix, every matrix job exists, ids are J01-J30 once
// Flo: scan tables > assert coverage both ways
// I/O: tables > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const mx = @import("ct-comm-matx.zig"); const jobs = @import("ru-jobs-main.zig"); const T = std.testing;
test "every job in the job table appears in the matrix" { for (jobs.SPECS) |sp| { try T.expect(mx.covered(sp.name)); } }
test "every job named in the matrix exists in the job table" { for (mx.ROWS) |row| { for (row.jobs) |nam| { try T.expect(jobs.known(nam)); } } }
test "ids are J01 to J30 in order, once; levels are 0 or 1 until the live campaign" { try T.expectEqual(@as(usize, 30), mx.ROWS.len); for (mx.ROWS, 0..) |row, idx| { var buf: [3]u8 = undefined; const want = try std.fmt.bufPrint(&buf, "J{d:0>2}", .{idx + 1}); try T.expectEqualStrings(want, row.id); try T.expect(row.level <= 1); } try T.expect(mx.ROWS[29].level == 0); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
