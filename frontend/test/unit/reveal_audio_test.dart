import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/features/game/providers/game_board_provider.dart';
import 'package:croiz/features/game/providers/puzzle_loader_provider.dart';
import 'package:croiz/features/game/providers/game_state_providers.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/services/audio_service.dart';

class MockAudio implements AudioService {
  int success = 0;
  int victory = 0;
  @override
  Future<void> playSuccess() async => success++;

  @override
  Future<void> playVictory() async => victory++;

  @override
  Future<void> playDelete() async {}

  @override
  Future<void> playType() async {}

  @override
  Future<void> get ready => Future.value();

  @override
  Future<void> dispose() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('revealEntry should play success sound', () async {
    final mock = MockAudio();
    const entry = PuzzleEntryData(
      number: 1,
      direction: 'across',
      x: 0,
      y: 0,
      length: 3,
      answer: 'ABC',
    );

    final board = GameBoard(
      id: 't',
      title: 't',
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
      entries: [entry],
      solutionGrid: [
        ['A', 'B', 'C'],
        ['D', 'E', 'F'],
        ['G', 'H', 'I'],
      ],
    );

    final container = ProviderContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        flashClearDelayProvider.overrideWithValue(Duration.zero),
        wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        gameAudioServiceProvider.overrideWithValue(mock),
      ],
    );
    addTearDown(container.dispose);

    container.read(gameBoardProvider.notifier).revealEntry(entry);
    await Future.microtask(() {});
    expect(mock.success, greaterThan(0));
  });

  test('revealEntry should NOT play success sound when muted', () async {
    final mock = MockAudio();
    const entry = PuzzleEntryData(
      number: 1,
      direction: 'across',
      x: 0,
      y: 0,
      length: 3,
      answer: 'ABC',
    );

    final board = GameBoard(
      id: 't',
      title: 't',
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
      entries: [entry],
      solutionGrid: [
        ['A', 'B', 'C'],
        ['D', 'E', 'F'],
        ['G', 'H', 'I'],
      ],
    );

    final container = ProviderContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        flashClearDelayProvider.overrideWithValue(Duration.zero),
        wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        gameAudioServiceProvider.overrideWithValue(mock),
      ],
    );
    addTearDown(container.dispose);

    // Set mute via the notifier rather than trying to override the NotifierProvider.
    container.read(gameAudioMutedProvider.notifier).setMuted(muted: true);

    container.read(gameBoardProvider.notifier).revealEntry(entry);
    await Future.microtask(() {});
    expect(mock.success, equals(0));
  });

  test('revealAll should play success when new words revealed', () async {
    final mock = MockAudio();
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
      id: 't',
      title: 't',
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
        ['D', 'E', 'F'],
        ['G', 'H', 'I'],
      ],
    );

    final container = ProviderContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        flashClearDelayProvider.overrideWithValue(Duration.zero),
        wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        gameAudioServiceProvider.overrideWithValue(mock),
      ],
    );
    addTearDown(container.dispose);

    container.read(gameBoardProvider.notifier).revealAll();
    await Future.microtask(() {});
    expect(mock.success, greaterThan(0));
  });

  test('revealAll should NOT play success when muted', () async {
    final mock = MockAudio();
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
      id: 't',
      title: 't',
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
        ['D', 'E', 'F'],
        ['G', 'H', 'I'],
      ],
    );

    final container = ProviderContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        flashClearDelayProvider.overrideWithValue(Duration.zero),
        wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        gameAudioServiceProvider.overrideWithValue(mock),
      ],
    );
    addTearDown(container.dispose);

    container.read(gameAudioMutedProvider.notifier).setMuted(muted: true);

    container.read(gameBoardProvider.notifier).revealAll();
    await Future.microtask(() {});
    expect(mock.success, equals(0));
  });

  test('revealEntry should be a no-op when entry already found', () async {
    final mock = MockAudio();
    const entry = PuzzleEntryData(
      number: 1,
      direction: 'across',
      x: 0,
      y: 0,
      length: 3,
      answer: 'ABC',
    );

    final board = GameBoard(
      id: 't',
      title: 't',
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
      entries: [entry],
      solutionGrid: [
        ['A', 'B', 'C'],
        ['D', 'E', 'F'],
        ['G', 'H', 'I'],
      ],
    );

    final container = ProviderContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        flashClearDelayProvider.overrideWithValue(Duration.zero),
        wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        gameAudioServiceProvider.overrideWithValue(mock),
      ],
    );
    addTearDown(container.dispose);

    // Mark the entry as already found before calling revealEntry
    final wordCheck = container.read(wordCheckServiceProvider);
    final key = wordCheck.getWordKey(entry);
    container.read(foundWordsProvider.notifier).setFoundWords({key});

    container.read(gameBoardProvider.notifier).revealEntry(entry);
    await Future.microtask(() {});

    // No audio should have been played and flashing set should be empty
    expect(mock.success, equals(0));
    final flashing = container.read(flashingCellsProvider);
    expect(flashing, isEmpty);
  });

  test('revealEntry second call should not replay audio', () async {
    final mock = MockAudio();
    const entry = PuzzleEntryData(
      number: 1,
      direction: 'across',
      x: 0,
      y: 0,
      length: 3,
      answer: 'ABC',
    );

    final board = GameBoard(
      id: 't',
      title: 't',
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
      entries: [entry],
      solutionGrid: [
        ['A', 'B', 'C'],
        ['D', 'E', 'F'],
        ['G', 'H', 'I'],
      ],
    );

    final container = ProviderContainer(
      overrides: [
        puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
        flashClearDelayProvider.overrideWithValue(Duration.zero),
        wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
        gameAudioServiceProvider.overrideWithValue(mock),
      ],
    );
    addTearDown(container.dispose);

    // First reveal: should play
    container.read(gameBoardProvider.notifier).revealEntry(entry);
    await Future.microtask(() {});
    expect(mock.success, greaterThan(0));

    final before = mock.success;
    // Second reveal: should not play again
    container.read(gameBoardProvider.notifier).revealEntry(entry);
    await Future.microtask(() {});
    expect(mock.success, equals(before));
  });

  test(
    'revealAll should NOT play victory sound when puzzle already completed',
    () async {
      final mock = MockAudio();
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
        id: 't',
        title: 't',
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
          ['D', 'E', 'F'],
          ['G', 'H', 'I'],
        ],
      );

      final container = ProviderContainer(
        overrides: [
          puzzleLoaderProvider.overrideWithValue(AsyncValue.data(board)),
          flashClearDelayProvider.overrideWithValue(Duration.zero),
          wordCheckDebounceDelayProvider.overrideWithValue(Duration.zero),
          gameAudioServiceProvider.overrideWithValue(mock),
        ],
      );
      addTearDown(container.dispose);

      // First revealAll: should play victory sound (puzzle completed)
      container.read(gameBoardProvider.notifier).revealAll();
      await Future.microtask(() {});
      expect(mock.victory, equals(1));

      // Second revealAll on already completed puzzle: should NOT play victory sound
      container.read(gameBoardProvider.notifier).revealAll();
      await Future.microtask(() {});
      expect(mock.victory, equals(1)); // Should still be 1, not 2
    },
  );
}
