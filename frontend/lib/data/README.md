# Data Layer

This directory contains the data layer implementation following Clean Architecture principles.

## Overview

The data layer is responsible for:
- Data model definitions (DTOs)
- Repository implementations
- Data source abstractions (remote/local)

## Directory Structure

```
data/
├── models/              # Data Transfer Objects (DTOs)
│   ├── puzzle_model.dart
│   ├── cell_model.dart
│   ├── clue_model.dart
│   ├── game_progress_model.dart
│   ├── user_model.dart
│   └── ...
├── repositories/        # Repository implementations
│   └── (future implementations)
└── datasources/         # Data source access
    └── (future implementations)
```

## Models

### Purpose
Models are data structures used for:
- JSON serialization/deserialization
- API request/response payloads
- Local storage data formats

### Conventions

1. **Immutable classes** with `final` fields
2. **Factory constructors** for JSON parsing
3. **`toJson()` methods** for serialization
4. **`copyWith()` for modifications**
5. **Use `json_serializable`** when beneficial

Example:
```dart
@JsonSerializable(fieldRename: FieldRename.snake)
class PuzzleModel {
  final String id;
  final String title;
  final List<ClueModel> clues;
  final List<List<CellModel>> grid;

  const PuzzleModel({
    required this.id,
    required this.title,
    required this.clues,
    required this.grid,
  });

  factory PuzzleModel.fromJson(Map<String, dynamic> json) =>
      _$PuzzleModelFromJson(json);

  Map<String, dynamic> toJson() => _$PuzzleModelToJson(this);

  PuzzleModel copyWith({
    String? id,
    String? title,
    // ...
  }) => PuzzleModel(
    id: id ?? this.id,
    title: title ?? this.title,
    // ...
  );
}
```

## Repositories

### Purpose
Repositories provide a clean API for data access:
- Abstract away data sources
- Handle caching strategies
- Manage data transformations
- Enable easy mocking for tests

### Pattern
```dart
abstract class PuzzleRepository {
  Future<List<PuzzleModel>> getAllPuzzles();
  Future<PuzzleModel?> getPuzzleById(String id);
  Future<void> savePuzzle(PuzzleModel puzzle);
}

class PuzzleRepositoryImpl implements PuzzleRepository {
  final AssetBundle assetBundle;
  final PuzzleCache cache;

  @override
  Future<List<PuzzleModel>> getAllPuzzles() async {
    // Check cache first
    final cached = cache.getAll();
    if (cached != null) return cached;

    // Load from assets
    final data = await assetBundle.loadString('assets/puzzles.json');
    final puzzles = _parse(data);
    cache.setAll(puzzles);
    return puzzles;
  }
}
```

## Data Sources

### Remote (API)
For backend communication via HTTP:
```dart
abstract class PuzzleRemoteDataSource {
  Future<List<PuzzleDto>> fetchPuzzles();
  Future<void> submitScore(ScoreDto score);
}
```

### Local (Storage)
For offline data access:
```dart
abstract class PuzzleLocalDataSource {
  Future<List<PuzzleModel>> getCachedPuzzles();
  Future<void> cachePuzzles(List<PuzzleModel> puzzles);
  Future<void> clearCache();
}
```

## Layer Boundaries

```
┌─────────────────────────────────────────────┐
│              Presentation Layer              │
│         (Screens, Widgets, Providers)        │
└─────────────────┬───────────────────────────┘
                  │ Uses repository interfaces
                  ▼
┌─────────────────────────────────────────────┐
│                Domain Layer                  │
│           (Entities, Use Cases)              │
└─────────────────┬───────────────────────────┘
                  │ Returns entities
                  ▼
┌─────────────────────────────────────────────┐
│                 Data Layer                   │
│  ┌─────────────────────────────────────┐    │
│  │           Repositories               │    │
│  │  - Coordinate data sources           │    │
│  │  - Transform models ↔ entities       │    │
│  └────────────┬────────────────────────┘    │
│               │                              │
│  ┌────────────▼────────────────────────┐    │
│  │           Data Sources               │    │
│  │  ┌─────────────┐  ┌──────────────┐  │    │
│  │  │   Remote    │  │    Local     │  │    │
│  │  │  (API/HTTP) │  │ (Hive/SQLite)│  │    │
│  │  └─────────────┘  └──────────────┘  │    │
│  └──────────────────────────────────────┘    │
└──────────────────────────────────────────────┘
```

## Testing

Models and repositories should be thoroughly tested:

```dart
// Model test
test('PuzzleModel fromJson parses correctly', () {
  final json = {'id': '1', 'title': 'Test'};
  final model = PuzzleModel.fromJson(json);
  expect(model.id, '1');
  expect(model.title, 'Test');
});

// Repository test with mock
test('repository returns cached data', () async {
  when(mockCache.getAll()).thenReturn([testPuzzle]);
  final result = await repository.getAllPuzzles();
  expect(result, [testPuzzle]);
  verifyNever(mockAssetBundle.loadString(any));
});
```

## Related Documentation

- [Architecture](../../../docs/architecture.md)
- [Domain Layer](../domain/README.md)
- [API Documentation](../../../docs/api.md)
