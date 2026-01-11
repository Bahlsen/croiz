import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import '../test_utils/test_board.dart';
import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('typing on filled cell replaces and advances to next editable', () {
    final board = makeEmptyBoard();
    final container = createTestContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
      ],
    );
    addTearDown(container.dispose);

    // Pre-fill (0,0)
    container.read(gameBoardProvider.notifier).setLetter(0, 0, 'X');
    container
        .read(selectedCellProvider.notifier)
        .select(const SelectedCell(0, 0));

    CrosswordInputController.fromContainer(container).setLetterAndAdvance('A');

    final sel = container.read(selectedCellProvider);
    // After replacing, selection should move to next editable cell
    expect(sel, isNotNull);
    expect(sel!.row == 0 && sel.col == 0, isFalse);
    final boardAfter = container.read(gameBoardProvider);
    expect(boardAfter.grid[0][0], 'A');
  });

  test('typing on empty cell advances to next editable', () {
    final board = makeEmptyBoard();
    final container = createTestContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
      ],
    );
    addTearDown(container.dispose);

    container
        .read(selectedCellProvider.notifier)
        .select(const SelectedCell(0, 0));

    CrosswordInputController.fromContainer(container).setLetterAndAdvance('A');

    final sel = container.read(selectedCellProvider);
    // Should have advanced to next editable cell
    expect(sel, isNotNull);
    expect(sel!.row == 0 && sel.col == 0, isFalse);
  });

  test('typing twice starting at last cell should advance twice', () {
    // Setup a board with two across words: [0..2] and [3..4]
    const size = 5;
    final grid = List.generate(size, (_) => List<String?>.filled(size, null));
    final black = List.generate(size, (_) => List<bool>.filled(size, false));
    final boardWithEntries = GameBoard(
      id: 'test-double',
      title: 'double',
      gridSize: size,
      createdAt: DateTime.now(),
      grid: grid,
      clues: const {},
      blackCells: black,
      difficulty: 1,
      entries: const [
        PuzzleEntryData(number: 1, direction: 'across', x: 0, y: 0, length: 3),
        PuzzleEntryData(number: 2, direction: 'across', x: 3, y: 0, length: 2),
      ],
    );

    final container = createTestContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(
          AsyncValue.data(boardWithEntries),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Select last cell of first word (0,2)
    container
        .read(selectedCellProvider.notifier)
        .select(const SelectedCell(0, 2));

    final controller = CrosswordInputController.fromContainer(container)
      ..setLetterAndAdvance('A');
    var sel = container.read(selectedCellProvider)!;
    expect(sel.row, 0);
    expect(sel.col, 3);

    // Second type: should fill (0,3) and advance to (0,4)
    controller.setLetterAndAdvance('B');
    sel = container.read(selectedCellProvider)!;
    expect(sel.row, 0);
    expect(sel.col, 4);
  });
}
