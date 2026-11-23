// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for every sett catalog row on the fake site (mock-tested, not live-verified): generated from the job table
// Flo: run each row live (irreversible rows must refuse without --force first) > assert what the fake page recorded > class H rows wait for the page marker
// I/O: real local Chrome (skipped when absent) + mock site > pass or fail (no leaks)
// ===================================================================
// Run: zig build test -Dfile=ru-jobs-sett-test.zig
const std = @import("std"); const rigz = @import("te-rigz-brow.zig"); const cas = @import("te-jobs-case.zig");
const CASES = [_]cas.Case{
.{ .name = "sett-privacy-check", .args = .{  } },
.{ .name = "sett-audience-default", .args = .{ .opt = "Opt1" }, .recs = &.{ "opt|Default audience=Opt1", "btn|Save changes|" } },
.{ .name = "sett-who-friends", .args = .{ .opt = "Opt1" }, .recs = &.{ "opt|Who can send you friend requests=Opt1", "btn|Save changes|" } },
.{ .name = "sett-who-find", .args = .{ .opt = "Opt1" }, .recs = &.{ "opt|Who can look you up=Opt1", "btn|Save changes|" } },
.{ .name = "sett-search-engine", .args = .{  }, .recs = &.{ "tog|Search engines can link to your profile=on" } },
.{ .name = "sett-tag-review", .args = .{  }, .recs = &.{ "tog|Review tags=on" } },
.{ .name = "sett-noti-email", .args = .{  }, .recs = &.{ "tog|Email notifications=on" } },
.{ .name = "sett-noti-push", .args = .{  }, .recs = &.{ "tog|Push notifications=on" } },
.{ .name = "sett-noti-sms", .args = .{  }, .recs = &.{ "tog|SMS notifications=on" } },
.{ .name = "sett-block-add", .args = .{ .to = "Ann Lee" }, .force = true, .recs = &.{ "btn|Ann Lee|", "btn|Block|" }, .typed = &.{ "Ann Lee" } },
.{ .name = "sett-unblock", .args = .{  }, .recs = &.{ "item|Unblock@Ann Lee" }, .num = 2 },
.{ .name = "sett-apps-list", .args = .{  } },
.{ .name = "sett-apps-remove", .args = .{ .to = "Ann Lee" }, .force = true, .recs = &.{ "btn|Ann Lee|", "btn|Remove|", "btn|Confirm|" } },
.{ .name = "sett-offfb-clear", .args = .{  }, .force = true, .recs = &.{ "btn|Clear history|", "btn|Confirm|" } },
.{ .name = "sett-adpref", .args = .{  }, .recs = &.{ "tog|Ads based on data from partners=on" } },
.{ .name = "data-activity-list", .args = .{  } },
.{ .name = "data-activity-delete", .args = .{ .opt = "Opt1" }, .force = true, .recs = &.{ "opt|Year=Opt1", "btn|Select all|", "btn|Delete|", "btn|Confirm|" } },
.{ .name = "data-download-request", .args = .{  }, .recs = &.{ "btn|Request a download|", "btn|Create file|" } },
.{ .name = "data-download-get", .args = .{  }, .recs = &.{ "btn|Available copies|", "btn|Download|" } },
.{ .name = "data-saved-list", .args = .{  } },
.{ .name = "data-album-create", .args = .{ .title = "Title46", .photo = "PHOTO" }, .recs = &.{ "btn|Create album|", "file|1", "btn|Post|" }, .typed = &.{ "Title46" } },
.{ .name = "data-album-delete", .args = .{ .title = "Title47" }, .force = true, .recs = &.{ "btn|Title47|", "btn|Album options|", "btn|Delete album|", "btn|Confirm|" } },
.{ .name = "data-memories", .args = .{  } },
};
test "sett rows: every job runs on its fake page and leaves the expected trace" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); try cas.runAll(&rig, &CASES); }
test "sett rows: every job of this table is covered by a case" { try cas.coverage(&CASES, 1); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
