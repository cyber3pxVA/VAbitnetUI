@echo off
REM ============================================
REM Run VAbitnetUI Application
REM ============================================

REM Check if venv exists
if not exist "venv" (
    echo.
    echo ERROR: Virtual environment not found!
    echo.
    echo Please run INSTALL.bat first to set up the application.
    echo.
    pause
    exit /b 1
)

REM Activate venv and run
call venv\Scripts\activate.bat
python main.py

REM Keep window open if there's an error
if errorlevel 1 (
    echo.
    echo The application closed with an error.
    echo Check the error message above.
    pause
)
