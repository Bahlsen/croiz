import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/features/game/board_helpers.dart';
import 'package:croiz/features/game/game_providers.dart';

void main() {
  group('Disabled cells', () {
    test('isDisabled returns true for black cells and out-of-bounds', () {
      final blacks = List.generate(5, (_) => List<bool>.filled(5, false));
      blacks[1][1] = true;

      expect(blacks.isDisabled(1, 1), isTrue, reason: 'black cell should be disabled');
      expect(blacks.isDisabled(-1, 0), isTrue, reason: 'out of bounds row should be disabled');
      expect(blacks.isDisabled(0, 5), isTrue, reason: 'out of bounds col should be disabled');
      expect(blacks.isDisabled(0, 0), isFalse, reason: 'normal cell should not be disabled');
    });

    test('GameBoardNotifier.setLetter does not write to disabled cells', () {
      final notifier = createSampleBoard();
      final board = notifier.state;

      // Known black cell from sample: (0,0)
      expect(board.blackCells.isDisabled(0, 0), isTrue);

      notifier.setLetter(0, 0, 'X');
      expect(notifier.state.grid[0][0], isNull, reason: 'setLetter should ignore black cells');

      // Ensure writing to a non-black cell works
      final r = 2, c = 0; // part of word SOL in sample
      expect(board.blackCells.isDisabled(r, c), isFalse);
      notifier.setLetter(r, c, 'Z');
      expect(notifier.state.grid[r][c], equals('Z'));
    });
  });
}
