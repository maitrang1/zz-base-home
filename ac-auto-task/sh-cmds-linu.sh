# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Auto-run dispatcher for tasks with no run line (Unix)
# Flo: read task id > load aa-conf-main.env > run its command via one case line > else exit 2
# I/O: task id (argv 1, from the scheduler) + optional aa-conf-main.env (CMDS_MISE, WO_DEVI_NAME) > command exit code, or stderr + exit 2
# Run: bash "~/zz-base-home/ac-auto-task/sh-cmds-linu.sh" <task-id>
# ===================================================================
dirz=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd); R=$(cd "$dirz/.." && pwd); WOZ=$R/as-apps/os-syst/wo-work-mode/zig-out/bin/wo; SSS=$R/as-apps/os-syst/ss-star-shut
if [[ -r $dirz/aa-conf-main.env ]]; then while IFS='=' read -r key val; do case $key in CMDS_MISE) [[ -n ${CMDS_MISE-} ]] || CMDS_MISE=$val ;; WO_DEVI_NAME) [[ -n ${WO_DEVI_NAME-} ]] || WO_DEVI_NAME=$val ;; esac; done < "$dirz/aa-conf-main.env"; fi
[[ -n ${CMDS_MISE-} ]] || { command -v mise >/dev/null 2>&1 && CMDS_MISE=mise || CMDS_MISE=$HOME/.local/bin/mise; }
[[ -z ${WO_DEVI_NAME-} ]] || export WO_DEVI_NAME
cd "$R" || exit 1
case "$1" in
home-wipz) exec "$CMDS_MISE" exec -- "$WOZ" wipz --live ;;
home-docs) exec "$CMDS_MISE" exec -- "$WOZ" docs sync --live ;;
home-code) exec "$CMDS_MISE" exec -- "$WOZ" sync --live ;;
home-beat) exec "$CMDS_MISE" exec -- "$WOZ" beat --live ;;
home-bkup-stat) exec "$CMDS_MISE" exec -- "$WOZ" bkup stat --live ;;
home-bkup-nigh) exec "$CMDS_MISE" exec -- "$WOZ" bkup nigh --live ;;
home-doct) exec "$CMDS_MISE" exec -- "$WOZ" doct ;;
home-dril) exec "$CMDS_MISE" exec -- "$WOZ" dril --live ;;
cicd-stat) exec "$CMDS_MISE" exec -- "$WOZ" ci stat ;;
cicd-rele) exec "$CMDS_MISE" exec -- "$WOZ" ci rele ;;
cicd-test) exec "$CMDS_MISE" exec -- "$WOZ" ci test ;;
cicd-leak) exec "$CMDS_MISE" exec -- "$WOZ" ci leak ;;
cicd-lock) exec "$CMDS_MISE" exec -- "$WOZ" ci lock ;;
cicd-repr) exec "$CMDS_MISE" exec -- "$WOZ" ci repr ;;
cicd-deps) exec "$CMDS_MISE" exec -- "$WOZ" ci deps ;;
linu-shut-nigh) exec bash "$SSS/ru-shut-guar.sh" tick ;;
*) echo "sh-cmds-linu.sh: unknown task id: $1" >&2; exit 2 ;;
esac
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
