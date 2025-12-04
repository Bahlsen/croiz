import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/main.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/features/game/widgets/grid/crossword_grid.dart';
import 'package:croiz/features/game/widgets/grid/crossword_cell.dart';
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

    // Access provider container via grid context so we can ensure no
    // pre-selection interferes with the test.
    final gridContext = tester.element(find.byType(CrosswordGrid));
    final container = ProviderScope.containerOf(gridContext);
    // Ensure no cell is pre-selected
    container.read(selectedCellProvider.notifier).value = null;

    // Find a selectable cell and tap it (first CrosswordCell is reliable)
    final cellFinder = find.byType(CrosswordCell).first;
    await tester.tap(cellFinder);
    await tester.pumpAndSettle();
    final firstDir = container.read(wordDirectionProvider);

    // Tap same cell again -> direction should toggle
    await tester.tap(cellFinder);
    await tester.pumpAndSettle();
    final secondDir = container.read(wordDirectionProvider);
    expect(secondDir, isNot(equals(firstDir)));
  });
}
