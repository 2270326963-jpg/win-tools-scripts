@echo off
title Activate Windows 11 Pro for Workstations (KMS)
color 0B

REM ===== auto elevate =====
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges, please click Yes...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "SL=cscript //nologo %SystemRoot%\system32\slmgr.vbs"

echo ==========================================
echo   Windows 11 Pro for Workstations - KMS
echo ==========================================
echo.

echo [1/4] Checking current activation status...
powershell -NoProfile -Command "$p = Get-CimInstance SoftwareLicensingProduct -Filter \"ApplicationId='55c92734-d682-4d71-983e-d6ec3f16059f' AND PartialProductKey IS NOT NULL\" -ErrorAction SilentlyContinue; if ($p -and ($p.LicenseStatus -eq 1)) { exit 0 } else { exit 1 }"
if %errorlevel%==0 (
    echo       Already activated. Nothing to do.
    goto showstatus
)
echo       Not activated yet.
echo.

echo [2/4] Checking KMS server connectivity (kms.03k.org:1688)...
powershell -NoProfile -Command "if ((Test-NetConnection kms.03k.org -Port 1688 -WarningAction SilentlyContinue).TcpTestSucceeded) { exit 0 } else { exit 1 }"
if %errorlevel% neq 0 (
    echo       ERROR: KMS server unreachable. Check network and run again.
    goto end
)
echo       Reachable.
echo.

echo [3/4] Installing GVLK and setting KMS host...
%SL% /ipk NRG8B-VKK3Q-CXVCJ-9G2XF-6Q84J
%SL% /skms kms.03k.org
echo.

echo [4/4] Activating...
%SL% /ato
echo.

:showstatus
echo ==========================================
echo   Current license status:
echo ==========================================
%SL% /xpr
echo.

:end
echo Finished.
pause
