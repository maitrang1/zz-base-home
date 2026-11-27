// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: One approval list: approve or deny planned items once
// Flo: items saved with approval 0 (needs OK) or 1 (auto) > show numbered list > approve all or some by number (duplicate approve = once) > deny some
// I/O: Ctx + flow id (caller) > printed plan lines; approval flags saved in the state db
// ===================================================================
const std = @import("std"); const task = @import("ru-task-runn.zig"); const stat = @import("st-stat-main.zig"); const cfgz = @import("cf-conf-load.zig");
pub fn refOf(ctx: *task.Ctx, args: []const u8) !cfgz.JobRef { return std.json.parseFromSliceLeaky(cfgz.JobRef, ctx.aren, args, .{ .ignore_unknown_fields = true, .allocate = .alloc_always }) catch return error.BadFlow; }
fn digest(ref: cfgz.JobRef) []const u8 { const cand = [_][]const u8{ ref.title, ref.text, ref.url, ref.to, ref.group, ref.photo }; for (cand) |cv| { if (cv.len > 0) return cv[0..@min(cv.len, 40)]; } return ""; }
pub fn mark(item: stat.Item) []const u8 { if (std.mem.eql(u8, item.st, "done")) return "done"; if (item.appr == 1) return "ok"; if (item.appr == 2) return "denied"; return "NEEDS OK"; }
pub fn show(ctx: *task.Ctx, fid: i64) !u32 { const flw = (try ctx.store.flowGet(ctx.aren, fid)) orelse return error.BadFlow; const items = try ctx.store.itemList(ctx.aren, fid); task.say(ctx, "plan \"{s}\" (flow {d}, {s}): {d} items", .{ flw.name, flw.id, flw.st, items.len }); var need: u32 = 0; for (items) |it| { const ref = try refOf(ctx, it.args); const mk = mark(it); if (std.mem.eql(u8, mk, "NEEDS OK")) need += 1; task.say(ctx, "{d}. [{s}] {s} {s}", .{ it.seq, mk, it.job, digest(ref) }); } if (need > 0) task.say(ctx, "{d} item(s) need your OK: run: or-orac-webs approve all (or: or-orac-webs approve 1,3)", .{need}); return need; }
pub fn setAppr(ctx: *task.Ctx, fid: i64, spec: []const u8, val: i64) !i64 { var total: i64 = 0; if (std.mem.eql(u8, spec, "all")) return ctx.store.itemAppr(fid, -1, val); var itr = std.mem.splitScalar(u8, spec, ','); while (itr.next()) |raw| { const num = std.fmt.parseInt(i64, std.mem.trim(u8, raw, " "), 10) catch return error.BadUsage; total += try ctx.store.itemAppr(fid, num, val); } return total; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
