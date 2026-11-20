// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Tests for ru-chat-grou: pin and mute live, group needs force, dry run changes nothing
// Flo: mock chat page > run each action > read page state
// I/O: html > pass or fail
// Run: zig build test
// ===================================================================
const std = @import("std"); const grp = @import("ru-chat-grou.zig"); const sess = @import("ru-sess-ctxz.zig"); const data = @import("st-stat-data.zig"); const conf = @import("cf-conf-load.zig"); const mock = @import("te-mock-page.zig"); const snap = @import("ru-page-snap.zig"); const fixt = @import("te-fixt-html.zig"); const T = std.testing;
const NOON: i64 = 100 * 86400000 + 12 * 3600000;
fn profOf(tmpz: *std.testing.TmpDir, buff: []u8) ![]const u8 { return std.fmt.bufPrint(buff, ".zig-cache/tmp/{s}/prof", .{tmpz.sub_path}); }
fn cfgOf() conf.Conf { var cfg: conf.Conf = .{}; cfg.type_dely_msec = .{ 1, 2 }; cfg.warm_dayz_coun = 0; cfg.retr_coun_maxz = 2; return cfg; }
const Rig = struct { tmpz: std.testing.TmpDir, mok: mock.Mock, aren: std.heap.ArenaAllocator, sto: data.Stor,
fn up(self: *Rig, buff: []u8) !void { self.tmpz = std.testing.tmpDir(.{}); self.mok = try mock.start(T.allocator, T.io, try profOf(&self.tmpz, buff), fixt.chat); self.aren = std.heap.ArenaAllocator.init(T.allocator); self.sto = try data.Stor.open(T.allocator, ":memory:"); }
fn down(self: *Rig) void { self.sto.close(); self.aren.deinit(); self.mok.stop(); self.tmpz.cleanup(); }
fn ses(self: *Rig, mode: sess.Mode) sess.Sess { var out = sess.Sess.init(T.allocator, T.io, self.aren.allocator(), cfgOf(), &self.sto, self.mok.conn, mode); out.fast = true; out.fake_ms = NOON; out.job = "grou"; return out; }
fn js(self: *Rig, code: []const u8) ![]const u8 { return snap.evalStr(self.aren.allocator(), self.mok.conn, code); } };
test "M6 pin and mute act on the opened chat in live mode" { var buff: [160]u8 = undefined; var rig: Rig = undefined; try rig.up(&buff); defer rig.down(); var ses = rig.ses(.live); try T.expect(try grp.chatAct(&ses, .pin, "Boss", "")); try T.expectEqualStrings("Boss", try rig.js("st.pin")); try T.expect(try grp.chatAct(&ses, .mute, "mom", "")); try T.expectEqualStrings("Mom", try rig.js("st.mute")); }
test "dry run previews and touches nothing" { var buff: [160]u8 = undefined; var rig: Rig = undefined; try rig.up(&buff); defer rig.down(); var ses = rig.ses(.dry); try T.expect(!try grp.chatAct(&ses, .pin, "Boss", "")); try T.expectEqualStrings("undefined", try rig.js("typeof st.pin")); const rows = try rig.sto.logTail(rig.aren.allocator(), 2); try T.expect(std.mem.startsWith(u8, rows[rows.len - 1].msg, "PREVIEW pin Boss")); }
test "read-only refuses, empty chat is BadJob, unknown chat is NoElem" { var buff: [160]u8 = undefined; var rig: Rig = undefined; try rig.up(&buff); defer rig.down(); var rdo = rig.ses(.read); try T.expectError(error.BadUsage, grp.chatAct(&rdo, .pin, "Boss", "")); var live = rig.ses(.live); try T.expectError(error.BadJob, grp.chatAct(&live, .pin, "", "")); try T.expectError(error.NoElem, grp.chatAct(&live, .pin, "Nobody", "")); }
test "new group and forward need force, then run and count as new contact" { var buff: [160]u8 = undefined; var rig: Rig = undefined; try rig.up(&buff); defer rig.down(); var live = rig.ses(.live); try T.expectError(error.NeedForce, grp.chatAct(&live, .grop, "", "")); try T.expectError(error.NeedForce, grp.chatAct(&live, .forw, "Mom", "Boss")); var frc = rig.ses(.force); try T.expect(try grp.chatAct(&frc, .grop, "", "")); try T.expectEqualStrings("1", try rig.js("st.grp")); const sta = try rig.sto.statGet(T.allocator, NOON + 1000); try T.expectEqual(@as(u32, 1), sta.newc_cnt); }
test "new-contact cap stops group creation" { var buff: [160]u8 = undefined; var rig: Rig = undefined; try rig.up(&buff); defer rig.down(); var frc = rig.ses(.force); frc.cfg.capz_newc_dayz = 1; try T.expect(try grp.chatAct(&frc, .grop, "", "")); frc.fake_ms = NOON + 10000; try T.expectError(error.CapHit, grp.chatAct(&frc, .grop, "", "")); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
