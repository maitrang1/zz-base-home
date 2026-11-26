# scra settings
File: `aa-conf-main.json` beside the project folder (or `--conf <file>`). Missing file = defaults. A wrong value, or a name scra does not know (a typo), stops scra with "bad config" (exit 2); the unknown name is printed.

## Settings
| Name | Does | Default | Allowed |
|---|---|---|---|
| capz_usdz_mont | Paid spend allowed per month, in dollars | 0 | 0 or more (0 = free only) |
| capz_disk_gbyt | Local disk cap (not enforced yet) | 5 | 1 or more |
| clou_poli_mode | At the high mark (purg_high_pctz) purge old data (`purg`) or only alert (`upgr`) | purg | purg, upgr |
| uagt_cont_mail | Contact address added to the User-Agent | empty | text |
| logi_mode_enab | Owner logged-in mode: your own accounts, in a scra-only browser profile (also needs brow_enab) | false | true or false |
| vend_orde | Vendor order | deco, zenr, brig | deco, zenr, brig |
| vend_free_cred | Free credits per month per vendor | 0 | whole numbers |
| vend_cred_micr | Price per credit beyond free, in millionths of a dollar | 1000 | whole numbers |
| vend_keyz_dirz | Folder with key files | ~/.zz-base-home-secr/as-apps/ws-webs/sc-scra | path |
| vend_zone_brig | Bright Data zone name | empty | text |
| fetc_time_seco | Seconds before a download is given up | 30 | 1 or more |
| runz_time_seco | Seconds a live `scra run` may work; then it stops cleanly, exit 3 (keep it under the hub step time) | 3300 | 60-86400 |
| fetc_body_maxz | Largest page in bytes (after unzip) | 5242880 | 1 or more |
| fetc_redi_maxz | Most redirects followed | 5 | 0-16 |
| rate_host_seco | Seconds between requests to one site | 1 | 0 or more |
| retr_cont_maxz | Tries before a page goes to the dead-letter list | 3 | 1 or more |
| shel_text_minz | A page with less visible text than this and a JavaScript-shell marker is a thin shell | 500 | 0 or more |
| apiz_prob_enab | Look for a free JSON or iframe URL behind a thin shell before paying a vendor | true | true or false |
| apiz_prob_maxz | Most probe requests per shell page | 8 | 0 turns probing off |
| geoz_code_dflt | Country code sent to vendors for every fetch (ZenRows needs premium, so it costs more). Any country skips your own free GET, so every page goes to a paid vendor tier. Leave empty unless a site needs it | empty | 2 letters or empty |
| geoz_host_over | Country code per site, for example {"example.com":"us"} | empty | object of 2-letter codes |
| pdfz_size_maxz | Largest PDF to download, bytes (0 = refuse PDFs) | 20971520 | 0 or more |
| brow_enab | Use your own Chrome or Edge to render JavaScript pages for free | false | true or false |
| brow_path_exec | Browser program (empty = look in the usual places) | empty | path |
| brow_prof_dirz | Folder for the scra-only browser profiles (never your daily profile). Empty = prof/ inside the data folder | empty | path |
| brow_time_seco | Seconds one browser page may take, including its actions | 60 | 1 or more |
| brow_scrl_maxz | Most scroll steps or load-more clicks per page | 30 | 1 or more |
| brow_step_maxz | Most steps in a steps file | 50 | 1 or more |
| brow_head_mode | Show the browser window while rendering | false | true or false |
| brow_wind_widt | Visible window width, in Chrome units (0 = Chrome's own; set with the height) | 0 | 0 to 10000 |
| brow_wind_high | Visible window height, in Chrome units | 0 | 0 to 10000 |
| brow_wind_scal | Display scale of the window and page (0 = system). 1.0 on a 125% screen looks like 80% zoom | 0 | 0, or 0.25 to 4 |
| brow_wind_left | Left position of a visible window; negative hides the Windows border gap | 0 | -100 to 10000 |
| cons_sele_list | Buttons clicked to dismiss cookie or consent walls | known list | CSS selectors |
| strm_time_seco | Seconds to listen to a live feed | 30 | 1 or more |
| strm_frme_maxz | Most frames kept per feed | 1000 | 1 or more |
| acct_page_maxz | Pages per day per logged-in account (spaced 3x rate_host_seco) | 200 | 0 or more |
| ocrz_path_exec | Optional OCR program for scanned PDFs, run as: program file (empty = off) | empty | path |
| revi_star_seco | First recrawl interval | 86400 | between floor and cap |
| revi_floo_seco | Shortest recrawl interval | 3600 | 1 or more |
| revi_capz_seco | Longest recrawl interval | 2592000 | at least the floor |
| data_dirz_wind | Where data is kept on Windows | E:\.zz-base-home-tena\as-apps\ws-webs\sc-scra | path |
| data_dirz_unix | Where data is kept on Linux and macOS | ~/.zz-base-home-tena/as-apps/ws-webs/sc-scra | path |
| clou_stor_orde | Object store order | b2zz, r2zz, tigr | b2zz, r2zz, tigr |
| clou_sqlz_orde | Cloud database order | turs, neon, tidb | turs, neon, tidb |
| clou_capz_gbyt | Size cap per object store, GB. Set to 80% of the free limit so purging starts before the vendor blocks you | b2zz 8, r2zz 8, tigr 4 | numbers above 0, fractions allowed (0.01 = 10 MB, for drills) |
| clou_sqlz_capz_mbyt | Size cap per cloud database, MB (80% of the free limit) | turs 4096, neon 800, tidb 4096 | numbers above 0, fractions allowed (0.01 = 10 MB, for drills) |
| clou_sync_batz | Most items per sync run | 200 | 1 or more |
| clou_mirr_enab | Mirror every run to all store vendors and all database vendors at the same time (see HOW-TO, Mirror). Off: one vendor per run with failover | false | true, false |
| clou_mirr_batz | Most statements one mirror database takes per round, and most rows per backfill chunk | 500 | 1 or more |
| clou_mirr_opsa_mont | Most write, delete and list calls the mirror makes to one store vendor per month (Tigris free = 10000, so the default leaves room) | 8000 | 1 or more |
| clou_mirr_spoo_maxz | A mirror database that is down keeps its missed statements; past this many it drops them and rebuilds from your local tables | 20000 | 1 or more |
| clou_fail_runs | Failed runs in a row before a vendor is skipped for a day (denied 401/402/403 = skipped until the 1st of next month) | 3 | 1 or more |
| clou_body_maxz | Most bytes of one record body sent to the cloud database (full pages are in the packs) | 8192 | 1024 to 60000 |
| purg_high_pctz | Purge starts when a store is this percent of its cap | 80 | 2 to 100 |
| purg_lowz_pctz | Purge stops at this percent | 60 | 1 to purg_high_pctz minus 1 |
| purg_maxx_pctz | Most percent of a cap one run may free (limit on a buggy purge; the rest continues next run) | 10 | 1 to 100 |
| purg_loca_days | Local raw files older than this go to the trash, only if the cloud copy is verified | 30 | 1 or more |
| purg_loca_veri | Require a size-verified cloud copy (false = any uploaded copy) | true | true, false |
| purg_tras_days | Days a trashed file stays in trash/ before it is deleted (0 = delete at once) | 7 | 0 or more |
| purg_clou_mini_days | Cloud daily packs younger than this are never purged | 90 | 1 or more |
| purg_dead_pctz | A keep pack with more than this percent of dead weight is rewritten | 30 | 1 to 100 |
| purg_copy_enab | Copy keep packs (the latest version of every page) to a second store | true | true, false |
| purg_dbzz_body_days | Blank cloud record bodies older than this when the database is at the high mark | 30 | 1 or more |
| purg_dbzz_gone_days | Drop cloud rows of 404/410 pages older than this when still at the high mark | 90 | 1 or more |
| purg_logz_days | Delete fetch log rows older than this | 90 | 1 or more |
| purg_outb_days | Delete finished upload-queue rows older than this | 30 | 1 or more |
| purg_dead_days | Delete dead-letter queue rows older than this | 90 | 1 or more |
| purg_veri_cont | Random packs downloaded and checked per verify run (0 = off) | 5 | 0 to 100 |
| purg_veri_days | Days between verify runs | 7 | 1 or more |
| purg_live_days | Days between keepalive pings to every vendor (stops idle free accounts being archived) | 7 | 1 or more |
| clou_endp | Per vendor: `host`, `regn` (region), `bukt` (bucket, stores), `dbnm` (database, TiDB). Example: `"turs": { "host": "scra-you.aws-ap-southeast-1.turso.io" }` | empty | text |
| aler_mail_from | Alert email sender | empty | email |
| aler_mail_toxx | Alert email recipient | empty | email |

## Site rules (per group, per site, per path)
Order: global settings, then the group, then the site rule, then matching path rules. Later wins. Check with `scra.exe site --check`. See what a URL gets with `scra.exe site https://shop.com/api/x`.
```
"grup_rule_mapz": { "retail": { "rate_host_seco": 5, "geoz_code_dflt": "us" } },
"site_rule_list": [ {
  "name": "shop", "host": ["shop.com", "*.shop.com"], "grup": "retail", "enab": true, "note": "",
  "tier_maxz": 3, "vend_bann_list": ["brig"], "cons_sele_list_adds": ["#my-banner-ok"],
  "path_rule_list": [ { "path": "/api/*", "brow_enab": true, "judg_must_list": ["price"] } ]
} ]
```
- Host: `name.tld` is exact. `*.name.tld` matches subdomains only, not `name.tld`. Exact beats wildcard.
- Path: `*` any text, `?` one character.
- A list key replaces the earlier value. Add `_adds` to a list key to append instead.
- A rule can only lower caps, never raise them: `retr_cont_maxz fetc_time_seco fetc_body_maxz fetc_redi_maxz pdfz_size_maxz tier_maxz apiz_prob_maxz brow_time_seco brow_scrl_maxz brow_step_maxz acct_page_maxz strm_time_seco strm_frme_maxz`. `capz_cred_pagz` must stay between 1 and the global value when the global is set.
- Never allowed in a rule: robots.txt, User-Agent, keys and paid-credit settings, TLS and private-address checks.
- A mistake in any rule stops scra at start with the rule and key named.

| Key | Does | Default |
|---|---|---|
| rate_host_seco | Seconds between requests | 1 |
| rate_jitt_pctz | Random extra wait, 0 to this percent of the gap (0 to 300). Example: gap 4 + 300 = random 4 to 16 seconds | 0 |
| rate_429z_pctz | Percent of Retry-After to wait after 429 or 503 | 100 |
| retr_afte_enab | Honor Retry-After | true |
| retr_back_seco | First retry delay (0 = global) | 0 |
| retr_code_list | Only these HTTP statuses are retried, others go to the dead list (empty = all) | empty |
| retr_cont_maxz · fetc_time_seco · fetc_body_maxz · fetc_redi_maxz · pdfz_size_maxz | As in Settings | global |
| tier_star | Start at: own, brow, plain, rend, prem | own |
| tier_maxz | Highest vendor tier allowed (1 = no vendors) | 4 |
| tier_skip_list | Tiers to skip, for example ["own"] | empty |
| tier_t1fz | Own-GET failures in a row before skipping it | 3 |
| tier_ages | Days before the remembered tier steps down | 7 |
| vend_orde · vend_bann_list | Vendor order, vendors never used here | global, empty |
| capz_cred_pagz | Most credits one page may cost (0 = no cap) | 0 |
| geoz_code_dflt | Country code | global |
| apiz_prob_enab · apiz_prob_maxz | API probe on or off, most probes | true, 8 |
| apiz_path_list | Extra paths to probe, for example ["/api/items"] | empty |
| shel_text_minz · shel_mark_list | Thin-page limit, extra shell markers | 500, empty |
| judg_bloc_list | Phrases that make a page a block | empty |
| judg_must_list | Phrases that must be on the page | empty |
| judg_text_minz | Least visible text | 0 |
| judg_fiel_requ | JSON fields that must be present and not empty | empty |
| brow_enab · brow_time_seco · brow_scrl_maxz · brow_step_maxz · cons_sele_list | Browser use and limits | global |
| brow_wait_msec · brow_sele_wait | Default wait and selector (forces a render) | 0, empty |
| brow_clic_text · brow_step_file | Default "load more" text and steps file | empty |
| brow_blok_resz | Skip images, fonts and media in the browser | false |
| acct_page_maxz · acct_gapz_mult | Pages per day and spacing multiplier for logged-in accounts | 200, 3 |
| strm_time_seco · strm_frme_maxz | Feed limits | global |
| foll_maxz | Most links followed per page (0 = no limit) | 0 |
| foll_incl_list · foll_excl_list | Path globs to follow or skip | empty |
| foll_nofo_enab | Also follow links marked rel=nofollow (robots.txt still applies). Hidden links and other traps stay skipped. Only turn it on for a site whose own car links carry nofollow | false |
| revi_star_seco · revi_floo_seco · revi_capz_seco | Recrawl timing | global |
| extr_pref_list | Record order: ldjs, next, text | ldjs, next, text |
| ocrz_enab | Allow OCR for scanned PDFs when ocrz_path_exec is set | true |

## Car rows (scra cars)
| Key | What it does | Default | Allowed |
|---|---|---|---|
| carz_enab | Turn the car parser on or off | true | true or false |
| carz_text_days | Gone listings lose their long text after this many days | 180 | 1 or more, at most carz_gone_days |
| carz_hist_days | Gone listings keep only first and last price after this many days | 365 | 1 or more, at most carz_gone_days |
| carz_gone_days | Gone listings are deleted after this many days, once a roll-up covers them | 730 | 1 or more |
| carz_pers_days | The raw seller phone is erased this many days after the listing is gone (the hash stays) | 90 | 1 or more |
| carz_stal_days | A listing not seen for this long no longer counts as active in the roll-ups | 14 | 1 or more, below carz_dead_days |
| carz_dead_days | A listing not seen for this long is marked gone (reason vani) | 90 | above carz_stal_days |
| cont_enab | Keep a contact book (name, phone, email, address, short note) from listing pages. Off = nothing saved | true | true or false |
| cont_priv_enab | Keep full details of private sellers. Off = only a salted phone hash for them; dealers stay in full | true | true or false |
| cont_week_keep | Weekly encrypted backups to keep, local and cloud. The latest copy is always kept too | 8 | 1 to 52 |
| carz_pull_maxz | Most pages parsed in one run | 5000 | 1 or more |

## Social records (scra ingest, scra social)
| Key | What it does | Default | Allowed |
|---|---|---|---|
| soci_enab | Load Facebook/Zalo records before the car parser runs. Off = ignore the input folder | true | true or false |
| soci_dirz | Input folder with the `*.jsonl` files. Empty = `<data folder>/social-in` | empty | a folder path (`~` works) |
| soci_engi_list | Engines that `scra social --live` runs, one per entry: `name\|exe\|arg\|arg` | none | each entry needs a `\|` |
| soci_time_seco | Deadline for one engine run, in seconds | 3600 | 1 or more |
| soci_line_maxz | Longest record line in bytes. Longer lines count as bad | 20000 | 256 or more |
| soci_file_maxz | Largest input file in bytes | 67108864 | at least soci_line_maxz |

Site group `social` (facebook.com, zalo.me): slow pace, no link following, public pages only.

The engines write into the input folder: `fb read feed --live` (feed_path_list in fb's config) and `za feed --live` (feed_chat_list in za's config). Example for `scra social --live`: `"soci_engi_list": ["fb|C:/path/to/fb.exe|read|feed|--live", "za|C:/path/to/za.exe|feed|--live"]`.

## Cloud copy and purge
- **Vendors:** pages go to the first healthy object store (b2zz, r2zz, tigr) and records to the first healthy database (turs, neon, tidb). If a vendor fails, the next one takes over in the same run and stays in charge until the first one is healthy again. Each pack remembers which vendor holds it.
- **Pages (packs):** `runs/` packs are daily and are purged by age, oldest first, never younger than purg_clou_mini_days. The newest copy of every page moves into a `keep/` pack first (checked, copied to a second store). A pack is marked "purging", deleted, then marked "purged", so a crash cannot lose track.
- **Database:** old record bodies are blanked, then old 404/410 rows are dropped, then you get an alert. The newest record of a live page is never deleted. Size is an estimate (Turso cannot shrink its file, but freed space is reused).
- **Local files:** a raw file older than purg_loca_days whose cloud copy is verified goes to `trash/<day>/`, and is deleted after purg_tras_days. At the high mark the trash is emptied and the oldest verified files are deleted. Nothing verified left = alert, nothing is deleted. At 95% of capz_disk_gbyt fetching pauses.
- **Safety:** a dry run is the default (`scra purge`, `scra sync`). One run frees at most purg_maxx_pctz of a cap. Weekly keepalive and a weekly download check of random packs.
- **Commands:** `scra sync --live` uploads and then purges; `scra purge` shows the plan, `scra purge --live` runs it.

## Files
| File | Holds |
|---|---|
| <data folder>/scra-index.db | page list, log, queue, records, spend, upload queue |
| <data folder>/raw/ab/cd/<hash>.gz | stored pages, once per content |
| <data folder>/scra-index.db tables carz, carp, carr | car rows, price changes, weekly market roll-ups |
| <data folder>/trash/<yyyymmdd>/... | raw files waiting to be deleted (purg_tras_days) |
| ~/.zz-base-home-secr/as-apps/ws-webs/sc-scra/<name>.key | vendor and cloud keys, line 1 |

## Exit codes
0 ok · 1 failed · 2 wrong use (bad flag, unknown command, bad or unknown config key, `--dry-run` with `--live`) · 3 layout changed or run incomplete (incl. the run time limit) · 4 blocked (guard, kill switch, another run holds the lock)

## Machine output
`--json` prints exactly one JSON document on stdout, failures too. Core fields: `ok` · `cmd` · `exit` · `dry_run` (commands that write) · `code` and `msg` (failures). Text lines of a command arrive in `lines`, a list in `data`. `export` with `--json` needs `--out <file>`. Errors and progress stay on stderr.

## One run at a time
Commands that write (`--live`, `login`) take `scra.lock` in the data folder. A second one stops with exit 4; a lock left by a dead run is replaced. `status`, dry runs and `kill` never take it.
