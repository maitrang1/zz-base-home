// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Id rules and whole-token find/replace on text
// Flo: split text into runs of id chars > a run equal to an old id is a hit > replace all hits in one pass
// I/O: text + Pair list > Hit list (offset, line, pair) or the patched text
// ===================================================================
const std = @import("std");
pub const CF = .{ .maxz = 120 };
pub const Pair = struct { old: []const u8, new: []const u8 };
pub const Hit = struct { offz: usize, lenz: usize, line: usize, pidx: usize };
pub fn isTok(byte: u8) bool { return std.ascii.isAlphanumeric(byte) or byte == '-' or byte == '_'; }
pub fn idenBadz(iden: []const u8) ?[]const u8 {
if (iden.len == 0) return "empty id";
if (iden.len > CF.maxz) return "id longer than 120";
for (iden) |byt| if (!isTok(byt)) return "id may hold only letters, digits, - and _";
return null;
}
fn pairOf(pairs: []const Pair, tokn: []const u8) ?usize { for (pairs, 0..) |pair, indx| if (std.mem.eql(u8, pair.old, tokn)) return indx; return null; }
pub fn scan(allo: std.mem.Allocator, text: []const u8, pairs: []const Pair) ![]Hit {
var list: std.ArrayList(Hit) = .empty;
errdefer list.deinit(allo);
var indx: usize = 0;
var line: usize = 1;
while (indx < text.len) {
const byt = text[indx];
if (byt == '\n') { line += 1; indx += 1; continue; }
if (!isTok(byt)) { indx += 1; continue; }
var endz = indx + 1;
while (endz < text.len and isTok(text[endz])) endz += 1;
if (pairOf(pairs, text[indx..endz])) |pidx| try list.append(allo, .{ .offz = indx, .lenz = endz - indx, .line = line, .pidx = pidx });
indx = endz;
}
return list.toOwnedSlice(allo);
}
pub fn apply(allo: std.mem.Allocator, text: []const u8, hits: []const Hit, pairs: []const Pair) ![]u8 {
var outz: std.ArrayList(u8) = .empty;
errdefer outz.deinit(allo);
var curz: usize = 0;
for (hits) |hit| {
try outz.appendSlice(allo, text[curz..hit.offz]);
try outz.appendSlice(allo, pairs[hit.pidx].new);
curz = hit.offz + hit.lenz;
}
try outz.appendSlice(allo, text[curz..]);
return outz.toOwnedSlice(allo);
}
pub fn hasTok(text: []const u8, tokn: []const u8) bool {
var indx: usize = 0;
while (indx < text.len) {
if (!isTok(text[indx])) { indx += 1; continue; }
var endz = indx + 1;
while (endz < text.len and isTok(text[endz])) endz += 1;
if (std.mem.eql(u8, text[indx..endz], tokn)) return true;
indx = endz;
}
return false;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
