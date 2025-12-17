import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/game_providers.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/services/word_check_service.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/services/game_audio_service.dart';

class CountingWordCheckService extends WordCheckService {
  int calls = 0;
  final List<String> keysChecked = [];
  @override
  bool isWordComplete(GameBoard board, PuzzleEntryData entry) {
    calls++;
    keysChecked.add(getWordKey(entry));
    // Never mark complete to avoid side-effects like flashing/locking.
    return false;
  }
}

// Local mock for audio service to avoid real playback in tests.
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
  test('Per-cell completion checks only evaluate impacted entries', () {
    final counting = CountingWordCheckService();

    final container = ProviderContainer(
      overrides: [
        wordCheckServiceProvider.overrideWithValue(counting),
        gameAudioServiceProvider.overrideWithValue(MockGameAudioService()),
      ],
    );
    addTearDown(container.dispose);

    const size = 5;
    // Build a board with multiple entries, the cell (0,0) belongs to both across #1 and down #2
    const entries = [
      PuzzleEntryData(
        number: 1,
        direction: 'across',
        x: 0,
        y: 0,
        length: 3,
        answer: 'CAT',
      ),
      PuzzleEntryData(
        number: 2,
        direction: 'down',
        x: 0,
        y: 0,
        length: 3,
        answer: 'COD',
      ),
      PuzzleEntryData(number: 3, direction: 'across', x: 1, y: 0, length: 3),
      PuzzleEntryData(number: 4, direction: 'down', x: 2, y: 1, length: 2),
    ];
    final board = GameBoard(
      id: 'perf',
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
    container.read(selectedCellProvider.notifier).state = const SelectedCell(
      0,
      0,
    );
    container.read(wordDirectionProvider.notifier).state =
        WordDirection.horizontal;


    // Scheduled checks run later; assert immediate checks are limited.
    expect(
      counting.calls <= 2,
      true,
      reason: 'Expected no more than two entries checked for one cell change',
    );
    expect(
      counting.keysChecked.every((k) => k.startsWith('0,0,')),
      true,
      reason: 'Only entries containing (0,0) should be checked',
    );
  });
}
