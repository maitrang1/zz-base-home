@rem ===================================================================
@rem Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
@rem Des: Auto-run dispatcher for jobs with no run line (Windows)
@rem Flo: read job id > run its command via one if line > else exit 2
@rem I/O: job id (argv 1, from the scheduler) > command exit code, or stderr + exit 2
@rem Run: "E:\zz-base-home\ac-auto-task\ba-cmds-wind.bat" <job-id>
@rem ===================================================================
@echo off
echo ba-cmds-wind.bat: unknown job id: %~1 1>&2
exit /b 2
@rem =======================___THIS_IS_THE_END___=======================
@rem ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
