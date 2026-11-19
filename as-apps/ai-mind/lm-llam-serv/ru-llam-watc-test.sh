# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Tests for ru-llam-watc.sh with a fake llama-server
# Flo: fixture > missing files > start > lock > port busy > vision role > lock cleanup
# I/O: none > PASS/FAIL lines, exit 0 only if all pass
# Run: bash ~/zz-base-home/as-apps/ai-mind/lm-llam-serv/ru-llam-watc-test.sh
# ===================================================================
source "$(dirname "${BASH_SOURCE[0]}")/te-base-fixt.sh"
fix_make
echo "-- llam-watc"
printf 'AISV_MODL=%s/models/none.gguf\nAISV_BINA=%s/bin/llama-server\nAISV_PORT=%s\n' "$tmpz" "$tmpz" "$port" > "$tmpz/nomod.env"; out=$(AISV_CONF="$tmpz/nomod.env" bash "$app/ru-llam-watc.sh" 2>&1); rc=$?
chk "missing model exits 1" test $rc -eq 1
chk "missing model is named" grep -q "ai server: missing .*none.gguf" <<< "$out"
printf 'AISV_BINA=%s/bin/llama-server\nAISV_PORT=%s\n' "$tmpz" "$port" > "$tmpz/nomodl.env"; chk "unset model exits 1" bash -c "! AISV_CONF='$tmpz/nomodl.env' bash '$app/ru-llam-watc.sh' >/dev/null 2>&1"
chk "no lock left after a refusal" test ! -e "$TMPDIR/aisv-watchdog-$port.lock"
chk "unknown role exits 1" bash -c "! bash '$app/ru-llam-watc.sh' bogus >/dev/null 2>&1"
bash "$app/ru-llam-watc.sh" & wp=$!; kids="$wp"; sleep 1.5
chk "server started once" test "$(grep -c '^llama ' "$logz")" -eq 1
chk "server gets the exact flags" grep -q "llama -m $tmpz/models/m.gguf --host 127.0.0.1 --port $port -np 1 -c 4096 -t 4$" "$logz"
chk "lock holds the watchdog pid" test "$(cat "$TMPDIR/aisv-watchdog-$port.lock")" = "$wp"
bash "$app/ru-llam-watc.sh"; chk "second watchdog on the same port exits 0" test $? -eq 0
chk "second watchdog starts nothing" test "$(grep -c '^llama ' "$logz")" -eq 1
kill "$wp" 2>/dev/null; wait "$wp" 2>/dev/null; sleep 0.3
chk "lock removed when the watchdog ends" test ! -e "$TMPDIR/aisv-watchdog-$port.lock"
if command -v python3 >/dev/null 2>&1 && command -v ss >/dev/null 2>&1; then : > "$logz"; python3 -m http.server "$port" --bind 127.0.0.1 >/dev/null 2>&1 & hp=$!; kids="$hp"; sleep 1; bash "$app/ru-llam-watc.sh" & wp=$!; kids="$hp $wp"; sleep 1.5; chk "busy port: nothing started" test ! -s "$logz"; kill "$wp" "$hp" 2>/dev/null; wait "$wp" "$hp" 2>/dev/null; fi
: > "$logz"; printf 'AISV_BINA=%s/bin/llama-server\nAISV_MODL=%s/models/m.gguf\nAISV_PORT=%s\nAISV_EVRY=30\nAISV_BOOT=0\nVISI_MODL=%s/models/v.gguf\nVISI_MMPJ=%s/models/p.gguf\nVISI_XTRA=--no-mmproj-offload --image-max-tokens 160\nVISI_PORT=%s\n' "$tmpz" "$tmpz" "$port" "$tmpz" "$tmpz" "$((port + 1))" > "$tmpz/two.env"; : > "$tmpz/models/v.gguf"
AISV_CONF="$tmpz/two.env" bash "$app/ru-llam-watc.sh" visi & wp=$!; kids="$wp"; sleep 1.5; kill "$wp" 2>/dev/null; wait "$wp" 2>/dev/null
chk "vision role: own model, projector, extras" grep -q -- "llama -m $tmpz/models/v.gguf --host 127.0.0.1 --port $((port + 1)) -np 1 -c 4096 -t 4 --mmproj $tmpz/models/p.gguf --no-mmproj-offload --image-max-tokens 160$" "$logz"
chk "vision role: its own lock" test ! -e "$TMPDIR/aisv-watchdog-$port.lock"
fini
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
