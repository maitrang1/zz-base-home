' ===================================================================
' Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
' Des: At login: WiFi, Sticky Notes, folders, Chrome profiles, VSCode, tr, old hub (3030); arg tr or hub = that one only
' Flo: WiFi > Sticky Notes > folders > Chrome profiles > VSCode > tr (hidden, only if down; mini window only if none open) > old hub (hidden, only if down) > extra scripts (admin)
' I/O: config lines below + aa-conf-main.env (WIFI_NAME, PROF_LIST, VSCO_BINA, HUBZ_BINA, HUBZ_PORT) > apps opened; a missing item shows a warning and the run goes on
' Run: wscript.exe "E:\zz-base-home\as-apps\os-syst\ss-star-shut\ru-star-wind.vbs" [tr|hub]
' ===================================================================
Option Explicit
Const CODE_OPEN = True : Const TR_PORT = 4000 : Const TR_JOBS = "aa-auto-task-wi01.json" : Const WAIT_SECO = 3 : Const PAUS_FOLD = 1000 : Const STIC_APPID = "Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe!App"
Dim sh, fso, waitms, root : Set sh = CreateObject("WScript.Shell") : Set fso = CreateObject("Scripting.FileSystemObject") : waitms = WAIT_SECO * 1000
root = fso.GetParentFolderName(fso.GetParentFolderName(fso.GetParentFolderName(fso.GetParentFolderName(WScript.ScriptFullName))))
Dim WIFI_NAME, VSCO_BINA, HUBZ_BINA, HUBZ_PORT, TR_EXEC, FOLD_LIST, PROF_LIST, EXTR_LIST : WIFI_NAME = "" : VSCO_BINA = "" : HUBZ_BINA = "" : HUBZ_PORT = 3030 : TR_EXEC = root & "\ac-auto-task\zig-out\bin\auto-task.exe" : FOLD_LIST = Array(root, "%USERPROFILE%\Downloads") : PROF_LIST = Array("Default") : EXTR_LIST = Array()
Sub Warn(msg, ttl) : MsgBox msg, vbExclamation, ttl : End Sub
Function EnvPath(nam) : EnvPath = sh.ExpandEnvironmentStrings(nam) : End Function
Function FindExe(paths) : Dim i : FindExe = "" : For i = 0 To UBound(paths) : If FindExe = "" Then If fso.FileExists(paths(i)) Then FindExe = paths(i)
Next : End Function
Sub OpenWifi()
If WIFI_NAME = "" Then Exit Sub
sh.Run "netsh wlan connect name=""" & WIFI_NAME & """", 0, True : WScript.Sleep waitms
If sh.Run("netsh wlan show interfaces | findstr /C:""" & WIFI_NAME & """", 0, True) <> 0 Then Warn "WiFi not connected - " & WIFI_NAME & " not found." & vbCrLf & "Script will continue.", "WiFi Warning"
End Sub
Sub OpenOne(ByVal f)
If f = "" Then Exit Sub
f = EnvPath(f)
If fso.FolderExists(f) Then sh.Run "explorer.exe """ & f & """", 3, False : WScript.Sleep PAUS_FOLD Else Warn "Folder not found: " & f, "Folder Warning"
End Sub
Sub OpenFold() : Dim f : For Each f In FOLD_LIST : OpenOne f : Next : End Sub
Sub OpenProf(exe, p) : If p <> "" Then sh.Run """" & exe & """ --profile-directory=""" & p & """ --start-maximized", 3, False : WScript.Sleep waitms
End Sub
Sub OpenChro()
Dim exe, p, n
n = 0
If Join(PROF_LIST, "") = "" Then Exit Sub
exe = FindExe(Array(EnvPath("%ProgramFiles%") & "\Google\Chrome\Application\chrome.exe", EnvPath("%ProgramFiles(x86)%") & "\Google\Chrome\Application\chrome.exe", EnvPath("%LocalAppData%") & "\Google\Chrome\Application\chrome.exe"))
If exe = "" Then Warn "Chrome not found. Skipping Chrome step.", "Chrome Warning" : Exit Sub
For Each p In PROF_LIST : OpenProf exe, p : n = n + 1 : If n = 1 Then WScript.Sleep waitms
Next
End Sub
Sub OpenCode()
Dim exe, first
If Not CODE_OPEN Then Exit Sub
exe = FindExe(Array(EnvPath(VSCO_BINA), EnvPath("%LocalAppData%") & "\Programs\Microsoft VS Code\Code.exe", EnvPath("%ProgramFiles%") & "\Microsoft VS Code\Code.exe", EnvPath("%ProgramFiles(x86)%") & "\Microsoft VS Code\Code.exe"))
If exe = "" Then Warn "VSCode not found. Skipping VSCode step.", "VSCode Warning" : Exit Sub
first = "" : If UBound(FOLD_LIST) >= 0 Then first = EnvPath(FOLD_LIST(0))
If first <> "" Then sh.Run """" & exe & """ """ & first & """", 1, False Else sh.Run """" & exe & """", 1, False
WScript.Sleep PAUS_FOLD
End Sub
Sub RunAdmin(x) : If LCase(fso.GetExtensionName(x)) = "vbs" Then CreateObject("Shell.Application").ShellExecute "wscript.exe", """" & x & """", "", "runas", 1 Else CreateObject("Shell.Application").ShellExecute x, "", "", "runas", 1
End Sub
Sub OpenExt1(x)
If x = "" Then Exit Sub
If fso.FileExists(x) Then RunAdmin x : WScript.Sleep PAUS_FOLD Else Warn "Script not found: " & x, "Script Warning"
End Sub
Sub OpenExtr() : Dim x : For Each x In EXTR_LIST : OpenExt1 x : Next : End Sub
Sub ConfSet(k, v)
Dim i
Select Case k
Case "WIFI_NAME" : WIFI_NAME = v
Case "VSCO_BINA" : VSCO_BINA = v
Case "HUBZ_BINA" : HUBZ_BINA = v
Case "HUBZ_PORT" : If IsNumeric(v) Then HUBZ_PORT = CLng(v)
Case "PROF_LIST" : PROF_LIST = Split(v, ",") : For i = 0 To UBound(PROF_LIST) : PROF_LIST(i) = Trim(PROF_LIST(i)) : Next
End Select
End Sub
Sub LoadConf(wrn)
Dim pf, ts, ln, p
pf = fso.GetParentFolderName(WScript.ScriptFullName) & "\aa-conf-main.env"
If Not fso.FileExists(pf) Then
If wrn Then Warn "aa-conf-main.env not found beside ru-star-wind.vbs." & vbCrLf & "WiFi, Chrome profiles and the VSCode path use the defaults.", "Config Warning"
Exit Sub
End If
Set ts = fso.OpenTextFile(pf, 1)
Do While Not ts.AtEndOfStream
ln = Trim(ts.ReadLine) : p = InStr(ln, "=")
If p > 1 And Left(ln, 1) <> "#" Then ConfSet Trim(Left(ln, p - 1)), Trim(Replace(Mid(ln, p + 1), """", ""))
Loop
ts.Close
End Sub
Sub OpenStic()
If STIC_APPID = "" Then Exit Sub
sh.Run "explorer.exe shell:AppsFolder\" & STIC_APPID, 1, False : WScript.Sleep PAUS_FOLD
End Sub
Function PingAt(port)
Dim tmp, ts
PingAt = "" : tmp = sh.ExpandEnvironmentStrings("%TEMP%") & "\ss-star-ping-" & port & ".txt"
fso.CreateTextFile(tmp, True).Close
sh.Run "cmd /c curl -s -f -m 2 http://127.0.0.1:" & port & "/ping -o """ & tmp & """ >nul 2>&1", 0, True
Set ts = fso.OpenTextFile(tmp, 1)
If Not ts.AtEndOfStream Then PingAt = ts.ReadAll
ts.Close
End Function
Function TrPing()
TrPing = PingAt(TR_PORT)
If InStr(TrPing, """ok"":true") = 0 Then TrPing = ""
End Function
Sub OpenHub()
Dim i
If HUBZ_BINA = "" Then Exit Sub
If PingAt(HUBZ_PORT) <> "" Then Exit Sub
If Not fso.FileExists(HUBZ_BINA) Then Warn "Hub not found: " & HUBZ_BINA, "Hub Warning" : Exit Sub
sh.Run """" & HUBZ_BINA & """ " & HUBZ_PORT, 0, False
For i = 1 To 20 : WScript.Sleep 500 : If PingAt(HUBZ_PORT) <> "" Then Exit For
Next
If PingAt(HUBZ_PORT) = "" Then Warn "Hub did not answer on port " & HUBZ_PORT, "Hub Warning"
End Sub
Function UiAge(js)
Dim rx, m
UiAge = -1 : Set rx = New RegExp : rx.Pattern = """uiAgeS"":(-?\d+)" : Set m = rx.Execute(js)
If m.Count > 0 Then UiAge = CLng(m(0).SubMatches(0))
End Function
Sub OpenTr()
Dim js, i, age
If TR_EXEC = "" Then Exit Sub
js = TrPing()
If js = "" Then
If Not fso.FileExists(TR_EXEC) Then Warn "auto-task (tr) not found: " & TR_EXEC, "tr Warning" : Exit Sub
sh.Run """" & TR_EXEC & """ " & TR_PORT & " " & TR_JOBS, 0, False
For i = 1 To 20 : WScript.Sleep 500 : js = TrPing() : If js <> "" Then Exit For
Next
If js = "" Then Warn "tr did not answer on port " & TR_PORT, "tr Warning" : Exit Sub
End If
age = UiAge(js)
If age < 0 Or age > 90 Then sh.Run "curl.exe -s http://127.0.0.1:" & TR_PORT & "/open-mini", 0, True
End Sub
If WScript.Arguments.Count = 0 Then
LoadConf True : OpenWifi : OpenStic : OpenFold : OpenChro : OpenCode : OpenTr : OpenHub : OpenExtr
ElseIf LCase(WScript.Arguments(0)) = "tr" Then
LoadConf False : OpenTr
ElseIf LCase(WScript.Arguments(0)) = "hub" Then
LoadConf False : OpenHub
Else
Warn "Use: ru-star-wind.vbs [tr|hub]", "Usage"
End If
' =======================___THIS_IS_THE_END___=======================
' ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
