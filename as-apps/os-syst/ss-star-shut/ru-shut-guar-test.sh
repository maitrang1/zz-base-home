# ===================================================================
# Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
# Des: Tests for ru-shut-guar.sh with fake hub and clock
# Flo: fixture > fake hub > arm/check/wait/forced/stale/down > chains > later > tick
# I/O: none > PASS/FAIL lines, exit 0 only if all pass
# Run: bash ~/zz-base-home/as-apps/os-syst/ss-star-shut/ru-shut-guar-test.sh
# ===================================================================
source "$(dirname "${BASH_SOURCE[0]}")/te-base-fixt.sh"
fix_make
echo "-- shutdown-guard"
idle='{"queue":{"running":[],"waiting":[]},"armErrors":[]}'
busy='{"queue":{"running":[{"id":"live-data","lock":"main","sinceMin":3}],"waiting":[]},"armErrors":[]}'
printf '%s' "$idle" > "$tmpz/queue.json"
printf '%s\n' 'import http.server, sys' 'q = sys.argv[1]' 'class H(http.server.BaseHTTPRequestHandler):' '    def do_GET(self):' "        b = open(q, 'rb').read()" '        self.send_response(200); self.send_header("Content-Length", str(len(b))); self.end_headers(); self.wfile.write(b)' '    def log_message(self, *a): pass' "s = http.server.HTTPServer(('127.0.0.1', 0), H)" "open(sys.argv[2], 'w').write(str(s.server_port))" 's.serve_forever()' > "$tmpz/hub.py"
python3 "$tmpz/hub.py" "$tmpz/queue.json" "$tmpz/hub.port" & hubz=$!
for _ in 1 2 3 4 5 6 7 8 9 10; do [[ -s $tmpz/hub.port ]] && break; sleep 0.3; done
printf '#!/usr/bin/env bash\necho "term $*" >> "%s"\n' "$logz" > "$tmpz/bin/fake-term"; chmod +x "$tmpz/bin/fake-term"
printf '%s\n' "GUAR_HUBP=$(<"$tmpz/hub.port")" "GUAR_FORC=2" "GUAR_STAL=3" "GUAR_ARMH=23" "GUAR_SELF=linu-shut-nigh" "GUAR_TERM=$tmpz/bin/fake-term" "GUAR_FLAG=$tmpz/armed" "GUAR_STAT=$tmpz/state" >> "$app/aa-conf-main.env"
mkdir -p "$tmpz/state"
G="$app/ru-shut-guar.sh"
T23=$(date -d "2026-11-07 23:00" +%s); T0030=$(date -d "2026-11-08 00:30" +%s); T0200=$(date -d "2026-11-08 02:00" +%s); T0900=$(date -d "2026-11-08 09:00" +%s)
: > "$logz"
GUARD_NOW=$T23 bash "$G" check | grep -q "not armed"; chk "check not armed skips" test $? -eq 0
GUARD_NOW=$T23 bash "$G" arm | grep -q "forced off at 2026-11-08 02:00"; chk "arm shows forced time" test $? -eq 0
chk "arm writes the flag" test "$(<"$tmpz/armed")" == "$T23"
GUARD_NOW=$T0030 bash "$G" check > "$tmpz/g1.txt"; sleep 0.6
chk "idle hub powers off" grep -q "term -- bash $app/ru-shut-linu.sh\|term bash $app/ru-shut-linu.sh" "$logz"
chk "run disarms the flag" test ! -f "$tmpz/armed"
: > "$logz"; GUARD_NOW=$T23 bash "$G" arm >/dev/null
printf '%s' '{"queue":{"running":[{"id":"live-data","lock":"main","sinceMin":3}],"waiting":[{"id":"zalo-push","lock":"main","retry":0}]},"armErrors":[]}' > "$tmpz/queue.json"
GUARD_NOW=$T0030 bash "$G" check > "$tmpz/g2.txt"; sleep 0.6
chk "busy waits" grep -q "wait: busy: live-data zalo-push" "$tmpz/g2.txt"
chk "busy runs nothing" test ! -s "$logz"
printf '%s' '{"queue":{"running":[{"id":"linu-shut-nigh","lock":"main","sinceMin":0}],"waiting":[]},"armErrors":[]}' > "$tmpz/queue.json"
GUARD_NOW=$T0030 bash "$G" check > "$tmpz/g3.txt"; sleep 0.6
chk "own job ignored" grep -q "shutdown: all jobs idle" "$tmpz/g3.txt"
: > "$logz"; GUARD_NOW=$T23 bash "$G" arm >/dev/null
printf '%s' "$busy" > "$tmpz/queue.json"
GUARD_NOW=$T0200 bash "$G" check > "$tmpz/g4.txt"; sleep 0.6
chk "forced hour powers off" grep -q "forced hour 2h reached (busy: live-data)" "$tmpz/g4.txt"
chk "forced run launches term" test -s "$logz"
: > "$logz"; GUARD_NOW=$T23 bash "$G" arm >/dev/null
GUARD_NOW=$T0900 bash "$G" check > "$tmpz/g5.txt"; sleep 0.6
chk "stale arm skipped" grep -q "arm is stale" "$tmpz/g5.txt"
chk "stale arm runs nothing" test ! -s "$logz"
GUARD_NOW=$T23 bash "$G" arm >/dev/null
sed -i "s/^GUAR_HUBP=.*/GUAR_HUBP=1/" "$app/aa-conf-main.env"
GUARD_NOW=$T0030 bash "$G" check > "$tmpz/g6.txt"; sleep 0.6
chk "hub down skips" grep -q "hub not answering" "$tmpz/g6.txt"
chk "hub down runs nothing" test ! -s "$logz"
bash "$G" --bogus >/dev/null 2>&1; chk "guard bad arg exits 2" test $? -eq 2
bash "$G" disarm | grep -q disarmed; chk "disarm renames flag" test -f "$tmpz/armed.off"
sed -i "s/^GUAR_HUBP=.*/GUAR_HUBP=$(<"$tmpz/hub.port")/" "$app/aa-conf-main.env"
printf '%s' "$idle" > "$tmpz/queue.json"
: > "$logz"; GUARD_NOW=$T23 bash "$G" arm >/dev/null
echo "1 1 0 $(( (T0030 + 600) * 1000 )) $((T23 * 1000))" > "$tmpz/state/flow-cars-data-publ.chain"
GUARD_NOW=$T0030 bash "$G" check > "$tmpz/g7.txt"; sleep 0.6
chk "live chain gap = busy" grep -q "wait: busy: flow-cars-data-publ" "$tmpz/g7.txt"
chk "live chain runs nothing" test ! -s "$logz"
echo "1 1 0 $(( (T0030 - 3600) * 1000 )) $((T23 * 1000))" > "$tmpz/state/flow-cars-data-publ.chain"
GUARD_NOW=$T0030 bash "$G" check > "$tmpz/g8.txt"; sleep 0.6
chk "stale chain file ignored" grep -q "shutdown: all jobs idle" "$tmpz/g8.txt"
mv "$tmpz/state/flow-cars-data-publ.chain" "$tmpz/state/flow-cars-data-publ.chain.done"
printf '%s' "$idle" > "$tmpz/queue.json"
GUARD_DRY=1 bash "$G" later 0 > "$tmpz/l1.txt"; chk "later 0 idle goes on" grep -q "dry: would run ru-shut-linu.sh$" "$tmpz/l1.txt"
printf '%s' "$busy" > "$tmpz/queue.json"
( sleep 2; printf '%s' "$idle" > "$tmpz/queue.json" ) & fixp=$!
GUARD_POLL=1 GUARD_DRY=1 timeout 30 bash "$G" later 0 > "$tmpz/l2.txt"; wait "$fixp"
chk "later waits while busy" grep -q "wait: busy: live-data" "$tmpz/l2.txt"
chk "later then goes on" grep -q "dry: would run ru-shut-linu.sh" "$tmpz/l2.txt"
bash "$G" later x >/dev/null 2>&1; chk "later bad arg exits 2" test $? -eq 2
printf '%s' "$idle" > "$tmpz/queue.json"
mv "$tmpz/armed" "$tmpz/armed.$$.old" 2>/dev/null; mv "$tmpz/armed.off" "$tmpz/armed.off.$$.old" 2>/dev/null; : > "$logz"
GUARD_NOW=$T23 bash "$G" tick | grep -q "^armed at"; chk "tick 23:00 arms" test $? -eq 0
GUARD_NOW=$((T23 + 900)) bash "$G" tick > "$tmpz/g9.txt"; sleep 0.6
chk "tick 23:15 checks, idle off" grep -q "shutdown: all jobs idle" "$tmpz/g9.txt"
GUARD_NOW=$((T23 + 900)) bash "$G" tick | grep -q "not armed"; chk "tick after run skips" test $? -eq 0
GUARD_NOW=$T0030 bash "$G" tick | grep -q "not armed"; chk "tick 00:30 no arm" test $? -eq 0
for m in armed armed.off armed.done; do [[ -e $tmpz/$m ]] && mv "$tmpz/$m" "$tmpz/$m.$$.late"; done; : > "$logz"
GUARD_NOW=$((T23 + 2400)) bash "$G" tick | grep -q "^armed at"; chk "late tick 23:40 arms" test $? -eq 0
bash "$G" disarm >/dev/null
GUARD_NOW=$((T23 + 3000)) bash "$G" tick | grep -q "not armed"; chk "late tick after disarm skips" test $? -eq 0
for m in armed armed.off armed.done; do [[ -e $tmpz/$m ]] && mv "$tmpz/$m" "$tmpz/$m.$$.late2"; done
GUARD_NOW=$((T23 + 2400)) bash "$G" tick >/dev/null
GUARD_NOW=$((T23 + 2700)) bash "$G" tick >/dev/null; sleep 0.6
GUARD_NOW=$((T23 + 3600 - 60)) bash "$G" tick | grep -q "not armed"; chk "late tick after shutdown skips" test $? -eq 0
fini
# =======================___THIS_IS_THE_END___=======================
# ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
