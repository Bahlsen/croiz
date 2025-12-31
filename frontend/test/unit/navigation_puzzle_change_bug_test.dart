// Test to reproduce and fix bug: navigation is broken after puzzle change
// The navigation jumps from one cell to another without logic after changing puzzles.
// Hypothesis: Something is not reinitialized when changing puzzles.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';

/// Helper to create a GameBoard for testing.
GameBoard _makeBoard({
  required String id,
  required int gridSize,
  required List<List<bool>> blackCells,
  required List<PuzzleEntryData> entries,
  required List<List<String?>> solutionGrid,
}) =>
    GameBoard(
      id: id,
      title: 'Test $id',
      gridSize: gridSize,
      createdAt: DateTime.now(),
      grid: List.generate(gridSize, (_) => List<String?>.filled(gridSize, null)),
      clues: const {},
      blackCells: blackCells,
      difficulty: 1,
      entries: entries,
      solutionGrid: solutionGrid,
    );

void main() {
  group('Navigation after puzzle change - bug reproduction', () {
    test(
      'typing letters after puzzle change should navigate correctly within new puzzle entries',
      () async {
        // Board 1: 5x5 with a horizontal word at row 0 (5 letters)
        final board1 = _makeBoard(
          id: 'puzzle1',
          gridSize: 5,
          blackCells: List.generate(5, (_) => List<bool>.filled(5, false)),
          entries: const [
            PuzzleEntryData(
              number: 1,
              direction: 'across',
              x: 0,
              y: 0,
              length: 5,
              answer: 'HELLO',
            ),
            PuzzleEntryData(
              number: 2,
              direction: 'down',
              x: 0,
              y: 0,
              length: 5,
              answer: 'HOUSE',
            ),
          ],
          solutionGrid: [
            ['H', 'E', 'L', 'L', 'O'],
            ['O', null, null, null, null],
            ['U', null, null, null, null],
            ['S', null, null, null, null],
            ['E', null, null, null, null],
          ],
        );

        // Board 2: Different layout - 3x3 with different entries
        // This tests that navigation uses the NEW puzzle's entries, not the old ones
        final board2 = _makeBoard(
          id: 'puzzle2',
          gridSize: 3,
          blackCells: [
            [false, false, true], // (0,2) is black
            [false, false, false],
            [true, false, false], // (2,0) is black
          ],
          entries: const [
            PuzzleEntryData(
              number: 1,
              direction: 'across',
              x: 0,
              y: 0,
              length: 2, // Only 2 cells because (0,2) is black
              answer: 'AB',
            ),
            PuzzleEntryData(
              number: 2,
              direction: 'down',
              x: 0,
              y: 0,
              length: 2, // Only 2 cells because (2,0) is black
              answer: 'AD',
            ),
            PuzzleEntryData(
              number: 3,
              direction: 'across',
              x: 0,
              y: 1,
              length: 3,
              answer: 'DEF',
            ),
          ],
          solutionGrid: [
            ['A', 'B', null],
            ['D', 'E', 'F'],
            [null, 'G', 'H'],
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

        // Initial load of board1
        await container.read(puzzleLoaderProvider.future);
        await Future.microtask(() {});
        container.read(gameBoardProvider);

        final controller = CrosswordInputController.fromContainer(container);
        addTearDown(controller.dispose);

        // Select (0,0) horizontal in board1
        container
            .read(selectedCellProvider.notifier)
            .select(const SelectedCell(0, 0));
        container
            .read(wordDirectionProvider.notifier)
            .setDirection(WordDirection.horizontal);

        // Type letters - should navigate within board1's 5-cell word
        controller.setLetterAndAdvance('H');
        final sel = container.read(selectedCellProvider);
        expect(sel, isNotNull, reason: 'Should have a selection after typing');
        expect(sel!.row, equals(0), reason: 'Row should be 0');
        expect(sel.col, equals(1), reason: 'Should advance to col 1');

        controller.setLetterAndAdvance('E');
        final sel2 = container.read(selectedCellProvider);
        expect(sel2!.col, equals(2), reason: 'Should advance to col 2');

        // ========== NOW SWITCH TO BOARD 2 ==========
        currentBoard = board2;
        container.refresh(puzzleLoaderProvider);
        await container.read(puzzleLoaderProvider.future);
        await Future.microtask(() {});

        // Verify we're on board2
        final newBoard = container.read(gameBoardProvider);
        expect(newBoard.id, equals('puzzle2'), reason: 'Should be on puzzle2');

        // Reset controller state as GameBoardObserver would do
        controller
          ..resetNavigationState()
          ..resetAutoSelectFirstAcross();

        // Clear selection as observer does
        container.read(selectedCellProvider.notifier).select(null);

        // Trigger auto-select first across
        controller.tryAutoSelectFirstAcross(newBoard);

        // Verify that the first across entry in board2 is selected
        final sel3 = container.read(selectedCellProvider);
        expect(sel3, isNotNull, reason: 'Should auto-select a cell');
        expect(sel3!.row, equals(0), reason: 'Should select row 0');
        expect(sel3.col, equals(0), reason: 'Should select col 0');

        // Verify direction is horizontal
        expect(
          container.read(wordDirectionProvider),
          equals(WordDirection.horizontal),
        );

        // BUG REPRODUCTION: Type letters in board2
        // The word at (0,0) horizontal in board2 only has 2 cells (0,0) and (0,1)
        // because (0,2) is black. Navigation should stay within these 2 cells.
        controller.setLetterAndAdvance('A');
        final sel4 = container.read(selectedCellProvider);
        expect(sel4, isNotNull, reason: 'Should have selection after typing A');
        expect(sel4!.row, equals(0), reason: 'Row should be 0');
        expect(
          sel4.col,
          equals(1),
          reason:
              'Should advance to col 1 (next cell in the 2-cell entry at row 0)',
        );

        // Typing the second letter should NOT advance past col 1
        // because the entry only has 2 cells and the next cell (0,2) is black
        controller.setLetterAndAdvance('B');
        final sel5 = container.read(selectedCellProvider);
        expect(sel5, isNotNull, reason: 'Should have selection after typing B');

        // After filling the 2-cell word, it should advance to the next entry
        // which is entry #3 at (0,1) across or stay on the last cell
        // The key point is: it should NOT jump to an invalid cell like (0,2)
        // and should NOT use old board1's entries (which had 5-cell word)

        // Check that the cell (0,2) was NOT selected (it's black in board2)
        expect(
          newBoard.blackCells[0][2],
          isTrue,
          reason: '(0,2) should be black in board2',
        );
        if (sel5!.row == 0 && sel5.col == 2) {
          fail(
            'BUG: Navigation selected black cell (0,2) which should be impossible',
          );
        }

        // The selection should be valid - either on a white cell in board2
        final selectedBlack = newBoard.blackCells[sel5.row][sel5.col];
        expect(
          selectedBlack,
          isFalse,
          reason: 'Selected cell should not be a black cell',
        );
      },
    );

    test(
      'cellEntriesIndex is correctly rebuilt when puzzle changes with different entry structure',
      () async {
        // Board 1: Has entries at specific positions
        final board1 = _makeBoard(
          id: 'index-test-1',
          gridSize: 4,
          blackCells: List.generate(4, (_) => List<bool>.filled(4, false)),
          entries: const [
            PuzzleEntryData(
              number: 1,
              direction: 'across',
              x: 0,
              y: 0,
              length: 4,
              answer: 'TEST',
            ),
          ],
          solutionGrid: [
            ['T', 'E', 'S', 'T'],
            [null, null, null, null],
            [null, null, null, null],
            [null, null, null, null],
          ],
        );

        // Board 2: Completely different entry structure
        final board2 = _makeBoard(
          id: 'index-test-2',
          gridSize: 4,
          blackCells: [
            [true, false, false, true],
            [false, false, false, false],
            [false, false, false, false],
            [true, false, false, true],
          ],
          entries: const [
            PuzzleEntryData(
              number: 1,
              direction: 'across',
              x: 1,
              y: 0,
              length: 2,
              answer: 'AB',
            ),
            PuzzleEntryData(
              number: 2,
              direction: 'down',
              x: 1,
              y: 0,
              length: 4,
              answer: 'ABCD',
            ),
          ],
          solutionGrid: [
            [null, 'A', 'B', null],
            ['X', 'B', 'Y', 'Z'],
            ['X', 'C', 'Y', 'Z'],
            [null, 'D', 'Y', null],
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

        // Load board1
        await container.read(puzzleLoaderProvider.future);
        await Future.microtask(() {});
        container.read(gameBoardProvider);

        // Verify cellEntriesIndex for board1
        var index = container.read(cellEntriesIndexProvider);
        expect(
          index[const CellKey(0, 0)],
          isNotEmpty,
          reason: 'Board1 should have entry at (0,0)',
        );
        expect(
          index[const CellKey(0, 0)]?.first.answer,
          equals('TEST'),
          reason: 'Board1 entry should be TEST',
        );

        // Switch to board2
        currentBoard = board2;
        container.refresh(puzzleLoaderProvider);
        await container.read(puzzleLoaderProvider.future);
        await Future.microtask(() {});

        // Verify gameBoardProvider is updated
        final gb = container.read(gameBoardProvider);
        expect(gb.id, equals('index-test-2'));

        // Verify cellEntriesIndex is now for board2
        index = container.read(cellEntriesIndexProvider);

        // (0,0) should have NO entry in board2 (it's a black cell)
        expect(
          index[const CellKey(0, 0)],
          anyOf(isNull, isEmpty),
          reason: 'Board2: (0,0) is black, should have no entry',
        );

        // (0,1) should have entries in board2
        expect(
          index[const CellKey(0, 1)],
          isNotEmpty,
          reason: 'Board2 should have entries at (0,1)',
        );

        // The entries at (0,1) should be the NEW entries (AB and ABCD), not TEST
        final entriesAt01 = index[const CellKey(0, 1)]!;
        final answers = entriesAt01.map((e) => e.answer).toSet();
        expect(
          answers,
          contains('AB'),
          reason: 'Board2 should have AB entry at (0,1)',
        );
        expect(
          answers,
          contains('ABCD'),
          reason: 'Board2 should have ABCD entry at (0,1)',
        );
        expect(
          answers.contains('TEST'),
          isFalse,
          reason: 'Board2 should NOT have TEST entry (from board1)',
        );
      },
    );

    test(
      'found words and locked cells are cleared when puzzle changes',
      () async {
        final board1 = _makeBoard(
          id: 'state-test-1',
          gridSize: 3,
          blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
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

        final board2 = _makeBoard(
          id: 'state-test-2',
          gridSize: 3,
          blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
          entries: const [
            PuzzleEntryData(
              number: 1,
              direction: 'across',
              x: 0,
              y: 0,
              length: 3,
              answer: 'XYZ',
            ),
          ],
          solutionGrid: [
            ['X', 'Y', 'Z'],
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

        // Load board1
        await container.read(puzzleLoaderProvider.future);
        await Future.microtask(() {});
        container.read(gameBoardProvider);

        // Simulate having found words and locked cells in board1
        container
            .read(foundWordsProvider.notifier)
            .setFoundWords({'0,0,across'});
        container.read(lockedCellsProvider.notifier).setLockedCells({
          const CellKey(0, 0),
          const CellKey(0, 1),
          const CellKey(0, 2),
        });

        // Verify state before switch
        expect(container.read(foundWordsProvider), isNotEmpty);
        expect(container.read(lockedCellsProvider), isNotEmpty);

        // Switch to board2
        currentBoard = board2;
        container.refresh(puzzleLoaderProvider);
        await container.read(puzzleLoaderProvider.future);
        await Future.microtask(() {});
        // Force gameBoardProvider to process the change
        final newBoard = container.read(gameBoardProvider);
        expect(newBoard.id, equals('state-test-2'));
        // Allow async operations to complete
        await Future.delayed(const Duration(milliseconds: 50));

        // BUG TEST: After switching puzzles, foundWords and lockedCells
        // from board1 should be CLEARED, not retained.
        // This is the root cause of the navigation bug.
        expect(
          container.read(foundWordsProvider),
          isEmpty,
          reason: 'BUG: foundWords from board1 should be cleared on puzzle change',
        );
        expect(
          container.read(lockedCellsProvider),
          isEmpty,
          reason: 'BUG: lockedCells from board1 should be cleared on puzzle change',
        );

        // The key test: navigation in board2 should work correctly
        final controller = CrosswordInputController.fromContainer(container);
        addTearDown(controller.dispose);

        controller
          ..resetNavigationState()
          ..resetAutoSelectFirstAcross();
        container.read(selectedCellProvider.notifier).select(null);

        final gb = container.read(gameBoardProvider);
        controller.tryAutoSelectFirstAcross(gb);

        // Should be able to select and type in board2
        final sel1 = container.read(selectedCellProvider);
        expect(sel1, isNotNull);

        // Type a letter - should work because lockedCells should be cleared
        controller.setLetterAndAdvance('X');

        // Should have advanced
        final sel2 = container.read(selectedCellProvider);
        expect(sel2, isNotNull);
        // The grid should have the letter
        expect(container.read(gameBoardProvider).grid[0][0], equals('X'));
      },
    );

    test(
      'setLetterAndAdvance uses current puzzle blackCells not cached old ones',
      () async {
        // Board 1: No black cells
        final board1 = _makeBoard(
          id: 'black-test-1',
          gridSize: 3,
          blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
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

        // Board 2: (0,1) is black - in between (0,0) and (0,2)
        final board2 = _makeBoard(
          id: 'black-test-2',
          gridSize: 3,
          blackCells: [
            [false, true, false], // (0,1) is black
            [false, false, false],
            [false, false, false],
          ],
          entries: const [
            // No across entry at row 0 because (0,1) is black
            PuzzleEntryData(
              number: 1,
              direction: 'down',
              x: 0,
              y: 0,
              length: 3,
              answer: 'ADG',
            ),
            PuzzleEntryData(
              number: 2,
              direction: 'down',
              x: 2,
              y: 0,
              length: 3,
              answer: 'CFI',
            ),
          ],
          solutionGrid: [
            ['A', null, 'C'],
            ['D', 'E', 'F'],
            ['G', 'H', 'I'],
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

        // Load board1 and type some letters
        await container.read(puzzleLoaderProvider.future);
        await Future.microtask(() {});
        container.read(gameBoardProvider);

        final controller = CrosswordInputController.fromContainer(container);
        addTearDown(controller.dispose);

        container
            .read(selectedCellProvider.notifier)
            .select(const SelectedCell(0, 0));
        container
            .read(wordDirectionProvider.notifier)
            .setDirection(WordDirection.horizontal);

        // In board1, typing at (0,0) should advance to (0,1)
        controller.setLetterAndAdvance('A');
        final sel1 = container.read(selectedCellProvider);
        expect(sel1!.col, equals(1), reason: 'Board1: should advance to col 1');

        // Switch to board2
        currentBoard = board2;
        container.refresh(puzzleLoaderProvider);
        await container.read(puzzleLoaderProvider.future);
        await Future.microtask(() {});

        final gb = container.read(gameBoardProvider);
        expect(gb.id, equals('black-test-2'));

        // Reset controller state
        controller
          ..resetNavigationState()
          ..resetAutoSelectFirstAcross();
        container.read(selectedCellProvider.notifier).select(null);

        // Auto-select first entry in board2 (down entry at (0,0))
        controller.tryAutoSelectFirstAcross(gb);

        // If there's no across entry, it should select the first down entry
        // or stay null. Let's manually select (0,0) down
        container
            .read(selectedCellProvider.notifier)
            .select(const SelectedCell(0, 0));
        container
            .read(wordDirectionProvider.notifier)
            .setDirection(WordDirection.vertical);

        // In board2, typing at (0,0) DOWN should advance to (1,0), NOT (0,1)
        // because (0,1) is BLACK in board2
        controller.setLetterAndAdvance('A');
        final sel3 = container.read(selectedCellProvider);

        // BUG CHECK: The selection should NOT be (0,1) which is black
        if (sel3 != null && sel3.row == 0 && sel3.col == 1) {
          fail(
            'BUG: Navigation used old board1 blackCells - selected (0,1) which is black in board2',
          );
        }

        // It should be (1,0) - next cell in the down entry
        expect(
          sel3,
          isNotNull,
          reason: 'Should have a selection after typing',
        );
        expect(
          sel3!.row,
          equals(1),
          reason: 'Board2: DOWN entry should advance to row 1',
        );
        expect(sel3.col, equals(0), reason: 'Board2: should stay in col 0');
      },
    );
  });
}
