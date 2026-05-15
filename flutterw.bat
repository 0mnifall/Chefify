@echo off
setlocal

set "SETUP_SCRIPT=%~dp0tools\setup-flutter.ps1"
if not exist "%SETUP_SCRIPT%" (
  echo Flutter setup script was not found at "%SETUP_SCRIPT%".
  exit /b 1
)

set "FLUTTER="
for /f "usebackq delims=" %%I in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%SETUP_SCRIPT%" -PrintFlutterExecutable`) do (
  set "FLUTTER=%%I"
)

if not defined FLUTTER (
  exit /b 1
)

if not exist "%FLUTTER%" (
  echo Flutter executable was not found at "%FLUTTER%".
  exit /b 1
)

call "%FLUTTER%" %*
exit /b %ERRORLEVEL%
