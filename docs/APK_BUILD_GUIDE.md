# 📱 BidWar APK Build Guide

This guide explains how to build APK files for the BidWar Flutter application using GitHub Actions.

## 🚀 Automated APK Building

We have set up two GitHub Actions workflows for building APK files:

### 1. Basic APK Build (`build-apk.yml`)
**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` branch
- Manual workflow dispatch

**Features:**
- Automatic APK building on code changes
- Debug/Release build options
- Artifact upload
- Automatic releases for main branch pushes

### 2. Advanced APK Build (`advanced-build.yml`)
**Triggers:**
- Manual workflow dispatch only

**Features:**
- Full control over build type and versioning
- Release signing support (when configured)
- Detailed build information
- Custom release notes
- Build artifacts with retention

## 🔧 Manual APK Building

### Running the Build Workflow

1. **Go to GitHub Actions tab** in your repository
2. **Select "Advanced APK Build & Release"** workflow
3. **Click "Run workflow"**
4. **Configure options:**
   - **Build Type:** Choose `debug` or `release`
   - **Version Name:** e.g., `1.0.0` (optional)
   - **Create Release:** Check to create a GitHub release

### Build Types

#### Debug Build
- **Purpose:** Development and testing
- **Signing:** Debug keystore (automatic)
- **Size:** Larger (includes debug info)
- **Performance:** Slower (includes debugging)

#### Release Build
- **Purpose:** Production deployment
- **Signing:** Release keystore (requires setup)
- **Size:** Optimized and smaller
- **Performance:** Optimized for production

## 🔐 Release Signing Setup (Optional)

For production releases, you need to configure release signing:

### 1. Create a Keystore
```bash
keytool -genkey -v -keystore bidwar-release-key.keystore -alias bidwar -keyalg RSA -keysize 2048 -validity 10000
```

### 2. Configure GitHub Secrets
Go to Repository Settings → Secrets and Variables → Actions, and add:

- `ANDROID_KEYSTORE_BASE64`: Base64 encoded keystore file
- `ANDROID_STORE_PASSWORD`: Keystore password
- `ANDROID_KEY_PASSWORD`: Key password
- `ANDROID_SIGNING_KEY_ALIAS`: Key alias (e.g., "bidwar")

### 3. Encode Keystore
```bash
base64 -i bidwar-release-key.keystore | pbcopy  # macOS
base64 -w 0 bidwar-release-key.keystore        # Linux
```

## 🌍 Environment Variables

The build system uses the following environment variables:

### Required (Supabase)
- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Your Supabase anonymous key

### Optional (AI Services)
- `OPENAI_API_KEY`: OpenAI API key
- `GEMINI_API_KEY`: Google Gemini API key
- `ANTHROPIC_API_KEY`: Anthropic Claude API key
- `PERPLEXITY_API_KEY`: Perplexity AI API key

### Setting Environment Variables

1. **Go to Repository Settings → Secrets and Variables → Actions**
2. **Add each secret** with the appropriate value
3. **The workflow will automatically use these** or fall back to demo values

## 📦 APK Download & Installation

### From GitHub Actions
1. **Go to the Actions tab**
2. **Click on a completed workflow run**
3. **Download the APK from the Artifacts section**

### From GitHub Releases
1. **Go to the Releases section**
2. **Download the APK from the latest release**

### Installation on Android
1. **Enable "Install from unknown sources"** in Android settings
2. **Download the APK** to your device
3. **Tap the APK file** and follow installation prompts

## 🔍 Build Troubleshooting

### Common Issues

#### Build Fails with Dependencies Error
- **Solution:** Ensure all dependencies in `pubspec.yaml` are compatible
- **Check:** Run `flutter pub get` locally first

#### Environment Variables Not Working
- **Solution:** Verify all required secrets are set in GitHub
- **Check:** Ensure secret names match exactly (case-sensitive)

#### Release Signing Fails
- **Solution:** Verify keystore secrets are correct
- **Check:** Ensure keystore is properly base64 encoded

### Debug Steps
1. **Check Flutter Doctor** output in the workflow logs
2. **Review dependency installation** logs
3. **Examine build output** for specific errors
4. **Verify environment file** creation

## 📋 Build Information

Each APK build includes:
- **Version Code:** GitHub run number
- **Version Name:** From input or pubspec.yaml
- **Build Type:** Debug or Release
- **Commit SHA:** Source code commit
- **Flutter Version:** 3.24.3
- **Target Android SDK:** 34
- **Minimum Android SDK:** 23

## 🚀 Deployment Workflow

### Development Cycle
1. **Develop** features locally
2. **Push** to `develop` branch (auto-builds debug APK)
3. **Create PR** to `main` (builds and tests)
4. **Merge** to `main` (creates release)

### Release Process
1. **Run Advanced Build** workflow manually
2. **Choose Release** build type
3. **Set version** number
4. **Download** and test APK
5. **Distribute** to users

## 📱 APK Details

### Supported Architectures
- arm64-v8a (64-bit ARM)
- armeabi-v7a (32-bit ARM)
- x86_64 (64-bit Intel/AMD)

### Android Compatibility
- **Minimum:** Android 6.0 (API level 23)
- **Target:** Android 14 (API level 34)
- **Architecture:** Universal APK

### App Permissions
- `INTERNET`: For network connectivity
- Additional permissions as required by Flutter plugins

---

**Need help?** Check the [Issues](../../issues) page or create a new issue for build-related problems.