@echo off
REM VAbitnetUI Complete System Startup
REM Starts BitNet backend server and UI in correct order

echo ========================================
echo  VAbitnetUI System Startup
echo ========================================
echo.

REM Check if venv exists
if not exist "venv\Scripts\python.exe" (
    echo ERROR: Virtual environment not found!
    echo Please run INSTALL.bat first.
    pause
    exit /b 1
)

REM Check if BitNet server is already running
netstat -ano | findstr ":8081" >nul 2>&1
if %ERRORLEVEL%==0 (
    echo WARNING: Port 8081 already in use. BitNet server may already be running.
    echo.
)

echo [1/2] Starting BitNet backend server...
cd bitnet_backend
start /B "" cmd /c "build_mingw\bin\llama-server.exe -m models\bitnet_b1_58-large\ggml-model-i2_s.gguf --host 127.0.0.1 --port 8081 -c 2048 -t 4 > server.log 2>&1"
cd ..

echo Waiting for server initialization (5 seconds)...
timeout /t 5 /nobreak >nul

REM Verify server started
netstat -ano | findstr ":8081" >nul 2>&1
if %ERRORLEVEL%==0 (
    echo [SUCCESS] BitNet server running on port 8081
) else (
    echo [ERROR] BitNet server failed to start!
    echo Check bitnet_backend\server.log for details
    pause
    exit /b 1
)

echo.
echo [2/2] Starting VAbitnetUI...
start "VAbitnetUI" venv\Scripts\pythonw.exe main.py

echo.
echo ========================================
echo  System Started Successfully!
echo ========================================
echo.
echo BitNet Server: http://127.0.0.1:8081
echo Server Log: bitnet_backend\server.log
echo.
echo To stop the system:
echo   1. Close the UI window
echo   2. Run: taskkill /F /IM llama-server.exe
echo.
echo Press any key to exit this window...
pause >nul
