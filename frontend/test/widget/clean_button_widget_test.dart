import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/widgets/in_game_text_input.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  testWidgets('Clear button clears incorrect letters and flashes cells', (
    WidgetTester tester,
  ) async {
    // Prepare a small board with a wrong letter at 0,1
    const entries = [
      PuzzleEntryData(
        number: 1,
        direction: 'across',
        x: 0,
        y: 0,
        length: 3,
        answer: 'CAT',
      ),
    ];

    final initialGrid = [
      ['C', 'X', 'T'],
      [null, null, null],
      [null, null, null],
    ];

    final board = GameBoard(
      id: 't',
      title: 't',
      gridSize: 3,
      createdAt: DateTime.now(),
      grid: initialGrid,
      clues: {},
      blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
      difficulty: 1,
      entries: entries,
    );

    // Create a ProviderContainer overriding the puzzleLoaderProvider so
    // the GameBoardNotifier.build() returns our test board.
    final container = ProviderContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
      ],
    );
    addTearDown(container.dispose);

    // Build widget tree with our ProviderContainer using UncontrolledProviderScope
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: InGameTextInput(controller: TextEditingController()),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Ensure the Clear button exists
    final nettoyButton = find.text('Clear');
    expect(nettoyButton, findsOneWidget);

    // Ensure the button exists and is tappable (UI presence)
    expect(nettoyButton, findsOneWidget);

    // Call the notifier directly to simulate the action and validate behavior
    container.read(gameBoardProvider.notifier).clearIncorrectLetters();
    await tester.pumpAndSettle();

    // After action, flashingClearedCellsProvider should contain '0,1'
    final flashing = container.read(flashingClearedCellsProvider);
    expect(flashing.contains('0,1'), isTrue);

    // The game board should have cleared the incorrect letter at 0,1
    final updated = container.read(gameBoardProvider);
    expect(updated.grid[0][1], isNull);

    // Advance time to allow the flash to be cleared (700ms in implementation)
    await tester.pump(const Duration(milliseconds: 800));
    final flashingAfter = container.read(flashingClearedCellsProvider);
    expect(flashingAfter, isEmpty);

    // Also ensure tapping again does not throw (smoke test)
    await tester.tap(nettoyButton);
    await tester.pumpAndSettle();
  });
}
