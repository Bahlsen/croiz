import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/services/game_audio_service.dart';

// Mock pour le service audio
class MockGameAudioService implements GameAudioService {
  @override
  Future<void> playType() async {}

  @override
  Future<void> playDelete() async {}

  @override
  Future<void> playSuccess() async {}
  @override
  Future<void> playVictory() async {}

  @override
  Future<void> get ready => Future<void>.value();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('typing a letter sets it and advances selection', () {
    final container = ProviderContainer(
      overrides: [
        gameAudioServiceProvider.overrideWithValue(MockGameAudioService()),
      ],
    );
    addTearDown(container.dispose);

    // Initialize board and selection
    final board = container.read(gameBoardProvider);
    container.read(selectedCellProvider.notifier).state = const SelectedCell(
      0,
      0,
    );

    final controller = CrosswordInputController.fromContainer(container);

    // Build a KeyDownEvent for letter 'a'
    const event = KeyDownEvent(
      logicalKey: LogicalKeyboardKey.keyA,
      physicalKey: PhysicalKeyboardKey.keyA,
      timeStamp: Duration(milliseconds: 1),
    );

    controller.handleKey(event, board.gridSize);

    final updated = container.read(gameBoardProvider);
    expect(updated.grid[0][0], 'A');

    final sel = container.read(selectedCellProvider);
    expect(sel != null, true);
    // After typing horizontally, selection should move to col 1
    expect(sel!.row, 0);
    expect(sel.col, 1);
  });

  test('typing on a locked cell inserts into next selectable cell', () {
    final container = ProviderContainer(
      overrides: [
        gameAudioServiceProvider.overrideWithValue(MockGameAudioService()),
      ],
    );
    addTearDown(container.dispose);

    // ensure selection
    container.read(selectedCellProvider.notifier).state = const SelectedCell(
      0,
      0,
    );

    // lock the current cell
    container.read(lockedCellsProvider.notifier).value = <String>{'0,0'};

    final updated = container.read(gameBoardProvider);
    // The locked cell remains empty
    expect(updated.grid[0][0], isNull);
    // The next cell should have the inserted letter
    expect(updated.grid[0][1], 'B');

    final sel = container.read(selectedCellProvider);
    expect(sel, isNotNull);
    // After inserting into next cell, selection advances to the following cell
    expect(sel!.row, 0);
    expect(sel.col, 2);
  });
}
