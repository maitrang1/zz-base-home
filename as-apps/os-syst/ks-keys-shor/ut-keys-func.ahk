; ===================================================================
; Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
; Des: Helpers for one-tap keys: send, double-tap, shutdown
; Flo: send combo > wait key release > check double-tap > run shutdown
; I/O: key name + combo (text) > keys sent to the active window, or shutdown run
; ===================================================================
CF := {taps: 300, hdbl: 0.2, shut: A_ScriptDir "\..\ss-star-shut\ru-shut-wind.bat"}
Out(keys)
{
global Test, Logz
if (Test)
Logz .= keys "|"
else
Send, %keys%
}
Tap(keys, key)
{
Out(keys)
KeyWait, %key%
}
DblOk(prior, gap, hk, ms)
{
return (prior = hk && prior != "" && gap < ms)
}
Dbl(hk)
{
global CF
return DblOk(A_PriorHotkey, A_TimeSincePriorHotkey, hk, CF.taps)
}
Once(hk, keys)
{
if (Dbl(hk))
Out(keys)
}
Tap2(one, two, hk, key)
{
if (Dbl(hk))
Out(two)
else
Out(one)
KeyWait, %key%
}
HomeKey()
{
global CF
hdbl := CF.hdbl
KeyWait, Home
KeyWait, Home, D T%hdbl%
if (ErrorLevel = 0)
Out("^+i")
else
Out("!{Left}")
}
Shut()
{
global CF, Test, Logz
shut := CF.shut
if (Test)
Logz .= "RUN|"
else
Run, %ComSpec% /c ""%shut%""
}
EndKey()
{
if (Dbl("$End"))
Shut()
else
Out("!{Right}")
KeyWait, End
}
Guid()
{
MsgBox, 0, __ ShortKey Guide _ Custom Remapped Unused Keys __,
(
+----------------------------------------------------+
|  Esc x2  Close Window   |  PrtScr   Address Bar    |
|  Scroll  Prev Tab       |  Pause    Next Tab       |
|  PageUp  App Forward    |  PageDn   App Backward   |
|  Insert  Hard Refresh   |  Menu     This Guide     |
+----------------------------------------------------+
|  F1      Find           |  F2       Find Replace   |
|  F3      Save           |  F4       Plain Paste    |
|  F5      Cut            |  F6       Select All     |
|  F7      Copy           |  F8       Paste          |
|  F9      Undo           |  F10      Redo           |
|  F11     Close Tab      |  F12      New Tab        |
|                         |  F12 x2   Re-Open Tab    |
+----------------------------------------------------+
|  Home    Backward       |  Home x2  DevTools       |
|  End     Forward        |  End  x2  SHUTDOWN       |
|  Backtick + 1~6  Heading 1-6                       |
+----------------------------------------------------+
)
KeyWait, AppsKey
}
; =======================___THIS_IS_THE_END___=======================
; ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
