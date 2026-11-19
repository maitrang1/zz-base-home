; ===================================================================
; Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
; Des: One-tap shortcuts on unused keys (Windows)
; Flo: load helpers > register hotkeys > idle in tray > send combo on key
; I/O: key presses > shortcuts sent to the active window, End x2 starts shutdown
; Run: "C:\Program Files\AutoHotkey\AutoHotkey.exe" "E:\zz-base-home\as-apps\os-syst\ks-keys-shor\ru-keys-shor.ahk"
; ===================================================================
#Include %A_ScriptDir%\ut-keys-func.ahk
~Esc::Once("~Esc", "!{F4}")
F1::Tap("^f", "F1")
F2::Tap("^h", "F2")
F3::Tap("^s", "F3")
F4::Tap("^+v", "F4")
F5::Tap("^x", "F5")
F6::Tap("^a", "F6")
F7::Tap("^c", "F7")
F8::Tap("^v", "F8")
F9::Tap("^z", "F9")
F10::Tap("^y", "F10")
F11::Tap("^w", "F11")
F12::Tap2("^t", "^+t", "F12", "F12")
PrintScreen::Tap("^l", "PrintScreen")
SC046::Tap("^+{Tab}", "SC046")
Break::Tap("^{Tab}", "Break")
PgUp::Tap("!{Tab}", "PgUp")
PgDn::Tap("!+{Tab}", "PgDn")
Insert::Tap("^{F5}", "Insert")
$Home::HomeKey()
$End::EndKey()
SC029 & 1::Out("^!1")
SC029 & 2::Out("^!2")
SC029 & 3::Out("^!3")
SC029 & 4::Out("^!4")
SC029 & 5::Out("^!5")
SC029 & 6::Out("^!6")
SC029::Out("{``}")
AppsKey::Guid()
~CapsLock::Once("~CapsLock", "a")
~+CapsLock::Once("~+CapsLock", "A")
; =======================___THIS_IS_THE_END___=======================
; ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
