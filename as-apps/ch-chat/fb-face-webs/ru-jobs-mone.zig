// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Money jobs as data: billing, invoices, payment methods, Meta Verified, ads (read, pause, resume, budget, create, boost), plans
// Flo: rows only; cap `mone` is 0 until the owner sets it; every spend row checks mone_spen_capz; card entry, payment and final publish are owner steps (class H)
// I/O: none (constants) > ROWS joined into the catalog by ru-jobs-tabl
// ===================================================================
const t = @import("ru-jobs-type.zig"); const Job = t.Job; const g = t.g; const c = t.c; const cm = t.cm; const cf = t.cf; const ty = t.ty; const ck = t.ck; const exk = t.exk; const tgl = t.tgl; const hn = t.hn;
pub const ROWS = [_]Job{
.{ .name = "mone-billing", .area = .mone, .kind = .help, .risk = .w, .src = .cfgp, .pkey = "pbiz_bill_main", .rep = true, .need = &.{}, .steps = &.{ g(), exk("bill_main") } },
.{ .name = "mone-invoices", .area = .mone, .kind = .data, .risk = .w, .src = .cfgp, .pkey = "pbiz_bill_main", .rep = true, .dl = true, .need = &.{}, .steps = &.{ g(), c("invo_tabz"), cm("invo_down") } },
.{ .name = "mone-paymethod-add", .area = .mone, .kind = .mone, .risk = .x, .src = .cfgp, .pkey = "pbiz_paym_main", .rep = true, .need = &.{}, .steps = &.{ g(), c("paym_addz"), hn("paym_done", "Type your card details yourself, then save|Tự nhập thông tin thẻ rồi lưu") } },
.{ .name = "mone-paymethod-remove", .area = .mone, .kind = .mone, .risk = .x, .src = .cfgp, .pkey = "pbiz_paym_main", .rep = true, .need = &.{}, .steps = &.{ g(), c("paym_remo"), cf("conf_butt") } },
.{ .name = "mone-verified-status", .area = .mone, .kind = .help, .risk = .w, .src = .cfgp, .pkey = "pbiz_veri_main", .rep = true, .need = &.{}, .steps = &.{ g(), exk("veri_main") } },
.{ .name = "mone-verified-subscribe", .area = .mone, .kind = .mone, .risk = .x, .src = .cfgp, .pkey = "pbiz_veri_main", .rep = true, .need = &.{}, .steps = &.{ g(), c("veri_subs"), hn("veri_done", "Check the price and pay yourself|Tự xem giá và thanh toán") } },
.{ .name = "mone-verified-cancel", .area = .mone, .kind = .mone, .risk = .x, .src = .cfgp, .pkey = "pbiz_veri_main", .rep = true, .need = &.{}, .steps = &.{ g(), c("veri_canc"), cf("conf_butt") } },
.{ .name = "mone-ads-read", .area = .mone, .kind = .help, .risk = .w, .src = .cfgp, .pkey = "pbiz_adsz_main", .rep = true, .need = &.{}, .steps = &.{ g(), exk("adsz_main") } },
.{ .name = "mone-ads-pause", .area = .mone, .kind = .admn, .risk = .w, .src = .cfgp, .pkey = "pbiz_adsz_main", .rep = true, .need = &.{}, .steps = &.{ g(), tgl("adsz_togg", "off") } },
.{ .name = "mone-ads-resume", .area = .mone, .kind = .mone, .risk = .x, .src = .cfgp, .pkey = "pbiz_adsz_main", .rep = true, .need = &.{}, .steps = &.{ g(), tgl("adsz_togg", "on") } },
.{ .name = "mone-ads-budget", .area = .mone, .kind = .mone, .risk = .x, .src = .cfgp, .pkey = "pbiz_adsz_main", .rep = true, .spend = true, .need = &.{.price}, .steps = &.{ g(), c("adsz_edit"), ck("adsz_budg"), ty("adsz_budg", .price), cm("adsz_save") } },
.{ .name = "mone-ads-create", .area = .mone, .kind = .mone, .risk = .x, .src = .cfgp, .pkey = "pbiz_adsz_main", .spend = true, .need = &.{ .title, .price }, .steps = &.{ g(), c("adsz_crea"), ty("adsz_name", .title), ty("adsz_budg", .price), hn("adsz_done", "Check the ad and budget, then press Publish yourself|Kiểm tra quảng cáo và ngân sách rồi tự bấm Đăng") } },
.{ .name = "mone-ads-boost", .area = .mone, .kind = .mone, .risk = .x, .src = .url, .spend = true, .need = &.{ .url, .price }, .steps = &.{ g(), c("boos_btnz"), ty("adsz_budg", .price), hn("adsz_done", "Check the boost and budget, then press Boost yourself|Kiểm tra quảng bá và ngân sách rồi tự bấm Quảng bá") } },
.{ .name = "mone-plan-view", .area = .mone, .kind = .help, .risk = .w, .src = .cfgp, .pkey = "pbiz_plan_main", .rep = true, .need = &.{}, .steps = &.{ g(), exk("plan_main") } },
};
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
