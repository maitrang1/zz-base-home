// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for plain-language recipes
// Flo: each phrase maps to the right job and arguments > unknown words give null
// I/O: sentences > Cmd or null (no leaks)
// Run: zig build test -Dfile=ru-reci-main-test.zig
// ===================================================================
const std = @import("std"); const reci = @import("ru-reci-main.zig");
fn one(text: []const u8) !?reci.Cmd { var aren = std.heap.ArenaAllocator.init(std.testing.allocator); defer aren.deinit(); const got = try reci.parse(aren.allocator(), text); if (got) |cmd| { return .{ .job = cmd.job, .args = .{ .text = try std.testing.allocator.dupe(u8, cmd.args.text), .to = try std.testing.allocator.dupe(u8, cmd.args.to), .title = try std.testing.allocator.dupe(u8, cmd.args.title) } }; } return null; }
fn drop(cmd: reci.Cmd) void { std.testing.allocator.free(cmd.args.text); std.testing.allocator.free(cmd.args.to); std.testing.allocator.free(cmd.args.title); }
test "post phrases keep the original case and text" { const cmd = (try one("Post: Bán xe đạp, giá 2 triệu")).?; defer drop(cmd); try std.testing.expectEqual(reci.Job.post, cmd.job); try std.testing.expectEqualStrings("Bán xe đạp, giá 2 triệu", cmd.args.text); const vi = (try one("Đăng: Xin chào cả nhà")).?; defer drop(vi); try std.testing.expectEqualStrings("Xin chào cả nhà", vi.args.text); }
test "reply and renew phrases" { const cmd = (try one("Please reply to my comments")).?; defer drop(cmd); try std.testing.expectEqual(reci.Job.reply, cmd.job); const all = (try one("Renew my listings")).?; defer drop(all); try std.testing.expectEqual(reci.Job.renewall, all.job); const one1 = (try one("renew Red Bike")).?; defer drop(one1); try std.testing.expectEqual(reci.Job.renew, one1.job); try std.testing.expectEqualStrings("Red Bike", one1.args.title); }
test "sold phrases" { const aaa = (try one("mark Red Bike sold")).?; defer drop(aaa); try std.testing.expectEqual(reci.Job.sold, aaa.job); try std.testing.expectEqualStrings("Red Bike", aaa.args.title); const bbb = (try one("Sold: Blue desk")).?; defer drop(bbb); try std.testing.expectEqualStrings("Blue desk", bbb.args.title); }
test "message phrase splits id and text" { const cmd = (try one("message 42 Hello there, is it free?")).?; defer drop(cmd); try std.testing.expectEqual(reci.Job.dm, cmd.job); try std.testing.expectEqualStrings("42", cmd.args.to); try std.testing.expectEqualStrings("Hello there, is it free?", cmd.args.text); try std.testing.expect((try one("message 42")) == null); }
test "unknown or empty sentences give null" { try std.testing.expect((try one("what is the weather")) == null); try std.testing.expect((try one("   ")) == null); try std.testing.expect((try one("post:")) == null); try std.testing.expect((try one("renew ")) == null); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
