// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Sync run buttons and icons with run state
// Flo: read tab state > flip run icon > sync side lists and buttons
// I/O: tab state (memory) > run/abort icons (DOM)
// ===================================================================
function updateRunUi(tabz) { if (!tabz) return; const boxz = cmdInput.value.trim(); const typiNewz = tabz.running && boxz !== '' && boxz !== (tabz.runCmd || '').trim(); if (tabz.running && !typiNewz) { runBtn.style.display = 'none'; abortBtn.classList.add('visible'); } else { runBtn.style.display = ''; abortBtn.classList.remove('visible'); } }
function flipRunIcon(cmdz, abrt) { document.querySelectorAll(`.hist-run[data-cmd="${CSS.escape(cmdz)}"], .fav-run[data-cmd="${CSS.escape(cmdz)}"]`).forEach(elem => { elem.classList.toggle('is-abrt', abrt); elem.innerHTML = abrt ? luci('square') : luci('play'); elem.title = abrt ? 'stop' : 'run'; }); lucide.createIcons(); }
function sideRunzIconSync() { document.querySelectorAll('.hist-run[data-cmd], .fav-run[data-cmd]').forEach(elem => { const live = [...liveJobs.values()].some(jobz => jobz.cmd === elem.dataset.cmd); if (elem.classList.contains('is-abrt') === live) return; elem.classList.toggle('is-abrt', live); elem.innerHTML = live ? luci('square') : luci('play'); elem.title = live ? 'stop' : 'run'; }); lucide.createIcons(); }
function runzButtStatSync() { document.querySelectorAll('.btn-blk.is-abrt:not(.is-server-abrt)').forEach(elem => { elem.innerHTML = luci('play') + '<span class="blk-lbl"> run</span>'; elem.classList.remove('is-abrt'); lucide.createIcons(); }); renderHistory(); renderFavorites(); sideRunzIconSync(); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
