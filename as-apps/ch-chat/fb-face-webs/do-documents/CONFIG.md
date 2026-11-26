# fb settings

Program: `fb` · settings file: `aa-conf-main.json` (next to the exe, one or two folders up, or `--conf <file>`) · built with Zig.
Missing keys use the defaults below. A name this program does not know (a typo) or a bad value stops it with "bad config" (exit 2) and the unknown name is printed.

## Settings
| Name | Does | Default | Allowed |
|---|---|---|---|
| base_urlz_main | Facebook address | https://www.facebook.com | http(s) address |
| base_bizz_main | Business Suite address | https://business.facebook.com | http(s) address |
| path_* | Page paths jobs use (home, notifications, friends, messages, selling, events, stories, reels, profile) | Facebook defaults | paths |
| data_loca_wind | Where fb keeps everything on Windows | E:\.zz-base-home-tena\as-apps\ch-chat\fb-face-webs | folder |
| data_loca_unix | Same on Linux and macOS | ~/.zz-base-home-tena/as-apps/ch-chat/fb-face-webs | folder |
| brow_exec_path | Chrome or Edge file ("" = find it) | "" | file |
| brow_head_mode | Hide the browser window | false | true/false |
| brow_wind_widt | Visible window width, in Chrome units (0 = Chrome's own; set with the height) | 0 | 0 to 10000 |
| brow_wind_high | Visible window height, in Chrome units | 0 | 0 to 10000 |
| brow_wind_scal | Display scale of the window and page (0 = system). 1.0 on a 125% screen looks like 80% zoom | 0 | 0, or 0.25 to 4 |
| brow_wind_left | Left position of a visible window; negative hides the Windows border gap | 0 | -100 to 10000 |
| brow_time_seco | Seconds to wait for one step | 60 | 1 and up |
| brow_vers_minz | Oldest Chrome version fb accepts | 120 | number |
| lang_main_code | Language of messages | vi | vi, en |
| type_dely_msec | Time between keys (min, max); waits are mostly short, one in five long, always inside this range | [90, 260] | min 30, max at least 1.5 x min |
| acti_dely_secs | Pause between actions (min, max) | [8, 40] | min 2, max above min |
| mous_step_coun | Base steps of one mouse move (long moves use up to 3 times this) | 18 | 8 to 200 |
| time_scal_perc | Speed of waits (100 = normal) | 100 | 50 to 1000 |
| rand_seed_numb | Must stay 0: a fixed seed is refused (real entropy every run, the seed is logged as `pace`) | 0 | 0 |
| capz_post_dayz | Posts per 24 hours | 3 | 0 and up |
| capz_comm_dayz | Comments and replies | 30 | 0 and up |
| capz_mark_dayz | Marketplace actions | 2 | 0 and up |
| capz_grou_dayz | Group posts, joins, listing shares | 5 | 0 and up |
| capz_frie_dayz | Friend actions | 5 | 0 and up |
| capz_dmsg_dayz | Messages | 30 | 0 and up |
| capz_reac_dayz | Reactions and saves | 60 | 0 and up |
| capz_shar_dayz | Shares | 10 | 0 and up |
| capz_admn_dayz | Group admin and page actions | 60 | 0 and up |
| capz_evnt_dayz | Event actions | 3 | 0 and up |
| capz_stor_dayz | Stories and reels | 5 | 0 and up |
| capz_prof_dayz | Profile edits | 3 | 0 and up |
| capz_acct_dayz | Account, security and settings changes | 12 | 0 and up |
| capz_data_dayz | Downloads, activity-log clean-up, albums | 5 | 0 and up |
| capz_mone_dayz | Money: payment methods, Meta Verified, ads (0 = off) | 0 | 0 and up |
| capz_help_dayz | Reads, support messages, map pages | 40 | 0 and up |
| acct_maxx_coun | Most accounts in `user-acct.json` | 5 | 1 to 20 |
| acct_gap_secs | Wait between accounts when running `--acct all` (min, max seconds) | [240, 960] | numbers |
| aliv_look_hour | Hours between the automatic read-only login looks of `fb alive` (one account per run; 0 is refused) | 8 | 1 to 72 |
| mone_spen_capz | Biggest budget a spend job may use (0 = none) | 0 | 0 and up |
| secr_loca_main | Folder with your secrets file `user-acct.json` | ~/.zz-base-home-secr/as-apps/ch-chat/fb-face-webs | folder |
| base_deve_main | Developer console address | https://developers.facebook.com | http(s) address |
| map_page_maxx | Pages `fb map` visits per run | 25 | 1 to 200 |
| map_deep_maxx | How many link steps from a start page | 2 | 0 to 3 |
| feed_path_list | Pages `fb read feed` reads for scra: group feeds, Marketplace searches (paths that start with `/`) | none | list of paths |
| feed_dirz_wind · feed_dirz_unix | Folder where `fb read feed --live` writes its `.jsonl` files (scra's `social-in` folder) | scra data folder | a path (`~` works) |
| feed_item_maxz | Most posts taken from one page per run | 50 | 1 to 500 |
| feed_text_maxz | Longest post text kept, in bytes | 4000 | 200 or more |
| map_seed_list | Pages `fb map` starts from | settings, Accounts Center, activity log, ... | list of paths |
| map_allo_list | Only paths starting like this are visited | settings, accountscenter, privacy, ... | list of paths |
| path_*, pbiz_*, pdev_* | Page paths jobs use (account, settings, billing on the business site, developer console, help, ...). Change one if Facebook moves a page | Facebook defaults | paths |
| quie_hour_rang | Quiet hours (from, to) | [23, 6] | hours 0 to 23 |
| quie_zone_minu | Minutes from UTC to your time | 420 | -840 to 840 |
| warm_dayz_coun | Days to reach full limits | 14 | 0 and up |
| retr_coun_maxz | Tries to find a button | 3 | 1 to 10 |
| wait_maxx_minu | Minutes fb waits for you during a check | 30 | 1 and up |
| sett_wait_minu | Minutes fb waits after you finish a check | 15 | 0 and up |
| cool_hour_coun | Hours of slow pace after a check | 24 | 1 and up |
| cool_perc_caps | Limits during slow pace (percent) | 50 | 1 to 100 |
| noti_chai_orde | How fb tells you (popup, file) | ["toas","file"] | toas, file |
| msgs_keep_days | Days to keep logs | 30 | 1 and up |
| logz_body_enab | Keep readable text in logs | false | true/false |
| smar_mode_enab | Let AI write replies | false | true/false |
| smar_chai_orde | AI tools in order | ["clau","llam"] | clau, llam |
| smar_clau_exec | Claude command | claude | command |
| smar_llam_urlz | Local llama.cpp address | http://127.0.0.1:8080 | local http address |
| smar_time_seco | Seconds to wait for AI | 90 | 1 and up |
| smar_call_dayz | AI calls per 24 hours | 20 | 0 and up |
| repl_temp_list | Reply texts when AI is off | 2 short thanks | list of text |
| inqu_temp_list | Texts for Marketplace buyers | 2 short answers | list of text |
| labl_over | Your own button names, by key (see `fb doctor`) | {} | key → list of names |
| labl_* | Older button and box names (English + Vietnamese) | built in | lists of text |
| flow_list | Routines: name and jobs (`job`, `text`, `url`, `maxn`, ...) | one `morning` example | list |

## Input
Words on the command line (see HOW-TO). Nothing is read from Facebook except the pages a job opens.

## Output
Text on screen (or `--json` for status, log, ledger). Exit code: 0 ok · 1 failed · 2 wrong command (bad flag, unknown command, bad or unknown config key, `--dry-run` with `--live`) · 3 page looks different · 4 blocked.

`--json` prints exactly one JSON document on stdout, failures too. Core fields: `ok` · `cmd` · `exit` · `dry_run` (commands that can act) · `code` and `msg` (failures). Text lines of a command arrive in `lines`, a list in `data`. Errors and progress stay on stderr. `status` reads only: it creates no folder and no file.

## Files (all inside the data folder)
- `stat/fb-state.db`: limits counters, once-only keys, ledger, log, routines.
- `stat/map/<date>/`: pages and controls saved by `fb map` (redacted).
- `stat/alerts.txt`: what fb told you. `stat/snaps/`, `report/`, `backup/`, `export/`: made by `fb snap`, `report`, `backup`, `export`.
- `prof/`: the browser profile with your Facebook login. This is the only folder fb uses outside its program folder.
