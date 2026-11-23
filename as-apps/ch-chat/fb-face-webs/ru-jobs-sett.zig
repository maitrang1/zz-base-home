// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Settings and data jobs as data: privacy, search, notifications, blocking, apps, activity log, download your information, albums, saved
// Flo: rows only; reads use the help cap, writes the acct or data cap; irreversible rows need approval
// I/O: none (constants) > ROWS joined into the catalog by ru-jobs-tabl
// ===================================================================
const t = @import("ru-jobs-type.zig"); const Job = t.Job; const g = t.g; const c = t.c; const cm = t.cm; const cf = t.cf; const cl = t.cl; const ty = t.ty; const up = t.up; const ex = t.ex; const exk = t.exk; const sl = t.sl; const tg = t.tg;
pub const ROWS = [_]Job{
.{ .name = "sett-privacy-check", .area = .sett, .kind = .help, .risk = .w, .src = .cfgp, .pkey = "path_priv_chek", .rep = true, .need = &.{}, .steps = &.{ g(), exk("priv_chek") } },
.{ .name = "sett-audience-default", .area = .sett, .kind = .acct, .risk = .w, .src = .cfgp, .pkey = "path_sett_priv", .rep = true, .need = &.{.opt}, .steps = &.{ g(), sl("sett_audi", .opt), cm("sett_save") } },
.{ .name = "sett-who-friends", .area = .sett, .kind = .acct, .risk = .w, .src = .cfgp, .pkey = "path_sett_priv", .rep = true, .need = &.{.opt}, .steps = &.{ g(), sl("sett_frie", .opt), cm("sett_save") } },
.{ .name = "sett-who-find", .area = .sett, .kind = .acct, .risk = .w, .src = .cfgp, .pkey = "path_sett_priv", .rep = true, .need = &.{.opt}, .steps = &.{ g(), sl("sett_find", .opt), cm("sett_save") } },
.{ .name = "sett-search-engine", .area = .sett, .kind = .acct, .risk = .w, .src = .cfgp, .pkey = "path_sett_priv", .rep = true, .need = &.{}, .steps = &.{ g(), tg("sett_seng", .opt) } },
.{ .name = "sett-tag-review", .area = .sett, .kind = .acct, .risk = .w, .src = .cfgp, .pkey = "path_sett_priv", .rep = true, .need = &.{}, .steps = &.{ g(), tg("sett_tagr", .opt) } },
.{ .name = "sett-noti-email", .area = .sett, .kind = .acct, .risk = .w, .src = .cfgp, .pkey = "path_noti_sett", .rep = true, .need = &.{}, .steps = &.{ g(), tg("noti_emai", .opt) } },
.{ .name = "sett-noti-push", .area = .sett, .kind = .acct, .risk = .w, .src = .cfgp, .pkey = "path_noti_sett", .rep = true, .need = &.{}, .steps = &.{ g(), tg("noti_push", .opt) } },
.{ .name = "sett-noti-sms", .area = .sett, .kind = .acct, .risk = .w, .src = .cfgp, .pkey = "path_noti_sett", .rep = true, .need = &.{}, .steps = &.{ g(), tg("noti_smsz", .opt) } },
.{ .name = "sett-block-add", .area = .sett, .kind = .acct, .risk = .x, .src = .cfgp, .pkey = "path_bloc_list", .rep = true, .need = &.{.to}, .steps = &.{ g(), ty("bloc_srch", .to), cl(.to), cm("bloc_addz") } },
.{ .name = "sett-unblock", .area = .sett, .kind = .acct, .risk = .w, .src = .cfgp, .pkey = "path_bloc_list", .each = true, .need = &.{}, .steps = &.{ g(), cm("bloc_remo") } },
.{ .name = "sett-apps-list", .area = .sett, .kind = .help, .risk = .w, .src = .cfgp, .pkey = "path_apps_webs", .rep = true, .need = &.{}, .steps = &.{ g(), exk("apps_list") } },
.{ .name = "sett-apps-remove", .area = .sett, .kind = .acct, .risk = .x, .src = .cfgp, .pkey = "path_apps_webs", .rep = true, .need = &.{.to}, .steps = &.{ g(), cl(.to), c("apps_remo"), cf("conf_butt") } },
.{ .name = "sett-offfb-clear", .area = .sett, .kind = .acct, .risk = .x, .src = .cfgp, .pkey = "path_offf_acti", .rep = true, .need = &.{}, .steps = &.{ g(), c("offf_clea"), cf("conf_butt") } },
.{ .name = "sett-adpref", .area = .sett, .kind = .acct, .risk = .w, .src = .cfgp, .pkey = "path_adpr_main", .rep = true, .need = &.{}, .steps = &.{ g(), tg("adpr_togg", .opt) } },
.{ .name = "data-activity-list", .area = .data, .kind = .help, .risk = .w, .src = .cfgp, .pkey = "path_acti_logz", .rep = true, .need = &.{}, .steps = &.{ g(), exk("acti_logz") } },
.{ .name = "data-activity-delete", .area = .data, .kind = .data, .risk = .x, .src = .cfgp, .pkey = "path_acti_logz", .rep = true, .need = &.{.opt}, .steps = &.{ g(), sl("acti_year", .opt), c("acti_sele"), cm("acti_dele"), cf("conf_butt") } },
.{ .name = "data-download-request", .area = .data, .kind = .data, .risk = .w, .src = .cfgp, .pkey = "path_down_info", .rep = true, .need = &.{}, .steps = &.{ g(), c("down_crea"), cm("down_subm"), exk("down_done") } },
.{ .name = "data-download-get", .area = .data, .kind = .data, .risk = .w, .src = .cfgp, .pkey = "path_down_info", .rep = true, .dl = true, .need = &.{}, .steps = &.{ g(), c("down_tabz"), cm("down_getz") } },
.{ .name = "data-saved-list", .area = .data, .kind = .help, .risk = .w, .src = .cfgp, .pkey = "path_save_main", .rep = true, .need = &.{}, .steps = &.{ g(), exk("save_list") } },
.{ .name = "data-album-create", .area = .data, .kind = .data, .risk = .w, .src = .cfgp, .pkey = "path_albu_main", .need = &.{ .title, .photo }, .steps = &.{ g(), c("albu_newz"), ty("albu_name", .title), up(.photo), cm("albu_subm"), ex(.title) } },
.{ .name = "data-album-delete", .area = .data, .kind = .data, .risk = .x, .src = .cfgp, .pkey = "path_albu_main", .need = &.{.title}, .steps = &.{ g(), cl(.title), c("albu_more"), c("albu_dele"), cf("conf_butt") } },
.{ .name = "data-memories", .area = .data, .kind = .help, .risk = .w, .src = .cfgp, .pkey = "path_memo_main", .rep = true, .need = &.{}, .steps = &.{ g(), exk("memo_list") } },
};
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
