import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/main.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/features/game/widgets/crossword_grid.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  testWidgets('tapping same cell toggles word direction', (tester) async {
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

    // Start game (navigate to crossword screen)
    await tester.tap(find.text('Start Game'));
    await tester.pumpAndSettle();

    // Find a selectable cell (GestureDetector in grid)
    final cellFinder = find.byType(GestureDetector).first;
    await tester.tap(cellFinder);
    await tester.pumpAndSettle();

    // Access provider container via grid context
    final gridContext = tester.element(find.byType(CrosswordGrid));
    final container = ProviderScope.containerOf(gridContext);
    expect(container.read(wordDirectionProvider), WordDirection.horizontal);

    // Tap same cell again -> should toggle to vertical
    await tester.tap(cellFinder);
    await tester.pumpAndSettle();
    expect(container.read(wordDirectionProvider), WordDirection.vertical);
  });
}
