@echo off
echo BidWar Flutter Setup for Windows
echo ================================

REM Check if Flutter is already installed
where flutter >nul 2>&1
if %ERRORLEVEL% == 0 (
    echo Flutter is already installed:
    flutter --version
    goto :dependencies
)

echo Installing Flutter SDK...

REM Create Flutter directory
if not exist "C:\flutter" (
    mkdir "C:\flutter"
)

REM Download Flutter SDK (you'll need to do this manually or use PowerShell)
echo.
echo Please follow these steps:
echo 1. Go to https://docs.flutter.dev/get-started/install/windows
echo 2. Download the Flutter SDK zip file
echo 3. Extract it to C:\flutter
echo 4. Run this script again after extraction
echo.
pause

REM Check if Flutter was extracted
if not exist "C:\flutter\bin\flutter.bat" (
    echo Flutter SDK not found in C:\flutter\bin\
    echo Please extract the Flutter SDK to C:\flutter
    pause
    exit /b 1
)

:dependencies
echo.
echo Setting up Flutter dependencies...

REM Navigate to project directory
cd /d "%~dp0"

REM Get Flutter dependencies
echo Running flutter pub get...
flutter pub get

REM Run Flutter doctor
echo.
echo Running Flutter doctor to check setup...
flutter doctor

echo.
echo Setup complete! 
echo If there are any issues shown by flutter doctor, please address them.
pause
