// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Test double for the tool runner: canned replies
// Flo: match argv against rule prefixes > record the call > return the canned reply
// I/O: Rule list + argv > Outp; no rule match = tool absent
// ===================================================================
const std = @import("std");
const runm = @import("ru-cmdz-runn.zig");
pub const Rule = struct { pref: []const []const u8, code: u8 = 0, outz: []const u8 = "", errz: []const u8 = "", absn: bool = false };
pub const Mock = struct {
rule: []const Rule,
call: std.ArrayList([]const u8) = .empty,
envz: std.ArrayList([]const u8) = .empty,
pub fn runn(self: *Mock) runm.Runn { return .{ .ctxz = self, .runz = mockRunz }; }
};
fn prefOkay(pref: []const []const u8, argv: []const []const u8) bool {
if (pref.len > argv.len) return false;
for (pref, 0..) |item, indx| { if (!std.mem.eql(u8, item, argv[indx])) return false; }
return true;
}
fn mockRunz(ctxz: *anyopaque, allo: std.mem.Allocator, argv: []const []const u8, envp: []const runm.Envp) anyerror!runm.Outp {
const self: *Mock = @ptrCast(@alignCast(ctxz));
try self.call.append(allo, try std.mem.join(allo, " ", argv));
for (envp) |pair| try self.envz.append(allo, try std.fmt.allocPrint(allo, "{s}={s}", .{ pair[0], pair[1] }));
for (self.rule) |item| {
if (!prefOkay(item.pref, argv)) continue;
if (item.absn) return runm.Erro.ToolAbsent;
return .{ .code = item.code, .outz = try allo.dupe(u8, item.outz), .errz = try allo.dupe(u8, item.errz) };
}
return runm.Erro.ToolAbsent;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
