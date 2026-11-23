// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: One lock for every entry point so two zr runs never share a profile
// Flo: create zr.lock exclusively with our pid > if it exists check the old pid is alive > stale lock replaced > release deletes it
// I/O: state folder (caller) > Lock handle; error Locked when another live run holds it
// ===================================================================
const std = @import("std"); const builtin = @import("builtin");
const CF = .{ .file = "zr.lock", .maxz = 32, .qlim = 0x1000 };
const wx = if (builtin.os.tag == .windows) struct { extern "kernel32" fn OpenProcess(acc: u32, inh: i32, pid: u32) callconv(.winapi) ?*anyopaque; extern "kernel32" fn CloseHandle(hnd: ?*anyopaque) callconv(.winapi) i32; extern "kernel32" fn GetCurrentProcessId() callconv(.winapi) u32; } else struct {};
pub fn myPid() u32 { if (builtin.os.tag == .windows) return wx.GetCurrentProcessId(); return @intCast(std.c.getpid()); }
pub fn alive(pid: u32) bool { if (pid == 0) return false; if (builtin.os.tag == .windows) { const hnd = wx.OpenProcess(CF.qlim, 0, pid); if (hnd == null) return false; _ = wx.CloseHandle(hnd); return true; } return std.c.kill(@intCast(pid), @fromBackingInt(0)) == 0; }
pub const Lock = struct { gpaz: std.mem.Allocator, iozz: std.Io, path: []u8,
pub fn release(self: *Lock) void { std.Io.Dir.cwd().deleteFile(self.iozz, self.path) catch {}; self.gpaz.free(self.path); } };
pub fn take(gpaz: std.mem.Allocator, iozz: std.Io, dir: []const u8) !Lock { const path = try std.fs.path.join(gpaz, &.{ dir, CF.file }); errdefer gpaz.free(path); var att: u32 = 0; while (att < 2) : (att += 1) { var buf: [32]u8 = undefined; const txt = try std.fmt.bufPrint(&buf, "{d}", .{myPid()}); if (std.Io.Dir.cwd().writeFile(iozz, .{ .sub_path = path, .data = txt, .flags = .{ .exclusive = true } })) |_| { return .{ .gpaz = gpaz, .iozz = iozz, .path = path }; } else |err| { if (err != error.PathAlreadyExists) return err; } const old = std.Io.Dir.cwd().readFileAlloc(iozz, path, gpaz, .limited(CF.maxz)) catch ""; defer if (old.len > 0) gpaz.free(old); const pid = std.fmt.parseInt(u32, std.mem.trim(u8, old, " \r\n"), 10) catch 0; if (alive(pid)) return error.Locked; std.Io.Dir.cwd().deleteFile(iozz, path) catch {}; } return error.Locked; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
