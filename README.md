# BidWar

[![Build APK](https://github.com/khamis1992/bidwar/actions/workflows/build-apk.yml/badge.svg)](https://github.com/khamis1992/bidwar/actions/workflows/build-apk.yml)
[![CI/CD Pipeline](https://github.com/khamis1992/bidwar/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/khamis1992/bidwar/actions/workflows/ci-cd.yml)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.24.5-blue.svg)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-3.6.0-blue.svg)](https://dart.dev/)

A modern Flutter-based mobile application utilizing the latest mobile development technologies and tools for building responsive cross-platform applications.

## 📋 Prerequisites

- Flutter SDK (^3.29.2)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android SDK / Xcode (for iOS development)

## 🛠️ Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run the application:

To run the app with environment variables defined in an env.json file, follow the steps mentioned below:
1. Through CLI
    ```bash
    flutter run --dart-define-from-file=env.json
    ```
2. For VSCode
    - Open .vscode/launch.json (create it if it doesn't exist).
    - Add or modify your launch configuration to include --dart-define-from-file:
    ```json
    {
        "version": "0.2.0",
        "configurations": [
            {
                "name": "Launch",
                "request": "launch",
                "type": "dart",
                "program": "lib/main.dart",
                "args": [
                    "--dart-define-from-file",
                    "env.json"
                ]
            }
        ]
    }
    ```
3. For IntelliJ / Android Studio
    - Go to Run > Edit Configurations.
    - Select your Flutter configuration or create a new one.
    - Add the following to the "Additional arguments" field:
    ```bash
    --dart-define-from-file=env.json
    ```

## 📁 Project Structure

```
flutter_app/
├── android/            # Android-specific configuration
├── ios/                # iOS-specific configuration
├── lib/
│   ├── core/           # Core utilities and services
│   │   └── utils/      # Utility classes
│   ├── presentation/   # UI screens and widgets
│   │   └── splash_screen/ # Splash screen implementation
│   ├── routes/         # Application routing
│   ├── theme/          # Theme configuration
│   ├── widgets/        # Reusable UI components
│   └── main.dart       # Application entry point
├── assets/             # Static assets (images, fonts, etc.)
├── pubspec.yaml        # Project dependencies and configuration
└── README.md           # Project documentation
```

## 🧩 Adding Routes

To add new routes to the application, update the `lib/routes/app_routes.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:package_name/presentation/home_screen/home_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String home = '/home';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
    // Add more routes as needed
  }
}
```

## 🎨 Theming

This project includes a comprehensive theming system with both light and dark themes:

```dart
// Access the current theme
ThemeData theme = Theme.of(context);

// Use theme colors
Color primaryColor = theme.colorScheme.primary;
```

The theme configuration includes:
- Color schemes for light and dark modes
- Typography styles
- Button themes
- Input decoration themes
- Card and dialog themes

## 📱 Responsive Design

The app is built with responsive design using the Sizer package:

```dart
// Example of responsive sizing
Container(
  width: 50.w, // 50% of screen width
  height: 20.h, // 20% of screen height
  child: Text('Responsive Container'),
)
```
## 📦 Deployment

### Automated APK Builds with GitHub Actions

The project now includes automated APK building through GitHub Actions:

#### 🤖 Automatic Builds
- **Push to main/develop**: Automatically triggers APK builds
- **Pull Requests**: Builds APKs and adds download links to PR comments
- **Manual Trigger**: Use GitHub Actions UI to build on-demand
- **Nightly Builds**: Scheduled builds every night at 2 AM UTC

#### 📱 Build Types
- **Debug APK**: Includes debugging symbols, larger size
- **Release APK**: Optimized for production, smaller size

#### 🚀 How to Get APK Files

**Method 1: GitHub Actions (Recommended)**
1. Go to the [Actions tab](https://github.com/khamis1992/bidwar/actions)
2. Click on the latest "Build APK" or "CI/CD Pipeline" workflow run
3. Scroll down to "Artifacts" section
4. Download the APK file (artifacts are kept for 30 days)

**Method 2: Manual Build Trigger**
1. Go to the [Actions tab](https://github.com/khamis1992/bidwar/actions)
2. Click on "Build APK" workflow
3. Click "Run workflow" button
4. Select build type (debug/release) and click "Run workflow"
5. Wait for completion and download from artifacts

**Method 3: Local Build Script**
```bash
# Build release APK locally
./build_apk.sh

# Build debug APK
./build_apk.sh -t debug

# Clean build
./build_apk.sh -c -t release

# Verbose output
./build_apk.sh -v -t release
```

#### 📋 Manual Build Commands

**Method 1: Comprehensive Build (Recommended)**
```bash
# All-in-one build script with Flutter installation
chmod +x setup_flutter_and_build.sh
./setup_flutter_and_build.sh -t release

# Debug build
./setup_flutter_and_build.sh -t debug -c -v
```

**Method 2: Network-Resilient Build**
```bash
# Works even with network restrictions
chmod +x build_apk_resilient.sh
./build_apk_resilient.sh -t release

# Clean debug build  
./build_apk_resilient.sh -c -t debug
```

**Method 3: Traditional Flutter Commands**
```bash
# Install dependencies
flutter pub get

# Build debug APK
flutter build apk --debug --dart-define-from-file=env.json

# Build release APK  
flutter build apk --release --dart-define-from-file=env.json --android-skip-build-dependency-validation

# For iOS (macOS only)
flutter build ios --release --dart-define-from-file=env.json
```

**Method 4: Fixed Build Scripts**
```bash
# Enhanced version of original script
chmod +x build_apk_fixed.sh
./build_apk_fixed.sh -t release -c

# With verbose output
./build_apk_fixed.sh -t debug -v
```

#### 🔧 Environment Configuration
The build system automatically handles environment variables:
- Uses `env.json` for local builds
- Uses GitHub Secrets for CI/CD builds
- Falls back to default values if secrets not configured

#### 📊 Build Features
- **Automated Testing**: Runs tests before building
- **Code Analysis**: Checks code quality
- **Build Caching**: Faster subsequent builds
- **Artifact Management**: Organized file naming with timestamps
- **Build Reports**: Detailed build summaries and logs
- **PR Integration**: Automatic APK links in pull request comments

## 🙏 Acknowledgments
- Built with [Rocket.new](https://rocket.new)
- Powered by [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
- Styled with Material Design

Built with ❤️ on Rocket.new
