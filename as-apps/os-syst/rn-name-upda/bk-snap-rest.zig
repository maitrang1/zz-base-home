// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Read a snapshot copy back, checked against its hash
// Flo: read the .bak > hash it > compare with the journal hash
// I/O: dir + name + expected hash > the original bytes, or an error
// ===================================================================
const std = @import("std");
const take = @import("bk-snap-take.zig");
pub const Erro = error{HashMismatch};
pub fn getz(allo: std.mem.Allocator, iozz: std.Io, dirz: []const u8, name: []const u8, hash: []const u8, maxz: usize) ![]u8 {
const path = try take.joinz(allo, dirz, name);
defer allo.free(path);
const data = try std.Io.Dir.cwd().readFileAlloc(iozz, path, allo, .limited(maxz));
errdefer allo.free(data);
const have = take.hashHex(data);
if (!std.mem.eql(u8, &have, hash)) return Erro.HashMismatch;
return data;
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
