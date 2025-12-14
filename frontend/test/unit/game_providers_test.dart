import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  test('createSampleBoard produces expected in-memory 5x5 layout', () async {
    final board = await createSampleBoard();
    final container = ProviderContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
      ],
    );
    addTearDown(container.dispose);
    container.read(gameBoardProvider.notifier);

    expect(board.gridSize, equals(5));
    // Grid should be empty by default (not pre-filled)
    expect(board.grid[0][0], isNull);

    // Empty sample board has no black cells.
    expect(board.blackCells[0][0], isFalse);
    expect(board.blackCells[2][1], isFalse);
    expect(board.blackCells[0][3], isFalse);
  });
}
