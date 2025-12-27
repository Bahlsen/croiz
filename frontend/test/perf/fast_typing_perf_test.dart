import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/services/word_check_service.dart';
import 'package:croiz/services/game_audio_service.dart';

class NoopWordCheckService extends WordCheckService {
  @override
  bool isWordComplete(GameBoard board, PuzzleEntryData entry) => false;
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
  test('fast typing stress test (measures latency)', () {
    final container = ProviderContainer(
      overrides: [
        wordCheckServiceProvider.overrideWithValue(NoopWordCheckService()),
        gameAudioServiceProvider.overrideWithValue(MockGameAudioService()),
        flashClearDelayProvider.overrideWithValue(Duration.zero),
      ],
    );
    addTearDown(container.dispose);

    const size = 12;
    // Create a simple board with long across entries so typing advances.
    final entries = <PuzzleEntryData>[];
    for (var r = 0; r < 8; r++) {
      entries.add(
        PuzzleEntryData(
          number: r + 1,
          direction: 'across',
          x: 0,
          y: r,
          length: 10,
        ),
      );
    }

    final board = GameBoard(
      id: 'perf-board',
      title: 'perf',
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

    final sw = Stopwatch()..start();
    // Simulate fast typing of 200 characters across board cells.
    const iterations = 200;
    // deterministic random removed; not needed for this test
    for (var i = 0; i < iterations; i++) {
      // Use deterministic letters A-Z
      final ch = String.fromCharCode(65 + (i % 26));
      controller.setLetterAndAdvance(ch);
      // Optionally introduce micro-yield to mimic UI event loop; none here.
    }
    sw.stop();

    // Ensure it completed in reasonable time. Threshold is generous to avoid
    // CI flakiness but still detect gross regressions.
    final elapsedMs = sw.elapsedMilliseconds;
    expect(
      elapsedMs < 2000,
      true,
      reason: 'Typing loop too slow: $elapsedMs ms',
    );
  });
}
