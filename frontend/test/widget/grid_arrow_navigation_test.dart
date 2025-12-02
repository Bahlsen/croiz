import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/main.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/features/game/widgets/crossword_grid.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  testWidgets('arrow right moves selection to next non-black cell', (
    tester,
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
          puzzleLoaderProvider.overrideWith((ref) async => boardWithEntries),
        ],
        child: const CroizApp(),
      ),
    );
    await tester.tap(find.text('Start Game'));
    await tester.pumpAndSettle();

    // Select first selectable cell
    final firstCell = find.byType(GestureDetector).first;
    await tester.tap(firstCell);
    await tester.pumpAndSettle();
    final gridContext = tester.element(find.byType(CrosswordGrid));
    final container = ProviderScope.containerOf(gridContext);
    final initial = container.read(selectedCellProvider);
    expect(initial, isNotNull);

    // Send arrow right key
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    final after = container.read(selectedCellProvider);

    // Ensure either column advanced or wrapped to different row/col
    expect(after, isNotNull);
    expect(!(after!.row == initial!.row && after.col == initial.col), isTrue);
  });
}
