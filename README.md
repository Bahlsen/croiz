# Croiz - French Crossword Game

[![CI](https://github.com/Bahlsen/croiz/actions/workflows/ci.yml/badge.svg)](https://github.com/Bahlsen/croiz/actions/workflows/ci.yml)

A modern mobile crossword game built with Flutter and Spring Boot, featuring real-time gameplay, user authentication, and comprehensive scoring systems.

## Project Structure

```
croiz/
├── frontend/          # Flutter mobile application (Riverpod state management)
├── backend/           # Spring Boot REST API
├── shared/            # Shared models and constants
├── tools/             # Python puzzle generation scripts
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

### Backend
- **Framework**: Spring Boot 4.0.1
- **Language**: Java 21 LTS
- **Database**: PostgreSQL + Flyway migrations
- **Security**: Spring Security + JWT
- **Build Tool**: Gradle
- **Code Quality**: Spotless, JaCoCo
- **Testing**: JUnit 5, Mockito, Spring Security Test, H2 (in-memory)

## Quick Start

### Prerequisites
- Flutter 3.19+ with Dart 3.10+
- Java 21 LTS
- PostgreSQL 14+
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

### Backend Setup

```powershell
# Navigate to backend directory
cd backend

# Run the application
.\gradlew bootRun

# Run tests
.\gradlew test

# Run with code coverage
.\gradlew jacocoTestReport

# Check code formatting
.\gradlew spotlessCheck

# Apply code formatting
.\gradlew spotlessApply
```

### Puzzle Generation

```powershell
# Navigate to tools directory
cd tools

# Install Python dependencies
pip install -r requirements.txt

# Generate a puzzle
python generate_puzzle.py
```

## Testing

### Unit Tests
```powershell
# Frontend
cd frontend
flutter test

# Backend
cd backend
.\gradlew test
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

# Backend
cd backend
.\gradlew jacocoTestReport
# Report available at: backend/build/jacocoHtml/index.html
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
4. Select the branch (main or develop)
5. Click "Run workflow" to start the build and distribution

The APK will be automatically uploaded to Firebase App Distribution and made available to the "testers" group.

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

## Project Resources

- [Contributing Guidelines](CONTRIBUTING.md)
- [Quick Reference](QUICK_REFERENCE.md)
- [Initialization Guide](INITIALIZATION.md)

## License

Private repository - All rights reserved
