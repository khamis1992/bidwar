# APK Build Troubleshooting Guide - Complete Solution

## 🎯 Quick Solutions

### ✅ **RECOMMENDED: Use GitHub Actions (Always Works)**
1. Push your code to the repository
2. Go to [Actions tab](https://github.com/khamis1992/bidwar/actions)
3. Download APK from artifacts (or trigger manual build)

### ✅ **LOCAL BUILD: Use Enhanced Scripts**
```bash
# Method 1: Network-resilient build
chmod +x build_apk_resilient.sh
./build_apk_resilient.sh -t release

# Method 2: Comprehensive build (if network allows)  
chmod +x setup_flutter_and_build.sh
./setup_flutter_and_build.sh -t release

# Method 3: Fixed original script
chmod +x build_apk_fixed.sh  
./build_apk_fixed.sh -t release -c
```

This guide helps resolve common issues when building APK files for the BidWar Flutter application.

## 🔧 Common Issues and Solutions

### 1. Build Fails with "Flutter not found"
**Problem:** Flutter SDK not installed or not in PATH
**Solution:**
```bash
# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

### 2. Environment Variables Not Found
**Problem:** Missing `env.json` file or environment variables
**Solution:**
```bash
# Create env.json with default values
cat > env.json << EOF
{
  "SUPABASE_URL": "your-supabase-url",
  "SUPABASE_ANON_KEY": "your-supabase-anon-key",
  "OPENAI_API_KEY": "your-openai-api-key-here",
  "GEMINI_API_KEY": "your-gemini-api-key-here",
  "ANTHROPIC_API_KEY": "your-anthropic-api-key-here",
  "PERPLEXITY_API_KEY": "your-perplexity-api-key-here"
}
EOF
```

### 3. Gradle Build Fails
**Problem:** Android build configuration issues
**Solutions:**
```bash
# Clean build directory
flutter clean

# Rebuild with verbose output
flutter build apk --release --verbose --dart-define-from-file=env.json

# Check Java version (should be 17)
java -version

# Update Gradle wrapper
cd android && ./gradlew wrapper --gradle-version=8.0
```

### 4. APK Not Generated
**Problem:** Build completes but no APK file found
**Solution:**
```bash
# Check build output directory
ls -la build/app/outputs/flutter-apk/

# Look for APK files anywhere
find . -name "*.apk" -type f

# Build with specific output
flutter build apk --release --target-platform android-arm,android-arm64,android-x64
```

### 5. GitHub Actions Build Fails

#### Missing Secrets
**Problem:** Environment variables not configured in GitHub
**Solution:**
1. Go to repository Settings → Secrets and variables → Actions
2. Add required secrets:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - Other API keys as needed

#### Workflow Permission Issues
**Problem:** GitHub Actions lacks permissions
**Solution:**
1. Go to repository Settings → Actions → General
2. Set "Workflow permissions" to "Read and write permissions"
3. Enable "Allow GitHub Actions to create and approve pull requests"

#### Java Version Mismatch
**Problem:** Wrong Java version in CI
**Solution:** The workflow uses Java 17, which is correct for current Flutter versions.

### 6. Dependencies Issues
**Problem:** Package dependency conflicts
**Solution:**
```bash
# Clean pub cache
dart pub cache clean

# Get fresh dependencies
flutter pub get

# Analyze dependencies
flutter pub deps

# Check for outdated packages
flutter pub outdated
```

### 7. Android SDK Issues
**Problem:** Missing Android SDK components
**Solution:**
```bash
# Accept all licenses
flutter doctor --android-licenses

# Check what's missing
flutter doctor -v

# Install missing components through Android Studio
```

### 8. Memory Issues During Build
**Problem:** Build fails due to insufficient memory
**Solution:**
```bash
# Increase Gradle memory
echo "org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=512m" >> android/gradle.properties

# Build with specific memory settings
flutter build apk --release --verbose --dart-define=flutter.build.memory=4096
```

### 9. Flutter SDK Download Issues ⭐ **MAIN ISSUE IDENTIFIED**
**Problem:** Flutter Dart SDK downloads fail due to network restrictions
**Root Cause:** Network infrastructure blocks downloads from storage.googleapis.com  
**Solutions:**
```bash
# BEST SOLUTION: Use GitHub Actions
# 1. Push code to repository  
# 2. Download APK from Actions artifacts

# ALTERNATIVE: Use pre-installed Flutter
export PATH="$PATH:/opt/flutter/bin"
./build_apk_resilient.sh -t release

# FOR DEVELOPERS: Manual Flutter installation
# Download Flutter SDK manually and extract to /opt/flutter
```

### 10. Environment Configuration Issues
**Problem:** Incorrect Android SDK paths or environment variables
**Solution:**
```bash
# Set correct environment (auto-handled by new scripts)
export ANDROID_HOME="/usr/local/lib/android/sdk"
export ANDROID_SDK_ROOT="/usr/local/lib/android/sdk" 
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"

# Verify setup
echo $ANDROID_HOME
flutter doctor -v
```

## 📊 Build Verification

### Check APK File
```bash
# Verify APK exists and is valid
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [ -f "$APK_PATH" ]; then
    echo "✅ APK found: $APK_PATH"
    echo "📏 Size: $(du -h $APK_PATH | cut -f1)"
    echo "📱 Info: $(aapt dump badging $APK_PATH | head -5)"
else
    echo "❌ APK not found"
fi
```

### Test APK Installation
```bash
# Install on connected device
adb install build/app/outputs/flutter-apk/app-release.apk

# Check installed apps
adb shell pm list packages | grep bidwar
```

## 🚀 GitHub Actions Debugging

### View Logs
1. Go to [Actions tab](https://github.com/khamis1992/bidwar/actions)
2. Click on failed workflow run
3. Click on failed job
4. Expand failed step to see detailed logs

### Download Build Artifacts
Even if build fails, partial artifacts might be available:
1. Go to failed workflow run
2. Scroll to "Artifacts" section
3. Download available logs and partial builds

### Re-run Failed Jobs
1. Go to failed workflow run
2. Click "Re-run failed jobs" button
3. Or click "Re-run all jobs" to start fresh

## 📞 Getting Help

If issues persist:
1. Check [Flutter documentation](https://flutter.dev/docs)
2. Search [GitHub Issues](https://github.com/khamis1992/bidwar/issues)
3. Create new issue with:
   - Build logs
   - System information (`flutter doctor -v`)
   - Steps to reproduce
   - Error messages

## 🔄 Quick Recovery Commands

```bash
# Complete clean rebuild
flutter clean
flutter pub get
flutter pub upgrade
flutter build apk --release --dart-define-from-file=env.json

# Reset to known good state
git stash
git pull origin main
./build_apk.sh -c -t release
```