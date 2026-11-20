// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Test helper: headless Chrome on a scratch profile loading a fake page
// Flo: find browser > launch scratch profile > connect > navigate data url > eval/stop
// I/O: html text + scratch dir (test) > Mock with live CDP connection
// ===================================================================
const std = @import("std"); const cdp = @import("nt-cdpz-sock.zig"); const brow = @import("nt-brow-laun.zig"); const snap = @import("ru-page-snap.zig");
const CF = .{ .head = "data:text/html;charset=utf-8,", .wait = 15000 };
pub const Mock = struct { gpaz: std.mem.Allocator, bro: brow.Brow, conn: *cdp.Conn,
pub fn stop(self: *Mock) void { self.conn.close(); self.bro.stop(); }
pub fn load(self: *Mock, html: []const u8) !void { var aren = std.heap.ArenaAllocator.init(self.gpaz); defer aren.deinit(); const url = try dataUrl(aren.allocator(), html); try snap.navigate(aren.allocator(), self.conn, url, CF.wait); } };
pub fn dataUrl(allo: std.mem.Allocator, html: []const u8) ![]u8 { var out: std.ArrayList(u8) = .empty; errdefer out.deinit(allo); try out.appendSlice(allo, CF.head); const hexz = "0123456789ABCDEF"; for (html) |byt| { if (std.ascii.isAlphanumeric(byt) or byt == '-' or byt == '_' or byt == '.') { try out.append(allo, byt); } else { try out.appendSlice(allo, &.{ '%', hexz[byt >> 4], hexz[byt & 15] }); } } return out.toOwnedSlice(allo); }
pub fn absPath(allo: std.mem.Allocator, iozz: std.Io, path: []const u8) ![]u8 { if (std.fs.path.isAbsolute(path)) return allo.dupe(u8, path); const cwdz = try std.process.currentPathAlloc(iozz, allo); defer allo.free(cwdz); return std.fs.path.join(allo, &.{ cwdz, path }); }
pub fn start(gpaz: std.mem.Allocator, iozz: std.Io, prof: []const u8, html: []const u8) !Mock { const exe = (try brow.exeFind(gpaz, iozz, "")) orelse return error.SkipZigTest; defer gpaz.free(exe); const profa = try absPath(gpaz, iozz, prof); defer gpaz.free(profa); var bro = try brow.launch(gpaz, iozz, exe, profa, true, CF.wait); errdefer bro.stop(); const path = try brow.pageWs(gpaz, iozz, bro.port, CF.wait); defer gpaz.free(path); const conn = try cdp.connect(gpaz, iozz, bro.port, path, CF.wait); errdefer conn.close(); var self: Mock = .{ .gpaz = gpaz, .bro = bro, .conn = conn }; try self.load(html); return self; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
