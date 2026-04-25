@echo off
setlocal
powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0build_dist.ps1"
exit /b %ERRORLEVEL%
