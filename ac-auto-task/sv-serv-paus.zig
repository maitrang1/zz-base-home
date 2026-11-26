// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Pause and resume routes for jobs and chains
// Flo: parse id > chain first, then live job > freeze or thaw the tree > reply status + JSON
// I/O: POST /pause and /resume body {"id"} > 200 ok, 409 not running or same state, 500 freeze failed
// ===================================================================
const std = @import("std"); const http = @import("http"); const spaw = @import("spawn"); const regi = @import("registry");
const svservbase = @import("sv-serv-base.zig"); const jsonStrz = svservbase.jsonStrz; const Rout = @import("sv-serv-rout.zig").Rout;
pub fn paus(self: Rout, onzz: bool) !void { const valu = self.bodyJson() orelse return self.erroSend("bad_json"); const iden = jsonStrz(valu, "id") orelse ""; if (iden.len == 0) return self.erroSend("missing_id"); const chai_iden = if (std.mem.lastIndexOfScalar(u8, iden, '~')) |atzz| iden[0..atzz] else iden; var code = self.ctxz.sche.chaiPaus(self.iozz, chai_iden, onzz); if (code == .none) code = self.ctxz.sche.manuPaus(self.iozz, iden, onzz); if (code == .none) code = self.ctxz.regz.pausSetz(self.iozz, iden, onzz, spaw.nowzMsec(self.iozz)); const resp = regi.pausResp(code, onzz); try http.respSend(self.strm, resp.stat, resp.text, resp.body); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
