# Local AI Server

Keeps a local AI model running on your own PC, all session. No cloud, no account, no per-call cost.
Linux and macOS.

## What you get
1. A watchdog that starts `llama-server` (llama.cpp) and restarts it if it stops.
2. A text server on port 4004 and an optional photo-reading server on port 4008.
3. A healthy server is never touched. A port used by another program is never taken over.
4. One stop command. One settings file for both servers.

## Requirements
1. `llama-server` from llama.cpp, built or installed.
2. A model file (`.gguf`). For photos also a projector file.
3. Linux or macOS with `bash` and `ss`.

## Quick start
1. Open `aa-conf-main.env` in this folder. Set `AISV_BINA` and `AISV_MODL` to your files (the `VISI_` lines are for the photo server).
2. Start it:
```
bash ~/zz-base-home/as-apps/ai-mind/lm-llam-serv/ru-llam-watc.sh
```
3. Check it (after a few seconds):
```
curl http://127.0.0.1:4004/health
```
Your login script starts it for you if `AISV_WDOG` is set in `ss-star-shut/aa-conf-main.env`.

## Next
- [HOW-TO.md](HOW-TO.md): start, stop, photo server, errors
- [CONFIG.md](CONFIG.md): every setting
- [UPDATE.md](UPDATE.md): what changed
