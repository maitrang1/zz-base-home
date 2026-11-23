// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Mock tool runner for tests (never runs a real tool)
// Flo: match argv prefix against rules (a rule can expire after N uses) > return the canned output > record every call
// I/O: rules + argv > Outp; call log
// ===================================================================
const std = @import("std");
const runm = @import("ru-cmdz-runn.zig");
pub const Rule = struct { pref: []const []const u8, code: u8 = 0, outz: []const u8 = "", errz: []const u8 = "", absn: bool = false, maxz: ?usize = null };
pub const Mock = struct {
rule: []const Rule = &.{},
call: std.ArrayList([]const u8) = .empty,
used: [32]usize = @splat(0),
pub fn runn(self: *Mock) runm.Runn { return .{ .ctxz = self, .runz = mockRunz }; }
pub fn callz(self: *const Mock, pref: []const u8) usize {
var cntz: usize = 0;
for (self.call.items) |item| { if (std.mem.startsWith(u8, item, pref)) cntz += 1; }
return cntz;
}
};
fn prefOkay(pref: []const []const u8, argv: []const []const u8) bool {
if (pref.len > argv.len) return false;
for (pref, 0..) |item, indx| { if (!std.mem.eql(u8, item, argv[indx])) return false; }
return true;
}
fn mockRunz(ctxz: *anyopaque, allo: std.mem.Allocator, argv: []const []const u8, envp: []const runm.Envp) anyerror!runm.Outp {
_ = envp;
const self: *Mock = @ptrCast(@alignCast(ctxz));
try self.call.append(allo, try std.mem.join(allo, " ", argv));
for (self.rule, 0..) |item, indx| {
if (!prefOkay(item.pref, argv)) continue;
if (item.maxz) |lim| { if (self.used[indx] >= lim) continue; }
self.used[indx] += 1;
if (item.absn) return runm.Erro.ToolAbsent;
return .{ .code = item.code, .outz = try allo.dupe(u8, item.outz), .errz = try allo.dupe(u8, item.errz) };
}
return runm.Erro.ToolAbsent;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
