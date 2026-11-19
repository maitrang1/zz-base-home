// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Layout helpers, log regexes, color palette, UI state
// Flo: measure gap > place popups > define regexes > palette > state vars
// I/O: Computed CSS + stor (browser) > layout fns, palettes, state (globals)
// ===================================================================
const DROP_GAP = (() => { const valu = parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--dropGap')); return Number.isFinite(valu) ? valu : CFST.dropGapz; })();
function placeFixedByAnchor(elemFixd, anchElem, marg = CFST.anchMarg) { const anchRect = anchElem.getBoundingClientRect(); const elemRect = elemFixd.getBoundingClientRect(); let posiLeft = Math.min(Math.max(marg, anchRect.right - elemRect.width), innerWidth - elemRect.width - marg); let posiTopz = anchRect.bottom + DROP_GAP; if (posiTopz + elemRect.height > innerHeight - marg) posiTopz = anchRect.top - elemRect.height - DROP_GAP; posiTopz = Math.min(Math.max(marg, posiTopz), innerHeight - elemRect.height - marg); elemFixd.style.left = posiLeft + 'px'; elemFixd.style.top = posiTopz + 'px'; elemFixd.style.right = ''; }
function gridWidthFor(contElem, rowzSize) { const itemList = [...contElem.children]; if (itemList.length <= rowzSize) return null; const gridStyl = getComputedStyle(contElem); const gapzSize = parseFloat(gridStyl.columnGap) || 0; const padzHori = parseFloat(gridStyl.paddingLeft) + parseFloat(gridStyl.paddingRight); const bordHori = parseFloat(gridStyl.borderLeftWidth) + parseFloat(gridStyl.borderRightWidth); const cellWide = Math.max(...itemList.map(itemElem => itemElem.getBoundingClientRect().width)); return rowzSize * cellWide + (rowzSize - 1) * gapzSize + padzHori + bordHori + CFST.gridSlak; }
const HL_ERR_RE  = /\b(error|Error|ERROR|exception|Exception|EXCEPTION|fatal|Fatal|FATAL|fail|Fail|FAIL|failed|Failed|FAILED|stderr|STDERR|panic|Panic|PANIC|crash|Crash|CRASH|abort|Abort|ABORT|denied|Denied|DENIED|refused|Refused|REFUSED|invalid|Invalid|INVALID|undefined|null|NullPointer|segfault|traceback|Traceback)\b/g;
const HL_OK_RE   = /\b(success|Success|SUCCESS|done|Done|DONE|ok|OK|pass|Pass|PASS|passed|Passed|PASSED|complete|Complete|COMPLETE|completed|Completed|ready|Ready|READY|started|Started|running|Running|built|Built|compiled|Compiled|installed|Installed|connected|Connected|loaded|Loaded|saved|Saved|created|Created|updated|Updated|deleted|Deleted|finished|Finished)\b/g;
const HL_WARN_RE = /\b(warning|Warning|WARNING|warn|Warn|WARN|deprecated|Deprecated|DEPRECATED|skip|Skip|SKIP|skipped|Skipped|ignored|Ignored|missing|Missing|MISSING|timeout|Timeout|TIMEOUT|retry|Retry|slow|Slow|SLOW)\b/g;
const LABL_COLO = ['#1ABC9C','#16A085','#2ECC71','#27AE60','#3498DB','#2980B9','#9B59B6','#8E44AD','#F1C40F','#F39C12','#E67E22','#D35400','#E74C3C','#C0392B'];
const GRUP_COLO = LABL_COLO, TABC_PALT = LABL_COLO;
function peekColor(poolKeyz) { const usedCoun = JSON.parse(stor.get(poolKeyz) || '{}'); const minzCoun = Math.min(...LABL_COLO.map(coloItem => usedCoun[coloItem] || 0)); const candList = LABL_COLO.filter(coloItem => (usedCoun[coloItem] || 0) === minzCoun); return candList[Math.floor(Math.random() * candList.length)]; }
function claimColor(coloValu, poolKeyz) { const usedCoun = JSON.parse(stor.get(poolKeyz) || '{}'); usedCoun[coloValu] = (usedCoun[coloValu] || 0) + 1; stor.set(poolKeyz, JSON.stringify(usedCoun)); }
const liveJobs = new Map();
let cmdHistory = [], favorites = [], favGroups = [], histIndex = -1, tabs = [], activeTab = null, tabCounter = 0, searchMatches = [], searchIdx = -1;
let dragSrcIdx = null, dragGrpIdx = null, openDotsDrop = null;
let scrollLocked = false, wrapOn = false, ansiOn = false, tsOn = false, fontSz = 13, favFilter = '', scheFilter = '', histFilter = '', _platform = '';
let brwsForInpu = null, brwsCurrPath = '', brwsFlatList = [], brwsFiltText = '', brwsPreHigh = '';
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
