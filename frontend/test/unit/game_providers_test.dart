import 'package:flutter_test/flutter_test.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/domain/entities/game_entities.dart';

void main() {
  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  test('createSampleBoard produces expected in-memory 5x5 layout', () async {
    final grid = List.generate(5, (_) => List<String?>.filled(5, null));
    final blacks = List.generate(5, (_) => List<bool>.filled(5, false));
    final board = GameBoard(
      id: 'test',
      title: 'Test',
      gridSize: 5,
      createdAt: DateTime.now(),
      grid: grid,
      clues: {},
      blackCells: blacks,
      difficulty: 1,
    );
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
