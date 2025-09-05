# Flutter Setup for Windows - BidWar Project

## Quick Setup (Recommended)

### Option 1: Using PowerShell Script (Automated)
1. **Run PowerShell as Administrator**
2. **Execute the setup script:**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   .\install_flutter_windows.ps1
   ```

### Option 2: Using Batch File
1. **Double-click** `install_flutter_windows.bat`
2. **Follow the on-screen instructions**

## Manual Setup (If scripts fail)

### Step 1: Download Flutter SDK
1. Go to https://docs.flutter.dev/get-started/install/windows
2. Download the Flutter SDK zip file (latest stable version)
3. Extract to `C:\flutter` (create this directory if it doesn't exist)

### Step 2: Add Flutter to PATH
1. **Open System Environment Variables:**
   - Press `Win + R`, type `sysdm.cpl`, press Enter
   - Click "Environment Variables"
   - Under "User variables", select "Path" and click "Edit"
   - Click "New" and add: `C:\flutter\bin`
   - Click "OK" to save

2. **Alternative method (PowerShell):**
   ```powershell
   [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\flutter\bin", [EnvironmentVariableTarget]::User)
   ```

### Step 3: Verify Installation
1. **Open a new Command Prompt or PowerShell**
2. **Run:** `flutter --version`
3. **You should see Flutter version information**

### Step 4: Install Project Dependencies
1. **Navigate to your project directory:**
   ```cmd
   cd C:\Users\khamis\bidwar-1
   ```
2. **Install dependencies:**
   ```cmd
   flutter pub get
   ```

### Step 5: Run Flutter Doctor
```cmd
flutter doctor
```

## Troubleshooting

### Error: 'flutter' is not recognized
- **Cause:** Flutter is not in your system PATH
- **Solution:** Follow Step 2 above to add Flutter to PATH, then restart your terminal

### Error: Target of URI doesn't exist: 'package:flutter/material.dart'
- **Cause:** Flutter SDK not installed or dependencies not fetched
- **Solution:** Complete all steps above, especially `flutter pub get`

### Error: Android toolchain issues
- **Install Android Studio:** https://developer.android.com/studio
- **Run:** `flutter doctor --android-licenses`

### Error: No connected devices
- **For physical device:** Enable USB debugging
- **For emulator:** Create an Android Virtual Device in Android Studio

## Project-Specific Configuration

### Environment Variables
This project uses environment variables defined in `env.json`. Make sure you have:
```json
{
  "SUPABASE_URL": "your_supabase_url",
  "SUPABASE_ANON_KEY": "your_supabase_anon_key"
}
```

### Required Dependencies
The project requires these key dependencies (already in pubspec.yaml):
- `flutter: sdk: flutter` - Core Flutter framework
- `google_fonts: ^6.1.0` - Typography system
- `sizer: ^2.0.15` - Responsive design
- `supabase_flutter: ^2.9.1` - Backend integration

## Next Steps After Setup

1. **Verify everything works:**
   ```cmd
   flutter doctor -v
   ```

2. **Run the project:**
   ```cmd
   flutter run
   ```

3. **Build APK (if needed):**
   ```cmd
   flutter build apk --release
   ```

## IDE Configuration

### VS Code
Install these extensions:
- Flutter (Dart-Code.flutter)
- Dart (Dart-Code.dart-code)

### Android Studio
- Flutter plugin should be automatically available

## Memory Requirements [[memory:8212412]]
Remember that this is a **BidWar auction app** built with:
- **Flutter (>= 3.29.2)** with Dart
- **Supabase** for Auth + DB + Realtime
- **Riverpod** for state management (if needed)
- **Clean Architecture** with features: auth, auctions, bids, profile, notifications, watchlist
