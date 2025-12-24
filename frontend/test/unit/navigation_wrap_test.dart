import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/features/game/helpers/board_helpers.dart';

void main() {
  group('nextSelectableFrom wrap-around', () {
    test('horizontal: moves to next row when at end of row', () {
      final blacks = List.generate(3, (_) => List<bool>.filled(3, false));

      // start at row 0, col 2 (end of row), move right -> should go to row1,col0
      final next = blacks.nextSelectableFrom(0, 2, 0, 1, wrap: true);
      expect(next, isNotNull);
      expect(next, [1, 0]);
    });

    test('horizontal: wrap from last row to first row', () {
      final blacks = List.generate(3, (_) => List<bool>.filled(3, false));

      // start at last cell (2,2), move right -> should wrap to (0,0)
      final next = blacks.nextSelectableFrom(2, 2, 0, 1, wrap: true);
      expect(next, isNotNull);
      expect(next, [0, 0]);
    });

    test('vertical: moves to next column when at bottom', () {
      final blacks = List.generate(3, (_) => List<bool>.filled(3, false));

      // start at row 2, col 0, move down -> should go to col1 at topmost selectable (0,1)
      final next = blacks.nextSelectableFrom(2, 0, 1, 0, wrap: true);
      expect(next, isNotNull);
      expect(next, [0, 1]);
    });

    test('skips disabled cells and finds next available', () {
      final blacks = List.generate(3, (_) => List<bool>.filled(3, false));
      // make row1 entirely disabled
      blacks[1] = List<bool>.filled(3, true);

      // start at row0,col2 moving right: linear advance hits out-of-bounds, next row is disabled,
      // should continue to row2 and pick first available col (0)
      final next = blacks.nextSelectableFrom(0, 2, 0, 1, wrap: true);
      expect(next, isNotNull);
      expect(next, [2, 0]);
    });

    test('returns null when no selectable exists', () {
      final blacks = List.generate(2, (_) => List<bool>.filled(2, true));
      final next = blacks.nextSelectableFrom(0, 0, 0, 1, wrap: true);
      expect(next, isNull);
    });
  });
}
