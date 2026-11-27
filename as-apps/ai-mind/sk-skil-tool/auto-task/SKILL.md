---
name: auto-task
description: Use the `tr` hub (ac-auto-task), the only scheduler on port 4000. Use to add, edit, list, run, pause or check scheduled/automatic jobs, triggers or chains, or to see job output.
---
# tr â€” auto-task hub (HTTP, port from `aa-conf-main.json`)
1. NEVER run `auto-task` or `auto-task.exe` to "check" it: it ignores `--help` and starts a second server. Live check: `curl -s http://127.0.0.1:4000/ping`.
2. NEVER kill by exe name. Find the PID: `netstat -ano | findstr :4000`, kill only that PID.
3. Jobs live ONLY in `E:\zz-base-home\ac-auto-task\aa-auto-task-<dev>.json` (this PC: `wi01`, Linux: `li01`). Edit with the Write/Edit tool, never a heredoc. After edits: `curl -s -X POST http://127.0.0.1:4000/reload`.
4. Read: `GET /tasks` Â· `/jobs` Â· `/config` Â· `/output` Â· `/task/log`.
5. Act: `POST /run` Â· `/kill` Â· `/pause` Â· `/resume` Â· `/stdin` Â· `/task/fire` Â· `/task/abort` Â· `/task/toggle` Â· `/step/run`.
6. Tests: spare port + scratch `HOME`/`USERPROFILE`, never the live data dir.
7. New auto-run task â†’ add to the job file. Never build another scheduler.
Trigger types (4-char `type`): boot chai cron disk even flag hand idle link live loop mail once powe proc puls queu sola tcpr webs.
Rename a job id: use `ie`.
Details: `E:\zz-base-home\ac-auto-task\CLAUDE.md`.
