@echo off
REM ============================================
REM VAbitnetUI Auto Installer (No Prompts)
REM For automated deployment
REM ============================================

echo.
echo ========================================
echo    VAbitnetUI Auto Installation
echo ========================================
echo.

REM Check if Python is installed
echo [Step 1/5] Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed!
    echo Please install Python 3.10+ from https://www.python.org/downloads/
    exit /b 1
)
echo ✓ Python is installed
echo.

REM Create virtual environment
echo [Step 2/5] Creating virtual environment...
if exist "venv" (
    echo   Virtual environment already exists, skipping...
) else (
    python -m venv venv
    if errorlevel 1 (
        echo ERROR: Could not create virtual environment
        exit /b 1
    )
    echo ✓ Virtual environment created
)
echo.

REM Activate virtual environment
echo [Step 3/5] Activating virtual environment...
call venv\Scripts\activate.bat
if errorlevel 1 (
    echo ERROR: Could not activate virtual environment
    exit /b 1
)
echo ✓ Virtual environment activated
echo.

REM Upgrade pip
echo [Step 4/5] Updating pip...
python -m pip install --upgrade pip --quiet
echo ✓ Pip updated
echo.

REM Install requirements
echo [Step 5/5] Installing packages (this may take several minutes)...
pip install -r requirements.txt --quiet
if errorlevel 1 (
    echo ERROR: Could not install required packages
    exit /b 1
)
echo ✓ All packages installed
echo.

REM Download VOSK model
echo [Bonus] Downloading speech model...
python src/core/download_vosk.py
echo.

echo ========================================
echo    Installation Complete!
echo ========================================
echo.
echo Run "RUN_APP.bat" to start the application.
echo.
