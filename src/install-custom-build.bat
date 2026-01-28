@echo off
chcp 65001>nul
setlocal EnableDelayedExpansion
set debug=

:request-admin-rights
set adm_arg=%1
if "%adm_arg%" neq "admin" (
    echo [93m[powershell] Requesting admin rights...[0m
    powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "Start-Process 'cmd.exe' -ArgumentList '/k \"\"%~f0\" admin\"' -Verb RunAs"
    exit /b
)

set src=Vencord\src
set plugins=userplugins


:check-discord
call :check-process "Discord.exe"
if %errorlevel% equ 1 set discord_been=1



:check-pnpm
echo [90mchecking pnpm...[0m
where pnpm >nul 2>nul
if %ERRORLEVEL% equ 0 (
    for /f "tokens=*" %%v in ('pnpm --version') do set PNPM_VER=%%v
    echo [90m[OK] pnpm is installed ^(!PNPM_VER!^)
    echo done[0m
) else (
    echo [91m[ERROR] pnpm has NOT found. Please install it via 'corepack enable' or npm[0m
    echo.&echo [93mPress any key to exit . . . &>nul timeout /t 30 & goto close
)

:check-git
echo.
echo [90mchecking git...[0m
where git >nul 2>nul
if %ERRORLEVEL% equ 0 (
    for /f "tokens=*" %%v in ('git --version') do set GIT_VER=%%v
    echo [90m[OK] git is installed ^(!GIT_VER!^)
    echo done[0m
) else (
    echo [93m[ERROR] git has NOT found. Please download it from git-scm.com
    echo.&echo [93mPress any key to exit . . . &>nul timeout /t 30 & goto close
)

:check-upload
echo.
cd /d %~dp0
echo [90mchecking uploading user dir...[0m
if not exist "%plugins%" (
    echo [93m[WARNING] : I cannot find %plugins% folder in my directory.
    echo [36mI can make it. But it seems to be empty while im going to making some things to inject the Vencord.
    echo [90mDoes it make sense to create a custom build if there are no custom plugins?[0m
    echo.
    echo [93mAre we continuing this?[0m
    pause
    echo [90mCreating...
    md %plugins%
    echo created!
    echo continuing . . .[0m
) else (
    echo [90mdone! uploading user dir is there[0m
)



:check-vencord
echo.
cd /d "%~dp0"
if exist "%src%" (
    echo [92mFound the Vencord dir[0m

    cd /d "%~dp0%src%"
    if exist "%plugins%" (
        echo.&echo [93muserplugins dir already there. cleaning . . .[0m
        rd /q /s %plugins%
        echo done
    )
    echo.&echo [93mcopying the plugins into %~dp0%src%\%plugins% . . .[0m
    cd /d "%~dp0"
    xcopy /e /y "%plugins%\" "%src%\%plugins%\"
    echo done
) else (
    echo [31mIDK where vencord is...[0m
    echo [93mSeems you need to clone Vencord to my directory. Do you want to try it now?[0m
    echo.
    pause
    
    echo.&echo [93mCloning . . .[90m
    git clone https://github.com/Vendicated/Vencord.git

    echo.&echo [93minstalling --frozen-lockfile . . .
    cd /d Vencord
    call pnpm install --frozen-lockfile
)


:kill-discord
echo.&echo [93mkilling discord . . .[90m
rem taskkill /f /t /im "Discord.exe"
call :check-process "Discord.exe" "kill"
echo done[0m


rem :repair
rem echo.&echo [93mrepairing the vencord . . .[0m
rem cd /d %~dp0\Vencord\dist\Installer
rem call "VencordInstallerCli.exe" --repair --branch stable
rem echo done


:inject
echo.&echo [93mbuilding and injecting the vencord . . .[0m
cd /d %~dp0\Vencord
:: build
call pnpm build --dev
:: inject
call pnpm inject --branch auto
if "%errorlevel%" neq "0" (msg * "[%~xn0] : pnpm inject exit code: %errorlevel%")
echo done


:start-discord
set discord=%LocalAppData%\Discord
cd /d "%discord%"
if "%discord_been%" == "1" (
    echo.&echo [93mstarting discord . . .[0m
    start "%~nx0" "Update.exe" --processStart Discord.exe
    echo done
)



:close
if "%debug%"=="1" (
    echo.&echo [93mdebug ended&timeout /t 120&exit
)
endlocal
exit



:check-process
set checking_process=%~1
set defined_tasks_count=

echo.&echo [93mAre '%checking_process%' is running?[0m

for /F "delims=" %%i in ('tasklist /fi "IMAGENAME eq %checking_process%" /fo CSV ^| find /c "%checking_process%"') do set defined_tasks_count=%%i

if "%~2"=="kill" (
    :: stopping it and making sure that this is not running
    echo Function action is: "%~2"

    if %defined_tasks_count% geq 1 (
        echo [91mYes[0m
        :: kill and make sure that process is killed
        echo [93m[cycle] : Trying to stop it . . .[0m
        taskkill /f /t /im "%checking_process%"
        echo Repeat checking . . .
        call :wait 500
        goto :check-process

    ) else (
        echo [92mNo[0m
        exit /b
    )

) else if "%~2"=="wait" (
    :: waiting to appear
    echo Function action is: "%~2"

    if %defined_tasks_count% geq 1 (
        echo [92mYes[0m
        exit /b
    ) else (
        echo [91mNo[0m
        echo [93m[cycle] : Waiting for "%checking_process%" to appear . . .[0m
        call :wait 1000
        goto :check-process
    )

) else (
    :: when we without any actions in %~2
    if %defined_tasks_count% geq 1 (
        echo [93mYes[0m
        exit /b 1
    ) else (
        echo [93mNo[0m
        exit /b 0
    )
    exit /b
)
msg * "Checking function for """"!checking_process!"""" has an exeption"
set debug=0
goto :close



:wait
:: just a function for additional delays in code. 
::it takes params:
:: time - wait in milliseconds
if "%1"=="" (set time=1000) else (set time=%1)
powershell -Command "$time = '!time!'; Write-Host "Pause for a $time ms"; Start-Sleep -m $time; exit"
set time=
exit /b


