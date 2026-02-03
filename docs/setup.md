# Croiz Project Setup Guide

Complete setup instructions for the Croiz crossword game project development environment.

## Prerequisites

### System Requirements

- **OS**: Windows 10+, macOS 11+, or Linux
- **Disk Space**: 5+ GB
- **RAM**: 8+ GB recommended

### Required Tools

#### Flutter Development
- **Flutter 3.x**
  - Download: https://flutter.dev/docs/get-started/install
  - Verify: `flutter --version`

#### Version Control
- **Git 2.30+**
  - Download: https://git-scm.com/downloads

#### IDEs
- **VS Code** (Recommended)
  - Extensions: Flutter, Dart, Awesome Flutter Snippets
- **Android Studio** (For Android emulator management)

## Installation Steps

### 1. Clone Repository

```bash
git clone https://github.com/yourusername/croiz.git
cd croiz
```

### 2. Project Setup

All project code is contained in the `frontend` directory.

```bash
cd frontend

# Get Flutter dependencies
flutter pub get

# Run code generation (for Riverpod, Drift, Freezed)
dart run build_runner build -d

# Verify setup
flutter doctor
```

## Running the Application

### Real Device (Recommended)
Connect your Android/iOS device via USB.

```bash
flutter run
```

### Emulators
```bash
# List available emulators
flutter emulators

# Launch an emulator
flutter emulators --launch <emulator_id>

# Run the app
flutter run
```

## Working with Code Generation

This project uses `build_runner` for:
- Riverpod (`riverpod_generator`)
- Freezed (`freezed`)
- Drift (`drift_dev`)
- JSON Serialization (`json_serializable`)

**One-time generation:**
```powershell
dart run build_runner build -d
```

**Watch mode (recommended during dev):**
```powershell
dart run build_runner watch -d
```

## Testing

### Run All Tests
```bash
flutter test
```

### Run Specific Test Type
```bash
# Unit tests
flutter test test/unit

# Widget tests
flutter test test/widget
```

### Integration Tests
```bash
flutter test integration_test/
```

## Common Issues & Troubleshooting

### "Missing generated files"
If you see errors about missing `.g.dart` or `.freezed.dart` files:
1. Stop any running instances.
2. Run `dart run build_runner build -d`.
3. If issues persist, try `flutter clean` then `flutter pub get` before regenerating.

### "CocoaPods not installed" (macOS)
If running on iOS/macOS:
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
```

### Code Style
We use standard Dart linting rules. Ensure your IDE is configured to format on save.
```bash
flutter analyze
```

---

**Last Updated**: February 2026
