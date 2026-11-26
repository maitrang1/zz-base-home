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
set "SCRA=%R%\as-apps\ws-webs\sc-scra\zig-out\bin\scra.exe"
set "FBZ=%R%\as-apps\ch-chat\fb-face-webs\zig-out\bin\fb.exe"
set "ZAZ=%R%\as-apps\ch-chat\za-zalo-webs\zig-out\bin\za.exe"
set "SEED=%R%\..\.zz-base-home-tena\as-apps\ws-webs\sc-scra\seeds.txt"
call :conf
if not defined CMDS_MISE set "CMDS_MISE=mise"
cd /d "%R%"
if "%~1"=="home-wipz" call "%CMDS_MISE%" exec -- "%WOZ%" wipz --live & call exit /b %%errorlevel%%
if "%~1"=="home-docs" call "%CMDS_MISE%" exec -- "%WOZ%" docs sync --live & call exit /b %%errorlevel%%
if "%~1"=="home-code" call "%CMDS_MISE%" exec -- "%WOZ%" sync --live & call exit /b %%errorlevel%%
if "%~1"=="home-beat" call "%CMDS_MISE%" exec -- "%WOZ%" beat --live & call exit /b %%errorlevel%%
if "%~1"=="home-bkup-stat" call "%CMDS_MISE%" exec -- "%WOZ%" bkup stat --live & call exit /b %%errorlevel%%
if "%~1"=="home-bkup-nigh" call "%CMDS_MISE%" exec -- "%WOZ%" bkup nigh --live & call exit /b %%errorlevel%%
if "%~1"=="home-doct" call "%CMDS_MISE%" exec -- "%WOZ%" doct & call exit /b %%errorlevel%%
if "%~1"=="home-dril" call "%CMDS_MISE%" exec -- "%WOZ%" dril --live & call exit /b %%errorlevel%%
if "%~1"=="cicd-stat" call "%CMDS_MISE%" exec -- "%WOZ%" ci stat & call exit /b %%errorlevel%%
if "%~1"=="cicd-rele" call "%CMDS_MISE%" exec -- "%WOZ%" ci rele & call exit /b %%errorlevel%%
if "%~1"=="cicd-test" call "%CMDS_MISE%" exec -- "%WOZ%" ci test & call exit /b %%errorlevel%%
if "%~1"=="cicd-leak" call "%CMDS_MISE%" exec -- "%WOZ%" ci leak & call exit /b %%errorlevel%%
if "%~1"=="cicd-lock" call "%CMDS_MISE%" exec -- "%WOZ%" ci lock & call exit /b %%errorlevel%%
if "%~1"=="cicd-repr" call "%CMDS_MISE%" exec -- "%WOZ%" ci repr & call exit /b %%errorlevel%%
if "%~1"=="cicd-deps" call "%CMDS_MISE%" exec -- "%WOZ%" ci deps & call exit /b %%errorlevel%%
if "%~1"=="scra-raws" call "%CMDS_MISE%" exec -- "%SCRA%" run --seed-file "%SEED%" --follow 800 --live & call exit /b %%errorlevel%%
if "%~1"=="scra-data" call "%CMDS_MISE%" exec -- "%SCRA%" cars --live & call exit /b %%errorlevel%%
if "%~1"=="scra-inge" call "%CMDS_MISE%" exec -- "%SCRA%" ingest --live & call exit /b %%errorlevel%%
if "%~1"=="scra-cont" call "%CMDS_MISE%" exec -- "%SCRA%" cont --live & call exit /b %%errorlevel%%
if "%~1"=="scra-sync" call "%CMDS_MISE%" exec -- "%SCRA%" sync --live & call exit /b %%errorlevel%%
if "%~1"=="fb-watc" call "%CMDS_MISE%" exec -- "%FBZ%" alive --acct all & call exit /b %%errorlevel%%
if "%~1"=="za-watc" call "%CMDS_MISE%" exec -- "%ZAZ%" alive --acct all & call exit /b %%errorlevel%%
if "%~1"=="face-scra" call "%CMDS_MISE%" exec -- "%FBZ%" read feed --live --acct all & call exit /b %%errorlevel%%
if "%~1"=="zalo-scra" goto :zalo_scra
echo ba-cmds-wind.bat: unknown task id: %~1 1>&2
exit /b 2
:zalo_scra
rem the feed step runs even when one account failed to read; the exit code is the first failure
call "%CMDS_MISE%" exec -- "%ZAZ%" run read --live --acct all
set "RC1=%errorlevel%"
call "%CMDS_MISE%" exec -- "%ZAZ%" feed --live --acct all
set "RC2=%errorlevel%"
if not "%RC1%"=="0" exit /b %RC1%
exit /b %RC2%
:conf
if not exist "%~dp0aa-conf-main.env" exit /b 0
for /f "usebackq eol=# tokens=1,* delims==" %%a in ("%~dp0aa-conf-main.env") do (
if /i "%%a"=="CMDS_MISE" if not defined CMDS_MISE set "CMDS_MISE=%%b"
if /i "%%a"=="WO_DEVI_NAME" if not defined WO_DEVI_NAME set "WO_DEVI_NAME=%%b"
)
exit /b 0
@rem =======================___THIS_IS_THE_END___=======================
@rem ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
