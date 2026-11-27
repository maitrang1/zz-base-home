# How to use scra
Every example uses the full path. Replace nothing. Add `--json` to any command for machine output.

## See what is going on
E:\zz-base-home\as-apps\ws-webs\sc-scra\zig-out\bin\sc-scra.exe status
Shows kill switch, month spend against your cap, pages stored and queue size.

## Fetch one page
1. Preview (no network):
   E:\zz-base-home\as-apps\ws-webs\sc-scra\zig-out\bin\sc-scra.exe fetch https://example.com/
2. Run it:
   E:\zz-base-home\as-apps\ws-webs\sc-scra\zig-out\bin\sc-scra.exe fetch https://example.com/ --live
Words in the answer: `new` stored, `same` same content as before, `notm` not modified, `http` the site answered with an error (not stored), `bloc` block page (not stored), `empt` empty page, `jbad` broken JSON.

## Crawl a list of pages
1. Put one address per line in a file, for example `E:\.zz-base-home-tena\as-apps\ws-webs\sc-scra\seeds.txt`. Lines starting with # are ignored.
2. Preview:
   E:\zz-base-home\as-apps\ws-webs\sc-scra\zig-out\bin\sc-scra.exe run --seed-file E:\.zz-base-home-tena\as-apps\ws-webs\sc-scra\seeds.txt
3. Run:
   E:\zz-base-home\as-apps\ws-webs\sc-scra\zig-out\bin\sc-scra.exe run --seed-file E:\.zz-base-home-tena\as-apps\ws-webs\sc-scra\seeds.txt --live
Add `--sitemap https://example.com/` to read the site's sitemap first. Add `--decl 120` if the site says it has 120 items: a shorter result is flagged (exit code 3).
scra reads robots.txt, waits between requests to the same site, retries failures, and stops the run if too many pages fail.

## Use scraping services (free first)
1. Sign up at ZenRows, Decodo or Bright Data. Note the free credits.
2. Save each key as the first line of a file in `C:\Users\<you>\.zz-base-home-secr\as-apps\ws-webs\sc-scra\`: `zenr.key`, `deco.key`, `brig.key`.
3. In aa-conf-main.json set `vend_free_cred` to your free credits for the month. Bright Data also needs `vend_zone_brig`.
4. Run with `--live`. Vendors are used only when a plain download is blocked.
5. To allow paid use: set `capz_usdz_mont` (dollars per month) and add `--force` after `--live`.

## Stop all spending
E:\zz-base-home\as-apps\ws-webs\sc-scra\zig-out\bin\sc-scra.exe kill --on
Undo with `--off`.

## Export what you collected
E:\zz-base-home\as-apps\ws-webs\sc-scra\zig-out\bin\sc-scra.exe export --format csv --out C:\Users\<you>\scra.csv
Formats: `jsonl` (default) or `csv`.

## Watch for layout changes
1. Save a baseline: scra.exe canary --add https://example.com/ --live
2. Check later: scra.exe canary --live. Exit code 3 means the page layout changed.

## Copy to the cloud
1. Fill `clou_endp` in aa-conf-main.json (host, bucket, region per vendor) and save the keys in the key folder: `b2zz.key`, `r2zz.key`, `tigr.key` have two lines (key id, then secret); `turs.key`, `neon.key`, `tidb.key` have one line (token, connection string, or `user:password`).
2. Preview: scra.exe sync
3. Upload: scra.exe sync --live. If a vendor fails, the next one takes over; a denied or full vendor is skipped until it works again.

## Clean up old data (purge)
1. See the plan: scra.exe purge
2. Run it: scra.exe purge --live. `sync --live` also purges after each upload.
3. Nothing is deleted locally until the cloud copy is verified; deleted local files wait in `trash\` for 7 days first.
4. Settings (ages, limits, copy to a second store): see CONFIG.md, "Cloud copy and purge".

## Car rows (price, year, km, place)
1. After a crawl: scra.exe cars shows what would be parsed. scra.exe cars --live parses, rolls up and cleans up.
2. Read them: scra.exe cars export --out cars.jsonl (one JSON line per listing; the raw phone is never in it).
3. Rows keep the price history, the last asking price when a listing disappears, and a weekly roll-up per make, model, year and fuel type.
4. Seller names of private people are not stored. Dealer names are. Phones are stored as a hash; the raw number is erased 90 days after the listing is gone.
5. The schedule job runs it after each crawl, and `sync --live` copies the rows to the cloud as three small gzip files that overwrite the last copy.

## Facebook and Zalo records
scra never logs in to Facebook or Zalo. Your own engines `fb` and `za` do that, read-only and by hand. They write one JSON record per line into `*.jsonl` files in the input folder (`soci_dirz`, default `<data folder>/social-in`).
1. A record: `{"kind":"face" or "zalo","id":"..","url":"https://..","text":"..","src":"group or chat","auth":"author","role":"private or dealer","phon":"..","mail":"..","posted":ms,"intent":"sell or buy"}`. `kind`, `url` (https) and `text` are required; the rest is optional.
2. `scra.exe ingest` shows what would load. `scra.exe ingest --live` loads it. `scra.exe cars --live` does the same first, so the daily job needs no new step.
3. Records are stored like fetched pages: raw file, record, cloud copy, purge. They are never fetched again. The finished file moves to the trash folder and the local purge deletes it after `purg_tras_days` (the records stay in the store).
4. `cars` turns them into rows like any listing. A buyer post ("cần mua ...") becomes a row with price 0 and seller `buyer`; the budget is in `xtra`. Buyer rows never count in price roll-ups or look-alike groups.
5. `scra.exe social --live` runs the engines in `soci_engi_list` (`name|exe|arg|arg`), then loads. Without `--live` it only lists.
6. Public Facebook and Zalo pages (no login) are fetched like any site (group `social`): own download first, vendors only inside free credits.

## Alerts
Save a Healthchecks.io ping address in `healthchecks.url` and a Resend key in `resend.key`, then set `aler_mail_from` and `aler_mail_toxx`. You are told when a run halts or the cloud is almost full.

## Errors
| Message | Fix |
|---|---|
| bad usage | Check the command with `scra.exe help`. `--force` needs `--live`. |
| host refused | The address points to a private or local machine. Only public sites are fetched. |
| not text | The page is an image, video or file. scra stores text only. |
| needs vendor | The plain download failed (blocked or TLS problem). Configure a vendor. |
| spend cap hit | No free credits left and no paid use allowed. Raise the cap and use `--force`, or wait for next month. |
| kill switch on | Run `scra.exe kill --off`. |
| no vendor key | Put the key on line 1 of `<vendor>.key` in the key folder. |
| cloud not configured | Fill `clou_endp` and the key files. |
| cloud storage error / cloud database error | The cloud refused. Your data is safe locally. Run `sync --live` again later. |

## JavaScript pages, PDFs, other countries
- A page that is only a JavaScript shell: scra first looks for the JSON behind it (free). With `brow_enab` true it then renders the page in your own Chrome (free). Only then does it use a vendor.
- PDF: fetched like a page, text is stored (record kind `pdft`; `pdfo` = scanned, needs OCR).
- Another country: `scra.exe fetch <url> --live --geoz us` (needs a vendor; ZenRows prices this as premium).
- Scroll, load more, cookie walls, forms: `fetch <url> --live --scroll 20`, `--click "load more"`, `--consent`, `--steps steps.json` (ops: goto click clicktext type wait waitsel scroll extract; never types into password fields).
- Your own logged-in account: set `logi_mode_enab` and `brow_enab` true, run `scra.exe login mine`, log in by hand in the window that opens, close it. Then `fetch <url> --live --account mine`. scra never sees your password. No vendors, one profile per account.
- Live feeds: `fetch <url> --live --stream sse` (or `poll`, or `ws` for a page that opens a WebSocket).
- Your own captured request (DevTools HAR or Copy as cURL): `scra.exe replay --spec capture.txt --param page=2 --live`. A 401/403 means the signature expired: capture a fresh one.
- Test many sites: write `L1 https://...` lines (levels 1-9, two or more per level), then `scra.exe bench --list urls.txt --out notes.txt --live`.
- Different settings per site or group: write rules in `site_rule_list` and `grup_rule_mapz` (CONFIG.md, "Site rules"). Check them with `scra.exe site --check`; see what a URL gets with `scra.exe site <url>`.
- Follow links while crawling: `run --follow 50 --live`. Hidden, nofollow and honeypot links are skipped.

## Contact book

`scra cars --live` fills it while it parses car pages. Then:

```
scra cont                      counts (add --live to back up now)
scra cont export --out c.vcf   vCard (add --format csv for CSV)
scra cont verify               open every backup with the key
scra cont key                  print the key once; keep an offline copy
scra cont restore <file>       load contacts from a backup file
scra cont forget <phone|id>    delete one person everywhere (--live to run)
scra cont drop                 delete all private persons everywhere (--live to run)
```

Backups are encrypted. Without the key they cannot be opened, so copy it offline. Read PRIVACY.md before keeping private persons.

## Mirror to all vendors
Turn it on with `"clou_mirr_enab": true` in `aa-conf-main.json`. Then every `scra sync --live` writes to all 3 stores (b2zz, r2zz, tigr) and all 3 databases (turs, neon, tidb) at the same time. The first healthy vendor is still the "main" one: its answer decides if the run worked. The others are mirrors; a mirror that is down never fails the run.
- A mirror store that fails gets its objects put in a queue (`mput@<vendor>`), is skipped for the rest of the run, and is retried next run. The copy is read from any vendor that has the object.
- A mirror database that fails keeps every missed statement in a local spool, in order. When it is back, it catches up. TiDB gets MySQL-form statements automatically.
- A new mirror database is filled from your local tables in chunks (backfill), a few hundred rows per run.
- Once a week (`purg_veri_days`) every store is listed. Missing or wrong-size objects are queued again, and `purg_veri_cont` objects are compared byte for byte.
- Calls to each store are counted per month (`clou_mirr_opsa_mont`). Past that count a mirror pauses until next month and an alert says so.
- Purge: a store is purged on its own cap, and what it deletes or rewrites goes to all vendors. The smallest cap you set drives the oldest-first purge, so keep `clou_capz_gbyt` honest.
- Check it: `scra sync --live` prints `mirror N objects M statements, queued A + B, down C, audit fixed D orphans E`. Nothing queued, nothing down and D = 0 means all vendors match.
Free limits worth knowing (as of 2026-11, check the vendor pages): Tigris 5 GB and 10000 write or list calls a month; Neon 1 GB per project; Turso 5 GB and 10M rows written a month; TiDB Starter 5 GiB per instance (the docs and the pricing page disagree, so plan on 5); R2 and B2 10 GB.

## Next
[CONFIG.md](CONFIG.md)
