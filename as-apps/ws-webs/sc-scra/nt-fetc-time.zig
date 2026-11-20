// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Hard deadline around a fetch, worker thread abandons safely
// Flo: copy inputs into a heap job > spawn worker > poll done flag until deadline > take result or abandon the job to the worker
// I/O: URL + Opts + Cond (caller) > Resp or error.Timeout; the worker frees an abandoned job itself
// ===================================================================
const std = @import("std"); const fetc = @import("nt-fetc-owns.zig");
const CF = .{ .poll = 10, .runn = 0, .done = 1, .gone = 2 };
const Job = struct { allo: std.mem.Allocator, iozz: std.Io, urlz: []u8, etag: []u8, lmod: []u8, opts: fetc.Opts, stat: std.atomic.Value(u8) = .init(CF.runn), resz: anyerror!fetc.Resp = error.Unexpected,
fn kill(self: *Job) void { const allo = self.allo; allo.free(self.urlz); allo.free(self.etag); allo.free(self.lmod); allo.destroy(self); } };
fn work(job: *Job) void { job.resz = fetc.fetcGet(job.allo, job.iozz, job.urlz, job.opts, .{ .etag = job.etag, .lmod = job.lmod }); if (job.stat.cmpxchgStrong(CF.runn, CF.done, .acq_rel, .acquire) != null) { if (job.resz) |*resp| { var tmpz = resp.*; tmpz.free(job.allo); } else |_| {} job.kill(); } }
pub fn fetcTime(allo: std.mem.Allocator, iozz: std.Io, urlz: []const u8, opts: fetc.Opts, cond: fetc.Cond) !fetc.Resp { const job = try allo.create(Job); job.* = .{ .allo = allo, .iozz = iozz, .urlz = try allo.dupe(u8, urlz), .etag = try allo.dupe(u8, cond.etag), .lmod = try allo.dupe(u8, cond.lmod), .opts = opts }; const thrd = std.Thread.spawn(.{}, work, .{job}) catch { job.kill(); return error.Unexpected; }; thrd.detach(); const dead = std.Io.Clock.awake.now(iozz).toMilliseconds() + opts.time_mill; while (job.stat.load(.acquire) != CF.done) { if (std.Io.Clock.awake.now(iozz).toMilliseconds() >= dead) { if (job.stat.cmpxchgStrong(CF.runn, CF.gone, .acq_rel, .acquire) == null) return error.Timeout; break; } std.Io.sleep(iozz, .fromMilliseconds(CF.poll), .awake) catch {}; } const outp = job.resz; job.kill(); return outp; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
