// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Network probe helpers: Win32 sockets, HTTP status parse
// Flo: winsock start > connect with deadline > cond or null
// I/O: host + port + ms > Cond; HTTP head > status code
// ===================================================================
const std = @import("std"); const builtin = @import("builtin"); const spawn = @import("spawn"); const netz = std.Io.net;
const evprobbase = @import("ev-prob-base.zig"); const ArmzErro = evprobbase.ArmzErro; const CF = evprobbase.CF; const Cond = evprobbase.Cond; const Kind = evprobbase.Kind; const duraPars = evprobbase.duraPars; const sizePars = evprobbase.sizePars;
const wsoc = struct {
const SOCKET = usize; const INVALID_SOCKET = ~@as(usize, 0); const SOCKET_ERROR = -1; const ws2z = std.os.windows.ws2_32;
const WSAEWOULDBLOCK = 10035; const WSAECONNREFUSED = 10061; const WSAENETUNREACH = 10051; const WSAEHOSTUNREACH = 10065; const WSAETIMEDOUT = 10060; const FIONBIO: u32 = 0x8004667E;
const fd_set = extern struct { fd_count: u32, fd_array: [64]SOCKET };
const WSADATA = extern struct { wVersion: u16, wHighVersion: u16, iMaxSockets: u16, iMaxUdpDg: u16, lpVendorInfo: ?*u8, szDescription: [257]u8, szSystemStatus: [129]u8 };
extern "ws2_32" fn WSAStartup(v: u16, d: *WSADATA) callconv(.winapi) i32;
extern "ws2_32" fn socket(af: i32, ty: i32, proto: i32) callconv(.winapi) SOCKET;
extern "ws2_32" fn closesocket(s: SOCKET) callconv(.winapi) i32;
extern "ws2_32" fn connect(s: SOCKET, name: *const anyopaque, namelen: i32) callconv(.winapi) i32;
extern "ws2_32" fn ioctlsocket(s: SOCKET, cmd: u32, argp: *u32) callconv(.winapi) i32;
extern "ws2_32" fn select(nfds: i32, r: ?*fd_set, w: ?*fd_set, e: ?*fd_set, t: ?*const ws2z.timeval) callconv(.winapi) i32;
extern "ws2_32" fn getsockopt(s: SOCKET, level: i32, name: i32, val: *anyopaque, len: *i32) callconv(.winapi) i32;
extern "ws2_32" fn WSAGetLastError() callconv(.winapi) i32;
};
var wsaz_star = std.atomic.Value(bool).init(false);
fn wsazEnsu() void { if (comptime builtin.os.tag != .windows) return; if (wsaz_star.load(.acquire)) return; var wdat: wsoc.WSADATA = undefined; _ = wsoc.WSAStartup(0x0202, &wdat); wsaz_star.store(true, .release); }
pub fn winzConnCond(host: []const u8, port: u16, time_msec: u32) ?Cond { if (comptime builtin.os.tag != .windows) return null; wsazEnsu(); const ws2z = std.os.windows.ws2_32; const ipzz = netz.IpAddress.parse(host, port) catch return null; var stor: ws2z.sockaddr.storage = undefined; var addr_leng: i32 = 0; var fami: i32 = 0; switch (ipzz) { .ip4 => |addr| { const sadr: *ws2z.sockaddr.in = @ptrCast(&stor); sadr.* = .{ .family = ws2z.AF.INET, .port = std.mem.nativeToBig(u16, port), .addr = @bitCast(addr.bytes) }; addr_leng = @sizeOf(ws2z.sockaddr.in); fami = ws2z.AF.INET; }, .ip6 => |addr| { const sadr: *ws2z.sockaddr.in6 = @ptrCast(&stor); sadr.* = .{ .family = ws2z.AF.INET6, .port = std.mem.nativeToBig(u16, port), .flowinfo = addr.flow, .addr = addr.bytes, .scope_id = addr.interface.index }; addr_leng = @sizeOf(ws2z.sockaddr.in6); fami = ws2z.AF.INET6; } } const sock = wsoc.socket(fami, ws2z.SOCK.STREAM, 0); if (sock == wsoc.INVALID_SOCKET) return null; defer _ = wsoc.closesocket(sock); var nblk: u32 = 1; if (wsoc.ioctlsocket(sock, wsoc.FIONBIO, &nblk) != 0) return null; if (wsoc.connect(sock, &stor, addr_leng) == 0) return .onzz; const erro = wsoc.WSAGetLastError(); if (erro != wsoc.WSAEWOULDBLOCK) { return switch (erro) { wsoc.WSAECONNREFUSED, wsoc.WSAENETUNREACH, wsoc.WSAEHOSTUNREACH, wsoc.WSAETIMEDOUT => .offz, else => null }; } var wset: wsoc.fd_set = .{ .fd_count = 1, .fd_array = undefined }; wset.fd_array[0] = sock; var eset: wsoc.fd_set = .{ .fd_count = 1, .fd_array = undefined }; eset.fd_array[0] = sock; const tvzz: ws2z.timeval = .{ .sec = @intCast(time_msec / 1000), .usec = @intCast((time_msec % 1000) * 1000) }; const numb = wsoc.select(0, null, &wset, &eset, &tvzz); if (numb == 0) return .offz; if (numb == wsoc.SOCKET_ERROR) return null; if (wset.fd_count > 0) return .onzz; var soer: i32 = 0; var leng: i32 = @sizeOf(i32); if (wsoc.getsockopt(sock, ws2z.SOL.SOCKET, ws2z.SO.ERROR, &soer, &leng) != 0) return null; return switch (soer) { wsoc.WSAECONNREFUSED, wsoc.WSAENETUNREACH, wsoc.WSAEHOSTUNREACH, wsoc.WSAETIMEDOUT => .offz, else => null }; }
pub fn ipzzLiteChec(host: []const u8) bool { _ = netz.IpAddress.parse(host, 0) catch return false; return true; }
pub fn statPars(head: []const u8) ?u16 { if (!std.mem.startsWith(u8, head, "HTTP/")) return null; const spac = std.mem.indexOfScalar(u8, head, ' ') orelse return null; var rest = head[spac + 1 ..]; if (rest.len < 3) return null; rest = rest[0..3]; return std.fmt.parseInt(u16, rest, 10) catch null; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
