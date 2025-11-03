@echo off
REM VAbitnetUI System Shutdown
REM Stops BitNet server and UI processes

echo ========================================
echo  VAbitnetUI System Shutdown
echo ========================================
echo.

echo Stopping BitNet server...
taskkill /F /IM llama-server.exe >nul 2>&1
if %ERRORLEVEL%==0 (
    echo [SUCCESS] BitNet server stopped
) else (
    echo [INFO] BitNet server not running
)

echo Stopping UI processes...
taskkill /F /IM python.exe >nul 2>&1
taskkill /F /IM pythonw.exe >nul 2>&1

echo.
echo ========================================
echo  System Stopped
echo ========================================
echo.
pause
