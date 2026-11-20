// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Store raw pages as hashed gzip files, once per content
// Flo: hash body > skip if file exists > gzip > write p.part > rename over final > load: read gz > inflate with size cap
// I/O: body bytes + root dir (caller) > hash hex, fresh flag, or bytes back (caller frees)
// ===================================================================
const std = @import("std"); const hash = @import("ut-hash-dedu.zig"); const flate = std.compress.flate;
const CF = .{ .part = ".part", .slak = 1024 };
pub const Saved = struct { hexz: hash.Hexz, fresh: bool, gzip: usize };
pub fn gzipPack(allo: std.mem.Allocator, body: []const u8) ![]u8 { var outw = try std.Io.Writer.Allocating.initCapacity(allo, body.len / 2 + CF.slak); defer outw.deinit(); const win = try allo.alloc(u8, flate.max_window_len); defer allo.free(win); var comp = try flate.Compress.init(&outw.writer, win, .gzip, .default); try comp.writer.writeAll(body); try comp.finish(); return outw.toOwnedSlice(); }
pub fn gzipOpen(allo: std.mem.Allocator, gzip: []const u8, maxz: usize) ![]u8 { var inpt = std.Io.Reader.fixed(gzip); const win = try allo.alloc(u8, flate.max_window_len); defer allo.free(win); var deco = flate.Decompress.init(&inpt, .gzip, win); return deco.reader.allocRemaining(allo, .limited(maxz)) catch |err| switch (err) { error.StreamTooLong => return error.TooBig, else => return error.GzipBad }; }
fn pathMake(allo: std.mem.Allocator, root: []const u8, hexz: hash.Hexz) ![]u8 { var buff: [96]u8 = undefined; const rela = try hash.hashPath(&buff, hexz); return std.fs.path.join(allo, &.{ root, rela }); }
pub fn fileSave(allo: std.mem.Allocator, iozz: std.Io, root: []const u8, body: []const u8) !Saved { const hexz = hash.hashHex(body); const path = try pathMake(allo, root, hexz); defer allo.free(path); const cwdz = std.Io.Dir.cwd(); if (cwdz.statFile(iozz, path, .{})) |stat| { return .{ .hexz = hexz, .fresh = false, .gzip = @intCast(stat.size) }; } else |err| { if (err != error.FileNotFound) return err; } const pack = try gzipPack(allo, body); defer allo.free(pack); if (std.fs.path.dirname(path)) |dirz| try cwdz.createDirPath(iozz, dirz); const temp = try std.fmt.allocPrint(allo, "{s}{s}", .{ path, CF.part }); defer allo.free(temp); try cwdz.writeFile(iozz, .{ .sub_path = temp, .data = pack }); try cwdz.rename(temp, cwdz, path, iozz); return .{ .hexz = hexz, .fresh = true, .gzip = pack.len }; }
pub fn fileLoad(allo: std.mem.Allocator, iozz: std.Io, root: []const u8, hexz: hash.Hexz, maxz: usize) ![]u8 { const path = try pathMake(allo, root, hexz); defer allo.free(path); const pack = try std.Io.Dir.cwd().readFileAlloc(iozz, path, allo, .limited(maxz)); defer allo.free(pack); const body = try gzipOpen(allo, pack, maxz); errdefer allo.free(body); const back = hash.hashHex(body); if (!std.mem.eql(u8, &back, &hexz)) return error.HashMismatch; return body; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
