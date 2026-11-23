// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Patch the refs inside one text file, safely
// Flo: read > re-scan now > snapshot + journal first > write in place > read back and compare hash
// I/O: file path + Targ + run paths > file rewritten, snapshot + journal line; count of refs patched
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const osys = @import("ut-osys-adap.zig");
const walk = @import("se-scan-walk.zig");
const stex = @import("se-scan-text.zig");
const plan = @import("pl-plan-buil.zig");
const stor = @import("st-runz-stor.zig");
const take = @import("bk-snap-take.zig");
const jour = @import("lg-jour-writ.zig");
const tick = @import("ut-faul-tick.zig");
const CF = .{ .mbyt = 1024 * 1024, .waitms = 200 };
pub const Erro = error{ Blocked, VerifyFail };
fn writeOnce(ctxz: *const cx.Ctxz, nat: []const u8, body: []const u8) !void {
var file = try std.Io.Dir.cwd().createFile(ctxz.iozz, nat, .{ .truncate = true });
defer file.close(ctxz.iozz);
try file.writePositionalAll(ctxz.iozz, body, 0);
}
pub fn writeRetry(ctxz: *const cx.Ctxz, nat: []const u8, body: []const u8) !void {
var tryz: u32 = 0;
while (true) : (tryz += 1) {
writeOnce(ctxz, nat, body) catch |err| {
if (tryz >= ctxz.conf.lock_retr) { std.debug.print("rn: cannot write {s}: {s}\n", .{ nat, @errorName(err) }); return Erro.Blocked; }
std.Io.sleep(ctxz.iozz, .fromMilliseconds(CF.waitms), .awake) catch {};
continue;
};
return;
}
}
pub fn patchFile(ctxz: *const cx.Ctxz, targ: walk.Targ, path: []const u8, pth: stor.Pths, seqn: usize, tck: *tick.Tick) !usize {
var scra = std.heap.ArenaAllocator.init(ctxz.gpaz);
defer scra.deinit();
const sara = scra.allocator();
const nat = try ctxz.nati(path);
const maxz = ctxz.conf.scan_maxz * CF.mbyt;
const text = std.Io.Dir.cwd().readFileAlloc(ctxz.iozz, nat, sara, .limited(maxz)) catch return Erro.Blocked;
const pair = try walk.variDir(sara, targ, osys.dirOf(path));
const hits = try stex.scanText(sara, ctxz.osy, text, pair.olds, pair.news);
var outz: std.ArrayList(u8) = .empty;
var curz: usize = 0;
var cntz: usize = 0;
for (hits) |hit| {
if (plan.skipOf(ctxz.conf, plan.clasOf(hit.kind))) continue;
try outz.appendSlice(sara, text[curz..hit.offz]);
try outz.appendSlice(sara, hit.newz);
curz = hit.offz + hit.lenz;
cntz += 1;
}
if (cntz == 0) return 0;
try outz.appendSlice(sara, text[curz..]);
const hold = take.hashHex(text);
const hnew = take.hashHex(outz.items);
const name = try std.fmt.allocPrint(sara, "{d}.bak", .{seqn});
try take.putz(sara, ctxz.iozz, pth.snap, name, text);
try jour.appd(sara, ctxz.iozz, pth.jour, pth.jfil, .{ .op = "patch", .a = path, .b = name, .h0 = &hold, .h1 = &hnew });
try tck.step();
try writeRetry(ctxz, nat, outz.items);
const back = std.Io.Dir.cwd().readFileAlloc(ctxz.iozz, nat, sara, .limited(outz.items.len + 1)) catch return Erro.VerifyFail;
const hbak = take.hashHex(back);
if (!std.mem.eql(u8, &hbak, &hnew)) return Erro.VerifyFail;
return cntz;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
