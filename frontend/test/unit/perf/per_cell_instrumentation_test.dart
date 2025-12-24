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
    return false;
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
  test(
    'instrumentation: isWordComplete called only for entries touching changed cell',
    () {
      final counting = CountingWordCheckService();
      final container = ProviderContainer(
        overrides: [
          wordCheckServiceProvider.overrideWithValue(counting),
          gameAudioServiceProvider.overrideWithValue(MockGameAudioService()),
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        ],
      );
      addTearDown(container.dispose);

      // Create entries where only two include (0,0)
      final entries =
          List<PuzzleEntryData>.generate(
              10,
              (r) => PuzzleEntryData(
                number: r + 1,
                direction: 'across',
                x: 1,
                y: r,
                length: 4,
              ),
            )
            // Two entries include (0,0)
            ..add(
              const PuzzleEntryData(
                number: 100,
                direction: 'across',
                x: 0,
                y: 0,
                length: 3,
              ),
            )
            ..add(
              const PuzzleEntryData(
                number: 101,
                direction: 'down',
                x: 0,
                y: 0,
                length: 3,
              ),
            );

      const size = 8;
      final board = GameBoard(
        id: 'instr',
        title: 'instr',
        gridSize: size,
        createdAt: DateTime.now(),
        grid: List.generate(size, (_) => List<String?>.filled(size, null)),
        clues: const {},
        blackCells: List.generate(size, (_) => List<bool>.filled(size, false)),
        difficulty: 1,
        entries: entries,
      );

      container
        ..read(gameBoardProvider.notifier).board = board
        ..read(selectedCellProvider.notifier).value = const SelectedCell(0, 0)
        ..read(wordDirectionProvider.notifier).value = WordDirection.horizontal;

      CrosswordInputController.fromContainer(
        container,
      ).setLetterAndAdvance('X');

      // Expect only a small number of checks (the two entries that include cell),
      // plus possible small overhead. Assert <= 4.
      expect(counting.calls > 0, true);
      expect(
        counting.calls <= 4,
        true,
        reason: 'Too many isWordComplete calls: ${counting.calls}',
      );
    },
  );
}
