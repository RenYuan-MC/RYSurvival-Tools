@echo off
title 任渊生存-测试模式
cd /d "%~dp0"
cls

call :info 初始化中...

:: 付费版参数检查
if "%~1" == "-pro" (set folder=RYSurvival-Pro && call :info 检测到使用付费版仓库) else (set folder=RYSurvival && call :info 检测到使用免费版仓库)
set folder=%folder: =%

:: 彩色字体初始化
setlocal EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "DEL=%%a"
call :info 彩色字体已完成初始化
cd..

:: 读取服务端版本
if exist %folder% (cd %folder%) else call :NotFoundError %folder% folder
call :info 已找到服务端仓库文件夹
if not exist .version call :NotFoundError .version file
call :info 已找到版本识别文件
:: 读取.version文件中的版本信息
for /f "tokens=1,* delims==" %%a in ('findstr "Version=" ".version"') do set version=%%b
if "%version%" == "" call :InvalidParameterError version
:: 清除空格
set version=%version: =%
call :info 读取到服务端版本 %version%
if "%version%" == "non-version" goto non-version-exit
cd /d "%~dp0"

:: 检查运行库
call :info 检查运行库中
if exist test-environment-runtime (cd test-environment-runtime) else call :NotFoundError test-environment-runtime folder
call :info 已找到运行库文件夹
if not exist java\bin\java.exe call :NotFoundError java.exe file
call :info 已找到Java
if exist test-flies (cd test-flies) else call :NotFoundError test-flies folder
call :info 已找到测试文件夹

:: 检查版本文件夹是否存在
if not exist TestServerLib_%version% call :NotFoundError TestServerLib_%version% folder
call :info 已找到测试文件

:: 读取对应版本的核心
for /f "tokens=1,* delims==" %%a in ('findstr "%version%=" "version.properties"') do set core-name=%%b
if "%core-name%" == "" call :InvalidParameterError core-name
:: 清除空格
set core-name=%core-name: =%
call :info 读取到服务端核心名称 %core-name%
for /l %%a in (1,1,3) do cd..

:: 清理测试服务器文件夹
if exist RYSurvival-TestServer rd RYSurvival-TestServer /s/q
mkdir RYSurvival-TestServer
call :info 已重置试服务器文件夹
call :info 复制服务端文件中

:: 复制服务端
xcopy "%folder%\Server" RYSurvival-TestServer /S/E/Y/I>nul
call :info 已复制仓库文件
xcopy "%~dp0test-environment-runtime\test-flies\TestServerLib" RYSurvival-TestServer /S/E/Y/I>nul
xcopy "%~dp0test-environment-runtime\test-flies\TestServerLib_%version%" RYSurvival-TestServer /S/E/Y/I>nul
call :info 已复制对应版本的测试文件
cd RYSurvival-TestServer

:: 初始化完成
call :info 初始化完成

:: 启动服务端
call :info 按任意键启动服务端 && pause>nul
:: 设置标题
title 任渊生存服务端-测试模式 %core-name:-=%


:: 脚本主循环
:loop
:: 刷新控制台
cls
:: 启动服务器
echo loading %core-name:-=%, please wait...
"%~dp0\test-environment-runtime\java\bin\java.exe" -Xms2G -Xmx2G --add-modules=jdk.incubator.vector -jar %core-name%.jar nogui
echo #
:: 关服分割线
echo -----------------------------------------------------
call :info 按任意键重启测试服务器 
:: 重启服务器
pause>nul

goto loop














:: 控制台输出方法
:info
echo [Info] %~1 %~2 %~3 %~4 %~5
goto exit

:warning
call :colortext 0e "[Warning] %~1" && echo.
goto exit

:error
call :colortext 0c "[Error] %~1" && echo.
goto exit

:: 输出彩色字体
:colortext
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1
goto exit


:: 错误报告处理
:NotFoundError
if "%~2" == "folder" call :error "NotFoundError：无法找到对应文件夹 %~1"
if "%~2" == "file" call :error "NotFoundError：无法找到对应文件 %~1"
pause>nul
exit 

:InvalidParameterError
call :error "InvalidParameterError：无效参数 %~1"
pause>nul
exit 

:: 检测到非服务端的退出
:non-version-exit
call :info 无服务端,即将退出
ping -n 3 -w 500 0.0.0.1 > nul
goto exit

:exit


