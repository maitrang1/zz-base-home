// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Job catalog as data: name, cap, risk, page, steps
// Flo: one row per ZenRows action > steps name a label key (ut-loca-pack) and an argument slot > the runner turns rows into flow steps
// I/O: none (constants) > Job rows (find by name, list for `zr-zrow-webs jobs`)
// ===================================================================
const std = @import("std"); const pace = @import("ru-huma-pace.zig"); const flow = @import("ru-flow-runz.zig");
pub const Risk = enum { w, x };
pub const Host = enum { app, www, docs };
pub const Arg = enum { none, text, to, url, title, price, desc, group, photo, opt, date, time, user, pass };
pub const T = struct { op: flow.Op, role: []const u8 = "", key: []const u8 = "", larg: Arg = .none, arg: Arg = .none, lit: []const u8 = "", commit: bool = false };
pub const Job = struct { name: []const u8, kind: pace.Kind, risk: Risk, host: Host, path: []const u8, need: []const Arg, steps: []const T, hint: []const u8, auth: bool = false, once: bool = false };
fn g() T { return .{ .op = .goto }; }
fn c(key: []const u8) T { return .{ .op = .click, .key = key }; }
fn cm(key: []const u8) T { return .{ .op = .click, .key = key, .commit = true }; }
fn cf(key: []const u8) T { return .{ .op = .confirm, .key = key, .commit = true }; }
fn cl(arg: Arg) T { return .{ .op = .click, .larg = arg }; }
fn ty(key: []const u8, arg: Arg) T { return .{ .op = .typez, .key = key, .arg = arg }; }
fn ck(key: []const u8) T { return .{ .op = .clear, .key = key }; }
fn up(arg: Arg) T { return .{ .op = .upload, .arg = arg }; }
fn ex(arg: Arg) T { return .{ .op = .expect, .arg = arg }; }
fn ek(key: []const u8) T { return .{ .op = .expect, .key = key }; }
fn sl(key: []const u8, arg: Arg) T { return .{ .op = .select, .key = key, .arg = arg }; }
fn tg(key: []const u8, lit: []const u8) T { return .{ .op = .toggle, .key = key, .lit = lit, .commit = true }; }
fn en() T { return .{ .op = .key, .lit = "Enter", .commit = true }; }
pub const JOBS = [_]Job{
.{ .name = "signup", .kind = .acct, .risk = .w, .host = .app, .path = "p_regi", .auth = true, .once = true, .need = &.{}, .hint = "OPTIONAL: fill the sign-up form (Cloudflare may block; prefer zr-zrow-webs login by hand)", .steps = &.{ g(), ty("emai_boxz", .user), ty("pass_boxz", .pass), cm("regi_subm"), ek("code_page") } },
.{ .name = "verify-email", .kind = .acct, .risk = .w, .host = .app, .path = "p_veri", .auth = true, .need = &.{.text}, .hint = "OPTIONAL: type the 6-digit email code (or type it by hand in the window)", .steps = &.{ g(), ty("code_boxz", .text), cm("veri_subm"), ek("dash_home") } },
.{ .name = "login", .kind = .acct, .risk = .w, .host = .app, .path = "p_logi", .auth = true, .need = &.{}, .hint = "OPTIONAL: fill the login form (Cloudflare may block; prefer zr-zrow-webs login by hand)", .steps = &.{ g(), ty("emai_boxz", .user), ty("pass_boxz", .pass), cm("logi_subm"), ek("dash_home") } },
.{ .name = "logout", .kind = .acct, .risk = .w, .host = .app, .path = "p_home", .auth = true, .need = &.{}, .hint = "log out", .steps = &.{ g(), c("user_menu"), cm("logo_butt"), ek("logi_page") } },
.{ .name = "sso-google", .kind = .acct, .risk = .w, .host = .app, .path = "p_logi", .auth = true, .need = &.{}, .hint = "start Google sign-in (you finish it in the window)", .steps = &.{ g(), cm("ssoz_goog") } },
.{ .name = "sso-github", .kind = .acct, .risk = .w, .host = .app, .path = "p_logi", .auth = true, .need = &.{}, .hint = "start GitHub sign-in (you finish it in the window)", .steps = &.{ g(), cm("ssoz_gith") } },
.{ .name = "reset-pass", .kind = .acct, .risk = .w, .host = .app, .path = "p_rese", .auth = true, .need = &.{}, .hint = "send the password reset email", .steps = &.{ g(), ty("emai_boxz", .user), cm("rese_subm"), ek("rese_sent") } },
.{ .name = "profile-name", .kind = .sett, .risk = .w, .host = .app, .path = "p_acco", .need = &.{.title}, .hint = "change the profile name", .steps = &.{ g(), ck("name_boxz"), ty("name_boxz", .title), cm("acco_save"), ek("save_done") } },
.{ .name = "email-change", .kind = .acct, .risk = .x, .host = .app, .path = "p_acco", .need = &.{.to}, .hint = "change the account email", .steps = &.{ g(), c("emai_chng"), ck("emai_boxz"), ty("emai_boxz", .to), cm("acco_save"), ek("save_done") } },
.{ .name = "pass-change", .kind = .sett, .risk = .x, .host = .app, .path = "p_secu", .need = &.{.opt}, .hint = "change the password (--opt new password)", .steps = &.{ g(), ty("pass_curr", .pass), ty("pass_newz", .opt), cm("pass_save"), ek("save_done") } },
.{ .name = "twofa-on", .kind = .sett, .risk = .w, .host = .app, .path = "p_secu", .need = &.{}, .hint = "turn 2FA on (you scan the code)", .steps = &.{ g(), tg("twof_togl", "on") } },
.{ .name = "twofa-off", .kind = .sett, .risk = .x, .host = .app, .path = "p_secu", .need = &.{}, .hint = "turn 2FA off", .steps = &.{ g(), tg("twof_togl", "off") } },
.{ .name = "account-delete", .kind = .acct, .risk = .x, .host = .app, .path = "p_acco", .once = true, .need = &.{}, .hint = "delete the account for good (ask support for a refund first)", .steps = &.{ g(), c("acco_dele"), cf("dele_conf"), ek("dele_done") } },
.{ .name = "fetch-run", .kind = .prod, .risk = .w, .host = .app, .path = "p_play", .need = &.{.url}, .hint = "get a web page (--opt extra params, --text code language)", .steps = &.{ g(), ty("play_urlz", .url), ty("play_para", .opt), sl("play_lang", .text), c("play_runz"), ek("play_resu") } },
.{ .name = "extract-run", .kind = .prod, .risk = .w, .host = .app, .path = "p_extr", .need = &.{.url}, .hint = "pull data fields from a page (--opt what to pull)", .steps = &.{ g(), ty("play_urlz", .url), ty("extr_rule", .opt), c("play_runz"), ek("play_resu") } },
.{ .name = "snippet-get", .kind = .prod, .risk = .w, .host = .app, .path = "p_play", .need = &.{ .url, .text }, .hint = "get code for a request (--text python|node|go|curl)", .steps = &.{ g(), ty("play_urlz", .url), sl("play_lang", .text), c("snip_show"), ek("snip_code") } },
.{ .name = "crawl-start", .kind = .prod, .risk = .w, .host = .app, .path = "p_craw", .need = &.{.url}, .hint = "start a crawl from a page", .steps = &.{ g(), c("craw_newz"), ty("craw_urlz", .url), cm("craw_star"), ek("craw_done") } },
.{ .name = "crawl-stop", .kind = .prod, .risk = .x, .host = .app, .path = "p_craw", .need = &.{}, .hint = "stop the running crawl", .steps = &.{ g(), c("craw_menu"), cf("craw_stop") } },
.{ .name = "crawl-view", .kind = .prod, .risk = .w, .host = .app, .path = "p_craw", .need = &.{}, .hint = "see the crawl status and results", .steps = &.{ g(), ek("craw_head") } },
.{ .name = "batch-send", .kind = .prod, .risk = .w, .host = .app, .path = "p_batc", .need = &.{.text}, .hint = "send many URLs at once (--text one URL per line)", .steps = &.{ g(), ty("batc_urls", .text), cm("batc_subm"), ek("batc_done") } },
.{ .name = "batch-file", .kind = .prod, .risk = .w, .host = .app, .path = "p_batc", .need = &.{.photo}, .hint = "send a file of URLs (--photo file path)", .steps = &.{ g(), up(.photo), cm("batc_subm"), ek("batc_done") } },
.{ .name = "browser-view", .kind = .prod, .risk = .w, .host = .app, .path = "p_brow", .need = &.{}, .hint = "show the cloud browser connect link", .steps = &.{ g(), ek("brow_conn") } },
.{ .name = "proxy-view", .kind = .prod, .risk = .w, .host = .app, .path = "p_prox", .need = &.{}, .hint = "show the proxy login details", .steps = &.{ g(), ek("prox_cred") } },
.{ .name = "usage-view", .kind = .data, .risk = .w, .host = .app, .path = "p_usag", .need = &.{}, .hint = "show how many credits you used", .steps = &.{ g(), ek("usag_head") } },
.{ .name = "analytics-view", .kind = .data, .risk = .w, .host = .app, .path = "p_anal", .need = &.{}, .hint = "show success rate and request history", .steps = &.{ g(), ek("anal_head") } },
.{ .name = "logs-view", .kind = .data, .risk = .w, .host = .app, .path = "p_logs", .need = &.{}, .hint = "show the recent request log", .steps = &.{ g(), ek("logs_head") } },
.{ .name = "report-export", .kind = .data, .risk = .w, .host = .app, .path = "p_anal", .need = &.{}, .hint = "export the report", .steps = &.{ g(), cm("expo_butt"), ek("expo_done") } },
.{ .name = "plan-view", .kind = .mone, .risk = .w, .host = .app, .path = "p_bill", .need = &.{}, .hint = "show your plan and credits", .steps = &.{ g(), ek("bill_head") } },
.{ .name = "plan-change", .kind = .mone, .risk = .x, .host = .app, .path = "p_bill", .need = &.{.opt}, .hint = "upgrade or downgrade (--opt plan name)", .steps = &.{ g(), c("plan_chan"), cl(.opt), cm("plan_conf"), ek("plan_done") } },
.{ .name = "topup-buy", .kind = .mone, .risk = .x, .host = .app, .path = "p_bill", .need = &.{}, .hint = "buy extra credits (paid plans, max 10 per period)", .steps = &.{ g(), c("topu_btnz"), cf("topu_conf"), ek("topu_done") } },
.{ .name = "invoice-list", .kind = .mone, .risk = .w, .host = .app, .path = "p_bill", .need = &.{}, .hint = "list your invoices", .steps = &.{ g(), ek("invo_head") } },
.{ .name = "invoice-get", .kind = .mone, .risk = .w, .host = .app, .path = "p_bill", .need = &.{}, .hint = "download the latest invoice", .steps = &.{ g(), cm("invo_down") } },
.{ .name = "payment-open", .kind = .mone, .risk = .x, .host = .app, .path = "p_bill", .need = &.{}, .hint = "open the card form (you type the card)", .steps = &.{ g(), c("paym_edit") } },
.{ .name = "sub-cancel", .kind = .mone, .risk = .x, .host = .app, .path = "p_bill", .once = true, .need = &.{}, .hint = "cancel the subscription (access stays to cycle end)", .steps = &.{ g(), c("subs_canc"), cf("canc_conf"), ek("canc_done") } },
.{ .name = "key-create", .kind = .acce, .risk = .w, .host = .app, .path = "p_keys", .need = &.{.title}, .hint = "create an API key (--title name)", .steps = &.{ g(), c("keyz_newz"), ty("keyz_name", .title), cm("keyz_save"), ex(.title) } },
.{ .name = "key-rename", .kind = .acce, .risk = .w, .host = .app, .path = "p_keys", .need = &.{.title}, .hint = "rename the first API key (--title new name)", .steps = &.{ g(), c("keyz_menu"), c("keyz_rena"), ck("keyz_name"), ty("keyz_name", .title), cm("keyz_save"), ex(.title) } },
.{ .name = "key-cap", .kind = .acce, .risk = .w, .host = .app, .path = "p_keys", .need = &.{.price}, .hint = "set a credit cap on the first key (--price credits)", .steps = &.{ g(), c("keyz_menu"), c("keyz_capz"), ck("capz_boxz"), ty("capz_boxz", .price), cm("capz_save"), ek("save_done") } },
.{ .name = "key-revoke", .kind = .acce, .risk = .x, .host = .app, .path = "p_keys", .need = &.{}, .hint = "delete the first API key", .steps = &.{ g(), c("keyz_menu"), c("keyz_revo"), cf("revo_conf"), ek("revo_done") } },
.{ .name = "team-invite", .kind = .acce, .risk = .w, .host = .app, .path = "p_team", .need = &.{.to}, .hint = "invite a teammate (--to email, --opt role)", .steps = &.{ g(), c("team_invi"), ty("emai_boxz", .to), sl("role_pick", .opt), cm("invi_send"), ek("invi_done") } },
.{ .name = "team-remove", .kind = .acce, .risk = .x, .host = .app, .path = "p_team", .need = &.{.to}, .hint = "remove a teammate (--to email)", .steps = &.{ g(), cl(.to), c("team_remo"), cf("remo_conf") } },
.{ .name = "webhook-add", .kind = .acce, .risk = .w, .host = .app, .path = "p_webh", .need = &.{.url}, .hint = "add a webhook (--url)", .steps = &.{ g(), c("webh_newz"), ty("webh_urlz", .url), cm("webh_save"), ex(.url) } },
.{ .name = "webhook-drop", .kind = .acce, .risk = .x, .host = .app, .path = "p_webh", .need = &.{}, .hint = "delete the first webhook", .steps = &.{ g(), c("webh_menu"), cf("webh_dele") } },
.{ .name = "integ-view", .kind = .acce, .risk = .w, .host = .app, .path = "p_inte", .need = &.{}, .hint = "list the integrations", .steps = &.{ g(), ek("inte_head") } },
.{ .name = "notif-usage-on", .kind = .sett, .risk = .w, .host = .app, .path = "p_noti", .need = &.{}, .hint = "turn usage alerts on (80% and 95%)", .steps = &.{ g(), tg("noti_usag", "on") } },
.{ .name = "notif-usage-off", .kind = .sett, .risk = .w, .host = .app, .path = "p_noti", .need = &.{}, .hint = "turn usage alerts off", .steps = &.{ g(), tg("noti_usag", "off") } },
.{ .name = "notif-email-add", .kind = .sett, .risk = .w, .host = .app, .path = "p_noti", .need = &.{.to}, .hint = "add an alert email (--to)", .steps = &.{ g(), ty("noti_emai", .to), cm("noti_save"), ek("save_done") } },
.{ .name = "prefs-view", .kind = .sett, .risk = .w, .host = .app, .path = "p_pref", .need = &.{}, .hint = "show the preferences page", .steps = &.{ g(), ek("pref_head") } },
.{ .name = "secu-view", .kind = .sett, .risk = .w, .host = .app, .path = "p_secu", .need = &.{}, .hint = "show the security page", .steps = &.{ g(), ek("secu_head") } },
.{ .name = "docs-open", .kind = .help, .risk = .w, .host = .docs, .path = "p_docs", .need = &.{}, .hint = "open the docs", .steps = &.{ g(), ek("docs_head") } },
.{ .name = "docs-search", .kind = .help, .risk = .w, .host = .docs, .path = "p_docs", .need = &.{.text}, .hint = "search the docs (--text words)", .steps = &.{ g(), ty("docs_srch", .text), en(), ex(.text) } },
.{ .name = "support-send", .kind = .help, .risk = .w, .host = .app, .path = "p_supp", .need = &.{ .title, .text }, .hint = "message support (--title subject, --text body)", .steps = &.{ g(), ty("supp_subj", .title), ty("supp_body", .text), cm("supp_send"), ek("supp_done") } },
.{ .name = "feedback-send", .kind = .help, .risk = .w, .host = .app, .path = "p_feed", .need = &.{.text}, .hint = "send feedback (--text)", .steps = &.{ g(), ty("supp_body", .text), cm("supp_send"), ek("supp_done") } },
.{ .name = "page-open", .kind = .help, .risk = .w, .host = .www, .path = "", .need = &.{.url}, .hint = "open any ZenRows page by path or URL (--url)", .steps = &.{g()} },
};
pub fn find(name: []const u8) ?*const Job { for (&JOBS) |*jb| { if (std.mem.eql(u8, jb.name, name)) return jb; } return null; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
