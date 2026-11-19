# wo settings

## Program
- File: `wo.exe` (Linux/macOS: `wo`)
- Run: `wo <command>`
- Output: lines on screen (or JSON with `--json`)
- Built with: Zig 0.16.0

## Settings (file `aa-conf-main.json`, found in the current folder or in `wo-work-mode`)
| Name | Does | Default | Allowed |
|---|---|---|---|
| apps_data_loca | Folder in your home for wo's own files | .wo-work-mode | any folder name |
| secr_home_loca | Folder in your home for secrets | .zz-base-home-secr | any folder name |
| hook_path_main | Hooks folder the repo must use | ci-flow-sync | any path |
| zigz_vers_pinz | Zig version the device must have | 0.16.0 | any version text |
| wipz_ager_maxz | Longest allowed gap since the last saved work (seconds) | 1800 | whole number |
| bkup_ager_maxz | Longest allowed gap since the last backup (seconds) | 1800 | whole number |
| dril_ager_maxz | Longest allowed gap since the last restore test (seconds) | 3024000 | whole number |
| dril_rtoz_maxz | Longest allowed restore time (seconds) | 900 | whole number |
| tail_days_minz | Fewest days left on the Tailscale key | 14 | whole number |
| tail_vers_minz | Oldest Tailscale version allowed | 1.102.1 | version text |
| clau_vers_minz | Oldest Claude Code version allowed (box only) | 2.1.302 | version text |
| patc_days_maxz | Most days since the last OS update | 45 | whole number |
| cpuz_okay_list | CPU model names a release build may have | x86_64, x86_64_v2, generic | text list |
| bknt_ager_maxz | Longest allowed gap since the nightly database copy (seconds) | 100800 | whole number |
| devi_name_main | Device name used in backup branch names. The environment variable `WO_DEVI_NAME` overrides it, so each device can keep its own name | empty (uses the computer name) | text |
| prof_main | Check set used when you give no `--prof` | t0 | t0, box, ci |
| chek_t0_list | Checks for the full profile | hook, head, tool, cpuz, wipz, bkup, bknt, dril, tail, tsfl, lock, patc, esus | those names |
| chek_box_list | Checks for the box profile | same, with clfl instead of esus | those names |
| chek_ci_list | Checks for the CI profile | hook, tool, cpuz | those names |
| wipz_remo_list | Private remotes to push saved work to | none | remote names |
| wipz_file_maxz | Files bigger than this many bytes stay out of the saved work | 10485760 | whole number |
| wipz_rest_tagz | Restic label for work that held a secret | wipz-held | text |
| bkup_list_file | List of state files the 5-minute backup saves | mo-modu/mo-core/bk-back-modu/bk-stat-list.txt | file path |
| bkup_dbzz_list | SQLite files copied every night | none | file paths (under your home, or absolute) |
| bkup_docs_list | Name starts of git-ignored docs that the 5-minute backup also saves | do-, aa-todo-, ag-agen, CLAUDE.md, AGENTS.md | text list |
| bkup_tagz_stat / bkup_tagz_nigh | Restic labels for the two backup jobs | stat / nigh | text |
| dril_mirr_dirz | Folder of the mirror repo to verify | empty (skipped) | folder path |
| kill_step_list | Commands `kill` runs, one list per command | gh variable set AGEN_ENAB --body false; sudo -n -u agen claude auth logout | lists of text |

## Input
Command line flags: `--json` `--live` `--force` `--conf FILE` `--prof t0|box|ci`.

## Output
Lines of `state<TAB>name<TAB>note`. States: okay · drif (drifted) · bloc (could not run) · fail · skip.

## Files
- `~/.wo-work-mode/wipz.json`, `wipzd.json`, `bkup.json`, `bknt.json`, `dril.json`: when each job last ran
- `~/.wo-work-mode/held-<date>.bundle`: work that held a secret (kept here and in restic, never pushed)
- `~/.wo-work-mode/nigh/<date>/`: the nightly database copies
- `~/.wo-work-mode/wipz.idx`: temporary work file
- `~/.wo-work-mode/dril-<date>/`: restored files from a drill
- `~/.zz-base-home-secr/`: created by `wo secr init --live`
