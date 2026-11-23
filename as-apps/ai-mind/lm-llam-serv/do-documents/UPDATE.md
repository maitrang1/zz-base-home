# Updates

## 2026-11-19 · Moved here
- The local AI server watchdog and stopper now live in this repo as `lm-llam-serv`, next to the other apps.
- Changed: files have new short names (`ru-llam-watc.sh`, `ru-llam-stop.sh`, `cf-llam-load.sh`). One settings file, `aa-conf-main.env`, holds both servers: the `AISV_*` lines are the text server and the `VISI_*` lines are the photo server (start it with `ru-llam-watc.sh visi`).
- Changed: stop no longer force-kills. It asks the server to quit and warns if it stays up.
- Changed: stop checks that the lock really belongs to the watchdog before ending it.
- Changed: a wrong setting now names the file and the line.
- Changed: default ports are now 4004 (text) and 4008 (photos). Change them in `aa-conf-main.env` (`AISV_PORT`, `VISI_PORT`); anything that calls the server must use the new port.
- Tested: 48 of 48 checks on Debian with a fake server. A real model was not started.
