// ignore_for_file: cascade_invocations
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  group('Navigation direction robustness', () {
    test('vertical: preserve direction when next vertical word exists', () {
      final container = ProviderContainer(
        overrides: [
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
          flashClearDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);
      final read = container.read;

      const size = 5;
      final grid = List.generate(size, (_) => List<String?>.filled(size, null));
      final solution = List.generate(
        size,
        (_) => List<String?>.filled(size, null),
      );

      // two vertical words: col0 rows0-1 (AB), col2 rows0-1 (CD)
      solution[0][0] = 'A';
      solution[1][0] = 'B';
      solution[0][2] = 'C';
      solution[1][2] = 'D';

      final board = GameBoard(
        id: 'v-preserve',
        title: 'v-preserve',
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

      final boardNotifier = read(gameBoardProvider.notifier);
      final selectedNotifier = read(selectedCellProvider.notifier);
      final wordDirectionNotifier = read(wordDirectionProvider.notifier);

      boardNotifier.board = board;
      selectedNotifier.value = const SelectedCell(
        1,
        0,
      );
      wordDirectionNotifier.value = WordDirection.vertical;

        final controller = CrosswordInputController.fromContainer(container);
        controller.setLetterAndAdvance('B');

        expect(wordDirectionNotifier.value, WordDirection.vertical);
        final sel = selectedNotifier.value;
        expect(sel, isNotNull);
        expect(sel!.col, 2);
        expect(sel.row, 0);
    });

    test('vertical: switch to horizontal when no other vertical exists', () {
      final container = ProviderContainer(
        overrides: [
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
          flashClearDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);
      final read = container.read;

      const size = 3;
      final grid = List.generate(size, (_) => List<String?>.filled(size, null));
      final solution = List.generate(
        size,
        (_) => List<String?>.filled(size, null),
      );

      // single vertical at col0 rows0-1 (AB)
      solution[0][0] = 'A';
      solution[1][0] = 'B';
      // horizontal entry at row2 col1-2 (EF)
      solution[2][1] = 'E';
      solution[2][2] = 'F';

      final board = GameBoard(
        id: 'v-switch',
        title: 'v-switch',
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
            direction: 'across',
            x: 1,
            y: 2,
            length: 2,
            answer: 'EF',
          ),
        ],
        solutionGrid: solution,
      );

      final boardNotifier = read(gameBoardProvider.notifier);
      final selectedNotifier = read(selectedCellProvider.notifier);
      final wordDirectionNotifier = read(wordDirectionProvider.notifier);

      boardNotifier.board = board;
      selectedNotifier.value = const SelectedCell(
        1,
        0,
      );
      wordDirectionNotifier.value = WordDirection.vertical;

        final controller = CrosswordInputController.fromContainer(container);
        controller.setLetterAndAdvance('B');

        // Should switch to horizontal because no vertical word remains
        expect(wordDirectionNotifier.value, WordDirection.horizontal);
        final sel = selectedNotifier.value;
        expect(sel, isNotNull);
        expect(sel!.row, 2);
        expect(sel.col, 1);
    });

    test('horizontal: preserve direction when next horizontal word exists', () {
      final container = ProviderContainer(
        overrides: [
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
          flashClearDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);
      final read = container.read;

      const size = 5;
      final grid = List.generate(size, (_) => List<String?>.filled(size, null));
      final solution = List.generate(
        size,
        (_) => List<String?>.filled(size, null),
      );

      // two horizontal words: row0 cols0-1 (AB), row2 cols0-1 (CD)
      solution[0][0] = 'A';
      solution[0][1] = 'B';
      solution[2][0] = 'C';
      solution[2][1] = 'D';

      final board = GameBoard(
        id: 'h-preserve',
        title: 'h-preserve',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: grid,
        clues: const {},
        blackCells: List.generate(size, (_) => List<bool>.filled(size, false)),
        difficulty: 1,
        entries: const [
          PuzzleEntryData(
            number: 1,
            direction: 'across',
            x: 0,
            y: 0,
            length: 2,
            answer: 'AB',
          ),
          PuzzleEntryData(
            number: 2,
            direction: 'across',
            x: 0,
            y: 2,
            length: 2,
            answer: 'CD',
          ),
        ],
        solutionGrid: solution,
      );

      final boardNotifier = read(gameBoardProvider.notifier);
      final selectedNotifier = read(selectedCellProvider.notifier);
      final wordDirectionNotifier = read(wordDirectionProvider.notifier);

      boardNotifier.board = board;
      selectedNotifier.value = const SelectedCell(
        0,
        1,
      );
      wordDirectionNotifier.value = WordDirection.horizontal;

      final controller = CrosswordInputController.fromContainer(container);
      controller.setLetterAndAdvance('B');

      expect(wordDirectionNotifier.value, WordDirection.horizontal);
      final sel = selectedNotifier.value;
      expect(sel, isNotNull);
      expect(sel!.row, 2);
      expect(sel.col, 0);
    });

    test('horizontal: switch to vertical when no other horizontal exists', () {
      final container = ProviderContainer(
        overrides: [
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
          flashClearDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);
      final read = container.read;

      const size = 3;
      final grid = List.generate(size, (_) => List<String?>.filled(size, null));
      final solution = List.generate(
        size,
        (_) => List<String?>.filled(size, null),
      );

      // single horizontal at row0 cols0-1 (AB)
      solution[0][0] = 'A';
      solution[0][1] = 'B';
      // vertical entry at col2 rows1-2 (CD)
      solution[1][2] = 'C';
      solution[2][2] = 'D';

      final board = GameBoard(
        id: 'h-switch',
        title: 'h-switch',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: grid,
        clues: const {},
        blackCells: List.generate(size, (_) => List<bool>.filled(size, false)),
        difficulty: 1,
        entries: const [
          PuzzleEntryData(
            number: 1,
            direction: 'across',
            x: 0,
            y: 0,
            length: 2,
            answer: 'AB',
          ),
          PuzzleEntryData(
            number: 2,
            direction: 'down',
            x: 2,
            y: 1,
            length: 2,
            answer: 'CD',
          ),
        ],
        solutionGrid: solution,
      );

      final boardNotifier = read(gameBoardProvider.notifier);
      final selectedNotifier = read(selectedCellProvider.notifier);
      final wordDirectionNotifier = read(wordDirectionProvider.notifier);

      boardNotifier.board = board;
      selectedNotifier.value = const SelectedCell(
        0,
        1,
      );
      wordDirectionNotifier.value = WordDirection.horizontal;

      final controller = CrosswordInputController.fromContainer(container);
      controller.setLetterAndAdvance('B');

      expect(wordDirectionNotifier.value, WordDirection.vertical);
      final sel = selectedNotifier.value;
      expect(sel, isNotNull);
      expect(sel!.col, 2);
      expect(sel.row, 1);
    });
  });
}
