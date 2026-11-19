# How to use
Linux first, then Windows (shutdown, then auto-open apps).

## Linux: open your apps
`bash ~/zz-base-home/as-apps/os-syst/ss-star-shut/ru-star-linu.sh`
Add `--dry-run` to preview only.

## Linux: close everything and power off
`bash ~/zz-base-home/as-apps/os-syst/ss-star-shut/ru-shut-linu.sh`
Save your work first. Press any key in a countdown to cancel. Add `--dry-run` to preview. Add `--auto` to skip countdowns. Add `--verbose` to see every window and app line.

## Linux: open apps at every login
`bash ~/zz-base-home/as-apps/os-syst/ss-star-shut/ct-auto-inst.sh`
Switch off: same command with `--remove`.

## Linux: check things
Add `status` to any of the three commands.

## Linux: night auto power-off
One hub job (`linu-shut-nigh`) runs every 15 minutes from 23:00 to 02:45 only: the first run of the 23:00 hour arms it (even if the hub ran it late), the later runs check. When no hub job is running, the PC closes everything and powers off (9s cancel key). At 02:00 it powers off even if a job is still running. If the hub is down, nothing happens.
- Status: `bash ~/zz-base-home/as-apps/os-syst/ss-star-shut/ru-shut-guar.sh status`
- Delayed power-off (desktop buttons Shut_Down / Shut_01hr / Shut_02h): `bash ~/zz-base-home/as-apps/os-syst/ss-star-shut/ru-shut-guar.sh later 60` (minutes; waits until no hub job runs)
- Cancel tonight: same command with `disarm`

## Linux: when something goes wrong
| You see (real message) | Do this |
|---|---|
| `wmctrl missing: sudo apt install wmctrl` | run that command |
| `config FILE line N: unknown key X` | fix line N in that file |
| `wmctrl cannot reach the X display` / `Wayland session` | log in to a Cinnamon X11 session and run from the desktop |
| `power-off command not found` | fix `POWE_CMDZ` |
| `WARN still open: 0x...` | that app wants you to save; save, or cancel the power-off |
| `WARN Chrome profile missing: Profile 9` | fix `CHRO_PROF` |
| `No terminal for the cancel key. Use --auto` | run from a terminal, or add `--auto` |
| `WARN save skipped` | the save-work tool is missing (`mise` or `wo`); build `wo` or fix `SYNC_CMDZ` |

## Windows: shutdown with no prompts (for scheduler jobs)
`E:\zz-base-home\as-apps\os-syst\ss-star-shut\ru-shut-wind.bat -Auto`
No admin prompt, no countdowns: it saves your work (`wo wipz`), closes apps and powers off at once. Use it only in a tr job you trust. The normal run (no `-Auto`) also saves your work first, then closes apps.

## Windows shutdown: set up
### Set Up — Close All Apps, Then Shut Down

One small tool. It closes your open apps the safe way, then shuts down your PC.

It gives you two chances to stop it. You stay in control the whole time.

This guide is **Part 1 — set it up**. You barely edit anything. There are two small settings, and the defaults are safe.

When you are done, read **Part 2 — how to use it** to run it.

**Require:** Windows. That is all.

---

### SAVE YOUR WORK FIRST

This tool closes apps. Any file you did not save can be lost.

Save everything before you run it. Every time. The tool is careful, but it cannot save your files for you.

---

### What it does

When the tool runs, it does these steps in order:

1. Asks for admin rights. You click **Yes**.
2. Shows a 9-second countdown. You can press any key to cancel.
3. Closes your apps. It asks each app to close nicely first.
4. Fixes Chrome and VSCode, so they do not show a "did not close right" warning next time.
5. Shows a second 9-second countdown. You can cancel again.

The countdown is 9 seconds by default. You can change it. See Step 3.
6. Shuts down your PC.

Two countdowns. Two chances to stop. Nothing happens fast.

---

### What is in the zip

You get two files. Keep them together in one folder.

| File | What it does |
|---|---|
| `ru-shut-wind.bat` | The starter. You double-click this one. |
| `ru-shut-wind.ps1` | The tool. It does the work. You do not open it by hand. |

You always run the `.bat` file. It starts the `.ps1` file for you.

---

### Step 1 — Get the files

Save both files in one folder. Keep them together.

A good spot is your Documents folder. Remember where you put them.

Do not split them. The `.bat` needs the `.ps1` right next to it.

---

### Step 2 — Test it once (optional but smart)

Before you trust it, watch it run one time.

1. Save and close all your real work first.
2. Double-click `ru-shut-wind.bat`.
3. A blue box asks for admin rights. Click **Yes**.
4. The first countdown starts. Press any key to cancel.

You just saw the start. It cancelled safely. Now you know what to expect.

---

### Step 3 — Settings you can change

The tool has two settings near the top. The defaults are safe. Most people never touch them.

To edit either one:

1. Right-click `ru-shut-wind.ps1`.
2. Pick **Open with**, then **Notepad**. Do not double-click it.
3. Find the lines below. Change them. Then press **Ctrl + S** to save.

#### Setting 1 — Countdown time

This is how long each cancel countdown lasts. Default is 9 seconds.

```
COUN_SECO = 9
```

It sits on the line that starts with `$CF = @{`.

Want more time to cancel? Use a bigger number, like `15`. Want it faster? Use a smaller one, like `5`.

#### Setting 2 — Hide the VSCode restore prompt

This moves VSCode's unsaved backup aside, so VSCode does not ask to restore files next time. Nothing is deleted: the folder is renamed `Backups_<date>`.

```
VSCO_BKUP_WIPE = $false
```

Leave this **off** (`$false`) unless you are sure. If you turn it on (`$true`), VSCode will no longer offer your unsaved edits at the next start.

Not sure? Leave it as `$false`. Your unsaved work stays safe.

That is all you can edit. Nothing else.

---

### Done. What next?

Your tool is ready. Now pick how to run it.

Read **Part 2 — how to use it**. It shows easy ways. By double-click. From the desktop. From the taskbar. At a set time.

---

### Windows shutdown: use it
### How To Use It — Close All Apps, Then Shut Down

This guide is **Part 2 — how to use it**. It shows the ways to run the tool.

First read **Part 1 — set it up**. Done that? Good. Now pick a way to run it.

**Always save your work before you run this.** The tool closes apps. Unsaved files can be lost.

You run the `.bat` file, never the `.ps1` file. Pick the way that fits you.

| Way | Best for | Effort |
|---|---|---|
| A. Double-click | A quick shutdown, now and then | Easiest |
| B. Desktop icon | One click on demand, any time | Easy |
| C. Taskbar icon | One click from the bottom bar | Easy |
| D. At a set time | Shut down on a clock, like every night | Advanced |
| E. One key press | Double-tap a key to shut down (needs AutoHotkey) | Advanced |

There is no "on startup" way here. You do not want a shutdown tool to run when you log in.

---

### A — Double-click to run

The simplest way. Use it any time you want to shut down.

1. Save and close all your work first.
2. Find `ru-shut-wind.bat`.
3. Double-click it.
4. The admin box asks to allow it. Click **Yes**.

The first countdown starts. To stop, press any key. To go on, wait.

That is all.

---

### B — Make a desktop icon

Want to shut down any time with one click? Put an icon on your desktop.

1. Right-click `ru-shut-wind.bat`.
2. Pick **Send to**.
3. Pick **Desktop (create shortcut)**.

Now an icon sits on your desktop. Double-click it any time. The tool starts.

Want a nicer icon? Right-click it. Pick **Properties**. Click **Change Icon**. Pick one you like.

---

### C — Pin it to the taskbar

Want it on the bar at the bottom of your screen? You need a small trick first. A `.bat` file cannot pin straight to the taskbar. So you wrap it in a shortcut.

1. Make a desktop icon first. Follow Way B above.
2. Right-click that desktop icon. Pick **Properties**.
3. Find the **Target** box. It shows the file path.
4. Click in the box. Go to the very start of the text.
5. Type this, with a space after it: `cmd /c `
6. The target now starts with `cmd /c` and then your file path.
7. Click **OK**.
8. Right-click the icon again. Pick **Pin to taskbar**.

Done. The icon sits on your taskbar. Click it any time. The admin box appears, then the tool starts.

Why the trick? The taskbar only pins programs. `cmd` is a program. It runs your `.bat` file for you.

---

### D — Run at a set time (advanced)

Want it to shut down on a clock? Like every night at 11 PM? Use Task Scheduler. This is built into Windows.

Be careful with this one. Make sure you never have unsaved work at that time.

1. Press **Windows key**. Type `Task Scheduler`. Open it.
2. On the right, click **Create Basic Task**.
3. Give it a name. Like `Night Shutdown`. Click **Next**.
4. Pick when to run. Like **Daily**. Click **Next**.
5. Set the time. Like `23:00` for 11 PM. Click **Next**.
6. Pick **Start a program**. Click **Next**.
7. In **Program/script**, click **Browse**. Find your `ru-shut-wind.bat`. Pick it.
8. Click **Next**. Then click **Finish**.

For the admin rights to work on a schedule, do one more thing:

1. Find your task in the list. Double-click it.
2. Check the box **Run with highest privileges**.
3. Click **OK**.

Done. Windows runs it on your schedule. The countdowns still show, so you can still cancel.

**To change or stop it:** open Task Scheduler. Find your task. Right-click it. Pick **Disable** or **Delete**.

---

### E — One key press to shut down (bonus)

Already use AutoHotkey? You can make one key press start this tool. No mouse. No clicks.

This works with our free key remap tool: `keys-short-script-autohotkey.ahk`. It is built for exactly this. By default, **double-tap the End key** and the shutdown starts.

To set it up:

1. Open `keys-short-script-autohotkey.ahk` in Notepad.
2. Find the line that runs the shutdown script. It looks like this:

```
Run, C:\Windows\System32\cmd.exe /c "PowerShell -ExecutionPolicy Bypass -File ...\ru-shut-wind.ps1"
```

3. Change the path so it points to your `ru-shut-wind.ps1`. Use the full path.
4. Save the file. Run the `.ahk` again to reload it.

Done. Now double-tap **End**. The shutdown tool starts, countdowns and all.

Want a different key? You can map any unused key to the same line. The End key is just the default.

---

### A useful tool to pair with this

If you liked Way E, get the full tool: **`keys-short-script-autohotkey.ahk`**.

It puts your dead keys to work. F-keys become Find, Save, Copy, Paste, and more. One tap each. The double-tap End shutdown is just one of its tricks.

It pairs perfectly with this shutdown tool. One key ends your day the safe way.

Find it on zzOwn.com, free to copy.

---

### Common questions

**I double-clicked the `.ps1` file and it just opened in Notepad.**
That is normal. Windows opens `.ps1` files in an editor, it does not run them. Run the `.bat` file instead. The `.bat` is the one that starts the tool.

**A black window flashed and closed before any countdown.**
The two files are not together. The `.bat` needs `ru-shut-wind.ps1` in the same folder. Put both files back in one folder. See Part 1, Step 1.

**I clicked No on the admin box.**
The tool needs admin rights to shut down. Run it again and click **Yes**.

**An app did not close.**
The tool gives each app a few seconds to close nicely. If an app ignores that, the tool closes it anyway. This is why you save your work first.

**It asks for admin rights every time.**
That is normal. The tool needs admin rights to shut down, so it asks each run. It is one extra click.

**I want to stop the timed shutdown.**
Did you use Way D? Open Task Scheduler and delete the task.

---

### The one rule

Save your work before you run this. The tool is careful, but it cannot save your files for you. That part is yours.

### Windows auto-open apps: set up
### Set Up — Auto-Open Your Whole Work Setup

One small file. It opens your whole work setup at once.

WiFi, folders, Chrome profiles, VSCode, and your own scripts. You press nothing.

This guide is **Part 1 — set it up**. You edit the file once. You tell it what to open.

When you are done, read **Part 2 — how to use it** to run it.

**Require:** Windows. Chrome and VSCode are optional. That is all.

---

### What it does

When the file runs, it does these steps in order:

1. Connects your WiFi.
2. Opens the folders you pick.
3. Opens your Chrome profiles.
4. Opens VSCode.
5. Runs any extra scripts you want.

Skip any step you do not need. Leave its value empty. Nothing breaks.

---

### Step 1 — Get the file

Save `ru-star-wind.vbs` anywhere you like.

A good spot is your Documents folder. Remember where you put it. You will need the path later.

### Step 2 — Open the file to edit it

1. Right-click the file.
2. Pick **Open with**.
3. Pick **Notepad**.

Do not double-click it yet. Double-click runs it. You want to edit it first.

You will see the settings in the first lines, right after the header. You only change those lines. Nothing else.

### Step 3 — Set your WiFi

Find this line:

```vbs
Const WIFI_NAME = ""
```

Type your WiFi name between the quotes. Example:

```vbs
Const WIFI_NAME = "My Home WiFi"
```

No WiFi step? Leave it empty. The script skips it.

### Step 4 — Set your folders

Find this block:

```vbs
FOLD_LIST = Array("C:\Users\Public\Documents")
```

Put the folders you want to open inside the brackets. Quote each one and separate them with commas.

Two folders look like this:

```vbs
FOLD_LIST = Array("C:\Users\You\Projects", "C:\Users\You\Downloads")
```

No folders? Make the list empty:

```vbs
FOLD_LIST = Array()
```

### Step 5 — Find your Chrome profile names

Use many Chrome accounts? Each one is a "profile". You need its real name.

1. Open Chrome.
2. In the address bar, type `chrome://version` and press Enter.
3. Look for the line **Profile Path**.
4. The last part is the name. Like `Default`, or `Profile 1`, or `Profile 2`.

Do this for each account you use. Write the names down.

### Step 6 — Set your Chrome profiles

Find this block:

```vbs
PROF_LIST = Array("Default")
```

Put your profile names here. Quote each one and separate them with commas.

```vbs
PROF_LIST = Array("Default", "Profile 1", "Profile 2")
```

No Chrome step? Make the list empty:

```vbs
PROF_LIST = Array()
```

You do not need the Chrome path. The script finds Chrome on its own.

### Step 7 — Set VSCode

Find this line:

```vbs
Const CODE_OPEN = True
```

Want VSCode to open? Leave it `True`.
Do not want it? Change it to `False`.

VSCode opens your first folder from Step 4. The script finds VSCode on its own.

### Step 8 — Add extra scripts (optional)

Have your own script to run? Add it here.

Find this block:

```vbs
EXTR_LIST = Array()
```

Put the full path to each script. It works with `.vbs`, `.ahk`, `.ps1`, and `.bat` files.

```vbs
EXTR_LIST = Array("C:\Users\You\my-hotkeys.ahk", "C:\Users\You\start-server.bat")
```

These run as admin. Windows may ask for permission. Click **Yes**.

No extra scripts? Leave the list empty.

### Step 9 — Set the wait time

Find this line:

```vbs
Const WAIT_SECO = 3
```

This is the pause between each app, in seconds.

Slow PC? Use a bigger number, like `5` or `6`. This gives each app time to open.

### Step 10 — Save your edits

1. Press **Ctrl + S** to save.
2. Close Notepad.

### Step 11 — Test it once

Double-click the file. Watch it run.

- Your apps should open one by one.
- See a warning box? Read it. It tells you what was not found.
- Wrong WiFi name or wrong profile name? Go back and fix that line.

Test until every step works the way you want.

---

### Done. What next?

Your file is ready. Now pick how to run it.

Read **Part 2 — how to use it**. It shows five easy ways. By double-click. On startup. From the desktop. From the taskbar. At a set time.

---
### Windows auto-open apps: use it
### How To Use It — Auto-Open Your Whole Work Setup

This guide is **Part 2 — how to use it**. It shows the ways to run your file.

First set up the file. Read **Part 1 — set it up**. Done that? Good. Now pick a way to run it.

You can use one way or many. Start with the one that fits you.

| Way | Best for | Effort |
|---|---|---|
| A. Double-click | A quick test, or run now and then | Easiest |
| B. On startup | Open everything every time you log in | Easy |
| C. Desktop icon | One click on demand, any time | Easy |
| D. Taskbar icon | One click from the bottom bar | Easy |
| E. At a set time | Run on a clock, or only some days | Advanced |

---

### A — Double-click to run

The simplest way. Use it to test, or any time you want.

1. Find the file.
2. Double-click it.

Your setup opens. That is all.

---

### B — Run on startup

Make Windows run it every time you log in. Best for a daily setup.

1. Press **Windows key + R**. A small box opens.
2. Type `shell:startup` and press Enter. A folder opens.
3. Right-click the script file. Pick **Copy**.
4. Go back to the Startup folder. Right-click. Pick **Paste shortcut**.

Use **Paste shortcut**, not **Paste**. This keeps the real file where it is.

Done. Next time you turn on your PC, your whole setup opens by itself.

**To turn it off:** open `shell:startup` again. Delete the shortcut. The real file stays safe.

---

### C — Make a desktop icon

Want to open your setup any time with one click? Put an icon on your desktop.

1. Right-click the script file.
2. Pick **Send to**.
3. Pick **Desktop (create shortcut)**.

Now an icon sits on your desktop. Double-click it any time. Your setup opens.

Want a nicer icon? Right-click it. Pick **Properties**. Click **Change Icon**. Pick one you like.

---

### D — Pin it to the taskbar

Want it on the bar at the bottom of your screen? You need a small trick first. A `.vbs` file cannot pin straight to the taskbar. So you wrap it in a shortcut.

1. Make a desktop icon first. Follow Way C above.
2. Right-click that desktop icon. Pick **Properties**.
3. Find the **Target** box. It shows the file path.
4. Click in the box. Go to the very start of the text.
5. Type this, with a space after it: `wscript.exe `
6. The target now starts with `wscript.exe` and then your file path.
7. Click **OK**.
8. Now right-click the icon again. Pick **Pin to taskbar**.

Done. The icon sits on your taskbar. Click it any time. Your setup opens.

Why the trick? The taskbar only pins programs. `wscript.exe` is a program. It runs your file for you.

---

### E — Run at a set time (advanced)

Want it to run on a clock? Like every day at 8 AM? Or only on work days? Use Task Scheduler. This is built into Windows.

1. Press **Windows key**. Type `Task Scheduler`. Open it.
2. On the right, click **Create Basic Task**.
3. Give it a name. Like `Open My Work Setup`. Click **Next**.
4. Pick when to run. Like **Daily** or **When I log on**. Click **Next**.
5. Set the time if it asks. Click **Next**.
6. Pick **Start a program**. Click **Next**.
7. In **Program/script**, type: `wscript.exe`
8. In **Add arguments**, type the full path in quotes. Like `"C:\Users\You\ru-star-wind.vbs"`
9. Click **Next**. Then click **Finish**.

Done. Windows runs it on your schedule.

**To change or stop it:** open Task Scheduler. Find your task in the list. Right-click it. Pick **Disable** or **Delete**.

---

### Common questions

**A step opened the wrong thing or nothing.**
Open the file again. Check that line in the settings lines. Fix the name or path. See Part 1.

**Chrome did not open.**
Check your profile names. They must match `chrome://version` exactly. See Part 1, Step 5.

**VSCode did not open.**
The script looks in the usual spots. Yours may be elsewhere. The script skips it and keeps going.

**A warning box popped up.**
That is normal. It means one item was not found. The script skips it and keeps going.

**It runs too fast and some apps fail.**
Raise the wait time. See Part 1, Step 9. Try `5` or `6`.

**I want to stop the auto-start.**
Did you use Way B? Open `shell:startup` and delete the shortcut. Did you use Way E? Open Task Scheduler and delete the task.

---