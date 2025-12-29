@echo off
:: Set PowerShell execution policy to RemoteSigned for the current user
powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"

:: Run the QA PowerShell script
powershell -ExecutionPolicy RemoteSigned -File "%~dp0QAScripts\qa.ps1"

:: Run the Updates script
powershell -ExecutionPolicy RemoteSigned -File "%~dp0updatesPS.ps1"

pause
