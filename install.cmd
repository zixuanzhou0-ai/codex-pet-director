@echo off
setlocal

set "REPO=zixuanzhou0-ai/codex-pet-director"
set "BRANCH=main"
set "LOCAL_PS1=%~dp0install.ps1"

where powershell >nul 2>nul
if errorlevel 1 (
  set "EXIT_CODE=1"
  echo [codex-pet-director] PowerShell is required but was not found.
  goto :end
)

if exist "%LOCAL_PS1%" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%LOCAL_PS1%" %*
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/%REPO%/%BRANCH%/install.ps1 | iex"
)

set "EXIT_CODE=%ERRORLEVEL%"
if not "%EXIT_CODE%"=="0" goto :fail

echo [codex-pet-director] Install command finished.
goto :end

:fail
echo [codex-pet-director] Install command failed.

:end
if "%CODEX_PET_DIRECTOR_NO_PAUSE%"=="" pause
exit /b %EXIT_CODE%
