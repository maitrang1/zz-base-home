# How to use the bootstrap

## Set up a new device
1. Clone zz-base-home.
2. Run the script for your system (see README, Quick start).
3. Read the last line and do the manual step it names.

## Put the tools in another folder
Set `WO_MISE_DIR` to the folder before you run the script.

## Run the short CI check on your own
Set `CI=true` before you run the script. It then checks only the hooks and the Zig version.

## Problems
| Message | Fix |
|---|---|
| `bs: mise sha256 mismatch (...): refusing to run it` | The download is not the expected file. Check your network or proxy, then run again. |
| `bs: unsupported platform ...` | Use Windows, Linux (x86_64 or arm64) or macOS (Apple silicon). |
| `hooksPath=... want ci-flow-sync` | Run the script again; it sets the hooks folder. |
