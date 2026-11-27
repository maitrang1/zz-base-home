// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Job rows: account, access, billing, settings, help
// Flo: one row per Oracle console action > steps name a label key (ut-loca-pack) and an argument slot
// I/O: none (constants) > []Job (joined in ru-jobs-tabl)
// ===================================================================
const t = @import("ru-jobs-type.zig"); const Job = t.Job; const g = t.g; const c = t.c; const cm = t.cm; const cf = t.cf; const cl = t.cl; const ty = t.ty; const ck = t.ck; const ex = t.ex; const ek = t.ek; const sl = t.sl; const tg = t.tg; const en = t.en;
pub const ROWS = [_]Job{
.{ .name = "signup", .kind = .acct, .risk = .w, .host = .www, .path = "p_regi", .auth = true, .once = true, .need = &.{}, .hint = "OPTIONAL: fill the Free Tier sign-up form (--title first name, --desc last name, --opt country); Oracle then emails you a link", .steps = &.{ g(), ty("emai_boxz", .user), ty("name_firs", .title), ty("name_last", .desc), sl("coun_pick", .opt), cm("regi_subm"), ek("veri_sent") } },
.{ .name = "verify-email", .kind = .acct, .risk = .w, .host = .www, .path = "", .auth = true, .need = &.{.url}, .hint = "open the link from the Oracle email (--url full link)", .steps = &.{g(), ek("setu_page")} },
.{ .name = "signup-setup", .kind = .acct, .risk = .x, .host = .www, .path = "p_setu", .auth = true, .once = true, .need = &.{.opt}, .hint = "set password, cloud account name and HOME REGION (--opt region; permanent). Card + phone check stay yours", .steps = &.{ g(), ty("pass_boxz", .pass), ty("pass_conf", .pass), ty("tena_boxz", .tena), sl("regi_home", .opt), cm("setu_subm"), ek("card_page") } },
.{ .name = "login", .kind = .acct, .risk = .w, .host = .app, .path = "p_logi", .auth = true, .need = &.{}, .hint = "OPTIONAL: fill the console login (cloud account name from config tena_name_main); prefer or-orac-webs login by hand", .steps = &.{ g(), ty("tena_boxz", .tena), c("tena_next"), ty("emai_boxz", .user), ty("pass_boxz", .pass), cm("logi_subm"), ek("cons_home") } },
.{ .name = "logout", .kind = .acct, .risk = .w, .host = .app, .path = "p_home", .auth = true, .need = &.{}, .hint = "sign out of the console", .steps = &.{ g(), c("user_menu"), cm("logo_butt"), ek("logi_page") } },
.{ .name = "sso-start", .kind = .acct, .risk = .w, .host = .app, .path = "p_logi", .auth = true, .need = &.{}, .hint = "start single sign-on (you finish it in the window)", .steps = &.{ g(), cm("ssoz_butt") } },
.{ .name = "reset-pass", .kind = .acct, .risk = .w, .host = .app, .path = "p_logi", .auth = true, .need = &.{}, .hint = "send the password reset email", .steps = &.{ g(), c("forg_link"), ty("emai_boxz", .user), cm("rese_subm"), ek("rese_sent") } },
.{ .name = "pass-change", .kind = .sett, .risk = .x, .host = .app, .path = "p_secu", .need = &.{.opt}, .hint = "change the console password (--opt new password)", .steps = &.{ g(), ty("pass_curr", .pass), ty("pass_newz", .opt), cm("pass_save"), ek("save_done") } },
.{ .name = "mfa-on", .kind = .sett, .risk = .w, .host = .app, .path = "p_secu", .need = &.{}, .hint = "turn multi-factor sign-in on (you scan the code)", .steps = &.{ g(), tg("mfaz_togl", "on") } },
.{ .name = "mfa-off", .kind = .sett, .risk = .x, .host = .app, .path = "p_secu", .need = &.{}, .hint = "turn multi-factor sign-in off", .steps = &.{ g(), tg("mfaz_togl", "off") } },
.{ .name = "profile-view", .kind = .acct, .risk = .w, .host = .app, .path = "p_prof", .need = &.{}, .hint = "show your user profile", .steps = &.{ g(), ek("prof_head") } },
.{ .name = "tenancy-view", .kind = .acct, .risk = .w, .host = .app, .path = "p_tena", .need = &.{}, .hint = "show tenancy details: name, home region", .steps = &.{ g(), ek("tena_head") } },
.{ .name = "region-subscribe", .kind = .acct, .risk = .x, .host = .app, .path = "p_regs", .once = true, .need = &.{.opt}, .hint = "subscribe to one more region (--opt region; cannot be undone)", .steps = &.{ g(), c("regi_mana"), cl(.opt), cf("regi_subs"), ek("regi_done") } },
.{ .name = "tenancy-close", .kind = .acct, .risk = .x, .host = .app, .path = "p_tena", .once = true, .need = &.{}, .hint = "terminate the whole account for good", .steps = &.{ g(), c("tena_term"), cf("term_conf"), ek("term_done") } },
.{ .name = "key-create", .kind = .acce, .risk = .w, .host = .app, .path = "p_apik", .need = &.{.text}, .hint = "add an API signing key (--text public key PEM)", .steps = &.{ g(), c("apik_addz"), c("apik_past"), ty("apik_body", .text), cm("apik_save"), ek("apik_done") } },
.{ .name = "key-list", .kind = .acce, .risk = .w, .host = .app, .path = "p_apik", .need = &.{}, .hint = "list your API keys and fingerprints", .steps = &.{ g(), ek("apik_head") } },
.{ .name = "key-revoke", .kind = .acce, .risk = .x, .host = .app, .path = "p_apik", .need = &.{}, .hint = "delete the first API key", .steps = &.{ g(), c("acti_menu"), c("apik_dele"), cf("dele_conf"), ek("dele_done") } },
.{ .name = "user-list", .kind = .acce, .risk = .w, .host = .app, .path = "p_user", .need = &.{}, .hint = "list the users", .steps = &.{ g(), ek("user_head") } },
.{ .name = "user-invite", .kind = .acce, .risk = .x, .host = .app, .path = "p_user", .need = &.{.to}, .hint = "create a user and mail the invite (--to email, --opt group)", .steps = &.{ g(), c("user_newz"), ty("emai_boxz", .to), sl("grup_pick", .opt), cm("invi_send"), ek("invi_done") } },
.{ .name = "user-drop", .kind = .acce, .risk = .x, .host = .app, .path = "p_user", .need = &.{.to}, .hint = "delete a user (--to email)", .steps = &.{ g(), cl(.to), c("acti_menu"), c("user_dele"), cf("dele_conf"), ek("dele_done") } },
.{ .name = "group-list", .kind = .acce, .risk = .w, .host = .app, .path = "p_grup", .need = &.{}, .hint = "list the groups", .steps = &.{ g(), ek("grup_head") } },
.{ .name = "policy-list", .kind = .acce, .risk = .w, .host = .app, .path = "p_poli", .need = &.{}, .hint = "list the access policies", .steps = &.{ g(), ek("poli_head") } },
.{ .name = "policy-create", .kind = .acce, .risk = .x, .host = .app, .path = "p_poli", .need = &.{ .title, .text }, .hint = "create an access policy (--title name, --text statement)", .steps = &.{ g(), c("poli_newz"), ty("poli_name", .title), ty("poli_body", .text), cm("poli_save"), ek("poli_done") } },
.{ .name = "policy-drop", .kind = .acce, .risk = .x, .host = .app, .path = "p_poli", .need = &.{.title}, .hint = "delete an access policy (--title name)", .steps = &.{ g(), cl(.title), c("acti_menu"), c("poli_dele"), cf("dele_conf"), ek("dele_done") } },
.{ .name = "comp-list", .kind = .acce, .risk = .w, .host = .app, .path = "p_comp", .need = &.{}, .hint = "list the compartments", .steps = &.{ g(), ek("comp_head") } },
.{ .name = "comp-create", .kind = .acce, .risk = .w, .host = .app, .path = "p_comp", .need = &.{.title}, .hint = "create a compartment (--title name)", .steps = &.{ g(), c("comp_newz"), ty("comp_name", .title), cm("comp_save"), ek("comp_done") } },
.{ .name = "plan-view", .kind = .mone, .risk = .w, .host = .app, .path = "p_cred", .need = &.{}, .hint = "show free-trial credits, plan and expiry", .steps = &.{ g(), ek("cred_head") } },
.{ .name = "payg-upgrade", .kind = .mone, .risk = .x, .host = .app, .path = "p_upgr", .once = true, .need = &.{}, .hint = "upgrade to Pay As You Go (money; you enter the card)", .steps = &.{ g(), c("upgr_butt"), cf("upgr_conf"), ek("upgr_done") } },
.{ .name = "payment-open", .kind = .mone, .risk = .x, .host = .app, .path = "p_paym", .need = &.{}, .hint = "open the card form (you type the card)", .steps = &.{ g(), c("paym_edit") } },
.{ .name = "invoice-list", .kind = .mone, .risk = .w, .host = .app, .path = "p_invo", .need = &.{}, .hint = "list your invoices and balance", .steps = &.{ g(), ek("invo_head") } },
.{ .name = "invoice-get", .kind = .mone, .risk = .w, .host = .app, .path = "p_invo", .need = &.{}, .hint = "download the latest invoice", .steps = &.{ g(), cm("invo_down") } },
.{ .name = "bill-pay", .kind = .mone, .risk = .x, .host = .app, .path = "p_invo", .need = &.{}, .hint = "pay the open balance now", .steps = &.{ g(), c("payz_nowz"), cf("payz_conf"), ek("payz_done") } },
.{ .name = "budget-list", .kind = .sett, .risk = .w, .host = .app, .path = "p_budg", .need = &.{}, .hint = "list the budgets", .steps = &.{ g(), ek("budg_head") } },
.{ .name = "budget-create", .kind = .sett, .risk = .w, .host = .app, .path = "p_budg", .need = &.{ .title, .price }, .hint = "create a monthly budget (--title name, --price amount)", .steps = &.{ g(), c("budg_newz"), ty("budg_name", .title), ty("budg_amnt", .price), cm("budg_save"), ek("budg_done") } },
.{ .name = "budget-alert", .kind = .sett, .risk = .w, .host = .app, .path = "p_budg", .need = &.{ .title, .price, .to }, .hint = "add an alert rule (--title budget, --price percent, --to email)", .steps = &.{ g(), cl(.title), c("alrt_newz"), ty("alrt_thre", .price), ty("alrt_emai", .to), cm("alrt_save"), ek("alrt_done") } },
.{ .name = "budget-drop", .kind = .sett, .risk = .x, .host = .app, .path = "p_budg", .need = &.{.title}, .hint = "delete a budget (--title name)", .steps = &.{ g(), cl(.title), c("acti_menu"), c("budg_dele"), cf("dele_conf"), ek("dele_done") } },
.{ .name = "prefs-view", .kind = .sett, .risk = .w, .host = .app, .path = "p_pref", .need = &.{}, .hint = "show the preferences page", .steps = &.{ g(), ek("pref_head") } },
.{ .name = "secu-view", .kind = .sett, .risk = .w, .host = .app, .path = "p_secu", .need = &.{}, .hint = "show the security page", .steps = &.{ g(), ek("secu_head") } },
.{ .name = "docs-open", .kind = .help, .risk = .w, .host = .docs, .path = "p_docs", .need = &.{}, .hint = "open the Oracle docs", .steps = &.{ g(), ek("docs_head") } },
.{ .name = "docs-search", .kind = .help, .risk = .w, .host = .docs, .path = "p_docs", .need = &.{.text}, .hint = "search the docs (--text words)", .steps = &.{ g(), ty("docs_srch", .text), en(), ex(.text) } },
.{ .name = "support-send", .kind = .help, .risk = .w, .host = .app, .path = "p_supp", .need = &.{ .title, .text }, .hint = "open a support request (--title subject, --text details)", .steps = &.{ g(), ty("supp_subj", .title), ty("supp_body", .text), cm("supp_send"), ek("supp_done") } },
.{ .name = "feedback-send", .kind = .help, .risk = .w, .host = .app, .path = "p_feed", .need = &.{.text}, .hint = "send feedback to Oracle (--text)", .steps = &.{ g(), ty("supp_body", .text), cm("supp_send"), ek("supp_done") } },
.{ .name = "page-open", .kind = .help, .risk = .w, .host = .app, .path = "", .need = &.{.url}, .hint = "open any console page by path or URL (--url)", .steps = &.{g()} },
};
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
