// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: One run lock per data folder, stale-safe
// Flo: exclusive create scra.lock with our pid > on conflict read pid > live other pid: Locked; dead pid: replace > release removes
// I/O: data folder (caller) > Lock handle; error Locked while another run is alive
// ===================================================================
const std = @import("std"); const builtin = @import("builtin");
const CF = .{ .file = "scra.lock", .maxz = 64, .qlim = 0x1000, .busy = 259 };
const kern = if (builtin.os.tag == .windows) struct { extern "kernel32" fn GetCurrentProcessId() callconv(.winapi) u32; extern "kernel32" fn OpenProcess(acc: u32, inh: i32, pid: u32) callconv(.winapi) ?std.os.windows.HANDLE; extern "kernel32" fn GetExitCodeProcess(hnd: std.os.windows.HANDLE, code: *u32) callconv(.winapi) i32; extern "kernel32" fn CloseHandle(hnd: std.os.windows.HANDLE) callconv(.winapi) i32; } else struct {};
pub fn pidSelf() u32 { if (builtin.os.tag == .windows) return kern.GetCurrentProcessId(); return @intCast(std.c.getpid()); }
pub fn pidAlive(pid: u32) bool { if (pid == 0) return false; if (builtin.os.tag == .windows) { const hnd = kern.OpenProcess(CF.qlim, 0, pid) orelse return false; defer _ = kern.CloseHandle(hnd); var code: u32 = 0; if (kern.GetExitCodeProcess(hnd, &code) == 0) return false; return code == CF.busy; } return std.c.kill(@intCast(pid), @enumFromInt(0)) == 0; }
pub const Lock = struct { allo: std.mem.Allocator, iozz: std.Io, path: []u8, pub fn release(self: *Lock) void { std.Io.Dir.cwd().deleteFile(self.iozz, self.path) catch {}; self.allo.free(self.path); } };
fn pidOf(allo: std.mem.Allocator, iozz: std.Io, path: []const u8) u32 { const txt = std.Io.Dir.cwd().readFileAlloc(iozz, path, allo, .limited(CF.maxz)) catch return 0; defer allo.free(txt); return std.fmt.parseInt(u32, std.mem.trim(u8, txt, " \r\n"), 10) catch 0; }
pub fn take(allo: std.mem.Allocator, iozz: std.Io, dirz: []const u8) !Lock { try std.Io.Dir.cwd().createDirPath(iozz, dirz); const path = try std.fs.path.join(allo, &.{ dirz, CF.file }); errdefer allo.free(path); var tries: u32 = 0; while (tries < 2) : (tries += 1) { var buf: [32]u8 = undefined; const txt = try std.fmt.bufPrint(&buf, "{d}", .{pidSelf()}); if (std.Io.Dir.cwd().writeFile(iozz, .{ .sub_path = path, .data = txt, .flags = .{ .exclusive = true } })) |_| { return .{ .allo = allo, .iozz = iozz, .path = path }; } else |err| { if (err != error.PathAlreadyExists) return err; } const other = pidOf(allo, iozz, path); if (other != 0 and pidAlive(other)) return error.Locked; std.Io.Dir.cwd().deleteFile(iozz, path) catch {}; } return error.Locked; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
