# Croiz - French Crossword Game

[![CI](https://github.com/Bahlsen/croiz/actions/workflows/ci.yml/badge.svg)](https://github.com/Bahlsen/croiz/actions/workflows/ci.yml)


## Project Structure

```
croiz/
├── frontend/          # Flutter mobile application (Riverpod state management)
├── shared/            # Shared models and constants
├── tools/             # Legacy/Utility scripts (Python)
├── .github/workflows/ # CI/CD pipelines
└── docs/              # Project documentation
```

## Tech Stack

### Frontend
- **Framework**: Flutter 3.19+ (Dart 3.10+)
- **State Management**: Riverpod 2.4
- **Routing**: GoRouter 12.0
- **HTTP Client**: Dio 5.3
- **Local Storage**: Sqflite + flutter_secure_storage
- **UI**: Google Fonts, Flutter SVG
- **Testing**: flutter_test, mockito, mocktail, golden_toolkit



## Quick Start

### Prerequisites
- Flutter 3.19+ with Dart 3.10+
- Java 17 (for Android build)
- Git
- Android SDK (for mobile development)

### Frontend Setup

```powershell
# Navigate to frontend directory
cd frontend

# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage
```



### Puzzle Generation
 
The project now features a robust **In-App Generation Engine v3.0** (Dart):
- **Grid-First Architecture**: Uses CSP solver and GADDAG for high-quality grids.
- **On-Device**: No backend required for generation.
- **Multilingual**: Supports English, French, Spanish, German, etc.

 Legacy Python scripts are in `tools/` but the core generation is now in `frontend/features/generation/`.

## Testing

### Unit Tests
```powershell
# Frontend
cd frontend
flutter test


```

### Integration Tests
```powershell
# Frontend (requires connected device/emulator)
cd frontend
flutter test integration_test/

# Run on specific device
flutter test integration_test/ -d <device-id>
```

### Coverage Reports
```powershell
# Frontend
cd frontend
flutter test --coverage
dart run tools/compute_coverage.dart


```

## CI/CD

The project uses GitHub Actions for continuous integration and deployment:

- **ci.yml**: Main CI pipeline (lint, test, build)
- **api-tests.yml**: Backend API tests
- **integration-tests.yml**: Frontend integration tests
- **firebase-distribution.yml**: Manual Firebase App Distribution (triggered via GitHub Actions UI)
- **deploy.yml**: Deployment pipeline

### Firebase Distribution

To distribute the app to testers via Firebase:

1. Go to the Actions tab in GitHub
2. Select "Firebase App Distribution" workflow
3. Click "Run workflow"
4. Select the platform:
   - **android**: Build and distribute Android APK
   - **ios**: Build and distribute iOS IPA
   - **both**: Build and distribute both platforms
5. Click "Run workflow" to start the build and distribution

The builds will be automatically uploaded to Firebase App Distribution and made available to the "testers" group.

**Note:** iOS distribution requires an Apple Developer account (paid) and signing setup. See [iOS Firebase Setup](docs/ios-firebase-setup.md) and the [iOS Checklist](docs/ios-setup-checklist.md).

## Documentation

- [Architecture](docs/architecture.md) - System design and architecture overview
- [API Documentation](docs/api.md) - REST API endpoints and specifications
- [Setup Guide](docs/setup.md) - Detailed setup instructions
- [Testing Strategy](docs/testing.md) - Testing approach and guidelines
- [Puzzle System](docs/puzzle-system.md) - Crossword puzzle mechanics
- [Puzzle Schema](docs/puzzle-schema.md) - Puzzle data structure
- [Puzzle Creation Guide](docs/puzzle-creation-guide.md) - How to create puzzles
- [Firebase Setup](docs/firebase-setup.md) - Firebase configuration
- [Firebase Credentials](docs/firebase-credentials.md) - Credentials management
- [iOS Firebase Setup](docs/ios-firebase-setup.md) - iOS App Distribution configuration

## Project Resources

- [Documentation Map](DOCS_MAP.md) - Complete overview of all documentation
- [Changelog](CHANGELOG.md) - Version history and release notes
- [Contributing Guidelines](CONTRIBUTING.md) - How to contribute to the project
- [Quick Reference](QUICK_REFERENCE.md) - Common commands and shortcuts
- [Initialization Guide](INITIALIZATION.md) - First-time setup guide

## License

Private repository - All rights reserved
