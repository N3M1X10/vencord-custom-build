@echo off
chcp 65001>nul
setlocal EnableDelayedExpansion
set debug=

::kill
echo.&echo [93mkilling discord . . .[0m
taskkill /f /t /im "Discord.exe"
echo done

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


cd /d "%~dp0"
if exist "Vencord" (
	echo.
	choice /C "10" /m "[93mVencord already exist. Are you sure you want to [36mcheck updates [93mthe existing Vencord local repo in there?[0m"
	if "%errorlevel%"=="2" (goto close)
	echo.
	echo [93mUpdating . . .[90m
	cd Vencord
	git fetch origin
	git reset --hard origin/main

	echo [92mDone[0m
)
rem goto close


cd /d "%~dp0"
echo.&echo [93mCloning . . .[90m
git clone https://github.com/Vendicated/Vencord.git


echo.
choice /C "10" /m "[93m[?] Do you want to [36minstall [93mfrozen-lockfile?[0m"
if "%errorlevel%"=="2" (goto close)

echo.&echo [93minstalling --frozen-lockfile ...
cd /d Vencord
call pnpm install --frozen-lockfile

:close
if "%debug%"=="1" (
	timeout /t 60
) else (
	timeout /t 5
)
endlocal
exit
