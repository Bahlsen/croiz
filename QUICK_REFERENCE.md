# Croiz Quick Reference

Fast lookup guide for common tasks during development.

## 🚀 Quick Start Commands

### Start Development Environment

```bash
# Terminal 1: Backend API
cd backend && ./gradlew bootRun
# Access: http://localhost:8080/api/v1/health

# Terminal 2: Frontend App
cd frontend && flutter run
# Or run on specific device:
# flutter run -d chrome (web)
# flutter run -d macos (desktop)

# Terminal 3: Database (if standalone)
psql -U postgres -d croiz
```

## 📝 Common Development Tasks

### Frontend Tasks

```bash
cd frontend

# Get dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build
flutter pub run build_runner watch

# Analyze code
flutter analyze

# Format code
dart format lib/ test/

# Run tests
flutter test
flutter test --watch
flutter test --coverage

# Build APK
flutter build apk --release

# Clean
flutter clean
```

### Backend Tasks

```bash
cd backend

# Build project
./gradlew build

# Run tests
./gradlew test
./gradlew test --tests ClassName

# Generate coverage
./gradlew jacocoTestReport

# Format code
./gradlew spotlessApply

# Run app
./gradlew bootRun

# Build JAR
./gradlew bootJar

# Check dependencies
./gradlew dependencies

# Clean
./gradlew clean
```

## 🔧 Configuration Files

| File | Purpose |
|------|---------|
| `frontend/pubspec.yaml` | Flutter dependencies |
| `backend/build.gradle` | Gradle build config |
| `backend/src/main/resources/application.yaml` | App config |
| `docs/*.md` | Comprehensive documentation |
| `.github/workflows/*.yml` | CI/CD pipelines |

## 🗄️ Database

### Connect to PostgreSQL

```bash
# Connect to local database
psql -U postgres -d croiz

# Useful commands
\dt                    # List tables
\d table_name          # Describe table
SELECT * FROM users;   # Query data
\q                     # Quit
```

### Database Files

```
backend/src/main/resources/db/migration/V1__Initial_schema.sql
```

## 📦 Project Structure

```
croiz/
├── frontend/               # Flutter app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── features/       # Game, home, auth screens
│   │   ├── data/           # Repos, models, API
│   │   ├── domain/         # Entities, usecases
│   │   └── services/       # Providers, HTTP, storage
│   ├── test/               # Unit & widget tests
│   └── pubspec.yaml
│
├── backend/                # Spring Boot API
│   ├── src/main/java/com/croiz/
│   │   ├── CroizApiApplication.java
│   │   ├── controller/
│   │   ├── service/
│   │   ├── repository/
│   │   ├── entity/
│   │   ├── dto/
│   │   ├── security/
│   │   ├── config/
│   │   └── exception/
│   ├── src/test/
│   ├── src/main/resources/
│   │   ├── application.yaml
│   │   └── db/migration/
│   └── build.gradle
│
├── .github/workflows/      # CI/CD pipelines
│   ├── flutter-tests.yml
│   ├── api-tests.yml
│   ├── integration-tests.yml
│   └── deploy.yml
│
├── docs/                   # Documentation
│   ├── setup.md
│   ├── architecture.md
│   ├── api.md
│   └── testing.md
│
└── shared/                 # Shared models (optional)
```

## 🧪 Testing

### Run All Tests

```bash
# Frontend
cd frontend && flutter test --coverage

# Backend
cd backend && ./gradlew test jacocoTestReport

# Integration (after starting backend)
cd frontend && flutter test integration_test/
```

### View Coverage Reports

```bash
# Frontend
open frontend/coverage/index.html

# Backend
open backend/build/reports/jacoco/test/html/index.html
```

## 🌐 API Quick Reference

### Health Check
```bash
curl http://localhost:8080/api/v1/health
```

### Login (To implement)
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"user","password":"pass"}'
```

### Get Games (To implement)
```bash
curl -H "Authorization: Bearer <token>" \
  http://localhost:8080/api/v1/games
```

See `docs/api.md` for complete API documentation.

## 🔐 Authentication

### Token Storage (Flutter)
```dart
// Store token securely
final storage = FlutterSecureStorage();
await storage.write(key: 'auth_token', value: token);

// Retrieve token
final token = await storage.read(key: 'auth_token');

// Delete token on logout
await storage.delete(key: 'auth_token');
```

### Token Usage
```dart
// Add to Dio interceptor
options.headers['Authorization'] = 'Bearer $token';
```

## 📊 Useful Gradle Commands

```bash
cd backend

# List all available tasks
./gradlew tasks

# Show dependency tree
./gradlew dependencies

# Check for updates
./gradlew dependencyUpdates

# Build and skip tests
./gradlew build -x test
```

## 🐛 Debugging

### Flutter
```bash
# Verbose output
flutter run -v

# Debug breakpoints
# In VS Code: F5
# In Android Studio: Run → Debug
```

### Spring Boot
```bash
# Debug mode
./gradlew bootRun --debug-jvm

# In IntelliJ: Run → Debug
```

## 🔗 Git Workflow

```bash
# Create feature branch
git checkout -b feature/my-feature develop

# Make changes
git add .
git commit -m "feat(scope): description"

# Push and create PR
git push origin feature/my-feature

# After merge
git checkout develop
git pull origin develop
```

### Commit Convention
```
<type>(<scope>): <subject>
<blank line>
<body>
<blank line>
<footer>

Types: feat, fix, docs, style, refactor, test, chore
```

## 📱 Device/Emulator Commands

```bash
# List connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Launch Android emulator
emulator -avd <emulator-name>

# Launch iOS simulator (Mac only)
open -a Simulator
```

## 🚨 Common Issues

### "Flutter SDK not found"
```bash
export PATH="$PATH:/path/to/flutter/bin"
flutter doctor
```

### "Port 8080 already in use"
```bash
# Find process using port
lsof -i :8080
# Kill process
kill -9 <PID>
```

### "Connection refused" (PostgreSQL)
```bash
# Check if running
pg_isready

# Start PostgreSQL
pg_ctl start -D /usr/local/var/postgres
```

### Gradle build fails
```bash
cd backend
./gradlew clean
./gradlew build --refresh-dependencies
```

## 📚 Documentation Navigation

| Need | File |
|------|------|
| How to set up? | `docs/setup.md` |
| Architecture overview? | `docs/architecture.md` |
| API endpoints? | `docs/api.md` |
| Testing guide? | `docs/testing.md` |
| Contributing? | `CONTRIBUTING.md` |
| Project status? | `INITIALIZATION.md` |

## 🎯 Next Steps Checklist

- [ ] Create GitHub private repository
- [ ] Set branch protection rules
- [ ] Install required tools locally
- [ ] Run `flutter doctor` and fix issues
- [ ] Run `./gradlew build` in backend
- [ ] Create PostgreSQL database
- [ ] Start both frontend and backend
- [ ] Run test suites
- [ ] Read full documentation

## 💡 Quick Tips

1. **Use hot reload**: Flutter hot reload (Ctrl+S) during development
2. **DevTools**: `flutter pub global activate devtools && devtools`
3. **Save time**: Use IDE shortcuts (Cmd+Shift+O for organize imports)
4. **Debug print**: Use `print()` in Dart, `System.out.println()` in Java
5. **Check logs**: `flutter logs` for Flutter, app logs in Spring Boot startup
6. **Mock data**: Use test fixtures to avoid repeated setup

## 📞 Getting Help

1. Check `docs/setup.md` troubleshooting section
2. Read relevant documentation file
3. Search GitHub issues
4. Check official Flutter/Spring Boot documentation
5. Ask team members

---

**Last Updated**: November 29, 2025  
**Bookmark this file for quick reference!**
