// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: wo entry: parse flags, load config, run command
// Flo: args > ladder flags > config > context > dispatch stat/conf/doct/wipz/bkup/dril/kill/secr > flush > exit
// I/O: argv + aa-conf-main.json > text or JSON on stdout, errors on stderr, exit 0-4
// Run: E:\zz-base-home\wo-work-mode\zig-out\bin\wo.exe doct --prof ci
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const cfgz = @import("cf-conf-load.zig");
const ladz = @import("ct-safe-ladd.zig");
const runm = @import("ru-cmdz-runn.zig");
const exit = @import("ct-exit-code.zig");
const stat = @import("ct-comm-stat.zig");
const conf = @import("ct-comm-conf.zig");
const doct = @import("ct-comm-doct.zig");
const wipz = @import("ct-comm-wipz.zig");
const dril = @import("ct-comm-dril.zig");
const kill = @import("ct-comm-kill.zig");
const secr = @import("ct-comm-secr.zig");
const bkup = @import("ct-comm-bkup.zig");
const docs = @import("ct-comm-docs.zig");
const beat = @import("ct-comm-beat.zig");
const rels = @import("ct-comm-rels.zig");
const ciii = @import("ct-comm-ci.zig");
const push = @import("ct-comm-push.zig");
const CF = .{ .bufz = 8192, .usag = "usage: wo [--conf FILE] [--prof t0|box|ci] [--json] [--live [--force]] stat|conf|doct|wipz|push|bkup [stat|nigh]|docs init|sync|beat|rels sign TAG|ci stat|test|leak|lock|rele|repr|deps|dril|kill|secr init|lend\n" };
fn devName(allo: std.mem.Allocator, envm: *const std.process.Environ.Map, name: []const u8) ![]const u8 {
if (envm.get("WO_DEVI_NAME")) |envv| { if (envv.len > 0) return envv; }
if (name.len > 0) return name;
const raww = envm.get("COMPUTERNAME") orelse envm.get("HOSTNAME") orelse "devi";
return std.ascii.allocLowerString(allo, raww);
}
fn dispatch(ctxz: *const cx.Ctxz, rest: []const []const u8) !exit.Code {
if (rest.len == 0) return exit.Erro.Usag;
const comm = rest[0];
const tail = rest[1..];
if (std.mem.eql(u8, comm, "stat")) return stat.comm(ctxz, tail);
if (std.mem.eql(u8, comm, "conf")) return conf.comm(ctxz, tail);
if (std.mem.eql(u8, comm, "doct")) return doct.comm(ctxz, tail);
if (std.mem.eql(u8, comm, "wipz")) return wipz.comm(ctxz, tail);
if (std.mem.eql(u8, comm, "dril")) return dril.comm(ctxz, tail);
if (std.mem.eql(u8, comm, "kill")) return kill.comm(ctxz, tail);
if (std.mem.eql(u8, comm, "secr")) return secr.comm(ctxz, tail);
if (std.mem.eql(u8, comm, "bkup")) return bkup.comm(ctxz, tail);
if (std.mem.eql(u8, comm, "docs")) return docs.comm(ctxz, tail);
if (std.mem.eql(u8, comm, "beat")) return beat.comm(ctxz, tail);
if (std.mem.eql(u8, comm, "rels")) return rels.comm(ctxz, tail);
if (std.mem.eql(u8, comm, "ci")) return ciii.comm(ctxz, tail);
if (std.mem.eql(u8, comm, "push")) return push.comm(ctxz, tail);
return exit.Erro.Usag;
}
fn run(init: std.process.Init, outw: *std.Io.Writer) !exit.Code {
const allo = init.arena.allocator();
var args: std.ArrayList([]const u8) = .empty;
var iter = try init.minimal.args.iterateAllocator(allo);
_ = iter.next();
while (iter.next()) |arg| try args.append(allo, arg);
const pars = ladz.parse(allo, args.items) catch |err| { std.debug.print("wo: {s}\n" ++ CF.usag, .{@errorName(err)}); return .usag; };
const cfgv = cfgz.confLoad(allo, init.io, pars.conf) catch |err| { std.debug.print("wo: config unreadable: {s}\n", .{@errorName(err)}); return .fail; };
const home = init.environ_map.get("USERPROFILE") orelse init.environ_map.get("HOME") orelse { std.debug.print("wo: no HOME or USERPROFILE in the environment\n", .{}); return .fail; };
var real: runm.Real = .{ .iozz = init.io, .envm = init.environ_map };
const ctxz: cx.Ctxz = .{ .allo = allo, .iozz = init.io, .runn = real.runn(), .conf = cfgv, .home = home, .devi = try devName(allo, init.environ_map, cfgv.devi_name_main), .ladd = pars.ladd, .prof = pars.prof orelse cfgv.prof_main, .outw = outw, .nowf = cx.realNow };
return dispatch(&ctxz, pars.rest) catch |err| switch (err) {
exit.Erro.Usag => { std.debug.print(CF.usag, .{}); return .usag; },
else => { std.debug.print("wo: failed: {s}\n", .{@errorName(err)}); return .fail; },
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
