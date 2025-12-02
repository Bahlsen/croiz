import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  test('createSampleBoard produces expected sample 5x5 layout', () async {
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

    // Check some black cells from sample_5x5.json pattern
    expect(board.blackCells[0][3], isTrue); // (3,0) is black
    expect(board.blackCells[2][1], isTrue); // (1,2) is black
    // Ensure a word area is not black
    expect(board.blackCells[0][0], isFalse); // start of SOL
  });
}
