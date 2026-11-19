// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Electron mini window: browser page, pinned on top
// Flo: read port from aa-conf-main.json > attach or spawn backend > open window > inject pin + web buttons
// I/O: npm start, or backend /open-mini > floating window on http://127.0.0.1:<port>
// Run: cd /d "E:\zz-base-home\ac-auto-task\ui-elec-mini" && npm install && npm start
// ===================================================================
const CF = { port: 4000, dataDir: '.ac-auto-task', confFile: 'aa-conf-main.json', exeWin: 'auto-task.exe', exeNix: 'auto-task', winWide: 250, winHigh: 500, minWide: 100, minHigh: 100, maxWide: 3840, maxHigh: 2160, winLeft: 0, winTopz: 50, pollMsec: 300, pollMaxz: 20, portMsec: 400, saveMsec: 200, armMsec: 2000, title: 'local command runner' };
const { app, BrowserWindow, ipcMain, Menu, shell } = require('electron'); const { spawn, exec } = require('child_process'); const path = require('path'); const http = require('http'); const fs = require('fs'); const os = require('os'); const { injeMake } = require('./js-mini-inje.js');
try { const cfgz = JSON.parse(fs.readFileSync(path.join(__dirname, '..', CF.confFile), 'utf8')); if (Number.isInteger(cfgz.port)) CF.port = cfgz.port; if (typeof cfgz.apps_data_loca === 'string' && cfgz.apps_data_loca) CF.dataDir = cfgz.apps_data_loca; } catch {}
const MINI_FILE = path.join(os.homedir(), CF.dataDir, 'config-mini.json'); const SERV_URLZ = `http://127.0.0.1:${CF.port}`; const BACK_DIRZ = path.join(__dirname, '..'); const BACK_EXEZ = path.join(BACK_DIRZ, 'zig-out', 'bin', process.platform === 'win32' ? CF.exeWin : CF.exeNix);
let win = null; let servProc = null;
function miniLoad() { try { return JSON.parse(fs.readFileSync(MINI_FILE, 'utf8')); } catch { return {}; } }
function miniSave(data) { try { fs.mkdirSync(path.dirname(MINI_FILE), { recursive: true }); const tmpz = MINI_FILE + '.tmp'; fs.writeFileSync(tmpz, JSON.stringify(data), 'utf8'); fs.renameSync(tmpz, MINI_FILE); } catch {} }
function miniCurr(aotz) { const boun = win.getNormalBounds(); return { v: 2, x: boun.x, y: boun.y, w: boun.width, h: boun.height, aot: aotz }; }
function clamp(valu, minz, maxz) { return (typeof valu === 'number' && isFinite(valu)) ? Math.max(minz, Math.min(maxz, valu)) : null; }
function servWait(urlz, maxz, done) { let tris = 0; const chek = () => { http.get(urlz + '/ping', resp => { resp.resume(); done(); }).on('error', () => { tris++; if (tris >= maxz) { done(); return; } setTimeout(chek, CF.pollMsec); }); }; chek(); }
function servStar() { if (!fs.existsSync(BACK_EXEZ)) { console.error('auto-task backend not found at', BACK_EXEZ, '— start it manually, or run `zig build`'); return; } servProc = spawn(BACK_EXEZ, [String(CF.port)], { cwd: BACK_DIRZ, stdio: 'ignore', detached: false }); servProc.on('error', erro => console.error('backend spawn error:', erro)); }
function servKill() { if (!servProc) return; if (process.platform === 'win32') { try { exec(`taskkill /PID ${servProc.pid} /T /F`); } catch {} } else { servProc.kill('SIGTERM'); } servProc = null; }
function portOpen(port, done) { const reqz = http.get(`http://127.0.0.1:${port}/ping`, resp => { resp.resume(); done(true); }); reqz.on('error', () => done(false)); reqz.setTimeout(CF.portMsec, () => { reqz.destroy(); done(false); }); }
function reloHard() { if (!win) return; win.webContents.session.clearCache().finally(() => win.webContents.reloadIgnoringCache()); }
function wndoMake() {
const savd = miniLoad(); const sizW = clamp(savd.w, CF.minWide, CF.maxWide); const sizH = clamp(savd.h, CF.minHigh, CF.maxHigh); const posX = clamp(savd.x, -CF.maxWide, CF.maxWide); const posY = clamp(savd.y, -CF.maxHigh, CF.maxHigh);
win = new BrowserWindow({ show: false, width: CF.winWide, height: CF.winHigh, minWidth: CF.minWide, minHeight: CF.minHigh, resizable: true, alwaysOnTop: !!savd.aot, frame: true, autoHideMenuBar: true, title: CF.title, webPreferences: { preload: path.join(__dirname, 'js-mini-prel.js'), contextIsolation: true, nodeIntegration: false } });
win.setMenuBarVisibility(false);
if (savd.v === 2 || sizW === null || sizH === null) { const targ = { x: posX ?? CF.winLeft, y: posY ?? CF.winTopz, width: sizW ?? CF.winWide, height: sizH ?? CF.winHigh }; let wide = targ.width; let high = targ.height; for (let indx = 0; indx < 4; indx++) { win.setBounds({ ...targ, width: wide, height: high }); const actu = win.getBounds(); if (actu.width === targ.width && actu.height === targ.height) break; wide += targ.width - actu.width; high += targ.height - actu.height; } } else { win.setContentSize(sizW, sizH); win.setPosition(posX ?? CF.winLeft, posY ?? CF.winTopz); miniSave(miniCurr(!!savd.aot)); }
win.show();
win.webContents.on('did-finish-load', () => { win.webContents.executeJavaScript(injeMake(win.isAlwaysOnTop())).catch(console.error); });
win.webContents.on('before-input-event', (_, inpu) => { if (inpu.type === 'keyDown' && inpu.key === 'F12') win.webContents.openDevTools({ mode: 'detach' }); if (inpu.type === 'keyDown' && ((inpu.control && inpu.key.toLowerCase() === 'r') || inpu.key === 'F5')) reloHard(); });
servWait(SERV_URLZ, CF.pollMaxz, () => { win.webContents.session.clearCache().finally(() => { win.webContents.loadURL(SERV_URLZ, { extraHeaders: 'pragma: no-cache\n' }); }); });
let armd = false; let timr = null; setTimeout(() => { armd = true; }, CF.armMsec);
const saveNow = () => { clearTimeout(timr); timr = null; if (win && !win.isDestroyed()) miniSave(miniCurr(win.isAlwaysOnTop())); };
const saveBoun = () => { if (!armd) return; clearTimeout(timr); timr = setTimeout(saveNow, CF.saveMsec); };
win.on('move', saveBoun); win.on('resize', saveBoun);
const flus = () => { if (armd && timr) saveNow(); };
win.on('close', flus); win.on('session-end', flus); win.on('closed', () => { win = null; });
}
const gotLock = app.requestSingleInstanceLock();
if (!gotLock) { http.get(`${SERV_URLZ}/reload`, resp => { resp.resume(); app.quit(); }).on('error', () => app.quit()); } else {
app.on('second-instance', () => { if (win) { if (win.isMinimized()) win.restore(); win.focus(); } });
app.whenReady().then(() => { portOpen(CF.port, already => { if (!already) servStar(); wndoMake(); }); });
app.on('window-all-closed', () => { servKill(); app.quit(); });
}
app.on('activate', () => { if (!win) wndoMake(); });
ipcMain.on('toggle-always-on-top', () => { if (!win) return; const aotz = !win.isAlwaysOnTop(); win.setAlwaysOnTop(aotz); miniSave(miniCurr(aotz)); });
ipcMain.on('open-web', () => { shell.openExternal(SERV_URLZ); });
ipcMain.on('hard-reload', () => { reloHard(); });
ipcMain.on('context-menu', (_, { x, y } = {}) => { if (!win) return; const menu = Menu.buildFromTemplate([{ label: 'Inspect', click: () => { win.webContents.inspectElement(x, y); } }, { type: 'separator' }, { role: 'cut' }, { role: 'copy' }, { role: 'paste' }, { type: 'separator' }, { role: 'selectAll' }]); menu.popup({ window: win, x, y }); });
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
