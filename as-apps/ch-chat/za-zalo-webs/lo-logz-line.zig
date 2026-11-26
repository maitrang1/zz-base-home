// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Log event on stderr: always 2 lines, one trace id per run
// Flo: begin at entry (id + clock) > logz(module, level, what, why, fix) > 2 lines on stderr
// I/O: text parts > line 1 "module | LEVEL | UTC time | trace_id", line 2 "what - why; fix: ..." (no dumps, long text clipped)
// ===================================================================
const std = @import("std");
const CF = .{ .maxz = 300, .hexz = "0123456789abcdef", .nonz = "00000000" };
pub const Levl = enum { info, warn, erro };
var tidz: [8]u8 = CF.nonz.*; var iozz: ?std.Io = null;
pub fn begin(ioxx: std.Io) void { iozz = ioxx; var rnd: [4]u8 = undefined; ioxx.random(&rnd); for (rnd, 0..) |byte, idx| { tidz[idx * 2] = CF.hexz[byte >> 4]; tidz[idx * 2 + 1] = CF.hexz[byte & 15]; } }
pub fn traceId() []const u8 { return &tidz; }
fn nowzMill() i64 { const ioxx = iozz orelse return 0; return @intCast(std.Io.Clock.real.now(ioxx).toMilliseconds()); }
fn putz(buff: []u8, pos: *usize, text: []const u8) void { for (text) |byte| { if (pos.* >= buff.len) return; buff[pos.*] = if (byte < 32 or byte == 127) ' ' else byte; pos.* += 1; } }
pub fn lineTwo(buff: []u8, modz: []const u8, levl: Levl, mill: i64, tid2: []const u8, what: []const u8, whyz: []const u8, fixz: []const u8) []const u8 {
if (buff.len < 120) return buff[0..0];
var pos: usize = 0; const secs: u64 = @intCast(@max(@divFloor(mill, 1000), 0)); const epsz: std.time.epoch.EpochSeconds = .{ .secs = secs }; const yday = epsz.getEpochDay().calculateYearDay(); const mday = yday.calculateMonthDay(); const dsec = epsz.getDaySeconds();
const head = std.fmt.bufPrint(buff, "{s} | {s} | {d:0>4}-{d:0>2}-{d:0>2}T{d:0>2}:{d:0>2}:{d:0>2}Z | {s}\n", .{ modz, switch (levl) { .info => "INFO", .warn => "WARN", .erro => "ERRO" }, yday.year, mday.month.numeric(), mday.day_index + 1, dsec.getHoursIntoDay(), dsec.getMinutesIntoHour(), dsec.getSecondsIntoMinute(), tid2 }) catch return buff[0..0];
pos = head.len; const body = @min(buff.len - 1, pos + CF.maxz); var cur = pos; var lim: usize = body;
putz(buff[0..lim], &cur, what); if (whyz.len > 0) { putz(buff[0..lim], &cur, " - "); putz(buff[0..lim], &cur, whyz); } if (fixz.len > 0) { putz(buff[0..lim], &cur, "; fix: "); putz(buff[0..lim], &cur, fixz); }
if (cur >= lim and lim >= 1) cur = lim - 1; lim = cur; buff[lim] = '\n'; return buff[0 .. lim + 1];
}
pub fn logz(modz: []const u8, levl: Levl, what: []const u8, whyz: []const u8, fixz: []const u8) void { var buff: [640]u8 = undefined; const outp = lineTwo(&buff, modz, levl, nowzMill(), &tidz, what, whyz, fixz); std.debug.print("{s}", .{outp}); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
