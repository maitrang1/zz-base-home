// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Find every reference to the old path inside one text
// Flo: search each old form > keep whole-path matches > drop overlaps (longest wins) > number lines
// I/O: text + old forms + new forms (same order) > sorted Hit list
// ===================================================================
const std = @import("std");
const osys = @import("ut-osys-adap.zig");
const vari = @import("ut-path-vari.zig");
const boun = @import("ut-path-boun.zig");
pub const Hit = struct { offz: usize, lenz: usize, kind: vari.Kind, line: u32, newz: []const u8 };
pub const Erro = error{ShapeMismatch};
fn lessHit(_: void, left: Hit, righ: Hit) bool { return if (left.offz != righ.offz) left.offz < righ.offz else left.lenz > righ.lenz; }
pub fn scanText(allo: std.mem.Allocator, osy: osys.Osys, text: []const u8, olds: []const vari.Vari, news: []const vari.Vari) ![]Hit {
if (olds.len != news.len) return Erro.ShapeMismatch;
var cand: std.ArrayList(Hit) = .empty;
errdefer cand.deinit(allo);
for (olds, news) |oldv, newv| {
if (oldv.text.len == 0) continue;
var from: usize = 0;
while (osys.findz(osy, text, oldv.text, from)) |offz| {
from = offz + 1;
if (!boun.okMatc(oldv.kind, text, offz, oldv.text.len)) continue;
try cand.append(allo, .{ .offz = offz, .lenz = oldv.text.len, .kind = oldv.kind, .line = 0, .newz = newv.text });
}
}
std.mem.sort(Hit, cand.items, {}, lessHit);
var keep: usize = 0;
var endz: usize = 0;
var line: u32 = 1;
var seen: usize = 0;
for (cand.items) |hit| {
if (keep > 0 and hit.offz < endz) continue;
line += @intCast(std.mem.count(u8, text[seen..hit.offz], "\n"));
seen = hit.offz;
cand.items[keep] = hit;
cand.items[keep].line = line;
keep += 1;
endz = hit.offz + hit.lenz;
}
cand.shrinkRetainingCapacity(keep);
return cand.toOwnedSlice(allo);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
