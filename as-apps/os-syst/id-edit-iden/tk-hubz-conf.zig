// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Read the hub (tr) config: port, data folder, lock lanes
// Flo: read ac-auto-task/aa-conf-main.json > pick port and data dir for this OS > list lanes (name + key prefixes)
// I/O: repo root + home > Hubz {port, data, lanes}; lane of an id = longest key prefix, like the hub
// ===================================================================
const std = @import("std");
const cfgz = @import("cf-conf-load.zig");
const osys = @import("ut-osys-adap.zig");
pub const Lane = struct { name: []const u8, keyz: []const []const u8 };
pub const Hubz = struct {
port: u16,
data: []const u8,
lanes: []const Lane,
pub fn laneOf(self: Hubz, iden: []const u8) []const u8 {
var best: usize = 0;
var name: []const u8 = "";
for (self.lanes) |lane| for (lane.keyz) |keyz| if (keyz.len > best and std.mem.startsWith(u8, iden, keyz)) { best = keyz.len; name = lane.name; };
return name;
}
};
const Raww = struct { port: u16 = 4000, apps_data_loca_wind: []const u8 = "", apps_data_loca_unix: []const u8 = "", lock_list: std.json.ArrayHashMap([]const []const u8) = .{} };
pub fn parse(allo: std.mem.Allocator, text: []const u8, homz: []const u8) !Hubz {
const raww = try std.json.parseFromSliceLeaky(Raww, allo, text, .{ .ignore_unknown_fields = true, .allocate = .alloc_always });
const path = if (osys.wind) raww.apps_data_loca_wind else raww.apps_data_loca_unix;
var lanes: std.ArrayList(Lane) = .empty;
var iter = raww.lock_list.map.iterator();
while (iter.next()) |entr| try lanes.append(allo, .{ .name = entr.key_ptr.*, .keyz = entr.value_ptr.* });
return .{ .port = raww.port, .data = if (path.len == 0) "" else try osys.nati(allo, try osys.home(allo, path, homz)), .lanes = try lanes.toOwnedSlice(allo) };
}
pub fn load(allo: std.mem.Allocator, iozz: std.Io, conf: cfgz.Conf, repo: []const u8, homz: []const u8) !Hubz {
const path = try std.fs.path.join(allo, &.{ repo, conf.hubz_dirz, conf.hubz_conf_name });
const text = try std.Io.Dir.cwd().readFileAlloc(iozz, path, allo, .limited(1 << 20));
return parse(allo, text, homz);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
