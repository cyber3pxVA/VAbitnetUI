@echo off
REM ============================================
REM Start BitNet Backend Server
REM ============================================

echo.
echo ============================================
echo Starting BitNet Backend Server
echo ============================================
echo.

REM Check if build exists
if not exist "bitnet_backend\build_mingw\bin\llama-server.exe" (
    echo ERROR: BitNet backend not built yet!
    echo.
    echo Run BUILD_BITNET.bat first to compile the backend.
    echo.
    pause
    exit /b 1
)

REM Start the server
cd bitnet_backend
echo Starting server on http://localhost:8081...
echo.
echo Press Ctrl+C to stop the server
echo.

build_mingw\bin\llama-server.exe ^
    -m models\bitnet_b1_58-large\ggml-model-i2_s.gguf ^
    --host 127.0.0.1 ^
    --port 8081 ^
    -c 2048 ^
    -t 4

echo.
echo Server stopped.
pause
