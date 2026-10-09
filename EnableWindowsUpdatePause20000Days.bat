@echo off
setlocal EnableExtensions
title Enable Windows Update Pause Limit - FlightSettingsMaxPauseDays=20000

set "KEY=HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
set "VAL=FlightSettingsMaxPauseDays"
set "DAYS=20000"

rem ============================================================
rem  No third-party dependency. Uses only components that ship
rem  with Windows itself: cmd.exe, reg.exe, fltmc.exe, net.exe,
rem  where.exe, powershell.exe (elevation only, built-in since
rem  Windows 7). Nothing to install, nothing to unzip.
rem ============================================================

rem ---- Step 0: already relaunched elevated, skip the admin check ----
if /i "%~1"=="--elevated" goto main

rem ---- Step 1: administrator detection ----
fltmc >nul 2>&1
if not errorlevel 1 goto main
net session >nul 2>&1
if not errorlevel 1 goto main

rem ---- Step 2: raise a UAC prompt and restart this file elevated ----
echo.
echo [INFO] Administrator rights are required. Requesting UAC elevation...
echo        Please click "Yes" in the UAC dialog.
echo.
where powershell.exe >nul 2>&1
if errorlevel 1 goto no_ps
set "SELF=%~f0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:SELF -ArgumentList '--elevated' -Verb RunAs"
exit /b

:no_ps
echo.
echo [ERROR] powershell.exe was not found on this system.
echo         Please right-click this .bat file and choose
echo         "Run as administrator" instead.
echo.
pause
exit /b

:main
rem ---- pick the right registry view, so a 32-bit cmd on a 64-bit
rem      system still writes the real 64-bit key (no Wow6432Node) ----
set "REGFLAG=/reg:64"
if not defined PROCESSOR_ARCHITEW6432 if /i "%PROCESSOR_ARCHITECTURE%"=="x86" set "REGFLAG="

cls
echo ==============================================================
echo   Enable Windows Update Pause Limit
echo   ----------------------------------------------------------
echo   Registry key : %KEY%
echo   Value name   : %VAL%
echo   Value type   : REG_DWORD (32-bit)
echo   Value data   : %DAYS% (decimal)
echo   Registry view: %REGFLAG%
echo   Note         : reg.exe treats /d as decimal, so this writes
echo                  exactly the same data as choosing Decimal and
echo                  typing %DAYS% in regedit.
echo ==============================================================
echo.

reg add "%KEY%" /v %VAL% /t REG_DWORD /d %DAYS% /f %REGFLAG%
if errorlevel 1 goto fail

echo.
echo ---- Verify 1/2: raw query ----
reg query "%KEY%" /v %VAL% %REGFLAG%
echo.
echo ---- Verify 2/2: decimal value ----
set "HEX="
for /f "tokens=3" %%a in ('reg query "%KEY%" /v %VAL% %REGFLAG% 2^>nul ^| findstr /i /c:"%VAL%"') do set "HEX=%%a"
if not defined HEX goto verify_fail
set /a DEC=%HEX%
if not "%DEC%"=="%DAYS%" goto verify_fail
echo Current value, decimal = %DEC%
echo RESULT: OK - FlightSettingsMaxPauseDays is %DAYS% decimal.

echo.
echo Next step: open Settings - Windows Update - Pause updates, then choose a
echo duration. The maximum pause is %DAYS% days, which is about 54 years.
echo.
echo Rollback: delete the value in regedit, or run:
echo   reg delete "%KEY%" /v %VAL% /reg:64 /f
goto end

:verify_fail
echo.
echo [WARNING] The value was written but the read-back check looks wrong.
echo           Please confirm what reg query printed above.

:end
echo.
pause
exit /b

:fail
echo.
echo [ERROR] Could not write the registry value.
echo         Make sure this window runs as Administrator and that the
echo         account you are using is an administrator account.
echo.
pause
exit /b