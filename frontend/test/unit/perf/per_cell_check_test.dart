import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/features/game/services/word_check_service.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/services/game_audio_service.dart';
import 'package:croiz/services/providers.dart';

class CountingWordCheckService extends WordCheckService {
  int calls = 0;

  @override
  bool isWordComplete(GameBoard board, PuzzleEntryData entry) {
    calls++;
    return false; // Don't mark complete in this instrumentation test.
  }
}

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

  @override
  Future<void> dispose() async {}
}

void main() {
  test('per-cell completion check limits isWordComplete invocations', () {
    final counting = CountingWordCheckService();

    final container = ProviderContainer(
      overrides: [
        wordCheckServiceProvider.overrideWithValue(counting),
        gameAudioServiceProvider.overrideWithValue(MockGameAudioService()),
        wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
      ],
    );
    addTearDown(container.dispose);

    final entries = <PuzzleEntryData>[];
    for (var r = 0; r < 20; r++) {
      entries.add(
        PuzzleEntryData(
          number: r + 1,
          direction: 'across',
          x: 0,
          y: r,
          length: 5,
        ),
      );
    }
    entries.add(
      const PuzzleEntryData(
        number: 100,
        direction: 'down',
        x: 0,
        y: 0,
        length: 5,
      ),
    );

    const size = 12;
    final board = GameBoard(
      id: 'test',
      title: 't',
      gridSize: size,
      createdAt: DateTime.now(),
      grid: List.generate(size, (_) => List<String?>.filled(size, null)),
      clues: const {},
      blackCells: List.generate(size, (_) => List<bool>.filled(size, false)),
      difficulty: 1,
      entries: entries,
    );

    container.read(gameBoardProvider.notifier).board = board;
    container.read(selectedCellProvider.notifier).value = const SelectedCell(
      0,
      0,
    );
    container.read(wordDirectionProvider.notifier).value =
        WordDirection.horizontal;

    final controller = CrosswordInputController.fromContainer(container);

    expect(counting.calls, 0);

    controller.setLetterAndAdvance('A');

    expect(counting.calls > 0, true);
    expect(
      counting.calls <= 3,
      true,
      reason: 'Expected limited per-cell checks, got ',
    );
  });
}
