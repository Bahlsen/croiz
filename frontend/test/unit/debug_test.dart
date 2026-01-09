import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/providers/game_board_notifier.dart';
import 'package:croiz/features/game/providers/puzzle_loader_provider.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import '../helpers/test_helpers.dart';

void main() {
  test('Minimal provider initialization test', () async {
    final board = GameBoard(
      id: 'debug',
      title: 'Debug',
      gridSize: 3,
      createdAt: DateTime.now(),
      grid: List.generate(3, (_) => List<String?>.filled(3, null)),
      clues: {},
      blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
      difficulty: 1,
    );

    final container = createTestContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
      ],
    );

    // This should not throw
    final state = container.read(gameBoardProvider);
    expect(state.id, equals('debug'));
  });
}
