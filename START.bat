@echo off
REM Simple startup script for VAbitnetUI
REM Starts the BitNet server and opens web UI in browser

title VAbitnetUI - Starting BitNet Server

echo.
echo ===================================================
echo  VAbitnetUI - BitNet 1.58-bit LLM
echo ===================================================
echo.
echo Starting BitNet inference server...
echo.
echo Model: bitnet_b1_58-large (1.2GB, i2_s format)
echo Port: 8081
echo.
echo Loading model (this takes 10-20 seconds)...
echo.

cd bitnet_backend

REM Start the server in background
REM -n 256 limits output to 256 tokens (~200 words). Adjust higher/lower as needed.
start /B "BitNet Server" build_mingw\bin\llama-server.exe -m models\bitnet_b1_58-large\ggml-model-i2_s.gguf --port 8081 --host 127.0.0.1 -c 2048 -n 256 -t 4

REM Wait for server to load
timeout /t 15 /nobreak >nul

echo.
echo ===================================================
echo  Server Ready!
echo ===================================================
echo.
echo Web UI: http://127.0.0.1:8081
echo.
echo Opening web browser...
echo.

REM Open browser to web UI
start http://127.0.0.1:8081

echo.
echo ===================================================
echo  Server is running in background
echo ===================================================
echo.
echo - Chat via browser at http://127.0.0.1:8081
echo - Close this window to keep server running
echo - Or press Ctrl+C to stop the server
echo.
echo Optional: Run "python main.py" for GUI with voice transcription
echo.

pause
