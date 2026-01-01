# Domain Layer

This directory contains the core business logic and domain entities for the Croiz application.

## Overview

The domain layer follows Clean Architecture principles and is responsible for:
- Business entities (pure domain models)
- Use cases (business operations)
- Repository interfaces (abstractions)
- Business rules and validations

## Directory Structure

```
domain/
├── entities/            # Business entities
│   ├── puzzle_entity.dart
│   ├── cell_entity.dart
│   ├── clue_entity.dart
│   └── game_state_entity.dart
└── usecases/            # Business logic operations
    ├── load_puzzle_usecase.dart
    ├── save_progress_usecase.dart
    └── validate_answer_usecase.dart
```

## Domain vs Data Layer

| Domain Layer | Data Layer |
|--------------|------------|
| Pure business logic | Data access logic |
| No framework dependencies | Uses Flutter/Dart packages |
| Entities (clean objects) | Models (DTOs with serialization) |
| Repository interfaces | Repository implementations |
| Use cases | Services |

## Entities

### Purpose
Entities represent core business concepts with:
- Immutable properties
- No serialization logic
- Business validation methods
- Framework-free implementation

### Example Entity

```dart
/// Represents a single cell in the crossword grid.
class CellEntity {
  /// Row position (0-indexed).
  final int row;
  
  /// Column position (0-indexed).
  final int column;
  
  /// Correct letter for this cell.
  final String correctLetter;
  
  /// User's current input (empty if not filled).
  final String userInput;
  
  /// Whether this cell is a black/blocked cell.
  final bool isBlocked;

  const CellEntity({
    required this.row,
    required this.column,
    required this.correctLetter,
    this.userInput = '',
    this.isBlocked = false,
  });

  /// Returns true if the user's input matches the correct letter.
  bool get isCorrect => userInput.toUpperCase() == correctLetter.toUpperCase();

  /// Returns true if the user has entered a letter.
  bool get isFilled => userInput.isNotEmpty;

  /// Creates a copy with updated user input.
  CellEntity withUserInput(String input) => CellEntity(
    row: row,
    column: column,
    correctLetter: correctLetter,
    userInput: input,
    isBlocked: isBlocked,
  );
}
```

## Use Cases

### Purpose
Use cases encapsulate a single business operation:
- One operation per class
- Clean interface (call method)
- Dependency injection via constructor
- Returns domain entities

### Example Use Case

```dart
/// Loads a puzzle from storage and returns the domain entity.
class LoadPuzzleUseCase {
  final PuzzleRepository _repository;

  LoadPuzzleUseCase(this._repository);

  /// Loads the puzzle with the given [id].
  ///
  /// Returns the [PuzzleEntity] if found.
  /// Throws [PuzzleNotFoundException] if not found.
  Future<PuzzleEntity> call(String id) async {
    final model = await _repository.findById(id);
    if (model == null) {
      throw PuzzleNotFoundException(id);
    }
    return model.toEntity();
  }
}
```

### Using Use Cases with Riverpod

```dart
// Provider for the use case
final loadPuzzleUseCaseProvider = Provider<LoadPuzzleUseCase>((ref) {
  final repository = ref.read(puzzleRepositoryProvider);
  return LoadPuzzleUseCase(repository);
});

// In a widget or provider
final puzzle = await ref.read(loadPuzzleUseCaseProvider).call(puzzleId);
```

## Repository Interfaces

Defined in the domain layer, implemented in the data layer:

```dart
/// Repository interface for puzzle operations.
abstract class PuzzleRepository {
  /// Finds a puzzle by its unique identifier.
  Future<PuzzleModel?> findById(String id);

  /// Returns all available puzzles.
  Future<List<PuzzleModel>> findAll();

  /// Saves puzzle progress.
  Future<void> saveProgress(String id, ProgressModel progress);
}
```

## Dependency Flow

```
┌─────────────────────────────────────────────┐
│              Presentation Layer              │
│         (Widgets, Screens, Providers)        │
└─────────────────┬───────────────────────────┘
                  │ Uses use cases
                  ▼
┌─────────────────────────────────────────────┐
│                Domain Layer                  │
│                                              │
│  ┌───────────────┐  ┌────────────────────┐  │
│  │   Entities    │  │     Use Cases      │  │
│  │               │  │                    │  │
│  │ - PuzzleEntity│  │ - LoadPuzzleUseCase│  │
│  │ - CellEntity  │←─│ - SaveProgressUC   │  │
│  │ - ClueEntity  │  │ - ValidateAnswerUC │  │
│  └───────────────┘  └────────┬───────────┘  │
│                              │              │
│         Repository Interfaces │              │
│         ─────────────────────▼──────────    │
└─────────────────────────────────────────────┘
                  │ Implemented by
                  ▼
┌─────────────────────────────────────────────┐
│                 Data Layer                   │
│  Repository Implementations, Models, APIs    │
└─────────────────────────────────────────────┘
```

## Testing

Domain logic should be thoroughly unit tested:

```dart
test('CellEntity.isCorrect returns true for matching input', () {
  final cell = CellEntity(
    row: 0,
    column: 0,
    correctLetter: 'A',
    userInput: 'a',
  );
  expect(cell.isCorrect, isTrue);
});

test('LoadPuzzleUseCase throws when puzzle not found', () async {
  when(mockRepository.findById('unknown')).thenAnswer((_) async => null);
  
  expect(
    () => useCase.call('unknown'),
    throwsA(isA<PuzzleNotFoundException>()),
  );
});
```

## Related Documentation

- [Data Layer](../data/README.md) - Repository implementations
- [Features](../features/README.md) - UI consumption of domain
- [Architecture](../../../docs/architecture.md) - System design
