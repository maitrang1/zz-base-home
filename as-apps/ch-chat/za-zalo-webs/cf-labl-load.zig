// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Load Zalo label registry: key to role and names
// Flo: embedded default or file override > parse json > key lookup, job key lists, name lists
// I/O: json text or path (caller) > Reg (arena owned)
// ===================================================================
const std = @import("std");
const CF = .{ .built = @embedFile("so-labl-zalo.json"), .maxz = 1 << 20 };
pub const Ent = struct { role: []const u8 = "", vi: []const []const u8 = &.{}, en: []const []const u8 = &.{} };
pub const Ext = struct { msg_sel: []const u8 = "", id_atr: []const u8 = "", dir_atr: []const u8 = "", kind_atr: []const u8 = "", time_atr: []const u8 = "", quot_atr: []const u8 = "", scrl_sel: []const u8 = "", list_sel: []const u8 = "", chat_sel: []const u8 = "", chat_nam_atr: []const u8 = "", chat_unr_atr: []const u8 = "", chat_fri_atr: []const u8 = "", chat_grp_atr: []const u8 = "", comp_sel: []const u8 = "", fail_atr: []const u8 = "", dom_read: bool = false };
pub const Jobk = struct { rest: []const []const u8 = &.{}, chat: []const []const u8 = &.{} };
pub const Reg = struct { keys: std.json.ArrayHashMap(Ent) = .{}, jobs: std.json.ArrayHashMap(Jobk) = .{}, ext: Ext = .{}, real: Ext = .{},
pub fn get(self: *const Reg, key: []const u8) ?Ent { return self.keys.map.get(key); }
pub fn names(self: *const Reg, aren: std.mem.Allocator, key: []const u8) ![]const []const u8 { const ent = self.get(key) orelse return error.NoElem; var out: std.ArrayList([]const u8) = .empty; for (ent.vi) |nam| try out.append(aren, nam); for (ent.en) |nam| try out.append(aren, nam); return out.items; }
pub fn jobKeys(self: *const Reg, job: []const u8) ?Jobk { return self.jobs.map.get(job); } };
pub fn parse(aren: std.mem.Allocator, text: []const u8) !Reg { return std.json.parseFromSliceLeaky(Reg, aren, text, .{ .ignore_unknown_fields = true, .allocate = .alloc_always }) catch return error.BadConfig; }
pub fn builtin(aren: std.mem.Allocator) !Reg { return parse(aren, CF.built); }
pub fn load(aren: std.mem.Allocator, iozz: std.Io, path: []const u8) !Reg { if (path.len == 0) return builtin(aren); const text = std.Io.Dir.cwd().readFileAlloc(iozz, path, aren, .limited(CF.maxz)) catch return error.BadConfig; return parse(aren, text); }
pub fn missing(self: *const Reg) ?[]const u8 { var it = self.jobs.map.iterator(); while (it.next()) |ent| { for (ent.value_ptr.rest) |key| { if (self.get(key) == null) return key; } for (ent.value_ptr.chat) |key| { if (self.get(key) == null) return key; } } return null; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
