# scra settings
File: `aa-conf-main.json` beside the project folder (or `--conf <file>`). Missing file = defaults. A wrong value stops scra with "bad config".

## Settings
| Name | Does | Default | Allowed |
|---|---|---|---|
| capz_usdz_mont | Paid spend allowed per month, in dollars | 0 | 0 or more (0 = free only) |
| capz_disk_gbyt | Local disk cap (not enforced yet) | 5 | 1 or more |
| clou_poli_mode | At 90% cloud full: delete oldest (`purg`) or only alert (`upgr`) | purg | purg, upgr |
| uagt_cont_mail | Contact address added to the User-Agent | empty | text |
| logi_mode_enab | Owner logged-in mode (not built yet) | false | false |
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
