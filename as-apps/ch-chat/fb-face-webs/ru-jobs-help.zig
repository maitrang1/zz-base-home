// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Help and support jobs as data rows
// Flo: rows only; sending text to Meta is guarded (needs approval) and uses the help cap
// I/O: none (constants) > ROWS joined into the catalog by ru-jobs-tabl
// ===================================================================
const t = @import("ru-jobs-type.zig"); const Job = t.Job; const g = t.g; const c = t.c; const cm = t.cm; const ty = t.ty; const exk = t.exk; const en = t.en;
pub const ROWS = [_]Job{
.{ .name = "help-search", .area = .help, .kind = .help, .risk = .w, .src = .cfgp, .pkey = "path_help_main", .rep = true, .need = &.{.text}, .steps = &.{ g(), ty("help_srch", .text), en(), exk("help_resu") } },
.{ .name = "help-open", .area = .help, .kind = .help, .risk = .w, .src = .cfgp, .pkey = "path_help_main", .rep = true, .need = &.{}, .steps = &.{ g(), exk("help_main") } },
.{ .name = "supp-inbox", .area = .help, .kind = .help, .risk = .w, .src = .cfgp, .pkey = "path_supp_inbx", .rep = true, .need = &.{}, .steps = &.{ g(), exk("supp_main") } },
.{ .name = "supp-report", .area = .help, .kind = .help, .risk = .x, .src = .cfgp, .pkey = "path_supp_inbx", .rep = true, .need = &.{.text}, .steps = &.{ g(), c("supp_repo"), ty("supp_boxz", .text), cm("supp_send"), exk("supp_done") } },
.{ .name = "supp-feedback", .area = .help, .kind = .help, .risk = .x, .src = .cfgp, .pkey = "path_supp_inbx", .rep = true, .need = &.{.text}, .steps = &.{ g(), c("supp_feed"), ty("supp_boxz", .text), cm("supp_send"), exk("supp_done") } },
.{ .name = "supp-contact", .area = .help, .kind = .help, .risk = .x, .src = .cfgp, .pkey = "path_supp_inbx", .rep = true, .need = &.{.text}, .steps = &.{ g(), c("supp_cont"), ty("supp_boxz", .text), cm("supp_send"), exk("supp_done") } },
};
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
