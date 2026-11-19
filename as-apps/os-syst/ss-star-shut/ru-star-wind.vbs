' ===================================================================
' Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
' Des: At login: WiFi, folders, Chrome profiles, VSCode, extras
' Flo: WiFi > folders > Chrome profiles > VSCode > extra scripts (admin)
' I/O: edit the config lines below > apps opened; a missing item shows a warning and the run goes on
' Run: wscript.exe "E:\zz-base-home\as-apps\os-syst\ss-star-shut\ru-star-wind.vbs"
' ===================================================================
Option Explicit
Const WIFI_NAME = "" : Const CODE_OPEN = True : Const WAIT_SECO = 3 : Const PAUS_FOLD = 1000
Dim FOLD_LIST, PROF_LIST, EXTR_LIST : FOLD_LIST = Array("C:\Users\Public\Documents") : PROF_LIST = Array("Default") : EXTR_LIST = Array()
Dim sh, fso, waitms : Set sh = CreateObject("WScript.Shell") : Set fso = CreateObject("Scripting.FileSystemObject") : waitms = WAIT_SECO * 1000
Sub Warn(msg, ttl) : MsgBox msg, vbExclamation, ttl : End Sub
Function EnvPath(nam) : EnvPath = sh.ExpandEnvironmentStrings(nam) : End Function
Function FindExe(paths) : Dim i : FindExe = "" : For i = 0 To UBound(paths) : If FindExe = "" Then If fso.FileExists(paths(i)) Then FindExe = paths(i)
Next : End Function
Sub OpenWifi()
If WIFI_NAME = "" Then Exit Sub
sh.Run "netsh wlan connect name=""" & WIFI_NAME & """", 0, True : WScript.Sleep waitms
If sh.Run("netsh wlan show interfaces | findstr /C:""" & WIFI_NAME & """", 0, True) <> 0 Then Warn "WiFi not connected - " & WIFI_NAME & " not found." & vbCrLf & "Script will continue.", "WiFi Warning"
End Sub
Sub OpenOne(f)
If f = "" Then Exit Sub
If fso.FolderExists(f) Then sh.Run "explorer.exe """ & f & """", 3, False : WScript.Sleep PAUS_FOLD Else Warn "Folder not found: " & f, "Folder Warning"
End Sub
Sub OpenFold() : Dim f : For Each f In FOLD_LIST : OpenOne f : Next : End Sub
Sub OpenProf(exe, p) : If p <> "" Then sh.Run """" & exe & """ --profile-directory=""" & p & """ --start-maximized", 3, False : WScript.Sleep waitms
End Sub
Sub OpenChro()
Dim exe, p
If Join(PROF_LIST, "") = "" Then Exit Sub
exe = FindExe(Array(EnvPath("%ProgramFiles%") & "\Google\Chrome\Application\chrome.exe", EnvPath("%ProgramFiles(x86)%") & "\Google\Chrome\Application\chrome.exe", EnvPath("%LocalAppData%") & "\Google\Chrome\Application\chrome.exe"))
If exe = "" Then Warn "Chrome not found. Skipping Chrome step.", "Chrome Warning" : Exit Sub
For Each p In PROF_LIST : OpenProf exe, p : Next
End Sub
Sub OpenCode()
Dim exe, first
If Not CODE_OPEN Then Exit Sub
exe = FindExe(Array(EnvPath("%LocalAppData%") & "\Programs\Microsoft VS Code\Code.exe", EnvPath("%ProgramFiles%") & "\Microsoft VS Code\Code.exe", EnvPath("%ProgramFiles(x86)%") & "\Microsoft VS Code\Code.exe"))
If exe = "" Then Warn "VSCode not found. Skipping VSCode step.", "VSCode Warning" : Exit Sub
first = "" : If UBound(FOLD_LIST) >= 0 Then first = FOLD_LIST(0)
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
OpenWifi : OpenFold : OpenChro : OpenCode : OpenExtr
' =======================___THIS_IS_THE_END___=======================
' ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
