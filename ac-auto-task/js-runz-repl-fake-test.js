// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Fake page and clock shared by reply tests
// Flo: build elements, timers and a server stub > load js-runz-repl.js > hand out jobs
// I/O: none > mkPage and flush for the two reply test files
// Use: required by js-runz-repl-test.js and js-runz-repl-wait-test.js
// ===================================================================
const fs = require('fs'); const vm = require('vm'); const path = require('path');
const flush = async () => { for (let indx = 0; indx < 8; indx++) await new Promise(done => setImmediate(done)); };
function mkPage() {
class Elem { constructor(tag) { this.tag = tag; this.kids = []; this.parent = null; this.lstn = {}; this.value = ''; this.className = ''; this.textContent = ''; this.flag = new Set(); const self = this; this.classList = { toggle: (nam, forc) => { const want = forc === undefined ? !self.flag.has(nam) : forc; if (want) self.flag.add(nam); else self.flag.delete(nam); return want; }, contains: nam => self.flag.has(nam), add: nam => self.flag.add(nam), remove: nam => self.flag.delete(nam) }; }
appendChild(kid) { kid.parent = this; this.kids.push(kid); return kid; } remove() { if (this.parent) this.parent.kids = this.parent.kids.filter(kid => kid !== this); this.parent = null; } focus() { page.doc.activeElement = this; } addEventListener(type, func) { (this.lstn[type] = this.lstn[type] || []).push(func); } fire(type, evnt) { const made = Object.assign({ key: '', preventDefault() { this.stopz = true; }, stopPropagation() { this.halt = true; } }, evnt); (this.lstn[type] || []).forEach(func => func(made)); return made; } }
const page = { posts: [], script: {}, now: 0, jobs: new Map(), idn: 0, Elem }; page.doc = { body: new Elem('body'), createElement: tag => new Elem(tag) }; page.doc.activeElement = page.doc.body;
page.setTimeout = (func, msec) => { const iden = ++page.idn; page.jobs.set(iden, { at: page.now + msec, func }); return iden; }; page.clearTimeout = iden => { page.jobs.delete(iden); };
page.tick = async msec => { await flush(); const end = page.now + msec; for (;;) { let next = null; for (const [iden, job] of page.jobs) if (job.at <= end && (!next || job.at < next[1].at)) next = [iden, job]; if (!next) break; page.now = next[1].at; page.jobs.delete(next[0]); next[1].func(); await flush(); } page.now = end; await flush(); };
page.fetch = async (url, opts) => { const body = JSON.parse(opts.body); const plan = page.script[body.jobId]; const code = plan && plan.length ? plan.shift() : 200; page.posts.push({ jobId: body.jobId, data: body.data, code }); return { status: code }; };
page.tab = () => ({ id: ++page.idn, dotEl: new Elem('div') }); page.activeTab = null;
const ctxz = vm.createContext({ document: page.doc, SERVER: 'http://s', setTimeout: page.setTimeout, clearTimeout: page.clearTimeout, fetch: page.fetch, activeTab: null }); vm.runInContext(fs.readFileSync(path.join(__dirname, 'js-runz-repl.js'), 'utf8'), ctxz); page.ctx = ctxz;
page.job = (tabz, jobz, lines) => { const bloc = new Elem('div'), outz = new Elem('div'); bloc.appendChild(outz); const ctrl = ctxz.replMake({ jobz, bloc, outz, tabz, lines }); return { ctrl, bloc, outz }; };
page.setActive = tabz => { ctxz.activeTab = tabz; };
page.sent = jobz => page.posts.filter(post => post.jobId === jobz).map(post => post.data); page.echoes = outz => outz.kids.map(kid => kid.textContent);
return page; }
module.exports = { mkPage, flush };
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
