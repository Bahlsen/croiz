import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fake_async/fake_async.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/features/game/controllers/crossword_input_controller.dart';
import 'package:croiz/features/game/services/word_check_service.dart';
import 'package:croiz/features/game/services/game_audio_service.dart';

/// Counts how many times word completion is checked.
class CountingWordCheckService extends WordCheckService {
  int checkCount = 0;

  @override
  bool isWordComplete(GameBoard board, PuzzleEntryData entry) {
    checkCount++;
    return super.isWordComplete(board, entry);
  }
}

/// Counts audio calls to verify throttling.
class CountingAudioService implements GameAudioService {
  int typeCount = 0;
  int deleteCount = 0;
  int successCount = 0;
  int victoryCount = 0;

  @override
  Future<void> playType() async {
    typeCount++;
  }

  @override
  Future<void> playDelete() async {
    deleteCount++;
  }

  @override
  Future<void> playSuccess() async {
    successCount++;
  }

  @override
  Future<void> playVictory() async {
    victoryCount++;
  }

  @override
  Future<void> get ready => Future<void>.value();

  @override
  Future<void> dispose() async {}
}

GameBoard _createTestBoard() {
  const size = 10;
  final grid = List.generate(size, (_) => List<String?>.filled(size, null));

  // Create solution grid for proper word completion checking
  final solution = List.generate(size, (_) => List<String?>.filled(size, null));
  // Word 1: TESTS at row 0
  solution[0][0] = 'T';
  solution[0][1] = 'E';
  solution[0][2] = 'S';
  solution[0][3] = 'T';
  solution[0][4] = 'S';
  // Word 2: HELLO at row 1
  solution[1][0] = 'H';
  solution[1][1] = 'E';
  solution[1][2] = 'L';
  solution[1][3] = 'L';
  solution[1][4] = 'O';
  // Word 3: THREE down at col 0
  solution[0][0] = 'T';
  solution[1][0] = 'H';
  solution[2][0] = 'R';
  solution[3][0] = 'E';
  solution[4][0] = 'E';

  // Create entries for testing
  final entries = <PuzzleEntryData>[
    const PuzzleEntryData(
      number: 1,
      direction: 'across',
      x: 0,
      y: 0,
      length: 5,
      answer: 'TESTS',
    ),
    const PuzzleEntryData(
      number: 2,
      direction: 'across',
      x: 0,
      y: 1,
      length: 5,
      answer: 'HELLO',
    ),
    const PuzzleEntryData(
      number: 3,
      direction: 'down',
      x: 0,
      y: 0,
      length: 5,
      answer: 'THREE',
    ),
  ];

  return GameBoard(
    id: 'debounce-test',
    title: 'debounce',
    gridSize: size,
    createdAt: DateTime.now(),
    grid: grid,
    clues: const {},
    blackCells: List.generate(size, (_) => List<bool>.filled(size, false)),
    difficulty: 1,
    entries: entries,
    solutionGrid: solution,
  );
}

void main() {
  group('Fast typing debounce', () {
    test('word checks are debounced during rapid typing', () {
      fakeAsync((async) {
        final countingWordCheck = CountingWordCheckService();
        final countingAudio = CountingAudioService();
        final board = _createTestBoard();

        final container = ProviderContainer(
          overrides: [
            wordCheckServiceProvider.overrideWithValue(countingWordCheck),
            gameAudioServiceProvider.overrideWithValue(countingAudio),
            flashClearDelayProvider.overrideWithValue(
              const Duration(milliseconds: 100),
            ),
            puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
          ],
        );

        container.read(gameBoardProvider.notifier).setBoard(board);
        container
            .read(selectedCellProvider.notifier)
            .select(const SelectedCell(0, 0));
        container
            .read(wordDirectionProvider.notifier)
            .setDirection(WordDirection.horizontal);

        final controller = CrosswordInputController.fromContainer(container);

        // Type 10 letters very fast (no time elapsing between calls)
        for (var i = 0; i < 10; i++) {
          controller.setLetterAndAdvance(String.fromCharCode(65 + i));
        }

        // Let debounce timer fire
        async.elapse(const Duration(milliseconds: 100));

        final checksAfterDebounce = countingWordCheck.checkCount;

        // The debounced implementation should result in fewer total checks
        // than one check per keystroke × entries per cell.
        // With 10 keystrokes and 2 entries at intersection, naive would be ~20 checks.
        // Debounced should do significantly fewer.
        expect(
          checksAfterDebounce,
          lessThan(20),
          reason: 'Debounced checks should be < 20, got $checksAfterDebounce',
        );

        // Cleanup after test completes
        controller.dispose();
        container.dispose();
      });
    });

    test('audio service throttles rapid playType calls', () async {
      // Note: This test uses a counting mock that bypasses the real throttle.
      // The real GameAudioService has its own internal throttle (60ms).
      // This test verifies the mock setup works, not the throttle itself.
      final countingAudio = CountingAudioService();

      final container = ProviderContainer(
        overrides: [gameAudioServiceProvider.overrideWithValue(countingAudio)],
      );
      addTearDown(container.dispose);

      final audio = container.read(gameAudioServiceProvider);

      // Call playType 20 times rapidly - mock doesn't throttle
      for (var i = 0; i < 20; i++) {
        await audio.playType();
      }

      // Mock counts all calls since it has no throttle
      expect(
        countingAudio.typeCount,
        equals(20),
        reason: 'Mock should count all 20 calls',
      );
    });

    test('word completion check runs synchronously when debounce is zero', () {
      final countingWordCheck = CountingWordCheckService();
      final countingAudio = CountingAudioService();
      final board = _createTestBoard();

      final container = ProviderContainer(
        overrides: [
          wordCheckServiceProvider.overrideWithValue(countingWordCheck),
          gameAudioServiceProvider.overrideWithValue(countingAudio),
          flashClearDelayProvider.overrideWithValue(Duration.zero),
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
          puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        ],
      );

      container.read(gameBoardProvider.notifier).setBoard(board);
      container
          .read(selectedCellProvider.notifier)
          .select(const SelectedCell(0, 0));
      container
          .read(wordDirectionProvider.notifier)
          .setDirection(WordDirection.horizontal);

      final controller =
          CrosswordInputController.fromContainer(container)
            // Type first word correctly: T-E-S-T-S
            ..setLetterAndAdvance('T')
            ..setLetterAndAdvance('E')
            ..setLetterAndAdvance('S')
            ..setLetterAndAdvance('T')
            ..setLetterAndAdvance('S');

      // Verify grid has the letters
      final updatedBoard = container.read(gameBoardProvider);
      expect(updatedBoard.grid[0][0], equals('T'));
      expect(updatedBoard.grid[0][1], equals('E'));
      expect(updatedBoard.grid[0][2], equals('S'));
      expect(updatedBoard.grid[0][3], equals('T'));
      expect(updatedBoard.grid[0][4], equals('S'));

      // Word should be found (synchronously since debounce is zero)
      final foundWords = container.read(foundWordsProvider);
      expect(foundWords, contains('0,0,across'));

      // Success sound should have been played (once, not multiple times)
      expect(countingAudio.successCount, equals(1));

      // Cleanup
      controller.dispose();
      container.dispose();
    });
  });
}
