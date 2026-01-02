import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/features/game/widgets/end_game_overlay.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  testWidgets(
    'Restart button should reset puzzle and overlay disappears naturally',
    (tester) async {
      final board = GameBoard(
        id: 'test-restart-bug',
        title: 'Test Restart Bug',
        gridSize: 3,
        createdAt: DateTime.now(),
        grid: [
          ['A', 'B', 'C'], // completed word
          [null, null, null],
          [null, null, null],
        ],
        clues: {},
        blackCells: [
          [false, false, false],
          [false, false, false],
          [false, false, false],
        ],
        difficulty: 1,
        entries: [
          const PuzzleEntryData(
            number: 1,
            direction: 'across',
            x: 0,
            y: 0,
            length: 3,
            answer: 'ABC',
          ),
        ],
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

      // Mark the word as found to show the overlay
      container.read(foundWordsProvider.notifier).setFoundWords({'0,0,across'});

      // Build UI with a proper navigation context (using MaterialApp)
      // The overlay should be embedded in a page with proper routing
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Sizer(
            builder:
                (context, orientation, deviceType) => const MaterialApp(
                  home: Scaffold(
                    body: Stack(
                      children: [
                        Center(child: Text('Game Content')),
                        EndGameOverlay(),
                      ],
                    ),
                  ),
                ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify overlay is showing
      expect(find.text('Congratulations!'), findsOneWidget);
      expect(find.text('Restart'), findsOneWidget);
      expect(find.text('Game Content'), findsOneWidget);

      // Verify initial state has progress
      expect(container.read(foundWordsProvider).length, equals(1));
      expect(container.read(gameBoardProvider).grid[0][0], equals('A'));

      // Tap the Restart button
      await tester.tap(find.text('Restart'));
      await tester.pumpAndSettle();

      // After restart, the overlay should disappear (because foundWords is now empty)
      // and we should see the underlying game content without any black screen
      expect(find.text('Congratulations!'), findsNothing);
      expect(find.text('Game Content'), findsOneWidget);

      // Verify all state is reset
      expect(container.read(foundWordsProvider), isEmpty);
      expect(container.read(lockedCellsProvider), isEmpty);

      // Grid should be cleared
      final resetGrid = container.read(gameBoardProvider).grid;
      for (var r = 0; r < resetGrid.length; r++) {
        for (var c = 0; c < resetGrid[r].length; c++) {
          expect(
            resetGrid[r][c],
            isNull,
            reason: 'Cell at ($r,$c) should be null after reset',
          );
        }
      }
    },
  );

  testWidgets(
    'View button should close overlay using Navigator.pop without resetting',
    (tester) async {
      final board = GameBoard(
        id: 'test-view-nav',
        title: 'Test View Navigation',
        gridSize: 3,
        createdAt: DateTime.now(),
        grid: [
          ['A', 'B', 'C'],
          [null, null, null],
          [null, null, null],
        ],
        clues: {},
        blackCells: [
          [false, false, false],
          [false, false, false],
          [false, false, false],
        ],
        difficulty: 1,
        entries: [
          const PuzzleEntryData(
            number: 1,
            direction: 'across',
            x: 0,
            y: 0,
            length: 3,
            answer: 'ABC',
          ),
        ],
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

      container.read(foundWordsProvider.notifier).setFoundWords({'0,0,across'});

      // Show overlay in a dialog-like context where pop() makes sense
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Sizer(
            builder:
                (context, orientation, deviceType) => MaterialApp(
                  home: Builder(
                    builder:
                        (context) => const Scaffold(
                          body: Stack(
                            children: [
                              Center(child: Text('Game Content')),
                              EndGameOverlay(),
                            ],
                          ),
                        ),
                  ),
                ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Congratulations!'), findsOneWidget);
      expect(container.read(foundWordsProvider).length, equals(1));

      // Tap View - should just dismiss overlay, keeping the game state
      await tester.tap(find.text('View'));
      await tester.pumpAndSettle();

      // Progress should be preserved
      expect(container.read(foundWordsProvider).length, equals(1));
      expect(container.read(gameBoardProvider).grid[0][0], equals('A'));
    },
  );
}
