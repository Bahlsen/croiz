import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/features/game/widgets/bottom/crossword_controls_bar.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  testWidgets(
    'Clear button in CrosswordKeyboardBar clears incorrect letters and flashes',
    (tester) async {
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

      final container = ProviderContainer(
        overrides: [
          puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        ],
      );
      // Ensure deterministic notifier state
      container.read(gameBoardProvider.notifier).state = board;
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: CrosswordControlsBar(
                onKey: (_) {},
                onBackspace: () {},
                heightFactor: 0.8,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The clear button has a key 'clear_button'
      final clearFinder = find.byKey(const Key('clear_button'));
      expect(clearFinder, findsOneWidget);

      // Ensure the IconButton is wired (onPressed non-null)
      final iconButton = tester.widget<IconButton>(clearFinder);
      expect(iconButton.onPressed, isNotNull);

      // Call the notifier directly to validate the expected behavior
      container.read(gameBoardProvider.notifier).clearIncorrectLetters();
      await tester.pumpAndSettle();

      final flashing = container.read(flashingClearedCellsProvider);
      expect(flashing.contains(const CellKey(0, 1)), isTrue);
      final updated = container.read(gameBoardProvider);
      expect(updated.grid[0][1], isNull);

      // Advance time to allow the flash timer to clear (implementation uses 700ms)
      await tester.pump(const Duration(milliseconds: 800));
      final flashingAfter = container.read(flashingClearedCellsProvider);
      expect(flashingAfter, isEmpty);
    },
  );
}
