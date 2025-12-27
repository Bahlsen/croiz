import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/providers/game_board_provider.dart';
import 'package:croiz/features/game/providers/game_state_providers.dart';
import 'package:croiz/features/game/providers/puzzle_loader_provider.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  test('revealLetterAt should flash the revealed cell', () {
    // Arrange a board where revealing (0,2) completes the across entry at y=0
    final entries = [
      const PuzzleEntryData(
        number: 1,
        direction: 'across',
        x: 0,
        y: 0,
        length: 3,
        answer: 'ABC',
      ),
    ];

    final board = GameBoard(
      id: 't',
      title: 't',
      gridSize: 3,
      createdAt: DateTime.now(),
      grid: [
        ['A', 'B', null],
        [null, null, null],
        [null, null, null],
      ],
      clues: {},
      blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
      difficulty: 1,
      entries: entries,
      solutionGrid: [
        ['A', 'B', 'C'],
        ['D', 'E', 'F'],
        ['G', 'H', 'I'],
      ],
    );

    final container = ProviderContainer(overrides: [
      puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
      flashClearDelayProvider.overrideWithValue(Duration.zero),
      wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
    ]);
    addTearDown(container.dispose);

    // reveal the final letter to complete the word
    container.read(gameBoardProvider.notifier).revealLetterAt(0, 2);

    final flashing = container.read(flashingCellsProvider);
    // All three cells of the entry should flash
    expect(flashing.contains(const CellKey(0, 0)), isTrue);
    expect(flashing.contains(const CellKey(0, 1)), isTrue);
    expect(flashing.contains(const CellKey(0, 2)), isTrue);

    return Future.microtask(() {
      final after = container.read(flashingCellsProvider);
      expect(after, isEmpty);
    });
  });

  test('revealEntry should flash all cells of the entry', () async {
    const entry = PuzzleEntryData(
      number: 1,
      direction: 'across',
      x: 0,
      y: 1,
      length: 3,
      answer: 'DEF',
    );

    final board = GameBoard(
      id: 't',
      title: 't',
      gridSize: 3,
      createdAt: DateTime.now(),
      grid: [
        [null, null, null],
        [null, null, null],
        [null, null, null],
      ],
      clues: {},
      blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
      difficulty: 1,
      entries: [entry],
      solutionGrid: [
        ['A', 'B', 'C'],
        ['D', 'E', 'F'],
        ['G', 'H', 'I'],
      ],
    );

    final container = ProviderContainer(overrides: [
      puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
      flashClearDelayProvider.overrideWithValue(Duration.zero),
      wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
    ]);
    addTearDown(container.dispose);

    container.read(gameBoardProvider.notifier).revealEntry(entry);

    final flashing = container.read(flashingCellsProvider);
    expect(flashing.contains(const CellKey(1, 0)), isTrue);
    expect(flashing.contains(const CellKey(1, 1)), isTrue);
    expect(flashing.contains(const CellKey(1, 2)), isTrue);

    await Future.microtask(() {
      final after = container.read(flashingCellsProvider);
      expect(after, isEmpty);
    });
  });

  test('revealAll should flash all non-black cells', () async {
    final board = GameBoard(
      id: 't',
      title: 't',
      gridSize: 2,
      createdAt: DateTime.now(),
      grid: [
        [null, null],
        [null, null],
      ],
      clues: {},
      blackCells: [
        [false, false],
        [false, true],
      ],
      difficulty: 1,
      entries: [],
      solutionGrid: [
        ['A', 'B'],
        ['C', null],
      ],
    );

    final container = ProviderContainer(overrides: [
      puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
      flashClearDelayProvider.overrideWithValue(Duration.zero),
      wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
    ]);
    addTearDown(container.dispose);

    container.read(gameBoardProvider.notifier).revealAll();

    final flashing = container.read(flashingCellsProvider);
    expect(flashing.contains(const CellKey(0, 0)), isTrue);
    expect(flashing.contains(const CellKey(0, 1)), isTrue);
    expect(flashing.contains(const CellKey(1, 0)), isTrue);
    expect(flashing.contains(const CellKey(1, 1)), isFalse); // black

    await Future.microtask(() {
      final after = container.read(flashingCellsProvider);
      expect(after, isEmpty);
    });
  });
}
