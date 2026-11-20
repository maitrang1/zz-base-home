# Updates
What changed, newest first.

## 2026-11-20
Changed: this PC's job file is now `aa-auto-task-wi01.json` (was `aa-auto-task.json`); `aa-auto-task-li01.json` (Dev 02) is a copy of it. The startup script `ru-star-wind.vbs` starts the hub as `auto-task 4000 aa-auto-task-wi01.json`. Without a file name the hub still reads `aa-auto-task.json`.
Changed: the repo's own task ids `work-*` are now `home-*` (for example `home-sync`, `home-code`). Old log files were copied to the new names. A device that keeps its own jobs file must rename the ids there too.
Changed: the task files (`aa-auto-task.json`, `aa-auto-task-li01.json`) now use the old hub layout: one compact task per line, a blank line between tasks, a fixed key order. The content did not change.
Changed: the seven `wo-*` task ids are now `work-*` (every id word has 4 letters), for example `work-wipz`. Old log files were copied to the new names. A device that runs its own task file keeps its old history under the old name.
Added: `do-docs-deve/ta-task-writ.txt`, the rules for writing tasks.
Changed: the `work-*` jobs no longer carry long command lines with your folders. `ba-cmds-wind.bat` and `sh-cmds-linu.sh` now hold their commands (one line or case per id), find the repo from where they sit, and read the device name from the private `aa-conf-main.env`. On a Linux device that runs `wo`, set `WO_DEVI_NAME` there once, or `wo` uses the computer name.
Changed: `linu-shut-nigh` moved to the Linux task file only (Linux-only jobs go last).
Added: two checks for the scripts, `sh-cmds-linu-test.sh` and `ba-cmds-wind-test.bat`.

## 2026-11-19
Added: commands now run with a fresh environment (Windows): a program you install or a PATH or variable you change after auto-task started is seen by the next command, with no restart. Setting `envi_mode` in aa-conf-main.json: fresh (default), login (Linux/macOS login shell), inherit (old behavior). `/env` lists which variable names differ.
Fixed: a tab whose folder was deleted or moved no longer fails every command until the tab is closed. The next command says so and runs in the default folder.

## 2026-11-18
Added: web addresses in the output are clickable links (new tab), with a small copy icon before each one. Only http, https and www. are linked.
Added: stop / play (pause / resume) on every running block and on every running chain. It freezes the command with all the programs it started (a chain also holds back its next step) and resumes exactly where it stopped. Stop still works while paused.
Removed: the "fill variables" popup. A {name} in a command is now sent to the shell as you typed it. Answer questions in the input box under a running command instead.
Changed: the one shared input bar is gone. Every running command now has its own input box under its output, so many commands can run at once and each gets only its own answers, in any tab. Up and Down bring back earlier answers of that command.
Added: a pulsing dot on a block and on its tab when the command stopped at a question and waits for you.
Added: an answers box. Type one line per question, run the command, and the lines are sent one at a time, each after the next question shows up.
Fixed: an answer and its Enter were sent in two pieces, so a command with two questions could get an empty answer to the second one. They are now sent together.
Changed: the job file is now aa-auto-task.json (was so-auto-list.json). Rename your own copy if you have one.
Changed: the program is now auto-task.exe (was cmd-run.exe). The data folder and the port are unchanged.
Changed: auto labels in history and blocks are shorter and cleaner (no more b for dir /b, no more && pieces). Labels you did not edit are updated once; labels you edited stay.
Fixed: a folder change with cd now carries over to the next command in the same tab.
Fixed: commands finish about 0.15 seconds sooner (no more wait at the end of every run).
Added: an optional always-on-top mini window (Electron), in ui-elec-mini/. The web version stays the main one. See HOW-TO.md.
Added: aa-conf-main.json sets the port, workers, history size, default job time limit and data folder name. See CONFIG.md.
Changed: the data folder is now ~\.ac-auto-task (was ~\.zz-base-home-auto). To keep your history, tabs and job state, move the old folder to the new name, or set "apps_data_loca" in aa-conf-main.json to the old name.
Fixed: history no longer breaks when a command prints a line that is only ####.
Added: the two auto-run scripts, ba-cmds-wind.bat (Windows) and sh-cmds-linu.sh (Linux, macOS), next to the job file. A job with no run lands there; an id with no line exits with code 2.
Changed: the job file is now so-auto-list.json (was tk-auto-list.json). Rename your own copy if you have one. The page files were renamed and split into smaller files; nothing changes in how you use the page.

## 2026-11-17
Changed: moved into zz-base-home. Files now follow the repo naming rule, and the program keeps its data in ~\.zz-base-home-auto (separate from the original auto-task). The job file is so-auto-list.json, one name for every system.
Changed: removed the per-system launchers and the Node test scripts. Build and run with zig build.

## 0.2.0 (first release)
Added: live command runner, tabs, favorites, history, 20 trigger types for scheduled jobs.
