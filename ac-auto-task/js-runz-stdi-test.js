// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Unit tests for the answers box
// Flo: load js-runz-stdi.js in a fake page > type, read lines, clear > assert
// I/O: answer text > line list, button and pane state
// Run: node "E:\zz-base-home\ac-auto-task\js-runz-stdi-test.js"
// ===================================================================
const fs = require('fs'); const vm = require('vm'); const assert = require('assert'); const path = require('path'); let doneCoun = 0; const test = (name, func) => { try { func(); doneCoun++; } catch (erro) { console.error('FAIL ' + name + '\n' + erro.message); process.exitCode = 1; } };
class Elem { constructor() { this.lstn = {}; this.value = ''; this.flag = new Set(); const self = this; this.classList = { add: nam => self.flag.add(nam), remove: nam => self.flag.delete(nam), toggle: (nam, forc) => { const want = forc === undefined ? !self.flag.has(nam) : forc; if (want) self.flag.add(nam); else self.flag.delete(nam); return want; }, contains: nam => self.flag.has(nam) }; } focus() { Elem.focus = this; } addEventListener(type, func) { (this.lstn[type] = this.lstn[type] || []).push(func); } fire(type) { (this.lstn[type] || []).forEach(func => func({})); } }
function mkPage() { const ids = { answTogBtn: new Elem(), answPane: new Elem(), answArea: new Elem() }; const ctxz = vm.createContext({ document: { getElementById: ident => ids[ident] } }); vm.runInContext(fs.readFileSync(path.join(__dirname, 'js-runz-stdi.js'), 'utf8'), ctxz); return { ids, ctxz }; }
const lines = page => JSON.parse(JSON.stringify(page.ctxz.answLines()));
test('answers split by line; a final newline adds no empty answer; empty lines inside stay', () => { const page = mkPage(); for (const [text, want] of [['', []], ['a', ['a']], ['a\nb', ['a', 'b']], ['a\r\nb\r\n', ['a', 'b']], ['a\n\nb', ['a', '', 'b']], ['\n', []], ['\n\n', ['', '']], ['a\n\n', ['a', '']], [' a ', [' a ']]]) { page.ids.answArea.value = text; assert.deepStrictEqual(lines(page), want, JSON.stringify(text)); } });
test('clear empties the box and the button mark', () => { const page = mkPage(); page.ids.answArea.value = 'x'; page.ids.answArea.fire('input'); assert.strictEqual(page.ids.answTogBtn.flag.has('active'), true); page.ctxz.answClea(); assert.strictEqual(page.ids.answArea.value, ''); assert.strictEqual(page.ids.answTogBtn.flag.has('active'), false); });
test('the button opens and closes the pane and focuses the box when opening', () => { Elem.focus = null; const page = mkPage(); page.ids.answTogBtn.fire('click'); assert.strictEqual(page.ids.answPane.flag.has('visible'), true); assert.strictEqual(Elem.focus, page.ids.answArea); Elem.focus = null; page.ids.answTogBtn.fire('click'); assert.strictEqual(page.ids.answPane.flag.has('visible'), false); assert.strictEqual(Elem.focus, null); });
test('the button mark follows the text', () => { const page = mkPage(); page.ids.answArea.value = 'a'; page.ids.answArea.fire('input'); assert.strictEqual(page.ids.answTogBtn.flag.has('active'), true); page.ids.answArea.value = ''; page.ids.answArea.fire('input'); assert.strictEqual(page.ids.answTogBtn.flag.has('active'), false); });
console.log(doneCoun + ' passed' + (process.exitCode ? ', some FAILED' : ''));
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
