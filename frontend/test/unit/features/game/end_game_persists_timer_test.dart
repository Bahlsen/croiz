import '../../../helpers/fake_puzzle_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:croiz/features/game/providers/game_providers.dart';

import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/services/persistence/storage_provider.dart';

void main() {
  late FakePuzzleStorage storage;
  // No need for GamePersistenceService variable if only checking storage side effects

  setUp(() {
    storage = FakePuzzleStorage();
    storage = FakePuzzleStorage();
  });
  tearDown(() async {
    // No specific cleanup needed for FakePuzzleStorage
  });

  test('end-game triggers persistence of elapsedSeconds', () async {
    const id = 'endgame-puzzle';

    // Create a tiny 2x2 puzzle where entries are already complete
    const size = 2;
    final grid = List.generate(size, (_) => List<String?>.filled(size, 'A'));
    final solution = List.generate(
      size,
      (_) => List<String?>.filled(size, 'A'),
    );
    final black = List.generate(size, (_) => List<bool>.filled(size, false));

    const entry = PuzzleEntryData(
      number: 1,
      direction: 'across',
      x: 0,
      y: 0,
      length: 1,
      clue: 'x',
      answer: 'A',
    );

    final board = GameBoard(
      id: id,
      title: 'EndGame',
      gridSize: size,
      createdAt: DateTime.now(),
      grid: grid,
      clues: const {},
      blackCells: black,
      difficulty: 1,
      entries: [entry],
      solutionGrid: solution,
    );

    final container = ProviderContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        puzzleStorageProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(container.dispose);

    // Trigger provider build and allow restoration microtask to run.
    container.read(gameBoardProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    // Allow debounce persistence to run (persist is debounced by 200ms).
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final saved = await storage.load(id);
    expect(saved, isNotNull, reason: 'Expected puzzle progress to be saved');
    expect(
      saved!.containsKey('elapsedSeconds'),
      isTrue,
      reason: 'elapsedSeconds should be persisted at end-game',
    );
  });
}
