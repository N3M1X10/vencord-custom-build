@echo off
setlocal EnableDelayedExpansion

::kill
echo.&echo [93mkilling discord . . .[0m
taskkill /f /t /im "Discord.exe"
echo done

echo uninjecting the vencord . . .
cd /d %~dp0\Vencord
call pnpm uninject -branch stable

endlocal
timeout /t 5
exit
