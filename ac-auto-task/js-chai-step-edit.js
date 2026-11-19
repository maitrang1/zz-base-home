// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Chain editor overlay, steps, and chain run
// Flo: open editor > render steps > pick fav > save > run chain
// I/O: favorite entry (object, sidebar) > chain steps, running tabs (DOM, stor)
// ===================================================================
let chaiEditEntr = null, chaiEditCmds = [], chaiEditCond = 'success';
const chaiOver = document.getElementById('chainOverlay'), chaiStepElem = document.getElementById('chainSteps'), chaiAddzInpu = document.getElementById('chainAddInp'), chaiCondSucc = document.getElementById('chainCondSucc'), chaiCondAlwa = document.getElementById('chainCondAlwa');
function chaiStepRend() { chaiStepElem.innerHTML = ''; chaiEditCmds.forEach((cmdz, indx) => { const rowz = document.createElement('div'); rowz.className = 'chain-step' + (indx === 0 ? ' is-first' : ''); const arro = document.createElement('span'); arro.className = 'chain-step-arrow'; arro.textContent = '→'; const numb = document.createElement('span'); numb.className = 'chain-step-idx'; numb.textContent = indx + 1; const cmdzElem = document.createElement('span'); cmdzElem.className = 'chain-step-cmd'; cmdzElem.textContent = cmdz; cmdzElem.title = cmdz; const delz = document.createElement('span'); delz.className = 'chain-step-del'; delz.innerHTML = luci('x'); delz.onclick = () => { if (chaiEditCmds.length <= 1) return; chaiEditCmds.splice(indx, 1); chaiStepRend(); lucide.createIcons(); }; rowz.appendChild(arro); rowz.appendChild(numb); rowz.appendChild(cmdzElem); rowz.appendChild(delz); chaiStepElem.appendChild(rowz); }); lucide.createIcons(); }
function chaiEditOpen(entr) { chaiEditEntr = entr; chaiEditCmds = [entr.cmd, ...(entr.chain || [])]; chaiEditCond = entr.chainCond || 'success'; chaiStepRend(); chaiAddzInpu.value = ''; chaiCondSucc.classList.toggle('active', chaiEditCond === 'success'); chaiCondAlwa.classList.toggle('active', chaiEditCond === 'always'); chaiOver.classList.add('visible'); lucide.createIcons(); }
const chaiFavoDrop = document.getElementById('chainFavDrop');
function chaiFavoDropRend() { const quer = chaiAddzInpu.value.toLowerCase(), favoList = favorites.filter(favz => !quer || favz.cmd.toLowerCase().includes(quer)); chaiFavoDrop.innerHTML = ''; if (!favoList.length) { chaiFavoDrop.classList.remove('open'); return; } favoList.forEach(favz => { const item = document.createElement('div'); item.className = 'chain-fav-drop-item'; item.textContent = favz.cmd; item.title = favz.cmd; item.addEventListener('mousedown', evnt => { evnt.preventDefault(); chaiAddzInpu.value = favz.cmd; chaiFavoDrop.classList.remove('open'); document.getElementById('chainAddBtn').click(); chaiFavoDropRend(); }); chaiFavoDrop.appendChild(item); }); chaiFavoDrop.classList.add('open'); }
chaiAddzInpu.addEventListener('input', chaiFavoDropRend);
chaiAddzInpu.addEventListener('focus', chaiFavoDropRend);
chaiAddzInpu.addEventListener('blur', () => setTimeout(() => chaiFavoDrop.classList.remove('open'), CFHI.blurWait));
document.getElementById('chainAddBtn').onclick = () => { const valu = chaiAddzInpu.value.trim(); if (!valu) return; chaiEditCmds.push(valu); chaiAddzInpu.value = ''; chaiFavoDrop.classList.remove('open'); chaiStepRend(); };
chaiAddzInpu.addEventListener('keydown', evnt => { if (evnt.key === 'Enter') document.getElementById('chainAddBtn').click(); else if (evnt.key === 'Escape' && chaiFavoDrop.classList.contains('open')) { evnt.stopPropagation(); chaiFavoDrop.classList.remove('open'); } });
chaiCondSucc.onclick = () => { chaiEditCond = 'success'; chaiCondSucc.classList.add('active'); chaiCondAlwa.classList.remove('active'); };
chaiCondAlwa.onclick = () => { chaiEditCond = 'always'; chaiCondAlwa.classList.add('active'); chaiCondSucc.classList.remove('active'); };
document.getElementById('chainDelBtn').onclick = evnt => { if (!chaiEditEntr) return; showConfPop(evnt.currentTarget, 'delete this whole chain?', () => { chaiEditEntr.chain = []; delete chaiEditEntr.chainCond; favsSave(); renderFavorites(); chaiOver.classList.remove('visible'); chaiEditEntr = null; }); };
document.getElementById('chainCancBtn').onclick = () => { chaiOver.classList.remove('visible'); chaiEditEntr = null; };
document.getElementById('chainSaveBtn').onclick = () => { if (!chaiEditEntr) return; chaiEditEntr.cmd = chaiEditCmds[0]; chaiEditEntr.chain = chaiEditCmds.slice(1); chaiEditEntr.chainCond = chaiEditCond; favsSave(); renderFavorites(); chaiOver.classList.remove('visible'); chaiEditEntr = null; };
chaiOver.addEventListener('click', evnt => { if (evnt.target === chaiOver) { chaiOver.classList.remove('visible'); chaiEditEntr = null; } });
document.addEventListener('keydown', evnt => { if (evnt.key === 'Escape' && chaiOver.classList.contains('visible')) { chaiOver.classList.remove('visible'); chaiEditEntr = null; } });
async function favoChaiRunz(entr) { if (!serverOk || activeTab.running) return; const stepList = [entr.cmd, ...(entr.chain || [])]; for (const step of stepList) { cmdInput.value = step; clearCmdBtn.style.display = 'block'; const code = await execCmd(step); if (entr.chainCond !== 'always' && code !== 0) break; } }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
