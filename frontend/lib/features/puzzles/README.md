# Puzzles Feature

The puzzle discovery and selection module for Croiz. This feature allows users to browse, filter, and select puzzles to play.

## Overview

The Puzzles feature provides:
- Browse all available puzzles grouped by origin
- Filter puzzles by language (FR, EN, UK)
- Filter by year and difficulty
- View in-progress puzzles for quick resume
- Lazy loading for performance on mobile devices

## Directory Structure

```
puzzles/
├── puzzles_list_page.dart       # Main puzzle browsing screen
├── puzzles_provider.dart        # Core puzzle data providers
├── puzzle_filter_provider.dart  # Filter state management
├── filtered_puzzles_provider.dart # Applied filter logic
└── widgets/
    ├── continue_playing_section.dart  # In-progress puzzles
    ├── language_filter_selector.dart  # Language filter UI
    ├── origin_card.dart               # Source card display
    ├── origin_section.dart            # Grouping by origin
    └── puzzle_list_item.dart          # Individual puzzle entry
```

## Key Providers

### `puzzlesProvider`
Loads all puzzle metadata from the bundled asset index:
```dart
final puzzlesProvider = FutureProvider<List<PuzzleDescriptor>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/puzzles_index.json');
  return compute(_parseAllFromIndex, raw);
});
```

### `originsProvider`
Returns distinct origins (e.g., "nyt", "wsj", "la-times"):
```dart
final originsProvider = FutureProvider<List<String>>((ref) async { ... });
```

### `originIndexProvider`
Family provider to load puzzles for a specific origin:
```dart
final originIndexProvider = FutureProvider.family<List<PuzzleDescriptor>, String>(
  (ref, origin) async { ... }
);
```

### `puzzleFilterProvider`
Manages the current filter state:
```dart
final puzzleFilterProvider = StateNotifierProvider<PuzzleFilterNotifier, PuzzleFilterState>(
  (ref) => PuzzleFilterNotifier(),
);
```

### `filteredPuzzlesProvider`
Applies active filters to the puzzle list:
```dart
final filteredPuzzlesProvider = Provider<List<PuzzleDescriptor>>((ref) {
  final all = ref.watch(puzzlesProvider).value ?? [];
  final filter = ref.watch(puzzleFilterProvider);
  return filter.apply(all);
});
```

### `inProgressPuzzlesProvider`
Retrieves puzzles with saved progress:
```dart
final inProgressPuzzlesProvider = FutureProvider<List<PuzzleDescriptor>>((ref) async {
  // Reads from HivePuzzleStorage
});
```

## Data Models

### `PuzzleDescriptor`
Lightweight metadata for puzzle listing:
```dart
class PuzzleDescriptor {
  final String id;
  final String title;
  final String path;        // Asset path
  final String? subtitle;
  final String? origin;     // e.g., "nyt", "wsj"
  final String? year;       // e.g., "2024"
  final int? difficulty;    // 1-3
  final String? difficultyLabel;
  final String? language;   // e.g., "fr", "en"
}
```

### `PuzzleFilterState`
Current filter selections:
```dart
class PuzzleFilterState {
  final Set<String> selectedOrigins;
  final Set<String> selectedLanguages;
  final String? yearFrom;
  final String? yearTo;
  final int? minDifficulty;
  final int? maxDifficulty;
}
```

## UI Components

### `PuzzlesListPage`
Main screen featuring:
- Header with app title
- Filter chips row (languages)
- "Continue Playing" section (if any in-progress)
- Grouped puzzle list by origin

### `ContinuePlayingSection`
Horizontal scroll showing puzzles with saved progress:
- Displays progress percentage
- Tap to resume playing
- Swipe to dismiss/clear progress

### `LanguageFilterSelector`
Button opening a bottom sheet for language filtering:
- Shows current selection status (e.g. "All Languages")
- Bottom sheet with checkbox list
- "Select All" functionality
- Uses clean "empty set = all" logic

### `OriginCard` / `OriginSection`
Groups puzzles by their source:
- Collapsible sections
- Shows puzzle count per origin
- Lazy loads puzzle details

### `PuzzleListItem`
Individual puzzle entry:
- Title and subtitle
- Difficulty indicator (stars or label)
- Progress bar (if in-progress)
- Tap to start playing

## Filter Flow

```
User taps language chip (e.g., "FR")
        │
        ▼
puzzleFilterProvider.selectLanguage("fr")
        │
        ▼
PuzzleFilterState updated
        │
        ▼
filteredPuzzlesProvider recomputes
        │
        ▼
PuzzlesListPage rebuilds with filtered list
```

## Performance Optimizations

1. **Lazy Index Loading**: Only load origin-specific data when needed
2. **Isolate Parsing**: JSON parsing on separate isolate via `compute()`
3. **Compact Index**: Minimal metadata in index, full data loaded on demand
4. **Widget Caching**: `const` constructors for static widgets

## Asset Structure

Puzzles are bundled as JSON files:
```
assets/data/
├── puzzles_index.json              # Master index
├── puzzles_index_origins.json      # Origins summary
├── puzzles_index_by_origin/
│   ├── nyt.json
│   ├── wsj.json
│   └── ...
└── <individual puzzle files>.json
```

## Testing

Located in:
- `test/unit/features/puzzles/` - Provider and filter logic tests
- `test/widget/features/puzzles/` - Widget tests

Key test files:
- `puzzles_provider_test.dart`
- `puzzle_filter_provider_test.dart`
- `in_progress_puzzles_provider_autodispose_test.dart`
- `language_filter_chips_test.dart`

## Related Documentation

- [Features README](../README.md)
- [Architecture](../../../../docs/architecture.md)
- [Puzzle System](../../../../docs/puzzle-system.md)
- [Puzzle Schema](../../../../docs/puzzle-schema.md)
