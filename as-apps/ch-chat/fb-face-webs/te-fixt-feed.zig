// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Fake group feed page for the feed reader tests
// Flo: one page string with role=article posts: two with a permalink, one without
// I/O: none (constant) > HTML text served by te-mock-page under /feeds/
// ===================================================================
const HEAD = "<!DOCTYPE html><html><head><meta charset=\"utf-8\"><title>feed</title></head><body><h1>Group feed</h1>";
const TAIL = "</body></html>";
pub const FEED = HEAD ++ "<div role=\"article\"><h3><a href=\"/groups/12/user/9/\">Nguyen Van A</a></h3><a href=\"/groups/12/posts/555001/?ref=x\">1h</a><div>Toyota Fortuner 2017 số sàn 84.000 km giá 520 triệu. Liên hệ 0966.353.678</div></div><div role=\"article\"><h3><a href=\"/groups/12/user/8/\">Tran B</a></h3><a href=\"/groups/12/posts/555002/\">2h</a><div>Cần mua Mazda CX-5 đời 2020 tầm 700tr</div></div><div role=\"article\"><h3>No Link</h3><div>post without a permalink</div></div>" ++ TAIL;
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
