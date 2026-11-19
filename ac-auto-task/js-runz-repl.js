// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Per-job reply row, waiting mark and step-by-step answers
// Flo: build row in the block > watch output > spot a prompt > send one step at a time
// I/O: output chunks + typed or queued lines > posts to this job only
// ===================================================================
const CFRP = { quieMsec: 700, fallMsec: 2000, showMsec: 600, tryMax: 40, tryMsec: 50, histMax: 50, tailMax: 200 };
async function replPost(jobz, text) { try { const resp = await fetch(SERVER + '/stdin', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ jobId: jobz, data: text }) }); return resp.status; } catch { return 0; } }
function replMake(spec) {
const { jobz, bloc, outz, tabz } = spec, lines = spec.lines || [];
const ctrl = { jobz, queue: [...lines], total: lines.length, sentQ: 0, hist: [], posi: -1, tail: '', wait: false, shown: lines.length > 0, ended: false, chain: Promise.resolve(), tQuie: 0, tFall: 0, tShow: 0 };
const rowz = document.createElement('div'); rowz.className = 'repl-row'; const stpz = document.createElement('span'); stpz.className = 'repl-step'; const inpz = document.createElement('input'); inpz.className = 'stdin-inp repl-inp'; inpz.placeholder = 'input the value here'; inpz.spellcheck = false; inpz.autocomplete = 'off'; const butz = document.createElement('button'); butz.className = 'btn-sm repl-send'; butz.textContent = 'send'; rowz.appendChild(stpz); rowz.appendChild(inpz); rowz.appendChild(butz); bloc.appendChild(rowz);
function waiSet() { tabz.waitSet = tabz.waitSet || new Set(); return tabz.waitSet; }
function look() { const live = !ctrl.ended; rowz.classList.toggle('visible', live && ctrl.shown); bloc.classList.toggle('is-waiting', live && ctrl.wait); const wset = waiSet(); if (live && ctrl.wait) wset.add(ctrl); else wset.delete(ctrl); if (tabz.dotEl) tabz.dotEl.classList.toggle('is-waiting', wset.size > 0); stpz.textContent = ctrl.total ? (ctrl.sentQ < ctrl.total ? `step ${ctrl.sentQ + 1}/${ctrl.total}` : 'all answers sent') : (ctrl.wait ? 'input' : ''); }
function lineAdd(clas, text) { const divz = document.createElement('div'); divz.className = 'line ' + clas; divz.textContent = text; outz.appendChild(divz); }
function focuTry() { if (typeof activeTab !== 'undefined' && tabz === activeTab && document.activeElement === document.body) inpz.focus(); }
async function deliv(line) { if (ctrl.broke) return; let code = 404; for (let tryn = 0; tryn < CFRP.tryMax && code === 404 && !ctrl.ended; tryn++) { code = await replPost(jobz, line); if (code === 404) await new Promise(done => setTimeout(done, CFRP.tryMsec)); } if (code === 200) { lineAdd('line-stdin-echo', '▶ ' + line); return; } ctrl.broke = true; ctrl.queue = []; if (!ctrl.ended) lineAdd('line-stderr', 'input not delivered — the job is gone'); look(); }
function send(line) { ctrl.chain = ctrl.chain.then(() => deliv(line)); return ctrl.chain; }
function arm() { clearTimeout(ctrl.tQuie); clearTimeout(ctrl.tFall); if (ctrl.ended) return; ctrl.tQuie = setTimeout(quie, CFRP.quieMsec); ctrl.tFall = setTimeout(fall, CFRP.fallMsec); }
function sendNex() { if (!ctrl.queue.length) return; const line = ctrl.queue.shift(); ctrl.sentQ++; ctrl.tail = ''; ctrl.wait = false; look(); send(line); arm(); }
function quie() { const last = ctrl.tail.slice(-1); ctrl.wait = last !== '' && last !== '\n' && last !== '\r'; look(); if (ctrl.wait && ctrl.queue.length) sendNex(); else if (ctrl.wait) focuTry(); }
function fall() { sendNex(); }
function submit() { const valu = inpz.value; inpz.value = ''; ctrl.posi = -1; if (valu !== '' && ctrl.hist[ctrl.hist.length - 1] !== valu) ctrl.hist.push(valu); if (ctrl.hist.length > CFRP.histMax) ctrl.hist.shift(); ctrl.tail = ''; ctrl.wait = false; look(); send(valu); arm(); }
function histMove(step) { if (!ctrl.hist.length) return; ctrl.posi = Math.max(-1, Math.min(ctrl.hist.length - 1, ctrl.posi + step)); inpz.value = ctrl.posi < 0 ? '' : ctrl.hist[ctrl.hist.length - 1 - ctrl.posi]; }
ctrl.feed = text => { if (!text) return; ctrl.tail = (ctrl.tail + text).slice(-CFRP.tailMax); if (ctrl.wait) { ctrl.wait = false; look(); } arm(); };
ctrl.end = () => { ctrl.ended = true; clearTimeout(ctrl.tQuie); clearTimeout(ctrl.tFall); clearTimeout(ctrl.tShow); look(); rowz.remove(); };
ctrl.row = rowz; ctrl.input = inpz; ctrl.submit = submit; ctrl.send = send;
inpz.addEventListener('keydown', evtn => { if (evtn.key === 'Enter') { evtn.preventDefault(); evtn.stopPropagation(); submit(); } if (evtn.key === 'ArrowUp') { evtn.preventDefault(); histMove(1); } if (evtn.key === 'ArrowDown') { evtn.preventDefault(); histMove(-1); } });
butz.addEventListener('click', evtn => { evtn.stopPropagation(); submit(); inpz.focus(); });
ctrl.tShow = setTimeout(() => { ctrl.shown = true; look(); }, CFRP.showMsec);
bloc._repl = ctrl; look(); arm();
return ctrl; }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
