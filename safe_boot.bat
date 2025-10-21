@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
:: --- Require admin ---
fltmc >nul 2>&1 || (
  echo This script must be run as Administrator.
  pause
  exit /b 1
)

:: --- Detect Safe Boot state ---
set "mode="
for /f "tokens=2 delims= " %%A in ('bcdedit /enum {current} ^| findstr /i safeboot') do set "mode=%%A"

if "%mode%"=="" (
  echo Safe Boot is not set. Enabling minimal Safe Boot...
  bcdedit /set {current} safeboot minimal
  call :countdown
  shutdown /r /fw /t 0
  shutdown /r /fw /t 0
) else (
  echo Safe Boot is already set to: %mode%
  set /p input=Disable Safe Boot now? Y/N: 
  if /i "!input!"=="Y" (
    echo Disabling Safe Boot...
    bcdedit /deletevalue {current} safeboot
    call :countdown
    shutdown /r /t 0
  ) else (
    echo No changes made.
  )
)
goto :eof

:countdown
for %%i in (5 4 3 2 1) do (
    echo Restarting in %%i seconds
    timeout /t 1 >nul
)
goto :eof
