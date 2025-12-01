import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/features/game/board_helpers.dart';

void main() {
  test('isDisabled detects out-of-bounds and black cells', () {
    final black = [
      [false, true],
      [false, false],
    ];
    expect(black.isDisabled(-1, 0), true);
    expect(black.isDisabled(0, -1), true);
    expect(black.isDisabled(0, 1), true);
    expect(black.isDisabled(1, 1), false);
  });

  test('nextSelectableFrom horizontal wrap across rows', () {
    final black = [
      [true, true],
      [true, false],
    ];
    // From row 0 col 1 moving right (dr=0, dc=1), should wrap to row 1 col 1
    final next = black.nextSelectableFrom(0, 1, 0, 1, wrap: true);
    expect(next, [1, 1]);
  });

  test('nextSelectableFrom vertical wrap across columns', () {
    final black = [
      [true, false],
      [true],
    ];
    // From row 0 col 0 moving down (dr=1, dc=0), should scan columns and find (0,1)
    final next = black.nextSelectableFrom(0, 0, 1, 0, wrap: true);
    expect(next, [0, 1]);
  });

  test('nextSelectableFrom horizontal wrap going left (dc < 0)', () {
    final black = [
      [false, true], // row0: selectable at col0 only
      [true, true],  // row1: all black
      [true, false], // row2: selectable at last col
    ];
    // Start at row0 col0 move left -> out of bounds triggers wrap scanning next rows right-to-left.
    // Row1 all black, then row2 finds col1 (last) selectable.
    final next = black.nextSelectableFrom(0, 0, 0, -1, wrap: true);
    expect(next, [2, 1]);
  });

  test('nextSelectableFrom vertical wrap moving up (dr < 0)', () {
    final black = [
      [true, true, false], // row0: selectable at col2
      [true, false, true], // row1: selectable at col1
      [true, true, true],  // row2: all black
    ];
    // From row1 col1 moving up -> linear hits row0 col1 (black), then row0 col1 -> continue until out-of-bounds.
    // Wrap: nextCol = (1+1)%3 = 2, scan rows bottom->top (dr<0) -> row2 col2 black, row1 col2 black, row0 col2 selectable.
    final next = black.nextSelectableFrom(1, 1, -1, 0, wrap: true);
    expect(next, [0, 2]);
  });
}
