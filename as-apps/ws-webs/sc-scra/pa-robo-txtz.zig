// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: robots.txt parser and matcher (RFC 9309)
// Flo: split lines > group by user-agent > pick most specific group for our token > collect rules > match path: longest wins, allow on tie
// I/O: robots text + agent token + HTTP status (fetcher) > Robo; path+query > Deci (allow flag + matched rule)
// ===================================================================
const std = @import("std"); const mem = std.mem;
const CF = .{ .maxl = 512 * 1024, .grpz = 256, .bomz = "\xEF\xBB\xBF" };
pub const Rule = struct { okay: bool, pata: []const u8 };
pub const Robo = struct { rules: []const Rule = &.{}, delz: u32 = 0, maps: []const []const u8 = &.{}, mode: Mode = .pars };
pub const Mode = enum { pars, allo, deny };
pub const Deci = struct { okay: bool, rule: []const u8 };
pub fn roboStat(code: u16) Mode { if (code >= 200 and code < 300) return .pars; if (code >= 400 and code < 500) return .allo; return .deny; }
fn pmat(pata: []const u8, path: []const u8) bool { var pat = pata; var anch = false; if (pat.len > 0 and pat[pat.len - 1] == '$') { anch = true; pat = pat[0 .. pat.len - 1]; } var pind: usize = 0; var jind: usize = 0; var star: ?usize = null; var mark: usize = 0; while (true) { if (pind == pat.len) { if (!anch or jind == path.len) return true; if (star) |sp| { mark += 1; if (mark > path.len) return false; jind = mark; pind = sp + 1; continue; } return false; } if (pat[pind] == '*') { star = pind; pind += 1; mark = jind; continue; } if (jind < path.len and pat[pind] == path[jind]) { pind += 1; jind += 1; continue; } if (star) |sp| { mark += 1; if (mark > path.len) return false; jind = mark; pind = sp + 1; continue; } return false; } }
fn fieldIs(line: []const u8, name: []const u8) ?[]const u8 { const colo = mem.findScalar(u8, line, ':') orelse return null; if (!std.ascii.eqlIgnoreCase(mem.trim(u8, line[0..colo], " \t"), name)) return null; return mem.trim(u8, line[colo + 1 ..], " \t"); }
fn lineClean(raws: []const u8) []const u8 { var line = mem.trim(u8, raws, " \t\r"); if (mem.findScalar(u8, line, '#')) |hash| line = mem.trim(u8, line[0..hash], " \t"); return line; }
fn specOf(agnt: []const u8, ua: []const u8) usize { if (ua.len == 1 and ua[0] == '*') return 1; if (ua.len > 0 and std.ascii.findIgnoreCase(agnt, ua) != null) return ua.len + 1; return 0; }
pub fn roboParse(aren: std.mem.Allocator, text: []const u8, agnt: []const u8) !Robo { var body = text; if (body.len > CF.maxl) body = body[0..CF.maxl]; if (mem.startsWith(u8, body, CF.bomz)) body = body[3..]; var gspc: [CF.grpz]usize = undefined; var gcnt: usize = 0; var best: usize = 0; var inua = false; var spec: usize = 0; var scan = mem.splitScalar(u8, body, '\n');
while (scan.next()) |raws| { const line = lineClean(raws); if (fieldIs(line, "user-agent")) |ua| { if (!inua) { spec = 0; inua = true; } spec = @max(spec, specOf(agnt, ua)); continue; } if (line.len == 0 or !inua) continue; if (gcnt < gspc.len) { gspc[gcnt] = spec; gcnt += 1; } best = @max(best, spec); inua = false; }
if (inua and gcnt < gspc.len) { gspc[gcnt] = spec; gcnt += 1; best = @max(best, spec); }
var rules: std.ArrayList(Rule) = .empty; var maps: std.ArrayList([]const u8) = .empty; var delz: u32 = 0; var gidx: usize = 0; var take = false; inua = false; scan = mem.splitScalar(u8, body, '\n');
while (scan.next()) |raws| { const line = lineClean(raws); if (fieldIs(line, "sitemap")) |smp| { if (smp.len > 0) try maps.append(aren, try aren.dupe(u8, smp)); continue; } if (fieldIs(line, "user-agent") != null) { if (!inua) { inua = true; take = best > 0 and gidx < gcnt and gspc[gidx] == best; gidx += 1; } continue; } if (line.len == 0) continue; inua = false; if (!take) continue; if (fieldIs(line, "allow")) |pat| { if (pat.len > 0) try rules.append(aren, .{ .okay = true, .pata = try aren.dupe(u8, pat) }); } else if (fieldIs(line, "disallow")) |pat| { if (pat.len > 0) try rules.append(aren, .{ .okay = false, .pata = try aren.dupe(u8, pat) }); } else if (fieldIs(line, "crawl-delay")) |val| { const secs = std.fmt.parseFloat(f32, val) catch 0; if (secs > 0 and secs < 3600) delz = @intFromFloat(secs * 1000); } }
return .{ .rules = try rules.toOwnedSlice(aren), .delz = delz, .maps = try maps.toOwnedSlice(aren) }; }
pub fn roboAllow(self: Robo, path: []const u8) Deci { if (self.mode == .allo) return .{ .okay = true, .rule = "robots 4xx: allow all" }; if (self.mode == .deny) return .{ .okay = false, .rule = "robots 5xx: deny all" }; if (mem.eql(u8, path, "/robots.txt")) return .{ .okay = true, .rule = "robots.txt itself" }; var win: ?Rule = null; for (self.rules) |rule| { if (!pmat(rule.pata, path)) continue; if (win == null or rule.pata.len > win.?.pata.len or (rule.pata.len == win.?.pata.len and rule.okay)) win = rule; } if (win) |rule| return .{ .okay = rule.okay, .rule = rule.pata }; return .{ .okay = true, .rule = "no rule" }; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
