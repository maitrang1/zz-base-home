# How to use

## Start the text server
```
bash ~/zz-base-home/as-apps/ai-mind/lm-llam-serv/ru-llam-watc.sh
```
It keeps running in the background and restarts the server if it dies. Run it twice and the second one exits: only one watchdog per port.

## Start the photo (vision) server
```
bash ~/zz-base-home/as-apps/ai-mind/lm-llam-serv/ru-llam-watc.sh visi
```
It uses the `VISI_*` lines of the same settings file: its own model, projector and port (4008).

## Stop a server
```
bash ~/zz-base-home/as-apps/ai-mind/lm-llam-serv/ru-llam-stop.sh
```
Add `visi` at the end to stop the photo server. It stops the watchdog first, then asks the server to quit. It never force-kills.

## Check your settings
```
bash ~/zz-base-home/as-apps/ai-mind/lm-llam-serv/cf-llam-load.sh --check
```
Add `visi` to see what the photo server will use.

## Start at every login
Set `AISV_WDOG` (and `AISV_VENV=visi` for the photo server) in `ss-star-shut/aa-conf-main.env`. The login script starts both.

## When something goes wrong
| You see | Do this |
|---|---|
| `ai server: missing /path/model.gguf` | fix `AISV_MODL` (or `AISV_BINA`, `AISV_MMPJ`, or the `VISI_` twin) in `aa-conf-main.env` |
| `ai server: AISV_MODL is not set` | set `AISV_MODL` (photo server: `VISI_MODL`) |
| `config aa-conf-main.env line N: unknown key X` | fix line N |
| `config: role visi needs VISI_PORT` | add `VISI_PORT=4008` |
| `config: unknown role 'x' (use main or visi)` | use `visi`, or no argument |
| `config: AISV_PORT must be 1..65535` | use a whole number in range |
| `ai server: binary or model is gone - watchdog stopping` | the file was moved; restore it and start again |
| `port 4004 is used by 'xyz' (pid N) - left running` | another program owns the port; close it or change `AISV_PORT` |
| `WARN llama-server N still up after TERM` | wait a moment and run stop again |
