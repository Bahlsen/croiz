# Croiz Project Setup Guide

Complete setup instructions for the Croiz crossword game project development environment.

## Prerequisites

### System Requirements

- **OS**: Windows 10+, macOS 11+, or Linux
- **Disk Space**: 10+ GB for all tools
- **RAM**: 8+ GB recommended

### Required Tools

#### Java Development
- **Java 17** (for Android builds)
  - Download: https://www.oracle.com/java/technologies/downloads/#java17
  - Verify: `java -version`

#### Flutter Development
- **Flutter 3.38+**
  - Download: https://flutter.dev/docs/get-started/install
  - Installation: Follow official guide for your OS
  - Verify: `flutter --version`

- **Dart 3.10+** (included with Flutter)
  - Verify: `dart --version`

#### Database


#### Version Control
- **Git 2.30+**
  - Download: https://git-scm.com/downloads
  - Configure: 
    ```bash
    git config --global user.name "Your Name"
    git config --global user.email "your.email@example.com"
    ```

#### IDEs (Choose one or both)
- **VS Code**
  - Extensions: Flutter, Dart, Java Extension Pack, REST Client
  
- **IntelliJ IDEA / Android Studio**
  - Plugins: Flutter, Dart, Gradle

## Installation Steps

### 1. Clone Repository

```bash
git clone https://github.com/yourusername/croiz.git
cd croiz
```

### 2. Frontend Setup

```bash
cd frontend

# Get Flutter dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build

# Verify setup
flutter doctor

# Run app on emulator
flutter run
```



## Development Environment Configuration

### VS Code Configuration

**`.vscode/settings.json`** (Create in project root):

```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.lineLength": 100,
  "editor.formatOnSave": true,
  "[dart]": {
    "editor.defaultFormatter": "Dart-Code.dart-code",
    "editor.formatOnSave": true
  },
  "[java]": {
    "editor.defaultFormatter": "redhat.java",
    "editor.formatOnSave": true
  },

}
```

### Environment Variables

**Create `.env` file** in project root (never commit):

```env
# Flutter
FLUTTER_ROOT=/path/to/flutter
```

**Load environment variables:**

```bash
# Linux/Mac
source .env

# Windows PowerShell
Get-Content .env | ForEach-Object {
  if ($_ -notmatch '^#') {
    $key, $value = $_.Split('=')
    [Environment]::SetEnvironmentVariable($key, $value)
  }
}
```

## Running the Applications

### Terminal 1: Frontend App

```bash
cd frontend

# For Android emulator
flutter run

# For iOS simulator (macOS only)
flutter run -d macos

# For web (development)
flutter run -d chrome

# With hot reload enabled (automatic)
```

## Testing

### Frontend Tests

```bash
cd frontend

# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/game_logic_test.dart

# Watch mode (re-run on changes)
flutter test --watch

# Generate coverage report
flutter test --coverage && open coverage/index.html
```



```bash
# In terminal, run Flutter integration tests
cd frontend
flutter test integration_test/
```

## Debugging

### Frontend Debugging

```bash
# Enable verbose logging
flutter run -v

# Debug mode with breakpoints
# In VS Code: Press F5 or click "Run and Debug"

# Use Flutter DevTools
flutter pub global activate devtools
devtools

# Access at: http://localhost:9101
```



## Troubleshooting

### Common Issues

#### Flutter: "Flutter SDK not found"
```bash
# Set Flutter path
export PATH="$PATH:/path/to/flutter/bin"
flutter doctor
```

#### Gradle: "Gradle command not found"
```bash
cd backend
chmod +x gradlew
./gradlew --version
```



```bash
# Flutter port (if applicable)
lsof -i :port
kill -9 <PID>
```

## Code Quality Tools

### Format Code

```bash
# Flutter
cd frontend
flutter analyze
```

## Useful Commands Reference

### Git Commands

```bash
# Create feature branch
git checkout -b feature/my-feature

# Make changes and commit
git add .
git commit -m "feat(game): add word validation"

# Push to remote
git push origin feature/my-feature

# Create pull request (via GitHub UI)

# Merge after approval
git checkout develop
git merge feature/my-feature
git push origin develop
```

### Flutter Commands

```bash
flutter pub get          # Install dependencies
flutter pub outdated     # Check for updates
flutter pub upgrade      # Upgrade dependencies
flutter clean            # Clean build artifacts
flutter doctor           # Check environment
flutter config           # View/set configuration
```



## Next Steps

1. **Read Architecture Docs**: `docs/architecture.md`
2. **API Documentation**: `docs/api.md`
3. **Contributing Guide**: `CONTRIBUTING.md`
4. **Create GitHub Repository**: Set to private, add collaborators
5. **Set Branch Protection**: Require PR reviews and CI/CD passing

## Getting Help

- **Flutter Docs**: https://flutter.dev/docs

- **GitHub Docs**: https://docs.github.com/en/repositories

## Support

For issues or questions:
1. Check documentation in `/docs`
2. Search existing GitHub issues
3. Create new issue with detailed description
4. Contact team lead

---

**Last Updated**: November 29, 2025
