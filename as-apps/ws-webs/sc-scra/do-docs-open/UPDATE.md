# Updates

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
