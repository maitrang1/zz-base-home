// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Theme, export, output copy, sidebar resize, tabs
// Flo: bind theme > export > output > sidebar > scroll lock
// I/O: User clicks and drags (browser) > DOM mutations, saved prefs, text export
// ===================================================================
const CFCT = { slugMaxz: 40, exprDela: 10000, exprMsgz: 2000, sideMinz: 140, sideMaxz: 0.8, narwQuer: '(max-width: 900px)', paltMaxz: 20, paltSche: 5, sessMsgz: 2500, miniMsgz: 3500, viewGutr: 8, confWide: 170, moreWide: 70 };
function applyThemeBtn(themName) { themeBtn.innerHTML = themName === 'light' ? '<i data-lucide="moon"></i>' : '<i data-lucide="sun"></i>'; lucide.createIcons({ nodes: [themeBtn] }); }
themeBtn.onclick = () => { const themLigh = document.documentElement.dataset.theme !== 'light'; const themName = themLigh ? 'light' : 'dark'; document.documentElement.dataset.theme = themName; stor.set('cmrn_theme', themName); try { localStorage.setItem('cmrn_theme', themName); } catch {} applyThemeBtn(themName); };
function expoSlug(textVal) { const slugOutp = String(textVal || '').replace(/[^a-zA-Z0-9._-]+/g, '-').replace(/^-+|-+$/g, '').slice(0, CFCT.slugMaxz); return slugOutp || 'session'; }
exportBtn.onclick = () => {
const lineList = [];
[...activeTab.blocks].reverse().forEach(({ cmd: blokCmdz, data: blokData, ts: blokTime }) => { const exitCode = Number.isFinite(blokData.code) ? blokData.code : '?'; const stamText = fmtStamp(blokTime); lineList.push(`[${stamText}] exit:${exitCode} · ${fmtElapsed(blokData.elapsed)}`); lineList.push(`$ ${blokCmdz}`); if (blokData.cwd) lineList.push(`# cwd: ${blokData.cwd}`); if (blokData.stdout) lineList.push(blokData.stdout); if (blokData.stderr) lineList.push('[stderr]\n' + blokData.stderr); lineList.push('---\n'); });
if (!lineList.length) { sbCmd.textContent = 'nothing to export'; setTimeout(() => { sbCmd.textContent = '—'; }, CFCT.exprMsgz); return; }
lineList.unshift(`# auto-task session · tab "${activeTab.label}" · ${activeTab.blocks.length} block(s) · exported ${fmtStamp(new Date())}`, '# note: each block output is capped at 5KB', '');
const blobUrlz = URL.createObjectURL(new Blob([lineList.join('\n')], { type: 'text/plain;charset=utf-8' }));
const linkElem = document.createElement('a');
linkElem.href = blobUrlz;
linkElem.download = `session-${expoSlug(activeTab.label)}-${fmtStamp(new Date())}.txt`;
linkElem.click();
setTimeout(() => URL.revokeObjectURL(blobUrlz), CFCT.exprDela);
};
function clearOutput() { const bodyElem = activeTab.bodyEl; if (!bodyElem.querySelector('.block:not([data-pinned]):not(.is-detached)')) return; showConfPop(document.getElementById('clearOutBtn'), 'clear output in this tab?', () => { bodyElem.querySelectorAll('.block:not([data-pinned]):not(.is-detached), .block-sep').forEach(elemItem => elemItem.remove()); activeTab.blocks = activeTab.blocks.filter(blokItem => blokItem.pinned); if (!bodyElem.querySelector('.block')) bodyElem.innerHTML = '<div class="empty-term"><div class="empty-term-big">$_</div><div>ready</div></div>'; saveOutp(true); }, true); }
function copyOutput() { const textAll = [...activeTab.bodyEl.querySelectorAll('.line')].map(lineElem => lineElem.textContent).join('\n'); navigator.clipboard.writeText(textAll).catch(() => {}); }
window.clearOutput = clearOutput;
window.copyOutput = copyOutput;
function topbHighSync() { const barzElem = document.querySelector('.topbar'); if (!barzElem) return; const barzHigh = Math.round(barzElem.getBoundingClientRect().height); if (barzHigh > 0) document.documentElement.style.setProperty('--topBarHei', barzHigh + 'px'); }
let sideDrag = false;
function applyUiPrefs() { topbHighSync(); const saveWide = stor.get('cmrn_side_w'); const saveColl = stor.get('cmrn_side_coll') === '1'; sidebar.style.transition = 'none'; if (saveWide) sidebar.style.width = saveWide; if (saveColl && !window.matchMedia(CFCT.narwQuer).matches) sidebar.classList.add('collapsed'); requestAnimationFrame(() => { sidebar.style.transition = ''; }); sideTabzInit(); }
sidebarResize.addEventListener('mousedown', evnt => { if (window.matchMedia(CFCT.narwQuer).matches) return; sideDrag = true; document.body.style.cursor = 'col-resize'; evnt.preventDefault(); });
document.addEventListener('mousemove', evnt => { if (!sideDrag) return; const sideWide = evnt.clientX; if (sideWide >= CFCT.sideMinz && sideWide <= window.innerWidth * CFCT.sideMaxz) sidebar.style.width = sideWide + 'px'; });
document.addEventListener('mouseup', () => { if (sideDrag) { sideDrag = false; document.body.style.cursor = ''; stor.set('cmrn_side_w', sidebar.style.width); } });
sidebarResize.addEventListener('touchstart', evnt => { if (window.matchMedia(CFCT.narwQuer).matches) return; sideDrag = true; evnt.preventDefault(); }, { passive: false });
document.addEventListener('touchmove', evnt => { if (!sideDrag) return; const sideWide = evnt.touches[0].clientX; if (sideWide >= CFCT.sideMinz && sideWide <= window.innerWidth * CFCT.sideMaxz) sidebar.style.width = sideWide + 'px'; }, { passive: false });
document.addEventListener('touchend', () => { if (sideDrag) { sideDrag = false; stor.set('cmrn_side_w', sidebar.style.width); } });
document.getElementById('sidebarToggleBtn').onclick = () => { if (window.matchMedia(CFCT.narwQuer).matches) return; sidebar.classList.toggle('collapsed'); stor.set('cmrn_side_coll', sidebar.classList.contains('collapsed') ? '1' : '0'); };
window.addEventListener('resize', topbHighSync);
let sideTabzActi = null;
function sideTabzInit() {
const sideTabs = [...document.querySelectorAll('.sidebar-tab')];
const tabzActi = (tabzIden, keepSave = false) => { const rediFlag = tabzIden === 'outpSectTab' && !mobiMq.matches; const saveIden = rediFlag && keepSave ? 'outpSectTab' : (rediFlag ? 'favSectTab' : tabzIden); if (rediFlag) tabzIden = 'favSectTab'; sideTabs.forEach(tabzItem => tabzItem.classList.toggle('active', tabzItem.id === tabzIden)); document.querySelectorAll('.sidebar-panel').forEach(panlItem => panlItem.classList.toggle('active', panlItem.id === document.getElementById(tabzIden).dataset.panel)); stor.set('cmrn_sidebar_tab', saveIden); if (grpDropEl) { grpDropEl.remove(); grpDropEl = null; } closeLablPopu(); };
sideTabzActi = tabzActi;
sideTabs.forEach(tabzItem => tabzItem.addEventListener('click', () => tabzActi(tabzItem.id)));
const saveTabz = stor.get('cmrn_sidebar_tab');
if (saveTabz && document.getElementById(saveTabz)) tabzActi(saveTabz, true);
}
mobiMq.addEventListener('change', () => { if (sideTabzActi && stor.get('cmrn_sidebar_tab') === 'outpSectTab') { sideTabzActi('outpSectTab', true); } });
function applyScrollLock() { scrollLockBtn.classList.toggle('locked', scrollLocked); scrollLockBtn.innerHTML = luci(scrollLocked ? 'lock' : 'lock-open') + '<span class="btn-label"> scroll</span>'; lucide.createIcons({ nodes: [scrollLockBtn] }); }
scrollLockBtn.onclick = () => { scrollLocked = !scrollLocked; stor.set('cmrn_scroll_lock', scrollLocked ? '1' : '0'); applyScrollLock(); };
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
