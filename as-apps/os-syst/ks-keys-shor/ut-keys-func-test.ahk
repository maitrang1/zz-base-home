; ===================================================================
; Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
; Des: Tests for ut-keys-func.ahk with a logged Send
; Flo: test mode > call helpers > compare the log > print PASS/FAIL
; I/O: none > PASS/FAIL lines on stdout, exit code = failed count
; Run: "C:\Program Files\AutoHotkey\AutoHotkey.exe" "E:\zz-base-home\as-apps\os-syst\ks-keys-shor\ut-keys-func-test.ahk" | more
; ===================================================================
#Include %A_ScriptDir%\ut-keys-func.ahk
Test := true
Pass := 0
Fail := 0
Chk(name, got, want)
{
global Pass, Fail
if (got == want)
{
Pass++
FileAppend, PASS  %name%`n, *
}
else
{
Fail++
FileAppend, FAIL  %name%  got=%got%  want=%want%`n, *
}
}
Reset()
{
global Logz
Logz := ""
}
Reset()
Out("^f")
Chk("Out logs the combo in test mode", Logz, "^f|")
Reset()
Tap("^s", "F3")
Chk("Tap sends the combo and returns", Logz, "^s|")
Chk("DblOk same key inside the window", DblOk("F12", 299, "F12", 300), true)
Chk("DblOk at the window edge is a miss", DblOk("F12", 300, "F12", 300), false)
Chk("DblOk other key is a miss", DblOk("F11", 10, "F12", 300), false)
Chk("DblOk slow second tap is a miss", DblOk("F12", 900, "F12", 300), false)
Chk("DblOk empty prior is a miss", DblOk("", 0, "", 300), false)
Reset()
Once("~Esc", "!{F4}")
Chk("Once sends nothing without a prior tap", Logz, "")
Reset()
Tap2("^t", "^+t", "F12", "F12")
Chk("Tap2 single tap sends the first combo", Logz, "^t|")
Reset()
HomeKey()
Chk("HomeKey single tap goes back", Logz, "!{Left}|")
Reset()
EndKey()
Chk("EndKey single tap goes forward", Logz, "!{Right}|")
Reset()
Shut()
Chk("Shut logs RUN, starts nothing in test mode", Logz, "RUN|")
Chk("Shut target is the ss-star-shut batch file", InStr(CF.shut, "ss-star-shut\ru-shut-wind.bat") > 0, true)
sumz := "`n" Pass " passed, " Fail " failed`n"
FileAppend, %sumz%, *
ExitApp, %Fail%
; =======================___THIS_IS_THE_END___=======================
; ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
