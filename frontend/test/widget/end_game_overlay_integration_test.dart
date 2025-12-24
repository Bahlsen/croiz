import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    container.read(foundWordsProvider.notifier).value = <String>{};

    // Build minimal UI with the overlay present
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: EndGameOverlay())),
      ),
    );

    // Initially overlay should not be visible
    final congratsFinder = find.text('Congratulations!');
    expect(congratsFinder, findsNothing);

    // Simulate the controller having completed the single entry by
    // updating the foundWordsProvider; this should make the overlay appear.
    container.read(foundWordsProvider.notifier).value = {'0,0,across'};

    // Allow providers and UI to settle
    await tester.pump();
    await tester.pumpAndSettle();

    // Ensure the provider recorded the found word
    expect(container.read(foundWordsProvider).length, equals(1));

    // Overlay should now be visible
    expect(congratsFinder, findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
  });
}
