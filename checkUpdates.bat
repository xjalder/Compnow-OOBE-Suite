@echo off

:: Set PowerShell execution policy to RemoteSigned for the current user
powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"

:: Run the PowerShell script
powershell -ExecutionPolicy RemoteSigned -File "%~dp0checkUpdatesPS.ps1"