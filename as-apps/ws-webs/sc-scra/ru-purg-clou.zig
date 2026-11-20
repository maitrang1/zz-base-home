// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Cloud purge: at 90% of the cap delete oldest packs down to 80%
// Flo: list packs > under 90%? stop > mode upgr? report only > oldest first: requeue latest-version pages, write manifest to the cloud DB, then delete the pack and its manifest rows
// I/O: Sync (store + sql + local Db) + cap bytes (caller) > Pres; parsed records are never touched
// ===================================================================
const std = @import("std"); const sync = @import("sy-clou-sync.zig"); const stor = @import("sy-clou-stor.zig"); const sqlz = @import("sy-clou-sqlz.zig"); const outb = @import("sy-clou-outb.zig");
const CF = .{ .hipc = 90, .lopc = 80, .pref = "runs/" };
pub const Act = enum { none, purged, upgr };
pub const Pres = struct { act: Act = .none, usage: u64 = 0, cap: u64 = 0, freed: u64 = 0, packs: u32 = 0, kept: u32 = 0 };
fn lessKey(_: void, left: stor.Obj, rite: stor.Obj) bool { return std.mem.lessThan(u8, left.key, rite.key); }
fn packEnts(self: *sync.Sync, aren: std.mem.Allocator, packk: []const u8) ![]const []const u8 { var stmt = try self.dbzz.prep("SELECT hexz FROM pack WHERE packk=?1;"); defer stmt.fini(); try stmt.bindText(1, packk); var list: std.ArrayList([]const u8) = .empty; while (try stmt.step()) try list.append(aren, try aren.dupe(u8, stmt.colText(0))); return list.toOwnedSlice(aren); }
fn isLive(self: *sync.Sync, hexz: []const u8) !bool { var stmt = try self.dbzz.prep("SELECT 1 FROM page WHERE hexz=?1 LIMIT 1;"); defer stmt.fini(); try stmt.bindText(1, hexz); return try stmt.step(); }
pub fn purgRun(self: *sync.Sync, aren: std.mem.Allocator, now: i64, capb: u64) !Pres { var res: Pres = .{ .cap = capb }; const objs = try self.store.list(self.store.ctx, aren, self.iozz, CF.pref); var usage: u64 = 0; for (objs) |obj| usage += obj.size; res.usage = usage; if (capb == 0 or usage * 100 < capb * CF.hipc) return res; if (std.mem.eql(u8, self.conf.clou_poli_mode, "upgr")) { res.act = .upgr; return res; } std.mem.sort(stor.Obj, objs, {}, lessKey); const target = capb * CF.lopc / 100;
for (objs) |obj| { if (usage <= target) break; const ents = try packEnts(self, aren, obj.key); var kept: u32 = 0; for (ents) |hexz| { if (try isLive(self, hexz)) { try outb.outbAdd(self.dbzz, "file", hexz, now, true); kept += 1; } }
const manif = [_]sqlz.Col{ .{ .name = "packz", .valu = try sqlz.lit(aren, self.sql.dial, obj.key) }, .{ .name = "timz", .valu = try std.fmt.allocPrint(aren, "{d}", .{now}) }, .{ .name = "ents", .valu = try std.fmt.allocPrint(aren, "{d}", .{ents.len}) } }; const stm = [_][]const u8{try sqlz.upsert(aren, self.sql.dial, "cl_purg", "packz", &manif)}; try self.sql.exec(self.sql.ctx, aren, self.iozz, &stm);
var ins = try self.dbzz.prep("INSERT INTO purg(packz,timz,ents) VALUES(?1,?2,?3) ON CONFLICT(packz) DO UPDATE SET timz=?2,ents=?3;"); defer ins.fini(); try ins.bindText(1, obj.key); try ins.bindInt(2, now); try ins.bindInt(3, @intCast(ents.len)); _ = try ins.step();
try self.store.del(self.store.ctx, aren, self.iozz, obj.key); const clr = [_][]const u8{try std.fmt.allocPrint(aren, "DELETE FROM cl_manif WHERE pack={s}", .{try sqlz.lit(aren, self.sql.dial, obj.key)})}; self.sql.exec(self.sql.ctx, aren, self.iozz, &clr) catch {}; var del = try self.dbzz.prep("DELETE FROM pack WHERE packk=?1;"); defer del.fini(); try del.bindText(1, obj.key); _ = try del.step();
usage -= obj.size; res.freed += obj.size; res.packs += 1; res.kept += kept; } res.act = .purged; res.usage = usage; return res; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
