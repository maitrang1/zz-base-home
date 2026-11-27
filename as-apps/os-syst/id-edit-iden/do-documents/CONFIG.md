# Config

## Program
- File: `E:\zz-base-home\as-apps\os-syst\id-edit-iden\zig-out\bin\id-edit-iden.exe`
- Setting file: `E:\zz-base-home\as-apps\os-syst\id-edit-iden\aa-conf-main.json` (a missing key uses the default; use `--conf FILE` for another file)
- Built with: Zig 0.17.0

## Settings
| Name | Does | Default | Allowed |
|---|---|---|---|
| apps_data_loca | Data folder under the tena root | as-apps/os-syst/id-edit-iden | path |
| tena_loca_wind | Tena root on Windows | E:\\.zz-base-home-tena | path |
| tena_loca_unix | Tena root on Linux and macOS (under home) | .zz-base-home-tena | path |
| repo_root | Repo folder; empty = find it | "" | path or empty |
| hubz_dirz | Hub folder in the repo | ac-auto-task | folder name |
| hubz_conf_name | Hub config file name | aa-conf-main.json | file name |
| hubz_jobs_pref | Job files start with this | aa-auto-task | text |
| hubz_host | Hub address | 127.0.0.1 | address |
| hubz_chec_on | Ask the live hub after a run | true | true, false |
| hubz_wait_seco | Seconds to wait for the hub to reload | 20 | 0 or more |
| disp_file_list | Start scripts that must know every step id | ac-auto-task/ba-cmds-wind.bat, ac-auto-task/sh-cmds-linu.sh | list of paths |
| scan_skip_dirs | Folders never scanned | .git, zig-out, .zig-cache, zz-dele-auto, node_modules, aa-todo-note, id-edit-iden | list |
| scan_skip_pref | Folders never scanned if the name starts like this | zzzz-dele- | list |
| scan_skip_name | Files never scanned (history) | UPDATE.md, wo-buil-logz.txt | list |
| scan_live_ext | Code and script file types | .json .bat .cmd .sh .ps1 .zig .zon .js .html .css | list |
| scan_docs_ext | Notes file types | .txt .md | list |
| scan_docs_on | Change notes too | true | true, false |
| scan_maxz_mbyt | Biggest file scanned, in MB | 4 | 1 or more |
| scan_deep | Deepest folder level | 24 | 1 or more |
| lock_stal_seco | Seconds before a lock counts as stale | 600 | 1 or more |
| curl_name_wind | Hub client on Windows | curl.exe | name |
| curl_name_unix | Hub client on Linux and macOS | curl | name |

The hub port, its data folder and its lock lanes come from the hub's own `aa-conf-main.json`. You do not set them here.

## Input
- `old=new` pairs on the command line, or a text file with `--map FILE`.
- Flags: `--live` `--force` `--dry-run` `--json` `--conf` `--scope all|repo|state` `--no-docs`.

## Output
- Text on screen, or one JSON document with `--json`.
- Exit codes: 0 ok · 1 failed (rolled back) · 2 usage · 3 finding · 4 blocked.

## Files
- Run notes: `<tena root>\as-apps\os-syst\id-edit-iden\jour\<run>.jsonl`
- Copies of changed files: `<tena root>\as-apps\os-syst\id-edit-iden\snap\<run>\`
- Lock: `<tena root>\as-apps\os-syst\id-edit-iden\run.lock` (used locks go to `lock-old\`)
- Hub files moved: `task-state\<id>.last`, `.chain`, `.done` and `task-log\<id>.log` in the hub data folder.
