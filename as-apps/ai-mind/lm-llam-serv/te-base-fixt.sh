# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Shared test fixture: temp home, fake llama-server, helpers
# Flo: temp dir > fake server + model > test settings > copy scripts > chk helpers
# I/O: sourced by every *-test.sh > vars app tmpz logz port, fns chk fini
# Run: source ~/zz-base-home/as-apps/ai-mind/lm-llam-serv/te-base-fixt.sh
# ===================================================================
set -u
dirz=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
tmpz=$(mktemp -d); pass=0; fail=0; kids=""
trap 'kill $kids 2>/dev/null; mv "$tmpz" "$tmpz.done" 2>/dev/null' EXIT
ok() { echo "PASS  $1"; pass=$((pass + 1)); }
bad() { echo "FAIL  $1"; fail=$((fail + 1)); }
chk() { local name=$1; shift; if "$@"; then ok "$name"; else bad "$name"; fi; }
fini() { echo; echo "$pass passed, $fail failed"; test "$fail" -eq 0; }
fix_make() { export HOME="$tmpz/home" TMPDIR="$tmpz/tmp"; app="$tmpz/app"; port=$((39000 + RANDOM % 900)); mkdir -p "$HOME" "$TMPDIR" "$app" "$tmpz/bin" "$tmpz/models"; logz="$tmpz/calls.log"; : > "$logz"; printf '#!/usr/bin/env bash\necho "llama $*" >> "%s"\nsleep 30\n' "$logz" > "$tmpz/bin/llama-server"; chmod +x "$tmpz/bin/llama-server"; : > "$tmpz/models/m.gguf"; : > "$tmpz/models/p.gguf"; printf '%s\n' "AISV_BINA=$tmpz/bin/llama-server" "AISV_MODL=$tmpz/models/m.gguf" "AISV_PORT=$port" "AISV_EVRY=30" "AISV_BOOT=0" > "$app/aa-conf-main.env"; cp "$dirz"/*.sh "$app/"; }
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
