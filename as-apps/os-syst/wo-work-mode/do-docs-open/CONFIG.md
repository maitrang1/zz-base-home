# wo settings

## Program
- File: `wo.exe` (Linux/macOS: `wo`)
- Run: `wo <command>`
- Output: lines on screen (or JSON with `--json`)
- Built with: Zig 0.17.0

## Settings (file `aa-conf-main.json`, found in the current folder or in `wo-work-mode`)
| Name | Does | Default | Allowed |
|---|---|---|---|
| apps_data_loca | Folder for wo's own files, under the tena root | as-apps/os-syst/wo-work-mode | relative folder |
| tena_loca_wind | The tena root on Windows | E:\.zz-base-home-tena | absolute path, or a folder under your home |
| tena_loca_unix | The tena root on Linux and macOS | .zz-base-home-tena | same |
| secr_home_loca | Folder in your home for secrets | .zz-base-home-secr | any folder name |
| hook_path_main | Hooks folder the repo must use | ci-flow-sync | any path |
| zigz_vers_pinz | Zig version the device must have | 0.17.0 | any version text |
| wipz_ager_maxz | Longest allowed gap since the last saved work (seconds) | 1800 | whole number |
| sync_ager_maxz | Longest allowed gap since the last good `wo sync` (seconds) | 1800 | whole number |
| bkup_ager_maxz | Longest allowed gap since the last backup (seconds) | 1800 | whole number |
| dril_ager_maxz | Longest allowed gap since the last restore test (seconds) | 3024000 | whole number |
| dril_rtoz_maxz | Longest allowed restore time (seconds) | 900 | whole number |
| tail_days_minz | Fewest days left on the Tailscale key | 14 | whole number |
| tail_vers_minz | Oldest Tailscale version allowed | 1.102.1 | version text |
| clau_vers_minz | Oldest Claude Code version allowed (box only) | 2.1.302 | version text |
| patc_days_maxz | Most days since the last OS update | 45 | whole number |
| cpuz_okay_list | CPU model names a release build may have | x86_64, x86_64_v2, generic, apple_m1 (the Mac baseline) | text list |
| bknt_ager_maxz | Longest allowed gap since the nightly database copy (seconds) | 100800 | whole number |
| devi_name_main | Device name used in backup branch names. The environment variable `WO_DEVI_NAME` overrides it, so each device can keep its own name | empty (uses the computer name) | text |
| prof_main | Check set used when you give no `--prof` | t0 | t0, box, ci |
| chek_t0_list | Checks for the full profile | hook, head, tool, cpuz, sync, bkup, bknt, dril, tail, tsfl, lock, patc, esus | those names |
| chek_box_list | Checks for the box profile | same, with clfl instead of esus | those names |
| chek_ci_list | Checks for the CI profile | hook, tool, cpuz | those names |
| doct_acpt_list | Checks whose drift or blocked result you accept: shown as okay, reason kept ("accepted risk: ...") | none | those names |
| wipz_remo_list | PRIVATE remotes to push saved work to. Never a public repo: saved work is readable by anyone who can read the remote. Add the same remote names on every device (`git remote add NAME URL`) | none (ships with wipg, wipl) | remote names |
| wipz_file_maxz | Files bigger than this many bytes stay out of the saved work | 10485760 | whole number |
| wipz_rest_tagz | Restic label for work that held a secret | wipz-held | text |
| bkup_list_file | List of state files the 5-minute backup saves (paths under the tena root) | mo-modu/mo-core/bk-back-modu/bk-stat-list.txt | file path |
| bkup_dbzz_list | SQLite files copied every night | none | file paths (under your home, or absolute) |
| bkup_docs_list | Name starts of git-ignored docs that the 5-minute backup also saves | do-, aa-todo-, ag-agen, rn-rena-hist, CLAUDE.md, AGENTS.md | text list |
| bkup_tagz_stat / bkup_tagz_nigh | Restic labels for the two backup jobs | stat / nigh | text |
| docs_gitd_name | Folder (under your home) holding the hidden git data of the private docs repo. `wo docs init` creates it, `wo docs sync` keeps the git-ignored docs (same name starts as `bkup_docs_list`) in step across devices | .zz-base-home-docs.git | folder name |
| docs_remo_list | Remotes of the main repo that the docs repo also uses (same host and account, repo name + `-docs`) | origin, mirr | remote names |
| rels_keyz_file | Public key (under your home) whose private half is loaded in ssh-agent; `wo rels sign TAG --live` signs the verified release hashes with it | .ssh/id_ed25519_sign.pub | file path |
| beat_urlz_file | File (under your home) whose first line is the https ping address of an outside dead-man monitor such as Healthchecks.io. `wo beat --live` pings it, or pings `/fail` when a check below is stale. If the hub dies the pings stop and the monitor alerts you. Keep the file outside the repo | empty (off) | file path |
| beat_chek_list | Stamps that must be fresh for a healthy ping (`docs`, `sync`, `bkup`, `bknt`). Empty = ping only proves the hub runs | docs | text list |
| beat_ager_maxz | Seconds a stamp may be old before the ping says fail | 3600 | seconds |
| sync_bran_main | Branch `wo sync` works on; anything else is blocked | main | branch name |
| sync_remo_list | Remotes `wo sync` merges from and pushes to, in order | origin, mirr | text list |
| sync_deny_list | Path prefixes `wo sync` never commits | empty | text list |
| sync_quie_secz | A changed file is committed only after it has been idle this long | 120 | seconds |
| sync_file_cntz | More files than this to commit stops the run | 200 | whole number |
| sync_file_maxz | A file bigger than this is kept out of the commit and reported (the run goes on) | 10485760 | bytes |
| sync_tryz_maxz | Fetch, merge and push attempts per run | 3 | whole number |
| ci_bran_main | Branch the CI watchers read | main | branch name |
| ci_gitl_proj | GitLab project path for the public pipelines API (slash written as %2F) | dinhthimaitrang1%2Fzz-base-home | text |
| ci_mirr_grac | Seconds GitHub and GitLab main may differ before `wo ci stat` fails | 900 | seconds |
| ci_deps_ager | Age in seconds after which an open Dependabot PR counts as stale | 604800 | seconds |
| ci_test_list | Build files `wo ci test` runs `zig build test` on, from the repo root | wo + hub | text list |
| dril_mirr_dirz | Folder of the mirror repo to verify | empty (skipped) | folder path |
| kill_step_list | Commands `kill` runs, one list per command | gh variable set AGEN_ENAB --body false; sudo -n -u agen claude auth logout | lists of text |

## Input
Command line flags: `--json` `--live` `--force` `--conf FILE` `--prof t0|box|ci`.

## Output
Lines of `state<TAB>name<TAB>note`. States: okay · drif (drifted) · bloc (could not run) · fail · skip.

## Files
`<wo data>` = `as-apps/os-syst/wo-work-mode` under the tena root (apps_data_loca).
- `<wo data>/wipz.json`, `wipzd.json`, `bkup.json`, `bknt.json`, `dril.json`: when each job last ran
- `<wo data>/held-<date>.bundle`: work that held a secret (kept here and in restic, never pushed)
- `<wo data>/nigh/<date>/`: the nightly database copies
- `<wo data>/wipz.idx`: temporary work file
- `<wo data>/dril-<date>/`: restored files from a drill
- `~/.zz-base-home-secr/`: created by `wo secr init --live`
