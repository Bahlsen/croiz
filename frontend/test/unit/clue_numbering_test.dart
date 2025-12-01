import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/features/game/utils/clue_numbering.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  test('numbersFromBoard returns minimal number per start cell', () {
    final board = GameBoard(
      id: 'id',
      title: 't',
      gridSize: 5,
      createdAt: DateTime.now(),
      grid: List.generate(5, (_) => List<String?>.filled(5, null)),
      clues: {},
      blackCells: List.generate(5, (_) => List<bool>.filled(5, false)),
      difficulty: 1,
      entries: const [
        PuzzleEntryData(number: 3, direction: 'across', x: 1, y: 1, length: 3),
        PuzzleEntryData(number: 2, direction: 'down', x: 1, y: 1, length: 2),
        PuzzleEntryData(number: 5, direction: 'across', x: 2, y: 2, length: 2),
      ],
    );

    final numbers = ClueNumbering.numbersFromBoard(board);
    expect(numbers['1,1'], 2);
    expect(numbers['2,2'], 5);
    expect(numbers['0,0'], isNull);
  });

  test('numbersFromBoard ignores out-of-bounds entries', () {
    final board = GameBoard(
      id: 'id',
      title: 't',
      gridSize: 3,
      createdAt: DateTime.now(),
      grid: List.generate(3, (_) => List<String?>.filled(3, null)),
      clues: {},
      blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
      difficulty: 1,
      entries: const [
        PuzzleEntryData(number: 1, direction: 'across', x: 5, y: 5, length: 2),
      ],
    );

    final numbers = ClueNumbering.numbersFromBoard(board);
    expect(numbers.isEmpty, true);
  });
}
