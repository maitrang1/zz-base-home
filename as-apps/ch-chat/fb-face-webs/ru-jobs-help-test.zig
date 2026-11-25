// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests every help catalog row on the fake site
// Flo: run each row live (irreversible rows must refuse without --force first) > assert what the fake page recorded > class H rows wait for the page marker
// I/O: real local Chrome (skipped when absent) + mock site > pass or fail (no leaks)
// ===================================================================
// Run: zig build test -Dfile=ru-jobs-help-test.zig
const std = @import("std"); const rigz = @import("te-rigz-brow.zig"); const cas = @import("te-jobs-case.zig");
const CASES = [_]cas.Case{
.{ .name = "help-search", .args = .{ .text = "Hello120" }, .recs = &.{ "key|Search the Help Center=Hello120" }, .typed = &.{ "Hello120" } },
.{ .name = "help-open", .args = .{  } },
.{ .name = "supp-inbox", .args = .{  } },
.{ .name = "supp-report", .args = .{ .text = "Hello123" }, .force = true, .recs = &.{ "btn|Report a problem|", "btn|Send message|" }, .typed = &.{ "Hello123" } },
.{ .name = "supp-feedback", .args = .{ .text = "Hello124" }, .force = true, .recs = &.{ "btn|Send feedback|", "btn|Send message|" }, .typed = &.{ "Hello124" } },
.{ .name = "supp-contact", .args = .{ .text = "Hello125" }, .force = true, .recs = &.{ "btn|Contact support|", "btn|Send message|" }, .typed = &.{ "Hello125" } },
};
test "help rows: every job runs on its fake page and leaves the expected trace" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); try cas.runAll(&rig, &CASES); }
test "help rows: every job of this table is covered by a case" { try cas.coverage(&CASES, 5); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
