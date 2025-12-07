import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  test('flashing cells clear after delay when a word is completed', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Build a simple 3x3 board with a single across entry at (0,0) length 3
    const size = 3;
    final grid = List.generate(size, (_) => List<String?>.filled(size, null));
    final solution = List.generate(
      size,
      (_) => List<String?>.filled(size, null),
    );
    // solution word ABC at row 0
    solution[0][0] = 'A';
    solution[0][1] = 'B';
    solution[0][2] = 'C';

    const entry = PuzzleEntryData(
      number: 1,
      direction: 'across',
      x: 0,
      y: 0,
      length: 3,
      answer: 'ABC',
    );

    final board = GameBoard(
      id: 'test',
      title: 'test',
      gridSize: size,
      createdAt: DateTime.now(),
      grid: grid,
      clues: {},
      blackCells: List.generate(size, (_) => List<bool>.filled(size, false)),
      difficulty: 1,
      entries: [entry],
      solutionGrid: solution,
    );

    // Inject board into provider state
    container.read(gameBoardProvider.notifier).state = board;

    // select first cell and horizontal direction
    container.read(selectedCellProvider.notifier).value = const SelectedCell(
      0,
      0,
    );
    container.read(wordDirectionProvider.notifier).value =
        WordDirection.horizontal;

    final controller = CrosswordInputController.fromContainer(container);

    // Use fake async so we can advance timers deterministically
    fakeAsync((async) {
      // Type the three letters of the word
      controller
        ..setLetterAndAdvance('A')
        ..setLetterAndAdvance('B')
        ..setLetterAndAdvance('C');

      // Immediately after completing, flashingCellsProvider should contain the 3 cell keys
      final flashingNow = container.read(flashingCellsProvider);
      expect(flashingNow.length, 3);
      expect(flashingNow, containsAll(['0,0', '0,1', '0,2']));

      // Advance time by 500ms (the controller clears after 500ms)
      async.elapse(const Duration(milliseconds: 500));

      // Now provider should be empty
      final flashingLater = container.read(flashingCellsProvider);
      expect(flashingLater, isEmpty);
    });
  });
}
