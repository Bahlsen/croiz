import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  test('GameBoard copyWith duplicates and overrides fields', () {
    final board = GameBoard(
      id: 'g1',
      title: 'T',
      gridSize: 3,
      createdAt: DateTime.utc(2020, 1, 1),
      grid: List.generate(3, (_) => List<String?>.filled(3, null)),
      clues: {'0,0': 'clue'},
      blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
      difficulty: 2,
    );

    final copy = board.copyWith(difficulty: 5);
    expect(copy.id, equals(board.id));
    expect(copy.difficulty, equals(5));
    // ensure grid is a deep copy
    expect(identical(copy.grid, board.grid), isFalse);
    expect(copy.clues['0,0'], 'clue');
  });
}
