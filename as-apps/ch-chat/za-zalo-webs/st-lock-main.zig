// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: One run lock for every entry point: pid file, stale lock cleared by pid check
// Flo: exclusive create > on conflict read pid > live other pid: Busy; dead pid: replace > release removes
// I/O: lock path + pid (caller) > lock file; error Busy when another run is alive
// ===================================================================
const std = @import("std"); const builtin = @import("builtin");
const kern = if (builtin.os.tag == .windows) struct { extern "kernel32" fn GetCurrentProcessId() callconv(.winapi) u32; extern "kernel32" fn OpenProcess(acc: u32, inh: i32, pid: u32) callconv(.winapi) ?std.os.windows.HANDLE; extern "kernel32" fn GetExitCodeProcess(hnd: std.os.windows.HANDLE, code: *u32) callconv(.winapi) i32; extern "kernel32" fn CloseHandle(hnd: std.os.windows.HANDLE) callconv(.winapi) i32; } else struct {};
pub fn pidSelf() u32 { if (builtin.os.tag == .windows) return kern.GetCurrentProcessId(); return @intCast(std.c.getpid()); }
pub fn pidAlive(pid: u32) bool { if (pid == 0) return false; if (builtin.os.tag == .windows) { const hnd = kern.OpenProcess(0x1000, 0, pid) orelse return false; defer _ = kern.CloseHandle(hnd); var code: u32 = 0; if (kern.GetExitCodeProcess(hnd, &code) == 0) return false; return code == 259; } return std.c.kill(@intCast(pid), @enumFromInt(0)) == 0; }
fn pidOf(allo: std.mem.Allocator, iozz: std.Io, path: []const u8) ?u32 { const txt = std.Io.Dir.cwd().readFileAlloc(iozz, path, allo, .limited(64)) catch return null; defer allo.free(txt); var itr = std.mem.splitScalar(u8, txt, ' '); const first = itr.next() orelse return null; return std.fmt.parseInt(u32, std.mem.trim(u8, first, " \r\n"), 10) catch null; }
pub fn acquire(allo: std.mem.Allocator, iozz: std.Io, path: []const u8, pid: u32, now_ms: i64) !void { if (std.fs.path.dirname(path)) |dirz| try std.Io.Dir.cwd().createDirPath(iozz, dirz); var tries: u32 = 0; while (tries < 2) : (tries += 1) { if (std.Io.Dir.cwd().createFile(iozz, path, .{ .exclusive = true })) |fil| { defer fil.close(iozz); var buf: [48]u8 = undefined; try fil.writeStreamingAll(iozz, try std.fmt.bufPrint(&buf, "{d} {d}\n", .{ pid, now_ms })); return; } else |err| { if (err != error.PathAlreadyExists) return err; } const other = pidOf(allo, iozz, path); if (other != null and other.? != pid and pidAlive(other.?)) return error.Busy; std.Io.Dir.cwd().deleteFile(iozz, path) catch {}; } return error.Busy; }
pub fn release(iozz: std.Io, path: []const u8) void { std.Io.Dir.cwd().deleteFile(iozz, path) catch {}; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
