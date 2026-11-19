// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Only OS-specific reads for wo doct: patch, ESU, CPU
// Flo: pick the OS tool (PowerShell / stat / reg) > run it through the runner > parse to one number
// I/O: Ctxz + OS tag > Host (unknown with a reason, a time, or a value)
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const isoz = @import("ti-isoz-epoc.zig");
const CF = .{ .esuk = "HKCU\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Windows\\ConsumerESU", .esun = "ESUEligibility", .aptl = "/var/log/apt/history.log", .pshl = "(Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 1).InstalledOn.ToString('yyyy-MM-dd')" };
pub const Host = union(enum) { unkn: []const u8, nota: void, when: i64, valu: i64 };
pub fn dateEpoc(allo: std.mem.Allocator, text: []const u8) ?i64 {
const full = std.fmt.allocPrint(allo, "{s}T00:00:00Z", .{cx.trim(text)}) catch return null;
return isoz.isoEpoc(full);
}
pub fn esusParse(text: []const u8) ?i64 {
var lines = std.mem.splitScalar(u8, text, '\n');
while (lines.next()) |line| {
var toks = std.mem.tokenizeAny(u8, line, " \t\r");
const name = toks.next() orelse continue;
if (!std.mem.eql(u8, name, CF.esun)) continue;
_ = toks.next() orelse return null;
const valu = toks.next() orelse return null;
const body = if (std.mem.startsWith(u8, valu, "0x")) valu[2..] else valu;
return std.fmt.parseInt(i64, body, 16) catch null;
}
return null;
}
pub fn patcLast(ctxz: *const cx.Ctxz, ostg: std.Target.Os.Tag) !Host {
switch (ostg) {
.windows => {
const outp = (try ctxz.tool(&.{ "powershell", "-NoProfile", "-Command", CF.pshl }, &.{})) orelse return .{ .unkn = "powershell absent" };
if (outp.code != 0) return .{ .unkn = "Get-HotFix failed" };
return if (dateEpoc(ctxz.allo, outp.outz)) |when| .{ .when = when } else .{ .unkn = "hotfix date not parsable" };
},
.linux => {
const outp = (try ctxz.tool(&.{ "stat", "-c", "%Y", CF.aptl }, &.{})) orelse return .{ .unkn = "stat absent" };
if (outp.code != 0) return .{ .unkn = "no apt history (not a Debian-family OS?)" };
return if (std.fmt.parseInt(i64, cx.trim(outp.outz), 10)) |when| .{ .when = when } else |_| .{ .unkn = "stat output not a number" };
},
else => return .{ .unkn = "patch age not supported on this OS" },
}
}
pub fn esusCode(ctxz: *const cx.Ctxz, ostg: std.Target.Os.Tag) !Host {
if (ostg != .windows) return .nota;
const outp = (try ctxz.tool(&.{ "reg.exe", "query", CF.esuk }, &.{})) orelse return .{ .unkn = "reg.exe absent" };
if (outp.code != 0) return .{ .unkn = "ConsumerESU key absent: not enrolled, or unknown" };
return if (esusParse(outp.outz)) |valu| .{ .valu = valu } else .{ .unkn = "ESUEligibility not parsable" };
}
pub fn cpuOkay(model: []const u8, list: []const []const u8) bool {
for (list) |item| { if (std.mem.eql(u8, item, model)) return true; }
return false;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
