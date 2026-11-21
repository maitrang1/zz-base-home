# scra settings
File: `aa-conf-main.json` beside the project folder (or `--conf <file>`). Missing file = defaults. A wrong value stops scra with "bad config".

## Settings
| Name | Does | Default | Allowed |
|---|---|---|---|
| capz_usdz_mont | Paid spend allowed per month, in dollars | 0 | 0 or more (0 = free only) |
| capz_disk_gbyt | Local disk cap (not enforced yet) | 5 | 1 or more |
| clou_poli_mode | At 90% cloud full: delete oldest (`purg`) or only alert (`upgr`) | purg | purg, upgr |
| uagt_cont_mail | Contact address added to the User-Agent | empty | text |
| logi_mode_enab | Owner logged-in mode: your own accounts, in a scra-only browser profile (also needs brow_enab) | false | true or false |
| vend_orde | Vendor order | deco, zenr, brig | deco, zenr, brig |
| vend_free_cred | Free credits per month per vendor | 0 | whole numbers |
| vend_cred_micr | Price per credit beyond free, in millionths of a dollar | 1000 | whole numbers |
| vend_keyz_dirz | Folder with key files | ~/.zz-base-home-secr/scra | path |
| vend_zone_brig | Bright Data zone name | empty | text |
| fetc_time_seco | Seconds before a download is given up | 30 | 1 or more |
| fetc_body_maxz | Largest page in bytes (after unzip) | 5242880 | 1 or more |
| fetc_redi_maxz | Most redirects followed | 5 | 0-16 |
| rate_host_seco | Seconds between requests to one site | 1 | 0 or more |
| retr_cont_maxz | Tries before a page goes to the dead-letter list | 3 | 1 or more |
| shel_text_minz | A page with less visible text than this and a JavaScript-shell marker is a thin shell | 500 | 0 or more |
| apiz_prob_enab | Look for a free JSON or iframe URL behind a thin shell before paying a vendor | true | true or false |
| apiz_prob_maxz | Most probe requests per shell page | 8 | 0 turns probing off |
| geoz_code_dflt | Country code sent to vendors for every fetch (ZenRows needs premium, so it costs more) | empty | 2 letters or empty |
| geoz_host_over | Country code per site, for example {"example.com":"us"} | empty | object of 2-letter codes |
| pdfz_size_maxz | Largest PDF to download, bytes (0 = refuse PDFs) | 20971520 | 0 or more |
| brow_enab | Use your own Chrome or Edge to render JavaScript pages for free | false | true or false |
| brow_path_exec | Browser program (empty = look in the usual places) | empty | path |
| brow_prof_dirz | Folder for the scra-only browser profiles (never your daily profile) | ~/.zs-scra-data/prof | path |
| brow_time_seco | Seconds one browser page may take, including its actions | 60 | 1 or more |
| brow_scrl_maxz | Most scroll steps or load-more clicks per page | 30 | 1 or more |
| brow_step_maxz | Most steps in a steps file | 50 | 1 or more |
| brow_head_mode | Show the browser window while rendering | false | true or false |
| cons_sele_list | Buttons clicked to dismiss cookie or consent walls | known list | CSS selectors |
| strm_time_seco | Seconds to listen to a live feed | 30 | 1 or more |
| strm_frme_maxz | Most frames kept per feed | 1000 | 1 or more |
| acct_page_maxz | Pages per day per logged-in account (spaced 3x rate_host_seco) | 200 | 0 or more |
| ocrz_path_exec | Optional OCR program for scanned PDFs, run as: program file (empty = off) | empty | path |
| revi_star_seco | First recrawl interval | 86400 | between floor and cap |
| revi_floo_seco | Shortest recrawl interval | 3600 | 1 or more |
| revi_capz_seco | Longest recrawl interval | 2592000 | at least the floor |
| data_dirz_path | Where data is kept | ~/.zs-scra-data | path |
| clou_stor_orde | Object store order | b2zz, r2zz, tigr | b2zz, r2zz, tigr |
| clou_sqlz_orde | Cloud database order | turs, neon, tidb | turs, neon, tidb |
| clou_capz_gbyt | Cloud size cap per store, GB | b2zz 10, r2zz 10, tigr 5 | whole numbers |
| clou_sync_batz | Most items per sync run | 200 | 1 or more |
| clou_endp | Host, region, bucket (stores) and host, database (databases) per vendor | empty | text |
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
| rate_jitt_pctz | Random extra wait, percent of the gap | 0 |
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
| revi_star_seco · revi_floo_seco · revi_capz_seco | Recrawl timing | global |
| extr_pref_list | Record order: ldjs, next, text | ldjs, next, text |
| ocrz_enab | Allow OCR for scanned PDFs when ocrz_path_exec is set | true |

## Files
| File | Holds |
|---|---|
| ~/.zs-scra-data/scra-index.db | page list, log, queue, records, spend, upload queue |
| ~/.zs-scra-data/raw/ab/cd/<hash>.gz | stored pages, once per content |
| ~/.zz-base-home-secr/scra/<name>.key | vendor and cloud keys, line 1 |

## Exit codes
0 ok · 1 failed · 2 wrong use · 3 layout changed or run incomplete · 4 blocked
