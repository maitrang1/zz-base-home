// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Read and save ZenRows logins in user-acct.json
// Flo: join secret dir + user-acct.json (old zr-login.json is read when the new file is missing) > parse {"v":1,"main":id,"accs":[{id,user,pass,lang,scal}]} or the flat file (= account main) > check ids and limit > pick one account ; save = replace or add one account
// I/O: secret dir path + limit (caller) > Book / Cred (arena owned); values are never printed or logged; errors BadConfig, NoSecret
// ===================================================================
const std = @import("std");
const CF = .{ .file = "user-acct.json", .old = "zr-login.json", .maxz = 65536, .idmx = 16, .main = "main" };
pub const Cred = struct { user: []const u8 = "", pass: []const u8 = "" };
pub const Acc = struct { id: []const u8 = CF.main, user: []const u8 = "", pass: []const u8 = "", lang: []const u8 = "", scal: u32 = 100 };
const Raw = struct { v: u32 = 1, main: []const u8 = "", accs: []const Acc = &.{}, user: []const u8 = "", pass: []const u8 = "", lang: []const u8 = "", scal: u32 = 100 };
const Out = struct { v: u32 = 1, main: []const u8, accs: []const Acc };
pub const Book = struct { main: []const u8, accs: []const Acc, filez: bool };
pub fn idOk(id: []const u8) bool { if (id.len == 0 or id.len > CF.idmx) return false; for (id) |chr| { if (!(std.ascii.isLower(chr) or std.ascii.isDigit(chr) or chr == '-')) return false; } return true; }
pub fn credOf(acc: Acc) Cred { return .{ .user = acc.user, .pass = acc.pass }; }
fn readFile(aren: std.mem.Allocator, iozz: std.Io, dir: []const u8) ?[]u8 { for ([_][]const u8{ CF.file, CF.old }) |nm| { const path = std.fs.path.join(aren, &.{ dir, nm }) catch return null; if (std.Io.Dir.cwd().readFileAlloc(iozz, path, aren, .limited(CF.maxz))) |byte| return byte else |_| {} } return null; }
pub fn loadBook(aren: std.mem.Allocator, iozz: std.Io, dir: []const u8, limit: u32) !Book { const none: Book = .{ .main = CF.main, .accs = &.{.{}}, .filez = false }; if (dir.len == 0) return none; const byte = readFile(aren, iozz, dir) orelse return none; const raw = std.json.parseFromSliceLeaky(Raw, aren, byte, .{ .ignore_unknown_fields = true, .allocate = .alloc_always }) catch return error.BadConfig;
if (raw.accs.len == 0) { const one = try aren.alloc(Acc, 1); one[0] = .{ .id = CF.main, .user = raw.user, .pass = raw.pass, .lang = raw.lang, .scal = raw.scal }; return .{ .main = CF.main, .accs = one, .filez = true }; }
if (raw.accs.len > limit) return error.BadConfig; for (raw.accs, 0..) |acc, ix| { if (!idOk(acc.id) or acc.scal == 0 or acc.scal > 100) return error.BadConfig; for (raw.accs[0..ix]) |prev| { if (std.mem.eql(u8, prev.id, acc.id)) return error.BadConfig; } } const mn = if (raw.main.len > 0) raw.main else raw.accs[0].id; var hit = false; for (raw.accs) |acc| { if (std.mem.eql(u8, acc.id, mn)) hit = true; } if (!hit) return error.BadConfig; return .{ .main = mn, .accs = raw.accs, .filez = true }; }
pub fn pick(book: Book, id: []const u8) ?Acc { const want = if (id.len == 0) book.main else id; for (book.accs) |acc| { if (std.mem.eql(u8, acc.id, want)) return acc; } return null; }
pub fn credFor(book: Book, id: []const u8) !Cred { const acc = pick(book, id) orelse return error.NoSecret; if (acc.user.len == 0 or acc.pass.len == 0) return error.NoSecret; return credOf(acc); }
pub fn saveAcc(iozz: std.Io, aren: std.mem.Allocator, dir: []const u8, limit: u32, id: []const u8, user: []const u8, pass: []const u8) !void { if (!idOk(id)) return error.BadUsage; const book = try loadBook(aren, iozz, dir, limit); var list: std.ArrayList(Acc) = .empty; var found = false; if (book.filez) { for (book.accs) |acc| { if (std.mem.eql(u8, acc.id, id)) { found = true; try list.append(aren, .{ .id = id, .user = user, .pass = pass, .lang = acc.lang, .scal = acc.scal }); } else try list.append(aren, acc); } } if (!found) { if (list.items.len >= limit) return error.BadConfig; try list.append(aren, .{ .id = id, .user = user, .pass = pass }); } const mn = if (book.filez) book.main else id; try std.Io.Dir.cwd().createDirPath(iozz, dir); const path = try std.fs.path.join(aren, &.{ dir, CF.file }); const body = try std.json.Stringify.valueAlloc(aren, Out{ .main = mn, .accs = list.items }, .{}); try std.Io.Dir.cwd().writeFile(iozz, .{ .sub_path = path, .data = body }); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
