import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/services/incorrect_letter_cleaner.dart';

void main() {
  group('IncorrectLetterCleaner', () {
    test('does nothing when entries are null', () {
      final board = GameBoard(
        id: 't',
        title: 't',
        gridSize: 3,
        createdAt: DateTime.now(),
        grid: [
          ['A', 'B', null],
          [null, 'C', 'D'],
          [null, null, null],
        ],
        clues: {},
        blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
        difficulty: 1,
        entries: null,
      );

      final result = const IncorrectLetterCleaner().cleanWithResult(board);
      expect(result.board.grid, board.grid);
      expect(result.clearedCells, isEmpty);
    });

    test('clears letters that do not match known answers', () {
      const entries = [
        PuzzleEntryData(
          number: 1,
          direction: 'across',
          x: 0,
          y: 0,
          length: 3,
          answer: 'CAT',
        ),
      ];

      final board = GameBoard(
        id: 't',
        title: 't',
        gridSize: 3,
        createdAt: DateTime.now(),
        grid: [
          ['C', 'X', 'T'], // X is incorrect (should be A)
          [null, null, null],
          [null, null, null],
        ],
        clues: {},
        blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
        difficulty: 1,
        entries: entries,
      );

      final result = const IncorrectLetterCleaner().cleanWithResult(board);

      expect(result.board.grid[0][0], 'C');
      expect(result.board.grid[0][1], isNull); // was 'X' but expected 'A'
      expect(result.board.grid[0][2], 'T');
      expect(result.clearedCells, contains(const CellKey(0, 1)));
    });

    test('preserves nulls and only clears mismatches', () {
      const entries = [
        PuzzleEntryData(
          number: 1,
          direction: 'down',
          x: 1,
          y: 0,
          length: 3,
          answer: 'DOG',
        ),
      ];

      final grid = [
        [null, 'D', null],
        [null, 'O', 'X'], // X will be cleared since expected is G
        [null, 'G', null],
      ];

      final board = GameBoard(
        id: 't',
        title: 't',
        gridSize: 3,
        createdAt: DateTime.now(),
        grid: grid,
        clues: {},
        blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
        difficulty: 1,
        entries: entries,
      );

      final result = const IncorrectLetterCleaner().cleanWithResult(board);
      expect(result.board.grid[0][1], 'D');
      expect(result.board.grid[1][1], 'O');
      expect(
        result.board.grid[1][2],
        'X',
      ); // stays untouched because not part of entry
      expect(result.board.grid[2][1], 'G');
      expect(result.clearedCells, isNot(contains('1,2')));
    });
  });
}
