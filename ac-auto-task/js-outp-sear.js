// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Output display toggles, text search, block filter
// Flo: toggle ANSI/ts/wrap/font > open search > mark matches > filter blocks
// I/O: toggle clicks + query (UI) > styled body, marks, filtered blocks
// ===================================================================
const ansiButt = document.getElementById('ansiBtn');
function applyAnsi() { document.querySelectorAll('.term-body').forEach(blkz => blkz.classList.toggle('ansi-on', ansiOn)); ansiButt.classList.toggle('active', ansiOn); }
ansiButt.onclick = () => { ansiOn = !ansiOn; stor.set('cmrn_ansi', ansiOn ? '1' : '0'); applyAnsi(); };
const stmpButt = document.getElementById('tsBtn');
function applyTs() { document.querySelectorAll('.term-body').forEach(blkz => blkz.classList.toggle('ts-on', tsOn)); stmpButt.classList.toggle('active', tsOn); }
stmpButt.onclick = () => { tsOn = !tsOn; stor.set('cmrn_ts', tsOn ? '1' : '0'); applyTs(); };
function applyWrap() { document.querySelectorAll('.term-body').forEach(blkz => { blkz.classList.toggle('wrap-on', wrapOn); blkz.classList.toggle('wrap-off', !wrapOn); }); wrapBtn.classList.toggle('active', wrapOn); }
wrapBtn.onclick = () => { wrapOn = !wrapOn; stor.set('cmrn_wrap', wrapOn ? '1' : '0'); applyWrap(); };
function applyFont() { document.querySelectorAll('.term-body').forEach(blkz => blkz.style.fontSize = fontSz + 'px'); }
document.getElementById('fontDecBtn').onclick = () => { if (fontSz > CF_OUTP.fontMinz)  { fontSz--; stor.set('cmrn_font', fontSz); applyFont(); } };
document.getElementById('fontIncBtn').onclick = () => { if (fontSz < CF_OUTP.fontMaxz) { fontSz++; stor.set('cmrn_font', fontSz); applyFont(); } };
function openSearch()  { searchBar.classList.add('visible'); searchInput.focus(); searchInput.select(); stor.set('cmrn_srch_open', '1'); }
function closeSearch() { searchBar.classList.remove('visible'); highClea(); searchMatches = []; searchIdx = -1; searchCount.textContent = '0 results'; stor.set('cmrn_srch_open', '0'); }
function highClea() { activeTab?.bodyEl.querySelectorAll('.line[data-orig-html]').forEach(line => { line.innerHTML = line.dataset.origHtml; delete line.dataset.origHtml; }); }
function doSearch(quer) { highClea(); searchMatches = []; searchIdx = -1; if (!quer.trim()) { searchCount.textContent = '0 results'; return; } const rgex = new RegExp(quer.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'gi'); activeTab.bodyEl.querySelectorAll('.line').forEach(line => { if (!rgex.test(line.textContent)) return; rgex.lastIndex = 0; if (!line.dataset.origHtml) line.dataset.origHtml = line.innerHTML; line.innerHTML = esc(line.textContent).replace(rgex, mtch => `<mark>${esc(mtch)}</mark>`); line.querySelectorAll('mark').forEach(mark => searchMatches.push(mark)); }); searchCount.textContent = searchMatches.length + ' result' + (searchMatches.length !== 1 ? 's' : ''); if (searchMatches.length) { searchIdx = 0; mtchScro(0); } }
function mtchScro(inde) { searchMatches.forEach((mark, indx) => mark.classList.toggle('current', indx === inde)); searchMatches[inde]?.scrollIntoView({ block: 'center' }); }
searchInput.addEventListener('input', () => { doSearch(searchInput.value); stor.set('cmrn_srch_q', searchInput.value); });
document.getElementById('searchNext').onclick = () => { if (!searchMatches.length) return; searchIdx = (searchIdx + 1) % searchMatches.length; mtchScro(searchIdx); };
document.getElementById('searchPrev').onclick = () => { if (!searchMatches.length) return; searchIdx = (searchIdx - 1 + searchMatches.length) % searchMatches.length; mtchScro(searchIdx); };
searchToggleBtn.onclick = () => searchBar.classList.contains('visible') ? closeSearch() : openSearch();
searchClose.onclick = closeSearch;
const outpSear = document.getElementById('outpSearch');
function applyOutpFilter() { if (!activeTab) return; const quer = outpSear.value.trim().toLowerCase(); const blks = [...activeTab.bodyEl.querySelectorAll(':scope > .block')]; blks.forEach(bloc => { const cmdz = bloc.querySelector('.block-cmd')?.dataset.cmd || ''; const show = !quer || cmdz.toLowerCase().includes(quer); bloc.style.display = show ? '' : 'none'; const sepa = bloc.nextElementSibling; if (sepa && sepa.classList.contains('block-sep')) sepa.style.display = show ? '' : 'none'; }); }
outpSear.addEventListener('input', applyOutpFilter);
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
