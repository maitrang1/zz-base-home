// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Run one chain step by hand from its output row (play button)
// Flo: click > POST /step/run {id, tab} > on 200 pull the new row in via the chain sync > else say why
// I/O: step id + tab > server answer, notify text, new output row (DOM, by syncChainTabs)
// ===================================================================
const stepBusy = new Set();
async function stepPost(iden, tabz) { try { const resp = await fetch(SERVER + '/step/run', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ id: iden, tab: tabz }) }); let data = {}; try { data = await resp.json(); } catch {} return { stat: resp.status, data }; } catch { return { stat: 0, data: {} }; } }
function stepErroText(answ) { const data = answ.data || {}; if (answ.stat === 0) return 'connection error — is the auto-task server running?'; switch (data.error) { case 'chain_running': return 'chain ' + data.chain + ' is running — abort it first'; case 'busy': return 'this step is already running or queued'; case 'unknown_step': return 'unknown step — not in any chain or task'; case 'is_chain': return 'that id is a chain — fire the chain instead'; case 'bad_id': case 'missing_id': return 'bad step id'; case 'not_found': return 'this hub is older than the page — restart auto-task to run a single step'; case 'no_memory': return 'server is out of memory'; default: return data.error ? 'step run failed: ' + data.error : 'step run failed (' + answ.stat + ')'; } }
async function stepRunz(iden, tabz, post = stepPost, say = typeof notify === 'function' ? notify : () => {}) { if (typeof serverOk !== 'undefined' && !serverOk) return false; if (stepBusy.has(iden)) return false; stepBusy.add(iden); try { const answ = await post(iden, tabz?.label || ''); if (answ.stat !== 200) { say(stepErroText(answ)); return false; } if (answ.data.waiting) say("queued — waiting for lock '" + answ.data.lock + "'"); if (typeof syncChainTabs === 'function') await syncChainTabs(); return true; } finally { stepBusy.delete(iden); } }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
