import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/features/game/game_providers.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  test('createSampleBoard produces expected sample 5x5 layout', () async {
    final notifier = await createSampleBoard();
    final board = notifier.state;

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
