import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/features/game/board_helpers.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Disabled cells', () {
    test('isDisabled returns true for black cells and out-of-bounds', () {
      final blacks = List.generate(5, (_) => List<bool>.filled(5, false));
      blacks[1][1] = true;

      expect(
        blacks.isDisabled(1, 1),
        isTrue,
        reason: 'black cell should be disabled',
      );
      expect(
        blacks.isDisabled(-1, 0),
        isTrue,
        reason: 'out of bounds row should be disabled',
      );
      expect(
        blacks.isDisabled(0, 5),
        isTrue,
        reason: 'out of bounds col should be disabled',
      );
      expect(
        blacks.isDisabled(0, 0),
        isFalse,
        reason: 'normal cell should not be disabled',
      );
    });

    test(
      'GameBoardNotifier.setLetter does not write to disabled cells',
      () async {
        // Build a small board with a known black cell.
        final base = createEmptyBoard(5);
        final blacks = List<List<bool>>.from(
          base.blackCells.map(List<bool>.from),
        );
        blacks[0][3] = true;
        final board = base.copyWith(blackCells: blacks);
        final container = ProviderContainer(
          overrides: [
            puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
          ],
        );
        addTearDown(container.dispose);
        final notifier = container.read(gameBoardProvider.notifier);

        // Known black cell: row=0, col=3
        expect(
          board.blackCells.isDisabled(0, 3),
          isTrue,
          reason: 'Expected black cell at row=0, col=3',
        );

        notifier.setLetter(0, 3, 'X');
        expect(
          notifier.state.grid[0][3],
          isNull,
          reason: 'setLetter should ignore black cells',
        );

        // Ensure writing to a non-black cell works
        const r = 0, c = 0;
        expect(board.blackCells.isDisabled(r, c), isFalse);
        notifier.setLetter(r, c, 'Z');
        expect(notifier.state.grid[r][c], equals('Z'));
      },
    );
  });
}
