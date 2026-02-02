import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/providers/game_board_notifier.dart';
import 'package:croiz/features/game/providers/game_state_providers.dart';
import 'package:croiz/features/game/providers/puzzle_loader_provider.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/services/audio_service.dart';
import '../helpers/test_helpers.dart';

class MockGameAudioService implements AudioService {
  int victoryCallCount = 0;
  int typeCallCount = 0;
  int deleteCallCount = 0;
  int successCallCount = 0;
  int revealCallCount = 0;

  @override
  Future<void> playReveal() async {
    revealCallCount++;
  }

  @override
  Future<void> playVictory() async {
    victoryCallCount++;
  }

  @override
  Future<void> playAchievement() async {}

  @override
  Future<void> playType() async {
    typeCallCount++;
  }

  @override
  Future<void> playDelete() async {
    deleteCallCount++;
  }

  @override
  Future<void> playSuccess() async {
    successCallCount++;
  }

  @override
  Future<void> get ready => Future.value();

  @override
  Future<void> dispose() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Victory sound behavior', () {
    test(
      'Should NOT play victory sound when loading an already completed puzzle',
      () async {
        final mockAudio = MockGameAudioService();

        final board = GameBoard(
          id: 'test-already-done',
          title: 'Already Done',
          gridSize: 3,
          createdAt: DateTime.now(),
          grid: [
            ['A', 'B', 'C'], // completed word
            [null, null, null],
            [null, null, null],
          ],
          clues: {},
          blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
          difficulty: 1,
          entries: [
            const PuzzleEntryData(
              number: 1,
              direction: 'across',
              x: 0,
              y: 0,
              length: 3,
              answer: 'ABC',
            ),
          ],
          solutionGrid: [
            ['A', 'B', 'C'],
            ['D', 'E', 'F'],
            ['G', 'H', 'I'],
          ],
        );

        final container = createTestContainer(
          audioService: mockAudio,
          overrides: [
            puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
          ],
        );
        addTearDown(container.dispose);

        // Pre-fill foundWords to simulate that this puzzle was already completed
        // before loading (e.g., loaded from persistent storage)
        container.read(foundWordsProvider.notifier).setFoundWords({
          '0,0,across',
        });

        // Initialize the board provider - this will trigger the restoration
        // and detection of completed words
        container.read(gameBoardProvider);

        // Wait for any async operations
        await Future.microtask(() {});

        // Verify the word was detected as complete
        expect(container.read(foundWordsProvider).length, equals(1));

        // Victory sound should NOT have been played (loading pre-completed puzzle)
        expect(mockAudio.victoryCallCount, equals(0));
      },
    );

    test(
      'Should play victory sound when completing the last word during gameplay',
      () async {
        final mockAudio = MockGameAudioService();

        final board = GameBoard(
          id: 'test-gameplay',
          title: 'Gameplay',
          gridSize: 3,
          createdAt: DateTime.now(),
          grid: [
            ['A', 'B', 'C'], // first word complete
            ['D', 'E', null], // second word incomplete
            [null, null, null],
          ],
          clues: {},
          blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
          difficulty: 1,
          entries: [
            const PuzzleEntryData(
              number: 1,
              direction: 'across',
              x: 0,
              y: 0,
              length: 3,
              answer: 'ABC',
            ),
            const PuzzleEntryData(
              number: 2,
              direction: 'across',
              x: 0,
              y: 1,
              length: 3,
              answer: 'DEF',
            ),
          ],
          solutionGrid: [
            ['A', 'B', 'C'],
            ['D', 'E', 'F'],
            ['G', 'H', 'I'],
          ],
        );

        final container = createTestContainer(
          audioService: mockAudio,
          overrides: [
            puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
          ],
        );
        addTearDown(container.dispose);

        // Initialize - one word already found, one incomplete
        container.read(foundWordsProvider.notifier).setFoundWords({
          '0,0,across',
        });
        container.read(gameBoardProvider);
        await Future.microtask(() {});

        // Verify puzzle is not yet complete
        expect(container.read(foundWordsProvider).length, equals(1));
        expect(mockAudio.victoryCallCount, equals(0));

        // Complete the last word by revealing the entry - this completes the puzzle
        container
            .read(gameBoardProvider.notifier)
            .revealEntry(
              const PuzzleEntryData(
                number: 2,
                direction: 'across',
                x: 0,
                y: 1,
                length: 3,
                answer: 'DEF',
              ),
            );
        await Future.microtask(() {});

        // Victory sound SHOULD have been played (completing during gameplay)
        expect(mockAudio.victoryCallCount, equals(1));
      },
    );

    test(
      'Should play victory sound when revealing completes the puzzle',
      () async {
        final mockAudio = MockGameAudioService();

        final board = GameBoard(
          id: 'test-reveal',
          title: 'Reveal Test',
          gridSize: 3,
          createdAt: DateTime.now(),
          grid: [
            ['A', 'B', null], // incomplete
            [null, null, null],
            [null, null, null],
          ],
          clues: {},
          blackCells: List.generate(3, (_) => List<bool>.filled(3, false)),
          difficulty: 1,
          entries: [
            const PuzzleEntryData(
              number: 1,
              direction: 'across',
              x: 0,
              y: 0,
              length: 3,
              answer: 'ABC',
            ),
          ],
          solutionGrid: [
            ['A', 'B', 'C'],
            ['D', 'E', 'F'],
            ['G', 'H', 'I'],
          ],
        );

        final container = createTestContainer(
          audioService: mockAudio,
          overrides: [
            puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
          ],
        );
        addTearDown(container.dispose);

        container.read(gameBoardProvider);
        await Future.microtask(() {});

        expect(mockAudio.victoryCallCount, equals(0));

        // Reveal the last letter to complete the puzzle
        container.read(gameBoardProvider.notifier).revealLetterAt(0, 2);
        await Future.microtask(() {});

        // Victory sound should play when revealing completes the puzzle
        expect(mockAudio.victoryCallCount, equals(1));
      },
    );
  });
}
