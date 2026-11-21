// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Newest-first deduped capped command history file
// Flo: lock > read entries > prepend new > drop older dupes > cap history > atomic rewrite (stream tail cap 8 KB: UI cuts at 5 KB, uncapped file hit 464 KB)
// I/O: cmd + stdout, stderr, code, elapsed, cwd, shell (POST /save) > data folder/history.txt ("####"-separated entries)
// ===================================================================
const std = @import("std"); const store = @import("store");
// libc time shim (no @cImport in 0.17); Windows struct tm has no gmtoff/zone
const clib = struct {
const win = @import("builtin").os.tag == .windows;
pub const time_t = i64;
pub const struct_tm = if (win) extern struct { tm_sec: c_int, tm_min: c_int, tm_hour: c_int, tm_mday: c_int, tm_mon: c_int, tm_year: c_int, tm_wday: c_int, tm_yday: c_int, tm_isdst: c_int } else extern struct { tm_sec: c_int, tm_min: c_int, tm_hour: c_int, tm_mday: c_int, tm_mon: c_int, tm_year: c_int, tm_wday: c_int, tm_yday: c_int, tm_isdst: c_int, tm_gmtoff: c_long, tm_zone: ?[*:0]const u8 };
extern "c" fn time(?*time_t) time_t;
extern "c" fn localtime_r(*const time_t, *struct_tm) ?*struct_tm;
extern "c" fn _time64(?*time_t) time_t;
extern "c" fn _localtime64(*const time_t) ?*struct_tm;
pub fn nowz() time_t { return if (win) _time64(null) else time(null); }
pub fn loca(src: *const time_t, out: *struct_tm) bool { if (win) { const ptrz = _localtime64(src) orelse return false; out.* = ptrz.*; return true; } return localtime_r(src, out) != null; }
};
const CF = .{ .sepa_entr = "\n####\n", .maxz_stre = 8 * 1024, .file = "history.txt", .zero = "0000-00-00 00:00:00" };
pub const SEPA_ENTR = CF.sepa_entr; pub const MAXZ_STRE = CF.maxz_stre;
pub const Entr = struct { cmdz: []const u8, outp: []const u8 = "", erro: []const u8 = "", code: i32 = 0, elap: i64 = 0, cwdz: []const u8 = "", shel: []const u8 = "" };
fn timeStam(buff: []u8) []const u8 { var nowz: clib.time_t = clib.nowz(); var ctim: clib.struct_tm = undefined; if (!timeLoca(&nowz, &ctim)) return CF.zero; return std.fmt.bufPrint(buff, "{d:0>4}-{d:0>2}-{d:0>2} {d:0>2}:{d:0>2}:{d:0>2}", .{ @as(u32, @intCast(ctim.tm_year + 1900)), @as(u32, @intCast(ctim.tm_mon + 1)), @as(u32, @intCast(ctim.tm_mday)), @as(u32, @intCast(ctim.tm_hour)), @as(u32, @intCast(ctim.tm_min)), @as(u32, @intCast(ctim.tm_sec)) }) catch CF.zero; }
fn timeLoca(nowz: *const clib.time_t, outz: *clib.struct_tm) bool { return clib.loca(nowz, outz); }
pub fn entrAppe(allo: std.mem.Allocator, iozz: std.Io, entr: Entr) !void { var stam_buff: [32]u8 = undefined; const stam = timeStam(&stam_buff); var entr_allo: std.Io.Writer.Allocating = .init(allo); defer entr_allo.deinit(); const wrtr = &entr_allo.writer; try wrtr.print("[{s}]  exit:{d}  elapsed:{d}ms\n", .{ stam, entr.code, entr.elap }); if (entr.cwdz.len > 0 or entr.shel.len > 0) try wrtr.print("@ {s}  [{s}]\n", .{ entr.cwdz, if (entr.shel.len > 0) entr.shel else "default" }); try wrtr.print("$ {s}\n", .{entr.cmdz}); try streWrit(wrtr, "stdout", entr.outp); try streWrit(wrtr, "stderr", entr.erro); try wrtr.writeAll("--- end ---"); try store.mute_save.lock(iozz); defer store.mute_save.unlock(iozz); const exis = store.load(allo, iozz, CF.file); const cmdz_line = try std.fmt.allocPrint(allo, "$ {s}", .{entr.cmdz}); var outz: std.Io.Writer.Allocating = .init(allo); defer outz.deinit(); try outz.writer.writeAll(entr_allo.writer.buffered()); var kept: usize = 1; var iter = std.mem.splitSequence(u8, exis, CF.sepa_entr); while (iter.next()) |rawz| { const oldz = std.mem.trim(u8, rawz, " \t\r\n"); if (oldz.len == 0 or std.mem.eql(u8, oldz, "{}")) continue; if (kept >= store.tune.hist_maxz) break; if (cmdzLineHasz(oldz, cmdz_line)) continue; try outz.writer.writeAll(CF.sepa_entr); try outz.writer.writeAll(oldz); kept += 1; } try outz.writer.writeAll("\n"); try store.lockSave(allo, iozz, CF.file, outz.writer.buffered()); }
fn streWrit(wrtr: *std.Io.Writer, labe: []const u8, data: []const u8) !void { const tail = std.mem.trimEnd(u8, data, " \t\r\n"); if (std.mem.trim(u8, tail, " \t\r\n").len == 0) return; if (tail.len > CF.maxz_stre) { try wrtr.print("--- {s} ---\n[…{d} bytes cut]\n", .{ labe, tail.len - CF.maxz_stre }); try bodyWrit(wrtr, tail[tail.len - CF.maxz_stre ..]); } else { try wrtr.print("--- {s} ---\n", .{labe}); try bodyWrit(wrtr, tail); } try wrtr.writeByte('\n'); }
pub fn bodyWrit(wrtr: *std.Io.Writer, data: []const u8) !void { var iter = std.mem.splitScalar(u8, data, '\n'); var firs = true; while (iter.next()) |line| { if (!firs) try wrtr.writeByte('\n'); firs = false; if (std.mem.eql(u8, line, "####")) try wrtr.writeByte(' '); try wrtr.writeAll(line); } }
fn cmdzLineHasz(entr: []const u8, cmdz_line: []const u8) bool { var iter = std.mem.splitScalar(u8, entr, '\n'); while (iter.next()) |line| { if (std.mem.eql(u8, std.mem.trimEnd(u8, line, "\r"), cmdz_line)) return true; } return false; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
