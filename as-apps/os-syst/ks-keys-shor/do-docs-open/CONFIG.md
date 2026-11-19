# Config

## Program
- `ru-keys-shor.ahk`: the app. One line per key. AutoHotkey v1.1, Windows only.
- `ut-keys-func.ahk`: the shared helpers and the settings line.
- `ut-keys-func-test.ahk`: checks for the helpers. Safe to run: it sends no keys.
- Shutdown target (End x2): `ss-star-shut\ru-shut-wind.bat`, found next to this folder.

## Settings
To change a key, edit its line in `ru-keys-shor.ahk` with Notepad. Other settings sit in the first line after the header of `ut-keys-func.ahk` (`CF`).

| Setting | Where | Default | Meaning |
|---|---|---|---|
| taps | `CF` in `ut-keys-func.ahk` | 300 | milliseconds allowed between two taps of a double-tap key |
| hdbl | `CF` in `ut-keys-func.ahk` | 0.2 | seconds Home waits for its second press |
| shut | `CF` in `ut-keys-func.ahk` | `ss-star-shut\ru-shut-wind.bat` next to this folder | what End x2 runs |
| Start at login | `EXTR_LIST` in `ss-star-shut\ru-star-wind.vbs` | on | the login script starts `ru-keys-shor.ahk` as admin |

## Input
Key presses.

## Output
- Shortcuts sent to the active window.
- End x2: the shutdown countdown window.
- Files written: none.
