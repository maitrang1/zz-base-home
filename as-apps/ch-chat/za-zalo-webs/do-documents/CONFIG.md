# za settings

Program: `za` · settings file: `aa-conf-main.json` (next to the exe, or `--conf <file>`) · built with Zig.
Missing keys use the defaults below. Times are in milliseconds (msec) or seconds (secs).

## Settings
| Name | Does | Default | Allowed |
|---|---|---|---|
| data_loca_wind | Data root on Windows (profile in `prof`, notes in `stat`) | E:\.zz-base-home-tena\as-apps\ch-chat\za-zalo-webs | folder |
| data_loca_unix | Data root on Linux and macOS | ~/.zz-base-home-tena/as-apps/ch-chat/za-zalo-webs | folder |
| brow_exec_path | Chrome or Edge file ("" = find it) | "" | file |
| brow_head_mode | true = hidden browser window | false | true, false |
| pipe_mode_enab | Reserved, no effect | false | true, false |
| zalo_page_urlz | Zalo Web address | https://chat.zalo.me/ | http(s) address |
| type_dely_msec | Pause between keys | [90, 260] | two numbers, low ≤ high |
| acti_dely_secs | Pause between actions | [6, 25] | two numbers, low ≥ 1 |
| read_dely_msec | Pause after opening a chat | [800, 3500] | two numbers |
| acct_maxx_coun | Most accounts in `user-acct.json` | 5 | 1 to 20 |
| acct_gap_secs | Wait between accounts with `--acct all` (min, max seconds) | [300, 1200] | numbers |
| secr_loca_main | Folder with `user-acct.json` | ~/.zz-base-home-secr/as-apps/ch-chat/za-zalo-webs | folder |
| capz_send_hour | Sends per hour | 20 | 1 or more, ≤ day cap |
| capz_send_dayz | Sends per day | 120 | 1 or more |
| capz_newc_dayz | New-contact actions per day | 5 | 0 or more |
| capz_send_minu | Sends per minute | 6 | 1 or more |
| gapz_send_msec | Least gap between sends | 3000 | 1000 or more |
| quie_hour_rang | No activity from hour to hour | [23, 6] | hours 0-23 (equal = none) |
| loca_utcz_mins | Your time zone, minutes from UTC | 420 | -720 to 840 |
| warm_dayz_coun | Days to grow caps from 20% to 100% | 7 | 0 or more |
| retr_coun_maxz | Tries to find a button | 3 | 1-9 |
| read_msgz_maxz | Messages read per chat | 20 | 1 or more |
| feed_chat_list | Chats whose stored messages `za feed` hands to scra. Only these; empty = nothing leaves | none | list of chat names |
| feed_dirz_wind · feed_dirz_unix | Folder where `za feed --live` writes its `.jsonl` files (scra's `social-in` folder) | scra data folder | a path (`~` works) |
| feed_item_maxz | Most messages per chat in one file | 500 | 1 to 5000 |
| feed_text_maxz | Longest message text kept, in bytes | 4000 | 200 or more |
| brow_time_secs | Browser wait | 60 | 1 or more |
| logi_wait_secs | How long login waits for the QR | 300 | 1 or more |
| smar_mode_enab | AI replies | false | true, false |
| smar_chai_orde | AI order | ["clau", "llam"] | clau, llam |
| smar_clau_exec · smar_clau_argz | Claude Code command and arguments (`{p}` = prompt) | claude · ["-p","{p}"] | command |
| smar_llam_exec · smar_llam_argz | llama.cpp command and arguments | llama-cli · ["-p","{p}",...] | command |
| smar_time_secs | AI wait | 60 | 1 or more |
| rand_seed_fixd | Fixed random seed (0 = random) | 0 | number |
| labl_file_path | Your own label file instead of the built-in `so-labl-zalo.json` ("" = built-in) | "" | file |
| halt_word_list | Extra words that stop za (the built-in Vietnamese and English lists always apply) | [] | list of text |
| lang_main_code | Language of messages | vi | vi, en |
| capz_reac_dayz | Reactions per day | 60 | 1 or more |
| capz_upld_dayz | File uploads per day (also count as sends) | 30 | 1 or more |
| outb_dirz_path | Folder za may send files from ("" = `<data root>/outb`) | "" | folder |
| file_size_maxz | Biggest file in bytes | 104857600 | 1 or more |
| scrl_step_maxz | Most scroll steps when looking for a chat or old messages | 40 | 1 or more |
| noti_chai_orde | How za tells you something needs you | ["toast","hubz","file"] | toast, hubz, file |
| wait_dead_mins | Minutes to wait for you before parking | 30 | 1 or more |
| wait_sett_mins | Minutes to settle after you cleared a check | 15 | 0 or more |
| cool_hour_coun | Hours of calm pace after a check | 24 | 1 or more |
| fail_strk_maxz | Failed sends in a row that stop everything | 3 | 1 or more |
| msgs_keep_days | Days to keep chat text (0 = forever) | 30 | 0 or more |
| logz_body_enab | Keep chat text in the log (off = hashed) | false | true, false |
| inbx_chek_mins | Minutes between inbox checks in `za watch` | 10 | 1 or more |
| sess_actv_mins · sess_brek_mins | Work session and break length | [20,60] · [5,20] | two numbers |
| watc_chek_maxz · watc_deadl_mins · watc_repl_enab | Watch limits (0 = no check limit) and price replies while watching | 0 · 600 · false | numbers, true/false |
| smar_calls_dayz | AI replies per day before the template is used | 20 | 0 or more |
| brow_vers_minz | Oldest Chrome version the canary accepts | 120 | number |
| flow_list | Named routines: `[{"name":"morning","items":["read","send Mom hi"]}]` | [] | list |
| reci_pric_word | Words that mark a price question | price, giá, bao nhiêu | list of text |
| reci_pric_text | Your price reply ("" = none) | "" | text |
| reci_bulk_maxz | Replies at once before `--force` | 5 | 0 or more |

## Input
Commands and words you type. A settings file.

## Output
Text or `--json` on screen. Exit code: 0 ok · 1 failed · 2 wrong use · 3 finding (something to check) · 4 blocked.

## Files
| File | What |
|---|---|
| <data root>/stat/za-stat.db | Counts, sent messages, chats, log |
| <data root>/stat/alerts.txt · za-alert.txt | What needed you, and when |
| <data root>/stat/probe · export · report · backup | Page dumps (text hashed) · your data · support bundle · database copies |
| <data root>/outb | The only folder za sends files from |
| <data root>/prof | Browser profile with your Zalo login |
| so-labl-zalo.json | Zalo button names in Vietnamese and English, per job; fix it when a label changes |
