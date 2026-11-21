// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Cloud purge: at 90% of the cap delete oldest packs down to 80%
// Flo: list packs > under 90%? stop > mode upgr? report only > oldest first: requeue latest-version pages, write manifest to the cloud DB, then delete the pack and its manifest rows
// I/O: Sync (store + sql + local Db) + cap bytes (caller) > Pres; parsed records are never touched
// ===================================================================
const std = @import("std"); const sync = @import("sy-clou-sync.zig"); const stor = @import("sy-clou-stor.zig"); const sqlz = @import("sy-clou-sqlz.zig"); const outb = @import("sy-clou-outb.zig");
const CF = .{ .hipc = 90, .lopc = 80, .pref = "runs/" };
pub const Actz = enum { none, purged, upgr };
pub const Pres = struct { act2: Actz = .none, usa2: u64 = 0, cap2: u64 = 0, fre3: u64 = 0, pac4: u32 = 0, kept: u32 = 0 };
fn lessKeyz(_: void, left: stor.Objz, rite: stor.Objz) bool { return std.mem.lessThan(u8, left.key2, rite.key2); }
fn packEnts(self: *sync.Sync, aren: std.mem.Allocator, pac3: []const u8) ![]const []const u8 { var stmt = try self.dbzz.prep("SELECT hexz FROM pack WHERE packk=?1;"); defer stmt.fini(); try stmt.bindText(1, pac3); var list: std.ArrayList([]const u8) = .empty; while (try stmt.step()) try list.append(aren, try aren.dupe(u8, stmt.colzText(0))); return list.toOwnedSlice(aren); }
fn iszzLive(self: *sync.Sync, hexz: []const u8) !bool { var stmt = try self.dbzz.prep("SELECT 1 FROM page WHERE hexz=?1 LIMIT 1;"); defer stmt.fini(); try stmt.bindText(1, hexz); return try stmt.step(); }
pub fn purgRunz(self: *sync.Sync, aren: std.mem.Allocator, nowz: i64, capb: u64) !Pres { var rslt: Pres = .{ .cap2 = capb }; const objs = try self.store.list(self.store.ctx2, aren, self.iozz, CF.pref); var usa2: u64 = 0; for (objs) |obj2| usa2 += obj2.size; rslt.usa2 = usa2; if (capb == 0 or usa2 * 100 < capb * CF.hipc) return rslt; if (std.mem.eql(u8, self.conf.clou_poli_mode, "upgr")) { rslt.act2 = .upgr; return rslt; } std.mem.sort(stor.Objz, objs, {}, lessKeyz); const tar2 = capb * CF.lopc / 100;
for (objs) |obj2| { if (usa2 <= tar2) break; const ents = try packEnts(self, aren, obj2.key2); var kept: u32 = 0; for (ents) |hexz| { if (try iszzLive(self, hexz)) { try outb.outbAddz(self.dbzz, "file", hexz, nowz, true); kept += 1; } }
const mani = [_]sqlz.Colz{ .{ .name = "packz", .valu = try sqlz.litz(aren, self.sql2.dial, obj2.key2) }, .{ .name = "timz", .valu = try std.fmt.allocPrint(aren, "{d}", .{nowz}) }, .{ .name = "ents", .valu = try std.fmt.allocPrint(aren, "{d}", .{ents.len}) } }; const stmz = [_][]const u8{try sqlz.upse(aren, self.sql2.dial, "cl_purg", "packz", &mani)}; try self.sql2.exec(self.sql2.ctx2, aren, self.iozz, &stmz);
var insz = try self.dbzz.prep("INSERT INTO purg(packz,timz,ents) VALUES(?1,?2,?3) ON CONFLICT(packz) DO UPDATE SET timz=?2,ents=?3;"); defer insz.fini(); try insz.bindText(1, obj2.key2); try insz.bindIntz(2, nowz); try insz.bindIntz(3, @intCast(ents.len)); _ = try insz.step();
try self.store.del2(self.store.ctx2, aren, self.iozz, obj2.key2); const clrz = [_][]const u8{try std.fmt.allocPrint(aren, "DELETE FROM cl_manif WHERE pack={s}", .{try sqlz.litz(aren, self.sql2.dial, obj2.key2)})}; self.sql2.exec(self.sql2.ctx2, aren, self.iozz, &clrz) catch {}; var del2 = try self.dbzz.prep("DELETE FROM pack WHERE packk=?1;"); defer del2.fini(); try del2.bindText(1, obj2.key2); _ = try del2.step();
usa2 -= obj2.size; rslt.fre3 += obj2.size; rslt.pac4 += 1; rslt.kept += kept; } rslt.act2 = .purged; rslt.usa2 = usa2; return rslt; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
