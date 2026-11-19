# Config

## Program
- `ru-llam-watc.sh`: the watchdog. `ru-llam-stop.sh`: the stopper. `cf-llam-load.sh`: reads and checks the settings.
- Built with: Bash 5. Needs `ss` (and `lsof` if you have it). No build step.

## Settings
One file for both servers: `aa-conf-main.env`, next to the scripts. One `KEY=value` per line. `~` means your home folder. A shell variable of the same name wins. The file is git-ignored and private to the device. Another file: set `AISV_CONF` to its path.
Two roles: `main` is the text server (the `AISV_*` lines). `visi` is the photo-reading server: every `AISV_*` key has a `VISI_*` twin that replaces it for `visi`; a key you leave out is inherited.

| Key (and `VISI_` twin) | Default | Meaning |
|---|---|---|
| AISV_BINA | `llama-server` on your PATH | the server program |
| AISV_MODL | none (required) | model file (`.gguf`) |
| AISV_MMPJ | empty | projector file for a photo model; empty = text only |
| AISV_HOST | 127.0.0.1 | address to listen on (local only by default) |
| AISV_PORT | 3010 | port (1 to 65535). `visi` must set `VISI_PORT` (3011) |
| AISV_SLOT | 1 | requests served at the same time |
| AISV_CTXN | 4096 | context size in tokens |
| AISV_THRD | 4 | CPU threads |
| AISV_XTRA | empty | extra `llama-server` flags, as typed |
| AISV_EVRY | 15 | seconds between health checks |
| AISV_BOOT | 5 | seconds a fresh server gets to start listening |
| AISV_LOGF | /dev/null | file the server writes its log to |

Allowed: numbers are whole numbers with no leading zero. A wrong key or number, an unknown role, or `visi` without `VISI_PORT` stops the script and says why.

## Input
- Commands: `ru-llam-watc.sh [visi]` · `ru-llam-stop.sh [visi]` · `cf-llam-load.sh --check [visi]`.

## Output
- A running `llama-server` on the role's `HOST:PORT`.
- Files written: the log file of each role and a lock file `aisv-watchdog-<port>.lock` in your temp folder (removed when the watchdog ends).
- Exit codes: 0 ok · 1 refused or failed · 2 usage (`cf-llam-load.sh` only).
