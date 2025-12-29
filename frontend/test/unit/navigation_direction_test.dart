// ignore_for_file: cascade_invocations
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';

void main() {
  test('keeps same direction when advancing to next word if available', () {
    final container = ProviderContainer(
      overrides: [
        wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        flashClearDelayProvider.overrideWithValue(Duration.zero),
      ],
    );
    addTearDown(container.dispose);
    final read = container.read;
    final boardNotifier = read(gameBoardProvider.notifier);
    final selectedNotifier = read(selectedCellProvider.notifier);
    final wordDirectionNotifier = read(wordDirectionProvider.notifier);

    // Build 5x1 columns grid where there are two vertical words at different columns
    const size = 5;
    final grid = List.generate(size, (_) => List<String?>.filled(size, null));
    final solution = List.generate(
      size,
      (_) => List<String?>.filled(size, null),
    );

    // Vertical word 1 at column 0, rows 0-1 (length 2): AB
    solution[0][0] = 'A';
    solution[1][0] = 'B';
    // Vertical word 2 at column 2, rows 0-1 (length 2): CD
    solution[0][2] = 'C';
    solution[1][2] = 'D';

    final board = GameBoard(
      id: 'nav-dir',
      title: 'nav-dir',
      gridSize: size,
      createdAt: DateTime.now(),
      grid: grid,
      clues: const {},
      blackCells: List.generate(size, (_) => List<bool>.filled(size, false)),
      difficulty: 1,
      entries: const [
        PuzzleEntryData(
          number: 1,
          direction: 'down',
          x: 0,
          y: 0,
          length: 2,
          answer: 'AB',
        ),
        PuzzleEntryData(
          number: 2,
          direction: 'down',
          x: 2,
          y: 0,
          length: 2,
          answer: 'CD',
        ),
      ],
      solutionGrid: solution,
    );

    boardNotifier.setBoard(board);
    // Select the last cell of the first vertical word (row 1, col 0)
    selectedNotifier.select(const SelectedCell(1, 0));
    wordDirectionNotifier.setDirection(WordDirection.vertical);

    final controller = CrosswordInputController.fromContainer(container);
    controller.setLetterAndAdvance('B');

    // Expect direction to remain vertical
    expect(read(wordDirectionProvider), WordDirection.vertical);

    // Expect selection to move to the first empty cell of the next vertical word
    final sel = read(selectedCellProvider);
    expect(sel, isNotNull);
    expect(sel!.col, 2);
    expect(sel.row, 0);
  });
}
