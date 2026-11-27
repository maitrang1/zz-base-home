// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: id-edit-iden entry: parse flags, load config, find the repo, run a command
// Flo: args > ladder flags > config > repo root > context > dispatch stat/plan/run/undo > flush > exit
// I/O: argv + aa-conf-main.json > text or JSON on stdout, errors on stderr, exit 0-4
// Run: E:\zz-base-home\as-apps\os-syst\id-edit-iden\zig-out\bin\id-edit-iden.exe stat
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const cfgz = @import("cf-conf-load.zig");
const ladz = @import("ct-safe-ladd.zig");
const runm = @import("ru-cmdz-runn.zig");
const exit = @import("ct-exit-code.zig");
const stat = @import("ct-comm-stat.zig");
const plan = @import("ct-comm-plan.zig");
const runz = @import("ct-comm-runz.zig");
const undo = @import("ct-comm-undo.zig");
const CF = .{ .bufz = 8192, .usag = "usage: id-edit-iden [--conf FILE] [--json] [--dry-run | --live [--force]] stat | plan PAIRS | run PAIRS | undo ID|last\nPAIRS: old=new ... [--map FILE] [--scope all|repo|state] [--no-docs]\n" };
fn dispatch(ctxz: *const cx.Ctxz, rest: []const []const u8) !exit.Code {
if (rest.len == 0) return exit.Erro.Usag;
const comm = rest[0];
const tail = rest[1..];
if (std.mem.eql(u8, comm, "stat") or std.mem.eql(u8, comm, "status")) return stat.comm(ctxz, tail);
if (std.mem.eql(u8, comm, "plan")) return plan.comm(ctxz, tail);
if (std.mem.eql(u8, comm, "run")) return runz.comm(ctxz, tail);
if (std.mem.eql(u8, comm, "undo")) return undo.comm(ctxz, tail);
return exit.Erro.Usag;
}
fn run(init: std.process.Init, outw: *std.Io.Writer) !exit.Code {
const allo = init.arena.allocator();
var args: std.ArrayList([]const u8) = .empty;
var iter = try init.minimal.args.iterateAllocator(allo);
_ = iter.next();
while (iter.next()) |arg| try args.append(allo, arg);
if (args.items.len == 1 and (std.mem.eql(u8, args.items[0], "--help") or std.mem.eql(u8, args.items[0], "-h"))) { try outw.print("{s}", .{CF.usag}); return .okay; }
const pars = ladz.parse(allo, args.items) catch |err| { std.debug.print("id-edit-iden: {s}\n" ++ CF.usag, .{@errorName(err)}); return .usag; };
const cfgv = cfgz.confLoad(allo, init.io, pars.conf) catch |err| { std.debug.print("id-edit-iden: config unreadable: {s}\nfix: check aa-conf-main.json\n", .{@errorName(err)}); return .usag; };
const home = init.environ_map.get("USERPROFILE") orelse init.environ_map.get("HOME") orelse { std.debug.print("id-edit-iden: no HOME or USERPROFILE in the environment\n", .{}); return .fail; };
const cwdz = std.process.currentPathAlloc(init.io, allo) catch |err| { std.debug.print("id-edit-iden: cannot read the current folder: {s}\n", .{@errorName(err)}); return .fail; };
const exed: ?[]const u8 = std.process.executableDirPathAlloc(init.io, allo) catch null;
const repo = cx.repoFind(allo, init.io, cfgv, cwdz, exed) catch { std.debug.print("id-edit-iden: repo root not found (no ac-auto-task/aa-conf-main.json above here)\nfix: run from inside the repo, or set repo_root in aa-conf-main.json\n", .{}); return .bloc; };
var real: runm.Real = .{ .iozz = init.io, .envm = init.environ_map };
const ctxz: cx.Ctxz = .{ .allo = allo, .gpaz = init.gpa, .iozz = init.io, .conf = cfgv, .ladd = pars.ladd, .outw = outw, .home = home, .repo = repo, .nowf = cx.realNow, .runn = real.runn() };
return dispatch(&ctxz, pars.rest) catch |err| switch (err) {
exit.Erro.Usag => { std.debug.print(CF.usag, .{}); return .usag; },
else => { std.debug.print("id-edit-iden: failed: {s}\n", .{@errorName(err)}); return .fail; },
};
}
pub fn main(init: std.process.Init) !void {
var buff: [CF.bufz]u8 = undefined;
var wrtr = std.Io.File.stdout().writerStreaming(init.io, &buff);
const code = try run(init, &wrtr.interface);
try wrtr.interface.flush();
exit.exitz(code);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
