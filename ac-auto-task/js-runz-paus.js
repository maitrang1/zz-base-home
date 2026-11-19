// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Pause / resume buttons for a running block and a chain row
// Flo: click > POST /pause or /resume > trust the server answer > flip label, block mark, tab dot
// I/O: job or chain id + server answers > button elements (DOM)
// ===================================================================
const CFPA = { pausTxt: 'stop', resuTxt: 'play', pausIcon: 'pause', resuIcon: 'play' };
async function pausPost(iden, onzz) { try { const resp = await fetch(SERVER + (onzz ? '/pause' : '/resume'), { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ id: iden }) }); let erro = ''; try { erro = (await resp.json()).error || ''; } catch {} return { stat: resp.status, erro }; } catch { return { stat: 0, erro: 'offline' }; } }
function pausNext(answ, want) { if (answ.stat === 200) return want; if (answ.erro === 'already_paused') return true; if (answ.erro === 'not_paused') return false; return null; }
function pausLabl(butt, onzz, rowz) { butt.classList.toggle('is-paused', onzz); butt.title = onzz ? 'resume' : 'pause'; butt.innerHTML = luci(onzz ? CFPA.resuIcon : CFPA.pausIcon) + (rowz ? '' : '<span class="blk-lbl"> ' + (onzz ? CFPA.resuTxt : CFPA.pausTxt) + '</span>'); lucide.createIcons(); }
function pausMake({ iden, init = false, rowz = false, onSet = null, post = pausPost }) { const butt = document.createElement(rowz ? 'span' : 'button'); butt.className = rowz ? 'hist-run sche-paus-btn' : 'btn-blk btn-blk-paus'; let paus = !!init; let busy = false; pausLabl(butt, paus, rowz); butt.onclick = async evtn => { evtn.stopPropagation(); if (busy) return; busy = true; const want = !paus; let answ; try { answ = await post(iden, want); } finally { busy = false; } const next = pausNext(answ, want); if (next === null) return; paus = next; pausLabl(butt, paus, rowz); if (onSet) onSet(paus); }; if (onSet && paus) onSet(paus); return butt; }
function pausBlokMake(iden, bloc, tabz, init = false) { return pausMake({ iden, init, onSet: onzz => { bloc.classList.toggle('is-paused', onzz); if (tabz && tabz.dotEl) tabz.dotEl.classList.toggle('is-paused', onzz); } }); }
function pausRowzMake(task, after) { return pausMake({ iden: task.id, init: !!task.chain?.paused, rowz: true, post: async (iden, onzz) => { const answ = await pausPost(iden, onzz); if (after) after(); return answ; } }); }
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
