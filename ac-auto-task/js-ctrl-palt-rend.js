// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Command palette: open, filter, render, pick
// Flo: open palette > render rows > filter input > keys > close
// I/O: User typing and clicks (browser) > palette rows, run commands
// ===================================================================
let paltSele = 0;
function paltOpen() { const butnElem = document.getElementById('paletteBtn'); const butnRect = butnElem.getBoundingClientRect(); paletteBar.style.right = (window.innerWidth - butnRect.right) + 'px'; paletteBar.classList.add('visible'); paletteInput.value = ''; paletteInput.focus(); paltRend(''); }
function paltClos() { paletteBar.classList.remove('visible'); }
function paltRend(quer) {
const scheList = (typeof scheTasks !== 'undefined' ? scheTasks : []).filter(taskItem => taskItem && taskItem.kind === 'shell' && taskItem.run).map(taskItem => ({ type: 'sch', cmdz: taskItem.run, note: taskItem.id }));
const itemList = [...scheList, ...favorites.map(favoItem => ({ type: 'fav', cmdz: favoItem.cmd })), ...cmdHistory.map(histItem => ({ type: 'his', cmdz: histItem.cmd }))];
let itemFilt;
if (quer) { const querLowr = quer.toLowerCase(); itemFilt = itemList.filter(itemObjz => (itemObjz.cmdz + ' ' + (itemObjz.note || '')).toLowerCase().includes(querLowr)); } else { itemFilt = [...scheList.slice(0, CFCT.paltSche), ...itemList.filter(itemObjz => itemObjz.type !== 'sch')]; }
paletteResults.innerHTML = ''; paltSele = 0;
itemFilt.slice(0, CFCT.paltMaxz).forEach((itemObjz, itemIndx) => { const rowzElem = document.createElement('div'); rowzElem.className = 'palette-item' + (itemIndx === 0 ? ' selected' : ''); const noteHtml = itemObjz.note ? `<span class="palette-item-note">${esc(itemObjz.note)}</span>` : ''; rowzElem.innerHTML = `<span class="palette-item-type">${itemObjz.type}</span><span style="flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${esc(itemObjz.cmdz)}</span>${noteHtml}`; rowzElem.onclick = () => { cmdInput.value = itemObjz.cmdz; clearCmdBtn.style.display = 'block'; paltClos(); cmdInput.focus(); }; paletteResults.appendChild(rowzElem); });
}
paletteInput.addEventListener('input', () => paltRend(paletteInput.value));
paletteInput.addEventListener('keydown', evnt => { const rowzList = paletteResults.querySelectorAll('.palette-item'); if (evnt.key === 'ArrowDown') { evnt.preventDefault(); paltSele = Math.min(paltSele + 1, rowzList.length - 1); } else if (evnt.key === 'ArrowUp') { evnt.preventDefault(); paltSele = Math.max(paltSele - 1, 0); } else if (evnt.key === 'Enter') { rowzList[paltSele]?.click(); return; } else if (evnt.key === 'Escape') { paltClos(); return; } rowzList.forEach((rowzElem, rowzIndx) => rowzElem.classList.toggle('selected', rowzIndx === paltSele)); });
document.getElementById('paletteBtn').onclick = evnt => { evnt.stopPropagation(); paletteBar.classList.contains('visible') ? paltClos() : paltOpen(); };
document.addEventListener('click', evnt => { if (paletteBar.classList.contains('visible') && !paletteBar.contains(evnt.target)) paltClos(); });
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
