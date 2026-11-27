---
name: webs-scra
description: Run the `scra` CLI, the web scraper. Use when the user wants to fetch or crawl a page or sitemap, export scraped data, parse car pages, sync or purge scrape data, or control vendor spend (ZenRows, Decodo, Bright Data).
---
# scra — scrape CLI (own GET first, vendors only on a block)
1. `scra status --json` first (read-only).
2. Every fetch is a dry-run unless `--live`. `--force` allows PAID vendor spend.
3. NEVER add `--live` or `--force` unless the user said so in this turn. Show the dry-run first.
4. Spend emergency stop: `scra kill --on` (allow again: `--off`).
Commands: `scra fetch <url> [--live [--force]]` · `scra run [url] [--seed-file f] [--sitemap u] [--follow n] [--live]` · `scra export [--format jsonl|csv] [--out file]` · `scra cars [--live] | cars export [--out f]` · `scra sync [--live]` · `scra purge [--live]` · `scra canary [--add url]` · `scra replay --spec f --param k=v` · `scra bench --list f` · `scra login <name>` (user logs in by hand).
Fetch options: --geoz cc --wait ms --selector css --scroll n --click text --consent --steps f.json --account name --stream sse|poll|ws.
Exit: 0 ok · 1 fail · 2 usage · 3 drift · 4 blocked — 4 is normal, report it, never retry in a loop.
Details: `E:\zz-base-home\as-apps\ws-webs\sc-scra\CLAUDE.md` · `scra --help`.
