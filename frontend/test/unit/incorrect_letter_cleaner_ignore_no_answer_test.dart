import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/features/game/services/incorrect_letter_cleaner.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  group('IncorrectLetterCleaner - ignore entries without answer', () {
    const cleaner = IncorrectLetterCleaner();

    test('does not clear letters for entries with no answer', () {
      final board = GameBoard(
        id: 'b',
        title: 't',
        gridSize: 3,
        createdAt: DateTime.now(),
        grid: [
          ['X', 'Y', 'Z'],
          [null, null, null],
          [null, null, null],
        ],
        clues: {},
        blackCells: [
          [false, false, false],
          [false, false, false],
          [false, false, false],
        ],
        difficulty: 1,
        entries: const [
          // entry has no answer -> cleaner should ignore it
          PuzzleEntryData(number: 1, direction: 'across', x: 0, y: 0, length: 3),
        ],
      );

      final result = cleaner.cleanWithResult(board);

      // Since there is no expected answer, cleaner should not clear any
      // of the provided letters, so clearedCells should be empty and the
      // grid should remain unchanged for those cells.
      expect(result.clearedCells, isEmpty);
      expect(result.board.grid[0][0], equals('X'));
      expect(result.board.grid[0][1], equals('Y'));
      expect(result.board.grid[0][2], equals('Z'));
    });
  });
}
