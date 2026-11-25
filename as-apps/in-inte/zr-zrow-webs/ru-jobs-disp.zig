// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Map a job name to its row, risk, description
// Flo: catalog jobs (ru-jobs-tabl) > exec by name > risk class from code (never the AI)
// I/O: job name + Args (caller) > runs the job; risky(): true when it needs the owner's approval; rows for `zr jobs`
// ===================================================================
const std = @import("std"); const task = @import("ru-task-runn.zig"); const jobs = @import("ru-jobs-tabl.zig"); const jrun = @import("ru-jobs-main.zig");
pub const Row = struct { name: []const u8, risk: u8, kind: []const u8, hint: []const u8 };
pub fn rowCount() usize { return jobs.JOBS.len; }
pub fn rowAt(idx: usize) Row { const jb = jobs.JOBS[idx]; return .{ .name = jb.name, .risk = if (jb.risk == .x) 'x' else 'w', .kind = @tagName(jb.kind), .hint = jb.hint }; }
pub fn known(name: []const u8) bool { return jobs.find(name) != null; }
pub fn risky(ctx: *task.Ctx, name: []const u8, tsk: task.Args) bool { _ = ctx; _ = tsk; const jb = jobs.find(name) orelse return false; return jb.risk == .x; }
pub fn exec(ctx: *task.Ctx, job: []const u8, tsk: task.Args) !void { const jb = jobs.find(job) orelse return error.NoJob; const cnt = try jrun.run(ctx, jb, tsk); task.say(ctx, "{s}: {d} done", .{ job, cnt }); }
pub fn fromRef(ref: @import("cf-conf-load.zig").JobRef) task.Args { return .{ .text = ref.text, .to = ref.to, .url = ref.url, .title = ref.title, .price = ref.price, .desc = ref.desc, .group = ref.group, .photo = ref.photo, .opt = ref.opt, .date = ref.date, .time = ref.time, .catg = ref.catg, .cond = ref.cond, .loca = ref.loca, .maxn = ref.maxn }; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
