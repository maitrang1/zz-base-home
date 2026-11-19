// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: wo rels sign TAG: sign the verified release hashes with the owner's SSH key
// Flo: release body says Verified? > download sha256.txt > ssh-keygen -Y sign -U (key from ssh-agent) > upload sha256.txt.sig > stamp
// I/O: Ctxz + sign TAG (dry-run default, --live acts) > facts, exit 0 ok / 1 failed / 4 blocked
// ===================================================================
const std = @import("std");
const cx = @import("ct-ctrl-ctxz.zig");
const fcts = @import("ob-fact-rept.zig");
const exit = @import("ct-exit-code.zig");
const CF = .{ .mark = "Verified: GitHub and GitLab built identical bytes", .nspc = "zz-base-home-release", .shaz = "sha256.txt", .sigz = "sha256.txt.sig", .maxz = 64 };
pub fn tagOkay(tag: []const u8) bool {
if (tag.len < 2 or tag.len > CF.maxz or tag[0] != 'v') return false;
for (tag) |chr| { if (!(std.ascii.isAlphanumeric(chr) or chr == '.' or chr == '-' or chr == '_')) return false; }
return true;
}
pub fn comm(ctxz: *const cx.Ctxz, args: []const []const u8) !exit.Code {
if (args.len != 2 or !std.mem.eql(u8, args[0], "sign")) return exit.Erro.Usag;
const tag = args[1];
var facts: std.ArrayList(fcts.Fact) = .empty;
if (!tagOkay(tag)) { try facts.append(ctxz.allo, cx.mkfa("tag", .fail, "tag must look like v1.2.3 (letters, digits, dot, dash, underscore)")); return ctxz.emit(facts.items); }
const keyp = try std.fs.path.join(ctxz.allo, &.{ ctxz.home, ctxz.conf.rels_keyz_file });
_ = std.Io.Dir.cwd().statFile(ctxz.iozz, keyp, .{}) catch { try facts.append(ctxz.allo, cx.mkfa("keyz", .bloc, try std.fmt.allocPrint(ctxz.allo, "signing key not found: {s}", .{ctxz.conf.rels_keyz_file}))); return ctxz.emit(facts.items); };
const view = (try ctxz.tool(&.{ "gh", "release", "view", tag, "--json", "body", "-q", ".body" }, &.{})) orelse { try facts.append(ctxz.allo, cx.mkfa("rele", .bloc, "gh absent")); return ctxz.emit(facts.items); };
if (view.code != 0) { try facts.append(ctxz.allo, cx.mkfa("rele", .fail, try std.fmt.allocPrint(ctxz.allo, "cannot read release {s}: {s}", .{ tag, cx.clip(cx.trim(view.errz)) }))); return ctxz.emit(facts.items); }
if (std.mem.indexOf(u8, view.outz, CF.mark) == null) { try facts.append(ctxz.allo, cx.mkfa("rele", .bloc, "release is not Verified yet (GitHub and GitLab have not agreed): sign later")); return ctxz.emit(facts.items); }
if (!ctxz.ladd.live) { try facts.append(ctxz.allo, cx.mkfa("sign", .okay, try std.fmt.allocPrint(ctxz.allo, "dry-run: would sign {s} of {s} with {s} and upload {s}", .{ CF.shaz, tag, std.fs.path.basename(keyp), CF.sigz }))); return ctxz.emit(facts.items); }
const dirz = try std.fs.path.join(ctxz.allo, &.{ try ctxz.dirzData(), "rels", try std.fmt.allocPrint(ctxz.allo, "{s}-{s}", .{ tag, try cx.stamTxt(ctxz.allo, ctxz.nowz()) }) });
try std.Io.Dir.cwd().createDirPath(ctxz.iozz, dirz);
_ = (try ctxz.step(&facts, "down", &.{ "gh", "release", "download", tag, "-p", CF.shaz, "-D", dirz }, &.{})) orelse return ctxz.emit(facts.items);
const shap = try std.fs.path.join(ctxz.allo, &.{ dirz, CF.shaz });
_ = (try ctxz.step(&facts, "sign", &.{ "ssh-keygen", "-Y", "sign", "-U", "-f", keyp, "-n", CF.nspc, shap }, &.{})) orelse return ctxz.emit(facts.items);
const sigp = try std.fs.path.join(ctxz.allo, &.{ dirz, CF.sigz });
_ = (try ctxz.step(&facts, "upld", &.{ "gh", "release", "upload", tag, sigp, "--clobber" }, &.{})) orelse return ctxz.emit(facts.items);
try ctxz.stamPut("rels", .{ .when = ctxz.nowz(), .okay = true, .note = tag });
return ctxz.emit(facts.items);
}
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
