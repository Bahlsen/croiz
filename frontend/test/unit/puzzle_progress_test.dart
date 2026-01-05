import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helpers/fake_puzzle_storage.dart';

import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/services/persistence/storage_provider.dart';

final mockPuzzleJson = {
  'rows': 5,
  'cols': 5,
  'cells': [
    {'solution': 'A', 'is_black': false},
  ],
};

void main() {
  late FakePuzzleStorage storage;

  setUp(() async {
    storage = FakePuzzleStorage();
  });

  test('restores persisted puzzle grid and persists changes', () async {
    const id = 'test-puzzle';

    // Prepare saved progress: 3x3 grid with some letters
    const savedGrid = [
      ['A', null, 'C'],
      [null, 'B', null],
      ['D', null, null],
    ];
    final payload = {
      'grid': savedGrid,
      'savedAt': DateTime.now().toIso8601String(),
    };
    await storage.save(id, payload);

    final data = await storage.load(id);
    expect(data, isNotNull);

    // Create a minimal board with same dimensions but empty grid
    const size = 3;
    final emptyGrid = List.generate(
      size,
      (_) => List<String?>.filled(size, null),
    );
    final black = List.generate(size, (_) => List<bool>.filled(size, false));
    final board = GameBoard(
      id: id,
      title: 'Test',
      gridSize: size,
      createdAt: DateTime.now(),
      grid: emptyGrid,
      clues: const {},
      blackCells: black,
      difficulty: 1,
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
    final current = container.read(gameBoardProvider);
    expect(current.id, equals(id));
    expect(current.grid.length, equals(3));
    expect(current.grid[0][0], equals('A'));
    expect(current.grid[0][2], equals('C'));
    expect(current.grid[1][1], equals('B'));

    // Modify a cell and ensure persistence happens (allow debounce)
    container.read(gameBoardProvider.notifier).setLetter(2, 2, 'Z');
    final inMem = container.read(gameBoardProvider).grid[2][2];
    expect(inMem, equals('Z'));

    await Future<void>.delayed(const Duration(milliseconds: 300));

    final saved = await storage.load(id);
    expect(saved, isNotNull);
    final savedGridList = saved!['grid'] as List;
    final row = savedGridList[2] as List;
    expect(row[2], equals('Z'));
  });
}
