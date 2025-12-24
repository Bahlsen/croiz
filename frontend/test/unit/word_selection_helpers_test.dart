import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/features/game/helpers/board_helpers.dart';

void main() {
  test('wordBounds horizontal and vertical', () {
    final black = [
      [false, false, true, false],
      [false, false, false, false],
    ];
    // Horizontal from (1,1): should expand to col 0..2 (stop before black at 2)
    final hv = black.wordBounds(1, 1, horizontal: true);
    expect(hv, [0, 1]);

    // Vertical from (0,1): should expand rows until black or bounds
    final vv = black.wordBounds(0, 1, horizontal: false);
    expect(vv, [0, 1]);
  });
}
