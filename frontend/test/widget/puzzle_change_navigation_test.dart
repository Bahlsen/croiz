import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:croiz/features/game/screens/crossword_body.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  group('Puzzle change navigation widget tests', () {
    testWidgets('cell entries index updates when puzzle changes', (
      tester,
    ) async {
      // Board 1: 3x3 with across entry at (0,0) length 3
      final board1 = GameBoard(
        id: 'widget-board1',
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

      // Board 2: 3x3 with down entry at (1,0) length 3 and black cell at (0,0)
      final board2 = GameBoard(
        id: 'widget-board2',
        title: 'Board 2',
        gridSize: 3,
        createdAt: DateTime.now(),
        grid: List.generate(3, (_) => List<String?>.filled(3, null)),
        clues: const {},
        blackCells: [
          [true, false, false],
          [false, false, false],
          [false, false, false],
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

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puzzleLoaderProvider.overrideWith((ref) async => currentBoard),
            flashClearDelayProvider.overrideWithValue(Duration.zero),
            wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
          ],
          child: Sizer(
            builder: (context, orientation, deviceType) => MaterialApp(
              home: Builder(
                builder: (context) => Consumer(
                  builder: (context, ref, _) {
                    final controller = CrosswordInputController(ref);
                    return CrosswordBody(controller: controller);
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify board1 is loaded
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CrosswordBody)),
      );
      expect(container.read(gameBoardProvider).id, equals('widget-board1'));

      // Verify cellEntriesIndex has board1's entry at (0,0)
      final index1 = container.read(cellEntriesIndexProvider);
      expect(
        index1[const CellKey(0, 0)],
        isNotEmpty,
        reason: 'Board1 should have entry at (0,0)',
      );
      expect(index1[const CellKey(0, 0)]?.first.direction, equals('across'));

      // Now switch to board2
      currentBoard = board2;
      container.refresh(puzzleLoaderProvider);
      await tester.pumpAndSettle();

      // Verify board2 is loaded
      expect(container.read(gameBoardProvider).id, equals('widget-board2'));

      // Verify cellEntriesIndex NOW reflects board2's entries
      final index2 = container.read(cellEntriesIndexProvider);
      expect(
        index2[const CellKey(0, 1)],
        isNotEmpty,
        reason: 'Board2 should have entry at (0,1)',
      );
      expect(index2[const CellKey(0, 1)]?.first.direction, equals('down'));
      // (0,0) is black in board2, so should not have entries
      expect(
        index2[const CellKey(0, 0)],
        anyOf(isNull, isEmpty),
        reason: 'Board2 should NOT have entry at (0,0)',
      );
    });

    testWidgets('selected word cells update when puzzle black cells change', (
      tester,
    ) async {
      // Board 1: 3x3 no black cells, word at row 0 has 3 cells
      final board1 = GameBoard(
        id: 'word-widget-board1',
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

      // Board 2: 3x3 with black cell at (0,2), word at row 0 has only 2 cells
      final board2 = GameBoard(
        id: 'word-widget-board2',
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

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            puzzleLoaderProvider.overrideWith((ref) async => currentBoard),
            flashClearDelayProvider.overrideWithValue(Duration.zero),
            wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
          ],
          child: Sizer(
            builder: (context, orientation, deviceType) => MaterialApp(
              home: Builder(
                builder: (context) => Consumer(
                  builder: (context, ref, _) {
                    final controller = CrosswordInputController(ref);
                    return CrosswordBody(controller: controller);
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(CrosswordBody)),
      );

      // Select (0,0) horizontal
      container
          .read(selectedCellProvider.notifier)
          .select(const SelectedCell(0, 0));
      container
          .read(wordDirectionProvider.notifier)
          .setDirection(WordDirection.horizontal);

      await tester.pump();

      // In board1, selected word at (0,0) horizontal should have 3 cells
      final wordCells1 = container.read(selectedWordCellsProvider);
      expect(
        wordCells1.length,
        equals(3),
        reason: 'Board1: word should have 3 cells',
      );
      expect(wordCells1, contains(const CellKey(0, 2)));

      // Switch to board2
      currentBoard = board2;
      container.refresh(puzzleLoaderProvider);
      await tester.pumpAndSettle();

      expect(
        container.read(gameBoardProvider).id,
        equals('word-widget-board2'),
      );

      // Selection might have been cleared, re-select (0,0) horizontal
      container
          .read(selectedCellProvider.notifier)
          .select(const SelectedCell(0, 0));
      container
          .read(wordDirectionProvider.notifier)
          .setDirection(WordDirection.horizontal);

      await tester.pump();

      // In board2, selected word at (0,0) horizontal should have 2 cells
      // because (0,2) is black
      final wordCells2 = container.read(selectedWordCellsProvider);
      expect(
        wordCells2.length,
        equals(2),
        reason: 'Board2: word should have 2 cells (not 3)',
      );
      expect(
        wordCells2,
        isNot(contains(const CellKey(0, 2))),
        reason: 'Board2: (0,2) should not be in word - it is black',
      );
    });
  });
}
