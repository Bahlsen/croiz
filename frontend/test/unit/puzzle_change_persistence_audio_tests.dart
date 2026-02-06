import 'package:flutter_test/flutter_test.dart';
import '../helpers/fake_puzzle_storage.dart';
import 'package:croiz/features/game/providers/game_timer_provider.dart';
import 'package:croiz/features/game/providers/puzzle_loader_provider.dart';
import 'package:croiz/features/game/providers/game_board_notifier.dart';
import 'package:croiz/domain/entities/game_entities.dart';

import '../helpers/fake_audio_service.dart';
import '../helpers/test_helpers.dart';

class FakeGameTimer extends GameTimer {
  FakeGameTimer(super.ref, super.gameId);
  int? lastSetElapsed;

  @override
  Future<void> setElapsed(int seconds) async {
    lastSetElapsed = seconds;
    await super.setElapsed(seconds);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Puzzle change persistence & audio', () {
    test('GameTimer.setElapsed called from persisted payload', () async {
      final board = GameBoard(
        id: 'persist-1',
        title: 'persist',
        gridSize: 2,
        createdAt: DateTime.now(),
        grid: [
          [null, null],
          [null, null],
        ],
        clues: {},
        blackCells: List.generate(2, (_) => List<bool>.filled(2, false)),
        difficulty: 1,
        entries: [],
        solutionGrid: [
          [null, null],
          [null, null],
        ],
      );

      // Prepare Hive box with stored payload containing elapsedSeconds
      final storage = FakePuzzleStorage();
      final payload = {'elapsedSeconds': 42};
      await storage.save(board.id, payload);

      final container = createTestContainer(
        storage: storage,
        overrides: [
          // Replace GameTimer instances with a fake that records setElapsed
          gameTimerProvider.overrideWith(FakeGameTimer.new),
          puzzleLoaderProvider.overrideWith((ref) async => board),
        ],
      );
      addTearDown(() async {
        container.dispose();
      });

      // Trigger load and ensure gameBoard provider is built so its
      // _onPuzzleLoaderChanged runs and processes stored payload.
      await container.read(puzzleLoaderProvider.future);
      // Build the gameBoardProvider to attach listeners
      container.read(gameBoardProvider);
      // Give async restore time to run
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // The GameTimer override should have recorded setElapsed
      final timer =
          container.read(gameTimerProvider(board.id)) as FakeGameTimer;
      expect(timer.lastSetElapsed, equals(42));
    });

    test('revealEntry triggers audio when not muted', () async {
      final entries = [
        const PuzzleEntryData(
          number: 1,
          direction: 'across',
          x: 0,
          y: 0,
          length: 3,
          answer: 'ABC',
        ),
      ];

      final board = GameBoard(
        id: 'audio-1',
        title: 'audio',
        gridSize: 3,
        createdAt: DateTime.now(),
        grid: [
          [null, null, null],
          [null, null, null],
          [null, null, null],
        ],
        clues: {},
        blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
        difficulty: 1,
        entries: entries,
        solutionGrid: [
          ['A', 'B', 'C'],
          [null, null, null],
          [null, null, null],
        ],
      );

      final fakeAudio = FakeAudioService();

      final container = createTestContainer(
        audioService: fakeAudio,
        overrides: [puzzleLoaderProvider.overrideWith((ref) async => board)],
      );
      addTearDown(() async => container.dispose());

      await container.read(puzzleLoaderProvider.future);
      await Future.microtask(() {});

      // Ensure board built
      container.read(gameBoardProvider);

      // Reveal entry should play success sound
      container.read(gameBoardProvider.notifier).revealEntry(entries[0]);

      expect(fakeAudio.successCount, greaterThanOrEqualTo(1));
    });
  });
}
