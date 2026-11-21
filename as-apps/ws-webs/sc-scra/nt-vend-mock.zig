// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Scripted fake vendor backend for tests, never live
// Flo: match URL to a rule > block until the rule's minimum mode > bill like the real price table > log every call
// I/O: Req (ladder) > Rsp; calls list kept for assertions
// ===================================================================
const std = @import("std"); const base = @import("nt-vend-base.zig"); const fixt = @import("te-fixt-html.zig");
pub const Rule = struct { hasz: []const u8, minm: base.Mode = .plain, body: []const u8 = "<html><body><p>Vendor page, real text content here.</p></body></html>" };
pub const Call = struct { vend: base.Vend, mode: base.Mode, urlz: []const u8, geoz: []const u8 = "", wait: u32 = 0, sele: []const u8 = "" };
pub const Mock = struct { gpaz: std.mem.Allocator, rul2: []const Rule = &.{}, down: [4]bool = .{ false, false, false, false }, calls: std.ArrayList(Call) = .empty,
pub fn init(gpaz: std.mem.Allocator) Mock { return .{ .gpaz = gpaz }; }
pub fn deinit(self: *Mock) void { for (self.calls.items) |item| self.gpaz.free(item.urlz); self.calls.deinit(self.gpaz); }
pub fn backend(self: *Mock) base.Backend { return .{ .ctx2 = self, .call = cal2 }; }
pub fn hits(self: *Mock, vend: base.Vend) usize { var con2: usize = 0; for (self.calls.items) |item| if (item.vend == vend) { con2 += 1; }; return con2; }
fn cal2(ctx2: *anyopaque, _: std.mem.Allocator, _: std.Io, vend: base.Vend, req2: base.Requ) anyerror!base.Res2 { const self: *Mock = @ptrCast(@alignCast(ctx2)); try self.calls.append(self.gpaz, .{ .vend = vend, .mode = req2.mode, .urlz = try self.gpaz.dupe(u8, req2.urlz), .geoz = req2.geoz, .wait = req2.wait, .sele = req2.sele }); if (self.down[@backingInt(vend)]) return .{ .code = 401, .ctyp = "", .body = "", .cred = 0, .errz = "AUTH001" }; for (self.rul2) |rule| { if (std.mem.indexOf(u8, req2.urlz, rule.hasz) == null) continue; if (@backingInt(req2.mode) < @backingInt(rule.minm)) return .{ .code = 200, .ctyp = "text/html", .body = fixt.cfch, .cred = base.credRequ(vend, req2), .errz = "" }; return .{ .code = 200, .ctyp = "text/html", .body = rule.body, .cred = base.credRequ(vend, req2), .errz = "" }; } return .{ .code = 200, .ctyp = "text/html", .body = "<html><body><p>Default vendor page, real text content.</p></body></html>", .cred = base.credRequ(vend, req2), .errz = "" }; } };
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
