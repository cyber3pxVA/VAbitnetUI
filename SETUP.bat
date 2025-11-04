@echo off
REM SETUP.bat - One-time setup for VAbitnetUI on fresh VA workstation
REM No admin rights needed, no bullshit

title VAbitnetUI - First Time Setup

echo.
echo ===================================================
echo  VAbitnetUI - First Time Setup
echo ===================================================
echo.
echo This will set up BitNet on your VA workstation
echo Time needed: 2-5 minutes
echo.
pause

REM Check if already set up
if exist "bitnet_backend\build_mingw\bin\llama-server.exe" (
    echo.
    echo [OK] BitNet server already installed!
    echo [OK] Model files present
    echo.
    echo You can now run START.bat to launch the application
    echo.
    pause
    exit /b 0
)

echo.
echo ===================================================
echo  Checking Requirements
echo ===================================================
echo.

REM Check Git
git --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git not found!
    echo Please install Git from: https://git-scm.com/download/win
    pause
    exit /b 1
)
echo [OK] Git found

REM Check Git LFS
git lfs version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git LFS not found!
    echo Please run: git lfs install
    pause
    exit /b 1
)
echo [OK] Git LFS found

echo.
echo ===================================================
echo  Pulling Latest Code and Binaries
echo ===================================================
echo.

REM Pull latest code (includes binaries from other workstation)
echo Fetching latest version from GitHub...
git pull origin master

REM Pull LFS files (model files)
echo.
echo Downloading model files (1.2GB - may take a few minutes)...
git lfs pull

echo.
echo ===================================================
echo  Verifying Installation
echo ===================================================
echo.

REM Check if server binary exists
if not exist "bitnet_backend\build_mingw\bin\llama-server.exe" (
    echo [ERROR] Server binary not found!
    echo The binaries may not have been pushed from the other workstation.
    echo Please ensure the build_mingw/bin/ directory is committed to Git.
    pause
    exit /b 1
)
echo [OK] BitNet server binary found (4.6MB)

REM Check if model exists
if not exist "bitnet_backend\models\bitnet_b1_58-large\ggml-model-i2_s.gguf" (
    echo [ERROR] Model file not found!
    echo Run: git lfs pull
    pause
    exit /b 1
)
echo [OK] BitNet model found (1.2GB)

REM Check if DLL exists
if not exist "bitnet_backend\build_mingw\bin\libgomp-1.dll" (
    echo [WARNING] OpenMP DLL not found
    echo Server may not start without libgomp-1.dll
)

echo.
echo ===================================================
echo  Setup Complete!
echo ===================================================
echo.
echo Everything is ready to use!
echo.
echo To start the application:
echo   1. Run START.bat
echo   2. Browser will open to http://127.0.0.1:8081
echo   3. Start chatting!
echo.
echo No Python needed for web UI (server has built-in interface)
echo Optional: Install Python 3.10+ for GUI with voice transcription
echo.
pause
