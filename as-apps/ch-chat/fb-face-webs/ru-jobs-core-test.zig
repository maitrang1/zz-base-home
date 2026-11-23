// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for every core catalog row on the fake site (mock-tested, not live-verified): generated from the job table
// Flo: run each row live (irreversible rows must refuse without --force first) > assert what the fake page recorded > class H rows wait for the page marker
// I/O: real local Chrome (skipped when absent) + mock site > pass or fail (no leaks)
// ===================================================================
// Run: zig build test -Dfile=ru-jobs-core-test.zig
const std = @import("std"); const rigz = @import("te-rigz-brow.zig"); const cas = @import("te-jobs-case.zig");
const CASES = [_]cas.Case{
.{ .name = "friend-list-add", .args = .{ .title = "Title81" }, .recs = &.{ "btn|Create list|", "btn|Save list|" }, .typed = &.{ "Title81" } },
.{ .name = "friend-close", .args = .{ .url = "/z/friend-close/1" }, .recs = &.{ "btn|Friends|", "btn|Add to Close Friends|" } },
.{ .name = "friend-close-remove", .args = .{ .url = "/z/friend-close-remove/1" }, .recs = &.{ "btn|Friends|", "btn|Remove from Close Friends|" } },
.{ .name = "friend-cancel", .args = .{ .url = "/z/friend-cancel/1" }, .recs = &.{ "btn|Cancel request|" } },
.{ .name = "page-like", .args = .{ .url = "/z/page-like/1" }, .recs = &.{ "btn|Like Page|" } },
.{ .name = "page-unlike", .args = .{ .url = "/z/page-unlike/1" }, .recs = &.{ "btn|Unlike Page|" } },
.{ .name = "group-create", .args = .{ .title = "Title87" }, .recs = &.{ "btn|Create group|" }, .typed = &.{ "Title87" } },
.{ .name = "group-rules", .args = .{ .url = "/z/group-rules/1", .text = "Hello88" }, .recs = &.{ "btn|Group settings|", "btn|Group rules|", "btn|Save group|" }, .typed = &.{ "Hello88" } },
.{ .name = "group-question", .args = .{ .url = "/z/group-question/1", .text = "Hello89" }, .recs = &.{ "btn|Group settings|", "btn|Membership questions|", "btn|Save group|" }, .typed = &.{ "Hello89" } },
.{ .name = "group-member-remove", .args = .{ .url = "/z/group-member-remove/1", .to = "Ann Lee" }, .force = true, .recs = &.{ "btn|Ann Lee|", "btn|Remove member|", "btn|Confirm|" } },
.{ .name = "group-member-block", .args = .{ .url = "/z/group-member-block/1", .to = "Ann Lee" }, .force = true, .recs = &.{ "btn|Ann Lee|", "btn|Block member|", "btn|Confirm|" } },
.{ .name = "page-create", .args = .{ .title = "Title92" }, .recs = &.{ "btn|Create Page|" }, .typed = &.{ "Title92" } },
.{ .name = "page-edit-info", .args = .{ .url = "/z/page-edit-info/1", .text = "Hello93" }, .recs = &.{ "btn|Edit Page info|", "btn|Save Page|" }, .typed = &.{ "Hello93" } },
.{ .name = "page-username", .args = .{ .url = "/z/page-username/1", .text = "Hello94" }, .recs = &.{ "btn|Edit Page info|", "btn|Save Page|" }, .typed = &.{ "Hello94" } },
.{ .name = "page-cta", .args = .{ .url = "/z/page-cta/1", .opt = "Opt1" }, .recs = &.{ "btn|Edit Page info|", "opt|Action button=Opt1", "btn|Save Page|" } },
.{ .name = "page-delete", .args = .{ .url = "/z/page-delete/1" }, .force = true, .recs = &.{ "btn|Page settings|", "btn|Delete Page|", "btn|Confirm|" } },
.{ .name = "page-unpublish", .args = .{ .url = "/z/page-unpublish/1" }, .force = true, .recs = &.{ "btn|Page settings|", "btn|Unpublish Page|", "btn|Confirm|" } },
.{ .name = "page-publish", .args = .{ .url = "/z/page-publish/1" }, .recs = &.{ "btn|Page settings|", "btn|Publish Page|" } },
.{ .name = "post-tag", .args = .{ .text = "Hello99", .to = "Ann Lee" }, .recs = &.{ "btn|What's on your mind|", "btn|Tag people|", "btn|Ann Lee|", "btn|Done|", "btn|Post|" }, .typed = &.{ "Ann Lee", "Hello99" }, .comp = "/z/post-tag/c" },
.{ .name = "post-checkin", .args = .{ .text = "Hello100", .opt = "Opt1" }, .recs = &.{ "btn|What's on your mind|", "btn|Check in|", "btn|Opt1|", "btn|Post|" }, .typed = &.{ "Hello100" }, .comp = "/z/post-checkin/c" },
.{ .name = "post-feeling", .args = .{ .text = "Hello101", .opt = "Opt1" }, .recs = &.{ "btn|What's on your mind|", "opt|Feeling or activity=Opt1", "btn|Post|" }, .typed = &.{ "Hello101" }, .comp = "/z/post-feeling/c" },
.{ .name = "post-hide", .args = .{ .url = "/z/post-hide/1" }, .recs = &.{ "btn|More|", "btn|Hide post|" } },
.{ .name = "post-report", .args = .{ .url = "/z/post-report/1", .opt = "Opt1" }, .force = true, .recs = &.{ "btn|More|", "btn|Report post|", "btn|Opt1|", "btn|Submit report|" } },
.{ .name = "post-pin", .args = .{ .url = "/z/post-pin/1" }, .recs = &.{ "btn|More|", "btn|Pin post|" } },
.{ .name = "comment-edit", .args = .{ .url = "/z/comment-edit/1", .text = "Hello105" }, .recs = &.{ "btn|Actions for this comment|", "btn|Edit comment|", "key|Write a comment=Hello105" }, .typed = &.{ "Hello105" } },
.{ .name = "comment-delete", .args = .{ .url = "/z/comment-delete/1" }, .force = true, .recs = &.{ "btn|Actions for this comment|", "btn|Delete comment|", "btn|Confirm|" } },
.{ .name = "saved-remove", .args = .{  }, .recs = &.{ "item|Unsave@Ann Lee" }, .num = 2 },
.{ .name = "search", .args = .{ .text = "Hello108" }, .recs = &.{ "key|Search Facebook=Hello108" }, .typed = &.{ "Hello108" } },
.{ .name = "story-delete", .args = .{  }, .force = true, .recs = &.{ "btn|Story options|", "btn|Delete story|", "btn|Confirm|" } },
.{ .name = "story-highlight", .args = .{  }, .recs = &.{ "btn|Add to highlights|" } },
.{ .name = "reel-delete", .args = .{ .url = "/z/reel-delete/1" }, .force = true, .recs = &.{ "btn|More|", "btn|Delete reel|", "btn|Confirm|" } },
.{ .name = "event-edit", .args = .{ .url = "/z/event-edit/1", .title = "Title112" }, .recs = &.{ "btn|Edit event|", "btn|Save event|" }, .typed = &.{ "Title112" } },
.{ .name = "market-boost", .args = .{ .url = "/z/market-boost/1", .price = "10" }, .force = true, .recs = &.{ "btn|Boost post|" } },
.{ .name = "msgr-new", .args = .{ .to = "Ann Lee", .text = "Hello114" }, .recs = &.{ "btn|Ann Lee|", "key|Message=Hello114" }, .typed = &.{ "Ann Lee", "Hello114" } },
.{ .name = "msgr-mute", .args = .{ .to = "z-msgr-mute" }, .recs = &.{ "btn|Conversation information|", "btn|Mute notifications|" } },
.{ .name = "msgr-nick", .args = .{ .to = "z-msgr-nick", .text = "Hello116" }, .recs = &.{ "btn|Conversation information|", "btn|Nicknames|", "btn|Set nickname|" }, .typed = &.{ "Hello116" } },
.{ .name = "msgr-vanish", .args = .{ .to = "z-msgr-vanish" }, .recs = &.{ "btn|Conversation information|", "tog|Vanish mode=on" } },
.{ .name = "msgr-block", .args = .{ .to = "z-msgr-block" }, .force = true, .recs = &.{ "btn|Conversation information|", "btn|Block chat|", "btn|Confirm|" } },
.{ .name = "msgr-delete", .args = .{ .to = "z-msgr-delete" }, .force = true, .recs = &.{ "btn|Conversation information|", "btn|Delete chat|", "btn|Confirm|" } },
};
test "core rows: every job runs on its fake page and leaves the expected trace" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); try cas.runAll(&rig, &CASES); }
test "core rows: every job of this table is covered by a case" { try cas.coverage(&CASES, 4); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
