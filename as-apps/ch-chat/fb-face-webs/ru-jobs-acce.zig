// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Access and team jobs as data rows
// Flo: rows only; every change is guarded (needs approval) and uses the admin cap; app secrets and tokens are never read or stored
// I/O: none (constants) > ROWS joined into the catalog by ru-jobs-tabl
// ===================================================================
const t = @import("ru-jobs-type.zig"); const Job = t.Job; const g = t.g; const c = t.c; const cm = t.cm; const cf = t.cf; const cl = t.cl; const ty = t.ty; const exk = t.exk; const sl = t.sl; const hn = t.hn;
pub const ROWS = [_]Job{
.{ .name = "acce-roles-list", .area = .acce, .kind = .help, .risk = .w, .src = .cfgp, .pkey = "pbiz_role_main", .rep = true, .need = &.{}, .steps = &.{ g(), exk("role_list") } },
.{ .name = "acce-role-add", .area = .acce, .kind = .admn, .risk = .x, .src = .cfgp, .pkey = "pbiz_role_main", .rep = true, .need = &.{ .to, .opt }, .steps = &.{ g(), c("role_addz"), ty("role_srch", .to), cl(.to), sl("role_sele", .opt), cm("role_send") } },
.{ .name = "acce-role-change", .area = .acce, .kind = .admn, .risk = .x, .src = .cfgp, .pkey = "pbiz_role_main", .rep = true, .need = &.{ .to, .opt }, .steps = &.{ g(), cl(.to), sl("role_sele", .opt), cm("role_save") } },
.{ .name = "acce-role-remove", .area = .acce, .kind = .admn, .risk = .x, .src = .cfgp, .pkey = "pbiz_role_main", .rep = true, .need = &.{.to}, .steps = &.{ g(), cl(.to), c("role_remo"), cf("conf_butt") } },
.{ .name = "acce-people-add", .area = .acce, .kind = .admn, .risk = .x, .src = .cfgp, .pkey = "pbiz_peop_main", .rep = true, .need = &.{ .to, .opt }, .steps = &.{ g(), c("role_addz"), ty("role_srch", .to), cl(.to), sl("role_sele", .opt), cm("role_send") } },
.{ .name = "acce-people-remove", .area = .acce, .kind = .admn, .risk = .x, .src = .cfgp, .pkey = "pbiz_peop_main", .rep = true, .need = &.{.to}, .steps = &.{ g(), cl(.to), c("role_remo"), cf("conf_butt") } },
.{ .name = "acce-adrole-add", .area = .acce, .kind = .admn, .risk = .x, .src = .cfgp, .pkey = "pbiz_adro_main", .rep = true, .need = &.{ .to, .opt }, .steps = &.{ g(), c("role_addz"), ty("role_srch", .to), cl(.to), sl("role_sele", .opt), cm("role_send") } },
.{ .name = "acce-adrole-remove", .area = .acce, .kind = .admn, .risk = .x, .src = .cfgp, .pkey = "pbiz_adro_main", .rep = true, .need = &.{.to}, .steps = &.{ g(), cl(.to), c("role_remo"), cf("conf_butt") } },
.{ .name = "acce-partner-add", .area = .acce, .kind = .admn, .risk = .x, .src = .cfgp, .pkey = "pbiz_part_main", .rep = true, .need = &.{.text}, .steps = &.{ g(), c("part_addz"), ty("part_idzz", .text), cm("part_send") } },
.{ .name = "acce-partner-remove", .area = .acce, .kind = .admn, .risk = .x, .src = .cfgp, .pkey = "pbiz_part_main", .rep = true, .need = &.{.text}, .steps = &.{ g(), cl(.text), c("part_remo"), cf("conf_butt") } },
.{ .name = "acce-group-admin", .area = .acce, .kind = .admn, .risk = .x, .src = .url, .rep = true, .need = &.{ .url, .to }, .steps = &.{ g(), cl(.to), c("gadm_mkad"), cf("conf_butt") } },
.{ .name = "acce-group-mod", .area = .acce, .kind = .admn, .risk = .x, .src = .url, .rep = true, .need = &.{ .url, .to }, .steps = &.{ g(), cl(.to), c("gadm_mkmo"), cf("conf_butt") } },
.{ .name = "acce-group-demote", .area = .acce, .kind = .admn, .risk = .x, .src = .url, .rep = true, .need = &.{ .url, .to }, .steps = &.{ g(), cl(.to), c("gadm_demo"), cf("conf_butt") } },
.{ .name = "acce-dev-apps", .area = .acce, .kind = .help, .risk = .w, .src = .cfgp, .pkey = "pdev_apps_main", .rep = true, .need = &.{}, .steps = &.{ g(), exk("deve_apps") } },
.{ .name = "acce-dev-hooks", .area = .acce, .kind = .help, .risk = .w, .src = .cfgp, .pkey = "pdev_hook_main", .rep = true, .need = &.{}, .steps = &.{ g(), exk("deve_hook") } },
.{ .name = "acce-dev-hook-add", .area = .acce, .kind = .admn, .risk = .x, .src = .cfgp, .pkey = "pdev_hook_main", .rep = true, .need = &.{.url}, .steps = &.{ g(), c("hook_addz"), ty("hook_urlz", .url), hn("hook_done", "Enter the verify token yourself, then save|Tự nhập mã xác minh rồi lưu") } },
.{ .name = "acce-conn-list", .area = .acce, .kind = .help, .risk = .w, .src = .cfgp, .pkey = "pbiz_conn_main", .rep = true, .need = &.{}, .steps = &.{ g(), exk("conn_list") } },
.{ .name = "acce-conn-remove", .area = .acce, .kind = .admn, .risk = .x, .src = .cfgp, .pkey = "pbiz_conn_main", .rep = true, .need = &.{.to}, .steps = &.{ g(), cl(.to), c("conn_remo"), cf("conf_butt") } },
};
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
