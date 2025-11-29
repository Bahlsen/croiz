import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/features/game/game_providers.dart';

void main() {
  test('createSampleBoard produces expected sample layout', () {
    final notifier = createSampleBoard();
    final board = notifier.state;

    expect(board.gridSize, equals(13));
    // check that some known word letters are placed uppercase
    expect(board.grid[2][0], equals('S'));
    expect(board.grid[2][5], equals('A'));
    expect(board.grid[2][10], isNotNull);

    // check some black cells from the pattern
    expect(board.blackCells[0][0], isTrue);
    expect(board.blackCells[0][11], isTrue);
    // ensure a word area is not black
    expect(board.blackCells[2][0], isFalse);
  });
}
