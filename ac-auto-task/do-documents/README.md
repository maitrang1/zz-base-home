# auto-task
Run commands from your browser, see the output live, and schedule jobs to run on their own.
One file. Nothing to install. No account, no cloud. Everything stays on your machine.

## What it does
Type a command, press Run, and watch the output appear line by line. Keep servers running, stop them with one click, and work in several tabs, each with its own folder. Schedule jobs to run at startup, every night, when a file changes, when a drive fills up, and more. Your tabs, output and settings are still there after you close the page or restart the PC.

## Requirements
A browser, and Zig 0.17.0 to build it. No runtime, no setup.

## Quick start
1. Build once:
cd /d E:\zz-base-home\ac-auto-task
zig build
2. Start it:
E:\zz-base-home\ac-auto-task\zig-out\bin\auto-task.exe
You see:
auto-task listening http://127.0.0.1:4000
ui <folder> · <os>
3. Open this in your browser:
http://127.0.0.1:4000
Another port: add it after the file name, for example `E:\zz-base-home\ac-auto-task\zig-out\bin\auto-task.exe 8080`.

## Key behavior
- It listens on your own machine only. Nothing leaves it.
- Closing the page does not stop a running command. Stopping a command also stops everything it started.
- Scheduled jobs are listed in `aa-auto-task-wi01.json`. A job with a mistake is skipped and shown with the reason.

## License
PolyForm Noncommercial 1.0.0: free for personal use, a paid license for commercial use. Full text: LICENSE.

## Next
- HOW-TO.md: how to use each feature
- CONFIG.md: ports, files, jobs, formats
- UPDATE.md: what changed
- LICENSE: license text
