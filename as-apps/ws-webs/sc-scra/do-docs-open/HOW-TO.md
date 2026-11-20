# How to use scra
Every example uses the full path. Replace nothing. Add `--json` to any command for machine output.

## See what is going on
E:\zz-base-home\as-apps\ws-webs\sc-scra\zig-out\bin\scra.exe status
Shows kill switch, month spend against your cap, pages stored and queue size.

## Fetch one page
1. Preview (no network):
   E:\zz-base-home\as-apps\ws-webs\sc-scra\zig-out\bin\scra.exe fetch https://example.com/
2. Run it:
   E:\zz-base-home\as-apps\ws-webs\sc-scra\zig-out\bin\scra.exe fetch https://example.com/ --live
Words in the answer: `new` stored, `same` same content as before, `notm` not modified, `http` the site answered with an error (not stored), `bloc` block page (not stored), `empt` empty page, `jbad` broken JSON.

## Crawl a list of pages
1. Put one address per line in a file, for example `C:\Users\<you>\.zs-scra-data\seeds.txt`. Lines starting with # are ignored.
2. Preview:
   E:\zz-base-home\as-apps\ws-webs\sc-scra\zig-out\bin\scra.exe run --seed-file C:\Users\<you>\.zs-scra-data\seeds.txt
3. Run:
   E:\zz-base-home\as-apps\ws-webs\sc-scra\zig-out\bin\scra.exe run --seed-file C:\Users\<you>\.zs-scra-data\seeds.txt --live
Add `--sitemap https://example.com/` to read the site's sitemap first. Add `--decl 120` if the site says it has 120 items: a shorter result is flagged (exit code 3).
scra reads robots.txt, waits between requests to the same site, retries failures, and stops the run if too many pages fail.

## Use scraping services (free first)
1. Sign up at ZenRows, Decodo or Bright Data. Note the free credits.
2. Save each key as the first line of a file in `C:\Users\<you>\.zz-base-home-secr\scra\`: `zenr.key`, `deco.key`, `brig.key`.
3. In aa-conf-main.json set `vend_free_cred` to your free credits for the month. Bright Data also needs `vend_zone_brig`.
4. Run with `--live`. Vendors are used only when a plain download is blocked.
5. To allow paid use: set `capz_usdz_mont` (dollars per month) and add `--force` after `--live`.

## Stop all spending
E:\zz-base-home\as-apps\ws-webs\sc-scra\zig-out\bin\scra.exe kill --on
Undo with `--off`.

## Export what you collected
E:\zz-base-home\as-apps\ws-webs\sc-scra\zig-out\bin\scra.exe export --format csv --out C:\Users\<you>\scra.csv
Formats: `jsonl` (default) or `csv`.

## Watch for layout changes
1. Save a baseline: scra.exe canary --add https://example.com/ --live
2. Check later: scra.exe canary --live. Exit code 3 means the page layout changed.

## Copy to the cloud
1. Fill `clou_endp` in aa-conf-main.json and save keys in the same key folder (`b2zz.key` two lines: key id, secret; `turs.key` one line).
2. Preview: scra.exe sync
3. Upload: scra.exe sync --live
When storage passes 90% of the cap, the oldest archives are deleted down to 80%. Parsed records are never deleted. Set `clou_poli_mode` to `upgr` to get an alert instead of deleting.

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
- Follow links while crawling: `run --follow 50 --live`. Hidden, nofollow and honeypot links are skipped.

## Next
[CONFIG.md](CONFIG.md)
