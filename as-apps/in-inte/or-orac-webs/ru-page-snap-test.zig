// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests that page reads and clicks reach inside an iframe (the Oracle console shape)
// Flo: open a shell page with a framed sign-up page > find a framed button > read framed text > click and see the record
// I/O: none (mock site on loopback, scratch profile) > pass or fail (browser tests skip without Chrome)
// Run: cd E:\zz-base-home\as-apps\in-inte\or-orac-webs && mise exec -- zig build test -Dfile=ru-page-snap-test.zig
// ===================================================================
const std = @import("std"); const rigz = @import("te-rigz-brow.zig"); const inpu = @import("ru-huma-inpu.zig");
test "a button inside an iframe is found, its text is read, and a click reaches it" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); const aren = rig.aren.allocator(); try rig.go("/framed"); std.Io.sleep(rig.iozz, .fromMilliseconds(800), .awake) catch {}; const bid = (try rig.page.axFind(aren, "button", &.{"Verify my email"}, 0)) orelse return error.TestUnexpectedResult; const txt = try rig.page.textNow(aren); try std.testing.expect(std.mem.find(u8, txt, "Sign up for Oracle Cloud Free Tier") != null); try rig.page.scrollInto(aren, bid); var env = rig.env(); const pnt = try rig.page.center(aren, bid); try inpu.click(&env, pnt.x, pnt.y); const rec = rig.waitRec("btn", 5000) orelse return error.TestUnexpectedResult; try std.testing.expect(std.mem.startsWith(u8, rec, "Verify my email")); }
test "navigate waits while a Loading dialog is up, so the real controls are there at once" { var rig: rigz.Rig = undefined; try rig.up(); defer rig.down(); const aren = rig.aren.allocator(); try rig.go("/loading"); try std.testing.expect((try rig.page.axFind(aren, "button", &.{"Ready now"}, 0)) != null); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
