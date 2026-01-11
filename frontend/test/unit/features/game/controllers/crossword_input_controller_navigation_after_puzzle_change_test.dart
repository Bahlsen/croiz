import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';

GameBoard _makeBoard(String id, String answer) {
  const size = 3;
  final grid = List.generate(size, (_) => List<String?>.filled(size, null));
  final solution = List.generate(size, (_) => List<String?>.filled(size, null));
  for (var i = 0; i < answer.length; i++) {
    final ch = answer[i];
    solution[0][i] = ch;
  }
  final entries = <PuzzleEntryData>[
    PuzzleEntryData(
      number: 1,
      direction: 'across',
      x: 0,
      y: 0,
      length: answer.length,
      answer: answer,
    ),
  ];
  return GameBoard(
    id: id,
    title: 't',
    gridSize: size,
    createdAt: DateTime.now(),
    grid: grid,
    clues: const {},
    blackCells: List.generate(size, (_) => List<bool>.filled(size, false)),
    difficulty: 1,
    entries: entries,
    solutionGrid: solution,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'setLetterAndAdvance works after puzzle change with fresh navigation state',
    () {
      final board1 = _makeBoard('b1', 'ABC');
      final board2 = _makeBoard('b2', 'DEF');

      final container = ProviderContainer(
        overrides: [
          flashClearDelayProvider.overrideWithValue(Duration.zero),
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
          puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board1)),
        ],
      );
      addTearDown(container.dispose);

      // Initialize with board1
      container.read(gameBoardProvider.notifier).setBoard(board1);
      container
          .read(selectedCellProvider.notifier)
          .select(const SelectedCell(0, 0));
      container
          .read(wordDirectionProvider.notifier)
          .setDirection(WordDirection.horizontal);

      final controller = CrosswordInputController.fromContainer(container)
        ..setLetterAndAdvance('A');
      final sel1 = container.read(selectedCellProvider);
      expect(sel1, isNotNull);
      expect(sel1!.row, equals(0));
      expect(sel1.col, equals(1));

      // Simulate loading board2
      container.read(gameBoardProvider.notifier).setBoard(board2);
      container.read(selectedCellProvider.notifier).select(null);
      controller
        ..resetNavigationState()
        ..setLetterAndAdvance('D');

      final sel2 = container.read(selectedCellProvider);
      expect(sel2, isNotNull);
      expect(sel2!.row, equals(0));
      expect(sel2.col, equals(1));

      controller.dispose();
    },
  );
}
