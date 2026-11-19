// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Static UI files, ETag and gzip cached
// Flo: safe name > cached asset (embedded or disk mtime reload) > 304 or body (gzip if accepted)
// I/O: GET path, Accept-Encoding, If-None-Match (http Request) > file body gzip or raw, or 304 (HTTP response); no-cache + ETag revalidates for 0 bytes, gzip once per file version
// ===================================================================
const std = @import("std"); const http = @import("http"); const assets = @import("assets");
const CF = .{ .gzip_minz = 1024, .file_maxz = 16 * 1024 * 1024 };
const Asse = struct { rawz: []u8, gzzz: ?[]u8, mime: []const u8, etag_bufz: [24]u8 = undefined, etag_leng: usize = 0, gzzz_etag_bufz: [28]u8 = undefined, gzzz_etag_leng: usize = 0, mtim: i128, refs: std.atomic.Value(u32) = .init(1),
fn etag(self: *const Asse) []const u8 { return self.etag_bufz[0..self.etag_leng]; }
fn etagGzzz(self: *const Asse) []const u8 { return self.gzzz_etag_bufz[0..self.gzzz_etag_leng]; }
fn rele(self: *Asse, gpaz: std.mem.Allocator) void { if (self.refs.fetchSub(1, .acq_rel) != 1) return; gpaz.free(self.rawz); if (self.gzzz) |gzzz| gpaz.free(gzzz); gpaz.destroy(self); } };
pub const Cach = struct { gpaz: std.mem.Allocator, root: []const u8, mute: std.Io.Mutex = .init, mapz: std.StringHashMapUnmanaged(*Asse) = .empty };
pub fn embe() bool { return assets.files.len > 0; }
pub fn serv(cach: *Cach, allo: std.mem.Allocator, iozz: std.Io, swzz: *std.Io.net.Stream.Writer, reqz: http.Requ) !void {
const relz = http.statRelz(reqz.path) orelse return http.respSend(swzz, 403, "Forbidden", "{\"error\":\"forbidden\"}");
const asse = asseGetz(cach, allo, iozz, relz, reqz.path) orelse return http.respSend(swzz, 404, "Not Found", "{\"error\":\"not_found\"}");
defer asse.rele(cach.gpaz);
if (reqz.acce_gzip and asse.gzzz != null) { return http.respStatSend(swzz, reqz.ifzz_none_matc, .{ .body = asse.gzzz.?, .mime = asse.mime, .etag = asse.etagGzzz(), .enco = "gzip" }); }
return http.respStatSend(swzz, reqz.ifzz_none_matc, .{ .body = asse.rawz, .mime = asse.mime, .etag = asse.etag() }); }
fn asseGetz(cach: *Cach, allo: std.mem.Allocator, iozz: std.Io, relz: []const u8, reqz_path: []const u8) ?*Asse {
var mtim: i128 = 0; var full: []const u8 = "";
if (!embe()) { full = http.statPathSafe(allo, cach.root, reqz_path) orelse return null; const stat = std.Io.Dir.cwd().statFile(iozz, full, .{}) catch return null; if (stat.kind == .directory) return null; mtim = stat.mtime.toNanoseconds(); }
{ cach.mute.lock(iozz) catch return null; defer cach.mute.unlock(iozz); if (cach.mapz.get(relz)) |asse| { if (asse.mtim == mtim) { _ = asse.refs.fetchAdd(1, .acq_rel); return asse; } } }
const rawz: []u8 = if (embe()) blk: { for (assets.files) |file| { if (std.mem.eql(u8, file.name, relz)) break :blk cach.gpaz.dupe(u8, file.data) catch return null; } return null; } else std.Io.Dir.cwd().readFileAlloc(iozz, full, cach.gpaz, .limited(CF.file_maxz)) catch return null;
const asse = cach.gpaz.create(Asse) catch { cach.gpaz.free(rawz); return null; };
asse.* = .{ .rawz = rawz, .gzzz = null, .mime = http.mimeFind(relz), .mtim = mtim };
asse.etag_leng = http.etagHash(&asse.etag_bufz, rawz).len;
if (rawz.len >= CF.gzip_minz and mimeText(asse.mime)) { asse.gzzz = gzip(cach.gpaz, rawz) catch null; const etag = asse.etag(); const etgz = std.fmt.bufPrint(&asse.gzzz_etag_bufz, "{s}-gz\"", .{etag[0 .. etag.len - 1]}) catch asse.gzzz_etag_bufz[0..0]; asse.gzzz_etag_leng = etgz.len; if (etgz.len == 0) { cach.gpaz.free(asse.gzzz.?); asse.gzzz = null; } }
cach.mute.lock(iozz) catch { asse.rele(cach.gpaz); return null; };
defer cach.mute.unlock(iozz);
_ = asse.refs.fetchAdd(1, .acq_rel);
if (cach.mapz.getPtr(relz)) |slot| { const oldz = slot.*; slot.* = asse; oldz.rele(cach.gpaz); } else { const keyz = cach.gpaz.dupe(u8, relz) catch { _ = asse.refs.fetchSub(1, .acq_rel); return asse; }; cach.mapz.put(cach.gpaz, keyz, asse) catch { cach.gpaz.free(keyz); _ = asse.refs.fetchSub(1, .acq_rel); }; }
return asse; }
fn mimeText(mime: []const u8) bool { return std.mem.startsWith(u8, mime, "text/") or std.mem.startsWith(u8, mime, "application/javascript") or std.mem.startsWith(u8, mime, "application/json") or std.mem.startsWith(u8, mime, "image/svg"); }
pub fn gzip(gpaz: std.mem.Allocator, data: []const u8) ![]u8 { var outz = try std.Io.Writer.Allocating.initCapacity(gpaz, data.len / 3 + 64); errdefer outz.deinit(); const wind = try gpaz.alloc(u8, std.compress.flate.max_window_len); defer gpaz.free(wind); var comp = try std.compress.flate.Compress.init(&outz.writer, wind, .gzip, .default); try comp.writer.writeAll(data); try comp.finish(); return outz.toOwnedSlice(); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
