// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Mock pages for halt tests: captcha, block, ban, limit
// Flo: constant HTML strings > served by te-mock-page on fixed paths
// I/O: none (constants) > HTML bytes
// ===================================================================
const HEAD = "<!DOCTYPE html><html><head><meta charset=\"utf-8\"><title>fixture</title></head><body>";
const TAIL = "</body></html>";
pub const CAPT = HEAD ++ "<h1>Just a moment</h1><p>Please verify you are human.</p>" ++ TAIL;
pub const CHKP = HEAD ++ "<h1>Account suspended</h1><p>Your account has been suspended.</p>" ++ TAIL;
pub const BLOK = HEAD ++ "<h1>Access denied</h1><p>Your API key has been banned.</p>" ++ TAIL;
pub const RATE = HEAD ++ "<h1>Dashboard</h1><div role=\"dialog\"><p>Too many requests. Please slow down.</p></div>" ++ TAIL;
pub const SOLV = HEAD ++ "<h1>Just a moment</h1><p>Please verify you are human.</p><script>setTimeout(function(){location.href='/dashboard'},2500)</script>" ++ TAIL;
pub const CKIE = HEAD ++ "<h1>Cookie page</h1><div role=\"dialog\" id=\"ck\"><p>We use cookies</p></div>" ++ TAIL;
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
