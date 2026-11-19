// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Confirm popup, more menu, global shortcuts
// Flo: show popup > confirm > bind more menu > bind shortcuts
// I/O: User clicks and keys (browser) > confirm callbacks, menu, shortcuts
// ===================================================================
let confPopz = null, confPopzAnch = null, confPopzClos = null;
function showConfPop(anchElem, mesg, confDone, hardFlag) {
if (!hardFlag && stor.get('cmrn_conf_skip') === '1') { confDone(); return; }
if (confPopz && confPopzAnch === anchElem) { confPopzClos(); return; }
if (confPopzClos) confPopzClos();
const popzElem = document.createElement('div'); popzElem.className = 'conf-pop'; confPopz = popzElem; confPopzAnch = anchElem;
const mesgElem = document.createElement('div'); mesgElem.className = 'conf-pop-msg'; mesgElem.textContent = mesg;
const rowzButn = document.createElement('div'); rowzButn.className = 'conf-pop-btns';
const cancButn = document.createElement('button'); cancButn.className = 'btn-sm'; cancButn.textContent = 'cancel';
const confButn = document.createElement('button'); confButn.className = 'btn-sm chain-del-btn'; confButn.textContent = 'delete';
const confClos = () => { popzElem.remove(); confPopz = null; confPopzAnch = null; confPopzClos = null; document.removeEventListener('click', confOffz); document.removeEventListener('keydown', confEscz); };
cancButn.onclick = evnt => { evnt.stopPropagation(); confClos(); };
confButn.onclick = evnt => { evnt.stopPropagation(); confClos(); confDone(); };
rowzButn.append(cancButn, confButn);
if (!hardFlag) { const skipLink = document.createElement('span'); skipLink.className = 'conf-pop-skip'; skipLink.textContent = 'never ask'; skipLink.onclick = evnt => { evnt.stopPropagation(); stor.set('cmrn_conf_skip', '1'); confClos(); confDone(); }; rowzButn.append(skipLink); }
popzElem.append(mesgElem, rowzButn);
document.body.appendChild(popzElem);
const anchRect = anchElem.getBoundingClientRect();
popzElem.style.cssText = `position:fixed;z-index:600;left:0px;top:${anchRect.bottom + DROP_GAP}px`;
requestAnimationFrame(() => { if (confPopz !== popzElem) return; const popzWide = popzElem.offsetWidth || CFCT.confWide; let popzLeft = anchRect.left; if (popzLeft + popzWide > window.innerWidth - CFCT.viewGutr) popzLeft = window.innerWidth - popzWide - CFCT.viewGutr; if (popzLeft < CFCT.viewGutr) popzLeft = CFCT.viewGutr; popzElem.style.left = popzLeft + 'px'; });
function confOffz(evnt) { if (confPopz && !popzElem.contains(evnt.target)) confClos(); }
function confEscz(evnt) { if (evnt.key === 'Escape') confClos(); }
confPopzClos = confClos;
setTimeout(() => document.addEventListener('click', confOffz), 0);
document.addEventListener('keydown', confEscz);
}
const moreButn = document.getElementById('moreBtn'), moreDrop = document.getElementById('moreDrop');
function moreDropClos() { moreDrop.classList.remove('open'); document.removeEventListener('click', moreDropOffz); }
function moreDropOffz(evnt) { if (!moreDrop.contains(evnt.target) && evnt.target !== moreButn) moreDropClos(); }
moreButn.addEventListener('click', evnt => { evnt.stopPropagation(); if (moreDrop.classList.contains('open')) { moreDropClos(); return; } const butnRect = moreButn.getBoundingClientRect(); moreDrop.classList.add('open'); const dropWide = moreDrop.offsetWidth || CFCT.moreWide; let dropLeft = butnRect.left; if (dropLeft + dropWide > window.innerWidth - CFCT.viewGutr) dropLeft = window.innerWidth - dropWide - CFCT.viewGutr; moreDrop.style.left = dropLeft + 'px'; moreDrop.style.top = (butnRect.bottom + DROP_GAP) + 'px'; setTimeout(() => document.addEventListener('click', moreDropOffz), 0); });
document.addEventListener('keydown', evnt => { if ((evnt.ctrlKey || evnt.metaKey) && evnt.key.toLowerCase() === 'k') { evnt.preventDefault(); evnt.stopPropagation(); paletteBar.classList.contains('visible') ? paltClos() : paltOpen(); } if ((evnt.ctrlKey || evnt.metaKey) && evnt.key === 'f') { evnt.preventDefault(); openSearch(); } if (evnt.key === 'Escape') { paltClos(); closeSearch(); moreDropClos(); browseOverlay.classList.remove('visible'); } });
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
