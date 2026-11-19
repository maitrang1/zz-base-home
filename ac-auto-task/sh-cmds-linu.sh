# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Auto-run dispatcher, jobs with no run line (Unix)
# Flo: read job id > run its command via one case line > else exit 2
# I/O: job id (argv 1, from the scheduler) > command exit code, or stderr + exit 2
# Run: bash "E:\zz-base-home\ac-auto-task\sh-cmds-linu.sh" <job-id>
# ===================================================================
case "$1" in
*) echo "sh-cmds-linu.sh: unknown job id: $1" >&2; exit 2 ;;
esac
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
