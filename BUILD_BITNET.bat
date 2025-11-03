@echo off
REM ============================================
REM Build BitNet Backend
REM ============================================

echo.
echo ============================================
echo Building BitNet Backend
echo ============================================
echo.
echo This will take 10-15 minutes...
echo.

cd bitnet_backend

REM Check for CMake
where cmake >nul 2>&1
if errorlevel 1 (
    echo ERROR: CMake not found!
    echo.
    echo Please install CMake from: https://cmake.org/download/
    echo.
    pause
    exit /b 1
)

REM Check for MinGW or MSVC
where g++ >nul 2>&1
if errorlevel 1 (
    where cl >nul 2>&1
    if errorlevel 1 (
        echo ERROR: No C++ compiler found!
        echo.
        echo Please install one of:
        echo - MinGW: https://www.mingw-w64.org/
        echo - Visual Studio Build Tools
        echo.
        pause
        exit /b 1
    )
    set GENERATOR="Visual Studio"
) else (
    set GENERATOR="MinGW Makefiles"
)

REM Create build directory
if not exist "build_mingw" mkdir build_mingw

REM Configure
echo Configuring build...
cmake -B build_mingw -G %GENERATOR% -DCMAKE_BUILD_TYPE=Release

if errorlevel 1 (
    echo.
    echo ERROR: CMake configuration failed!
    pause
    exit /b 1
)

REM Build
echo.
echo Building... (this takes ~10 minutes)
cmake --build build_mingw --config Release -j 4

if errorlevel 1 (
    echo.
    echo ERROR: Build failed!
    pause
    exit /b 1
)

echo.
echo ============================================
echo ✓ BitNet backend built successfully!
echo ============================================
echo.
echo Binary location: bitnet_backend\build_mingw\bin\llama-server.exe
echo.
echo Next: Run START_BITNET.bat to start the server
echo.
pause
