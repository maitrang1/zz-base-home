// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests every mone catalog row on the fake site
// Flo: run each row live (irreversible rows must refuse without --force first) > assert what the fake page recorded > class H rows wait for the page marker
// I/O: real local Chrome (skipped when absent) + mock site > pass or fail (no leaks)
// ===================================================================
// Run: zig build test -Dfile=ru-jobs-mone-test.zig
const std = @import("std"); const rigz = @import("te-rigz-brow.zig"); const cas = @import("te-jobs-case.zig");
const CASES = [_]cas.Case{
.{ .name = "mone-billing", .args = .{  } },
.{ .name = "mone-invoices", .args = .{  }, .recs = &.{ "btn|Invoices|", "btn|Download invoice|" } },
.{ .name = "mone-paymethod-add", .args = .{  }, .force = true, .recs = &.{ "btn|Add payment method|" } },
.{ .name = "mone-paymethod-remove", .args = .{  }, .force = true, .recs = &.{ "btn|Remove payment method|", "btn|Confirm|" } },
.{ .name = "mone-verified-status", .args = .{  } },
.{ .name = "mone-verified-subscribe", .args = .{  }, .force = true, .recs = &.{ "btn|Subscribe|" } },
.{ .name = "mone-verified-cancel", .args = .{  }, .force = true, .recs = &.{ "btn|Cancel subscription|", "btn|Confirm|" } },
.{ .name = "mone-ads-read", .args = .{  } },
.{ .name = "mone-ads-pause", .args = .{  }, .recs = &.{ "tog|Campaign on or off=off" } },
.{ .name = "mone-ads-resume", .args = .{  }, .force = true, .recs = &.{ "tog|Campaign on or off=on" }, .pkey = "pbiz_adsz_main", .pval = "/z/ads-resume" },
.{ .name = "mone-ads-budget", .args = .{ .price = "10" }, .force = true, .recs = &.{ "btn|Edit budget|", "btn|Save budget|" }, .typed = &.{ "10" } },
.{ .name = "mone-ads-create", .args = .{ .title = "Title60", .price = "10" }, .force = true, .recs = &.{ "btn|Create campaign|" } },
.{ .name = "mone-ads-boost", .args = .{ .url = "/z/mone-ads-boost/1", .price = "10" }, .force = true, .recs = &.{ "btn|Boost post|" } },
.{ .name = "mone-plan-view", .args = .{  } },
};
test "mone rows: every job runs on its fake page and leaves the expected trace" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); try cas.runAll(&rig, &CASES); }
test "mone rows: every job of this table is covered by a case" { try cas.coverage(&CASES, 2); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
