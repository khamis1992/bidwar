# BidWar Flutter Setup for Windows PowerShell Script
# Run this script as Administrator for best results

Write-Host "BidWar Flutter Setup for Windows" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# Check if Flutter is already installed
$flutterPath = Get-Command flutter -ErrorAction SilentlyContinue
if ($flutterPath) {
    Write-Host "Flutter is already installed:" -ForegroundColor Green
    flutter --version
} else {
    Write-Host "Installing Flutter SDK..." -ForegroundColor Yellow
    
    # Create Flutter directory
    $flutterDir = "C:\flutter"
    if (-not (Test-Path $flutterDir)) {
        New-Item -ItemType Directory -Path $flutterDir -Force
    }
    
    # Download Flutter SDK
    $flutterZipUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip"
    $flutterZipPath = "$env:TEMP\flutter_windows_stable.zip"
    
    Write-Host "Downloading Flutter SDK..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $flutterZipUrl -OutFile $flutterZipPath -UseBasicParsing
        Write-Host "Download completed!" -ForegroundColor Green
    } catch {
        Write-Host "Failed to download Flutter SDK. Please download manually from:" -ForegroundColor Red
        Write-Host "https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
        exit 1
    }
    
    # Extract Flutter SDK
    Write-Host "Extracting Flutter SDK..." -ForegroundColor Yellow
    try {
        Expand-Archive -Path $flutterZipPath -DestinationPath "C:\" -Force
        Write-Host "Extraction completed!" -ForegroundColor Green
    } catch {
        Write-Host "Failed to extract Flutter SDK" -ForegroundColor Red
        exit 1
    }
    
    # Add Flutter to PATH
    $currentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
    $flutterBinPath = "C:\flutter\bin"
    
    if ($currentPath -notlike "*$flutterBinPath*") {
        Write-Host "Adding Flutter to PATH..." -ForegroundColor Yellow
        $newPath = "$currentPath;$flutterBinPath"
        [Environment]::SetEnvironmentVariable("Path", $newPath, [EnvironmentVariableTarget]::User)
        $env:Path = "$env:Path;$flutterBinPath"
        Write-Host "Flutter added to PATH!" -ForegroundColor Green
    }
    
    # Clean up
    Remove-Item $flutterZipPath -ErrorAction SilentlyContinue
}

# Navigate to project directory
Set-Location $PSScriptRoot

# Get Flutter dependencies
Write-Host "`nRunning flutter pub get..." -ForegroundColor Yellow
try {
    flutter pub get
    Write-Host "Dependencies installed successfully!" -ForegroundColor Green
} catch {
    Write-Host "Failed to install dependencies. Please run 'flutter pub get' manually." -ForegroundColor Red
}

# Run Flutter doctor
Write-Host "`nRunning Flutter doctor to check setup..." -ForegroundColor Yellow
flutter doctor

Write-Host "`nSetup complete!" -ForegroundColor Green
Write-Host "If there are any issues shown by flutter doctor, please address them." -ForegroundColor Yellow
Write-Host "You may need to restart your terminal/IDE for PATH changes to take effect." -ForegroundColor Yellow
