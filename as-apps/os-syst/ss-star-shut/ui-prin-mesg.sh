# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Shared console look: banner, detail line, countdown bar
# Flo: banner > detail (only with verbose or dry-run) > bar
# I/O: caller sets vrbz, dryz (1 = on) > text on stdout; sourced, never run
# Run: source ~/zz-base-home/as-apps/os-syst/ss-star-shut/ui-prin-mesg.sh
# ===================================================================
banner() { printf '\n====== %s ======\n\n' "$*"; }
detail() { if ((${vrbz:-0} || ${dryz:-0})); then printf '    %s\n' "$*"; fi; return 0; }
bar() { local i=$1 n=$2 d e; printf -v d '%*s' $((n - i)) ''; printf -v e '%*s' "$i" ''; printf '\r       [%s%s] - %ss  ' "${d// /-}" "${e// /=}" "$i"; }
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
