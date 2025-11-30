// ignore_for_file: cascade_invocations, avoid_single_cascade_in_expression_statements

import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/features/game/board_helpers.dart';

void main() {
  group('BoardHelpers', () {
    test('setWordSafe writes within bounds horizontally', () {
      final grid = List.generate(5, (_) => List<String?>.filled(5, null));
      grid.setWordSafe(1, 1, 'AbC', horizontal: true);
      final row1 = grid[1];
      expect(row1.sublist(1, 4), ['A', 'B', 'C']);
    });

    test('setWordSafe writes within bounds vertically', () {
      final grid = List.generate(5, (_) => List<String?>.filled(5, null));
      grid.setWordSafe(0, 0, 'xy', horizontal: false);
      final col = [grid[0][0], grid[1][0]];
      expect(col, ['X', 'Y']);
    });

    test('setBlackCells marks given coords safely', () {
      final blacks = List.generate(4, (_) => List<bool>.filled(4, false));
      blacks.setBlackCells([[0, 0], [2, 3], [10, 10]]); // last out-of-bounds ignored
      expect([blacks[0][0], blacks[2][3]], [isTrue, isTrue]);
      // other cells remain false
      expect(blacks[1][1], isFalse);
    });

    test('wordBounds expands correctly for contiguous area', () {
      // false = not black, true = black
      final grid = [
        [true, true, true, true],
        [true, false, false, true],
        [true, false, false, true],
        [true, true, true, true],
      ];

      // horizontal from (1,1) should give bounds 1..2
      final g = grid;
      final horiz = g.wordBounds(1, 1, horizontal: true);
      expect(horiz, [1, 2]);

      // vertical from (1,1) should give bounds 1..2
      final vert = g.wordBounds(1, 1, horizontal: false);
      expect(vert, [1, 2]);
    });
  });
}
