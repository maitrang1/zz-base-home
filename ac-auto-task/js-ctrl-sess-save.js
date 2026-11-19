// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Saved sessions, hard reload, mini panel
// Flo: load list > save > load > delete > render > bind buttons
// I/O: Session name and clicks (browser) > saved sessions, restored tabs
// ===================================================================
const sessButn = document.getElementById('sessBtn'), sessOver = document.getElementById('sessOverlay'), sessInpt = document.getElementById('sessNameInp'), sessSaveButn = document.getElementById('sessSaveBtn'), sessList = document.getElementById('sessList');
function sessNorm(sessObjz) { if (!sessObjz || typeof sessObjz !== 'object' || typeof sessObjz.name !== 'string' || !sessObjz.name) return null; return { name: sessObjz.name, tabs: Array.isArray(sessObjz.tabs) ? sessObjz.tabs.filter(tabzItem => tabzItem && typeof tabzItem === 'object') : [], actIdx: Number.isFinite(sessObjz.actIdx) ? sessObjz.actIdx : 0, cwd: typeof sessObjz.cwd === 'string' ? sessObjz.cwd : '', cmd: typeof sessObjz.cmd === 'string' ? sessObjz.cmd : '' }; }
let sessData = (() => { try { const rawzData = JSON.parse(stor.get('cmrn_sessions') || '[]'); return Array.isArray(rawzData) ? rawzData.map(sessNorm).filter(Boolean) : []; } catch { return []; } })();
function sessSaveCurr() {
const sessName = sessInpt.value.trim();
if (!sessName) { sessInpt.focus(); return; }
const snapData = { name: sessName, tabs: tabs.map(tabzItem => ({ label: tabzItem.label, color: tabzItem.color, pinned: !!tabzItem.pinned, envVars: [...(tabzItem.envVars || [])] })), actIdx: tabs.indexOf(activeTab), cwd: cwdInp.value, cmd: cmdInput.value };
const sessIndx = sessData.findIndex(sessItem => sessItem.name === sessName);
if (sessIndx >= 0) { showConfPop(sessSaveButn, `"${sessName}" exists — replace it?`, () => { sessData[sessIndx] = snapData; sessComm(`replaced "${sessName}"`); }); return; }
sessData.push(snapData);
sessComm(`saved "${sessName}"`);
}
function sessComm(mesg) { stor.set('cmrn_sessions', JSON.stringify(sessData)); sessInpt.value = ''; sessListRend(); if (mesg) sessSayz(mesg); }
function sessSayz(mesg) { const elem = document.getElementById('sessMsg'); if (!elem) return; elem.textContent = mesg; clearTimeout(sessSayz.time); sessSayz.time = setTimeout(() => { elem.textContent = ''; }, CFCT.sessMsgz); }
function sessLoad(snapData, anchElem) { if (tabs.some(tabzItem => tabzItem.running)) { sessSayz('stop the running command first'); return; } const outpHave = tabs.some(tabzItem => tabzItem.blocks && tabzItem.blocks.length > 0); if (outpHave) { showConfPop(anchElem || sessButn, 'discard output in open tabs?', () => sessLoadExec(snapData)); return; } sessLoadExec(snapData); }
function sessLoadExec(snapData) {
[...tabs].forEach(tabzItem => { termTabsEl.querySelector(`.tab[data-tab-id="${tabzItem.id}"]`)?.remove(); termPanesEl.querySelector(`.term-pane[data-tab-id="${tabzItem.id}"]`)?.remove(); });
tabs.length = 0; activeTab = null;
snapData.tabs.forEach(tabzSnap => { const tabzNewz = createTab(tabzSnap.label, false, tabzSnap.color, false); tabzNewz.pinned = !!tabzSnap.pinned; tabzNewz.envVars = tabzSnap.envVars || []; const tabzElem = termTabsEl.querySelector(`.tab[data-tab-id="${tabzNewz.id}"]`); if (tabzNewz.pinned) { tabzElem?.classList.add('pinned'); tabzNewz.pinEl.title = 'pinned'; tabzNewz.pinEl.innerHTML = luci('pin-off'); lucide.createIcons(); } });
const tabzTarg = tabs[snapData.actIdx] || tabs[0];
if (tabzTarg) switchTab(tabzTarg.id);
cwdInp.value = snapData.cwd || ''; cmdInput.value = snapData.cmd || '';
saveTabs(); updateEnvBtn(activeTab);
sessOver.classList.remove('visible');
}
function sessDele(sessName) { sessData = sessData.filter(sessItem => sessItem.name !== sessName); sessComm(`deleted "${sessName}"`); }
function sessListRend() {
sessList.innerHTML = '';
if (!sessData.length) { sessList.innerHTML = '<div class="sess-empty">no sessions saved</div>'; return; }
sessData.forEach(sessItem => { const rowzElem = document.createElement('div'); rowzElem.className = 'sess-row'; const nameElem = document.createElement('span'); nameElem.className = 'sess-row-name'; nameElem.textContent = sessItem.name; const metaElem = document.createElement('span'); metaElem.className = 'sess-row-meta'; metaElem.textContent = sessItem.tabs.length + ' tab' + (sessItem.tabs.length !== 1 ? 's' : ''); const loadButn = document.createElement('button'); loadButn.className = 'btn-sm'; loadButn.textContent = 'load'; const deleButn = document.createElement('button'); deleButn.className = 'btn-sm sess-del-btn'; deleButn.innerHTML = luci('trash-2'); deleButn.title = 'delete'; loadButn.addEventListener('click', () => sessLoad(sessItem, loadButn)); deleButn.addEventListener('click', () => showConfPop(deleButn, `delete "${sessItem.name}"?`, () => sessDele(sessItem.name))); rowzElem.append(nameElem, metaElem, loadButn, deleButn); sessList.appendChild(rowzElem); });
lucide.createIcons();
}
function hardReloExec() { location.reload(); }
const hardReloButn = document.getElementById('hardReloadBtn'), hardCmdzButn = document.getElementById('hardReloadCmdBtn');
hardReloButn.addEventListener('click', hardReloExec);
hardCmdzButn.addEventListener('click', hardReloExec);
const MINI_MESG = { not_installed: 'mini panel not installed — run: npm install (in ui-elec-mini)', no_dir: 'ui-elec-mini folder is missing', spawn_failed: 'could not start the mini panel — try: npm install (in ui-mini)' };
function miniPanlOpen() { const mesgSayz = mesg => { inlineError.innerHTML = luci('monitor') + ' ' + mesg; inlineError.classList.add('show'); setTimeout(() => inlineError.classList.remove('show'), CFCT.miniMsgz); }; fetch('/open-mini').then(respObjz => respObjz.json()).then(respData => { if (!respData.launched) mesgSayz(MINI_MESG[respData.reason] || 'mini panel did not open'); }).catch(() => mesgSayz('mini panel request failed')); }
document.getElementById('cornMiniBtn').addEventListener('click', miniPanlOpen);
document.getElementById('cornSlot2Btn').disabled = true;
sessButn.addEventListener('click', () => { sessOver.classList.toggle('visible'); if (sessOver.classList.contains('visible')) { sessListRend(); sessInpt.focus(); } });
sessSaveButn.addEventListener('click', sessSaveCurr);
sessInpt.addEventListener('keydown', evnt => { if (evnt.key === 'Enter') { evnt.stopPropagation(); sessSaveCurr(); } if (evnt.key === 'Escape') { evnt.stopPropagation(); sessOver.classList.remove('visible'); } });
document.getElementById('sessCancBtn').addEventListener('click', () => sessOver.classList.remove('visible'));
sessOver.addEventListener('click', evnt => { if (evnt.target === sessOver) sessOver.classList.remove('visible'); });
document.addEventListener('keydown', evnt => { if (evnt.key === 'Escape' && sessOver.classList.contains('visible')) sessOver.classList.remove('visible'); });
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
