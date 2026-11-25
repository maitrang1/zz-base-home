// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Find page nodes by registry key, Vietnamese or English
// Flo: key > role + names > pass 1 exact name > pass 2 substring > node; helpers for marks and prefixes
// I/O: Reg + AX nodes (caller) > Node or null; text helpers
// ===================================================================
const std = @import("std"); const snap = @import("ru-page-snap.zig"); const lab = @import("cf-labl-load.zig");
fn roleOk(nod: snap.Node, role: []const u8) bool { return role.len == 0 or std.ascii.eqlIgnoreCase(nod.role, role); }
fn nameHas(hay: []const u8, nee: []const u8) bool { return nee.len > 0 and std.ascii.findIgnoreCase(hay, nee) != null; }
fn anyExact(ent: lab.Ent, name: []const u8) bool { for (ent.vi) |nam| { if (std.ascii.eqlIgnoreCase(nam, name)) return true; } for (ent.en) |nam| { if (std.ascii.eqlIgnoreCase(nam, name)) return true; } return false; }
fn anySub(ent: lab.Ent, name: []const u8) bool { for (ent.vi) |nam| { if (nameHas(name, nam)) return true; } for (ent.en) |nam| { if (nameHas(name, nam)) return true; } return false; }
pub fn findEnt(nodes: []const snap.Node, ent: lab.Ent) ?snap.Node { const noname = ent.vi.len == 0 and ent.en.len == 0; for (nodes) |nod| { if (!roleOk(nod, ent.role)) continue; if (noname) return nod; if (anyExact(ent, nod.name)) return nod; } if (noname) return null; for (nodes) |nod| { if (!roleOk(nod, ent.role)) continue; if (anySub(ent, nod.name)) return nod; } return null; }
pub fn findKey(reg: *const lab.Reg, nodes: []const snap.Node, key: []const u8) ?snap.Node { const ent = reg.get(key) orelse return null; return findEnt(nodes, ent); }
pub fn findWith(reg: *const lab.Reg, nodes: []const snap.Node, key: []const u8, extra: []const u8) ?snap.Node { const ent = reg.get(key) orelse return null; for (nodes) |nod| { if (!roleOk(nod, ent.role)) continue; if (anySub(ent, nod.name) and nameHas(nod.name, extra)) return nod; } return null; }
pub fn allKey(aren: std.mem.Allocator, reg: *const lab.Reg, nodes: []const snap.Node, key: []const u8) ![]snap.Node { const ent = reg.get(key) orelse return &.{}; const noname = ent.vi.len == 0 and ent.en.len == 0; var out: std.ArrayList(snap.Node) = .empty; for (nodes) |nod| { if (!roleOk(nod, ent.role)) continue; if (noname or anySub(ent, nod.name)) try out.append(aren, nod); } return out.items; }
pub fn missingKeys(aren: std.mem.Allocator, reg: *const lab.Reg, nodes: []const snap.Node, keys: []const []const u8) ![]const []const u8 { var out: std.ArrayList([]const u8) = .empty; for (keys) |key| { if (!present(reg, nodes, key)) try out.append(aren, key); } return out.items; }
pub fn present(reg: *const lab.Reg, nodes: []const snap.Node, key: []const u8) bool { return findKey(reg, nodes, key) != null; }
pub fn markPos(reg: *const lab.Reg, text: []const u8, key: []const u8) ?usize { const ent = reg.get(key) orelse return null; var best: ?usize = null; for (ent.vi) |nam| { if (nam.len > 0) { if (std.ascii.findIgnoreCase(text, nam)) |idx| { if (best == null or idx < best.?) best = idx; } } } for (ent.en) |nam| { if (nam.len > 0) { if (std.ascii.findIgnoreCase(text, nam)) |idx| { if (best == null or idx < best.?) best = idx; } } } return best; }
pub fn selfPrefix(reg: *const lab.Reg, body: []const u8) ?usize { const ent = reg.get("self_pref") orelse return null; for (ent.vi) |nam| { if (nam.len > 0 and std.mem.startsWith(u8, body, nam)) return nam.len; } for (ent.en) |nam| { if (nam.len > 0 and std.mem.startsWith(u8, body, nam)) return nam.len; } return null; }
pub fn roleOf(reg: *const lab.Reg, key: []const u8) []const u8 { const ent = reg.get(key) orelse return ""; return ent.role; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
