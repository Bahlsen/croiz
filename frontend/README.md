# Flutter Frontend

## Overview

The Croiz Flutter application provides a mobile crossword game interface with real-time gameplay, user authentication, and comprehensive scoring systems.

## Architecture

### Layered Architecture

```
Presentation (Screens/Widgets)
         ↓
   State Management (Riverpod)
         ↓
   Use Cases / Services
         ↓
   Repositories (Data Access)
         ↓
   Data Sources (API / Local Storage)
```

### Directory Structure

```
lib/
├── core/                 # App-wide utilities
│   ├── constants.dart   # Global constants
│   └── theme.dart       # UI themes
├── services/            # Business logic & providers
│   └── providers.dart   # Riverpod providers
├── features/            # Feature modules
│   ├── home/            # Home screen
│   ├── game/            # Game screens
│   └── auth/            # Authentication
├── data/                # Data layer
│   ├── models/          # DTOs/serialization
│   ├── repositories/    # Data repositories
│   └── datasources/     # API & local storage
├── domain/              # Domain layer
│   ├── entities/        # Business entities
│   └── usecases/        # Business logic
└── main.dart            # Entry point
```

## State Management - Riverpod

Riverpod is chosen for:
- **Type-safe**: Compile-time safety
- **Testable**: Easy mocking and testing
- **Performant**: Fine-grained reactivity
- **Scalable**: Perfect for game state management

### Key Providers

```dart
// HTTP Client
final dioProvider = Provider<Dio>(...);

// Authentication State
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>(...);

// Game State (to be implemented)
final gameProvider = StateNotifierProvider<GameNotifier, AsyncValue<GameState>>(...);

// User Statistics (to be implemented)
final statsProvider = FutureProvider<UserStats>(...);
```

## Testing Strategy

### Test Pyramid

- **70% Unit Tests** - Business logic, validators, calculations
- **20% Widget Tests** - UI components, screens
- **10% Integration Tests** - Full gameplay flows

### Running Tests

```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# Specific test file
flutter test test/unit/game_logic_test.dart

# Watch mode
flutter test --watch
```

## Dependencies

### State Management
- `flutter_riverpod: ^2.4.0` - Riverpod state management
- `riverpod_generator: ^2.3.0` - Code generation

### Networking
- `dio: ^5.3.0` - HTTP client
- `dio_http_cache: ^1.0.0` - Request caching

### Storage & Security
- `flutter_secure_storage: ^9.0.0` - Secure token storage
- `sqflite: ^2.3.0` - Local SQLite database
- `shared_preferences: ^2.2.0` - Simple key-value storage

### UI & Navigation
- `go_router: ^12.0.0` - Declarative routing
- `google_fonts: ^6.1.0` - Font library
- `flutter_svg: ^2.0.0` - SVG rendering

### Testing
- `mockito: ^5.4.0` - Mocking framework
- `mocktail: ^1.0.0` - Modern mocking
- `golden_toolkit: ^0.13.0` - Golden tests

## Development Workflow

### Adding a New Feature

1. **Create feature directory**
   ```bash
   mkdir lib/features/my_feature
   ```

2. **Define entities** in `domain/entities/`

3. **Create repositories** in `data/repositories/`

4. **Implement Riverpod providers** in `services/providers.dart`

5. **Build UI screens** in `features/my_feature/`

6. **Write tests** in `test/unit/` and `test/widget/`

### Code Generation

Some packages require code generation:

```bash
# Run once
flutter pub run build_runner build

# Watch mode
flutter pub run build_runner watch
```

## Environment Setup

### Prerequisites
- Flutter 3.38+ with Dart 3.10+
- Android Studio / Xcode for emulators
- VS Code with Flutter extension

### Installation

```bash
cd frontend
flutter pub get
flutter pub run build_runner build
flutter run
```

## CI/CD Integration

GitHub Actions automatically runs:
- `flutter analyze` - Lint analysis
- `flutter test --coverage` - Unit & widget tests
- Coverage report generation

See `.github/workflows/flutter-tests.yml`
