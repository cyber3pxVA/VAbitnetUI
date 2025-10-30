@echo off
REM ============================================
REM Quick Test - Verify Installation
REM ============================================

echo.
echo Testing VAbitnetUI Installation...
echo.

if not exist "venv" (
    echo ERROR: Virtual environment not found!
    echo Please run INSTALL.bat first.
    pause
    exit /b 1
)

call venv\Scripts\activate.bat

echo Testing core modules...
python -c "from src.core.errors import APIError, ErrorCode; print('  ✓ Core errors module')"
if errorlevel 1 goto :error

python -c "from src.core.models import ProcessingRequest, ProcessingResult; print('  ✓ Core models module')"
if errorlevel 1 goto :error

python -c "from src.core.config import Config; print('  ✓ Core config module')"
if errorlevel 1 goto :error

echo.
echo Testing infrastructure...
python -c "from src.infrastructure.http_client import BitNetHTTPClient; print('  ✓ HTTP client module')"
if errorlevel 1 goto :error

echo.
echo Testing services...
python -c "from src.services.inference_service import InferenceService; print('  ✓ Inference service')"
if errorlevel 1 goto :error

python -c "from src.services.chat_service import ChatService; print('  ✓ Chat service')"
if errorlevel 1 goto :error

echo.
echo ========================================
echo    All Tests Passed! ✓
echo ========================================
echo.
echo Your installation is working correctly.
echo You can now run RUN_APP.bat to start the application.
echo.
pause
exit /b 0

:error
echo.
echo ========================================
echo    Test Failed!
echo ========================================
echo.
echo Some modules are not working correctly.
echo Try running INSTALL.bat again.
echo.
pause
exit /b 1
