import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/providers/game_board_notifier.dart';
import 'package:croiz/features/game/providers/game_state_providers.dart';
import 'package:croiz/features/game/providers/puzzle_loader_provider.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  group('GameBoardNotifier.resetPuzzle', () {
    test('should clear all user progress and reset game state', () async {
      // Arrange: create a board with some progress (filled cells, found words)
      final entries = [
        const PuzzleEntryData(
          number: 1,
          direction: 'across',
          x: 0,
          y: 0,
          length: 3,
          answer: 'ABC',
        ),
        const PuzzleEntryData(
          number: 2,
          direction: 'down',
          x: 0,
          y: 0,
          length: 3,
          answer: 'ADG',
        ),
      ];

      final board = GameBoard(
        id: 'test-puzzle',
        title: 'Test Puzzle',
        gridSize: 3,
        createdAt: DateTime.now(),
        grid: [
          ['A', 'B', 'C'], // completed word
          ['D', 'E', null],
          ['G', null, null],
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

      final container = ProviderContainer(
        overrides: [
          puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
          flashClearDelayProvider.overrideWithValue(Duration.zero),
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);

      // Initialize board and simulate some game state
      final boardNotifier = container.read(gameBoardProvider.notifier);

      // Set some found words and locked cells manually to simulate game progress
      container.read(foundWordsProvider.notifier).setFoundWords({'0,0,across'});
      container.read(lockedCellsProvider.notifier).setLockedCells({
        const CellKey(0, 0),
        const CellKey(0, 1),
        const CellKey(0, 2),
      });
      container
          .read(selectedCellProvider.notifier)
          .select(const SelectedCell(1, 1));

      // Verify initial state has progress
      expect(container.read(foundWordsProvider).length, equals(1));
      expect(container.read(lockedCellsProvider).length, equals(3));
      expect(container.read(selectedCellProvider), isNotNull);
      expect(container.read(gameBoardProvider).grid[0][0], equals('A'));
      expect(container.read(gameBoardProvider).grid[0][1], equals('B'));
      expect(container.read(gameBoardProvider).grid[0][2], equals('C'));

      // Act: reset the puzzle
      boardNotifier.resetPuzzle();

      // Assert: all state should be cleared
      expect(container.read(foundWordsProvider), isEmpty);
      expect(container.read(lockedCellsProvider), isEmpty);
      expect(container.read(selectedCellProvider), isNull);
      expect(container.read(flashingCellsProvider), isEmpty);
      expect(container.read(flashingClearedCellsProvider), isEmpty);

      // Grid should be cleared (all non-black cells should be null)
      final resetGrid = container.read(gameBoardProvider).grid;
      for (var r = 0; r < resetGrid.length; r++) {
        for (var c = 0; c < resetGrid[r].length; c++) {
          expect(
            resetGrid[r][c],
            isNull,
            reason: 'Cell at ($r,$c) should be null',
          );
        }
      }
    });

    test('should preserve black cells when resetting', () {
      // Arrange: create a board with black cells
      final board = GameBoard(
        id: 'test-black-cells',
        title: 'Test Black Cells',
        gridSize: 3,
        createdAt: DateTime.now(),
        grid: [
          ['A', null, 'C'], // middle cell is black
          ['D', 'E', 'F'],
          ['G', null, 'I'], // middle cell is black
        ],
        clues: {},
        blackCells: [
          [false, true, false], // row 0, col 1 is black
          [false, false, false],
          [false, true, false], // row 2, col 1 is black
        ],
        difficulty: 1,
        entries: [],
        solutionGrid: [
          ['A', null, 'C'],
          ['D', 'E', 'F'],
          ['G', null, 'I'],
        ],
      );

      final container = ProviderContainer(
        overrides: [
          puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
          flashClearDelayProvider.overrideWithValue(Duration.zero),
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);

      // Act: reset the puzzle
      container.read(gameBoardProvider.notifier).resetPuzzle();

      // Assert: black cells should remain null, white cells should be cleared
      final resetGrid = container.read(gameBoardProvider).grid;
      expect(resetGrid[0][0], isNull); // white cell cleared
      expect(resetGrid[0][1], isNull); // black cell remains null
      expect(resetGrid[0][2], isNull); // white cell cleared
      expect(resetGrid[2][1], isNull); // black cell remains null

      // Black cells structure should be preserved
      final blackCells = container.read(gameBoardProvider).blackCells;
      expect(blackCells[0][1], isTrue);
      expect(blackCells[2][1], isTrue);
      expect(blackCells[0][0], isFalse);
      expect(blackCells[1][1], isFalse);
    });
  });
}
