@echo off
REM ============================================
REM VAbitnetUI Easy Installer for VA Workstations
REM No technical knowledge required!
REM ============================================

echo.
echo ========================================
echo    VAbitnetUI Installation Wizard
echo    For VA Windows Workstations
echo ========================================
echo.
echo This will:
echo  1. Create a safe Python environment (venv)
echo  2. Install all required packages
echo  3. Download speech recognition model
echo  4. Set up the application
echo.
pause

REM Check if Python is installed
echo.
echo [Step 1/5] Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Python is not installed!
    echo.
    echo Please install Python 3.10 or newer from:
    echo https://www.python.org/downloads/
    echo.
    echo Make sure to check "Add Python to PATH" during installation!
    pause
    exit /b 1
)
echo ✓ Python is installed
echo.

REM Create virtual environment
echo [Step 2/5] Creating safe Python environment (venv)...
if exist "venv" (
    echo   Virtual environment already exists, skipping...
) else (
    python -m venv venv
    if errorlevel 1 (
        echo.
        echo ERROR: Could not create virtual environment
        echo This might mean Python venv module is missing
        pause
        exit /b 1
    )
    echo ✓ Virtual environment created
)
echo.

REM Activate virtual environment
echo [Step 3/5] Activating virtual environment...
call venv\Scripts\activate.bat
if errorlevel 1 (
    echo.
    echo ERROR: Could not activate virtual environment
    pause
    exit /b 1
)
echo ✓ Virtual environment activated
echo.

REM Upgrade pip
echo [Step 4/5] Updating package installer (pip)...
python -m pip install --upgrade pip --quiet
echo ✓ Pip updated
echo.

REM Install requirements
echo [Step 5/5] Installing application packages...
echo This may take 5-10 minutes depending on your internet speed...
echo.
pip install -r requirements.txt
if errorlevel 1 (
    echo.
    echo ERROR: Could not install required packages
    echo Check your internet connection and try again
    pause
    exit /b 1
)
echo ✓ All packages installed
echo.

REM Download VOSK model
echo [Bonus Step] Downloading speech recognition model...
echo This is a large file (40+ MB) and may take a few minutes...
echo.
python src/core/download_vosk.py
if errorlevel 1 (
    echo.
    echo WARNING: Could not download VOSK model automatically
    echo You may need to download it manually later
    echo.
)
echo.

echo ========================================
echo    Installation Complete!
echo ========================================
echo.
echo Next steps:
echo  1. Close this window
echo  2. Double-click "RUN_APP.bat" to start the application
echo.
echo If you need to reinstall, just run this script again.
echo.
pause
