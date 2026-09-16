@echo off
chcp 936 >nul
title 禁用 Windows 自动更新（生效至 2081 年）
color 0B

rem ====== 自动请求管理员权限 ======
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo 正在请求管理员权限，请在弹窗中点“是”...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo ==========================================
echo   正在禁用 Windows 自动更新（生效至 2081 年）
echo ==========================================
echo.

rem ---- 1. 组策略：关闭自动更新（Win7/10/11 通用）----
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v DoNotConnectToWindowsUpdateInternetLocations /t REG_DWORD /d 1 /f >nul
echo [1/4] 已写入组策略：禁止自动下载和安装更新

rem ---- 2. 暂停期限延长到 2081-01-01（Win10/11 设置页生效）----
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseFeatureUpdatesStartTime /t REG_SZ /d "2026-01-01T00:00:00Z" /f >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseFeatureUpdatesEndTime /t REG_SZ /d "2081-01-01T00:00:00Z" /f >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseQualityUpdatesStartTime /t REG_SZ /d "2026-01-01T00:00:00Z" /f >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseQualityUpdatesEndTime /t REG_SZ /d "2081-01-01T00:00:00Z" /f >nul
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseUpdatesExpiryTime /t REG_SZ /d "2081-01-01T00:00:00Z" /f >nul
echo [2/4] 已将暂停更新期限设置为 2081-01-01

rem ---- 3. 停用并禁用更新相关服务（注册表方式，最彻底）----
for %%S in (wuauserv UsoSvc WaaSMedicSvc DoSvc) do (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%S" /v Start /t REG_DWORD /d 4 /f >nul 2>&1
    sc stop %%S >nul 2>&1
)
echo [3/4] 已停用：Windows Update、更新协调、更新医生、传递优化服务

rem ---- 4. 禁用自动更新计划任务 ----
for %%T in ("\Microsoft\Windows\WindowsUpdate\Scheduled Start" "\Microsoft\Windows\WindowsUpdate\sih" "\Microsoft\Windows\UpdateOrchestrator\Schedule Scan" "\Microsoft\Windows\UpdateOrchestrator\USO_UxBroker") do (
    schtasks /Change /TN %%T /Disable >nul 2>&1
)
echo [4/4] 已禁用自动更新相关计划任务

echo.
echo ==========================================
echo   全部完成！2081 年之前本机不会自动更新。
echo   如需恢复，请运行同目录“恢复Windows更新.bat”
echo ==========================================
echo.
pause
