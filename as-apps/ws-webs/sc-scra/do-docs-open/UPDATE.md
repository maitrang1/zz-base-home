# Updates

## 0.12.0 — 2026-11-26
- Command-line contract: a wrong flag, unknown command or bad value now names itself on stderr and exits 2. `--help` prints to stdout (exit 0); no command prints usage to stderr (exit 2).
- Changed: a bad config now exits 2 (was 1). An unknown name in `aa-conf-main.json` now stops scra instead of being ignored: a typo can no longer silently turn a setting off.
- New: `--dry-run` (the default for writes); with `--live` it exits 2.
- New: `--json` always prints exactly one document, failures too, with `ok`, `cmd`, `exit`, `dry_run`, `code`, `msg`. Old fields are unchanged. `export --json` needs `--out`.
- New: one run at a time per data folder (`scra.lock`); a second live run exits 4. `kill` still works during a run.
- New: setting `runz_time_seco` (3300): a live `run` stops cleanly at this limit (exit 3, INCOMPLETE) so it ends before the hub step timeout (3600 s).

## 0.11.0 — 2026-11-26
- `scra cars` now builds rows for 7 more sites (muaban, oto360, vucar, vuabantai, fordassured, xetaitoanquoc, xedaukeocu); stored pages are parsed again.
- Fixed: phone numbers read as prices, category text read as the make, "Truck" or "SUV" read as the model, trailers classed as cars.

## 0.10.0 — 2026-11-26
- The visible browser window (`scra login`, or rendering with `brow_head_mode` true) now opens small at the left edge. Hidden rendering is unchanged. New settings brow_wind_widt, brow_wind_high, brow_wind_scal, brow_wind_left.
- The shipped values (500, 1008, 1.0, -7) give a 400 by 800 window on a Windows screen set to 125%. Other screens need their own numbers; 0 turns a setting off. The page is about 500 wide in this window. Not tried on a real logged-in account.

## 0.9.0 — 2026-11-25
- New mirror mode (`clou_mirr_enab`): each sync writes to all 3 object stores and all 3 databases in parallel instead of one vendor per run. The main vendor decides success; a down mirror is queued (stores) or spooled (databases) and catches up on its own.
- New weekly audit of every store: missing or wrong-size objects are queued again, a few are compared byte for byte.
- New monthly call counter per store so a free quota (Tigris 10000 write or list calls) is never passed; alerts at 80% and when paused.
- New settings clou_mirr_enab, clou_mirr_batz, clou_mirr_opsa_mont, clou_mirr_spoo_maxz. The sync line shows `mirror ...` counts. Off by default; nothing changes until you turn it on.

## 0.8.0 — 2026-11-25
- New commands `scra ingest` and `scra social`: Facebook and Zalo records from your own `fb` and `za` engines (JSON lines) are stored like fetched pages, so the cloud copy, purge, keepalive and alerts treat them the same. scra never logs in to either site.
- `scra cars` loads new records first and parses them like any listing. Sell posts become car rows; buyer posts ("cần mua") become rows with price 0 and seller `buyer`, left out of price roll-ups and look-alike groups. Phones are hashed, phones in text become `[tel]`, private names go only to the contact book.
- Public Facebook and Zalo pages are a new site group `social`, fetched with the usual ladder (own download first, vendors only inside free credits).
- New settings soci_* (CONFIG.md).

## 0.7.0 — 2026-11-25
- New contact book: name, phone, email, address and a short note of each seller, one row per phone (or per name and address when the phone is hidden). A full phone beats a masked one, a dealer beats a private seller.
- Only phones the page shows are stored. Nothing is clicked to reveal a number.
- Encrypted backups (XChaCha20-Poly1305): latest plus weekly copies, local and cloud, verified after each upload. The key lives in your key folder; `scra cont key` prints it once for an offline copy.
- Commands: `scra cont` (counts, `--live` backs up), `export` (vCard, or `--format csv`), `verify`, `restore <file>`, `forget <phone|id>`, `drop` (all private persons). Writing commands are dry-run unless `--live`.
- New settings cont_enab, cont_priv_enab, cont_week_keep. New hub step scra-cont. See PRIVACY.md.
- This replaces the 0.6.0 rule that private seller names are not kept.

## 0.6.1 — 2026-11-25
- 15 more sites in the daily run: used cars, pickups, trucks and tractor heads (muaban.net, oto360.net, vucar.vn, vuabantai.net, fordassured.com.vn, xetaitoanquoc.com, otohuynhgiaphat.com, xedaukeocu.com), price pages (danhgiaxe.com, gialanbanh.vn, toyota.com.vn) and buyer forums (tinhte.vn, otofun.net, otosaigon.com, forum.autodaily.vn). Seeds were added to the seed file.
- Forum sites follow at most 10 links per page, so they cannot use up the run's follow budget.
- Raw pages of the new sites are stored and synced. `scra cars` does not turn them into rows yet.

## 0.6.0 — 2026-11-25
- New command `scra cars`: parses stored car pages (7 sites) into rows with price, year, km, gearbox, fuel type (gas, diesel, hybrid, plug-in, mild hybrid, electric, LPG), condition, province, seller kind and more. Extra labels (inspection, warranty, payload for trucks) land in one JSON field.
- Change-only price history, gone detection (404/410, sold notice, not seen for 90 days), weekly market roll-ups kept forever, look-alike cluster ids across sites.
- Privacy: no private seller names, phone stored as a salted hash, raw phone erased 90 days after gone, phone numbers inside descriptions are masked.
- Retention by age: text 180 days, price history collapsed after 365, rows deleted after 730 (only after a roll-up). New settings carz_*.
- `scra cars export [--out file]` writes JSONL. `sync --live` copies the rows, price history and roll-ups to the cloud store (latest copy only).
- Link following now stays on the site of the page it came from (www and sub-domains count as the same site); links to other sites are ignored. `--follow n` is one budget for the whole run; the job now uses 800, with at most 30 links per page for the car sites.
- Site rules for the 6 daily car sites now follow only car pages (not menus), car pages follow nothing, and pages 2-5 of the listings are seeds. otofun left the daily run. Chain step scra-data added.

## 0.5.0 — 2026-11-24
- Cloud copy with failover: pages go to the first healthy store (B2, R2, Tigris), records to the first healthy database (Turso, Neon, TiDB). A failed vendor is skipped, and the next takes over in the same run.
- Purge in three layers: cloud pages (daily packs by age, newest copy of each page kept in a second-store copy), cloud database (blank old bodies, drop old gone rows), local files (30 days, verified only, 7 days in a trash folder). A dry-run plan with `scra purge`.
- Weekly keepalive on every vendor and a weekly download check of random packs. 20 new settings (purg_*, clou_fail_runs, clou_body_maxz, clou_sqlz_capz_mbyt); cloud caps now default to 80% of the free limits.
- Own GET timeouts are now a typed Timeout. JSON output of `sync` has new 4-letter keys (stor, purg, kept, comp, blan, gone, aged, pres, tras, veri, bads, lost, errs, alrt).
- Real-vendor drills passed: purge (pack to keep pack, second copy, download check) and failover (broken B2 bucket, R2 took over). A daily job (scra-dail, 03:15) now runs crawl then sync in the scheduler.
- clou_capz_gbyt accepts fractions (0.01 = 10 MB) so a purge can be drilled on small data.
- Not live-tested: the database purge ladder on a real database.

## 0.4.0 — 2026-11-21
- Site rules: settings per group, per site (exact or *.domain) and per path. About 50 keys: pace, retries, tiers, vendors, judging, browser, follow, extraction. Rules can only lower caps. New command: scra site.

## 0.3.0 — 2026-11-21
- Free local browser (your own Chrome) renders JavaScript pages; scroll, load more, consent walls, form steps.
- PDF text, country option per vendor, your own logged-in accounts, live feeds (SSE, WebSocket), replay of your own captures, link-trap skipping, vendor learning, bench command.
- Still not live-tested: vendor parameter names, real sites.

## 0.2.0 — 2026-11-20
- Thin JavaScript pages are now detected. scra looks for the free JSON or iframe behind them (WordPress, Next.js, /api/ calls) before spending a vendor credit.

## 0.1.0 — 2026-11-20
- First release: fetch, run, export, canary, kill, sync, status.
- Plain download first; ZenRows, Decodo and Bright Data only on a block and inside free credits.
- Robots.txt, rate limits, retries, dead-letter list, circuit breaker, recrawl intervals.
- Local SQLite store with a cloud copy (Backblaze B2, Cloudflare R2, Tigris; Turso, Neon, TiDB) and 90%→80% cleanup.
- Alerts by Healthchecks.io and Resend.
- Not yet: logged-in mode, local disk cap, live-checked vendor numbers.
