# How to use

## Use the keys
| Key | Action | Key | Action |
|---|---|---|---|
| F1 | Find | F2 | Find & Replace |
| F3 | Save | F4 | Paste plain text |
| F5 | Cut | F6 | Select all |
| F7 | Copy | F8 | Paste |
| F9 | Undo | F10 | Redo |
| F11 | Close tab | F12 | New tab (x2 = reopen closed tab) |
| Insert | Hard refresh | PrintScreen | Address bar |
| Scroll Lock | Previous tab | Pause | Next tab |
| Page Up | Next app | Page Down | Previous app |
| Home | Back (x2 = DevTools) | End | Forward (x2 = shut down) |
| Esc x2 | Close window | Menu | Show this list |
| Backtick + 1 to 6 | Heading 1 to 6 | CapsLock x2 | Types `a` (Shift: `A`) |

## Start at every login
The login script `ru-star-wind.vbs` already starts it. It asks for admin once per login (click **Yes**), so the keys also work in admin windows.
Make sure your Startup shortcut points to:
```
E:\zz-base-home\as-apps\os-syst\ss-star-shut\ru-star-wind.vbs
```

## Start at login with no prompt
1. Press `Win + R`. Type `taskschd.msc`. Press Enter.
2. Click **Create Task** (not "Basic Task").
3. **General**: name it `OneTapKeys`. Tick **Run with highest privileges**.
4. **Triggers**: **New**, "Begin the task" = **At log on**.
5. **Actions**: **New**, Program = `C:\Program Files\AutoHotkey\AutoHotkey.exe`.
6. Add arguments:
```
"E:\zz-base-home\as-apps\os-syst\ks-keys-shor\ru-keys-shor.ahk"
```
7. Click OK. Then remove `ru-keys-shor.ahk` from `EXTR_LIST` in `ru-star-wind.vbs`, or it starts twice.

## Shut down with End x2
Double-tap **End**. A countdown starts (`ru-shut-wind.bat`). Press any key to cancel. Save your work first.
Do not want it? Open `ru-keys-shor.ahk` in Notepad. Find `$End::`. Delete the block. Save. Restart the script.

## Turn it off
Right-click the green **H** icon near your clock. Click **Exit**.

## When something goes wrong
| You see | Do this |
|---|---|
| Keys do nothing in one app | That app runs as admin. Start the script as admin (login script does it). |
| "This script requires v1" or a syntax error window | You installed AutoHotkey v2. Install v1.1. |
| End x2 shows a cmd error | `ss-star-shut\ru-shut-wind.bat` is missing. Keep both folders side by side. |
