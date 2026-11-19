// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Electron preload: send-only IPC bridge for window chrome
// Flo: Electron loads preload > contextBridge exposes API > injected buttons call it
// I/O: none in > window.electronAPI = { toggleAlwaysOnTop, showContextMenu, openWeb, hardReload }
// Run: loaded by js-mini-main.js, never run alone
// ===================================================================
const { contextBridge, ipcRenderer } = require('electron');
contextBridge.exposeInMainWorld('electronAPI', { toggleAlwaysOnTop: () => ipcRenderer.send('toggle-always-on-top'), showContextMenu: (xzzz, yzzz) => ipcRenderer.send('context-menu', { x: xzzz, y: yzzz }), openWeb: () => ipcRenderer.send('open-web'), hardReload: () => ipcRenderer.send('hard-reload') });
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
