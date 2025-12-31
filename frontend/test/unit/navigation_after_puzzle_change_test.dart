import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  group('Navigation after puzzle change', () {
    test(
      'cellEntriesIndexProvider reflects new puzzle entries after puzzle change',
      () async {
        // Board 1: 3x3 with one across entry at (0,0)
        final board1 = GameBoard(
          id: 'board1',
          title: 'Board 1',
          gridSize: 3,
          createdAt: DateTime.now(),
          grid: List.generate(3, (_) => List<String?>.filled(3, null)),
          clues: const {},
          blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
          difficulty: 1,
          entries: const [
            PuzzleEntryData(
              number: 1,
              direction: 'across',
              x: 0,
              y: 0,
              length: 3,
              answer: 'ABC',
            ),
          ],
          solutionGrid: [
            ['A', 'B', 'C'],
            [null, null, null],
            [null, null, null],
          ],
        );

        // Board 2: 3x3 with different entries - down entry at (1,1)
        final board2 = GameBoard(
          id: 'board2',
          title: 'Board 2',
          gridSize: 3,
          createdAt: DateTime.now(),
          grid: List.generate(3, (_) => List<String?>.filled(3, null)),
          clues: const {},
          blackCells: [
            [true, false, true],
            [false, false, false],
            [true, false, true],
          ],
          difficulty: 1,
          entries: const [
            PuzzleEntryData(
              number: 1,
              direction: 'down',
              x: 1,
              y: 0,
              length: 3,
              answer: 'DEF',
            ),
          ],
          solutionGrid: [
            [null, 'D', null],
            [null, 'E', null],
            [null, 'F', null],
          ],
        );

        var currentBoard = board1;

        final container = ProviderContainer(
          overrides: [
            puzzleLoaderProvider.overrideWith((ref) async => currentBoard),
            flashClearDelayProvider.overrideWithValue(Duration.zero),
            wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
          ],
        );
        addTearDown(container.dispose);

        // Initial load
        await container.read(puzzleLoaderProvider.future);
        await Future.microtask(() {});
        container.read(gameBoardProvider);

        // Verify cellEntriesIndex contains entries from board1
        final index1 = container.read(cellEntriesIndexProvider);
        expect(
          index1[const CellKey(0, 0)],
          isNotEmpty,
          reason: 'Board1 should have entry at (0,0)',
        );
        expect(
          index1[const CellKey(0, 0)]?.first.direction,
          equals('across'),
          reason: 'Board1 entry should be across',
        );

        // Switch to board2
        currentBoard = board2;
        container.refresh(puzzleLoaderProvider);
        await container.read(puzzleLoaderProvider.future);
        await Future.microtask(() {});

        // Force re-read after puzzle change
        final newBoard = container.read(gameBoardProvider);
        expect(newBoard.id, equals('board2'));

        // Verify cellEntriesIndex NOW reflects board2's entries
        final index2 = container.read(cellEntriesIndexProvider);
        expect(
          index2[const CellKey(0, 1)],
          isNotEmpty,
          reason: 'Board2 should have entry at (0,1)',
        );
        expect(
          index2[const CellKey(0, 1)]?.first.direction,
          equals('down'),
          reason: 'Board2 entry should be down',
        );
        // Old board1 entries should NOT be present
        expect(
          index2[const CellKey(0, 0)],
          anyOf(isNull, isEmpty),
          reason:
              'Board2 should NOT have entry at (0,0) - this is a black cell',
        );
      },
    );

    test('navigation uses new blackCells after puzzle change', () async {
      // Board 1: 3x3 no black cells
      final board1 = GameBoard(
        id: 'board1-nav',
        title: 'Board 1',
        gridSize: 3,
        createdAt: DateTime.now(),
        grid: List.generate(3, (_) => List<String?>.filled(3, null)),
        clues: const {},
        blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
        difficulty: 1,
        entries: const [
          PuzzleEntryData(
            number: 1,
            direction: 'across',
            x: 0,
            y: 0,
            length: 3,
            answer: 'ABC',
          ),
        ],
        solutionGrid: [
          ['A', 'B', 'C'],
          [null, null, null],
          [null, null, null],
        ],
      );

      // Board 2: 3x3 with black cell at (0,0)
      final board2 = GameBoard(
        id: 'board2-nav',
        title: 'Board 2',
        gridSize: 3,
        createdAt: DateTime.now(),
        grid: List.generate(3, (_) => List<String?>.filled(3, null)),
        clues: const {},
        blackCells: [
          [true, false, false], // (0,0) is black
          [false, false, false],
          [false, false, false],
        ],
        difficulty: 1,
        entries: const [
          PuzzleEntryData(
            number: 1,
            direction: 'across',
            x: 1,
            y: 0,
            length: 2,
            answer: 'DE',
          ),
        ],
        solutionGrid: [
          [null, 'D', 'E'],
          [null, null, null],
          [null, null, null],
        ],
      );

      var currentBoard = board1;

      final container = ProviderContainer(
        overrides: [
          puzzleLoaderProvider.overrideWith((ref) async => currentBoard),
          flashClearDelayProvider.overrideWithValue(Duration.zero),
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);

      // Initial load
      await container.read(puzzleLoaderProvider.future);
      await Future.microtask(() {});
      container.read(gameBoardProvider);

      final controller = CrosswordInputController.fromContainer(container);
      addTearDown(controller.dispose);

      // In board1, selecting (0,0) should work - it's not black
      container
          .read(selectedCellProvider.notifier)
          .select(const SelectedCell(0, 0));
      container
          .read(wordDirectionProvider.notifier)
          .setDirection(WordDirection.horizontal);

      // Type a letter at (0,0) - should work in board1
      controller.setLetterAndAdvance('A');
      expect(
        container.read(gameBoardProvider).grid[0][0],
        equals('A'),
        reason: 'Board1: (0,0) should accept letter',
      );

      // Switch to board2 - (0,0) is NOW a black cell
      currentBoard = board2;
      container.refresh(puzzleLoaderProvider);
      await container.read(puzzleLoaderProvider.future);
      await Future.microtask(() {});

      // Reset controller state as GameBoardObserver would do
      controller
        ..resetNavigationState()
        ..resetAutoSelectFirstAcross();

      // Clear selection as observer does
      container.read(selectedCellProvider.notifier).select(null);

      final newBoard = container.read(gameBoardProvider);
      expect(newBoard.id, equals('board2-nav'));

      // The first selectable cell should NOT be (0,0) anymore because it's black
      // Auto-select first across should select (0,1) since (0,0) is black
      controller.tryAutoSelectFirstAcross(newBoard);

      final sel = container.read(selectedCellProvider);
      expect(sel, isNotNull, reason: 'Should have auto-selected a cell');
      // Should have selected a non-black cell
      expect(
        newBoard.blackCells[sel!.row][sel.col],
        isFalse,
        reason: 'Selected cell should not be black in board2',
      );
      // Specifically, should NOT select (0,0) which is black in board2
      expect(
        sel.row == 0 && sel.col == 0,
        isFalse,
        reason: 'Should not select (0,0) which is black in board2',
      );
    });

    test(
      'selectedWordCellsProvider reflects new board blackCells after puzzle change',
      () async {
        // Board 1: 3x3 no black cells
        final board1 = GameBoard(
          id: 'word-cells-1',
          title: 'Board 1',
          gridSize: 3,
          createdAt: DateTime.now(),
          grid: List.generate(3, (_) => List<String?>.filled(3, null)),
          clues: const {},
          blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
          difficulty: 1,
          entries: const [
            PuzzleEntryData(
              number: 1,
              direction: 'across',
              x: 0,
              y: 0,
              length: 3,
              answer: 'ABC',
            ),
          ],
          solutionGrid: [
            ['A', 'B', 'C'],
            [null, null, null],
            [null, null, null],
          ],
        );

        // Board 2: 3x3 with black cell at (0,2) - word should be shorter
        final board2 = GameBoard(
          id: 'word-cells-2',
          title: 'Board 2',
          gridSize: 3,
          createdAt: DateTime.now(),
          grid: List.generate(3, (_) => List<String?>.filled(3, null)),
          clues: const {},
          blackCells: [
            [false, false, true], // (0,2) is black
            [false, false, false],
            [false, false, false],
          ],
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
          ],
          solutionGrid: [
            ['A', 'B', null],
            [null, null, null],
            [null, null, null],
          ],
        );

        var currentBoard = board1;

        final container = ProviderContainer(
          overrides: [
            puzzleLoaderProvider.overrideWith((ref) async => currentBoard),
            flashClearDelayProvider.overrideWithValue(Duration.zero),
            wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
          ],
        );
        addTearDown(container.dispose);

        // Initial load
        await container.read(puzzleLoaderProvider.future);
        await Future.microtask(() {});
        container.read(gameBoardProvider);

        // Select (0,0) horizontal in board1 - word should span 3 cells
        container
            .read(selectedCellProvider.notifier)
            .select(const SelectedCell(0, 0));
        container
            .read(wordDirectionProvider.notifier)
            .setDirection(WordDirection.horizontal);

        final wordCells1 = container.read(selectedWordCellsProvider);
        expect(
          wordCells1.length,
          equals(3),
          reason: 'Board1: word at (0,0) horizontal should have 3 cells',
        );
        expect(wordCells1, contains(const CellKey(0, 2)));

        // Switch to board2
        currentBoard = board2;
        container.refresh(puzzleLoaderProvider);
        await container.read(puzzleLoaderProvider.future);
        await Future.microtask(() {});

        final newBoard = container.read(gameBoardProvider);
        expect(newBoard.id, equals('word-cells-2'));

        // Re-select (0,0) horizontal after puzzle change (selection is cleared)
        container
            .read(selectedCellProvider.notifier)
            .select(const SelectedCell(0, 0));
        container
            .read(wordDirectionProvider.notifier)
            .setDirection(WordDirection.horizontal);

        // Keep same selection (0,0) horizontal - word should now be 2 cells
        // because (0,2) is black
        final wordCells2 = container.read(selectedWordCellsProvider);
        expect(
          wordCells2.length,
          equals(2),
          reason:
              'Board2: word at (0,0) horizontal should have 2 cells (not 3, because (0,2) is black)',
        );
        expect(
          wordCells2,
          isNot(contains(const CellKey(0, 2))),
          reason: 'Board2: (0,2) should not be in word - it is black',
        );
      },
    );
  });
}
