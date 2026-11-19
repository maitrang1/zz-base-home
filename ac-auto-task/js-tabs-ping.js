// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Terminal wrap placement, status pill, server ping
// Flo: place term wrap > set status > ping > poll
// I/O: /ping JSON (browser, server) > status pill (DOM)
// ===================================================================
const termWrapElem = document.querySelector('.term-wrap'); const outpSectBody = document.getElementById('outpSectBody'); const termWrapHome = document.createElement('div'); termWrapElem.after(termWrapHome); const mobiMq = window.matchMedia('(max-width: 600px)'); const outpFootElem = document.querySelector('#outpSectBody .sidebar-panel-foot');
function termWrapHomeSync() { if (mobiMq.matches) { if (termWrapElem.parentElement !== outpSectBody) outpSectBody.insertBefore(termWrapElem, outpFootElem); } else { if (termWrapElem.parentElement !== termWrapHome.parentElement) termWrapHome.after(termWrapElem); } }
mobiMq.addEventListener('change', termWrapHomeSync); termWrapHomeSync();
function setStatus(stat, labl) { serverOk = stat === 'connected'; statusPill.className = 'status-pill ' + stat; statusDot.classList.toggle('pulse', stat !== 'connected'); statusText.textContent = labl; }
const pageQury = (/Electron/.test(navigator.userAgent) || matchMedia('(display-mode: standalone)').matches) ? '' : '?ui=1';
async function ping() { try { const resp = await fetch(SERVER + '/ping' + pageQury, { signal: AbortSignal.timeout(CFTB.pingWaitTime) }); const data = await resp.json(); if (data.reloadAt && data.reloadAt > reloLast) { reloLast = data.reloadAt; location.reload(); return; } setStatus('connected', 'connected'); document.getElementById('sbLeft').textContent = 'port ' + (location.port || '80') + ' · ' + data.platform + ' · ' + data.cwd; cmdInput.placeholder = data.platform === 'windows' ? 'enter command — full path required — e.g. node D:\\tool\\run.js E:\\file\\name.txt' : 'enter command — full path required — e.g. /usr/bin/node /home/user/app.js arg2'; if (!cwdInp.value) cwdInp.placeholder = activeTab?.sessionCwd || data.cwd; _platform = data.platform; if (Array.isArray(data.shells)) shelSync(data.shells); } catch { setStatus('error', 'disconnected'); } }
let serverOk = false, pollTime = null, reloLast = Date.now();
function shelSync(list) { const keyz = list.join(','); if (shelSync.keyz === keyz) return; shelSync.keyz = keyz; const curr = shellSel.value || stor.get('cmrn_shell') || 'default'; shellSel.innerHTML = '<option value="default">shell: auto</option>' + list.map(shel => `<option value="${esc(shel)}">${esc(CFTB.shelLabe[shel] || shel)}</option>`).join(''); shellSel.value = list.includes(curr) ? curr : 'default'; }
function pollStar() { clearInterval(pollTime); ping(); let hideLast = 0; pollTime = setInterval(() => { if (document.body.classList.contains('tab-evicted')) { clearInterval(pollTime); return; } if (document.hidden) { if (Date.now() - hideLast < CFTB.pingHideTime) return; hideLast = Date.now(); } ping(); }, CFTB.pingPollTime); if (!pollStar.visi) { pollStar.visi = true; document.addEventListener('visibilitychange', () => { if (!document.hidden) ping(); }); } }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
