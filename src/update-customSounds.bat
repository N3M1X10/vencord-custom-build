@echo off
chcp 65001>nul
setlocal EnableDelayedExpansion
set debug=

::kill
echo.&echo [93mkilling discord . . .[0m
taskkill /f /t /im "Discord.exe"
echo done

:check-pnpm
echo [96mchecking pnpm...[0m
where pnpm >nul 2>nul
if %ERRORLEVEL% equ 0 (
    for /f "tokens=*" %%v in ('pnpm --version') do set PNPM_VER=%%v
    echo [OK] pnpm is installed ^(!PNPM_VER!^)
    echo done
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

cd /d "%~dp0"
set "plugin=customSounds"
set "tar=%~dp0userplugins"

if exist "%tar%" (
	if exist "%tar%\%plugin%" (
		echo.
		echo [93mPlugin already exist. Are you sure you want to [91mclean and overwrite [93mthe existing local repo in there?[0m
		echo.
		pause
		echo [93mCleaning . . .[90m
		rd /q /s "%tar%\%plugin%"
		echo [92mDone[0m
	)
) else (
	md %tar%
)


echo.&echo [93mCloning . . .[90m

cd /d "%tar%"
git clone https://github.com/ScattrdBlade/customSounds.git
echo [92mdone
echo [93mnow you can close this window

if "%debug%"=="1" (
	timeout /t 60
) else (
	timeout /t 5
)
endlocal
exit
