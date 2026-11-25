// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Account book: user-acct.json lists owned Zalo accounts, no passwords
// Flo: read user-acct.json {"v":1,"main":id,"accs":[{id,label,phone,lang,scal}]} (missing file = one account "main") > check ids, count, limit > pick one account ; phone is shown masked
// I/O: folder path + limit (caller) > Book (arena owned); error BadConfig (broken file, bad or repeated id, too many, unknown main, caps percent out of range)
// ===================================================================
const std = @import("std");
const CF = .{ .file = "user-acct.json", .maxz = 65536, .idmx = 16, .main = "main" };
pub const Acc = struct { id: []const u8 = CF.main, label: []const u8 = "", phone: []const u8 = "", lang: []const u8 = "", scal: u32 = 100 };
const Raw = struct { v: u32 = 1, main: []const u8 = "", accs: []const Acc = &.{} };
pub const Book = struct { main: []const u8, accs: []const Acc, filez: bool };
pub fn idOk(id: []const u8) bool { if (id.len == 0 or id.len > CF.idmx) return false; for (id) |chr| { if (!(std.ascii.isLower(chr) or std.ascii.isDigit(chr) or chr == '-')) return false; } return true; }
pub fn loadBook(aren: std.mem.Allocator, iozz: std.Io, dir: []const u8, limit: u32) !Book { const none: Book = .{ .main = CF.main, .accs = &.{.{}}, .filez = false }; if (dir.len == 0) return none; const path = std.fs.path.join(aren, &.{ dir, CF.file }) catch return none; const byte = std.Io.Dir.cwd().readFileAlloc(iozz, path, aren, .limited(CF.maxz)) catch return none; const raw = std.json.parseFromSliceLeaky(Raw, aren, byte, .{ .ignore_unknown_fields = true, .allocate = .alloc_always }) catch return error.BadConfig; if (raw.accs.len == 0) return .{ .main = CF.main, .accs = &.{.{}}, .filez = true };
if (raw.accs.len > limit) return error.BadConfig; for (raw.accs, 0..) |acc, ix| { if (!idOk(acc.id) or acc.scal == 0 or acc.scal > 100) return error.BadConfig; for (raw.accs[0..ix]) |prev| { if (std.mem.eql(u8, prev.id, acc.id)) return error.BadConfig; } } const mn = if (raw.main.len > 0) raw.main else raw.accs[0].id; var hit = false; for (raw.accs) |acc| { if (std.mem.eql(u8, acc.id, mn)) hit = true; } if (!hit) return error.BadConfig; return .{ .main = mn, .accs = raw.accs, .filez = true }; }
pub fn pick(book: Book, id: []const u8) ?Acc { const want = if (id.len == 0) book.main else id; for (book.accs) |acc| { if (std.mem.eql(u8, acc.id, want)) return acc; } return null; }
pub fn maskPhone(aren: std.mem.Allocator, phone: []const u8) ![]u8 { if (phone.len == 0) return aren.dupe(u8, "-"); const keep = @min(phone.len, 3); return std.fmt.allocPrint(aren, "***{s}", .{phone[phone.len - keep ..]}); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
