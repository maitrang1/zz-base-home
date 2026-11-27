// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Job rows: compute, network, storage, database, shell, usage data
// Flo: one row per Oracle console action > steps name a label key (ut-loca-pack) and an argument slot
// I/O: none (constants) > []Job (joined in ru-jobs-tabl)
// ===================================================================
const t = @import("ru-jobs-type.zig"); const Job = t.Job; const g = t.g; const c = t.c; const cm = t.cm; const cf = t.cf; const cl = t.cl; const ty = t.ty; const up = t.up; const ex = t.ex; const ek = t.ek; const en = t.en;
pub const ROWS = [_]Job{
.{ .name = "inst-list", .kind = .prod, .risk = .w, .host = .app, .path = "p_inst", .need = &.{}, .hint = "list the compute instances", .steps = &.{ g(), ek("inst_head") } },
.{ .name = "inst-view", .kind = .prod, .risk = .w, .host = .app, .path = "p_inst", .need = &.{.title}, .hint = "open one instance: state, IP, shape (--title name)", .steps = &.{ g(), cl(.title), ek("inst_dtal") } },
.{ .name = "inst-create", .kind = .prod, .risk = .x, .host = .app, .path = "p_inst", .need = &.{ .title, .opt, .text }, .hint = "create an instance (--title name, --opt shape, --text ssh public key); 'out of host capacity' = retry later by hand", .steps = &.{ g(), c("inst_newz"), ty("inst_name", .title), c("shap_chng"), cl(.opt), c("shap_pick"), ty("sshk_body", .text), cm("inst_crea"), ek("inst_prov") } },
.{ .name = "inst-start", .kind = .prod, .risk = .w, .host = .app, .path = "p_inst", .need = &.{.title}, .hint = "start a stopped instance (--title name)", .steps = &.{ g(), cl(.title), cm("inst_star"), ek("inst_runn") } },
.{ .name = "inst-stop", .kind = .prod, .risk = .x, .host = .app, .path = "p_inst", .need = &.{.title}, .hint = "stop an instance (--title name); what runs on it stops", .steps = &.{ g(), cl(.title), c("inst_stop"), cf("stop_conf"), ek("inst_stpd") } },
.{ .name = "inst-reboot", .kind = .prod, .risk = .x, .host = .app, .path = "p_inst", .need = &.{.title}, .hint = "reboot an instance (--title name)", .steps = &.{ g(), cl(.title), c("inst_rebo"), cf("rebo_conf"), ek("inst_rbtd") } },
.{ .name = "inst-drop", .kind = .prod, .risk = .x, .host = .app, .path = "p_inst", .need = &.{.title}, .hint = "terminate an instance for good (--title name)", .steps = &.{ g(), cl(.title), c("inst_term"), cf("dele_conf"), ek("dele_done") } },
.{ .name = "vcn-list", .kind = .prod, .risk = .w, .host = .app, .path = "p_vcns", .need = &.{}, .hint = "list the virtual networks", .steps = &.{ g(), ek("vcnz_head") } },
.{ .name = "vcn-create", .kind = .prod, .risk = .w, .host = .app, .path = "p_vcns", .need = &.{.title}, .hint = "create a network with internet access (--title name)", .steps = &.{ g(), c("vcnz_newz"), c("vcnz_wiza"), ty("vcnz_name", .title), c("wiza_next"), cm("vcnz_crea"), ek("vcnz_done") } },
.{ .name = "vcn-drop", .kind = .prod, .risk = .x, .host = .app, .path = "p_vcns", .need = &.{.title}, .hint = "delete a network (--title name)", .steps = &.{ g(), cl(.title), c("vcnz_term"), cf("dele_conf"), ek("dele_done") } },
.{ .name = "secl-view", .kind = .prod, .risk = .w, .host = .app, .path = "p_vcns", .need = &.{.title}, .hint = "show a network's security lists, to check no port is open (--title name)", .steps = &.{ g(), cl(.title), c("secl_tabz"), ek("secl_head") } },
.{ .name = "rule-add", .kind = .prod, .risk = .x, .host = .app, .path = "p_vcns", .need = &.{ .title, .text, .opt }, .hint = "open a port: add an ingress rule (--title network, --text source CIDR, --opt port)", .steps = &.{ g(), cl(.title), c("secl_tabz"), c("secl_defa"), c("rule_addz"), ty("rule_cidr", .text), ty("rule_port", .opt), cm("rule_save"), ek("rule_done") } },
.{ .name = "ip-reserve", .kind = .prod, .risk = .w, .host = .app, .path = "p_ipzz", .need = &.{.title}, .hint = "reserve a public IP (--title name)", .steps = &.{ g(), c("ipzz_newz"), ty("ipzz_name", .title), cm("ipzz_save"), ek("ipzz_done") } },
.{ .name = "vol-list", .kind = .prod, .risk = .w, .host = .app, .path = "p_volu", .need = &.{}, .hint = "list the block volumes", .steps = &.{ g(), ek("volu_head") } },
.{ .name = "vol-create", .kind = .prod, .risk = .x, .host = .app, .path = "p_volu", .need = &.{ .title, .price }, .hint = "create a block volume (--title name, --price size in GB; free tier total 200 GB)", .steps = &.{ g(), c("volu_newz"), ty("volu_name", .title), ty("volu_size", .price), cm("volu_crea"), ek("volu_done") } },
.{ .name = "vol-drop", .kind = .prod, .risk = .x, .host = .app, .path = "p_volu", .need = &.{.title}, .hint = "delete a block volume (--title name)", .steps = &.{ g(), cl(.title), c("volu_term"), cf("dele_conf"), ek("dele_done") } },
.{ .name = "bucket-list", .kind = .prod, .risk = .w, .host = .app, .path = "p_bkts", .need = &.{}, .hint = "list the storage buckets", .steps = &.{ g(), ek("bkts_head") } },
.{ .name = "bucket-create", .kind = .prod, .risk = .w, .host = .app, .path = "p_bkts", .need = &.{.title}, .hint = "create a bucket (--title name)", .steps = &.{ g(), c("bkts_newz"), ty("bkts_name", .title), cm("bkts_crea"), ek("bkts_done") } },
.{ .name = "bucket-drop", .kind = .prod, .risk = .x, .host = .app, .path = "p_bkts", .need = &.{.title}, .hint = "delete an empty bucket (--title name)", .steps = &.{ g(), cl(.title), c("bkts_term"), cf("dele_conf"), ek("dele_done") } },
.{ .name = "obj-list", .kind = .prod, .risk = .w, .host = .app, .path = "p_bkts", .need = &.{.title}, .hint = "list the files in a bucket (--title bucket)", .steps = &.{ g(), cl(.title), ek("objs_head") } },
.{ .name = "obj-upload", .kind = .prod, .risk = .w, .host = .app, .path = "p_bkts", .need = &.{ .title, .photo }, .hint = "upload a file (--title bucket, --photo file path)", .steps = &.{ g(), cl(.title), c("objz_upld"), up(.photo), cm("objz_conf"), ek("objz_done") } },
.{ .name = "adb-list", .kind = .prod, .risk = .w, .host = .app, .path = "p_adbs", .need = &.{}, .hint = "list the autonomous databases", .steps = &.{ g(), ek("adbs_head") } },
.{ .name = "adb-start", .kind = .prod, .risk = .w, .host = .app, .path = "p_adbs", .need = &.{.title}, .hint = "start a database (--title name)", .steps = &.{ g(), cl(.title), cm("adbs_star"), ek("adbs_runn") } },
.{ .name = "adb-stop", .kind = .prod, .risk = .x, .host = .app, .path = "p_adbs", .need = &.{.title}, .hint = "stop a database (--title name)", .steps = &.{ g(), cl(.title), c("adbs_stop"), cf("stop_conf"), ek("adbs_stpd") } },
.{ .name = "shell-open", .kind = .prod, .risk = .w, .host = .app, .path = "p_home", .need = &.{}, .hint = "open the Cloud Shell (you type in it)", .steps = &.{ g(), c("shel_open"), ek("shel_prom") } },
.{ .name = "usage-view", .kind = .data, .risk = .w, .host = .app, .path = "p_cost", .need = &.{}, .hint = "show cost and usage", .steps = &.{ g(), ek("cost_head") } },
.{ .name = "limits-view", .kind = .data, .risk = .w, .host = .app, .path = "p_limi", .need = &.{}, .hint = "show service limits and what you use", .steps = &.{ g(), ek("limi_head") } },
.{ .name = "limits-find", .kind = .data, .risk = .w, .host = .app, .path = "p_limi", .need = &.{.text}, .hint = "find one limit, e.g. A1 cores (--text words)", .steps = &.{ g(), ty("limi_srch", .text), en(), ex(.text) } },
.{ .name = "metrics-view", .kind = .data, .risk = .w, .host = .app, .path = "p_inst", .need = &.{.title}, .hint = "show an instance's CPU and network charts, for the idle check (--title name)", .steps = &.{ g(), cl(.title), c("moni_tabz"), ek("moni_cpuz") } },
.{ .name = "audit-view", .kind = .data, .risk = .w, .host = .app, .path = "p_audi", .need = &.{}, .hint = "show the audit log", .steps = &.{ g(), ek("audi_head") } },
.{ .name = "report-export", .kind = .data, .risk = .w, .host = .app, .path = "p_cost", .need = &.{}, .hint = "export the cost report", .steps = &.{ g(), cm("expo_butt"), ek("expo_done") } },
};
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
