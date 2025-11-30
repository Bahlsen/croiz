import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/features/game/board_helpers.dart';

void main() {
  group('BoardHelpers', () {
    test('setWordSafe writes within bounds horizontally', () {
      final grid = List.generate(5, (_) => List<String?>.filled(5, null));
      grid.setWordSafe(1, 1, 'AbC', horizontal: true);
      expect(grid[1][1], 'A');
      expect(grid[1][2], 'B');
      expect(grid[1][3], 'C');
    });

    test('setWordSafe writes within bounds vertically', () {
      final grid = List.generate(5, (_) => List<String?>.filled(5, null));
      grid.setWordSafe(0, 0, 'xy', horizontal: false);
      expect(grid[0][0], 'X');
      expect(grid[1][0], 'Y');
    });

    test('setBlackCells marks given coords safely', () {
      final blacks = List.generate(4, (_) => List<bool>.filled(4, false));
      blacks.setBlackCells([[0, 0], [2, 3], [10, 10]]); // last out-of-bounds ignored
      expect(blacks[0][0], isTrue);
      expect(blacks[2][3], isTrue);
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
      final horiz = grid.wordBounds(1, 1, horizontal: true);
      expect(horiz, [1, 2]);

      // vertical from (1,1) should give bounds 1..2
      final vert = grid.wordBounds(1, 1, horizontal: false);
      expect(vert, [1, 2]);
    });
  });
}
