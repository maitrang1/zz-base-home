# Config

## Program
| Item | Value |
|---|---|
| File | `zr.exe` (`zr` on Linux and macOS) |
| Settings | `aa-conf-main.json` next to the program, or `--conf <file>` |
| Output | lines on screen; state in the data folder |
| Built with | Zig, Chrome DevTools, SQLite |

## Settings
| Name | Does | Default | Allowed |
|---|---|---|---|
| base_urlz_main | Main site | https://www.zenrows.com | http(s) URL |
| base_appz_main | Dashboard site | https://app.zenrows.com | http(s) URL |
| base_docz_main | Docs site | https://docs.zenrows.com | http(s) URL |
| data_loca_wind / data_loca_unix | Data folder | tena root of this app | path, `~` ok |
| secr_loca_main | Secret folder | `~/.zz-base-home-secr/as-apps/in-inte/zr-zrow-webs` | path |
| brow_exec_path | Chrome path | empty (auto) | path |
| brow_head_mode | Hide the window (headless) | false | true, false |
| brow_time_seco | Page wait | 60 | 1 and up |
| brow_vers_minz | Oldest Chrome | 120 | number |
| type_dely_msec | Gap between keys | [90, 260] | low ≤ high |
| acti_dely_secs | Gap between actions | [2, 9] | low ≤ high |
| mous_step_coun | Mouse steps | 18 | 1 to 200 |
| time_scal_perc | Speed of all waits | 100 | 0 to 1000 |
| rand_seed_numb | Fixed random seed | 0 (random) | number |
| acct_maxx_coun | Most accounts in `user-acct.json` | 3 | 1 to 20 |
| acct_gap_secs | Wait between accounts with `--acct all` (min, max seconds) | [300, 1200] | numbers |
| capz_acct_dayz | Account acts per day | 10 | number |
| capz_prod_dayz | Product runs per day | 200 | number |
| capz_data_dayz | Data views per day | 300 | number |
| capz_mone_dayz | Money acts per day | 5 | number |
| capz_acce_dayz | Key, team, webhook acts per day | 30 | number |
| capz_sett_dayz | Settings acts per day | 30 | number |
| capz_help_dayz | Help acts per day | 30 | number |
| quie_hour_rang | Quiet hours, start and end | [0, 0] (off) | 0 to 23 |
| quie_zone_minu | Time zone minutes | 0 | -840 to 840 |
| warm_dayz_coun | Slow start days | 0 (off) | number |
| retr_coun_maxz | Tries per button | 3 | 1 to 10 |
| wait_maxx_minu | Longest wait for you | 30 | 1 and up |
| wait_maxx_secs | Same, in seconds (wins if set) | 0 | number |
| sett_wait_minu | Rest after you finish a check | 15 | number |
| cool_hour_coun | Slow-pace hours after a check | 24 | number |
| cool_perc_caps | Cap percent in slow pace | 50 | 1 to 100 |
| noti_chai_orde | Alert ways | ["toas","file"] | toas, file |
| msgs_keep_days | Days to keep logs | 30 | number |
| logz_body_enab | Log full action text | false | true, false |
| lang_main_code | Language | en | en |
| labl_over | Your own button names | {} | key: list of names |
| path_over | Your own page paths | {} | key: path |
| flow_list | Routines | zero-start, daily-check | name + jobs |

## Input
Commands and flags: run `zr help`. Flags: `--text --to --url --title --price --desc --group --photo --opt --date --time --max --conf --head --yes --live --force --read --json`.

## Output
Lines on screen. Exit code: 0 ok, 1 failed, 2 usage, 3 page changed, 4 blocked.

## Files
| File | What |
|---|---|
| `<data>/stat/zr-state.db` | State, log, page map |
| `<data>/prof/` | Chrome profile |
| `<data>/stat/alerts.txt` | Alerts to you |
| `<data>/stat/report`, `backup`, `export`, `snaps` | Support, backup, export, page copies |
| `<secret>/user-acct.json` | Your ZenRows logins (one or many accounts) |
| `<data>/acct/<id>/` | Browser profile and state of one account |
