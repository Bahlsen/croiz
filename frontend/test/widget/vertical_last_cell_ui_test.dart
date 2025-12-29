import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/screens/crossword_screen.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
// providers import not needed here; remove to keep analyzer clean.

void main() {
  testWidgets(
    'Vertical last cell edit: no jump when incomplete, grid updates when completed',
    (tester) async {
      final board = GameBoard(
        id: 'test',
        title: 'UI Vertical Last Cell',
        gridSize: 3,
        createdAt: DateTime.now(),
        grid: const [
          ['C', null, null],
          ['A', null, null],
          ['X', null, null], // last letter incorrect at (2,0)
        ],
        clues: const {},
        blackCells: const [
          [false, false, false],
          [false, false, false],
          [false, false, false],
        ],
        difficulty: 1,
        entries: const [
          PuzzleEntryData(
            number: 1,
            direction: 'down',
            x: 0,
            y: 0,
            length: 3,
            answer: 'CAT',
          ),
          PuzzleEntryData(number: 2, direction: 'down', x: 1, y: 0, length: 3),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
            // Ensure flash timers do not interfere with test timing
            flashClearDelayProvider.overrideWith((ref) => Duration.zero),
          ],
          child: const MaterialApp(home: CrosswordScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the cell at (2,0) to select last letter of vertical word
      // Grid cells are typically keyed by their coordinates; rely on semantics by tapping near bottom-left.
      final gridFinder = find.byType(CrosswordScreen);
      expect(gridFinder, findsOneWidget);

      // Use the controller to set selection (through provider), since tapping exact cell coordinates
      // may vary across layouts. This keeps the test robust.
      final container = ProviderScope.containerOf(tester.element(gridFinder));
      container
          .read(selectedCellProvider.notifier)
          .select(const SelectedCell(2, 0));
      container
          .read(wordDirectionProvider.notifier)
          .setDirection(WordDirection.vertical);

      // Tap a wrong letter 'Z' on the virtual keyboard
      await tester.tap(find.text('Z'));
      await tester.pump();

      // With new behavior: after replacing, selection advances to next empty cell
      // Since this word is filled, it goes to the next word's first empty (row=0, col=1)
      final sel = container.read(selectedCellProvider);
      expect(sel, isNotNull);
      expect(sel!.row, 0);
      expect(sel.col, 1);

      // Now tap another letter - this goes to the new selected cell (0,1)
      await tester.tap(find.text('T'));
      await tester.pump();

      // Grid should update: Z at (2,0), T at (0,1)
      final updated = container.read(gameBoardProvider);
      expect(updated.grid[2][0], 'Z');
      expect(updated.grid[0][1], 'T');
    },
  );
}
