// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Job catalog as data: each job = name, cap kind, risk, page, steps with label keys
// Flo: one row per job > steps name a label key (ut-loca-pack) and an argument slot > the runner turns rows into flow steps
// I/O: none (constants) > Job rows (find by name, list for `fb jobs`)
// ===================================================================
const std = @import("std"); const pace = @import("ru-huma-pace.zig"); const flow = @import("ru-flow-runz.zig");
pub const Risk = enum { w, x };
pub const Src = enum { none, url, home, noti, frie_requ, birt, msgr, msgr_requ, mark_sell, evnt_crea, stor_crea, reel_crea, prof, bizz, dmsg_thre };
pub const Arg = enum { none, text, to, url, title, price, desc, group, photo, opt, date, time };
pub const T = struct { op: flow.Op, role: []const u8 = "", key: []const u8 = "", larg: Arg = .none, arg: Arg = .none, lit: []const u8 = "", commit: bool = false, idx: bool = false };
pub const Job = struct { name: []const u8, kind: pace.Kind, risk: Risk, src: Src, need: []const Arg, each: bool = false, steps: []const T };
fn g() T { return .{ .op = .goto }; }
fn c(key: []const u8) T { return .{ .op = .click, .key = key }; }
fn cm(key: []const u8) T { return .{ .op = .click, .key = key, .commit = true }; }
fn cf(key: []const u8) T { return .{ .op = .confirm, .key = key, .commit = true }; }
fn cl(arg: Arg) T { return .{ .op = .click, .larg = arg }; }
fn ty(key: []const u8, arg: Arg) T { return .{ .op = .typez, .key = key, .arg = arg }; }
fn tyi(key: []const u8, arg: Arg) T { return .{ .op = .typez, .key = key, .arg = arg, .idx = true }; }
fn ck(key: []const u8) T { return .{ .op = .clear, .key = key }; }
fn up(arg: Arg) T { return .{ .op = .upload, .arg = arg }; }
fn ex(arg: Arg) T { return .{ .op = .expect, .arg = arg }; }
fn sl(key: []const u8, arg: Arg) T { return .{ .op = .select, .key = key, .arg = arg, .role = "button" }; }
fn hv(key: []const u8) T { return .{ .op = .hover, .key = key }; }
fn mi(arg: Arg, key: []const u8) T { return .{ .op = .click, .key = key, .larg = arg, .role = "menuitem", .commit = true }; }
fn en() T { return .{ .op = .key, .lit = "Enter", .commit = true }; }
pub const JOBS = [_]Job{
.{ .name = "post-photo", .kind = .post, .risk = .w, .src = .home, .need = &.{ .text, .photo }, .steps = &.{ g(), c("post_open"), up(.photo), ty("post_boxz", .text), cm("post_subm"), ex(.text) } },
.{ .name = "post-audience", .kind = .post, .risk = .w, .src = .home, .need = &.{ .text, .opt }, .steps = &.{ g(), c("post_open"), sl("audi_btnz", .opt), ty("post_boxz", .text), cm("post_subm"), ex(.text) } },
.{ .name = "post-poll", .kind = .post, .risk = .w, .src = .home, .need = &.{ .text, .title, .desc }, .steps = &.{ g(), c("post_open"), c("poll_addz"), ty("post_boxz", .text), ty("poll_opt1", .title), ty("poll_opt2", .desc), cm("post_subm"), ex(.text) } },
.{ .name = "post-edit", .kind = .post, .risk = .w, .src = .url, .need = &.{ .url, .text }, .steps = &.{ g(), c("more_menu"), c("post_edit"), ck("post_boxz"), ty("post_boxz", .text), cm("post_updt"), ex(.text) } },
.{ .name = "post-delete", .kind = .post, .risk = .x, .src = .url, .need = &.{.url}, .steps = &.{ g(), c("more_menu"), c("post_dele"), cf("dele_conf") } },
.{ .name = "post-comment", .kind = .comm, .risk = .w, .src = .url, .need = &.{ .url, .text }, .steps = &.{ g(), ty("comm_boxz", .text), en(), ex(.text) } },
.{ .name = "post-react", .kind = .reac, .risk = .w, .src = .url, .need = &.{.url}, .steps = &.{ g(), hv("reac_btnz"), mi(.opt, "reac_like") } },
.{ .name = "post-share", .kind = .shar, .risk = .w, .src = .url, .need = &.{.url}, .steps = &.{ g(), c("shar_btnz"), cm("shar_feed") } },
.{ .name = "post-share-group", .kind = .shar, .risk = .w, .src = .url, .need = &.{ .url, .group }, .steps = &.{ g(), c("shar_btnz"), c("shar_grou"), cl(.group), cm("shar_post") } },
.{ .name = "post-save", .kind = .reac, .risk = .w, .src = .url, .need = &.{.url}, .steps = &.{ g(), cm("post_save") } },
.{ .name = "friend-accept", .kind = .frie, .risk = .w, .src = .frie_requ, .need = &.{}, .each = true, .steps = &.{ g(), cm("frie_conf") } },
.{ .name = "friend-decline", .kind = .frie, .risk = .x, .src = .frie_requ, .need = &.{}, .each = true, .steps = &.{ g(), cm("frie_decl") } },
.{ .name = "friend-unfriend", .kind = .frie, .risk = .x, .src = .url, .need = &.{.url}, .steps = &.{ g(), c("frie_menu"), c("frie_unfr"), cf("conf_butt") } },
.{ .name = "friend-follow", .kind = .frie, .risk = .w, .src = .url, .need = &.{.url}, .steps = &.{ g(), cm("frie_foll") } },
.{ .name = "friend-unfollow", .kind = .frie, .risk = .w, .src = .url, .need = &.{.url}, .steps = &.{ g(), cm("frie_unfo") } },
.{ .name = "friend-block", .kind = .frie, .risk = .x, .src = .url, .need = &.{.url}, .steps = &.{ g(), c("more_menu"), c("frie_blok"), cf("conf_butt") } },
.{ .name = "birthday-wish", .kind = .comm, .risk = .w, .src = .birt, .need = &.{.text}, .each = true, .steps = &.{ g(), tyi("birt_boxz", .text), en() } },
.{ .name = "noti-mark", .kind = .comm, .risk = .w, .src = .noti, .need = &.{}, .steps = &.{ g(), cm("noti_mark") } },
.{ .name = "msgr-file", .kind = .dmsg, .risk = .w, .src = .dmsg_thre, .need = &.{ .to, .photo }, .steps = &.{ g(), up(.photo), en() } },
.{ .name = "msgr-accept", .kind = .dmsg, .risk = .w, .src = .msgr_requ, .need = &.{}, .each = true, .steps = &.{ g(), cm("msgr_acpt") } },
.{ .name = "msgr-ignore", .kind = .dmsg, .risk = .x, .src = .msgr_requ, .need = &.{}, .each = true, .steps = &.{ g(), cm("msgr_igno") } },
.{ .name = "group-leave", .kind = .grou, .risk = .x, .src = .url, .need = &.{.url}, .steps = &.{ g(), c("grou_leav"), cf("conf_butt") } },
.{ .name = "admin-approve", .kind = .admn, .risk = .w, .src = .url, .need = &.{.url}, .each = true, .steps = &.{ g(), cm("gadm_appr") } },
.{ .name = "admin-decline", .kind = .admn, .risk = .x, .src = .url, .need = &.{.url}, .each = true, .steps = &.{ g(), cm("gadm_decl") } },
.{ .name = "admin-remove", .kind = .admn, .risk = .x, .src = .url, .need = &.{.url}, .steps = &.{ g(), c("gadm_remo"), cf("conf_butt") } },
.{ .name = "page-switch", .kind = .admn, .risk = .w, .src = .url, .need = &.{.url}, .steps = &.{ g(), cm("pgem_swit") } },
.{ .name = "page-hide", .kind = .admn, .risk = .x, .src = .url, .need = &.{.url}, .steps = &.{ g(), cm("pgem_hide") } },
.{ .name = "biz-schedule", .kind = .post, .risk = .w, .src = .bizz, .need = &.{ .text, .date, .time }, .steps = &.{ g(), ty("post_boxz", .text), ty("bizz_date", .date), ty("bizz_time", .time), cm("bizz_sche") } },
.{ .name = "market-edit", .kind = .mark, .risk = .w, .src = .url, .need = &.{ .url, .price }, .steps = &.{ g(), c("mark_edit"), ck("mark_pric"), ty("mark_pric", .price), cm("mark_save") } },
.{ .name = "event-create", .kind = .evnt, .risk = .w, .src = .evnt_crea, .need = &.{ .title, .date }, .steps = &.{ g(), ty("evnt_name", .title), ty("evnt_date", .date), ty("mark_desc", .desc), cm("evnt_crea") } },
.{ .name = "event-invite", .kind = .evnt, .risk = .w, .src = .url, .need = &.{ .url, .to }, .steps = &.{ g(), c("evnt_invi"), ty("evnt_srch", .to), cl(.to), cm("evnt_send") } },
.{ .name = "event-respond", .kind = .evnt, .risk = .w, .src = .url, .need = &.{.url}, .steps = &.{ g(), cm("evnt_goin") } },
.{ .name = "event-cancel", .kind = .evnt, .risk = .x, .src = .url, .need = &.{.url}, .steps = &.{ g(), c("evnt_canc"), cf("conf_butt") } },
.{ .name = "story-create", .kind = .stor, .risk = .w, .src = .stor_crea, .need = &.{.photo}, .steps = &.{ g(), up(.photo), cm("stor_shar") } },
.{ .name = "reel-create", .kind = .stor, .risk = .w, .src = .reel_crea, .need = &.{.photo}, .steps = &.{ g(), up(.photo), ty("mark_desc", .text), cm("reel_publ") } },
.{ .name = "profile-bio", .kind = .prof, .risk = .w, .src = .prof, .need = &.{.text}, .steps = &.{ g(), c("prof_edit"), ck("prof_bioz"), ty("prof_bioz", .text), cm("prof_save") } },
};
pub fn find(name: []const u8) ?*const Job { for (&JOBS) |*jb| { if (std.mem.eql(u8, jb.name, name)) return jb; } return null; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
