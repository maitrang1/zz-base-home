# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Tests for sh-cmds-linu.sh with a fake mise and wo
# Flo: temp tree > each task id > unknown id > exit code > cwd > aa-conf-main.env > mise fallback
# I/O: none > PASS/FAIL lines, exit 0 only if all pass
# Run: bash ~/zz-base-home/ac-auto-task/sh-cmds-linu-test.sh
# ===================================================================
set -u
dirz=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
tmpz=$(mktemp -d); pass=0; fail=0; trap 'mv "$tmpz" "$tmpz.done" 2>/dev/null' EXIT
ok() { echo "PASS  $1"; pass=$((pass + 1)); }
bad() { echo "FAIL  $1"; fail=$((fail + 1)); }
chk() { local name=$1; shift; if "$@"; then ok "$name"; else bad "$name"; fi; }
mkdir -p "$tmpz/ac-auto-task" "$tmpz/as-apps/os-syst/wo-work-mode/zig-out/bin" "$tmpz/as-apps/os-syst/ss-star-shut" "$tmpz/home/.local/bin"
cp "$dirz/sh-cmds-linu.sh" "$tmpz/ac-auto-task/"; logz="$tmpz/calls.log"; wo="$tmpz/as-apps/os-syst/wo-work-mode/zig-out/bin/wo"
printf '#!/usr/bin/env bash\necho "mise $*" >> "%s"\necho "dev=${WO_DEVI_NAME:-}" >> "%s"\necho "cwd=$PWD" >> "%s"\nexit "${FAKE_RC:-0}"\n' "$logz" "$logz" "$logz" > "$tmpz/mise"; chmod +x "$tmpz/mise"; cp "$tmpz/mise" "$tmpz/home/.local/bin/mise"
printf 'echo "guar $*" >> "%s"\n' "$logz" > "$tmpz/as-apps/os-syst/ss-star-shut/ru-shut-guar.sh"
run() { : > "$logz"; env -u WO_DEVI_NAME -u CMDS_MISE CMDS_MISE="$tmpz/mise" bash "$tmpz/ac-auto-task/sh-cmds-linu.sh" "$@"; }
echo "-- cmds-linu"
for pair in "home-wipz|wipz --live" "home-docs|docs sync --live" "home-beat|beat --live" "home-bkup-stat|bkup stat --live" "home-bkup-nigh|bkup nigh --live" "home-doct|doct" "home-dril|dril --live" "home-code|sync --live" "cicd-stat|ci stat" "cicd-rele|ci rele" "cicd-test|ci test" "cicd-leak|ci leak" "cicd-lock|ci lock" "cicd-repr|ci repr" "cicd-deps|ci deps"; do id=${pair%%|*}; args=${pair#*|}; run "$id"; chk "$id runs wo $args" grep -q -x "mise exec -- $wo $args" "$logz"; done
scr="$tmpz/as-apps/ws-webs/sc-scra/zig-out/bin/scra"; run scra-raws; chk "scra-raws runs scra run" grep -q -x "mise exec -- $scr run --seed-file $HOME/.zz-base-home-tena/as-apps/ws-webs/sc-scra/seeds.txt --follow 800 --live" "$logz"
run scra-data; chk "scra-data runs scra cars" grep -q -x "mise exec -- $scr cars --live" "$logz"
run scra-inge; chk "scra-inge runs scra ingest" grep -q -x "mise exec -- $scr ingest --live" "$logz"
run scra-cont; chk "scra-cont runs scra cont" grep -q -x "mise exec -- $scr cont --live" "$logz"
run scra-sync; chk "scra-sync runs scra sync" grep -q -x "mise exec -- $scr sync --live" "$logz"
fbx="$tmpz/as-apps/ch-chat/fb-face-webs/zig-out/bin/fb"; zax="$tmpz/as-apps/ch-chat/za-zalo-webs/zig-out/bin/za"
run fb-watc; chk "fb-watc runs fb alive" grep -q -x "mise exec -- $fbx alive --acct all" "$logz"
run za-watc; chk "za-watc runs za alive" grep -q -x "mise exec -- $zax alive --acct all" "$logz"
run face-scra; chk "face-scra runs fb read feed" grep -q -x "mise exec -- $fbx read feed --live --acct all" "$logz"
run zalo-scra; chk "zalo-scra reads first" grep -q -x "mise exec -- $zax run read --live --acct all" "$logz"; chk "zalo-scra then feeds" grep -q -x "mise exec -- $zax feed --live --acct all" "$logz"
FAKE_RC=5 run zalo-scra; chk "zalo-scra exits with the read failure" test $? -eq 5
run linu-shut-nigh; chk "linu-shut-nigh runs the guard tick" grep -q -x "guar tick" "$logz"
run home-wipz; chk "task runs from the repo root" grep -q -x "cwd=$tmpz" "$logz"
run nope-nope 2>"$tmpz/err.txt"; rc=$?; chk "unknown id exits 2" test $rc -eq 2
chk "unknown id says so" grep -q "unknown task id: nope-nope" "$tmpz/err.txt"
run 2>/dev/null; chk "no id exits 2" test $? -eq 2
FAKE_RC=7 run home-doct; chk "exit code passes through" test $? -eq 7
printf '# private\nWO_DEVI_NAME=dev9\nCMDS_MISE=%s\n' "$tmpz/mise" > "$tmpz/ac-auto-task/aa-conf-main.env"
: > "$logz"; env -u WO_DEVI_NAME -u CMDS_MISE bash "$tmpz/ac-auto-task/sh-cmds-linu.sh" home-wipz; chk "aa-conf-main.env sets the device name" grep -q -x "dev=dev9" "$logz"
chk "aa-conf-main.env sets the mise command" grep -q "^mise exec -- " "$logz"
: > "$logz"; env -u CMDS_MISE WO_DEVI_NAME=envwins bash "$tmpz/ac-auto-task/sh-cmds-linu.sh" home-wipz; chk "env var beats the file" grep -q -x "dev=envwins" "$logz"
rm -f "$tmpz/ac-auto-task/aa-conf-main.env"; : > "$logz"; env -u WO_DEVI_NAME -u CMDS_MISE HOME="$tmpz/home" PATH="/usr/bin:/bin" bash "$tmpz/ac-auto-task/sh-cmds-linu.sh" home-wipz 2>/dev/null
if PATH="/usr/bin:/bin" command -v mise >/dev/null 2>&1; then echo "SKIP  mise fallback (a real mise is on PATH)"; else chk "no mise on PATH: falls back to ~/.local/bin/mise" grep -q "^mise exec -- " "$logz"; fi
echo; echo "$pass passed, $fail failed"
test "$fail" -eq 0
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
