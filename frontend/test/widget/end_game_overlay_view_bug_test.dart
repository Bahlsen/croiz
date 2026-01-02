import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/features/game/widgets/end_game_overlay.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  testWidgets(
    'View button should not cause black screen when overlay is not in navigation stack',
    (tester) async {
      final board = GameBoard(
        id: 'test-view-bug',
        title: 'Test View Bug',
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

      // Overlay is not in a navigation stack
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

      expect(find.text('Congratulations!'), findsOneWidget);
      expect(find.text('View'), findsOneWidget);
      expect(find.text('Game Content'), findsOneWidget);

      // Tap View
      await tester.tap(find.text('View'));
      await tester.pumpAndSettle();

      // Overlay should be dismissed, game content visible, no black screen
      expect(find.text('Congratulations!'), findsNothing);
      expect(find.text('Game Content'), findsOneWidget);
    },
  );

  testWidgets(
    'View button should close overlay using Navigator.pop when in navigation stack',
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
      expect(find.text('View'), findsOneWidget);
      expect(find.text('Game Content'), findsOneWidget);

      // Tap View
      await tester.tap(find.text('View'));
      await tester.pumpAndSettle();

      // Overlay should be dismissed, game content visible
      expect(find.text('Congratulations!'), findsNothing);
      expect(find.text('Game Content'), findsOneWidget);
    },
  );
}
