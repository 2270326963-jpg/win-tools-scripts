@echo off
off&(cd/d "%~dp0")&(cacls "%SystemDrive%\System Volume Information" >nul 2>&1)||(start "" mshta vbscript:CreateObject^("Shell.Application"^).ShellExecute^("%~snx0"," %*","","runas",1^)^(window.close^)&exit /b)
if "%1"=="h" goto begin
start mshta vbscript:createobject("wscript.shell").run("""%~nx0"" h",0)(window.close)&&exit
:begin

if not "%OS%"=="Windows_NT" exit
title WindosActive
 
cd /D %~dp0
echo WindosActive
echo ====================================
echo Author:feiquan
echo Create:// :
echo UpdataDate:// :
echo Version:.0v
echo Function:
echo        Windos激活器
echo        可以将已有的序列号输入WindosSerial.ini中进行测试，
echo        在ActiveLog.log中查看激活的详细信息
echo =====================================
cls
 
set slmgrPath=%SystemRoot%\system32\slmgr.vbs
set pk=null
set KMS=null
 
if exist ActiveLog.log del ActiveLog.log >nul
 
setlocal EnableDelayedExpansion
    set pk=NRG8B-VKK3Q-CXVCJ-9G2XF-6Q84J
    echo 使用密钥：privetKey 测试...
    echo 使用密钥：privetKey 测试...>>ActiveLog.log
 
    echo 卸载产品密钥:>>ActiveLog.log
    cscript /nologo %slmgrPath% /upk >>ActiveLog.log
 
    (
        more ActiveLog.log |find "拒绝访问: 所请求的操作需要提升特权" >nul && echo 请以管理员身份运行 && pause && exit ) || (
        more ActiveLog.log |find "Access denied: the requested action requires elevated privileges" >nul && echo Please runas Administrator && pause && exit
    )
 
    echo 从注册表中清除产品密钥^(防止泄露引起的攻击^):>>ActiveLog.log
    cscript /nologo %slmgrPath% /cpky >>ActiveLog.log>>ActiveLog.log
 
    echo 清除所使用的KMS计算机名称^(将端口设置为默认值^):>>ActiveLog.log
    cscript /nologo %slmgrPath% /ckms >>ActiveLog.log>>ActiveLog.log
 
    set KMS=kms.03k.org
    echo 设置KMS计算机名称为：!KMS!>>ActiveLog.log
    cscript /nologo %slmgrPath% /skms !KMS! >>ActiveLog.log
 
    echo 开始使用密钥：privetKey 激活 >>ActiveLog.log
    cscript /nologo %slmgrPath% /ipk  !pk!
    cscript /nologo %slmgrPath% /ato  >>ActiveLog.log
 
    echo ++++++++++++++++++++++++++++++>>ActiveLog.log
 
    (
        (
            more ActiveLog.log | find "成功地激活了产品。" >nul && (
            echo privetKey 成功地激活了产品。
            cscript /nologo %slmgrPath% /dlv  | more
            %slmgrPath% /xpr
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
echo 卓越模式激活成功>>ActiveLog.log
msg %username% /time:10 卓越模式激活完毕，若要使用，请在控制面板内的电源选项中勾选 对话框10秒后关闭

            exit
            )
        ) || (
            more ActiveLog.log | find "Product activated successfully." >nul && (
            echo !pk! Product activated successfully.
            cscript /nologo %slmgrPath% /dlv  | more
            %slmgrPath% /xpr
            exit
            )
        )
    ) || echo             Defeated&&echo.
 
setlocal DisableDelayedExpansion
echo WindowsSerial.ini中的所有的序列号都测试失败，请重新百度新的Windows密钥输入到WindosSerial.ini进行激活
exit