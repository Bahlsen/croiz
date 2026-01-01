# Services Directory

This directory contains application-level services and providers that are shared across multiple features.

## Overview

Services provide:
- Global state management (Riverpod providers)
- Cross-cutting concerns (audio, storage, HTTP)
- Dependency injection configuration

## Directory Structure

```
services/
├── providers.dart            # Central Riverpod providers
├── audio_service.dart        # Audio interface
├── game_audio_service.dart   # Audio implementation
└── persistence/              # Data persistence
    ├── hive_puzzle_storage.dart
    └── puzzle_storage_interface.dart
```

## Key Files

### `providers.dart`

Central hub for all application-wide Riverpod providers:

#### UI Preferences
- `localeProvider` - App language (en/fr/uk)
- `appIsDarkProvider` - Dark/light theme toggle
- `gameKeyboardLayoutProvider` - QWERTY/AZERTY keyboard
- `gameKeyboardSizeProvider` - Keyboard size (small/medium/large)
- `gameAudioMutedProvider` - Audio mute state

#### Services
- `secureStorageProvider` - Flutter Secure Storage instance
- `gameAudioServiceProvider` - Audio playback service
- `wordCheckServiceProvider` - Answer validation service
- `dioProvider` - HTTP client with auth interceptors

#### Authentication
- `authProvider` - User authentication state

### Usage Examples

```dart
// Reading a provider in a widget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(appIsDarkProvider);
    final locale = ref.watch(localeProvider);
    // ...
  }
}

// Modifying state
ref.read(appIsDarkProvider.notifier).toggle();
ref.read(localeProvider.notifier).setLocale(const Locale('fr'));
```

### `audio_service.dart`

Abstract interface for audio playback:

```dart
abstract class AudioService {
  Future<void> playKeyPress();
  Future<void> playCorrect();
  Future<void> playError();
  Future<void> playComplete();
  Future<void> dispose();
}
```

### `game_audio_service.dart`

Concrete implementation using Flutter audio libraries:
- Loads audio assets from `assets/audio/`
- Respects mute preference from `gameAudioMutedProvider`
- Handles audio focus and session management

## Persistence

### `puzzle_storage_interface.dart`

Abstract interface for puzzle progress storage:

```dart
abstract class PuzzleStorageInterface {
  Future<PuzzleProgress?> load(String puzzleId);
  Future<void> save(String puzzleId, PuzzleProgress progress);
  Future<void> delete(String puzzleId);
  Future<List<String>> getAllPuzzleIds();
}
```

### `hive_puzzle_storage.dart`

Hive-based implementation for local storage:
- Uses Hive boxes for fast NoSQL storage
- Automatically persists during gameplay
- Supports progress restoration on app restart

## Provider Architecture

```
┌─────────────────────────────────────────────┐
│           Application Layer                  │
│   (main.dart, routes, screens)              │
└─────────────────┬───────────────────────────┘
                  │ ref.watch / ref.read
                  ▼
┌─────────────────────────────────────────────┐
│         providers.dart (Central Hub)         │
│                                              │
│  ┌──────────────┐  ┌───────────────────┐   │
│  │ UI Prefs     │  │ Audio Service     │   │
│  │ - locale     │  │ - keypress sounds │   │
│  │ - theme      │  │ - feedback        │   │
│  │ - keyboard   │  │                   │   │
│  └──────────────┘  └───────────────────┘   │
│                                              │
│  ┌──────────────┐  ┌───────────────────┐   │
│  │ Auth State   │  │ HTTP Client (Dio) │   │
│  │ - login      │  │ - interceptors    │   │
│  │ - token      │  │ - auth headers    │   │
│  └──────────────┘  └───────────────────┘   │
└──────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│         Feature-specific Providers           │
│   (game/, puzzles/, home/)                   │
└─────────────────────────────────────────────┘
```

## Notifier Conventions

All Notifiers follow Riverpod 3.0 patterns:

1. **Extend `Notifier<T>`** for synchronous state
2. **Extend `AsyncNotifier<T>`** for async state
3. **Implement `build()`** for initial state
4. **Use setters** instead of direct property access
5. **Persist preferences** in `SharedPreferences`

Example:
```dart
class MySettingNotifier extends Notifier<bool> {
  @override
  bool build() => false; // default value

  void setEnabled({required bool enabled}) {
    state = enabled;
    _persist(enabled);
  }

  Future<void> _persist(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('my_setting', v);
  }

  void toggle() => state = !state;
}
```

## Testing

Services are designed for easy testing:
- Providers can be overridden in tests
- Interfaces allow mock implementations
- No global singletons or static state

Example test setup:
```dart
final container = ProviderContainer(
  overrides: [
    gameAudioServiceProvider.overrideWithValue(MockAudioService()),
  ],
);
```

## Related Documentation

- [Features README](../features/README.md)
- [Architecture](../../../docs/architecture.md)
- [Providers Best Practices](https://riverpod.dev/docs/concepts/do_dont)
