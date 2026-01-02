import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/features/game/widgets/end_game_overlay.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  testWidgets('EndGameOverlay appears when controller completes all words', (
    tester,
  ) async {
    final board = GameBoard(
      id: 'test',
      title: 'T',
      gridSize: 3,
      createdAt: DateTime.now(),
      grid: [
        [null, null, null],
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
        ),
      ],
    );

    final container = ProviderContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
      ],
    );
    addTearDown(container.dispose);

    // Ensure the provider starts empty to match expected initial state.
    container.read(foundWordsProvider.notifier).setFoundWords(<String>{});

    // Build minimal UI with the overlay present
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Sizer(
          builder:
              (context, orientation, deviceType) =>
                  const MaterialApp(home: Scaffold(body: EndGameOverlay())),
        ),
      ),
    );

    // Initially overlay should not be visible
    final congratsFinder = find.text('Congratulations!');
    expect(congratsFinder, findsNothing);

    // Simulate the controller having completed the single entry by
    // updating the foundWordsProvider; this should make the overlay appear.
    container.read(foundWordsProvider.notifier).setFoundWords({'0,0,across'});

    // Allow providers and UI to settle
    await tester.pump();
    await tester.pumpAndSettle();

    // Ensure the provider recorded the found word
    expect(container.read(foundWordsProvider).length, equals(1));

    // Overlay should now be visible
    expect(congratsFinder, findsOneWidget);
    expect(find.text('View'), findsOneWidget);
    expect(find.text('Restart'), findsOneWidget);
  });

  testWidgets('Restart button resets puzzle and clears progress', (
    tester,
  ) async {
    final board = GameBoard(
      id: 'test-reset',
      title: 'Test Reset',
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

    // Build UI
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Sizer(
          builder:
              (context, orientation, deviceType) =>
                  const MaterialApp(home: Scaffold(body: EndGameOverlay())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify overlay is showing
    expect(find.text('Congratulations!'), findsOneWidget);
    expect(find.text('Restart'), findsOneWidget);

    // Verify initial state has progress
    expect(container.read(foundWordsProvider).length, equals(1));
    expect(container.read(gameBoardProvider).grid[0][0], equals('A'));

    // Tap the Restart button
    await tester.tap(find.text('Restart'));
    await tester.pumpAndSettle();

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
  });

  testWidgets('View button closes overlay without resetting puzzle', (
    tester,
  ) async {
    final board = GameBoard(
      id: 'test-view',
      title: 'Test View',
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

    // Build UI
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Sizer(
          builder:
              (context, orientation, deviceType) =>
                  const MaterialApp(home: Scaffold(body: EndGameOverlay())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify overlay is showing
    expect(find.text('Congratulations!'), findsOneWidget);
    expect(find.text('View'), findsOneWidget);

    // Verify initial state has progress
    expect(container.read(foundWordsProvider).length, equals(1));
    expect(container.read(gameBoardProvider).grid[0][0], equals('A'));
    expect(container.read(gameBoardProvider).grid[0][1], equals('B'));
    expect(container.read(gameBoardProvider).grid[0][2], equals('C'));

    // Tap the View button
    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();

    // Verify state is NOT reset - progress is preserved
    expect(container.read(foundWordsProvider).length, equals(1));
    expect(container.read(gameBoardProvider).grid[0][0], equals('A'));
    expect(container.read(gameBoardProvider).grid[0][1], equals('B'));
    expect(container.read(gameBoardProvider).grid[0][2], equals('C'));

    // Overlay should be dismissed
    expect(find.text('Congratulations!'), findsNothing);
  });
}
