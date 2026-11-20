// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Post text on the timeline, a group or a page
// Flo: plan steps (open composer, type, submit, check text shows) > run through the safety ladder > once-only key from the text
// I/O: Args text + optional url (caller) > Out; one post per run; same text on the same place is never posted twice
// ===================================================================
const std = @import("std"); const task = @import("ru-task-runn.zig"); const flow = @import("ru-flow-runz.zig"); const pace = @import("ru-huma-pace.zig");
const CF = .{ .snip = 30 };
pub fn cutUtf8(txt: []const u8, maxz: usize) []const u8 { if (txt.len <= maxz) return txt; var end = maxz; while (end > 0 and (txt[end] & 0xC0) == 0x80) end -= 1; return txt[0..end]; }
pub fn postTo(ctx: *task.Ctx, text: []const u8, path: []const u8, kind: pace.Kind) !task.Out { if (text.len == 0) return error.BadUsage; const hsh = try task.hashHex(ctx, text); const key = try std.fmt.allocPrint(ctx.aren, "post|{s}|{s}", .{ path, hsh }); const what = try std.fmt.allocPrint(ctx.aren, "post {d} chars at {s}: {s}", .{ text.len, path, cutUtf8(text, CF.snip) }); const stps = try ctx.aren.dupe(flow.Step, &.{ task.goStep(path), .{ .op = .click, .labs = ctx.conf.labl_post_open }, .{ .op = .typez, .labs = ctx.conf.labl_post_boxz, .text = text }, .{ .op = .click, .labs = ctx.conf.labl_post_subm, .commit = true }, .{ .op = .expect, .labs = &.{cutUtf8(text, CF.snip)} } }); return task.execWrite(ctx, kind, key, what, false, stps); }
pub fn postRun(ctx: *task.Ctx, args: task.Args) !task.Out { const grp = args.url.len > 0 and std.mem.find(u8, args.url, "/groups/") != null; const path = if (args.url.len > 0) args.url else ctx.conf.path_home_main; return postTo(ctx, args.text, path, if (grp) .grou else .post); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
