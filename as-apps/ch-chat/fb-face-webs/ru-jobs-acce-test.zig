// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for every acce catalog row on the fake site (mock-tested, not live-verified): generated from the job table
// Flo: run each row live (irreversible rows must refuse without --force first) > assert what the fake page recorded > class H rows wait for the page marker
// I/O: real local Chrome (skipped when absent) + mock site > pass or fail (no leaks)
// ===================================================================
// Run: zig build test -Dfile=ru-jobs-acce-test.zig
const std = @import("std"); const rigz = @import("te-rigz-brow.zig"); const cas = @import("te-jobs-case.zig");
const CASES = [_]cas.Case{
.{ .name = "acce-roles-list", .args = .{  } },
.{ .name = "acce-role-add", .args = .{ .to = "Ann Lee", .opt = "Opt1" }, .force = true, .recs = &.{ "btn|Add people|", "btn|Ann Lee|", "opt|Role=Opt1", "btn|Give access|" }, .typed = &.{ "Ann Lee" } },
.{ .name = "acce-role-change", .args = .{ .to = "Ann Lee", .opt = "Opt1" }, .force = true, .recs = &.{ "btn|Ann Lee|", "opt|Role=Opt1", "btn|Save role|" } },
.{ .name = "acce-role-remove", .args = .{ .to = "Ann Lee" }, .force = true, .recs = &.{ "btn|Ann Lee|", "btn|Remove access|", "btn|Confirm|" } },
.{ .name = "acce-people-add", .args = .{ .to = "Ann Lee", .opt = "Opt1" }, .force = true, .recs = &.{ "btn|Add people|", "btn|Ann Lee|", "opt|Role=Opt1", "btn|Give access|" }, .typed = &.{ "Ann Lee" } },
.{ .name = "acce-people-remove", .args = .{ .to = "Ann Lee" }, .force = true, .recs = &.{ "btn|Ann Lee|", "btn|Remove access|", "btn|Confirm|" } },
.{ .name = "acce-adrole-add", .args = .{ .to = "Ann Lee", .opt = "Opt1" }, .force = true, .recs = &.{ "btn|Add people|", "btn|Ann Lee|", "opt|Role=Opt1", "btn|Give access|" }, .typed = &.{ "Ann Lee" } },
.{ .name = "acce-adrole-remove", .args = .{ .to = "Ann Lee" }, .force = true, .recs = &.{ "btn|Ann Lee|", "btn|Remove access|", "btn|Confirm|" } },
.{ .name = "acce-partner-add", .args = .{ .text = "Hello71" }, .force = true, .recs = &.{ "btn|Add partner|", "btn|Share access|" }, .typed = &.{ "Hello71" } },
.{ .name = "acce-partner-remove", .args = .{ .text = "Hello72" }, .force = true, .recs = &.{ "btn|Hello72|", "btn|Remove partner|", "btn|Confirm|" } },
.{ .name = "acce-group-admin", .args = .{ .url = "/z/acce-group-admin/1", .to = "Ann Lee" }, .force = true, .recs = &.{ "btn|Ann Lee|", "btn|Make admin|", "btn|Confirm|" } },
.{ .name = "acce-group-mod", .args = .{ .url = "/z/acce-group-mod/1", .to = "Ann Lee" }, .force = true, .recs = &.{ "btn|Ann Lee|", "btn|Make moderator|", "btn|Confirm|" } },
.{ .name = "acce-group-demote", .args = .{ .url = "/z/acce-group-demote/1", .to = "Ann Lee" }, .force = true, .recs = &.{ "btn|Ann Lee|", "btn|Remove admin or moderator|", "btn|Confirm|" } },
.{ .name = "acce-dev-apps", .args = .{  } },
.{ .name = "acce-dev-hooks", .args = .{  } },
.{ .name = "acce-dev-hook-add", .args = .{ .url = "https://x.test/78" }, .force = true, .recs = &.{ "btn|Add callback URL|" } },
.{ .name = "acce-conn-list", .args = .{  } },
.{ .name = "acce-conn-remove", .args = .{ .to = "Ann Lee" }, .force = true, .recs = &.{ "btn|Ann Lee|", "btn|Disconnect|", "btn|Confirm|" } },
};
test "acce rows: every job runs on its fake page and leaves the expected trace" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); try cas.runAll(&rig, &CASES); }
test "acce rows: every job of this table is covered by a case" { try cas.coverage(&CASES, 3); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
