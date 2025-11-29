# Croiz Project Setup Guide

Complete setup instructions for the Croiz crossword game project development environment.

## Prerequisites

### System Requirements

- **OS**: Windows 10+, macOS 11+, or Linux
- **Disk Space**: 10+ GB for all tools
- **RAM**: 8+ GB recommended

### Required Tools

#### Java Development
- **Java 21 LTS**
  - Download: https://www.oracle.com/java/technologies/downloads/#java21
  - Verify: `java -version`

#### Flutter Development
- **Flutter 3.38+**
  - Download: https://flutter.dev/docs/get-started/install
  - Installation: Follow official guide for your OS
  - Verify: `flutter --version`

- **Dart 3.10+** (included with Flutter)
  - Verify: `dart --version`

#### Database
- **PostgreSQL 14+**
  - Download: https://www.postgresql.org/download/
  - Default port: 5432
  - Create test database: `createdb croiz`

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

### 3. Backend Setup

```bash
cd backend

# Set executable permissions (Linux/Mac)
chmod +x gradlew

# Download Gradle wrapper
./gradlew wrapper

# Build project
./gradlew build

# Run tests
./gradlew test

# Start development server
./gradlew bootRun
```

### 4. Database Setup

```bash
# Create database
createdb -U postgres croiz

# Run migrations (automatic on app start)
# Or manual with Flyway:
./gradlew flywayMigrate
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
  "java.configuration.runtimes": [
    {
      "name": "JavaSE-21",
      "path": "/path/to/java/21"
    }
  ]
}
```

### Environment Variables

**Create `.env` file** in project root (never commit):

```env
# Database
POSTGRES_URL=jdbc:postgresql://localhost:5432/croiz
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres

# API
API_BASE_URL=http://localhost:8080/api/v1

# JWT Secret (development only)
JWT_SECRET=dev-secret-key-change-in-production
JWT_EXPIRATION=86400000

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

### Terminal 1: Database (Optional if running as service)

```bash
# macOS/Linux
pg_ctl -D /usr/local/var/postgres start

# Windows (if installed as service)
net start PostgreSQL
```

### Terminal 2: Backend API

```bash
cd backend
./gradlew bootRun
# API runs on: http://localhost:8080
# Health check: http://localhost:8080/api/v1/health
```

### Terminal 3: Frontend App

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

### Backend Tests

```bash
cd backend

# Run all tests
./gradlew test

# Run specific test class
./gradlew test --tests HealthControllerTest

# Run with coverage
./gradlew test jacocoTestReport

# View coverage report
open build/reports/jacoco/test/html/index.html

# Run tests with logging
./gradlew test --info
```

### Integration Tests

```bash
# Start backend first
cd backend
./gradlew bootRun

# In another terminal, run Flutter integration tests
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

### Backend Debugging

```bash
# Run with debug flag
./gradlew bootRun --debug-jvm

# In IntelliJ: Run → Debug 'CroizApiApplication'
# Set breakpoints in code, execution will pause

# View logs
tail -f build/logs/*.log
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

#### Database: "Connection refused"
```bash
# Check if PostgreSQL is running
psql -U postgres -c "SELECT version();"

# Restart PostgreSQL
pg_ctl restart -D /usr/local/var/postgres
```

#### Port already in use
```bash
# API port (8080)
lsof -i :8080
kill -9 <PID>

# Database port (5432)
lsof -i :5432
kill -9 <PID>
```

## Code Quality Tools

### Format Code

```bash
# Flutter
cd frontend
dart format lib/ test/

# Backend
cd backend
./gradlew spotlessApply
```

### Lint/Analyze

```bash
# Flutter
cd frontend
flutter analyze

# Backend
cd backend
./gradlew check
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

### Gradle Commands

```bash
./gradlew tasks                  # List available tasks
./gradlew dependencies           # Show dependency tree
./gradlew build                  # Build project
./gradlew test                   # Run tests
./gradlew bootRun               # Run application
./gradlew clean                 # Clean build artifacts
```

## Next Steps

1. **Read Architecture Docs**: `docs/architecture.md`
2. **API Documentation**: `docs/api.md`
3. **Contributing Guide**: `CONTRIBUTING.md`
4. **Create GitHub Repository**: Set to private, add collaborators
5. **Set Branch Protection**: Require PR reviews and CI/CD passing

## Getting Help

- **Flutter Docs**: https://flutter.dev/docs
- **Spring Boot Docs**: https://spring.io/projects/spring-boot
- **PostgreSQL Docs**: https://www.postgresql.org/docs/
- **GitHub Docs**: https://docs.github.com/en/repositories

## Support

For issues or questions:
1. Check documentation in `/docs`
2. Search existing GitHub issues
3. Create new issue with detailed description
4. Contact team lead

---

**Last Updated**: November 29, 2025
