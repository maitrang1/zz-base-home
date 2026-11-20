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

## Files
| File | Holds |
|---|---|
| ~/.zs-scra-data/scra-index.db | page list, log, queue, records, spend, upload queue |
| ~/.zs-scra-data/raw/ab/cd/<hash>.gz | stored pages, once per content |
| ~/.zz-base-home-secr/scra/<name>.key | vendor and cloud keys, line 1 |

## Exit codes
0 ok · 1 failed · 2 wrong use · 3 layout changed or run incomplete · 4 blocked
