@echo off
rem ScratchVerilog launcher
rem   double-click            -> open the editor
rem   drag a .v file onto it  -> open that file
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scratchverilog.ps1" %*
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" pause
endlocal & exit /b %RC%
