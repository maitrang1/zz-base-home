@rem ===================================================================
@rem Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
@rem Des: Auto-run dispatcher for tasks with no run line (Windows)
@rem Flo: read task id > load aa-conf-main.env > run its command via one if line > else exit 2
@rem I/O: task id (argv 1, from the scheduler) + optional aa-conf-main.env (CMDS_MISE, WO_DEVI_NAME) > command exit code, or stderr + exit 2
@rem Run: "E:\zz-base-home\ac-auto-task\ba-cmds-wind.bat" <task-id>
@rem ===================================================================
@echo off
rem exit code: "call exit /b %%errorlevel%%" - a plain "exit /b" after a command returns 0 and hides failures
setlocal
for %%I in ("%~dp0..") do set "R=%%~fI"
set "WOZ=%R%\as-apps\os-syst\wo-work-mode\zig-out\bin\wo.exe"
call :conf
if not defined CMDS_MISE set "CMDS_MISE=mise"
cd /d "%R%"
if "%~1"=="work-wipz" call "%CMDS_MISE%" exec -- "%WOZ%" wipz --live & call exit /b %%errorlevel%%
if "%~1"=="work-docs" call "%CMDS_MISE%" exec -- "%WOZ%" docs sync --live & call exit /b %%errorlevel%%
if "%~1"=="work-beat" call "%CMDS_MISE%" exec -- "%WOZ%" beat --live & call exit /b %%errorlevel%%
if "%~1"=="work-bkup-stat" call "%CMDS_MISE%" exec -- "%WOZ%" bkup stat --live & call exit /b %%errorlevel%%
if "%~1"=="work-bkup-nigh" call "%CMDS_MISE%" exec -- "%WOZ%" bkup nigh --live & call exit /b %%errorlevel%%
if "%~1"=="work-doct" call "%CMDS_MISE%" exec -- "%WOZ%" doct & call exit /b %%errorlevel%%
if "%~1"=="work-dril" call "%CMDS_MISE%" exec -- "%WOZ%" dril --live & call exit /b %%errorlevel%%
if "%~1"=="cicd-stat" call "%CMDS_MISE%" exec -- "%WOZ%" ci stat & call exit /b %%errorlevel%%
if "%~1"=="cicd-rele" call "%CMDS_MISE%" exec -- "%WOZ%" ci rele & call exit /b %%errorlevel%%
if "%~1"=="cicd-test" call "%CMDS_MISE%" exec -- "%WOZ%" ci test & call exit /b %%errorlevel%%
if "%~1"=="cicd-leak" call "%CMDS_MISE%" exec -- "%WOZ%" ci leak & call exit /b %%errorlevel%%
if "%~1"=="cicd-lock" call "%CMDS_MISE%" exec -- "%WOZ%" ci lock & call exit /b %%errorlevel%%
if "%~1"=="cicd-repr" call "%CMDS_MISE%" exec -- "%WOZ%" ci repr & call exit /b %%errorlevel%%
if "%~1"=="cicd-deps" call "%CMDS_MISE%" exec -- "%WOZ%" ci deps & call exit /b %%errorlevel%%
echo ba-cmds-wind.bat: unknown task id: %~1 1>&2
exit /b 2
:conf
if not exist "%~dp0aa-conf-main.env" exit /b 0
for /f "usebackq eol=# tokens=1,* delims==" %%a in ("%~dp0aa-conf-main.env") do (
if /i "%%a"=="CMDS_MISE" if not defined CMDS_MISE set "CMDS_MISE=%%b"
if /i "%%a"=="WO_DEVI_NAME" if not defined WO_DEVI_NAME set "WO_DEVI_NAME=%%b"
)
exit /b 0
@rem =======================___THIS_IS_THE_END___=======================
@rem ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
