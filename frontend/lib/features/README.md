# Features Directory

This directory contains feature modules for the Croiz application. Each feature is organized as a self-contained module following the layered architecture pattern.

## Directory Structure

```
features/
├── game/              # Core crossword gameplay
├── home/              # Home screen and navigation
├── puzzles/           # Puzzle selection and browsing
└── splash/            # Application splash/loading screen
```

## Feature Module Architecture

Each feature module follows a consistent structure:

```
feature_name/
├── controllers/       # Business logic controllers (BLoC-like)
├── helpers/           # Feature-specific helper functions
├── listeners/         # Event listeners and callbacks
├── models/            # Data models specific to this feature
├── providers/         # Riverpod providers for state management
├── screens/           # Full-screen UI components
├── services/          # Feature-specific services
├── utils/             # Utility functions
└── widgets/           # Reusable UI components
```

## Features Overview

### 🎮 Game (`game/`)

The core crossword gameplay feature including:

- **screens/**: `GameScreen` - Main gameplay interface
- **controllers/**: Game logic, cursor movement, letter input
- **providers/**: 
  - `crosswordStateProvider` - Current puzzle state
  - `cursorPositionProvider` - Player cursor tracking
  - `gameProgressProvider` - Completion percentage
- **widgets/**: 
  - `CrosswordGridWidget` - Interactive crossword grid
  - `CluesPanel` - Across/Down clues display
  - `VirtualKeyboard` - In-app keyboard input
  - `CrosswordControlsBar` - Game controls (hint, check, reveal)
- **services/**:
  - `WordCheckService` - Validates player answers
  - `PuzzleLoaderService` - Loads puzzle data from assets

### 🏠 Home (`home/`)

Application home screen and main navigation:

- Entry point after splash screen
- Navigation to puzzle selection
- Quick access to settings

### 🧩 Puzzles (`puzzles/`)

Puzzle discovery and selection:

- **puzzles_list_page.dart**: Browse available puzzles
- **puzzles_provider.dart**: Loads puzzle metadata from assets
- **puzzle_filter_provider.dart**: Filtering by origin, year, language
- **filtered_puzzles_provider.dart**: Applies active filters
- **widgets/**:
  - `ContinuePlayingSection` - Show in-progress puzzles
  - `LanguageFilterChips` - Filter by puzzle language
  - `OriginCard` - Display puzzle source cards
  - `PuzzleListItem` - Individual puzzle entry

### 🌊 Splash (`splash/`)

Application loading and initialization:

- `SplashScreen` - Animated loading screen
- Handles asset preloading
- Initializes persistence layer (Hive)
- Loads user preferences

## Creating a New Feature

1. **Create the feature directory**:
   ```bash
   mkdir lib/features/my_feature
   mkdir lib/features/my_feature/{screens,providers,widgets}
   ```

2. **Define providers** for state management

3. **Create screens** for full-page UI

4. **Extract widgets** for reusable components

5. **Write tests** in `test/unit/features/my_feature/` and `test/widget/features/my_feature/`

6. **Register routes** in `lib/routes/app_router.dart`

## Best Practices

- **Single Responsibility**: Each widget/provider should do one thing well
- **Testability**: Write providers that are easy to mock
- **Reusability**: Extract common widgets to `lib/widgets/`
- **Documentation**: Add dartdoc comments to public APIs
- **Immutability**: Prefer immutable state objects

## State Management

All features use **Riverpod** for state management:

```dart
// Feature-specific provider example
final myFeatureStateProvider = 
    // Use @riverpod annotation (Riverpod 3.x)
    @riverpod
    class MyFeature extends _$MyFeature {
      @override
      MyFeatureState build() => MyFeatureState.initial();
      
      void doSomething() {
        state = state.copyWith(...);
      }
    }

// Access in widgets
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myFeatureStateProvider);
    return ...;
  }
}
```

## Related Documentation

- [Frontend README](../../../README.md) - Project setup
- [Architecture](../../../../docs/architecture.md) - System design
- [Testing](../../../../docs/testing.md) - Test strategy
- [Providers](../../services/providers.dart) - Global providers
