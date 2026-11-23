// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Core jobs the first catalog missed: friend lists, page likes, groups and pages (create, edit, delete), post extras, comment edit and delete, saved, search, story, reel, event edit, Messenger extras, boost
// Flo: rows only; same safety ladder as every job; `url` rows act on the page the owner names
// I/O: none (constants) > ROWS joined into the catalog by ru-jobs-tabl
// ===================================================================
const t = @import("ru-jobs-type.zig"); const Job = t.Job; const g = t.g; const c = t.c; const cm = t.cm; const cf = t.cf; const cl = t.cl; const ty = t.ty; const ck = t.ck; const ex = t.ex; const sl = t.sl; const en = t.en; const tg = t.tg; const hn = t.hn;
pub const ROWS = [_]Job{
.{ .name = "friend-list-add", .kind = .frie, .risk = .w, .src = .cfgp, .pkey = "path_frie_list", .need = &.{.title}, .steps = &.{ g(), c("list_crea"), ty("list_name", .title), cm("list_save"), ex(.title) } },
.{ .name = "friend-close", .kind = .frie, .risk = .w, .src = .url, .need = &.{.url}, .steps = &.{ g(), c("frie_menu"), cm("frie_clos") } },
.{ .name = "friend-close-remove", .kind = .frie, .risk = .w, .src = .url, .need = &.{.url}, .steps = &.{ g(), c("frie_menu"), cm("frie_clor") } },
.{ .name = "friend-cancel", .kind = .frie, .risk = .w, .src = .url, .need = &.{.url}, .steps = &.{ g(), cm("frie_cncl") } },
.{ .name = "page-like", .kind = .reac, .risk = .w, .src = .url, .need = &.{.url}, .steps = &.{ g(), cm("page_like") } },
.{ .name = "page-unlike", .kind = .reac, .risk = .w, .src = .url, .need = &.{.url}, .steps = &.{ g(), cm("page_unli") } },
.{ .name = "group-create", .kind = .grou, .risk = .w, .src = .cfgp, .pkey = "path_grou_crea", .need = &.{.title}, .steps = &.{ g(), ty("grou_name", .title), sl("grou_priv", .opt), cm("grou_crea"), ex(.title) } },
.{ .name = "group-rules", .kind = .admn, .risk = .w, .src = .url, .need = &.{ .url, .text }, .steps = &.{ g(), c("grou_sett"), c("grou_rule"), ty("grou_rtxt", .text), cm("grou_save") } },
.{ .name = "group-question", .kind = .admn, .risk = .w, .src = .url, .need = &.{ .url, .text }, .steps = &.{ g(), c("grou_sett"), c("grou_ques"), ty("grou_qtxt", .text), cm("grou_save") } },
.{ .name = "group-member-remove", .kind = .admn, .risk = .x, .src = .url, .need = &.{ .url, .to }, .steps = &.{ g(), cl(.to), c("gmem_remo"), cf("conf_butt") } },
.{ .name = "group-member-block", .kind = .admn, .risk = .x, .src = .url, .need = &.{ .url, .to }, .steps = &.{ g(), cl(.to), c("gmem_blok"), cf("conf_butt") } },
.{ .name = "page-create", .kind = .admn, .risk = .w, .src = .cfgp, .pkey = "path_page_crea", .need = &.{.title}, .steps = &.{ g(), ty("page_name", .title), ty("page_cate", .opt), cm("page_crea"), ex(.title) } },
.{ .name = "page-edit-info", .kind = .admn, .risk = .w, .src = .url, .need = &.{ .url, .text }, .steps = &.{ g(), c("page_edit"), ck("page_bioz"), ty("page_bioz", .text), cm("page_save") } },
.{ .name = "page-username", .kind = .admn, .risk = .w, .src = .url, .need = &.{ .url, .text }, .steps = &.{ g(), c("page_edit"), ty("page_user", .text), cm("page_save") } },
.{ .name = "page-cta", .kind = .admn, .risk = .w, .src = .url, .need = &.{ .url, .opt }, .steps = &.{ g(), c("page_edit"), sl("page_ctas", .opt), cm("page_save") } },
.{ .name = "page-delete", .kind = .admn, .risk = .x, .src = .url, .need = &.{.url}, .steps = &.{ g(), c("page_sett"), c("page_dele"), cf("conf_butt") } },
.{ .name = "page-unpublish", .kind = .admn, .risk = .x, .src = .url, .need = &.{.url}, .steps = &.{ g(), c("page_sett"), cm("page_unpu"), cf("conf_butt") } },
.{ .name = "page-publish", .kind = .admn, .risk = .w, .src = .url, .need = &.{.url}, .steps = &.{ g(), c("page_sett"), cm("page_publ") } },
.{ .name = "post-tag", .kind = .post, .risk = .w, .src = .cfgp, .pkey = "path_post_comp", .need = &.{ .text, .to }, .steps = &.{ g(), c("post_open"), c("post_tagz"), ty("tag_srch", .to), cl(.to), c("tag_done"), ty("post_boxz", .text), cm("post_subm"), ex(.text) } },
.{ .name = "post-checkin", .kind = .post, .risk = .w, .src = .cfgp, .pkey = "path_post_comp", .need = &.{ .text, .opt }, .steps = &.{ g(), c("post_open"), c("chek_btnz"), ty("chek_srch", .opt), cl(.opt), ty("post_boxz", .text), cm("post_subm"), ex(.text) } },
.{ .name = "post-feeling", .kind = .post, .risk = .w, .src = .cfgp, .pkey = "path_post_comp", .need = &.{ .text, .opt }, .steps = &.{ g(), c("post_open"), sl("feel_btnz", .opt), ty("post_boxz", .text), cm("post_subm"), ex(.text) } },
.{ .name = "post-hide", .kind = .reac, .risk = .w, .src = .url, .need = &.{.url}, .steps = &.{ g(), c("more_menu"), cm("post_hide") } },
.{ .name = "post-report", .kind = .help, .risk = .x, .src = .url, .need = &.{ .url, .opt }, .steps = &.{ g(), c("more_menu"), c("post_repo"), cl(.opt), cm("repo_subm") } },
.{ .name = "post-pin", .kind = .post, .risk = .w, .src = .url, .need = &.{.url}, .steps = &.{ g(), c("more_menu"), cm("post_pinz") } },
.{ .name = "comment-edit", .kind = .comm, .risk = .w, .src = .url, .need = &.{ .url, .text }, .steps = &.{ g(), c("comm_more"), c("comm_edit"), ck("comm_boxz"), ty("comm_boxz", .text), en(), ex(.text) } },
.{ .name = "comment-delete", .kind = .comm, .risk = .x, .src = .url, .need = &.{.url}, .steps = &.{ g(), c("comm_more"), c("comm_dele"), cf("conf_butt") } },
.{ .name = "saved-remove", .kind = .reac, .risk = .w, .src = .cfgp, .pkey = "path_save_main", .each = true, .need = &.{}, .steps = &.{ g(), cm("save_remo") } },
.{ .name = "search", .area = .help, .kind = .help, .risk = .w, .src = .cfgp, .pkey = "path_srch_main", .rep = true, .need = &.{.text}, .steps = &.{ g(), ty("srch_boxz", .text), en(), ex(.text) } },
.{ .name = "story-delete", .kind = .stor, .risk = .x, .src = .cfgp, .pkey = "path_stor_main", .need = &.{}, .steps = &.{ g(), c("stor_more"), c("stor_dele"), cf("conf_butt") } },
.{ .name = "story-highlight", .kind = .stor, .risk = .w, .src = .cfgp, .pkey = "path_stor_main", .need = &.{}, .steps = &.{ g(), cm("stor_high") } },
.{ .name = "reel-delete", .kind = .stor, .risk = .x, .src = .url, .need = &.{.url}, .steps = &.{ g(), c("more_menu"), c("reel_dele"), cf("conf_butt") } },
.{ .name = "event-edit", .kind = .evnt, .risk = .w, .src = .url, .need = &.{ .url, .title }, .steps = &.{ g(), c("evnt_edit"), ck("evnt_name"), ty("evnt_name", .title), cm("evnt_save") } },
.{ .name = "market-boost", .area = .mone, .kind = .mone, .risk = .x, .src = .url, .spend = true, .need = &.{ .url, .price }, .steps = &.{ g(), c("boos_btnz"), ty("ads_budg", .price), hn("ads_done", "Check the boost and budget, then press Boost yourself|Kiểm tra quảng bá và ngân sách rồi tự bấm Quảng bá") } },
.{ .name = "msgr-new", .kind = .dmsg, .risk = .w, .src = .cfgp, .pkey = "path_msgr_new", .need = &.{ .to, .text }, .steps = &.{ g(), ty("msgr_to", .to), cl(.to), ty("msgr_boxz", .text), en() } },
.{ .name = "msgr-mute", .kind = .dmsg, .risk = .w, .src = .dmsg_thre, .need = &.{.to}, .steps = &.{ g(), c("msgr_info"), cm("msgr_mute") } },
.{ .name = "msgr-nick", .kind = .dmsg, .risk = .w, .src = .dmsg_thre, .need = &.{ .to, .text }, .steps = &.{ g(), c("msgr_info"), c("msgr_nick"), ty("nick_boxz", .text), cm("nick_save") } },
.{ .name = "msgr-vanish", .kind = .dmsg, .risk = .w, .src = .dmsg_thre, .need = &.{.to}, .steps = &.{ g(), c("msgr_info"), tg("msgr_vani", .opt) } },
.{ .name = "msgr-block", .kind = .dmsg, .risk = .x, .src = .dmsg_thre, .need = &.{.to}, .steps = &.{ g(), c("msgr_info"), c("msgr_blok"), cf("conf_butt") } },
.{ .name = "msgr-delete", .kind = .dmsg, .risk = .x, .src = .dmsg_thre, .need = &.{.to}, .steps = &.{ g(), c("msgr_info"), c("msgr_dele"), cf("conf_butt") } },
};
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
