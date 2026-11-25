// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests every acct catalog row on the fake site
// Flo: run each row live (irreversible rows must refuse without --force first) > assert what the fake page recorded > class H rows wait for the page marker
// I/O: real local Chrome (skipped when absent) + mock site > pass or fail (no leaks)
// ===================================================================
// Run: zig build test -Dfile=ru-jobs-acct-test.zig
const std = @import("std"); const rigz = @import("te-rigz-brow.zig"); const cas = @import("te-jobs-case.zig");
const CASES = [_]cas.Case{
.{ .name = "acct-login", .args = .{  }, .recs = &.{ "btn|Log in|" }, .typed = &.{ "u@fb.test", "pw-test-1" } },
.{ .name = "acct-logout", .args = .{  }, .recs = &.{ "btn|Your profile|", "btn|Log out|" } },
.{ .name = "acct-signup", .args = .{  }, .force = true, .recs = &.{ "btn|Sign Up|" }, .typed = &.{ "Anh", "Tran", "u@fb.test", "pw-test-1", "1990-01-02" } },
.{ .name = "acct-reset-pass", .args = .{  }, .force = true, .recs = &.{ "btn|Search|" }, .typed = &.{ "u@fb.test" } },
.{ .name = "acct-pass-change", .args = .{  }, .force = true, .recs = &.{ "btn|Change password|", "btn|Save changes|" }, .typed = &.{ "pw-test-1", "pw-test-2", "pw-test-2" } },
.{ .name = "acct-2fa-setup", .args = .{  }, .force = true, .recs = &.{ "btn|Two-factor authentication|", "btn|Authentication app|" } },
.{ .name = "acct-2fa-codes", .args = .{  }, .force = true, .recs = &.{ "btn|Two-factor authentication|", "btn|Recovery codes|" } },
.{ .name = "acct-alerts", .args = .{  }, .recs = &.{ "tog|Login alerts=on" } },
.{ .name = "acct-sessions", .args = .{  } },
.{ .name = "acct-sessions-out", .args = .{  }, .force = true, .recs = &.{ "btn|Where you're logged in|", "btn|Log out of all sessions|", "btn|Confirm|" } },
.{ .name = "acct-passkey", .args = .{  }, .force = true, .recs = &.{ "btn|Passkey|" } },
.{ .name = "acct-mail-add", .args = .{ .text = "Hello12" }, .force = true, .recs = &.{ "btn|Contact info|", "btn|Add email|", "btn|Continue|" }, .typed = &.{ "Hello12" } },
.{ .name = "acct-phone-add", .args = .{ .text = "Hello13" }, .force = true, .recs = &.{ "btn|Contact info|", "btn|Add mobile number|", "btn|Continue|" }, .typed = &.{ "Hello13" } },
.{ .name = "acct-name", .args = .{  }, .force = true, .recs = &.{ "btn|Name|", "btn|Review change|" }, .typed = &.{ "Anh", "Tran" } },
.{ .name = "acct-lang", .args = .{ .opt = "Opt1" }, .recs = &.{ "opt|Facebook language=Opt1", "btn|Save changes|" } },
.{ .name = "acct-deactivate", .args = .{  }, .force = true, .recs = &.{ "btn|Deactivation or deletion|", "btn|Deactivate account|" } },
.{ .name = "acct-delete", .args = .{  }, .force = true, .recs = &.{ "btn|Deactivation or deletion|", "btn|Delete account|" } },
.{ .name = "profile-photo", .args = .{ .photo = "PHOTO" }, .recs = &.{ "btn|Edit profile|", "btn|Profile picture|", "file|1", "btn|Save|" } },
.{ .name = "profile-cover", .args = .{ .photo = "PHOTO" }, .recs = &.{ "btn|Edit profile|", "btn|Cover photo|", "file|1", "btn|Save|" } },
.{ .name = "profile-work", .args = .{ .text = "Hello20" }, .recs = &.{ "btn|Edit profile|", "btn|Add workplace|", "btn|Save|" }, .typed = &.{ "Hello20" } },
.{ .name = "profile-edu", .args = .{ .text = "Hello21" }, .recs = &.{ "btn|Edit profile|", "btn|Add college|", "btn|Save|" }, .typed = &.{ "Hello21" } },
.{ .name = "profile-city", .args = .{ .text = "Hello22" }, .recs = &.{ "btn|Edit profile|", "btn|Add current city|", "btn|Save|" }, .typed = &.{ "Hello22" } },
.{ .name = "profile-link", .args = .{ .url = "https://x.test/23" }, .recs = &.{ "btn|Edit profile|", "btn|Add social link|", "btn|Save|" }, .typed = &.{ "https://x.test/23" } },
.{ .name = "profile-featured", .args = .{ .photo = "PHOTO" }, .recs = &.{ "btn|Edit profile|", "btn|Add featured|", "file|1", "btn|Save|" } },
.{ .name = "profile-life", .args = .{ .title = "Title25" }, .recs = &.{ "btn|Add life event|", "btn|Save|" }, .typed = &.{ "Title25" } },
};
test "acct rows: every job runs on its fake page and leaves the expected trace" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); try cas.runAll(&rig, &CASES); }
test "acct rows: every job of this table is covered by a case" { try cas.coverage(&CASES, 0); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
