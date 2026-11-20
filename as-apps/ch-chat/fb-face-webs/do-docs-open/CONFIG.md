# fb settings

Program: `fb` · settings file: `aa-conf-main.json` (next to the exe, one or two folders up, or `--conf <file>`) · built with Zig.
Missing keys use the defaults below.

## Settings
| Name | Does | Default | Allowed |
|---|---|---|---|
| base_urlz_main | Facebook address | https://www.facebook.com | http(s) address |
| prof_dirz_path | Browser profile folder | ~/.fb-prof | folder |
| stat_dirz_path | Where fb keeps its notes | ~/.fb-state | folder |
| brow_exec_path | Chrome or Edge file ("" = find it) | "" | file |
| brow_head_mode | Hide the browser window | false | true/false |
| brow_time_seco | Seconds to wait for one step | 60 | 1 and up |
| type_dely_msec | Time between keys (min, max) | [90, 260] | numbers |
| acti_dely_secs | Pause between actions (min, max) | [8, 40] | numbers |
| mous_step_coun | Steps of one mouse move | 18 | 1 to 200 |
| time_scal_perc | Speed of waits (100 = normal, 0 = none, tests only) | 100 | 0 to 1000 |
| rand_seed_numb | Fixed randomness (0 = random) | 0 | number |
| capz_post_dayz | Posts per 24 hours | 3 | 0 and up |
| capz_comm_dayz | Comments and replies per 24 hours | 30 | 0 and up |
| capz_mark_dayz | Marketplace actions per 24 hours | 2 | 0 and up |
| capz_grou_dayz | Group posts and joins per 24 hours | 5 | 0 and up |
| capz_frie_dayz | Friend requests per 24 hours | 5 | 0 and up |
| capz_dmsg_dayz | Messages per 24 hours | 30 | 0 and up |
| capz_reac_dayz | Reactions per 24 hours (reserved) | 60 | 0 and up |
| quie_hour_rang | Quiet hours (from, to) | [23, 6] | hours 0 to 23 |
| quie_zone_minu | Minutes from UTC to your time | 420 | -840 to 840 |
| warm_dayz_coun | Days to reach full limits | 14 | 0 and up |
| retr_coun_maxz | Tries to find a button | 3 | 1 to 10 |
| smar_mode_enab | Let AI write replies | false | true/false |
| smar_chai_orde | AI tools in order | ["clau","llam"] | clau, llam |
| smar_clau_exec | Claude command | claude | command |
| smar_llam_urlz | Local llama.cpp address | http://127.0.0.1:8080 | local http address |
| smar_time_seco | Seconds to wait for AI | 90 | 1 and up |
| repl_temp_list | Reply texts when AI is off | 2 short thanks | list of text |
| path_* | Facebook page paths used by jobs | Facebook defaults | paths |
| labl_* | Button and box names (English + Vietnamese) | built in | lists of text |

## Input
Words on the command line (see HOW-TO). Nothing is read from Facebook except the pages the job opens.

## Output
Text on screen (or `--json` for status, log, ledger). Exit code: 0 ok · 1 failed · 2 wrong command · 3 page looks different · 4 blocked.

## Files
- `fb-state.db` in `stat_dirz_path`: limits counters, once-only keys, ledger, log.
- Browser profile in `prof_dirz_path`: your Facebook login.
