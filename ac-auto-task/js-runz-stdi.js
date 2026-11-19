// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Answers box: one line per prompt for next run
// Flo: toggle pane > read lines > clear after the run starts
// I/O: answer text (input) > line list for execCmd
// ===================================================================
const answTogBtn = document.getElementById('answTogBtn'), answPane = document.getElementById('answPane'), answArea = document.getElementById('answArea');
function answLines() { const text = answArea.value.replace(/\r?\n$/, ''); return text === '' ? [] : text.split(/\r?\n/); }
function answClea() { answArea.value = ''; answTogBtn.classList.remove('active'); }
answTogBtn.addEventListener('click', () => { const open = answPane.classList.toggle('visible'); if (open) answArea.focus(); });
answArea.addEventListener('input', () => answTogBtn.classList.toggle('active', answArea.value !== ''));
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
