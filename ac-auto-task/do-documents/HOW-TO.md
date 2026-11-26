# How to use auto-task
Assumes it is already running. If not, see README.md.

## Run a command
1. Type the command in the box.
2. Press Enter, or click Run.
3. Output appears line by line. When it finishes you see the exit code, the time, and the line count. Green 0 = worked. Red = failed.

## Run a server and stop it
1. Type the command, for example: python -m http.server 8000
2. Press Run. Every request shows up live.
3. Click abort to stop it. Abort also closes anything the server started, so the port is free again.

## Keep a server running and use the tab again
Click detach. The tab unlocks, the command keeps streaming with its own abort button. Reload or close the page: running commands keep going and come back with everything they printed. Only abort stops them.

## Change the folder
Type `cd "C:\path\to\folder"`. The tab remembers it. Each tab keeps its own folder. `cd` alone shows the current one. If that folder is deleted or moved, the next command says so and runs in the default folder.

## Answer a command that asks a question
Every running command has its own input box under its output. It shows after half a second. Type your answer, press Enter. Up and Down bring back earlier answers from that command. An empty Enter sends a blank line, for "press Enter to continue".
A command that stops at a question without a new line shows a pulsing dot on its block and on its tab, and the box is labeled input, so you can see which one is waiting. Many commands can run at once, in any tab: each reply goes only to its own command.
To answer ahead of time, click answers, type one line per question, then run the command. The lines belong to that run only. They are sent one at a time: the next line goes out only after the command printed a new question. The box is cleared when the run starts.

## Links in the output
Any http(s):// or www. address in the output is a link. Click it to open it in a new tab. A small copy icon sits right before every link: click it to copy the link (it shows a check for a moment). You can also right-click the link, or select it as plain text and copy it. Trailing dots, commas and closing brackets are left out of the link. Other kinds of links (file:, javascript:, ftp:) stay plain text. While a search is active the links are plain text again.

## Run one step of a chain by hand
Each step of a chain logs in its own row (in the chain's tab). Click the play button on that row to run only that step again. It does not touch the chain or its schedule, it uses the same lock and worker limit as the chain, and its output shows up as a new row in the same tab. If the step's lock is busy it waits its turn and the row says so. Stop and pause work on the new row like on any running block. You cannot run a step while its chain is running (abort the chain first), and a step that is already running or queued is refused.

## Pause and resume a command or chain
Click stop on a running block to freeze the command and every program it started. The block shows a pause mark and the button turns into play. Click play and it goes on where it stopped. A chain has a pause icon on its row in the schedule list: the running step freezes and the next step does not start until you resume. Stop (abort) still works while paused.
Good to know: the command's own time limit does not count the paused time. A paused command still holds its memory. Things that depend on a clock outside this PC (a login, a download, a server connection) can time out while it is frozen. On Linux the whole tree is frozen. On macOS only the command's process group is. Scheduled jobs that are not part of a chain have no pause button.

## Use tabs
Click + to add. Double-click a name to rename. Drag to reorder. Click the pin to protect a tab from closing.

## Save favorites and search
- Star a command to save it under favorites. + group makes groups.
- Every command you run is in history. Ctrl+K searches history and favorites together.
- search (above the output) finds text in the output, with arrows to jump.

## Pick a shell, set variables, watch a file
- Pick a shell next to the command box (auto, cmd, PowerShell, pwsh, bash). Auto = your system default.
- ENV: names and values that apply to every command in that tab only.
- watch: pick a file or folder, click start. The command re-runs each time it changes. Click stop to end.

## Use the output buttons
wrap (wrap long lines) · ansi (colors) · ts (time per line) · A- / A+ (text size) · scroll (stop auto-scroll) · export (download the session as text) · sessions (save and reload a set of tabs).

## Schedule a job
- SCHEDULE in the sidebar lists the jobs. The counter, like 75/77 armed, = jobs on / total.
- Each row has a check box (on/off), a play button (run now) and a log button (last output). A failed job shows its last result in red.
- Add one: SCHEDULE → + task → pick the type (boot, cron, ...) → fill the field (the hint shows the format) → type the full command path → Save. It shows up at once.
- A favorite can be scheduled with the clock icon next to it.
- try = run again this many times after a failure. out = stop it after this many seconds. Both apply to scheduled runs only.
- You can also edit aa-auto-task-wi01.json by hand. The change is picked up in about 2 seconds.

## Stop auto-task
Press Ctrl+C in its console. Any command still running stops with it.

## Use it from another device
auto-task only listens on its own machine, by design. Use an SSH tunnel: ssh -L 4000:127.0.0.1:4000 you@the-machine, then open http://127.0.0.1:4000 on the device you are using.

## New programs and PATH changes
Commands run with the environment as it is now, not as it was when auto-task started. On Windows, after you install a program or change PATH or a variable, the next command already sees it: no restart, no new window. Open `http://127.0.0.1:4000/env` to see which variable names differ from the start-up environment (names only, no values). On Linux and macOS the start-up environment is fixed. To read your profile files, set `"envi_mode": "login"` in aa-conf-main.json, or restart auto-task from a fresh terminal. A new group (docker, dialout) still needs a log out and in.

## When something goes wrong
| You see | Do this |
|---|---|
| The top-right pill is red | The program is not running. Start it again. |
| A closed tab's output came back | Reload the page once. |
| A scheduled job never runs | Open SCHEDULE. Check it is on. A bad schedule is listed with the reason. |
| A command works in a new window but not here, or just installed, not found | Open `/env`. The name you need should be listed. If not, restart auto-task. |
| `AccessDenied` when rebuilding | Stop the program first, then build again. |
| A job's log ends with TIMEOUT | It ran past its time limit (1 hour if none is set). Raise out. |
| `error: port 4000 is already in use.` | Another program has the port. Close it, or start with the port it suggests: `E:\zz-base-home\ac-auto-task\zig-out\bin\auto-task.exe 4001`. |

## Open the mini window (optional)
- Web is the main version: open the page in a browser. The mini window is the same page in a small always-on-top window.
- One time: `cd ui-elec-mini` then `npm install` (about 150 MB). Needs Node.js.
- Start it: the corner button on the page, or `npm start` in `ui-elec-mini`.
- Without `npm install`, the corner button shows "mini panel not installed". Nothing else is affected.
