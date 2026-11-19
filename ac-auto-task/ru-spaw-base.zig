// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Spawn basics: limits, env expand, child spawn lock, clock
// Flo: consts > env expand > locked spawn > capture run
// I/O: cmd + env map > expanded text, child, captured output
// ===================================================================
const std = @import("std"); const builtin = @import("builtin"); const regi = @import("registry"); const stre = @import("stream"); const cwdi = @import("cwd"); const stor = @import("store");
pub const CF = .{ .pipe_buff = 16 * 1024, .moni_msec = 200, .moni_slic = 10, .auxi_stak = 1024 * 1024, .keep_deci = 30, .encz_buff = 16 * 1024 * 6 + 64, .teez_tail = 4096, .teez_coun = 3, .teez_line_maxz = 200, .time_code = -2, .envi_name = "CMDRUN_CMD", .shel_buff = 256, .orph_maxz = 256, .orph_file = "task-state" ++ std.fs.path.sep_str ++ "pgids" };
pub const TIME_CODE: i32 = CF.time_code; pub const CMDZ_ENVI_VARZ = CF.envi_name;
pub fn enviExpa(allo: std.mem.Allocator, srcz: []const u8, mapz: *const std.process.Environ.Map) ![]const u8 { var outz: std.ArrayList(u8) = .empty; var indx: usize = 0; while (indx < srcz.len) { if (srcz[indx] != '%') { try outz.append(allo, srcz[indx]); indx += 1; continue; } if (indx + 1 < srcz.len and srcz[indx + 1] == '%') { try outz.append(allo, '%'); indx += 2; continue; } const clos = std.mem.indexOfScalarPos(u8, srcz, indx + 1, '%') orelse { try outz.append(allo, srcz[indx]); indx += 1; continue; }; const name = srcz[indx + 1 .. clos]; if (name.len == 0 or std.mem.indexOfScalar(u8, name, ':') != null) { try outz.appendSlice(allo, srcz[indx .. clos + 1]); indx = clos + 1; continue; } if (mapz.get(name)) |valz| { try outz.appendSlice(allo, valz); } else { try outz.appendSlice(allo, srcz[indx .. clos + 1]); } indx = clos + 1; } return outz.toOwnedSlice(allo); }
pub var mute_spaw: std.Io.Mutex = .init;
pub fn chilSpaw(iozz: std.Io, opts: std.process.SpawnOptions) !std.process.Child { try mute_spaw.lock(iozz); defer mute_spaw.unlock(iozz); return std.process.spawn(iozz, opts); }
pub fn runzCapt(allo: std.mem.Allocator, iozz: std.Io, argv: []const []const u8, maxz: usize) ?[]u8 { var chil = chilSpaw(iozz, .{ .argv = argv, .stdin = .ignore, .stdout = .pipe, .stderr = .ignore, .create_no_window = true }) catch return null; var outz: std.ArrayList(u8) = .empty; var buff: [4096]u8 = undefined; if (chil.stdout) |file| { while (true) { const size = file.readStreaming(iozz, &.{&buff}) catch 0; if (size == 0) break; if (outz.items.len + size <= maxz) outz.appendSlice(allo, buff[0..size]) catch {}; } } const term = chil.wait(iozz) catch return null; if (term != .exited or term.exited != 0) return null; return outz.toOwnedSlice(allo) catch null; }
pub fn nowzMsec(iozz: std.Io) i64 { return std.Io.Clock.real.now(iozz).toMilliseconds(); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
