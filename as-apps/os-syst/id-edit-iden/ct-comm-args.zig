// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Parse the command tail of plan and run: pairs, map files, scope, docs
// Flo: walk args > old=new pairs, --map FILE (repeatable), --scope S, --no-docs > check the map > Req
// I/O: arg slice + Ctxz > Req {pairs, opts}; usage errors as exit.Erro.Usag, bad map = Issue printed
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const exit = @import("ct-exit-code.zig");
const tk = @import("ut-iden-toke.zig");
const mp = @import("pl-plan-maps.zig");
const pl = @import("pl-plan-buil.zig");
pub const Req = struct { pairs: []const tk.Pair, opts: pl.Opts };
pub fn parse(ctxz: *const cx.Ctxz, args: []const []const u8) !Req {
const allo = ctxz.allo;
var list: std.ArrayList(tk.Pair) = .empty;
var plain: std.ArrayList([]const u8) = .empty;
var opts: pl.Opts = .{ .docs = ctxz.conf.scan_docs_on };
var indx: usize = 0;
while (indx < args.len) : (indx += 1) {
const arg = args[indx];
if (std.mem.eql(u8, arg, "--no-docs")) { opts.docs = false; continue; }
if (std.mem.eql(u8, arg, "--map") or std.mem.eql(u8, arg, "--scope")) {
if (indx + 1 >= args.len) { std.debug.print("id-edit-iden: {s} needs a value\n", .{arg}); return exit.Erro.Usag; }
indx += 1;
if (std.mem.eql(u8, arg, "--scope")) { opts.scope = std.meta.stringToEnum(pl.Scope, args[indx]) orelse { std.debug.print("id-edit-iden: --scope is all, repo or state\n", .{}); return exit.Erro.Usag; }; continue; }
const text = std.Io.Dir.cwd().readFileAlloc(ctxz.iozz, args[indx], allo, .limited(1 << 20)) catch |err| { std.debug.print("id-edit-iden: cannot read map file {s}: {s}\n", .{ args[indx], @errorName(err) }); return exit.Erro.Usag; };
mp.fromText(allo, text, &list) catch { std.debug.print("id-edit-iden: bad line in {s}: use old=new, one per line\n", .{args[indx]}); return exit.Erro.Usag; };
continue;
}
if (std.mem.startsWith(u8, arg, "--")) { std.debug.print("id-edit-iden: unknown flag {s}\n", .{arg}); return exit.Erro.Usag; }
try plain.append(allo, arg);
}
mp.fromArgs(allo, plain.items, &list) catch { std.debug.print("id-edit-iden: a pair looks like old=new\n", .{}); return exit.Erro.Usag; };
if (mp.check(list.items)) |iss| { std.debug.print("id-edit-iden: bad map: {s}: {s}\nfix: edit the pair, then run again\n", .{ iss.iden, iss.why }); return exit.Erro.Usag; }
return .{ .pairs = list.items, .opts = opts };
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
