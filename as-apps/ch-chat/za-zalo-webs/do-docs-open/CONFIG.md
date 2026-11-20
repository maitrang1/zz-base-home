# za settings

Program: `za` · settings file: `aa-conf-main.json` (next to the exe, or `--conf <file>`) · built with Zig.
Missing keys use the defaults below. Times are in milliseconds (msec) or seconds (secs).

## Settings
| Name | Does | Default | Allowed |
|---|---|---|---|
| prof_dirz_path | Browser profile folder | ~/.za-prof | folder |
| stat_dirz_path | Where za keeps its notes | ~/.za-state | folder |
| brow_exec_path | Chrome or Edge file ("" = find it) | "" | file |
| brow_head_mode | true = hidden browser window | false | true, false |
| pipe_mode_enab | Reserved, no effect | false | true, false |
| zalo_page_urlz | Zalo Web address | https://chat.zalo.me/ | http(s) address |
| type_dely_msec | Pause between keys | [90, 260] | two numbers, low ≤ high |
| acti_dely_secs | Pause between actions | [6, 25] | two numbers, low ≥ 1 |
| read_dely_msec | Pause after opening a chat | [800, 3500] | two numbers |
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
| brow_time_secs | Browser wait | 60 | 1 or more |
| logi_wait_secs | How long login waits for the QR | 300 | 1 or more |
| smar_mode_enab | AI replies | false | true, false |
| smar_chai_orde | AI order | ["clau", "llam"] | clau, llam |
| smar_clau_exec · smar_clau_argz | Claude Code command and arguments (`{p}` = prompt) | claude · ["-p","{p}"] | command |
| smar_llam_exec · smar_llam_argz | llama.cpp command and arguments | llama-cli · ["-p","{p}",...] | command |
| smar_time_secs | AI wait | 60 | 1 or more |
| rand_seed_fixd | Fixed random seed (0 = random) | 0 | number |
| labl_* | Names of Zalo buttons and boxes (search, message box, send, unread mark, QR page, pin, mute, forward, group, reminder fields, chat role, message role, own-message prefix) | Vietnamese guesses | text |
| halt_word_list | Words that stop za | captcha, xác minh, bị khóa, … | list of text |
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
| ~/.za-state/za-stat.db | Counts, sent messages, chats, log |
| ~/.za-state/za-alert.txt | Last alert (halt or login needed) |
| ~/.za-prof | Browser profile with your Zalo login |
