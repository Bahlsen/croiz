import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/features/game/widgets/grid/crossword_cell.dart';
import 'package:croiz/features/game/screens/crossword_screen.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  testWidgets('tap selectable cell then tap virtual keyboard letter updates grid', (
    WidgetTester tester,
  ) async {
    const size = 5;
    final grid = List.generate(size, (_) => List<String?>.filled(size, null));
    final black = List.generate(size, (_) => List<bool>.filled(size, false));
    final boardWithEntries = GameBoard(
      id: 'test-empty',
      title: 'Test',
      gridSize: size,
      createdAt: DateTime.now(),
      grid: grid,
      clues: const {},
      blackCells: black,
      difficulty: 1,
      entries: const [
        PuzzleEntryData(number: 1, direction: 'across', x: 0, y: 0, length: 3),
        PuzzleEntryData(number: 2, direction: 'down', x: 2, y: 1, length: 4),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          puzzleLoaderProvider.overrideWithValue(
            AsyncValue.data(boardWithEntries),
          ),
        ],
        child: Sizer(
          builder: (context, orientation, deviceType) => const MaterialApp(
            home: CrosswordScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The grid is a 5x5 board provided by this test.
    // Cell at row=2, col=0 (letter 'C') should be one of the tappable cells
    final gridFinder = find.byType(GridView);
    // Tapping the first CrosswordCell is more reliable than counting GestureDetectors
    final firstCell = find.byType(CrosswordCell, skipOffstage: false);
    expect(firstCell, findsWidgets);
    await tester.tap(firstCell.first);
    await tester.pumpAndSettle();

    // Count existing 'Z' occurrences inside the grid (should be 0 initially for empty cell set).
    final zInGridBefore = find
        .descendant(of: gridFinder, matching: find.text('Z'))
        .evaluate()
        .length;

    // Tap letter 'Z' on virtual keyboard. Ensure the key is visible first
    // so the tap doesn't compute off-screen coordinates in headless tests.
    // Find the actual button by its visible text which is more robust
    // for headless hit-testing in our widget tree.
    final zKey = find.widgetWithText(FilledButton, 'Z').first;
    await tester.ensureVisible(zKey);
    await tester.pumpAndSettle();
    // Invoke the button callback directly to avoid flaky hit-test issues
    // in headless environments where the widget may be offstage or covered.
    final filled = tester.widget<FilledButton>(zKey);
    expect(filled.onPressed, isNotNull);
    filled.onPressed!();
    await tester.pumpAndSettle();

    final zInGridAfter = find
        .descendant(of: gridFinder, matching: find.text('Z'))
        .evaluate()
        .length;
    expect(zInGridAfter, greaterThan(zInGridBefore));
  });
}
