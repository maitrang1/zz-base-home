# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Tests for cf-llam-load.sh: defaults, keys, numbers, roles
# Flo: fixture > good file > defaults > override > bad keys and numbers > ~ > vision role
# I/O: none > PASS/FAIL lines, exit 0 only if all pass
# Run: bash ~/zz-base-home/as-apps/ai-mind/lm-llam-serv/cf-llam-load-test.sh
# ===================================================================
source "$(dirname "${BASH_SOURCE[0]}")/te-base-fixt.sh"
fix_make
echo "-- llam-load"
ld() { AISV_CONF="$1" bash "$app/cf-llam-load.sh" --check "${@:2}"; }
chk "good file passes" bash "$app/cf-llam-load.sh" --check
printf 'AISV_MODL=/x/m.gguf\n' > "$tmpz/min.env"; out=$(ld "$tmpz/min.env")
chk "default port 3010" grep -q "AISV_PORT = 3010" <<< "$out"
chk "default host is local only" grep -q "AISV_HOST = 127.0.0.1" <<< "$out"
chk "default log is /dev/null" grep -q "AISV_LOGF = /dev/null" <<< "$out"
chk "env var beats the file" bash -c "AISV_PORT=7 bash '$app/cf-llam-load.sh' --check | grep -q 'AISV_PORT = 7'"
printf 'BOGU_KEYZ=1\n' > "$tmpz/bad1.env"; out=$(ld "$tmpz/bad1.env" 2>&1); rc=$?
chk "unknown key refused" test $rc -eq 1
chk "error names file and line" grep -q "bad1.env line 1" <<< "$out"
printf 'AISV_PORT=abc\n' > "$tmpz/bad2.env"; chk "bad number refused" bash -c "! AISV_CONF='$tmpz/bad2.env' bash '$app/cf-llam-load.sh' --check >/dev/null 2>&1"
printf 'AISV_THRD=04\n' > "$tmpz/bad3.env"; chk "leading zero refused" bash -c "! AISV_CONF='$tmpz/bad3.env' bash '$app/cf-llam-load.sh' --check >/dev/null 2>&1"
printf 'AISV_PORT=70000\n' > "$tmpz/bad4.env"; chk "port over 65535 refused" bash -c "! AISV_CONF='$tmpz/bad4.env' bash '$app/cf-llam-load.sh' --check >/dev/null 2>&1"
printf 'AISV_MODL=~/m.gguf\n' > "$tmpz/tld.env"; chk "~ expands to HOME" bash -c "AISV_CONF='$tmpz/tld.env' bash '$app/cf-llam-load.sh' --check | grep -q 'AISV_MODL = $HOME/m.gguf'"
chk "default file is found from any folder" bash -c "cd / && bash '$app/cf-llam-load.sh' --check >/dev/null"
chk "missing file refused" bash -c "! AISV_CONF='$tmpz/none.env' bash '$app/cf-llam-load.sh' --check >/dev/null 2>&1"
printf 'AISV_BINA=/no/such/llama-server\nAISV_MODL=/x\n' > "$tmpz/pth.env"; chk "binary falls back to PATH" bash -c "PATH='$tmpz/bin':\$PATH AISV_CONF='$tmpz/pth.env' bash '$app/cf-llam-load.sh' --check | grep -q 'AISV_BINA = $tmpz/bin/llama-server'"
printf 'AISV_MODL=/t.gguf\nAISV_PORT=3010\nAISV_LOGF=/t.log\nAISV_THRD=6\nVISI_MODL=/v.gguf\nVISI_MMPJ=/p.gguf\nVISI_PORT=3011\nVISI_XTRA=--flag 1\nVISI_LOGF=/v.log\n' > "$tmpz/two.env"
out=$(ld "$tmpz/two.env" visi); chk "visi role: own model" grep -q "AISV_MODL = /v.gguf" <<< "$out"
chk "visi role: own port" grep -q "AISV_PORT = 3011" <<< "$out"
chk "visi role: projector and extras" grep -q "AISV_MMPJ = /p.gguf" <<< "$out"
chk "visi role: log" grep -q "AISV_LOGF = /v.log" <<< "$out"
chk "visi role: inherits threads" grep -q "AISV_THRD = 6" <<< "$out"
out=$(ld "$tmpz/two.env"); chk "main role: text model and port" bash -c "grep -q 'AISV_MODL = /t.gguf' <<< '$out' && grep -q 'AISV_PORT = 3010' <<< '$out'"
chk "main role ignores the vision keys" bash -c "! grep -q 'AISV_MMPJ = /p.gguf' <<< '$out'"
printf 'AISV_MODL=/t.gguf\nVISI_MODL=/v.gguf\n' > "$tmpz/nop.env"; chk "visi without VISI_PORT refused" bash -c "! AISV_CONF='$tmpz/nop.env' bash '$app/cf-llam-load.sh' --check visi >/dev/null 2>&1"
chk "unknown role refused" bash -c "! bash '$app/cf-llam-load.sh' --check bogus >/dev/null 2>&1"
printf 'VISI_PORT=abc\n' > "$tmpz/bad5.env"; chk "bad VISI number refused" bash -c "! AISV_CONF='$tmpz/bad5.env' bash '$app/cf-llam-load.sh' --check >/dev/null 2>&1"
fini
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
