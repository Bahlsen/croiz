import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/widgets/end_game_overlay.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  testWidgets('EndGameOverlay appears when revealAll is called', (
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
      solutionGrid: [
        ['A', 'B', 'C'],
        ['D', 'E', 'F'],
        ['G', 'H', 'I'],
      ],
    );

    final container = ProviderContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        // Make flashing/persistence deterministic in tests
        flashClearDelayProvider.overrideWithValue(Duration.zero),
        wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
      ],
    );
    addTearDown(container.dispose);

    // Start with no found words
    container.read(foundWordsProvider.notifier).value = <String>{};

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: EndGameOverlay())),
      ),
    );

    final congratsFinder = find.text('Congratulations!');
    expect(congratsFinder, findsNothing);

    // Call revealAll on the notifier
    container.read(gameBoardProvider.notifier).revealAll();

    // Allow providers and UI to settle
    await tester.pump();

    // The provider should have recorded the found word(s)
    expect(container.read(foundWordsProvider).length, equals(1));

    // Allow timers (flash/persist) to run
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // Now the overlay should appear
    expect(congratsFinder, findsOneWidget);
  });
}
