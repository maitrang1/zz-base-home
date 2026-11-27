@rem ===================================================================
@rem Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
@rem Des: Tests for ba-cmds-wind.bat with a fake mise
@rem Flo: temp tree > each task id > unknown id > exit code > aa-conf-main.env > env var wins
@rem I/O: none > PASS/FAIL lines, exit code = failed count
@rem Run: "E:\zz-base-home\ac-auto-task\ba-cmds-wind-test.bat"
@rem ===================================================================
@echo off
setlocal
set "T=%TEMP%\ba-cmds-test-%RANDOM%%RANDOM%"
set "PASSZ=0" & set "FAILZ=0"
mkdir "%T%\ac-auto-task" "%T%\as-apps\os-syst\wo-work-mode\zig-out\bin" >nul
copy "%~dp0ba-cmds-wind.bat" "%T%\ac-auto-task\" >nul
set "LOGZ=%T%\calls.log" & set "WOX=%T%\as-apps\os-syst\wo-work-mode\zig-out\bin\wo.exe" & set "DISP=%T%\ac-auto-task\ba-cmds-wind.bat"
> "%T%\fake-mise.bat" echo @echo off
>> "%T%\fake-mise.bat" echo ^>^>"%LOGZ%" echo mise %%*
>> "%T%\fake-mise.bat" echo ^>^>"%LOGZ%" echo dev=%%WO_DEVI_NAME%%
>> "%T%\fake-mise.bat" echo ^>^>"%LOGZ%" echo cwd=%%CD%%
>> "%T%\fake-mise.bat" echo exit /b %%FAKE_RC%%
set "FAKE_RC=0"
echo -- cmds-wind
for %%P in ("home-wipz|wipz --live" "home-docs|docs sync --live" "home-beat|beat --live" "home-bkup-stat|bkup stat --live" "home-bkup-nigh|bkup nigh --live" "home-doct|doct" "home-dril|dril --live" "home-code|sync --live" "cicd-stat|ci stat" "cicd-rele|ci rele" "cicd-test|ci test" "cicd-leak|ci leak" "cicd-lock|ci lock" "cicd-repr|ci repr" "cicd-deps|ci deps") do for /f "tokens=1,2 delims=|" %%A in ("%%~P") do call :runid "%%A" "%%B"
set "SCX=%T%\as-apps\ws-webs\sc-scra\zig-out\bin\scra.exe"
type nul > "%LOGZ%"
set "WO_DEVI_NAME=" & set "CMDS_MISE=%T%\fake-mise.bat"
call "%DISP%" scra-raws
> "%T%\exp.txt" echo mise exec -- "%SCX%" run --seed-file "%T%\..\.zz-base-home-tena\as-apps\ws-webs\sc-scra\seeds.txt" --follow 800 --live
findstr /b /c:"mise exec -- \"%SCX%\" run" "%LOGZ%" > "%T%\got.txt"
fc "%T%\exp.txt" "%T%\got.txt" >nul && call :ok "scra-raws runs scra run with the tena seeds" || call :bad "scra-raws runs scra run with the tena seeds"
call :runsc scra-data "cars --live"
call :runsc scra-inge "ingest --live"
call :runsc scra-cont "cont --live"
call :runsc scra-sync "sync --live"
set "FBX=%T%\as-apps\ch-chat\fb-face-webs\zig-out\bin\fb.exe" & set "ZAX=%T%\as-apps\ch-chat\za-zalo-webs\zig-out\bin\za.exe"
call :runapp fb-watc "%FBX%" "alive --acct all"
call :runapp za-watc "%ZAX%" "alive --acct all"
call :runapp face-scra "%FBX%" "read feed --live --acct all"
call :runapp zalo-scra "%ZAX%" "run read --live --acct all"
call :runapp zalo-scra "%ZAX%" "feed --live --acct all"
set "WO_DEVI_NAME=" & set "CMDS_MISE=%T%\fake-mise.bat"
call "%DISP%" home-wipz
findstr /b /c:"cwd=%T%" "%LOGZ%" >nul && call :ok "task runs from the repo root" || call :bad "task runs from the repo root"
call "%DISP%" nope-nope 2>"%T%\err.txt"
if errorlevel 2 (call :ok "unknown id exits 2") else (call :bad "unknown id exits 2")
findstr /c:"unknown task id: nope-nope" "%T%\err.txt" >nul && call :ok "unknown id says so" || call :bad "unknown id says so"
set "FAKE_RC=7"
call "%DISP%" home-doct
if "%errorlevel%"=="7" (call :ok "exit code passes through") else (call :bad "exit code passes through")
set "FAKE_RC=0"
set "CMDS_MISE=" & set "WO_DEVI_NAME="
> "%T%\ac-auto-task\aa-conf-main.env" echo # private
>> "%T%\ac-auto-task\aa-conf-main.env" echo WO_DEVI_NAME=dev9
>> "%T%\ac-auto-task\aa-conf-main.env" echo CMDS_MISE=%T%\fake-mise.bat
type nul > "%LOGZ%"
call "%DISP%" home-wipz
findstr /x /c:"dev=dev9" "%LOGZ%" >nul && call :ok "aa-conf-main.env sets the device name" || call :bad "aa-conf-main.env sets the device name"
findstr /b /c:"mise exec -- " "%LOGZ%" >nul && call :ok "aa-conf-main.env sets the mise command" || call :bad "aa-conf-main.env sets the mise command"
set "CMDS_MISE=" & set "WO_DEVI_NAME=envwins"
type nul > "%LOGZ%"
call "%DISP%" home-wipz
findstr /x /c:"dev=envwins" "%LOGZ%" >nul && call :ok "env var beats the file" || call :bad "env var beats the file"
mkdir "%T%\as-apps\ai-mind\sk-skil-tool" >nul
> "%T%\as-apps\ai-mind\sk-skil-tool\ps-bins-inst.ps1" echo Set-Content "%T%\skil.log" 'ran'; exit 3
call "%DISP%" skil-sync
set "RCS=%errorlevel%"
if "%RCS%"=="3" (call :ok "skil-sync exit code passes through") else (call :bad "skil-sync exit code passes through")
findstr /c:"ran" "%T%\skil.log" >nul && call :ok "skil-sync runs the skill installer" || call :bad "skil-sync runs the skill installer"
echo.
echo %PASSZ% passed, %FAILZ% failed
endlocal & exit /b %FAILZ%
:runid
type nul > "%LOGZ%"
set "WO_DEVI_NAME=" & set "CMDS_MISE=%T%\fake-mise.bat"
call "%DISP%" %~1
findstr /x /c:"mise exec -- \"%WOX%\" %~2" "%LOGZ%" >nul && call :ok "%~1 runs wo %~2" || call :bad "%~1 runs wo %~2"
exit /b 0
:runsc
type nul > "%LOGZ%"
set "WO_DEVI_NAME=" & set "CMDS_MISE=%T%\fake-mise.bat"
call "%DISP%" %~1
findstr /x /c:"mise exec -- \"%SCX%\" %~2" "%LOGZ%" >nul && call :ok "%~1 runs scra %~2" || call :bad "%~1 runs scra %~2"
exit /b 0
:runapp
type nul > "%LOGZ%"
set "WO_DEVI_NAME=" & set "CMDS_MISE=%T%\fake-mise.bat"
call "%DISP%" %~1
findstr /x /c:"mise exec -- \"%~2\" %~3" "%LOGZ%" >nul && call :ok "%~1 runs %~3" || call :bad "%~1 runs %~3"
exit /b 0
:ok
echo PASS  %~1
set /a PASSZ+=1
exit /b 0
:bad
echo FAIL  %~1
set /a FAILZ+=1
exit /b 0
@rem =======================___THIS_IS_THE_END___=======================
@rem ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
