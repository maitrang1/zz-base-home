// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Boot config, restore tabs, wire page events
// Flo: fetch config + output > restore prefs + tabs > start poll > render panes > re-attach jobs > wire unload
// I/O: /config /output /jobs JSON (server) > UI state restored + unload beacons (DOM, server)
// ===================================================================
const CFBT = { resiWide: 100, resiWait: 3000, fontDefa: '13' };
;(async () => {
const bootElem = document.getElementById('bootLoad'); let outpData = {}; const objzChek = valu => !!valu && typeof valu === 'object' && !Array.isArray(valu);
try { const resp = await fetch(SERVER + '/config'); if (resp.ok) { const data = await resp.json(); if (objzChek(data)) { conf = data; if (!conf._v) conf._v = 0; } } } catch {}
try { const resp = await fetch(SERVER + '/output'); if (resp.ok) { const data = await resp.json(); if (objzChek(data)) outpData = data; } } catch {}
bootElem.classList.remove('visible');
applyUiPrefs(); scrollLocked = stor.get('cmrn_scroll_lock') === '1'; wrapOn = stor.get('cmrn_wrap') === '1'; ansiOn = stor.get('cmrn_ansi') === '1'; tsOn = stor.get('cmrn_ts') === '1'; fontSz = parseInt(stor.get('cmrn_font') || CFBT.fontDefa);
cwdInp.value = stor.get('cmrn_cwd') || ''; shellSel.value = stor.get('cmrn_shell') || 'default'; watcPathInpu.value = stor.get('cmrn_watch_path') || '';
cmdHistory = JSON.parse(stor.get('cmrn_hist') || '[]'); favorites = JSON.parse(stor.get('cmrn_favs') || '[]').map(favz => typeof favz === 'string' ? { cmd: favz, group: null } : favz); favGroups = JSON.parse(stor.get('cmrn_fav_grps') || '[]');
let lablChng = { hist: 0, outp: 0 }; if (stor.get('cmrn_labl_v') !== '2') { lablChng = lablMigrRun(cmdHistory, outpData); if (lablChng.hist) stor.set('cmrn_hist', JSON.stringify(cmdHistory)); stor.set('cmrn_labl_v', '2'); }
const hour = new Date().getHours(); const saveThem = stor.get('cmrn_theme') || (hour >= 6 && hour < 18 ? 'light' : 'dark'); document.documentElement.dataset.theme = saveThem; applyThemeBtn(saveThem); try { localStorage.setItem('cmrn_theme', saveThem); } catch {}
const tabzSaveRawz = JSON.parse(stor.get('cmrn_tabs') || 'null'); const outpKeyz = Object.keys(outpData); const labeRawz = Array.isArray(tabzSaveRawz) ? tabzSaveRawz : (tabzSaveRawz?.labels || null); const rawzUsez = !!labeRawz; const tabzSaveLabe = rawzUsez ? labeRawz : (outpKeyz.length ? outpKeyz : ['main']);
const tabzSaveColo = rawzUsez ? (tabzSaveRawz?.colors || []) : [], tabzSavePinz = rawzUsez ? (tabzSaveRawz?.pins || []) : [], tabzSaveEnvz = rawzUsez ? (tabzSaveRawz?.envs || []) : [], tabzSaveCmdz = rawzUsez ? (tabzSaveRawz?.cmds || []) : [], tabzSaveHist = rawzUsez ? (tabzSaveRawz?.hists || []) : [], tabzSaveLast = rawzUsez ? (tabzSaveRawz?.lastUsed || []) : [], tabzSaveOpen = rawzUsez ? (tabzSaveRawz?.envOpen || []) : [], tabzSaveScro = rawzUsez ? (tabzSaveRawz?.scrolls || []) : [], tabzSaveActi = rawzUsez ? (tabzSaveRawz?.actIdx ?? 0) : 0;
tabzSaveLabe.forEach((name, indx) => { const tabz = createTab(name, false, tabzSaveColo[indx] || null, false); if (tabzSavePinz[indx]) { tabz.pinned = true; const elem = termTabsEl.querySelector(`.tab[data-tab-id="${tabz.id}"]`); if (elem) { elem.classList.add('pinned'); tabz.pinEl.title = 'pinned'; tabz.pinEl.innerHTML = luci('pin-off'); lucide.createIcons(); } } if (Array.isArray(tabzSaveEnvz[indx])) tabz.envVars = tabzSaveEnvz[indx]; if (tabzSaveCmdz[indx]) tabz.cmd = tabzSaveCmdz[indx]; if (Array.isArray(tabzSaveHist[indx])) tabz.hist = tabzSaveHist[indx]; if (tabzSaveLast[indx]) tabz.lastUsed = tabzSaveLast[indx]; tabz.envzOpen = !!tabzSaveOpen[indx]; });
if (tabs[tabzSaveActi]?.envzOpen) { envzPaneOpen = true; envzPanl.classList.add('open'); }
tabs.forEach(tabz => { if (outpData[tabz.label]) restoreTabOutp(tabz, outpData[tabz.label]); });
if (lablChng.outp) saveOutp();
if (tabs[tabzSaveActi]) switchTab(tabs[tabzSaveActi].id); tabsInitDone = true; updateEnvBtn(activeTab); saveTabs();
pollStar(); if (stor.get('cmrn_watch_open') === '1') watcPane.classList.add('open'); if (stor.get('cmrn_watch_activ') === '1' && watcPathInpu.value.trim()) watcStar(); lucide.createIcons();
applyScrollLock(); applyWrap(); applyAnsi(); applyTs(); applyFont();
tabs.forEach((tabz, indx) => { if (!tabz.blocks.length) return; openBlockAt(tabz, 0); if (tabzSaveScro[indx] && tabz.bodyEl) tabz.bodyEl.scrollTop = tabzSaveScro[indx]; });
if (stor.get('cmrn_srch_open') === '1') { const quer = stor.get('cmrn_srch_q') || ''; searchInput.value = quer; openSearch(); if (quer) doSearch(quer); }
const histSaveFilt = stor.get('cmrn_hist_filt') || ''; if (histSaveFilt) { histSearch.value = histSaveFilt; histFilter = histSaveFilt.toLowerCase(); } renderHistory();
const favzSaveFilt = stor.get('cmrn_fav_filt') || ''; if (favzSaveFilt) { favSearch.value = favzSaveFilt; favFilter = favzSaveFilt.toLowerCase(); } renderFavorites();
touchDragEmulate(favList, '.fav-drag-handle', '.fav-item');
const scheSaveFilt = stor.get('cmrn_sche_filt') || ''; if (scheSaveFilt) { scheSearch.value = scheSaveFilt; scheFilter = scheSaveFilt.toLowerCase(); }
initSchePanel();
try { const resp = await fetch(SERVER + '/jobs'); const data = resp.ok ? await resp.json() : null; let jobzNewe = null; for (const jobz of (data?.jobs || [])) { if (jobz.done || !jobz.keep || jobz.chain || liveJobs.has(jobz.id)) continue; const tabz = tabs.find(tabx => tabx.label === jobz.tab) || activeTab; execCmd(jobz.cmd, false, { jobId: jobz.id, tab: tabz, paused: !!jobz.paused }); if (!jobzNewe || jobz.started > jobzNewe.star) jobzNewe = { star: jobz.started, tab: tabz }; } if (jobzNewe && jobzNewe.tab !== activeTab) switchTab(jobzNewe.tab.id); } catch {}
let evicFlag = false;
try { const chanBroa = new BroadcastChannel('cmrn-tab'); chanBroa.postMessage('claim'); chanBroa.onmessage = evnt => { if (evnt.data !== 'claim' || evicFlag) return; evicFlag = true; document.body.classList.add('tab-evicted'); const bann = document.createElement('div'); bann.className = 'evicted-banner'; bann.innerHTML = 'auto-task is open in another tab. <button id="evictTake">use this tab instead</button>'; document.body.appendChild(bann); document.getElementById('evictTake').onclick = () => location.reload(); }; } catch {}
let lastWide = window.innerWidth, resiTime = null;
window.addEventListener('resize', () => { if (Math.abs(window.innerWidth - lastWide) <= CFBT.resiWide) return; clearTimeout(resiTime); resiTime = setTimeout(() => { if (Math.abs(window.innerWidth - lastWide) > CFBT.resiWide) location.reload(); }, CFBT.resiWait); });
window.addEventListener('pagehide', () => { if (pageQury && !evicFlag) try { fetch(SERVER + '/ping?ui=0', { keepalive: true }); } catch {} });
window.addEventListener('beforeunload', () => { if (evicFlag) return; for (const iden of liveJobs.keys()) { navigator.sendBeacon(SERVER + '/job/keep', new Blob([JSON.stringify({ id: iden })], { type: 'application/json' })); } saveTabs(); if (confDirty.size) { const patc = {}; for (const keyz of confDirty) patc[keyz] = keyz in conf ? conf[keyz] : null; confDirty.clear(); navigator.sendBeacon(SERVER + '/config/patch' + (saveConf._clr ? '?clear=1' : ''), new Blob([JSON.stringify(patc)], { type: 'application/json' })); } const outpSave = {}; tabs.forEach(tabz => { if (tabz.blocks.length) outpSave[tabz.label] = tabz.blocks; }); navigator.sendBeacon(SERVER + '/output', new Blob([JSON.stringify(outpSave)], { type: 'application/json' })); });
})();
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
