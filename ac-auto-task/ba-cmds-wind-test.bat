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
for %%P in ("work-wipz|wipz --live" "work-docs|docs sync --live" "work-beat|beat --live" "work-bkup-stat|bkup stat --live" "work-bkup-nigh|bkup nigh --live" "work-doct|doct" "work-dril|dril --live" "work-code|sync --live" "cicd-stat|ci stat" "cicd-rele|ci rele" "cicd-test|ci test" "cicd-leak|ci leak" "cicd-lock|ci lock" "cicd-repr|ci repr" "cicd-deps|ci deps") do for /f "tokens=1,2 delims=|" %%A in ("%%~P") do call :runid "%%A" "%%B"
set "WO_DEVI_NAME=" & set "CMDS_MISE=%T%\fake-mise.bat"
call "%DISP%" work-wipz
findstr /b /c:"cwd=%T%" "%LOGZ%" >nul && call :ok "task runs from the repo root" || call :bad "task runs from the repo root"
call "%DISP%" nope-nope 2>"%T%\err.txt"
if errorlevel 2 (call :ok "unknown id exits 2") else (call :bad "unknown id exits 2")
findstr /c:"unknown task id: nope-nope" "%T%\err.txt" >nul && call :ok "unknown id says so" || call :bad "unknown id says so"
set "FAKE_RC=7"
call "%DISP%" work-doct
if "%errorlevel%"=="7" (call :ok "exit code passes through") else (call :bad "exit code passes through")
set "FAKE_RC=0"
set "CMDS_MISE=" & set "WO_DEVI_NAME="
> "%T%\ac-auto-task\aa-conf-main.env" echo # private
>> "%T%\ac-auto-task\aa-conf-main.env" echo WO_DEVI_NAME=dev9
>> "%T%\ac-auto-task\aa-conf-main.env" echo CMDS_MISE=%T%\fake-mise.bat
type nul > "%LOGZ%"
call "%DISP%" work-wipz
findstr /x /c:"dev=dev9" "%LOGZ%" >nul && call :ok "aa-conf-main.env sets the device name" || call :bad "aa-conf-main.env sets the device name"
findstr /b /c:"mise exec -- " "%LOGZ%" >nul && call :ok "aa-conf-main.env sets the mise command" || call :bad "aa-conf-main.env sets the mise command"
set "CMDS_MISE=" & set "WO_DEVI_NAME=envwins"
type nul > "%LOGZ%"
call "%DISP%" work-wipz
findstr /x /c:"dev=envwins" "%LOGZ%" >nul && call :ok "env var beats the file" || call :bad "env var beats the file"
echo.
echo %PASSZ% passed, %FAILZ% failed
endlocal & exit /b %FAILZ%
:runid
type nul > "%LOGZ%"
set "WO_DEVI_NAME=" & set "CMDS_MISE=%T%\fake-mise.bat"
call "%DISP%" %~1
findstr /x /c:"mise exec -- \"%WOX%\" %~2" "%LOGZ%" >nul && call :ok "%~1 runs wo %~2" || call :bad "%~1 runs wo %~2"
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
