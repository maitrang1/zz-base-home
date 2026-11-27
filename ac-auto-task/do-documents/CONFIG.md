# Reference
Lookup only. For steps, see HOW-TO.md.

## Program
| | |
|---|---|
| File | zig-out\bin\ac-auto-task.exe |
| Run | ac-auto-task.exe [port] |
| Output | a web page at http://127.0.0.1:<port>, plus the files under Your data |
| Built with | Zig 0.17.0, one file, no other program needed |

## Settings
File: aa-conf-main.json, next to aa-auto-task.json. Every key is optional. A missing file uses the defaults. A bad value is skipped with a warning and its default is used.
| Name | Does | Default | Allowed |
|---|---|---|---|
| port | the port the page is served on (127.0.0.1 only). A port typed on the command line wins | 4000 | 1 to 65535. If it is taken, the program says so and stops |
| jobs_same_time | jobs that may run at the same time (this repo sets 8) | 4 | 1 to 8 |
| lock_list | lock name to the job or step ids that share it: an id or a prefix (`scra-` covers scra-raws, scra-cars). Same lock = one at a time | none (all `main`) | `{ "scra": ["scra-"], "cicd": ["cicd-", "home-doct"] }` · up to 32 ids in all · id ≤ 64 · name ≤ 32 · name `none` = run beside anything |
| cmds_hist_maxz | commands kept in history | 64 | 1 to 10000 |
| time_limi_seco | default time limit of a job, in seconds | 86400 | 1 to 86400 |
| apps_data_loca_wind | data folder on Windows | E:\.zz-base-home-tena\ac-auto-task | absolute path, `~/name`, or a name under your user folder (max 260, no ..) |
| apps_data_loca_unix | data folder on Linux/macOS | ~/.zz-base-home-tena/ac-auto-task | same |
| envi_mode | the environment (PATH and other variables) that commands run with. fresh: Windows picks up changes made after the program started (an install, setx, System Properties); other systems keep the launch environment. login: fresh, and on Linux/macOS the default shell runs as a login shell (-lc) so it reads your profile files. inherit: the launch environment, exactly as before | fresh | fresh, login, inherit |

## Your data
Saved in the data folder (the apps_data_loca_wind / apps_data_loca_unix setting; Windows default E:\.zz-base-home-tena\ac-auto-task\), outside the program folder, so updates never touch it.
| File | Holds |
|---|---|
| config.json | settings, tabs, favorites |
| output.json | saved output per tab |
| history.txt | commands you ran (newest first, max cmds_hist_maxz) |
| task-log\ | what each job printed (one file per job, rolls over at 1 MB) |
| task-state\ | which one-time jobs already ran |
Files are written to a temporary name first, then renamed. A crash mid-save cannot damage the old file.

## Scheduled jobs
Jobs live in aa-auto-task.json in the project folder (next to the zig-out folder). Each has an id, a type (when it runs), an optional sche (the schedule) and a run (the command). Leave run out and the job runs ba-cmds-wind.bat <id> (Windows) or bash sh-cmds-linu.sh <id> (Linux, macOS). The scripts are next to aa-auto-task.json (ba-cmds-wind.bat on Windows, sh-cmds-linu.sh on Linux and macOS). Add one line (Windows) or one case (Linux, macOS) per job id. An id that has no line stops with exit code 2. Windows line, above the "unknown" echo: `if "%~1"=="my-job" "C:/tools/my.exe" --live & call exit /b %%errorlevel%%`. Linux and macOS line, above the `*)` case: `my-job) exec "$HOME/tools/my" --live ;;`.
| Type | Runs when | sche looks like |
|---|---|---|
| boot | the program starts | — |
| cron | the clock matches | 0 2 * * * |
| puls | every N seconds, minutes, hours | 30s · 5m |
| once | one time only | 261231_0930 |
| hand | you click play | — |
| link | another job finishes | after:other-job:ok |
| loop | always, restarts if it stops | — |
| even | a file or folder changes | C:\folder |
| flag | a file appears | file:C:\go.flag |
| queu | a file sits in a folder | C:\inbox |
| disk | free space drops past a size | C:\<10GB |
| idle | you have been away a while | 15m |
| powe | power switches battery / AC | battery |
| proc | a program starts | app.exe |
| live | a program stops | app.exe |
| tcpr | a port opens | 3000 |
| webs | a web address starts answering | localhost:8080 |
| sola | sunrise or sunset | sunset+30 |
| mail | not available, listed but never runs | — |
A job with ids is a chain. Its type is the trigger that starts it: boot (no sche), cron, puls or sola, with the same sche form. The type must match the sche, and the old type chai is rejected.
Random hour: put hours in [ ] in a cron chain or cron job time to pick one at random each day, for example `08 [09,10,11],[15,16],[22] * * *`. Ranges work: [09..11]. The pick stays the same all day, even after a restart.
Linux and macOS: disk takes a path like /home<10GB; idle needs xprintidle on Linux; powe and proc work everywhere.
Optional per job:
| Field | Does | Default | Allowed |
|---|---|---|---|
| on | false switches the job off | true | true · false |
| try | run again this many times after a failure | 0 | whole number |
| tmo | stop the job after this many seconds | time_limi_seco | up to 86400 (24 h) |
| dela | minutes to wait before a boot job, or before a chain's first job | 0 | whole number |
| catc | if the PC was off when a cron, once or chain job was due, run the missed slots when it is back, up to this many (once and chain: at most 1) | 0 (none) | 0-9 · the old `"catchup":"once"` still loads as `1` |
| ids | makes the job a chain (type cron, puls, sola or boot, matching its sche): the ids to run in order. An id with no job line runs the auto-run script. A failed step does not stop the chain | — | 1-32 distinct ids |
| plus | chain only: the wait between jobs, six positions [years, months, days, hours, mins, secs]. A list picks one at random, one letter = default 0 | — | whole numbers, up to 64 per list |
| cwd | folder to run in | the program folder | a folder path |
| shell | which shell | auto | see Shells |
| noLog | no log for this job | false | true · false |
| _cmt | a note to yourself | — | any text |
A job with a mistake is not run. It is listed with the reason, and the other jobs keep going.
Auto-run scripts: the repo's own jobs (`home-*` for the `wo` tool, `linu-shut-nigh`) have no run line; `ba-cmds-wind.bat` / `sh-cmds-linu.sh` know their commands. Private settings for them go in `aa-conf-main.env` next to the scripts (git-ignored, one `KEY=value` per line, an environment variable of the same name wins): `CMDS_MISE` = the mise command (default: mise on your PATH) · `WO_DEVI_NAME` = the device name `wo` uses in its backup refs (default: the computer name).

## Input
Commands typed in the page, and the jobs in aa-auto-task.json.

## Output format
One JSON line at a time, as it arrives:
{"t":"out","d":"hello\r\n"} · {"t":"err","d":"..."} · {"t":"exit","code":0,"elapsed":1240,"cwd":"..."}
t = out (normal) · err (error) · exit (finished) · hb ("still here", ignore it). No size limit and no time limit.

## Shells
auto (cmd on Windows, $SHELL elsewhere) · cmd · powershell · pwsh · bash · bash-login · sh · zsh · fish · wsl. The page lists only the shells installed here.

## Security
Listens on 127.0.0.1 only. Accepts pages from its own page only. Serves only .html .css .js .ico files from the program folder (never sources, the job list or docs). No login. This program runs commands on your computer: do not put it on a shared or public machine.

## Stopping commands
Stopping a command also stops everything it started (Windows job object, elsewhere the process group). Closing the page does NOT stop a command. A command whose page vanished (browser crash) stops after about 3 seconds. If auto-task itself stops or crashes, every running command stops too.
